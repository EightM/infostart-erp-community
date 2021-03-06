﻿Перем ПараметрыПриложения Экспорт;
Перем глПодключаемоеОборудование Экспорт; // для кэширования на клиенте
Перем глЗапрашиватьПодтверждениеПриЗакрытии Экспорт;
Перем глОбщиеЗначения;
Перем ПараметрыВнешнихРегламентированныхОтчетов Экспорт;
Перем КонтекстЭДО Экспорт;
Перем ПараметрыКлиента Экспорт;

Процедура ПередНачаломРаботыСистемы(Отказ)
	//*** СтандартныеПодсистемыКлиент.ПередНачаломРаботыСистемы();

	//*** ShareСервер.Share_ДобавитьРоль();
	ShareСервер.Share_УдалитьСсылкиПоДате();
	Если ПараметрыПриложения = Неопределено Тогда
		ПараметрыПриложения = Новый Соответствие;
	КонецЕсли;
КонецПроцедуры

Процедура ПриНачалеРаботыСистемы()
	//*** СтандартныеПодсистемыКлиент.ПриНачалеРаботыСистемы();
	Если НЕ УправлениеКонфигурациейСервер.КонфигурацияЗарегистрированна() Тогда
		ОткрытьФорму("Обработка.Регистрация.Форма.Форма");
	КонецЕсли; 
КонецПроцедуры

Процедура ПередЗавершениемРаботыСистемы(Отказ, ТекстПредупреждения)
	//*** СтандартныеПодсистемыКлиент.ПередЗавершениемРаботыСистемы(Отказ, ТекстПредупреждения);	
КонецПроцедуры

Процедура ОбработкаВнешнегоСобытия(Источник, Событие, Данные)
КонецПроцедуры

Функция глЗначениеПеременной(Имя) Экспорт
	Возврат ОбщегоНазначения.ПолучитьЗначениеПеременной(Имя, глОбщиеЗначения);
КонецФункции

Процедура глЗначениеПеременнойУстановить(Имя, Значение, ОбновлятьВоВсехКэшах = Ложь) Экспорт
	ОбщегоНазначения.УстановитьЗначениеПеременной(Имя, глОбщиеЗначения, Значение, ОбновлятьВоВсехКэшах);
КонецПроцедуры