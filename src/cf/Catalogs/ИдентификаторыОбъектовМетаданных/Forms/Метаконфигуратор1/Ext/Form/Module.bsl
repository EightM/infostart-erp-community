﻿&НаКлиенте
Процедура УстановитьОтбор(Значение, ЭлементыОтбора, стрПоле="Владелец", стрВидСравнения="Равно")
	ЭлементОтбора=Неопределено; ПолеОтбора=Новый ПолеКомпоновкиДанных(стрПоле);
	Для каждого СтрокаКоллекции Из ЭлементыОтбора Цикл
		Если СтрокаКоллекции.ЛевоеЗначение=ПолеОтбора Тогда
			ЭлементОтбора=СтрокаКоллекции; Прервать;
		КонецЕсли;
	КонецЦикла;
	Если ЭлементОтбора=Неопределено Тогда
		ЭлементОтбора=ЭлементыОтбора.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ЛевоеЗначение=ПолеОтбора;
		ЭлементОтбора.ВидСравнения=ВидСравненияКомпоновкиДанных[стрВидСравнения];
		ЭлементОтбора.Использование=Истина;
		ЭлементОтбора.РежимОтображения=РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный;
	КонецЕсли;
	ЭлементОтбора.ПравоеЗначение=Значение;
КонецПроцедуры

&НаСервере
Функция МассивСсылок(Ссылка)
	Массив=Новый Массив;

	//Новый Структура("ПометкаУдаления", Ложь)
	Выборка=Справочники.ИдентификаторыОбъектовМетаданных.Выбрать(Ссылка,,, "Код");
	Пока Выборка.Следующий() Цикл
		Если Выборка.ПометкаУдаления Тогда Продолжить; КонецЕсли;
		Массив.Добавить(Выборка.Ссылка);
	КонецЦикла;

	Возврат Массив; 
КонецФункции

&НаСервере
Функция МассивСсылок_Реквизиты(Ссылка)
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Владелец", Ссылка);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Реквизит КАК Ссылка
	|ИЗ
	|	РегистрСведений.ДополнительныеРеквизиты КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Владелец = &Владелец
	|";	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
КонецФункции

&НаСервере
Функция МассивСсылок_Подвиды(Ссылка)
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Владелец", Ссылка);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Подвиды КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Владелец = &Владелец
	|";	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
КонецФункции

&НаСервере
Функция МассивСсылок_ПечатныеФормы(Ссылка)
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Владелец", Ссылка);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Наименование
	|ИЗ
	|	РегистрСведений.ПечатныеФормы КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Владелец = &Владелец
	|";
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Наименование");
КонецФункции

&НаСервере
Функция ПриктограммаЭлемента(Ссылка)
	КартинкиМетаданных=СтруктураКартинок();
 	стрСсылка=Ссылка.ИмяПредопределенныхДанных;
	стрРодитель=Ссылка.Родитель.ИмяПредопределенныхДанных;
	//Метаданные.НайтиПоПолномуИмени(стрЗаменить(стрИмя, "_", "."))
	//Метаданные.НайтиПоПолномуИмени("Документ.ЗаказПокупателя.ТабличныеЧасти.Товары")
	//Метаданные.Документы.ЗаказПокупателя.ТабличныеЧасти.Товары

	Если стрСсылка="Документы" Или стрРодитель="Документы" Тогда
		Возврат КартинкиМетаданных["Документы"];
	КонецЕсли;

	Если стрСсылка="Справочники" Или стрРодитель="Справочники" Тогда
		Возврат КартинкиМетаданных["Справочники"]; 
	КонецЕсли;

	Если Найти(стрСсылка, "_Подвиды") > 0 Тогда
		Возврат КартинкиМетаданных["Подвиды"]; 
	КонецЕсли;

	Если Найти(стрСсылка, "_ТабличныеЧасти") > 0 Или Найти(стрРодитель, "_ТабличныеЧасти") > 0 Тогда
		Возврат КартинкиМетаданных["ТабличныеЧасти"];
	КонецЕсли;

	Если Найти(стрСсылка, "_ПечатныеФормы") > 0 Тогда
		Возврат КартинкиМетаданных["ПечатныеФормы"];
	КонецЕсли;

	Если Найти(стрСсылка, "_Плагины") > 0 Тогда
		Возврат КартинкиМетаданных["Плагины"];
	КонецЕсли;

	Возврат КартинкиМетаданных["Реквизит"];
