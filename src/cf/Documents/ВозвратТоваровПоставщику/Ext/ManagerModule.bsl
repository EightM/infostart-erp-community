﻿////////////////////////////////////////////////////////////////////////////////
//Управление печатными формами

Процедура СтруктураПечатныхФорм(Структура) Экспорт
	Структура.Вставить("Накладная", "Возврат поставщику");
	Структура.Вставить("ТОРГ12", "ТОРГ-12 (Товарная накладная)");
	Структура.Вставить("РасходСРозничныхСкладовВЦенахАТТ" , "Расход с розничных складов в ценах АТТ");
	Структура.Вставить("БухгалтерскаяСправка", "Бухгалтерская cправка");
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

Функция Печать_ВозвратаПоставщику(СтруктураПараметров)
    СсылкаНаОбъект=СтруктураПараметров.СсылкаНаОбъект;
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Номер,
	|	Дата,
	|	ДоговорКонтрагента,
	|	Контрагент,
	|	Организация,
	|	СуммаДокумента,
	|	ВалютаДокумента,
	|	УчитыватьНДС,
	|	СуммаВключаетНДС,
	|	Товары.(
	|		Номенклатура,
	|		ВЫРАЗИТЬ(Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК Товар,
	|		Количество,
	|		ЕдиницаИзмерения.Представление  КАК ЕдиницаИзмерения,
	|		Цена,
	|		Сумма,
	|		СуммаНДС,
	|		ХарактеристикаНоменклатуры КАК Характеристика,
	|		СерияНоменклатуры КАК Серия
	|	),
	|	ВозвратнаяТара.(
	|		Номенклатура,
	|		ВЫРАЗИТЬ(Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК Товар,
	|		Количество,
	|		Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаИзмерения,
	|		Цена,
	|		Сумма
	|	)
	|ИЗ
	|	Документ.ВозвратТоваровПоставщику КАК ВозвратТоваровПоставщику
	|
	|ГДЕ
	|	ВозвратТоваровПоставщику.Ссылка = &ТекущийДокумент
	|
	|УПОРЯДОЧИТЬ ПО
	|	Товары.НомерСтроки,
	|	ВозвратнаяТара.НомерСтроки
	|";

	Шапка=Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	ВыборкаСтрокТовары = Шапка.Товары.Выбрать();
	ВыборкаСтрокТара   = Шапка.ВозвратнаяТара.Выбрать();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ВозвратТоваровПоставщику_Накладная";

	Макет=ИнициализацияМакета(СтруктураПараметров, "Накладная");

	// Выводим шапку накладной

	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = ОбщегоНазначения.СформироватьЗаголовокДокумента(СсылкаНаОбъект, "Возврат поставщику");
	ТабДокумент.Вывести(ОбластьМакета);

	ПредставлениеОрганизации = ПечатныеФормыСервер.ОписаниеОрганизации(КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата), "ПолноеНаименование,");
	ПредставлениеКонтрагента = ПечатныеФормыСервер.ОписаниеОрганизации(КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.Контрагент, Шапка.Дата), "ПолноеНаименование,");

	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
	ОбластьМакета.Параметры.ПредставлениеПоставщика = ПредставлениеКонтрагента;
	ОбластьМакета.Параметры.Поставщик = Шапка.Контрагент;
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	ОбластьМакета.Параметры.ПредставлениеПолучателя = ПредставлениеОрганизации;
	ОбластьМакета.Параметры.Получатель = Шапка.Организация;
	ТабДокумент.Вывести(ОбластьМакета);

	// Вывести табличную часть
	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Строка");
	Сумма    = 0;
	СуммаНДС = 0;
	Ном      = 0;

	// Товары
	Пока ВыборкаСтрокТовары.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(ВыборкаСтрокТовары.Номенклатура) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;

		Ном = Ном + 1;

		ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТовары);
		ОбластьМакета.Параметры.НомерСтроки = Ном;
		ОбластьМакета.Параметры.Товар       = СокрЛП(ВыборкаСтрокТовары.Товар) + ПечатныеФормыСервер.ПредставлениеСерий(ВыборкаСтрокТовары);
		ТабДокумент.Вывести(ОбластьМакета);

		Сумма    = Сумма    + ВыборкаСтрокТовары.Сумма;
		СуммаНДС = СуммаНДС + ВыборкаСтрокТовары.СуммаНДС;
	КонецЦикла;

	// Тара
	Пока ВыборкаСтрокТара.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(ВыборкаСтрокТара.Номенклатура) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;
		Ном=Ном+1;

		ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТара);
		ОбластьМакета.Параметры.НомерСтроки=Ном;
		ОбластьМакета.Параметры.Товар=СокрЛП(ВыборкаСтрокТара.Товар)+" (возвратная тара)";
		ТабДокумент.Вывести(ОбластьМакета);

		Сумма=Сумма+ВыборкаСтрокТара.Сумма;
	КонецЦикла;

	// Вывести Итого
	ОбластьМакета = Макет.ПолучитьОбласть("Итого");
	ОбластьМакета.Параметры.Всего = ОбщегоНазначения.ФорматСумм(Сумма);
	ТабДокумент.Вывести(ОбластьМакета);

	// Вывести ИтогоНДС
	Если Шапка.УчитыватьНДС Тогда
		ОбластьМакета = Макет.ПолучитьОбласть("ИтогоНДС");
		ОбластьМакета.Параметры.ВсегоНДС = ОбщегоНазначения.ФорматСумм(Шапка.Товары.Выгрузить().Итог("СуммаНДС"));
		ОбластьМакета.Параметры.НДС = ?(Шапка.СуммаВключаетНДС, "В том числе НДС:", "Сумма НДС:");
		ТабДокумент.Вывести(ОбластьМакета);
	КонецЕсли;

	// Вывести Сумму прописью
	ОбластьМакета = Макет.ПолучитьОбласть("СуммаПрописью");
	СуммаКПрописи = Сумма + ?(Шапка.СуммаВключаетНДС, 0, СуммаНДС);
	ОбластьМакета.Параметры.ИтоговаяСтрока ="Всего наименований " + ВыборкаСтрокТовары.Количество()
	+ ", на сумму " + ОбщегоНазначения.ФорматСумм(СуммаКПрописи, Шапка.ВалютаДокумента);
	ОбластьМакета.Параметры.СуммаПрописью = ОбщегоНазначения.СформироватьСуммуПрописью(СуммаКПрописи, Шапка.ВалютаДокумента);
	ТабДокумент.Вывести(ОбластьМакета);

	// Вывести подписи
	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;
