﻿&НаКлиенте
Процедура ВыполнитьДействие(Команда)
	Если Команда.Имя="УправлениеШапкой" Тогда
		Видимость=НЕ Элементы.ШапкаПанель1.Видимость;		
		Элементы.ШапкаПанель1.Видимость=Видимость;
		Элементы.ШапкаПанель2.Видимость=Видимость;
		Элементы[Команда.Имя].Картинка=?(Видимость, БиблиотекаКартинок.СтрелкаВнизСплошная, БиблиотекаКартинок.СтрелкаВправоКрасная);
		Элементы.ШапкаИнфо.Видимость=Не Видимость;

		МассивДанных=Новый Массив;
		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" Организация: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Организация));
		
		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" | Склад: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Склад));
		
		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" | Отдел: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Подразделение));

		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" | Куратор: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Ответственный));

		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" | Тип цен: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.ТипЦен));

		Элементы.ШапкаИнфо.Заголовок=Новый ФорматированнаяСтрока(МассивДанных);
	Иначе
		УправлениеДиалогамиКлиент.ВыполнитьДействие(Команда.Имя, ЭтаФорма, Объект);
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Вложения"

&НаКлиенте
Процедура тпВложение_ВыполнитьДействие(Команда)
	Если Команда.Имя="ВложенияПредпросмотр" Тогда
		Элементы.ВложенияПредпросмотр.Пометка=НЕ Элементы.ВложенияПредпросмотр.Пометка;
		Элементы.ВложенияГруппаПросмотр.Видимость=Элементы.ВложенияПредпросмотр.Пометка;
		Если Элементы.ВложенияПредпросмотр.Пометка Тогда
			тпВложения_ОбработчикОжидания();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры	 

&НаКлиенте
Процедура тпВложения_ПриАктивизацииСтроки(Элемент)
	Если Элементы.тпВложения.ТекущиеДанные=Неопределено Тогда Возврат; КонецЕсли;
	Если НЕ Элементы.ВложенияПредпросмотр.Пометка Тогда Возврат; КонецЕсли;
	
	тпВложения_ОбработчикОжидания();
КонецПроцедуры

&НаКлиенте
Процедура тпВложения_ПредпросмотПоказать(СтруктураДанных)
	Модуль=ОбщегоНазначенияКлиент.ОбщийМодуль("ВложенияКлиент");
	Модуль.ПредпросмотрПоказать(ЭтаФорма, СтруктураДанных);
КонецПроцедуры

&НаСервере
Процедура тпВложения_ПредпросмотСоздать(СтруктураДанных)
	Модуль=ОбщегоНазначенияСервер.ОбщийМодуль("ВложенияСервер");
	Модуль.ПредпросмотрСоздать(ЭтаФорма, СтруктураДанных);
КонецПроцедуры

&НаКлиенте
Процедура тпВложения_ОбработчикОжидания()
	Если Элементы.тпВложения.ТекущиеДанные=Неопределено Тогда Возврат; КонецЕсли;

	СтруктураДанных=Новый Структура("ИмяФайла,Каталог,ТипID,ID,ВариантХранения,ИндексПиктограммы");
	ЗаполнитьЗначенияСвойств(СтруктураДанных, Элементы.тпВложения.ТекущиеДанные);
	СтруктураДанных.Вставить("Ссылка", Объект.Ссылка);
	СтруктураДанных.Вставить("ИмяРеквизита", ОбщегоНазначенияКлиент.ОбщийМодуль("ВложенияОбщий").ИмяРеквизитаПоИндексуПиктограммы(СтруктураДанных.ИндексПиктограммы));

	Если Элементы.Найти("ВложениеПросмотр"+СтруктураДанных.ИмяРеквизита)=Неопределено Тогда	
		тпВложения_ПредпросмотСоздать(СтруктураДанных);
	КонецЕсли;

	тпВложения_ПредпросмотПоказать(СтруктураДанных);
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Обработчики оповещений

