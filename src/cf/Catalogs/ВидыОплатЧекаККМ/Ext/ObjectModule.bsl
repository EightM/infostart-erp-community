﻿Процедура ПередЗаписью(Отказ)
	Если ОбменДанными.Загрузка Тогда Возврат; КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Если Не ЭтоГруппа И ТипОплаты=Перечисления.ТипыОплатЧекаККМ.БанковскийКредит Тогда
		ПроверяемыеРеквизиты.Добавить("БанкКредитор");
		ПроверяемыеРеквизиты.Добавить("ДоговорВзаиморасчетовБанкаКредитора");
	КонецЕсли;
КонецПроцедуры


