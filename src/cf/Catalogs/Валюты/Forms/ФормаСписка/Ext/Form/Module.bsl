﻿&НаКлиенте
Процедура ПодборИзОКВ(Команда)
	ОткрытьФорму("Справочник.Валюты.Форма.ПодборВалютИзКлассификатора",,ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьКурсыВалют(Команда)
	ОткрытьФорму("Обработка.ЗагрузкаКурсовВалют.Форма", Новый Структура("ОткрытиеИзСписка"));
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("АвтоТест") Тогда Возврат; КонецЕсли;
	
	Список.Параметры.УстановитьЗначениеПараметра("КонецПериода", НачалоДня(ТекущаяДатаСеанса()));
	Список.Параметры.УстановитьЗначениеПараметра("ПояснениеКратности", НСтр("ru = 'руб. за'"));
	
	Элементы.Валюты.РежимВыбора=Параметры.РежимВыбора;	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(РезультатВыбора, ИсточникВыбора)
	Элементы.Валюты.Обновить();
	Элементы.Валюты.ТекущаяСтрока=РезультатВыбора;	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	Если ИмяСобытия="Запись_КурсыВалют"	Или ИмяСобытия="Запись_ЗагрузкаКурсовВалют" Тогда
		Элементы.Валюты.Обновить();
	КонецЕсли;
КонецПроцедуры