&НаКлиенте
Процедура ОбработчикОповещения_ОбработкаПодбора(Параметр1, Параметр2) Экспорт
	Если Параметр1=Неопределено Тогда Возврат; КонецЕсли;
	тпТабличноеПоле_Изменить(Параметр1);
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОповещения_ВводШтрихкода(Штрихкод, ПараметрыДоп) Экспорт
	Если Не ПустаяСтрока(Штрихкод) Тогда 
		СтруктураВозврата=ПодключаемоеОборудованиеСервер.ОбработатьВведенныйШтрихкод(Штрихкод);
		Если ЗначениеЗаполнено(СтруктураВозврата.Номенклатура) Тогда
			тпТовары_Добавить(СтруктураВозврата.Номенклатура, СтруктураВозврата.ХарактеристикаНоменклатуры, СтруктураВозврата.СерияНоменклатуры, СтруктураВозврата.Качество, СтруктураВозврата.ЕдиницаИзмерения, СтруктураВозврата.Количество);
		Иначе
			ПоказатьПредупреждение(,"штрих код не найден!", 10);
		КонецЕсли;
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОповещения_Товары_Заполнить(Параметр1, Параметр2) Экспорт
	Если Параметр1=КодВозвратаДиалога.Отмена Тогда Возврат; КонецЕсли; 
	Если НЕ Параметр1=КодВозвратаДиалога.Да Тогда Возврат; КонецЕсли;

	Объект.Товары.Очистить();
	тпТовары_Заполнить(Параметр2.Команда);
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Стандартные (универсальные) процедуры\функции

&НаСервере
Процедура ВыполнитьСортировкуТабличнойЧасти(ИмяТабличнойЧасти, стрСортировка) Экспорт
	СортировкаТабличнойЧастиСервер.Сортировать(ИмяТабличнойЧасти, стрСортировка, Объект);
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТиповыеОперации(стрТабличнаяЧасть)
	ДокументОбъект=РеквизитФормыВЗначение("Объект");
	Для каждого СтрокаТабличнойЧасти Из ДокументОбъект[стрТабличнаяЧасть] Цикл
		УправлениеТиповымиОперациямиСервер.УстановитьТиповуюОперацию(СтрокаТабличнойЧасти, ДокументОбъект, ЭтаФорма, стрТабличнаяЧасть);
	КонецЦикла;
	ЗначениеВРеквизитФормы(ДокументОбъект, "Объект");
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Произвольные алгоритмы

&НаКлиенте
Процедура ВыполнитьАлгоритмКлиент(Команда)
	ВыполнитьАлгоритм(Команда.Имя, "АлгоритмВыполнения");
КонецПроцедуры

&НаСервере
Процедура ВыполнитьАлгоритмСервер(Алгоритм, СтруктураКоманды)
	Выполнить(Алгоритм);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВыполнитьАлгоритмСерверБезКонтекста(Алгоритм, СтруктураКоманды)
	Выполнить(Алгоритм);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьАлгоритм_ОбработчикОповещения(Параметр1, Параметр2=Неопределено) Экспорт
	Если Параметр1=Неопределено Тогда Возврат; КонецЕсли;
	ВыполнитьАлгоритм(ЭтаФорма.ТекущийЭлемент.Имя, "АлгоритмОповещения", Параметр1, Параметр2);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьАлгоритм(стрКоманда, стрИмяАлгоритма, Параметр1=Неопределено, Параметр2=Неопределено) Экспорт
	Если НЕ ТипЗнч(ПроизвольныеАлгоритмы)=Тип("Структура") Тогда Возврат; КонецЕсли;

	СтруктураКоманды=Неопределено; ПроизвольныеАлгоритмы.Свойство(стрКоманда, СтруктураКоманды);
	Если НЕ ТипЗнч(СтруктураКоманды)=Тип("Структура") Тогда Возврат; КонецЕсли;

	Для каждого СтрокаКоллекции Из СтруктураКоманды[стрИмяАлгоритма] Цикл
		Если СтрокаКоллекции.Ключ="НаКлиенте" Тогда
			Выполнить(СтрокаКоллекции.Значение);
		ИначеЕсли СтрокаКоллекции.Ключ="НаСервере" Тогда
			ВыполнитьАлгоритмСервер(СтрокаКоллекции.Значение, СтруктураКоманды);
		ИначеЕсли СтрокаКоллекции.Ключ="НаСервереБезКонтекста" Тогда
			ВыполнитьАлгоритмСерверБезКонтекста(СтрокаКоллекции.Значение, СтруктураКоманды);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибутов шапки

&НаКлиенте
Процедура Атрибут_ПриИзменении(Элемент)
КонецПроцедуры

