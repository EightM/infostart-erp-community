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
	
		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" | Куратор: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Ответственный));

		МассивДанных.Добавить(Новый ФорматированнаяСтрока(" | Комментарий: ", Новый Шрифт(,,Истина), Новый Цвет(0,0,255)));
		МассивДанных.Добавить(СокрЛП(Объект.Комментарий));

		Элементы.ШапкаИнфо.Заголовок=Новый ФорматированнаяСтрока(МассивДанных);		
	Иначе
		УправлениеДиалогамиКлиент.ВыполнитьДействие(Команда.Имя, ЭтаФорма, Объект);
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьРеквизитыФормы(стрРеквизиты)
	МассивРеквизитов=СтрРазделить(стрРеквизиты, ",");
	Для каждого ИмяРеквизита Из МассивРеквизитов Цикл
		Если ИмяРеквизита="УчетнаяПолитика" Тогда
			УчетнаяПолитика=ОбщегоНазначенияСервер.ПараметрыУчетнойПолитики(Объект.Организация, Объект.Дата);
		КонецЕсли;
	КонецЦикла; 
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьНДС()
	СтрокиНеПодтверждено=Объект.Состав.НайтиСтроки(Новый Структура("Событие", ПредопределенноеЗначение("Перечисление.СобытияПоНДСПродажи.НеПодтвержденаСтавка0")));
	Если СтрокиНеПодтверждено.Количество()=0 Тогда Возврат; КонецЕсли;

	ОбновитьРеквизитыФормы("УчетнаяПолитика");
	НДСПриНеподтвержденииСверху=?(ЗначениеЗаполнено(Объект.Организация), УчетнаяПолитика.НДСПриНеподтвержденииСверху, Ложь);

	ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_ЗаполнитьНалогиСостава", ЭтотОбъект, Новый Структура("НДСПриНеподтвержденииСверху,Строки", НДСПриНеподтвержденииСверху, СтрокиНеПодтверждено));
	ПоказатьВопрос(ОписаниеОповещения, "Изменился метод начисления НДС при невозможности подтверждения ставки НДС 0%. Пересчитать суммы НДС табличной части?", РежимДиалогаВопрос.ДаНетОтмена, 20, КодВозвратаДиалога.Отмена, "Внимание", КодВозвратаДиалога.Отмена);
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
// Обработчики оповещения

&НаКлиенте
Процедура ОбработчикОповещения_ЗаполнитьСостав(Параметр1, Параметр2=Неопределено) Экспорт
	Если НЕ Параметр1=КодВозвратаДиалога.Да Тогда Возврат; КонецЕсли;
	Объект.Состав.Очистить();
	ЗаполнитьСтрокиДокумента();
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОповещения_ЗаполнитьНалогиСостава(Параметр1, Параметр2=Неопределено) Экспорт
	Если НЕ Параметр1=КодВозвратаДиалога.Да Тогда Возврат; КонецЕсли;

	Для Каждого СтрокаКоллекции Из Параметр2.Строки Цикл
		СтрокаКоллекции.СтавкаНДС=ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС20"+?(Параметр2.НДСПриНеподтвержденииСверху, "", "_120"));
		СтрокаКоллекции.СуммаНДС=УчетНалоговСервер.РассчитатьСуммуНДС(СтрокаКоллекции.ПродажиСНДС0, Истина, Не Параметр2.НДСПриНеподтвержденииСверху, СтрокаКоллекции.СтавкаНДС);
	КонецЦикла;				
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Стандартные (универсальные) процедуры\функции

