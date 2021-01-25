﻿////////////////////////////////////////////////////////////////////////////////
//Управление печатными формами

Процедура СтруктураПечатныхФорм(Структура) Экспорт
	Структура.Вставить("ПереоценкаТоваровВРознице", "Переоценка товаров в рознице");
КонецПроцедуры

Функция ИнициализацияМакета(СтруктураПараметров, стрМакет)
	Если СтруктураПараметров.Свойство("Макет") Тогда
		Возврат СтруктураПараметров.Макет;
	КонецЕсли;
	Макет=СтруктураПараметров.МакетШаблон;
	Если Макет=Неопределено Тогда
		Если Метаданные.ОбщиеМакеты.Найти(стрМакет)=Неопределено Тогда
			Макет=ПолучитьМакет(стрМакет);
		Иначе
			Макет=ПолучитьОбщийМакет(стрМакет);
		КонецЕсли;
	КонецЕсли;
	Возврат Макет;
КонецФункции

Функция Печать_ПереоценкиТоваровВРознице(СтруктураПараметров)
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СтруктураПараметров.СсылкаНаОбъект);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Дата КАК Дата,
	|	ИсточникДанных.Склад КАК Склад,
	|	ИсточникДанных.Товары.(Номенклатура КАК Номенклатура, ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры) КАК Товары
	|ИЗ
	|	Документ.ПереоценкаТоваровВРознице КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Ссылка = &ТекущийДокумент
	|";
	Шапка=Запрос.Выполнить().Выбрать();
	Шапка.Следующий();
	тзТовары=Шапка.Товары.Выгрузить();
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокСсылка", СтруктураПараметров.СсылкаНаОбъект);
	Запрос.УстановитьПараметр("Склад", Шапка.Склад);
	Запрос.УстановитьПараметр("СписокНоменклатуры", тзТовары.ВыгрузитьКолонку("Номенклатура"));
	Запрос.УстановитьПараметр("СписокХарактеристик", тзТовары.ВыгрузитьКолонку("ХарактеристикаНоменклатуры"));
	Запрос.УстановитьПараметр("Дата", Шапка.Дата);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Док.Ссылка.Номер,
	|	Док.Ссылка.Дата,
	|	Док.Ссылка.Организация,
	|	Док.Ссылка.Организация КАК Поставщик,
	|	Док.Ссылка.Склад КАК Получатель,
	|	Док.Ссылка.Склад.Представление КАК ПредставлениеПолучателя,
	|	Док.НомерСтроки КАК НомерСтроки,
	|	Док.Количество КАК Количество,
	|	Док.Номенклатура КАК Номенклатура,
	|	Док.Номенклатура.НаименованиеПолное КАК Товар,
	|	Док.Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаИзмерения,
	|	Док.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент,
	|	Док.ЦенаВРозницеСтарая КАК ЦенаВРозницеСтарая,
	|	Док.ЦенаВРознице,
	|	Док.СуммаПереоценки КАК ОтклонениеСтоимости,
	|	Док.ХарактеристикаНоменклатуры КАК Характеристика,
	|	Док.СерияНоменклатуры КАК Серия
	|ИЗ
	|	Документ.ПереоценкаТоваровВРознице.Товары КАК Док
	|ГДЕ
	|	Док.Ссылка = &ДокСсылка
	|";
	Шапка=Запрос.Выполнить().Выбрать();
	Если Не Шапка.Следующий() Тогда Возврат Неопределено; КонецЕсли;

	ТабДокумент = Новый ТабличныйДокумент;
	//*** ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ПереоценкаТоваровВРознице_ПереоценкаТоваровВРознице";
	Макет = ИнициализацияМакета(СтруктураПараметров, "ПереоценкаТоваровВРознице");

	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = ОбщегоНазначения.СформироватьЗаголовокДокумента(СтруктураПараметров.СсылкаНаОбъект, "Переоценка товаров в рознице");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ОбластьМакета.Параметры.ПредставлениеПоставщика = ПечатныеФормыСервер.ОписаниеОрганизации(КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата), "ПолноеНаименование,");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Строка");

	ИтогОтклонениеСтоимости = 0;
	ВыборкаСтрокТовары = Шапка;
	ВыборкаСтрокТовары.Сбросить();
	Пока ВыборкаСтрокТовары.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(ВыборкаСтрокТовары.Номенклатура) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;

		ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТовары);
		ОбластьМакета.Параметры.Товар = ВыборкаСтрокТовары.Товар + ПечатныеФормыСервер.ПредставлениеСерий(ВыборкаСтрокТовары);
		ТабДокумент.Вывести(ОбластьМакета);

		ИтогОтклонениеСтоимости = ИтогОтклонениеСтоимости + ВыборкаСтрокТовары.ОтклонениеСтоимости;
	КонецЦикла;

	ОбластьМакета = Макет.ПолучитьОбласть("Итог");
	ОбластьМакета.Параметры.ИтогОтклонениеСтоимости = ИтогОтклонениеСтоимости;
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;
КонецФункции

Функция Печать(СтруктураПараметров, КоличествоЭкземпляров=1, НаПринтер=Ложь, ТабДокумент=Неопределено) Экспорт
	Если СтруктураПараметров.СсылкаНаОбъект.Пустая() Тогда
		Сообщить("Документ можно распечатать только после его записи");
		Возврат Неопределено;

	ИначеЕсли Не УправлениеПользователямиСервер.РазрешитьПечатьНепроведенныхДокументов(СтруктураПараметров.СсылкаНаОбъект.Проведен) Тогда
		Сообщить("Недостаточно полномочий для печати непроведенного документа!");
		Возврат Неопределено;
	КонецЕсли;
	
	Если Не СтруктураПараметров.СсылкаНаОбъект.Проведен Тогда
		Сообщить("Документ можно распечатать только после его проведения");
		Возврат Неопределено;
	КонецЕсли;

	Если СтруктураПараметров.ИмяМакета="ПереоценкаТоваровВРознице" Тогда
		ТабДокумент=Печать_ПереоценкиТоваровВРознице(СтруктураПараметров);
	КонецЕсли;

	Возврат ТабДокумент;
КонецФункции