&НаКлиенте
Процедура Атрибут_НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СобытияЭлементовФормыКлиент.НачалоВыбора(ЭтаФорма, Элемент, ДанныеВыбора, СтандартнаяОбработка);

	Если Элемент.Имя="ДокументОснование" Тогда
		СтандартнаяОбработка=Ложь;

		ПараметрыФормы=Новый Структура;
		ПараметрыФормы.Вставить("РежимВыбора", Истина);
		ПараметрыФормы.Вставить("Отбор", Новый Структура("Склад,Организация", Объект.Склад, Объект.Организация));
		ОткрытьФорму("Документ.УстановкаЦенНоменклатуры.ФормаВыбора", ПараметрыФормы, Элемент, УникальныйИдентификатор,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура Атрибут_Нажатие(Элемент, СтандартнаяОбработка)
	СобытияЭлементовФормыКлиент.Нажатие(ЭтаФорма, Элемент, СтандартнаяОбработка);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Товары"

&НаКлиенте
Процедура кпТовары_ВыполнитьДействие(Команда)
	стрТабличнаяЧасть="Товары"; стрКоманда=стрЗаменить(Команда.Имя, "кп"+стрТабличнаяЧасть+"_", "");
		
	Если стрКоманда="Сортировать" Тогда
		СортировкаТабличнойЧастиКлиент.Открыть(стрТабличнаяЧасть, ЭтаФорма, Объект);

	ИначеЕсли стрКоманда="НайтиПоШтрихКоду" Тогда
		ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_ВводШтрихкода", ЭтотОбъект);
		ПоказатьВводСтроки(ОписаниеОповещения, , "Введите штрихкод товара");

	ИначеЕсли стрКоманда="Подбор" Тогда
		ПараметрыФормы=УправлениеДиалогамиСервер.СтруктураПодбора();
		ПараметрыФормы.Вставить("Организация", Объект.Организация);
		ПараметрыФормы.Вставить("Склад", Объект.Склад);
		ПараметрыФормы.Вставить("ТипЦен", ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Объект.Склад, "ТипЦенРозничнойТорговли"));
		ПараметрыФормы.Свойство("ПоказыватьЦены", НЕ ПараметрыФормы.ТипЦен.Пустая());

		УправлениеДокументамиКлиент.ПодборТоваров(ЭтаФорма, ПараметрыФормы);

	ИначеЕсли стрКоманда="ЗаполнитьИзУстановкиЦен" Тогда
		Если Объект.ДокументУстановкаЦен.Пустая() Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указан документ установки цен номенклатуры!",,"ДокументУстановкаЦен", "Объект");
			Возврат; 
		КонецЕсли;
		Если Объект.ТипЦен.Пустая() Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указан тип цен номенклатуры!",,"ТипЦен", "Объект");
			Возврат; 
		КонецЕсли; 

		Если НЕ Объект.Товары.Количество()=0 Тогда
			ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_Товары_Заполнить", ЭтотОбъект, Новый Структура("Команда", стрКоманда));
			ПоказатьВопрос(ОписаниеОповещения, "Перед заполнением табличная часть будет очищена, продолжить?", РежимДиалогаВопрос.ДаНет, 20, КодВозвратаДиалога.Нет, "Внимание", КодВозвратаДиалога.Нет);
		Иначе
			тпТовары_Заполнить(стрКоманда);
		КонецЕсли;

	ИначеЕсли стрКоманда="ЗаполнитьПоОстаткам" Тогда
		Если НЕ Объект.Товары.Количество()=0 Тогда
			ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_Товары_Заполнить", ЭтотОбъект, Новый Структура("Команда", стрКоманда));
			ПоказатьВопрос(ОписаниеОповещения, "Перед заполнением табличная часть будет очищена, продолжить?", РежимДиалогаВопрос.ДаНет, 20, КодВозвратаДиалога.Нет, "Внимание", КодВозвратаДиалога.Нет);
		Иначе
			тпТовары_Заполнить(стрКоманда);
		КонецЕсли;

	ИначеЕсли стрКоманда="ЗаполнитьПоСериям" Тогда
		тпТовары_Заполнить(стрКоманда);

	ИначеЕсли стрКоманда="ЗаполнитьТОП" Тогда
		ЗаполнитьТиповыеОперации(стрТабличнаяЧасть);		
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура тпТабличноеПоле_Изменить(СтруктураПараметров) Экспорт
	Если СтруктураПараметров.Свойство("Ошибка") Тогда ПоказатьПредупреждение(, СтруктураПараметров.Ошибка, 10, "Ошибка"); Возврат; КонецЕсли; 

	УправлениеКоллекциямиЗначенийСервер.СвойствоСтруктуры(СтруктураПараметров, "ХарактеристикаНоменклатуры", ПредопределенноеЗначение("Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка"));
	УправлениеКоллекциямиЗначенийСервер.СвойствоСтруктуры(СтруктураПараметров, "СерииНоменклатуры", ПредопределенноеЗначение("Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка"));
	УправлениеКоллекциямиЗначенийСервер.СвойствоСтруктуры(СтруктураПараметров, "Качество", ПредопределенноеЗначение("Справочник.Качество.Новый"));

	стрТабличнаяЧасть=СтрЗаменить(Элементы.ТабличныеЧасти.ТекущаяСтраница.Имя, "Страница", "");
	
	СтруктураПоиска=Новый Структура("Номенклатура");
	Если стрТабличнаяЧасть="Товары" Тогда
		СтруктураПоиска.Вставить("ХарактеристикаНоменклатуры", ПредопределенноеЗначение("Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка"));
		СтруктураПоиска.Вставить("СерияНоменклатуры", ПредопределенноеЗначение("Справочник.СерииНоменклатуры.ПустаяСсылка"));
	КонецЕсли; 

	ЗаполнитьЗначенияСвойств(СтруктураПоиска, СтруктураПараметров);

	РезультатПоиска=Объект[стрТабличнаяЧасть].НайтиСтроки(СтруктураПоиска);
	Если РезультатПоиска.Количество()=0 Тогда
		УправлениеКоллекциямиЗначенийСервер.СвойствоСтруктуры(СтруктураПараметров, "ЕдиницаИзмерения", ПредопределенноеЗначение("Справочник.ЕдиницыИзмерения.ПустаяСсылка"));
		Если ЗначениеЗаполнено(СтруктураПараметров.ЕдиницаИзмерения) Тогда
			СтруктураПараметров.ЕдиницаИзмерения=ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(СтруктураПараметров.Номенклатура, "ЕдиницаХраненияОстатков");
		КонецЕсли;
		ТекущиеДанные=Объект[стрТабличнаяЧасть].Добавить();
		ЗаполнитьЗначенияСвойств(ТекущиеДанные, СтруктураПараметров);
	Иначе
		ТекущиеДанные=РезультатПоиска[0];
		ТекущиеДанные.Количество=ТекущиеДанные.Количество+СтруктураПараметров.Количество;
	КонецЕсли;
	
	//Установим добавленную\найденную строку текущей
	Элементы[стрТабличнаяЧасть].ТекущаяСтрока=ТекущиеДанные.ПолучитьИдентификатор();

	//Выполним модуль при изменении номенклатуры(если новая строка) или количества(если строка найдена)
	Если стрТабличнаяЧасть="Товары" Тогда
		тпТовары_Колонка_ПриИзменении(?(РезультатПоиска.Количество()=0, Элементы.ТоварыНоменклатура, Элементы.ТоварыКоличество));
	КонецЕсли;

	Элементы[стрТабличнаяЧасть].Обновить();