КонецФункции

&НаСервере
Функция СтруктураКартинок()
	КартинкиМетаданных=Новый Структура;
	КартинкиМетаданных.Вставить("Константы", БиблиотекаКартинок.Константа);
	КартинкиМетаданных.Вставить("Справочники", БиблиотекаКартинок.Справочник);
//	КартинкиМетаданных.Вставить("Справочник", БиблиотекаКартинок.Справочник);
	КартинкиМетаданных.Вставить("Документы", БиблиотекаКартинок.Документ);
//	КартинкиМетаданных.Вставить("Документ", БиблиотекаКартинок.Документ);
	КартинкиМетаданных.Вставить("ЖурналыДокументов", БиблиотекаКартинок.ЖурналДокументов);
	КартинкиМетаданных.Вставить("Перечисления", БиблиотекаКартинок.Перечисление);
	КартинкиМетаданных.Вставить("Отчеты", БиблиотекаКартинок.Отчет);
	КартинкиМетаданных.Вставить("Обработки", БиблиотекаКартинок.Обработка);
	КартинкиМетаданных.Вставить("ПланыВидовХарактеристик", БиблиотекаКартинок.ПланВидовХарактеристик);
	КартинкиМетаданных.Вставить("ПланыСчетов", БиблиотекаКартинок.ПланСчетов);
	КартинкиМетаданных.Вставить("ПланыВидовРасчета", БиблиотекаКартинок.ПланВидовРасчета);
	КартинкиМетаданных.Вставить("РегистрыСведений", БиблиотекаКартинок.РегистрСведений);
	КартинкиМетаданных.Вставить("РегистрыНакопления", БиблиотекаКартинок.РегистрНакопления);
	КартинкиМетаданных.Вставить("РегистрыБухгалтерии", БиблиотекаКартинок.РегистрБухгалтерии);
	КартинкиМетаданных.Вставить("РегистрыРасчета", БиблиотекаКартинок.РегистрРасчета);
	КартинкиМетаданных.Вставить("БизнесПроцессы", БиблиотекаКартинок.БизнесПроцесс);
	КартинкиМетаданных.Вставить("Задачи", БиблиотекаКартинок.Задача);
	КартинкиМетаданных.Вставить("Реквизит", БиблиотекаКартинок.Реквизит);
	КартинкиМетаданных.Вставить("ТабличныеЧасти", БиблиотекаКартинок.Таблица);
	КартинкиМетаданных.Вставить("Подвиды", БиблиотекаКартинок.ПорядокНаступленияСобытия123);
	КартинкиМетаданных.Вставить("Плагины", БиблиотекаКартинок.Обработка);
	КартинкиМетаданных.Вставить("ПечатныеФормы", БиблиотекаКартинок.Печать);

	Возврат КартинкиМетаданных;
КонецФункции

&НаСервере
Функция ЭлементУдален(Ссылка, ВладелецСсылки, ТолькоПроверка=Ложь)
	Если ТипЗнч(Ссылка)=Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда
		Возврат Ложь;
	КонецЕсли;

	Если ТипЗнч(Ссылка)=Тип("ПланВидовХарактеристикСсылка.ДополнительныеРеквизиты") Тогда
		МенеджерЗаписи=РегистрыСведений.ДополнительныеРеквизиты.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Реквизит=Ссылка;
		МенеджерЗаписи.Владелец=ВладелецСсылки;
		МенеджерЗаписи.Прочитать();
		Если МенеджерЗаписи.Выбран() Тогда
			Если НЕ ТолькоПроверка Тогда
				МенеджерЗаписи.Отключен=НЕ МенеджерЗаписи.Отключен;
				МенеджерЗаписи.Записать();
			КонецЕсли;
			Возврат МенеджерЗаписи.Отключен; 
		КонецЕсли;

	ИначеЕсли ТипЗнч(Ссылка)=Тип("СправочникСсылка.Подвиды") Тогда
		СправочникОбъект=Ссылка.ПолучитьОбъект();
		Если НЕ ТолькоПроверка Тогда
			СправочникОбъект.ПометкаУдаления=НЕ СправочникОбъект.ПометкаУдаления;
			СправочникОбъект.Записать();
		КонецЕсли;
		Возврат СправочникОбъект.ПометкаУдаления; 
	КонецЕсли;
	
	
