﻿&НаКлиенте
Процедура ВыполнитьДействие(Команда)
	стрДействие=?(ТипЗнч(Команда)=Тип("Строка"), Команда, Команда.Имя);
	Если стрДействие="ОК" Тогда
		Если Элементы.тзЗаказыПометка.Видимость Тогда //Множественный выбор
			МассивСделок=Новый Массив;
			Для каждого СтрокаКоллекции Из тзЗаказы Цикл
				Если НЕ СтрокаКоллекции.Пометка Тогда Продолжить; КонецЕсли;
				МассивСделок.Добавить(СтрокаКоллекции.Заказ);
			КонецЦикла;
			ЭтаФорма.Закрыть(МассивСделок);
		Иначе
			СтрокаТабличногоПоля=Элементы.тзЗаказы.ТекущиеДанные;
			Если НЕ СтрокаТабличногоПоля=Неопределено Тогда
				ОповеститьОВыборе(СтрокаТабличногоПоля.Заказ);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Страницы_ПриСменеСтраницы(Элемент, ТекущаяСтраница)
	ПереместитьЭлемент(ТекущаяСтраница.Имя);
	ВидРегистраУстановить(стрЗаменить(ТекущаяСтраница.Имя, "Страница_", ""));
	тпЗаказы_Заполнить();
КонецПроцедуры

&НаСервере
Процедура ПереместитьЭлемент(стрРодитель)
	Для каждого СтрокаКоллекции Из Элементы.Страницы.ПодчиненныеЭлементы Цикл
		Элементы["РеквизитВидимость_"+СтрокаКоллекции.Имя].Видимость=Истина;
	КонецЦикла;
	Элементы.Переместить(Элементы.тзЗаказы, Элементы[стрРодитель]);
	Элементы["РеквизитВидимость_"+стрРодитель].Видимость=Ложь;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий "Вид регистры"

&НаКлиенте
Процедура ВидРегистраВыбрать(Команда)
	ВидРегистра=Команда.Имя;
	Элементы.кпЗаказы_ВидРегистра.Заголовок="Регистр ("+Элементы[Команда.Имя].Заголовок+")";
	тпЗаказы_Заполнить();
КонецПроцедуры

&НаКлиенте
Процедура ВидРегистраУстановить(стрИмя)
	Элементы.УчетПотребностей.Видимость=Ложь;
	Элементы.ВнутренниеЗаказы.Видимость=Ложь;
	Элементы.ЗаказыПокупателей.Видимость=Ложь;
	Элементы.ЗаказыНаПроизводство.Видимость=Ложь;
	Элементы.ЗаказыПоставщикам.Видимость=Ложь;
	
	Если стрИмя="ВнутреннийЗаказ" Тогда
		Элементы.УчетПотребностей.Видимость=Истина;
		Элементы.ВнутренниеЗаказы.Видимость=Истина;
		ВидРегистра="ВнутренниеЗаказы"; 
		Элементы.кпЗаказы_ВидРегистра.Заголовок="Регистр (внутренние заказы)";

	ИначеЕсли стрИмя="ЗаказНаПроизводство" Тогда
		Элементы.УчетПотребностей.Видимость=Истина;
		Элементы.ЗаказыНаПроизводство.Видимость=Истина;
		ВидРегистра="ЗаказыНаПроизводство";
		Элементы.кпЗаказы_ВидРегистра.Заголовок="Регистр (заказы на производство)";

	ИначеЕсли стрИмя="ЗаказПокупателя" Тогда
		Элементы.УчетПотребностей.Видимость=Истина;
		Элементы.ЗаказыПокупателей.Видимость=Истина;
		ВидРегистра="ЗаказыПокупателей";
		Элементы.кпЗаказы_ВидРегистра.Заголовок="Регистр (учет покупателей)";

	ИначеЕсли стрИмя="ЗаказПоставщику" Тогда
		Элементы.ЗаказыПоставщикам.Видимость=Истина;
		ВидРегистра="ЗаказыПоставщикам";
		Элементы.кпЗаказы_ВидРегистра.Заголовок="Регистр (заказы поставщикам)";
	КонецЕсли;
КонецПроцедуры
 
////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Заказы"

