﻿&НаКлиенте
Процедура УстановитьДоступность()
	ЭтоРозничныйСклад=Объект.ВидСклада=ПредопределенноеЗначение("Перечисление.ВидыСкладов.Розничный");
	Элементы.ТипЦенРозничнойТорговли.АвтоОтметкаНезаполненного=ЭтоРозничныйСклад;
	Элементы.ТипЦенРозничнойТорговли.ОтметкаНезаполненного=ЭтоРозничныйСклад;
	Элементы.НомерСекции.Видимость=ЭтоРозничныйСклад;
	Элементы.РасчетРозничныхЦенПоТорговойНаценке.Видимость=ЭтоРозничныйСклад;
	Элементы.ТипЦенРозничнойТорговли.Видимость=ЭтоРозничныйСклад;

	Элементы.Ячеистый.Видимость=Объект.ВидСклада=ПредопределенноеЗначение("Перечисление.ВидыСкладов.Оптовый");
	Если Не Элементы.Ячеистый.Видимость И Объект.Ячеистый Тогда Объект.Ячеистый=Ложь; КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОтборыСписков()
	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(ОтветственныеЛица, "СтруктурнаяЕдиница", Объект.Ссылка);
	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(МестаХранения, "Склад", Объект.Ссылка);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибутов шапки

&НаКлиенте
Процедура АтрибутФормы_ПриИзменении(Элемент)
	стрИмя=Элемент.Имя;
	Если Элемент.Имя="ВидСклада" Тогда
		УстановитьДоступность();
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СобытияФормыСервер.ПриСозданииНаСервере(Отказ, СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если Объект.Ссылка.Пустая() Тогда
		Объект.ТипЦенРозничнойТорговли=Неопределено;
	КонецЕсли;
	
	УстановитьДоступность();
	УстановитьОтборыСписков();

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
	УстановитьОтборыСписков();
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