КонецФункции

Функция Печать_ТОРГ12(СтруктураПараметров)
    СсылкаНаОбъект=СтруктураПараметров.СсылкаНаОбъект;
	
	ЕдиницаИзмеренияВеса = Константы.ЕдиницаИзмеренияВеса.Получить();

	Колонка=Константы.ДополнительнаяКолонкаПечатныхФормДокументов.Получить();
	ТоварКод=?(Колонка="","Код",Колонка);
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДатаСреза",          СсылкаНаОбъект.Дата);
	Запрос.УстановитьПараметр("СтруктурнаяЕдиница", СсылкаНаОбъект.Склад);
	Запрос.УстановитьПараметр("ТекущийДокумент",    СсылкаНаОбъект);
	Запрос.УстановитьПараметр("ПустойКонтрагент",   Справочники.Контрагенты.ПустаяСсылка());
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Дата КАК ДатаДокумента,
	|	Номер КАК НомерДокумента,
	|	Организация КАК Руководители,
	|	Организация КАК Организация,
	|	Контрагент КАК Контрагент,
	|	ДоговорКонтрагента Как ДоговорКонтрагента,
	|	Организация КАК Поставщик,
	|	ВалютаДокумента,
	|	КурсВзаиморасчетов,
	|	КратностьВзаиморасчетов,
	|	ВЫБОР КОГДА Грузополучатель = &ПустойКонтрагент
	|	      ТОГДА Контрагент
	|	      ИНАЧЕ Грузополучатель КОНЕЦ КАК Грузополучатель,
	|	ВЫБОР КОГДА Грузоотправитель = &ПустойКонтрагент
	|	      ТОГДА Организация
	|	      ИНАЧЕ Грузоотправитель КОНЕЦ КАК Грузоотправитель,
	|	БанковскийСчетОрганизации КАК БанковскийСчет,
	|	Контрагент КАК Плательщик,
	|	Сделка,
	|	ДоговорКонтрагента.Представление КАК Основание,
	|	ОтветственныеЛица.ФизическоеЛицо КАК ОтветственноеЛицо,
	|	Подразделение,
	|	ВалютаДокумента,
	|	УчитыватьНДС,
	|	СуммаВключаетНДС
	|
	|ИЗ
	|	Документ.ВозвратТоваровПоставщику КАК ВозвратТоваровПоставщику,
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.ОтветственныеЛица.СрезПоследних(&ДатаСреза, СтруктурнаяЕдиница = &СтруктурнаяЕдиница) КАК ОтветственныеЛица
	|ПО
	|	ОтветственныеЛица.СтруктурнаяЕдиница = ВозвратТоваровПоставщику.Склад
	|
	|ГДЕ
	|	ВозвратТоваровПоставщику.Ссылка = &ТекущийДокумент
	|";

	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);

	Если Шапка.ВалютаДокумента = Шапка.ДоговорКонтрагента.ВалютаВзаиморасчетов Тогда
		// Документ оформлен в валюте взаиморасчетов
		Запрос.УстановитьПараметр("Курс", Шапка.КурсВзаиморасчетов);
		Запрос.УстановитьПараметр("Кратность", Шапка.КратностьВзаиморасчетов);
	Иначе
		// Документ оформлен в валюте регламентированного учета
		Запрос.УстановитьПараметр("Курс", 1);
		Запрос.УстановитьПараметр("Кратность", 1);
	КонецЕсли;

	Запрос.Текст="
	|ВЫБРАТЬ
	|	ВложенныйЗапрос.Номенклатура                    КАК Номенклатура,
	|	ВЫРАЗИТЬ(ВложенныйЗапрос.Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК ТоварНаименование,
	|	ВложенныйЗапрос.Номенклатура." + ТоварКод + "   КАК ТоварКод,
	|	ВложенныйЗапрос.ЕдиницаИзмерения.Представление  КАК БазоваяЕдиницаНаименование,
	|	ВложенныйЗапрос.ЕдиницаИзмерения.ЕдиницаПоКлассификатору.Код КАК БазоваяЕдиницаКодПоОКЕИ,
	|	ВложенныйЗапрос.ЕдиницаИзмерения    КАК ЕдиницаИзмерения,
	|	ВложенныйЗапрос.ЕдиницаИзмеренияМест.Представление            КАК ВидУпаковки,
	|	ВложенныйЗапрос.КоэффициентМест / ВложенныйЗапрос.Коэффициент КАК КоличествоВОдномМесте,
	|	ВЫБОР
	|		КОГДА ВложенныйЗапрос.КоличествоМест > 0 ТОГДА ВложенныйЗапрос.КоличествоМест * ВложенныйЗапрос.ЕдиницаИзмеренияМест.Вес
	|		ИНАЧЕ ВложенныйЗапрос.Количество * ВложенныйЗапрос.ЕдиницаИзмерения.Вес
	|	КОНЕЦ КАК МассаБрутто,
	|	ВложенныйЗапрос.Характеристика      КАК Характеристика,
	|	ВложенныйЗапрос.Серия               КАК Серия,
	|	ВложенныйЗапрос.СтавкаНДС           КАК СтавкаНДС,
	|	ВложенныйЗапрос.Цена                КАК Цена,
	|	ВложенныйЗапрос.Количество          КАК Количество,
	|	ВложенныйЗапрос.КоличествоМест      КАК КоличествоМест,
	|	ВложенныйЗапрос.Сумма               КАК Сумма,
	|	ВложенныйЗапрос.СуммаНДС            КАК СуммаНДС,
	|	ВложенныйЗапрос.НомерСтроки         КАК НомерСтроки,
	|	ВложенныйЗапрос.Метка               КАК Метка
	|ИЗ
	|
	|	(
	|	ВЫБРАТЬ
	|		ВозвратТоваровПоставщику.Номенклатура,
	|		ВозвратТоваровПоставщику.Коэффициент,
	|		ВозвратТоваровПоставщику.ЕдиницаИзмерения,
	|		ВозвратТоваровПоставщику.ЕдиницаИзмеренияМест,
	|		ВозвратТоваровПоставщику.ЕдиницаИзмеренияМест.Коэффициент     КАК КоэффициентМест,
	|		ВозвратТоваровПоставщику.ХарактеристикаНоменклатуры КАК Характеристика,
	|		ВозвратТоваровПоставщику.СерияНоменклатуры          КАК Серия,
	|		ВозвратТоваровПоставщику.СтавкаНДС,
	|		ВозвратТоваровПоставщику.Цена * &Курс / &Кратность            КАК Цена,
	|		СУММА(ВозвратТоваровПоставщику.Количество)                    КАК Количество,
	|		СУММА(ВозвратТоваровПоставщику.КоличествоМест)                КАК КоличествоМест,
	|		СУММА(ВозвратТоваровПоставщику.Сумма    * &Курс / &Кратность) КАК Сумма,
	|		СУММА(ВозвратТоваровПоставщику.СуммаНДС * &Курс / &Кратность) КАК СуммаНДС,
	|		МИНИМУМ(ВозвратТоваровПоставщику.НомерСтроки)                 КАК НомерСтроки,
	|		0                                                             КАК Метка
	|	ИЗ
	|		Документ.ВозвратТоваровПоставщику.Товары КАК ВозвратТоваровПоставщику
	|	ГДЕ
	|		ВозвратТоваровПоставщику.Ссылка = &ТекущийДокумент
	|
	|СГРУППИРОВАТЬ ПО
	|		ВозвратТоваровПоставщику.Номенклатура,
	|		ВозвратТоваровПоставщику.Коэффициент,
	|		ВозвратТоваровПоставщику.ЕдиницаИзмерения,
	|		ВозвратТоваровПоставщику.ЕдиницаИзмеренияМест,
	|		ВозвратТоваровПоставщику.ХарактеристикаНоменклатуры,
	|		ВозвратТоваровПоставщику.СерияНоменклатуры,
	|		ВозвратТоваровПоставщику.СтавкаНДС,
	|		ВозвратТоваровПоставщику.Цена
	|
	|	) КАК ВложенныйЗапрос
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВозвратТоваровПоставщику.Номенклатура                    КАК Номенклатура,
	|	ВЫРАЗИТЬ(ВозвратТоваровПоставщику.Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК ТоварНаименование,
	|	ВозвратТоваровПоставщику.Номенклатура." + ТоварКод + "   КАК ТоварКод,
	|	ВозвратТоваровПоставщику.Номенклатура.ЕдиницаХраненияОстатков.Представление               КАК БазоваяЕдиницаНаименование,
	|	ВозвратТоваровПоставщику.Номенклатура.ЕдиницаХраненияОстатков.ЕдиницаПоКлассификатору.Код КАК БазоваяЕдиницаКодПоОКЕИ,
	|	ВозвратТоваровПоставщику.Номенклатура.ЕдиницаХраненияОстатков                             КАК ЕдиницаИзмерения,
	|	NULL                                                  КАК ВидУпаковки,
	|	NULL                                                  КАК КоличествоВОдномМесте,
	|	ВозвратТоваровПоставщику.Количество * ВозвратТоваровПоставщику.Номенклатура.ЕдиницаХраненияОстатков.Вес КАК МассаБрутто,
	|	NULL                                                  КАК Характеристика,
	|	NULL                                                  КАК Серия,
	|	""Без НДС""                                           КАК СтавкаНДС,
	|	ВозвратТоваровПоставщику.Цена * &Курс / &Кратность    КАК Цена,
	|	ВозвратТоваровПоставщику.Количество                   КАК Количество,
	|	NULL                                                  КАК КоличествоМест,
	|	ВозвратТоваровПоставщику.Сумма * &Курс / &Кратность   КАК Сумма,
	|	0                                                     КАК СуммаНДС,
	|	ВозвратТоваровПоставщику.НомерСтроки                  КАК НомерСтроки,
	|	2                                                     КАК Метка
	|ИЗ
	|	Документ.ВозвратТоваровПоставщику.ВозвратнаяТара КАК ВозвратТоваровПоставщику
	|
	|ГДЕ
	|	ВозвратТоваровПоставщику.Ссылка = &ТекущийДокумент
	|
	|УПОРЯДОЧИТЬ ПО Метка ВОЗР, НомерСтроки ВОЗР
	|
	|";

	ЗапросТовары = Запрос.Выполнить().Выгрузить();

	ТабДокумент = Новый ТабличныйДокумент;
	
	// Зададим параметры макета
	ТабДокумент.ПолеСверху              = 0;
	ТабДокумент.ПолеСлева               = 5;
	ТабДокумент.ПолеСнизу               = 0;
	ТабДокумент.ПолеСправа              = 5;
	ТабДокумент.АвтоМасштаб             = Истина;
	ТабДокумент.ОриентацияСтраницы      = ОриентацияСтраницы.Ландшафт;
	
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ВозвратТоваровПоставщику_ТОРГ12";

	Макет=ИнициализацияМакета(СтруктураПараметров, "ТОРГ12");

	// Выводим общие реквизиты шапки
	СведенияОПоставщике       = КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.Организация,      Шапка.ДатаДокумента,, Шапка.БанковскийСчет);
	СведенияОПокупателе       = КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.Контрагент,       Шапка.ДатаДокумента);
	СведенияОГрузополучателе  = КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.Грузополучатель,  Шапка.ДатаДокумента);
	СведенияОГрузоотправитель = КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.Грузоотправитель, Шапка.ДатаДокумента);

	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	стрОснования="";
	Для Каждого СтрокаДок ИЗ СсылкаНаОбъект.Товары Цикл
		Если НЕ ЗначениеЗаполнено(СтрокаДок.ДокументПоступления) Тогда Продолжить; КонецЕсли;
		стрОснования=?(стрОснования="","возврат по документу № "+СокрЛП(СтрокаДок.ДокументПоступления.Номер)+" от "+Формат(СтрокаДок.ДокументПоступления.Дата,"ДЛФ=D"),", № "+СокрЛП(СтрокаДок.ДокументПоступления.Номер)+" от "+Формат(СтрокаДок.ДокументПоступления.Дата,"ДЛФ=D"));
	КонецЦикла;	
	
	Если ЗначениеЗаполнено(Шапка.Сделка) И стрОснования="" Тогда
		ОбластьМакета.Параметры.Основание = ОбщегоНазначения.СформироватьЗаголовокДокумента(Шапка.Сделка, Строка(Шапка.Сделка.Метаданные().Синоним));
	Иначе
		ОбластьМакета.Параметры.Основание = стрОснования;
	КонецЕсли;

	ОбластьМакета.Параметры.НомерДокумента = ОбщегоНазначенияСервер.НомерНаПечать(СсылкаНаОбъект);
	ОбластьМакета.Параметры.ДатаДокумента  = Формат(Шапка.ДатаДокумента, "ДФ=""дд ММММ гггг""");

	Если Шапка.Организация = Шапка.Грузоотправитель Тогда
		ОбластьМакета.Параметры.ПредставлениеОрганизации = ПечатныеФормыСервер.ОписаниеОрганизации(СведенияОПоставщике);
	Иначе
		ОбластьМакета.Параметры.ПредставлениеОрганизации = ПечатныеФормыСервер.ОписаниеОрганизации(СведенияОГрузоотправитель, "ПолноеНаименование,ИНН,ФактическийАдрес,Телефоны,НомерСчета,Банк,БИК,КоррСчет");
	КонецЕсли;

	ОбластьМакета.Параметры.Подразделение                = Шапка.Подразделение;
	ОбластьМакета.Параметры.ПредставлениеГрузополучателя = ПечатныеФормыСервер.ОписаниеОрганизации(СведенияОГрузополучателе,"ПолноеНаименование,ИНН,ФактическийАдрес,Телефоны,НомерСчета,Банк,БИК,КоррСчет");
	ОбластьМакета.Параметры.АдресДоставки                = ПечатныеФормыСервер.ОписаниеОрганизации(СведенияОГрузополучателе, "ФактическийАдрес");
	ОбластьМакета.Параметры.ПредставлениеПоставщика      = ПечатныеФормыСервер.ОписаниеОрганизации(СведенияОПоставщике);
	ОбластьМакета.Параметры.ПредставлениеПлательщика     = ПечатныеФормыСервер.ОписаниеОрганизации(СведенияОПокупателе);

	// Выводим всевозможные коды
	ОбластьМакета.Параметры.ОрганизацияПоОКПО     = СведенияОПоставщике.КодПоОКПО;
	ОбластьМакета.Параметры.ВидДеятельностиПоОКДП = "";
	ОбластьМакета.Параметры.ГрузополучательПоОКПО = СведенияОГрузополучателе.КодПоОКПО;
	ОбластьМакета.Параметры.ПоставщикПоОКПО  = СведенияОПоставщике.КодПоОКПО;
	ОбластьМакета.Параметры.ПлательщикПоОКПО = СведенияОПокупателе.КодПоОКПО;
	ОбластьМакета.Параметры.ОснованиеНомер   = "";
	ОбластьМакета.Параметры.ОснованиеДата    = "";
	ОбластьМакета.Параметры.ТранспортнаяНакладнаяНомер = "";
	ОбластьМакета.Параметры.ТранспортнаяНакладнаяДата  = "";

	ТабДокумент.Вывести(ОбластьМакета);

	НомерСтраницы   = 1;

	КоличествоСтрок = ЗапросТовары.Количество();

	// инициализация итогов по странице
	ИтогоМассаБруттоНаСтранице = 0;
	ИтогоМестНаСтранице        = 0;
	ИтогоКоличествоНаСтранице  = 0;
	ИтогоСуммаНаСтранице       = 0;
	ИтогоНДСНаСтранице         = 0;
	ИтогоСуммаСНДСНаСтранице   = 0;

	// инициализация итогов по документу
	ИтогоМассаБрутто = 0;
	ИтогоМест        = 0;
	ИтогоКоличество  = 0;
	ИтогоСуммаСНДС   = 0;
	ИтогоСумма       = 0;
	ИтогоНДС         = 0;
	Ном              = 0;

	// Создаем массив для проверки вывода
	МассивВыводимыхОбластей = Новый Массив;
	
	// Выводим многострочную часть докмента
	ОбластьЗаголовокТаблицы = Макет.ПолучитьОбласть("ЗаголовокТаб");
	ОбластьМакета           = Макет.ПолучитьОбласть("Строка");
	ОбластьИтоговПоСтранице = Макет.ПолучитьОбласть("ИтогоПоСтранице");
	ОбластьПодвала          = Макет.ПолучитьОбласть("Подвал");
	Для Каждого ВыборкаСтрок Из ЗапросТовары Цикл

		Если НЕ ЗначениеЗаполнено(ВыборкаСтрок.Номенклатура) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;
		
		Ном = Ном + 1;

		ОбластьМакета.Параметры.Заполнить(ВыборкаСтрок);
		ОбластьМакета.Параметры.НомерСтроки             = ЗапросТовары.Индекс(ВыборкаСтрок) + 1;
		ОбластьМакета.Параметры.НоменклатураНаименование = СокрЛП(ВыборкаСтрок.ТоварНаименование)
		                                          + ПечатныеФормыСервер.ПредставлениеСерий(ВыборкаСтрок)
		                                          + ?(ВыборкаСтрок.Метка = 2, " (возвратная тара)", "");

		СуммаСНДС = Окр((ВыборкаСтрок.Сумма + ?(Шапка.СуммаВключаетНДС, 0, ВыборкаСтрок.СуммаНДС)), 2);

		Если НЕ ЗначениеЗаполнено(ЕдиницаИзмеренияВеса) Тогда
			МассаБрутто = 0;
		Иначе
			МассаБрутто = ВыборкаСтрок.МассаБрутто;
			МассаБрутто = ?(МассаБрутто <> Неопределено И МассаБрутто <> NULL, МассаБрутто, 0);
		КонецЕсли;

		Мест        = ВыборкаСтрок.КоличествоМест;
		Мест        = ?(Мест <> Неопределено И Мест <> NULL, Мест, 0);

		Количество  = ВыборкаСтрок.Количество;
		СуммаНДС    = Окр(ВыборкаСтрок.СуммаНДС, 2);
		СуммаБезНДС = СуммаСНДС - СуммаНДС;

		ОбластьМакета.Параметры.МассаБрутто = МассаБрутто;
		ОбластьМакета.Параметры.СтоимостьСНДС   = СуммаСНДС;
		ОбластьМакета.Параметры.СуммаНДС    = СуммаНДС;
		ОбластьМакета.Параметры.СтавкаНДС   = ВыборкаСтрок.СтавкаНДС;
		ОбластьМакета.Параметры.СтоимостьБезНДС = СуммаБезНДС;

		Если Шапка.СуммаВключаетНДС Тогда
			ОбластьМакета.Параметры.Цена = ?(Количество = 0, 0, СуммаБезНДС / Количество);
		Иначе
			ОбластьМакета.Параметры.Цена = ВыборкаСтрок.Цена;
		КонецЕсли;
		
		Если Ном = 1 Тогда // первая срока
			
			ОбластьЗаголовокТаблицы.Параметры.НомерСтраницы = "Страница " + НомерСтраницы; 
			ТабДокумент.Вывести(ОбластьЗаголовокТаблицы);
			
		Иначе
			
			МассивВыводимыхОбластей.Очистить();
			МассивВыводимыхОбластей.Добавить(ОбластьМакета);
			МассивВыводимыхОбластей.Добавить(ОбластьИтоговПоСтранице);
			Если Ном = КоличествоСтрок Тогда
				МассивВыводимыхОбластей.Добавить(ОбластьПодвала);
			КонецЕсли;		
			
			Если Ном <> 1 И НЕ ТабДокумент.ПроверитьВывод(МассивВыводимыхОбластей) Тогда
				
				ОбластьИтоговПоСтранице.Параметры.ИтогМассаБруттоПоСтранице = ИтогоМассаБруттоНаСтранице;
				ОбластьИтоговПоСтранице.Параметры.ИтогМестПоСтранице        = ИтогоМестНаСтранице;
				ОбластьИтоговПоСтранице.Параметры.ИтогКоличествоПоСтранице  = ИтогоКоличествоНаСтранице;
				ОбластьИтоговПоСтранице.Параметры.ИтогСуммыПоСтранице       = ИтогоСуммаНаСтранице;
				ОбластьИтоговПоСтранице.Параметры.ИтогНДСПоСтранице         = ИтогоНДСНаСтранице;
				ОбластьИтоговПоСтранице.Параметры.ИтогСуммыСНДСПоСтранице   = ИтогоСуммаСНДСНаСтранице;
				
				ТабДокумент.Вывести(ОбластьИтоговПоСтранице);
				
				// очистим итоги по странице
				ИтогоМассаБруттоНаСтранице = 0;
				ИтогоМестНаСтранице        = 0;
				ИтогоКоличествоНаСтранице  = 0;
				ИтогоСуммаНаСтранице       = 0;
				ИтогоНДСНаСтранице         = 0;
				ИтогоСуммаСНДСНаСтранице   = 0;
				
				НомерСтраницы = НомерСтраницы + 1;
				ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
				ОбластьЗаголовокТаблицы.Параметры.НомерСтраницы = "Страница " + НомерСтраницы;
				ТабДокумент.Вывести(ОбластьЗаголовокТаблицы);
				
			КонецЕсли;
			
		КонецЕсли;

		ТабДокумент.Вывести(ОбластьМакета);

		// увеличим итоги по странице
		ИтогоМассаБруттоНаСтранице = ИтогоМассаБруттоНаСтранице + МассаБрутто;
		ИтогоМестНаСтранице        = ИтогоМестНаСтранице        + Мест;
		ИтогоКоличествоНаСтранице  = ИтогоКоличествоНаСтранице  + Количество;
		ИтогоСуммаНаСтранице       = ИтогоСуммаНаСтранице       + СуммаБезНДС;
		ИтогоНДСНаСтранице         = ИтогоНДСНаСтранице         + СуммаНДС;
		ИтогоСуммаСНДСНаСтранице   = ИтогоСуммаСНДСНаСтранице   + СуммаСНДС;

		// увеличим итоги по дукументу
		ИтогоМассаБрутто = ИтогоМассаБрутто + МассаБрутто;
		ИтогоМест        = ИтогоМест        + Мест;
		ИтогоКоличество  = ИтогоКоличество  + Количество;
		ИтогоСумма       = ИтогоСумма       + СуммаБезНДС;
		ИтогоНДС         = ИтогоНДС         + СуммаНДС;
		ИтогоСуммаСНДС   = ИтогоСуммаСНДС   + СуммаСНДС;

	КонецЦикла;

	// Выводим итоги по последней странице
	ОбластьИтоговПоСтранице = Макет.ПолучитьОбласть("ИтогоПоСтранице");
	ОбластьИтоговПоСтранице.Параметры.ИтогМассаБруттоПоСтранице = ИтогоМассаБруттоНаСтранице;
	ОбластьИтоговПоСтранице.Параметры.ИтогМестПоСтранице        = ИтогоМестНаСтранице;
	ОбластьИтоговПоСтранице.Параметры.ИтогКоличествоПоСтранице  = ИтогоКоличествоНаСтранице;
	ОбластьИтоговПоСтранице.Параметры.ИтогСуммыПоСтранице       = ИтогоСуммаНаСтранице;
	ОбластьИтоговПоСтранице.Параметры.ИтогНДСПоСтранице         = ИтогоНДСНаСтранице;
	ОбластьИтоговПоСтранице.Параметры.ИтогСуммыСНДСПоСтранице   = ИтогоСуммаСНДСНаСтранице;

	ТабДокумент.Вывести(ОбластьИтоговПоСтранице);
	
	// Выводим итоги по документу в целом
	ОбластьМакета = Макет.ПолучитьОбласть("Всего");
	ОбластьМакета.Параметры.МассаБрутто = ИтогоМассаБрутто;
	ОбластьМакета.Параметры.КоличествоМест        = ИтогоМест;
	ОбластьМакета.Параметры.Количество  = ИтогоКоличество;
	ОбластьМакета.Параметры.СтоимостьБезНДС       = ИтогоСумма;
	ОбластьМакета.Параметры.СуммаНДС         = ИтогоНДС;
	ОбластьМакета.Параметры.СтоимостьСНДС   = ИтогоСуммаСНДС;

	ТабДокумент.Вывести(ОбластьМакета);

	// Выводим подвал документа
	ОбластьМакета = Макет.ПолучитьОбласть("Подвал");

	Руководители = ПечатныеФормыСервер.ОтветственныеЛицаОрганизации(Шапка.Руководители, Шапка.ДатаДокумента, СтруктураПараметров.СсылкаНаОбъект);
	Руководитель = Руководители.Руководитель;
	Бухгалтер    = Руководители.ГлавныйБухгалтер;
	ОбластьМакета.Параметры.ФИОРуководителя       = Руководитель;
	ОбластьМакета.Параметры.ФИОГлавБухгалтера     = Бухгалтер;
	ОбластьМакета.Параметры.ДолжностьРуководителя = Руководители.РуководительДолжность;
	ФамилияИмяОтчествоФизЛица                     = ПечатныеФормыСервер.ФамилияИмяОтчество(Шапка.ОтветственноеЛицо, Шапка.ДатаДокумента);
	Если ФамилияИмяОтчествоФизЛица.Фамилия<>Неопределено И ФамилияИмяОтчествоФизЛица.Имя<>Неопределено  И ФамилияИмяОтчествоФизЛица.Отчество<>Неопределено Тогда 
		ФамилияИмяОтчествоКладовщика                  = ФамилияИмяОтчествоФизЛица.Фамилия + " " + ФамилияИмяОтчествоФизЛица.Имя + " " + ФамилияИмяОтчествоФизЛица.Отчество;
		ОбластьМакета.Параметры.ФИОКладовщика         = ОбщегоНазначения.ФамилияИнициалыФизЛица(ФамилияИмяОтчествоКладовщика);
	КонецЕсли;
	ПолнаяДатаДокумента = Формат(Шапка.ДатаДокумента, "ДФ=""дд ММММ гггг """"года""""""");
	ДлинаСтроки = СтрДлина(ПолнаяДатаДокумента);
	ПервыйРазделитель = Найти(ПолнаяДатаДокумента," ");
	ВторойРазделитель = Найти(Прав(ПолнаяДатаДокумента,ДлинаСтроки-ПервыйРазделитель)," ")+ПервыйРазделитель;
	ОбластьМакета.Параметры.ДатаДокументаДень     = """"+Лев(ПолнаяДатаДокумента,ПервыйРазделитель-1)+"""";
	ОбластьМакета.Параметры.ДатаДокументаМесяц    = Сред(ПолнаяДатаДокумента,ПервыйРазделитель+1,ВторойРазделитель-ПервыйРазделитель-1);
	ОбластьМакета.Параметры.ДатаДокументаГод      = Прав(ПолнаяДатаДокумента,ДлинаСтроки-ВторойРазделитель);

	Если ЗначениеЗаполнено(ЕдиницаИзмеренияВеса) И ИтогоМассаБрутто > 0 Тогда
		ОбластьМакета.Параметры.МассаГрузаПрописью = ЧислоПрописью(ИтогоМассаБрутто, ,",,,,,,,,0")+ " " + СокрЛП(ЕдиницаИзмеренияВеса) + ".";
	КонецЕсли;

	Если ИтогоМест > 0 Тогда
		ОбластьМакета.Параметры.ВсегоМестПрописью = ЧислоПрописью(ИтогоМест, ,",,,,,,,,0");
	КонецЕсли;

	ОбластьМакета.Параметры.КоличествоПорядковыхНомеровЗаписейПрописью = ЧислоПрописью(КоличествоСтрок, ,",,,,,,,,0");
	ОбластьМакета.Параметры.СуммаПрописью = ОбщегоНазначения.СформироватьСуммуПрописью(ИтогоСуммаСНДС, МодульВалютногоУчета.ПолучитьВалюту("Бух"));
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;
КонецФункции

Функция Печать(СтруктураПараметров, КоличествоЭкземпляров=1, НаПринтер=Ложь, ТабДокумент=Неопределено) Экспорт
	Если СтруктураПараметров.ИмяМакета="Накладная"  Тогда
		ТабДокумент=Печать_ВозвратаПоставщику(СтруктураПараметров);

	ИначеЕсли СтруктураПараметров.ИмяМакета="ТОРГ12" тогда
		ТабДокумент=Печать_ТОРГ12(СтруктураПараметров);

	ИначеЕсли СтруктураПараметров.ИмяМакета="РасходСРозничныхСкладовВЦенахАТТ" Тогда
		ТабДокумент=ПечатныеФормыСервер.ПриходРасходСРозничныхСкладовВЦенахАТТ(СтруктураПараметров.СсылкаНаОбъект, МодульВалютногоУчета.ПолучитьВалюту("Бух"), Ложь);

	ИначеЕсли СтруктураПараметров.ИмяМакета="БухгалтерскаяСправка" Тогда
		ТабДокумент=ПечатныеФормыСервер.БухгалтерскаяСправка(СтруктураПараметров, "Хозрасчетный");		
	КонецЕсли;

	Возврат ТабДокумент;
КонецФункции