&НаКлиенте
Процедура тпЗаказы_ВыполнитьДействие(Команда)
	Если Команда.Имя="Обновить" Тогда
		тпЗаказы_Заполнить();
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Процедура тпЗаказы_Заполнить()
	тзЗаказы.Очистить();
	
	Если НЕ СтруктураПараметров.Свойство("ДоговорКонтрагента") Тогда
		СтруктураПараметров.Вставить("ДоговорКонтрагента", Неопределено);
	КонецЕсли;
	Если НЕ СтруктураПараметров.Свойство("Контрагент") Тогда
		СтруктураПараметров.Вставить("Контрагент", Неопределено);
	КонецЕсли;
	
	Если ВидРегистра="УчетПотребностей" Тогда
		стрИмяИзмерения_Заказ="ДокументРезерва";
	ИначеЕсли ВидРегистра="ЗаказыПоставщикам" Тогда
		стрИмяИзмерения_Заказ="ЗаказПоставщику";
	ИначеЕсли ВидРегистра="ЗаказыПокупателей" Тогда
		стрИмяИзмерения_Заказ="ЗаказПокупателя";
	ИначеЕсли ВидРегистра="ЗаказыНаПроизводство" Тогда
		стрИмяИзмерения_Заказ="ЗаказНаряд";
	ИначеЕсли ВидРегистра="ВнутренниеЗаказы" Тогда
		стрИмяИзмерения_Заказ="ВнутреннийЗаказ";
	КонецЕсли;
	
	мдИзмерения=Метаданные.РегистрыНакопления[ВидРегистра].Измерения;
	
	стрУсловие="Организация = &Организация";
	Если НЕ мдИзмерения.Найти("Склад")=Неопределено И ЗначениеЗаполнено(СтруктураПараметров.Склад) Тогда
		стрУсловие=стрУсловие+" И Склад = &Склад";
	КонецЕсли;
	Если НЕ мдИзмерения.Найти("Номенклатура")=Неопределено И ЗначениеЗаполнено(СтруктураПараметров.Номенклатура) Тогда
		стрУсловие=стрУсловие+" И Номенклатура = &Номенклатура";
	КонецЕсли;
	Если НЕ мдИзмерения.Найти("ХарактеристикаНоменклатуры")=Неопределено И ЗначениеЗаполнено(СтруктураПараметров.ХарактеристикаНоменклатуры) Тогда
		стрУсловие=стрУсловие+" И ХарактеристикаНоменклатуры = &ХарактеристикаНоменклатуры";
	КонецЕсли; 
	Если НЕ мдИзмерения.Найти("СерияНоменклатуры")=Неопределено И ЗначениеЗаполнено(СтруктураПараметров.СерияНоменклатуры) Тогда
		стрУсловие=стрУсловие+" И СерияНоменклатуры = &СерияНоменклатуры";
	КонецЕсли;
	
	Если ВидРегистра="ЗаказыПоставщикам" Или ВидРегистра="ЗаказыПокупателей" Тогда
		Если ЗначениеЗаполнено(СтруктураПараметров.ДоговорКонтрагента) Тогда
			стрУсловие=стрУсловие+" И ДоговорКонтрагента = &ДоговорКонтрагента";
		КонецЕсли;
		
	ИначеЕсли ВидРегистра="УчетПотребностей" Тогда
		Если НЕ Элементы.Страницы.ТекущаяСтраница.Имя="Страница_ВнутреннийЗаказ" Тогда
			Если ЗначениеЗаполнено(СтруктураПараметров.Контрагент) Тогда
				стрУсловие=стрУсловие+" И ВЫРАЗИТЬ("+стрИмяИзмерения_Заказ+" КАК Документ."+стрЗаменить(Элементы.Страницы.ТекущаяСтраница.Имя, "Страница_", "")+").Контрагент = &Контрагент";
			КонецЕсли;
			//Если ЗначениеЗаполнено(СтруктураПараметров.ДоговорКонтрагента) Тогда
			//	стрУсловие=стрУсловие+" И ВЫРАЗИТЬ("+стрИмяИзмерения_Заказ+" КАК Документ."+ЭлементыФормы.ПанельОсновная.ТекущаяСтраница.Имя+").ДоговорКонтрагента = &ДоговорКонтрагента";
			//КонецЕсли; //Возможно понадобится (но пока вроде как такой необходимости нет)
		КонецЕсли;
	КонецЕсли;
	
	стрУсловие=стрУсловие+" И "+стрИмяИзмерения_Заказ+" Ссылка Документ."+стрЗаменить(Элементы.Страницы.ТекущаяСтраница.Имя, "Страница_", "");
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("НаДату", НаДату);
	Запрос.УстановитьПараметр("Организация", СтруктураПараметров.Организация);
	Запрос.УстановитьПараметр("Склад", СтруктураПараметров.Склад);
	Запрос.УстановитьПараметр("Номенклатура", СтруктураПараметров.Номенклатура);
	Запрос.УстановитьПараметр("ХарактеристикаНоменклатуры", СтруктураПараметров.ХарактеристикаНоменклатуры);
	Запрос.УстановитьПараметр("СерияНоменклатуры", СтруктураПараметров.СерияНоменклатуры);
	Запрос.УстановитьПараметр("Контрагент", СтруктураПараметров.Контрагент);
	Запрос.УстановитьПараметр("ДоговорКонтрагента", СтруктураПараметров.ДоговорКонтрагента);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных."+стрИмяИзмерения_Заказ+" Как Заказ,
	|	ИсточникДанных.КоличествоОстаток Как Количество
	|ИЗ
	|	РегистрНакопления."+ВидРегистра+".Остатки(&НаДату, "+стрУсловие+") КАК ИсточникДанных
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		НоваяСтрока=тзЗаказы.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
		Если СтруктураПараметров.Свойство("Сделки") Тогда
			НоваяСтрока.Пометка=НЕ СтруктураПараметров.Сделки.Найти(Выборка.Заказ)=Неопределено;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура тзЗаказы_Выбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если НЕ Элементы.тзЗаказыПометка.Видимость Тогда
		ОповеститьОВыборе(тзЗаказы.НайтиПоИдентификатору(ВыбраннаяСтрока).Заказ);
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Параметры ТМЦ"

