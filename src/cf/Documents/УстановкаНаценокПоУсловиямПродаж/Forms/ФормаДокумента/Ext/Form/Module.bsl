﻿&НаСервере
Функция ТипЗначенияГруппы()
	Если Объект.ВидОперации=Перечисления.ВидыОперацийУстановкаНаценокПоУсловиямПродаж.ПоНоменклатурнымГруппам Тогда
		Возврат Тип("СправочникСсылка.НоменклатурныеГруппы");
	ИначеЕсли Объект.ВидОперации=Перечисления.ВидыОперацийУстановкаНаценокПоУсловиямПродаж.ПоЦеновымГруппам Тогда
		Возврат Тип("СправочникСсылка.ЦеновыеГруппы");
	КонецЕсли;
КонецФункции 

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
	Если Элемент.Имя="ВидОперации" Тогда
		тпНаценки_ОграничениеТипа();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Атрибут_Нажатие(Элемент, СтандартнаяОбработка)
	СобытияЭлементовФормыКлиент.Нажатие(ЭтаФорма, Элемент, СтандартнаяОбработка);
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
// Обработчики событий "Шкалы диапазонов"

&НаКлиенте
Процедура тпНаценки_ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	Если НоваяСтрока Тогда
		Элемент.ТекущиеДанные.ID=Строка(Новый УникальныйИдентификатор);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура тпНаценки_ОграничениеТипа()
	Массив=Новый Массив;
	Массив.Добавить(ТипЗначенияГруппы());
	Элементы.НаценкиНоменклатурнаяЦеноваяГруппа.ОграничениеТипа=Новый ОписаниеТипов(Массив);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	СобытияФормыСервер.ПриСозданииНаСервере(Отказ, СтандартнаяОбработка, ЭтаФорма, Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	тпНаценки_ОграничениеТипа();
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