&НаСервере
Процедура ВыполнитьСортировкуТабличнойЧасти(ИмяТабличнойЧасти, стрСортировка) Экспорт
	СортировкаТабличнойЧастиСервер.Сортировать(ИмяТабличнойЧасти, стрСортировка, Объект);
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСтрокиДокумента() Экспорт
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("КонецПериода",  Новый Граница(КонецДня(Объект.Дата), ВидГраницы.Включая));
	Запрос.УстановитьПараметр("Организация",   Объект.Организация);
	Запрос.УстановитьПараметр("СостояниеПредположения0", Перечисления.НДССостоянияРеализация0.ОжидаетсяПодтверждение);	
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.СчетФактура,
	|	ИсточникДанных.ВидЦенности,
	|	ИсточникДанных.СтавкаНДС,
	|	ИсточникДанных.СуммаБезНДСОстаток + ИсточникДанных.НДСОстаток КАК ПродажиСНДС0,
	|	ИсточникДанных.Покупатель
	|ИЗ
	|	РегистрНакопления.НДСРеализация0.Остатки(&КонецПериода,	Организация = &Организация И Состояние = &СостояниеПредположения0) КАК ИсточникДанных
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		НоваяСтрока=Объект.Состав.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
		НоваяСтрока.Событие=Перечисления.СобытияПоНДСПродажи.ПодтвержденаСтавка0;
		Если Год(Объект.Дата)>2018 Тогда
			НоваяСтрока.СтавкаНДС=Перечисления.СтавкиНДС.НДС20_120;	
		Иначе	
			НоваяСтрока.СтавкаНДС=Перечисления.СтавкиНДС.НДС18_118;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибутов

&НаКлиенте
Процедура Атрибут_ПриИзменении(Элемент)
	Если Элемент.Имя="Дата" Тогда
		ПересчитатьНДС();

	ИначеЕсли Элемент.Имя="Организация" Тогда
		ПересчитатьНДС();
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
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Состав"

&НаКлиенте
Процедура кпСостав_ВыполнитьДействие(Команда)
	стрТабличнаяЧасть="Состав"; стрКоманда=стрЗаменить(Команда.Имя, "кп"+стрТабличнаяЧасть+"_", "");
		
	Если стрКоманда="Заполнить" Тогда
		Если Объект.Проведен Тогда
			ПоказатьПредупреждение(,"Заполнение возможно только в непроведенном документе", 60,);
			Отказ=Истина; Возврат;
		КонецЕсли;
		Если Объект.Состав.Количество() > 0 Тогда
			ПоказатьВопрос(Новый ОписаниеОповещения("ОбработчикОповещения_ЗаполнитьСостав", ЭтотОбъект), "Табличное поле будет очищено. Продолжить?", РежимДиалогаВопрос.ДаНет, 60, КодВозвратаДиалога.Нет);
		Иначе
			ЗаполнитьСтрокиДокумента();
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура тпСостав_Колонка_ПриИзменении(Элемент)
	стрКолонка=стрЗаменить(Элемент.Имя, "Состав", "");
	ТекущиеДанные=Элементы.Состав.ТекущиеДанные;

	Если стрКолонка="Событие" Тогда
		МассивСтрок=Новый Массив;
		МассивСтрок.Добавить(ТекущиеДанные);
		ОбработчикОповещения_ЗаполнитьНалогиСостава(КодВозвратаДиалога.Да, Новый Структура("НДСПриНеподтвержденииСверху,Строки", Ложь, МассивСтрок));

	ИначеЕсли стрКолонка="ПродажиСНДС0" Тогда
		ТекущиеДанные.СуммаНДС=УчетНалоговСервер.РассчитатьСуммуНДС(ТекущиеДанные.ПродажиСНДС0, Истина, Ложь, ТекущиеДанные.СтавкаНДС);		
	ИначеЕсли стрКолонка="СтавкаНДС" Тогда
		ТекущиеДанные.СуммаНДС=УчетНалоговСервер.РассчитатьСуммуНДС(ТекущиеДанные.ПродажиСНДС0, Истина, Ложь, ТекущиеДанные.СтавкаНДС);		
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура тпСостав_ПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	Если НоваяСтрока Тогда
		Элемент.ТекущиеДанные.ID=Строка(Новый УникальныйИдентификатор);
	КонецЕсли;
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
	ОбновитьРеквизитыФормы("УчетнаяПолитика"); ПересчитатьНДС();
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