КонецФункции

&НаКлиенте
Процедура ОбработчикОповещения_ПоказатьЗначение(Параметр1, Параметр2) Экспорт
	ТекущиеДанные=Элементы.дзМетаконфигуратор.ТекущиеДанные;
	Если ТекущиеДанные=Неопределено Тогда Возврат; КонецЕсли;
	ТекущиеДанные.Ссылка=Параметр2.Ссылка;
КонецПроцедуры

&НаСервере
Функция ИмяЭлемента(Ссылка, Родитель=Ложь)
	Если НЕ Родитель Тогда
		Возврат Ссылка.ИмяПредопределенныхДанных;
	КонецЕсли;
	Возврат Ссылка.Родитель.ИмяПредопределенныхДанных;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий "Мета-конфигуратор"

&НаСервере
Процедура дзМетаконфигуратор_Инициализация()
	ЭлементыДерева=дзМетаконфигуратор.ПолучитьЭлементы();

	//Справочники
	Ссылка=Справочники.ИдентификаторыОбъектовМетаданных.Справочники;
	НоваяСтрока=ЭлементыДерева.Добавить();
	НоваяСтрока.Ссылка=Ссылка;
	НоваяСтрока.Пиктограмма=БиблиотекаКартинок.Справочник;
	НоваяСтрока.ПолучитьЭлементы().Добавить();

	//Документы
	Ссылка=Справочники.ИдентификаторыОбъектовМетаданных.Документы;
	НоваяСтрока=ЭлементыДерева.Добавить();
	НоваяСтрока.Ссылка=Ссылка;
	НоваяСтрока.Пиктограмма=БиблиотекаКартинок.Документ;
	НоваяСтрока.ПолучитьЭлементы().Добавить();

	////Отчеты
	//Ссылка=Справочники.ИдентификаторыОбъектовМетаданных.Отчеты;
	//НоваяСтрока=ЭлементыДерева.Добавить();
	//НоваяСтрока.Ссылка=Ссылка;
	//НоваяСтрока.Пиктограмма=БиблиотекаКартинок.Отчет;
	//НоваяСтрока.ПолучитьЭлементы().Добавить();

	////Обработки
	//Ссылка=Справочники.ИдентификаторыОбъектовМетаданных.Обработки;
	//НоваяСтрока=ЭлементыДерева.Добавить();
	//НоваяСтрока.Ссылка=Ссылка;
	//НоваяСтрока.Пиктограмма=БиблиотекаКартинок.Обработка;
	//НоваяСтрока.ПолучитьЭлементы().Добавить();
	//
	////Константы
	//Ссылка=Справочники.ИдентификаторыОбъектовМетаданных.Константы;
	//НоваяСтрока=ЭлементыДерева.Добавить();
	//НоваяСтрока.Ссылка=Ссылка;
	//НоваяСтрока.Пиктограмма=БиблиотекаКартинок.Константа;
	//НоваяСтрока.ПолучитьЭлементы().Добавить();	
КонецПроцедуры

&НаКлиенте
Процедура дзМетаконфигуратор_Выбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ТекущиеДанные=дзМетаконфигуратор.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если ТипЗнч(ТекущиеДанные.Ссылка)=Тип("Строка") Тогда Возврат; КонецЕсли;
	Если ТипЗнч(ТекущиеДанные.Ссылка)=Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда Возврат; КонецЕсли;

	Если ТипЗнч(ТекущиеДанные.Ссылка)=Тип("СправочникСсылка.Подвиды") Тогда //Подвиды
		ПараметрыОткрытия=Новый Структура("Ключ", ТекущиеДанные.Ссылка);
		стрФорма="Справочник.Подвиды.Форма.ФормаЭлемента";

	ИначеЕсли ТипЗнч(ТекущиеДанные.Ссылка)=Тип("ПланВидовХарактеристикСсылка.ДополнительныеРеквизиты") Тогда //Доп.атрибуты
		ПараметрыКлюча=новый Структура;
		ПараметрыКлюча.Вставить("Владелец", ТекущиеДанные.Владелец);
		ПараметрыКлюча.Вставить("Реквизит", ТекущиеДанные.Ссылка);

		МассивКлюча=Новый Массив;
		МассивКлюча.Добавить(ПараметрыКлюча);
		
		ПараметрыОткрытия=Новый структура;
		ПараметрыОткрытия.Вставить("Ключ", Новый("РегистрСведенийКлючЗаписи.ДополнительныеРеквизиты", МассивКлюча));

		стрФорма="РегистрСведений.ДополнительныеРеквизиты.ФормаЗаписи";
	КонецЕсли;

	Если стрФорма=Неопределено Тогда Возврат; КонецЕсли; 

	ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_ПоказатьЗначение", ЭтотОбъект, Новый Структура("Ссылка", ТекущиеДанные.Ссылка));
    ОткрытьФорму(стрФорма, ПараметрыОткрытия, ЭтаФорма,,,,ОписаниеОповещения);