КонецПроцедуры

&НаКлиенте
Процедура тпТовары_Добавить(Номенклатура, Характеристика=Неопределено, Серия=Неопределено, Качество=Неопределено, Единица=Неопределено, Количество=1)
	Если Характеристика=Неопределено Тогда
		Характеристика=ПредопределенноеЗначение("Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка");
	КонецЕсли; 
	Если Серия=Неопределено Тогда
		Серия=ПредопределенноеЗначение("Справочник.СерииНоменклатуры.ПустаяСсылка");
	КонецЕсли;	
	Если Качество=Неопределено Тогда
		Качество=ПредопределенноеЗначение("Справочник.Качество.Новый");
	КонецЕсли;
	Если Единица=Неопределено Тогда
		Единица=ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Номенклатура, "ЕдиницаХраненияОстатков");
	КонецЕсли; 
	ТипЦен=ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Объект.Склад, "ТипЦенРозничнойТорговли");

	СтруктураПоиска=Новый Структура;
	СтруктураПоиска.Вставить("Номенклатура", Номенклатура);
	СтруктураПоиска.Вставить("ХарактеристикаНоменклатуры", Характеристика);
	СтруктураПоиска.Вставить("СерияНоменклатуры", Серия);
	
	РезультатПоиска=Объект.Товары.НайтиСтроки(СтруктураПоиска);
	Если РезультатПоиска.Количество()=0 Тогда
		ТекущиеДанные=Объект.Товары.Добавить();
		ТекущиеДанные.Номенклатура=Номенклатура;
		ТекущиеДанные.ЕдиницаИзмерения=Единица;
		ТекущиеДанные.Коэффициент=ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Единица, "Коэффициент");
	Иначе
		ТекущиеДанные=РезультатПоиска[0];
	КонецЕсли;
	ТекущиеДанные.Количество=ТекущиеДанные.Количество+Количество;
	ТекущиеДанные.Цена=ЦенообразованиеСервер.ПолучитьЦенуНоменклатуры(Номенклатура, Характеристика, ТипЦен, ТекущаяДата(), Единица);;
	ТекущиеДанные.Сумма=ТекущиеДанные.Количество*ТекущиеДанные.Цена;

	Элементы.Товары.Обновить();
	Элементы.Товары.ТекущаяСтрока=ТекущиеДанные.ПолучитьИдентификатор();

	//Выполним действия "при изменении"
	СтруктураПараметров=Новый Структура("Номенклатура,ХарактеристикаНоменклатуры,СерияНоменклатуры,Количество");
	ЗаполнитьЗначенияСвойств(СтруктураПараметров, ТекущиеДанные);
	тпТабличноеПоле_Изменить(СтруктураПараметров);