&НаСервере
Процедура тпПарамертыТМЦ_ДобавитьСтроку(Идентификатор, Представление)
	Если НЕ Параметры.Свойство(Идентификатор) Тогда
		СтруктураПараметров.Вставить(Идентификатор, Неопределено);
		Возврат;
	КонецЕсли;
	СтруктураПараметров.Вставить(Идентификатор, Параметры[Идентификатор]);

	НоваяСтрока=тпПарамертыТМЦ.Добавить();
	НоваяСтрока.Идентификатор=Идентификатор;
	НоваяСтрока.Представление=Представление;
	НоваяСтрока.Значение=Параметры[Идентификатор];
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СтруктураПараметров=Новый Структура;
	Если Параметры.Свойство("Сделки") Тогда
		СтруктураПараметров.Вставить("Сделки", Параметры.Сделки);
	КонецЕсли;

	тпПарамертыТМЦ_ДобавитьСтроку("Организация", "Организация");
	тпПарамертыТМЦ_ДобавитьСтроку("Склад", "Склад");
	тпПарамертыТМЦ_ДобавитьСтроку("Номенклатура", "Номенклатура");
	тпПарамертыТМЦ_ДобавитьСтроку("ХарактеристикаНоменклатуры", "Характеристика");
	тпПарамертыТМЦ_ДобавитьСтроку("СерияНоменклатуры", "Серия");
	тпПарамертыТМЦ_ДобавитьСтроку("Контрагент", "Контрагент");
	тпПарамертыТМЦ_ДобавитьСтроку("ДоговорКонтрагента", "Договор контрагента");

	НаДату=?(Параметры.Свойство("НаДату"), Параметры.НаДату, ТекущаяДата());
	Элементы.тзЗаказыПометка.Видимость=?(Параметры.Свойство("МножественныйВыбор"), Параметры.МножественныйВыбор, Ложь);

	ВидРегистра="ВнутренниеЗаказы"; тпЗаказы_Заполнить();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ВидРегистраУстановить("ВнутреннийЗаказ");
	Элементы.кпЗаказы_ВидРегистра.Заголовок="Регистр (внутренние заказы)";
КонецПроцедуры