КонецПроцедуры

&НаСервере
Функция ЭтоВеткаРеквизитов(Ссылка)
	Если ТипЗнч(Ссылка)=Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда
		стрИмя=УниверсальныеМеханизмыСервер.ИмяПредопределенныхДанных(Ссылка);
		Если Прав(стрИмя, 10)="_Реквизиты" Тогда Возврат Истина; КонецЕсли;

		Массив=СтрРазделить(стрИмя, "_");
		Если НЕ Массив.Количество()=3 Тогда Возврат Ложь; КонецЕсли;
		
		Если Массив[0]="Документ" Тогда
			мдОбъект=Метаданные.Документы.Найти(Массив[1]);	
		ИначеЕсли Массив[0]="Справочник" Тогда
			мдОбъект=Метаданные.Справочники.Найти(Массив[1]);
		КонецЕсли;
		Если мдОбъект=Неопределено Тогда Возврат Ложь; КонецЕсли;

		Возврат НЕ мдОбъект.ТабличныеЧасти.Найти(Массив[2])=Неопределено;
	КонецЕсли;

	Возврат ТипЗнч(Ссылка)=Тип("ПланВидовХарактеристикСсылка.ДополнительныеРеквизиты"); 
КонецФункции

&НаКлиенте
Процедура дзМетаконфигуратор_ПриАктивизацииСтроки(Элемент)
	Элементы.Группа_Подвиды.Видимость=Ложь;
	Элементы.Группа_Реквизиты.Видимость=Ложь;

	ТекущиеДанные=Элемент.ТекущиеДанные;
	Если ТекущиеДанные.Ссылка="Подвиды" Тогда
		Ссылка=ТекущиеДанные.ПолучитьРодителя().Ссылка;
		Элементы.Группа_Подвиды.Видимость=Истина;
		Элементы.Группа_Подвиды.Заголовок="Подвиды "+?(ИмяЭлемента(Ссылка, Истина)="Документы", "документа ", "справочника ")+""""+СокрЛП(Ссылка)+"""";
		УстановитьОтбор(Ссылка, КлассификаторПодвидов.Отбор.Элементы);
	КонецЕсли;
	
	Если ЭтоВеткаРеквизитов(ТекущиеДанные.Ссылка) Тогда
		Ссылка=ТекущиеДанные.ПолучитьРодителя().Ссылка;
		Элементы.Группа_Реквизиты.Видимость=Истина;		
		Элементы.Группа_Реквизиты.Заголовок="Реквизиты "+?(ИмяЭлемента(Ссылка, Истина)="Документы", "документа ", "справочника ")+""""+СокрЛП(Ссылка)+"""";
		УстановитьОтбор(Ссылка, дсРеквиизты.Отбор.Элементы);
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура дзМетаконфигуратор_ПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	ТекущиеДанные=Элемент.ТекущиеДанные; Отказ=Истина; стрИмя="";

	Если ТипЗнч(Элемент.ТекущиеДанные.Ссылка)=Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда
		стрИмя=УниверсальныеМеханизмыСервер.ИмяПредопределенныхДанных(ТекущиеДанные.Ссылка);
	КонецЕсли;

	Если ТекущиеДанные.Ссылка="Подвиды" ИЛИ ТипЗнч(ТекущиеДанные.Ссылка)=Тип("СправочникСсылка.Подвиды") Тогда
		ПараметрыФормы=Новый Структура("Владелец", ?(ПустаяСтрока(стрИмя), ТекущиеДанные.Владелец, ТекущиеДанные.Ссылка));
		ОткрытьФорму("Справочник.Подвиды.Форма.ФормаЭлемента", ПараметрыФормы, ЭтотОбъект, УникальныйИдентификатор,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
	ИначеЕсли ЭтоВеткаРеквизитов(ТекущиеДанные.Ссылка) Тогда
		ПараметрыФормы=Новый Структура("Владелец", ?(ПустаяСтрока(стрИмя), ТекущиеДанные.Владелец, ТекущиеДанные.Ссылка));
		ОткрытьФорму("РегистрСведений.ДополнительныеРеквизиты.ФормаЗаписи", ПараметрыФормы, ЭтотОбъект, УникальныйИдентификатор,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура дзМетаконфигуратор_ПередНачаломИзменения(Элемент, Отказ)
	Сообщить(123);
КонецПроцедуры

&НаКлиенте
Процедура дзМетаконфигуратор_ПередУдалением(Элемент, Отказ)
	Отказ=Истина;
	Элемент.ТекущиеДанные.Удален=ЭлементУдален(Элемент.ТекущиеДанные.Ссылка, Элемент.ТекущиеДанные.Владелец, Ложь);
КонецПроцедуры

&НаКлиенте
Процедура дзМетаконфигуратор_ПередРазворачиванием(Элемент, Строка, Отказ)
	дзМетаконфигуратор_ЗаполнитьВетку(Строка);	
КонецПроцедуры

&НаКлиенте
Процедура дзМетаконфигуратор_ПриСменеТекущегоРодителя(Элемент)
	//Сообщить(111);
КонецПроцедуры

&НаКлиенте
Функция дзМетаконфигуратор_ДобавитьСтроку(КоллекцияЭлементов, Ссылка1, Ссылка2, Пиктограмма=Неопределено, Загружено=Ложь)
	НоваяСтрока=КоллекцияЭлементов.Добавить();
	НоваяСтрока.Владелец=Ссылка1;
	НоваяСтрока.Ссылка=Ссылка2;	
	НоваяСтрока.Пиктограмма=?(Пиктограмма=Неопределено, ПриктограммаЭлемента(Ссылка2), Пиктограмма);
	НоваяСтрока.Загружено=Загружено;
	НоваяСтрока.Удален=ЭлементУдален(Ссылка2, Ссылка1, Истина);
	Возврат НоваяСтрока; 
КонецФункции
 
&НаКлиенте
Процедура дзМетаконфигуратор_ЗаполнитьВетку(ИдентификаторСтроки)
	ТекущиеДанные=дзМетаконфигуратор.НайтиПоИдентификатору(ИдентификаторСтроки);
	Если ТекущиеДанные.Загружено Тогда Возврат; КонецЕсли;

	ТекущиеДанные.Загружено=Истина;
	Ссылка=ТекущиеДанные.Ссылка;

	КоллекцияЭлементов=ТекущиеДанные.ПолучитьЭлементы();
	КоллекцияЭлементов.Очистить();

	стрРодитель=ИмяЭлемента(Ссылка, Истина);
	
	Если стрРодитель="Документы" Или стрРодитель="Справочники" Тогда
		//Подвиды
		НоваяСтрока=дзМетаконфигуратор_ДобавитьСтроку(КоллекцияЭлементов, Ссылка, "Подвиды", БиблиотекаКартинок.ПорядокНаступленияСобытия123, Истина);
		НоваяСтрока.Загружено=Истина;
		МасссивСсылок=МассивСсылок_Подвиды(Ссылка);
		Для каждого Ссылка1 Из МасссивСсылок Цикл
			дзМетаконфигуратор_ДобавитьСтроку(НоваяСтрока.ПолучитьЭлементы(), Ссылка, Ссылка1, БиблиотекаКартинок.Реквизит, Истина);
		КонецЦикла;

		//Печатные формы
		НоваяСтрока=дзМетаконфигуратор_ДобавитьСтроку(КоллекцияЭлементов, Ссылка, "Печатные формы", БиблиотекаКартинок.Печать, Истина);
		НоваяСтрока.Загружено=Истина;
		МасссивСсылок=МассивСсылок_ПечатныеФормы(Ссылка);
		Для каждого Ссылка1 Из МасссивСсылок Цикл
			дзМетаконфигуратор_ДобавитьСтроку(НоваяСтрока.ПолучитьЭлементы(), Ссылка, Ссылка1, БиблиотекаКартинок.Реквизит, Истина);
		КонецЦикла;
		
		//Плагины
		//НоваяСтрока=дзМетаконфигуратор_ДобавитьСтроку(КоллекцияЭлементов, Ссылка, "Плагины", БиблиотекаКартинок.Обработка, Истина);
		//НоваяСтрока.Загружено=Истина;
		//МасссивСсылок=МассивСсылок_Плагины(Ссылка);
		//Для каждого Ссылка1 Из МасссивСсылок Цикл
		//	дзМетаконфигуратор_ДобавитьСтроку(НоваяСтрока.ПолучитьЭлементы(), Ссылка, Ссылка1, БиблиотекаКартинок.Реквизит, Истина);
		//КонецЦикла;
	КонецЕсли;

	МасссивСсылок1=МассивСсылок(Ссылка);
	Для каждого Ссылка1 Из МасссивСсылок1 Цикл
		НоваяСтрока=дзМетаконфигуратор_ДобавитьСтроку(КоллекцияЭлементов,,Ссылка1);
		
		КоллекцияЭлементов1=НоваяСтрока.ПолучитьЭлементы();
		Если НЕ МассивСсылок(Ссылка1).Количество()=0 Тогда
			КоллекцияЭлементов1.Добавить();
		КонецЕсли;

		//стрИмя=Ссылка1.ИмяПредопределенныхДанных;
		//стрРодитель=Ссылка1.Родитель.ИмяПредопределенныхДанных;
		стрИмя=ИмяЭлемента(Ссылка1, Ложь);
		стрРодитель=ИмяЭлемента(Ссылка1, Истина);

		//Доп.реквизиты
		Если Прав(стрИмя, 10)="_Реквизиты" Или Прав(стрРодитель, 15)="_ТабличныеЧасти" Тогда
			НоваяСтрока.Загружено=Истина;
			МасссивСсылок2=МассивСсылок_Реквизиты(Ссылка1);
			Для каждого Ссылка2 Из МасссивСсылок2 Цикл
				дзМетаконфигуратор_ДобавитьСтроку(КоллекцияЭлементов1, Ссылка1, Ссылка2, БиблиотекаКартинок.Реквизит, Истина);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	дзМетаконфигуратор_Инициализация();
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	//Если ИмяСобытия="ЗаписанПодвид" Тогда
	//	ОбработчикОповещения_Подвиды(Параметр, Ложь);
	//КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗаписиНового(НовыйОбъект, Источник, СтандартнаяОбработка)
	Если ТипЗнч(Источник)=Тип("УправляемаяФорма") Тогда
		ТекущиеДанные=Элементы.дзМетаконфигуратор.ТекущиеДанные;
		Если ТекущиеДанные=Неопределено Тогда Возврат; КонецЕсли;

		Если Источник.ИмяФормы="Справочник.Подвиды.Форма.ФормаЭлемента" Тогда
			Если ТипЗнч(ТекущиеДанные.Ссылка)=Тип("СправочникСсылка.Подвиды") Тогда
				КоллекцияЭлементов=ТекущиеДанные.ПолучитьРодителя().ПолучитьЭлементы();
			Иначе
				КоллекцияЭлементов=ТекущиеДанные.ПолучитьЭлементы();
			КонецЕсли;			
			дзМетаконфигуратор_ДобавитьСтроку(КоллекцияЭлементов, Неопределено, НовыйОбъект, БиблиотекаКартинок.Реквизит);

		ИначеЕсли Источник.ИмяФормы="РегистрСведений.ДополнительныеРеквизиты.Форма.ФормаЗаписи" Тогда
			Если ТипЗнч(ТекущиеДанные.Ссылка)=Тип("ПланВидовХарактеристикСсылка.ДополнительныеРеквизиты") Тогда
				КоллекцияЭлементов=ТекущиеДанные.ПолучитьРодителя().ПолучитьЭлементы();				
			Иначе
				КоллекцияЭлементов=ТекущиеДанные.ПолучитьЭлементы();
			КонецЕсли;
			дзМетаконфигуратор_ДобавитьСтроку(КоллекцияЭлементов, Неопределено, Источник.Запись.Реквизит, БиблиотекаКартинок.Реквизит);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры
