﻿&НаКлиенте
Процедура ВыполнитьДействие(Команда)
	УправлениеДиалогамиКлиент.ВыполнитьДействие(Команда.Имя, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеФормы()
	ДенежныеСредстваКлиент.РасшифровкаПлатежа_ОбновитьПредставлениеДанных(ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура ВыборВидаОперации(Команда)
	ДенежныеСредстваКлиент.ВыборВидаОперации(ЭтаФорма, Команда.Имя, "ВидыОперацийПоступлениеБезналичныхДенежныхСредств");
	//Объект.ВидОперации=ПредопределенноеЗначение("Перечисление.ВидыОперацийПоступлениеБезналичныхДенежныхСредств."+стрЗаменить(Команда.Имя, "Операция_", ""));
	//ДенежныеСредстваКлиент.ПриВыбореВидаОперации(ЭтаФорма);
	ВидимостьЭлементовФормы();
КонецПроцедуры

&НаКлиенте
Процедура ВидимостьЭлементовФормы()
	//Видмость колонок взаиморасчетов
	Видимость=ДенежныеСредстваСервер.ЕстьВзаиморасчеты(Объект.ВидОперации);
	Элементы.РасшифровкаПлатежаДоговорКонтрагента.Видимость=Видимость;
	Элементы.РасшифровкаПлатежаСтавкаНДС.Видимость=Видимость;
	Элементы.РасшифровкаПлатежаСуммаНДС.Видимость=Видимость;
	Элементы.РасшифровкаПлатежаОплачиваемыеДокументы.Видимость=Видимость;

	Если Объект.ВидОперации=ПредопределенноеЗначение("Перечисление.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПриобретениеИностраннойВалюты") Или Объект.ВидОперации=ПредопределенноеЗначение("Перечисление.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПоступленияОтПродажиИностраннойВалюты") Тогда
		Элементы.РасшифровкаПлатежаДоговорКонтрагента.Видимость=Истина;
	КонецЕсли;

	Элементы.ГруппаУчетЗатрат.Видимость=Объект.ВидОперации=ПредопределенноеЗначение("Перечисление.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПоступлениеОплатыПоПлатежнымКартам");

	//УСН
	Видимость=Ложь;
	Если УчетнаяПолитика.СистемаНалогообложения=ПредопределенноеЗначение("Перечисление.СистемыНалогообложения.Упрощенная") Или
		 УчетнаяПолитика.СистемаНалогообложения=ПредопределенноеЗначение("Перечисление.СистемыНалогообложения.Упрощенная_ЕНВД") Тогда
		 Видимость=Истина;
	КонецЕсли;	
	Элементы.РасшифровкаПлатежаСуммаУСН.Видимость=Видимость;
	Элементы.РасшифровкаПлатежаСуммаПатент.Видимость=Видимость;
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьРеквизитыФормы(стрРеквизиты)
	МассивРеквизитов=СтрРазделить(стрРеквизиты, ",");
	Для каждого ИмяРеквизита Из МассивРеквизитов Цикл
		Если ИмяРеквизита="УчетнаяПолитика" Тогда
			УчетнаяПолитика=ОбщегоНазначенияСервер.ПараметрыУчетнойПолитики(Объект.Организация, Объект.Дата);
			ВидимостьЭлементовФормы();
		КонецЕсли; 
	КонецЦикла; 
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСоздалИзменилКуратор()
	Элементы.ГруппаСоздалИзменилКуратор.Заголовок="Создал: "+СокрЛП(Объект.Автор)+" \ "+"Изменил: "+СокрЛП(Объект.ПоследнийАвтор)+" \ "+"Куратор: "+СокрЛП(Объект.Ответственный);
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

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибутов

&НаКлиенте
Процедура Атрибут_ПриИзменении(Элемент)
	Если Элемент.Имя="Дата" Тогда
		ОбновитьРеквизитыФормы("УчетнаяПолитика");

	ИначеЕсли Элемент.Имя="Организация" Тогда
		Объект.СчетОрганизации=?(НЕ Объект.СчетОрганизации.Пустая(), ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Объект.Организация, "ОсновнойБанковскийСчет"), ПредопределенноеЗначение("Справочник.БанковскиеСчета.ПустаяСсылка"));
		ОбновитьРеквизитыФормы("УчетнаяПолитика");

	ИначеЕсли Элемент.Имя="Контрагент" Тогда
		УчетБезНДС=ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Объект.Контрагент, "УчетБезНДС");
		УстановитьПараметрыФункциональныхОпцийФормы(Новый Структура("Контрагент", Объект.Контрагент));
		Элементы.РасшифровкаПлатежаВалюта.Видимость=Элементы.РасшифровкаПлатежаСуммаВал.Видимость;
		
		Объект.СчетКонтрагента=?(ЗначениеЗаполнено(Объект.Контрагент), ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Объект.Контрагент, "ОсновнойБанковскийСчет"), ПредопределенноеЗначение("Справочник.БанковскиеСчета.ПустаяСсылка"));
		ДоговорКонтрагента=ДенежныеСредстваСервер.ДоговорКонтрагентаПоУмолчанию(Объект.Контрагент, Объект.Организация, Объект.ВидОперации);
		Для каждого СтрокаКоллекции Из Объект.РасшифровкаПлатежа Цикл
			Если УчетБезНДС Тогда
				СтрокаКоллекции.СтавкаНДС=ПредопределенноеЗначение("Перечисление.СтавкиНДС.БезНДС");				
			КонецЕсли;
			СтрокаКоллекции.ДоговорКонтрагента=ДоговорКонтрагента;
			тпРасшифровкаПлатежа_Колонка_ПриИзменении(Элементы.РасшифровкаПлатежаДоговорКонтрагента, СтрокаКоллекции);
		КонецЦикла;
		
	ИначеЕсли Элемент.Имя="Ответственный" Тогда
		ОбновитьСоздалИзменилКуратор();
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура Атрибут_НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СобытияЭлементовФормыКлиент.НачалоВыбора(ЭтаФорма, Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура Атрибут_Нажатие(Элемент, СтандартнаяОбработка)
	СобытияЭлементовФормыКлиент.Нажатие(ЭтаФорма, Элемент, СтандартнаяОбработка);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля УНИВЕРСАЛЬНЫЕ

&НаКлиенте
Процедура кпТабличноеПоле_ВыполнитьДействие(Команда)
	стрКоманда=Команда.Имя;
	Если стрКоманда="Сортировать" Тогда
		стрТабличнаяЧасть=стрЗаменить(ЭтаФорма.Элементы.ТабличныеЧасти.ТекущаяСтраница.Имя, "Страница", "");
		СортировкаТабличнойЧастиКлиент.Открыть(стрТабличнаяЧасть, ЭтаФорма, Объект);

	ИначеЕсли стрКоманда="ЗаполнитьТОП" Тогда
		стрТабличнаяЧасть=стрЗаменить(ЭтаФорма.Элементы.ТабличныеЧасти.ТекущаяСтраница.Имя, "Страница", "");
		ЗаполнитьТиповыеОперации(стрТабличнаяЧасть);		
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Расшифровка платежа"

&НаКлиенте
Процедура кпРасшифровкаПлатежа_ВыполнитьДействие(Команда)
	//стрКоманда=стрЗаменить(Команда.Имя, "кпРасшифровкаПлатежа_", "");
КонецПроцедуры

&НаКлиенте
Процедура тпРасшифровкаПлатежа_Колонка_ПриИзменении(Элемент, ТекущиеДанные=Неопределено) Экспорт
	ДенежныеСредстваКлиент.РасшифровкаПлатежа_Колонка_ПриИзменении(ЭтаФорма, Элемент, ТекущиеДанные);
КонецПроцедуры

&НаКлиенте
Процедура тпРасшифровкаПлатежа_Колонка_НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ДенежныеСредстваКлиент.РасшифровкаПлатежа_НачалоВыбора(ЭтаФорма, Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура тпРасшифровкаПлатежа_ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	Если НоваяСтрока Тогда
		Элемент.ТекущиеДанные.ID=Строка(Новый УникальныйИдентификатор);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура тпРасшифровкаПлатежа_Выбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ДенежныеСредстваКлиент.РасшифровкаПлатежа_Выбор(ЭтаФорма, Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СобытияФормыСервер.ПриСозданииНаСервере(Отказ, СтандартнаяОбработка, ЭтаФорма, Объект);	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьПараметрыФункциональныхОпцийФормы(Новый Структура("Контрагент", Объект.Контрагент));
	Элементы.РасшифровкаПлатежаВалюта.Видимость=Элементы.РасшифровкаПлатежаСуммаВал.Видимость;
	ОбновитьРеквизитыФормы("УчетнаяПолитика");
	Если НЕ Объект.Ссылка.Пустая() Тогда
		ОбновитьДанныеФормы();	
	КонецЕсли;
	ОбновитьСоздалИзменилКуратор();
	Элементы.РасшифровкаПлатежаОплачиваемыеДокументы.Видимость=ОбщегоНазначенияСервер.ПроверкаРасширения("lab33_ПлатежныйКалендарь");
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
	Объект.СуммаДокумента=Объект.РасшифровкаПлатежа.Итог("СуммаПлатежа");
	Объект.СуммаДокументаУСН=Объект.РасшифровкаПлатежа.Итог("СуммаУСН");
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
	ОбновитьДанныеФормы();
	СобытияФормыКлиент.ПослеЗаписи(ПараметрыЗаписи, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	СобытияФормыКлиент.ВнешнееСобытие(Источник, Событие, Данные, ЭтаФорма, Объект);
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
КонецПроцедуры

&НаКлиенте
Процедура ВыборЗначения(СтандартнаяОбработка)
	СобытияФормыКлиент.ВыборЗначения(СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры
