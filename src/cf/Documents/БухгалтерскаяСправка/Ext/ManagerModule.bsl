﻿////////////////////////////////////////////////////////////////////////////////
//Управление печатными формами

Процедура СтруктураПечатныхФорм(Структура) Экспорт
	Структура.Вставить("БухгалтерскаяСправка", "Бухгалтерская справка");
	Структура.Вставить("БухгалтерскаяСправкаНУ", "Бухгалтерская справка(НУ)");
КонецПроцедуры

Функция Печать(СтруктураПараметров, КоличествоЭкземпляров=1, НаПринтер=Ложь, ТабДокумент=Неопределено) Экспорт
	Если СтруктураПараметров.ИмяМакета="БухгалтерскаяСправка" Тогда
		ТабДокумент=ПечатныеФормыСервер.БухгалтерскаяСправка(СтруктураПараметров, "Хозрасчетный");		
	КонецЕсли;

	Если СтруктураПараметров.ИмяМакета="БухгалтерскаяСправкаНУ" Тогда
		ТабДокумент=ПечатныеФормыСервер.БухгалтерскаяСправка(СтруктураПараметров, "Хозрасчетный","НУ");		
	КонецЕсли;

	Возврат ТабДокумент;
КонецФункции