КонецПроцедуры

&НаКлиенте
Процедура тпТовары_ПриАктивизацииСтроки(Элемент)
КонецПроцедуры

&НаКлиенте
Процедура тпТовары_ПередНачаломИзменения(Элемент, Отказ)
КонецПроцедуры

&НаКлиенте
Процедура тпТовары_ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	Если НоваяСтрока Тогда
		Элемент.ТекущиеДанные.ID=Строка(Новый УникальныйИдентификатор);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура тпТовары_ПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
КонецПроцедуры

&НаКлиенте
Процедура тпТовары_ПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
КонецПроцедуры

&НаКлиенте
Процедура тпТовары_Колонка_ПриИзменении(Элемент)
	стрКолонка=стрЗаменить(Элемент.Имя, "Товары", "");
	ТекущиеДанные=Элементы.Товары.ТекущиеДанные;

	Если стрКолонка="Номенклатура" Тогда
		Если ТекущиеДанные.Количество=0 Тогда ТекущиеДанные.Количество=1; КонецЕсли;
		ТипЦенРозничнойТорговли=ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Объект.Склад, "ТипЦенРозничнойТорговли");
		ЕдиницаХраненияОстатков=ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(ТекущиеДанные.Номенклатура, "ЕдиницаХраненияОстатков");
		
		ТекущиеДанные.ЦенаВРозницеСтарая=ЦенообразованиеСервер.ПолучитьЦенуНоменклатуры(ТекущиеДанные.Номенклатура, ТекущиеДанные.ХарактеристикаНоменклатуры, ТипЦенРозничнойТорговли, Объект.Дата, ЕдиницаХраненияОстатков);
		ТекущиеДанные.ЦенаВРознице=ТекущиеДанные.ЦенаВРозницеСтарая;

	ИначеЕсли стрКолонка="ХарактеристикаНоменклатуры" Или стрКолонка="СерияНоменклатуры" Тогда
		Если НЕ ТекущиеДанные.ХарактеристикаНоменклатуры.Владелец=ТекущиеДанные.Номенклатура Тогда
			ТекущиеДанные.Номенклатура=ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(ТекущиеДанные.ХарактеристикаНоменклатуры, "Владелец");
			Если стрКолонка="ХарактеристикаНоменклатуры" Тогда
				тпТовары_Колонка_ПриИзменении(Элементы.ТоварыНоменклатура);
			КонецЕсли;
		КонецЕсли;

	ИначеЕсли стрКолонка="ЦенаВРозницеСтарая" ИЛИ стрКолонка="ЦенаВРознице" ИЛИ стрКолонка="Количество" Тогда
		ТекущиеДанные.СуммаПереоценки=(ТекущиеДанные.Количество*ТекущиеДанные.ЦенаВРознице)-(ТекущиеДанные.Количество*ТекущиеДанные.ЦенаВРозницеСтарая);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура тпТовары_Колонка_НачалоВыбора(Элемент, СтандартнаяОбработка)
КонецПроцедуры

