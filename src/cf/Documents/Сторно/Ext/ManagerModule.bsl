﻿////////////////////////////////////////////////////////////////////////////////
//Управление печатными формами

Процедура СтруктураПечатныхФорм(Структура) Экспорт
	Структура.Вставить("БухгалтерскаяСправка", "Бухгалтерская справка");
КонецПроцедуры

Функция Печать(СтруктураПараметров, КоличествоЭкземпляров=1, НаПринтер=Ложь, ТабДокумент=Неопределено) Экспорт
	Если СтруктураПараметров.ИмяМакета="БухгалтерскаяСправка" Тогда
		ТабДокумент=ПечатныеФормыСервер.БухгалтерскаяСправка(СтруктураПараметров, "Хозрасчетный");
	КонецЕсли;
	Возврат ТабДокумент;
КонецФункции