&НаСервере
Процедура тпТовары_Заполнить(стрКоманда)
	ДокументОбъект=РеквизитФормыВЗначение("Объект");
	
	Если стрКоманда="ЗаполнитьИзУстановкиЦен" Тогда
		Запрос=Новый Запрос;
		Запрос.УстановитьПараметр("ТипЦен", Объект.ТипЦен);
		Запрос.УстановитьПараметр("Док", Объект.ДокументУстановкаЦен);
		Запрос.Текст="
		|ВЫБРАТЬ
		|	УстановкаЦен.Номенклатура КАК Номенклатура,
		|	УстановкаЦен.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
		|	УстановкаЦен.Цена КАК ЦенаВРознице
		|ИЗ
		|	Документ.УстановкаЦенНоменклатуры.Товары КАК УстановкаЦен
		|ГДЕ
		|	УстановкаЦен.Ссылка = &Док
		|	И УстановкаЦен.ТипЦен = &ТипЦен
		|	И НЕ УстановкаЦен.Номенклатура.Услуга
		|";
		ДокументОбъект.Товары.Загрузить(Запрос.Выполнить().Выгрузить());

	ИначеЕсли стрКоманда="ЗаполнитьПоОстаткам" Тогда
		Запрос=Новый Запрос;
		Запрос.УстановитьПараметр("Организация", Объект.Организация);
		Запрос.УстановитьПараметр("Склад", Объект.Склад);
		Запрос.УстановитьПараметр("ТипЦен", Объект.Склад.ТипЦенРозничнойТорговли);
		Запрос.УстановитьПараметр("МоментВремени", Объект.Дата);
		Запрос.Текст="
		|ВЫБРАТЬ
		|	ОстаткиТМЦ.Номенклатура КАК Номенклатура,
		|	ОстаткиТМЦ.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
		|	ОстаткиТМЦ.КоличествоОстаток КАК Количество,
		|	ЦеныНоменклатуры.Цена Как ЦенаВРозницеСтарая
		|ИЗ
		|	РегистрНакопления.ПартииТоваровНаСкладах.Остатки(&МоментВремени, Организация = &Организация	И Склад = &Склад) КАК ОстаткиТМЦ
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&МоментВремени, ТипЦен = &ТипЦен) КАК ЦеныНоменклатуры
		|		ПО ОстаткиТМЦ.Номенклатура = ЦеныНоменклатуры.Номенклатура
		|		И ОстаткиТМЦ.ХарактеристикаНоменклатуры = ЦеныНоменклатуры.ХарактеристикаНоменклатуры
		|ГДЕ
		|	ОстаткиТМЦ.КоличествоОстаток > 0			
		|";
		ДокументОбъект.Товары.Загрузить(Запрос.Выполнить().Выгрузить());

	ИначеЕсли стрКоманда="ЗаполнитьПоСериям" Тогда
		ОбработкаТабличныхЧастей.ЗаполнитьСерии(ДокументОбъект);
	КонецЕсли;

	ЗначениеВРеквизитФормы(ДокументОбъект, "Объект");
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий дополнительных реквизитов табличных частей

&НаКлиенте
Процедура тзРеквизитыТЧ_ПриИзменении_Клиент(Элемент)
	тзРеквизитыТЧ_ПриИзменении_Сервер(Элемент.Имя);
КонецПроцедуры

&НаСервере
Процедура тзРеквизитыТЧ_ПриИзменении_Сервер(стрИмя)
	МетаконфигураторСервер.ДопРеквизиты_ПриИзменении(стрИмя, ЭтаФорма);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СобытияФормыСервер.ПриСозданииНаСервере(Отказ, СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	//УчетнаяПолитика=ОбщегоНазначенияСервер.ПараметрыУчетнойПолитики(Объект.Организация, Объект.Дата);
	СобытияФормыКлиент.ПриОткрытии(Отказ, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	СобытияФормыКлиент.ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	СобытияФормыКлиент.ПриЗакрытии(ЗавершениеРаботы, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	СобытияФормыКлиент.ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	СобытияФормыКлиент.ОбработкаОповещения(ИмяСобытия, Параметр, Источник, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаАктивизации(АктивныйОбъект, Источник)
	СобытияФормыКлиент.ОбработкаАктивизации(АктивныйОбъект, Источник, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗаписиНового(НовыйОбъект, Источник, СтандартнаяОбработка)
	СобытияФормыКлиент.ОбработкаЗаписиНового(НовыйОбъект, Источник, СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)	
	СобытияФормыСервер.ПриЧтенииНаСервере(ТекущийОбъект, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	СобытияФормыКлиент.ПередЗаписью(Отказ, ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	СобытияФормыСервер.ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры
 
&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	СобытияФормыСервер.ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	СобытияФормыСервер.ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	СобытияФормыКлиент.ПослеЗаписи(ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	СобытияФормыКлиент.ВнешнееСобытие(Источник, Событие, Данные, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ВыборЗначения(СтандартнаяОбработка)
	СобытияФормыКлиент.ВыборЗначения(СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры