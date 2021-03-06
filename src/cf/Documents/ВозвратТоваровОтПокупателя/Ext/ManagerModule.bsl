﻿////////////////////////////////////////////////////////////////////////////////
//Управление печатными формами

Процедура СтруктураПечатныхФорм(Структура) Экспорт
	Структура.Вставить("Накладная", "Возврат от покупателя");
	Структура.Вставить("Бланк", "Бланк товарного наполнения");
	Структура.Вставить("ПриходНаРозничныеСкладыВЦенахАТТ", "Приход на розничные склады в ценах АТТ");
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

Функция ПолучитьРеквизитыШапки(СсылкаНаОбъект, стрРеквизиты="")
	Если НЕ ПустаяСтрока(стрРеквизиты) Тогда стрРеквизиты=","+стрРеквизиты; КонецЕсли; 
	Для каждого мдРеквизит Из СсылкаНаОбъект.Метаданные().Реквизиты Цикл
		стрРеквизиты=стрРеквизиты+","+Символы.ПС+мдРеквизит.Имя;
	КонецЦикла;	

	Запрос=Новый ПостроительЗапроса;
	Запрос.Параметры.Вставить("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Дата,
	|	Номер,
	|	Проведен
	|	"+стрРеквизиты+"
	|ИЗ
	|	Документ.ВозвратТоваровОтПокупателя КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Ссылка = &ТекущийДокумент
	|";
	
	#Если НаСервере Тогда
	Запрос.Выполнить();
	#КонецЕсли
	Реквизиты=Запрос.Результат.Выбрать();
	Реквизиты.Следующий();

	Возврат Реквизиты;
КонецФункции 	

Функция Печать_ВозвратаОтПокупателя(СтруктураПараметров)
	СсылкаНаОбъект=СтруктураПараметров.СсылкаНаОбъект;

	РеквизитыШапки=ПолучитьРеквизитыШапки(СсылкаНаОбъект);

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Номенклатура,
	|	ВЫРАЗИТЬ(Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК Товар,
	|	Номенклатура.Код     КАК Код,
	|	Номенклатура.Артикул КАК Артикул,
	|	Количество,
	|	ЕдиницаИзмерения.Представление КАК ЕдиницаИзмерения,
	|	Цена,
	|	Сумма,
	|	СуммаНДС,
	|	ПроцентСкидкиНаценки       КАК Скидка,
	|	ХарактеристикаНоменклатуры КАК Характеристика,
	|	СерияНоменклатуры          КАК Серия,
	|	НомерСтроки,
	|	0 КАК Метка
	|	
	|ИЗ
	|	Документ.ВозвратТоваровОтПокупателя.Товары КАК ВозвратТоваровОтПокупателя
	|
	|ГДЕ
	|	ВозвратТоваровОтПокупателя.Ссылка = &ТекущийДокумент
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	Номенклатура,
	|	ВЫРАЗИТЬ(Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК Товар,
	|	Номенклатура.Код               КАК Код,
	|	Номенклатура.Артикул           КАК Артикул,
	|	Количество,
	|	Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаЦены,
	|	Цена,
	|	Сумма,
	|	0,
	|	0,
	|	NULL,
	|	NULL,
	|	НомерСтроки,
	|	2 КАК Метка
	|ИЗ
	|	Документ.ВозвратТоваровОтПокупателя.ВозвратнаяТара КАК ВозвратТоваровОтПокупателя
	|
	|ГДЕ
	|	ВозвратТоваровОтПокупателя.Ссылка = &ТекущийДокумент
	|
	|УПОРЯДОЧИТЬ ПО Метка ВОЗР, НомерСтроки ВОЗР
	|";

	ЗапросТовары = Запрос.Выполнить();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ВозвратТоваровОтПокупателя_Накладная";

	Макет = ИнициализацияМакета(СтруктураПараметров, "Накладная");

	// Выводим шапку накладной
	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = ОбщегоНазначения.СформироватьЗаголовокДокумента(СсылкаНаОбъект, "Возврат от покупателя");
	ТабДокумент.Вывести(ОбластьМакета);

	ПредставлениеОрганизации = ПечатныеФормыСервер.ОписаниеОрганизации(КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(РеквизитыШапки.Организация, РеквизитыШапки.Дата), "ПолноеНаименование,");
	ПредставлениеКонтрагента = ПечатныеФормыСервер.ОписаниеОрганизации(КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(РеквизитыШапки.Контрагент, РеквизитыШапки.Дата), "ПолноеНаименование,");
	ПредставлениеГрузоотправителя = ПечатныеФормыСервер.ОписаниеОрганизации(КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(РеквизитыШапки.Грузополучатель, РеквизитыШапки.Дата), "ПолноеНаименование,");

	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
	ОбластьМакета.Параметры.ПредставлениеПоставщика = ПредставлениеКонтрагента;
	ОбластьМакета.Параметры.ПредставлениеГрузоотправителя= ПредставлениеГрузоотправителя;
	ОбластьМакета.Параметры.Поставщик = РеквизитыШапки.Контрагент;
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	ОбластьМакета.Параметры.ПредставлениеПолучателя = ПредставлениеОрганизации;
	ОбластьМакета.Параметры.Получатель = РеквизитыШапки.Организация;
	ТабДокумент.Вывести(ОбластьМакета);

	ЕстьСкидки = Ложь;
	ВыборкаСтрокТовары = ЗапросТовары.Выбрать();
	Пока ВыборкаСтрокТовары.Следующий() Цикл
		Если ВыборкаСтрокТовары.Скидка <> 0 Тогда
			ЕстьСкидки = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Колонка=Константы.ДополнительнаяКолонкаПечатныхФормДокументов.Получить();
	ВыводитьКоды=Не ПустаяСтрока(Колонка);
	
	ОбластьНомера = Макет.ПолучитьОбласть("ШапкаТаблицы|НомерСтроки");
	ОбластьКодов  = Макет.ПолучитьОбласть("ШапкаТаблицы|КолонкаКодов");
	ОбластьДанных = Макет.ПолучитьОбласть("ШапкаТаблицы|Данные");
	ОбластьСкидок = Макет.ПолучитьОбласть("ШапкаТаблицы|Скидка");
	ОбластьСуммы  = Макет.ПолучитьОбласть("ШапкаТаблицы|Сумма");

	ТабДокумент.Вывести(ОбластьНомера);
	Если ВыводитьКоды Тогда
		ОбластьКодов.Параметры.ИмяКолонкиКодов = Колонка;
		ТабДокумент.Присоединить(ОбластьКодов);
	КонецЕсли;
	ТабДокумент.Присоединить(ОбластьДанных);
	Если ЕстьСкидки Тогда
		ТабДокумент.Присоединить(ОбластьСкидок);
	КонецЕсли;
	ТабДокумент.Присоединить(ОбластьСуммы);

	ОбластьКолонкаТовар = Макет.Область("Товар");
	Если Не ВыводитьКоды Тогда
		ОбластьКолонкаТовар.ШиринаКолонки = ОбластьКолонкаТовар.ШиринаКолонки+Макет.Область("КолонкаКодов").ШиринаКолонки;
	КонецЕсли;
	Если НЕ ЕстьСкидки Тогда
		ОбластьКолонкаТовар.ШиринаКолонки = ОбластьКолонкаТовар.ШиринаКолонки + 
		                                    Макет.Область("СуммаБезСкидки").ШиринаКолонки +
		                                    Макет.Область("СуммаСкидки").ШиринаКолонки;
	КонецЕсли;

	ОбластьНомера = Макет.ПолучитьОбласть("Строка|НомерСтроки");
	ОбластьКодов  = Макет.ПолучитьОбласть("Строка|КолонкаКодов");
	ОбластьДанных = Макет.ПолучитьОбласть("Строка|Данные");
	ОбластьСкидок = Макет.ПолучитьОбласть("Строка|Скидка");
	ОбластьСуммы  = Макет.ПолучитьОбласть("Строка|Сумма");

	НомПП    = 0;
	Сумма    = 0;
	СуммаНДС = 0;
	СуммаНП  = 0;
	ВсегоСкидок    = 0;
	ВсегоБезСкидок = 0;

	ВыборкаСтрокТовары = ЗапросТовары.Выбрать();
	Пока ВыборкаСтрокТовары.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(ВыборкаСтрокТовары.Номенклатура) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;

		НомПП =НомПП+1;
		ОбластьНомера.Параметры.НомерСтроки = НомПП;
		ТабДокумент.Вывести(ОбластьНомера);

		Если ВыводитьКоды Тогда
			Если Колонка = "Артикул" Тогда
				ОбластьКодов.Параметры.Артикул = ВыборкаСтрокТовары.Артикул;
			Иначе
				ОбластьКодов.Параметры.Артикул = ВыборкаСтрокТовары.Код;
			КонецЕсли;
			ТабДокумент.Присоединить(ОбластьКодов);
		КонецЕсли;

		ОбластьДанных.Параметры.Заполнить(ВыборкаСтрокТовары);
		ОбластьДанных.Параметры.Товар = СокрЛП(ВыборкаСтрокТовары.Товар) + 
		                                ПечатныеФормыСервер.ПредставлениеСерий(ВыборкаСтрокТовары) + 
		                                ?(ВыборкаСтрокТовары.Метка = 2, " (возвратная тара)", "");
		ТабДокумент.Присоединить(ОбластьДанных);

		Скидка = ВыборкаСтрокТовары.Сумма  / (100 - ВыборкаСтрокТовары.Скидка) * ВыборкаСтрокТовары.Скидка;
		Если ЕстьСкидки Тогда
			ОбластьСкидок.Параметры.Скидка         = Скидка;
			ОбластьСкидок.Параметры.СуммаБезСкидки = ВыборкаСтрокТовары.Сумма + Скидка;
			ТабДокумент.Присоединить(ОбластьСкидок);
		КонецЕсли;

		ОбластьСуммы.Параметры.Заполнить(ВыборкаСтрокТовары);
		ТабДокумент.Присоединить(ОбластьСуммы);
		Сумма          = Сумма       + ВыборкаСтрокТовары.Сумма;
		СуммаНДС       = СуммаНДС    + ВыборкаСтрокТовары.СуммаНДС;
		ВсегоСкидок    = ВсегоСкидок + Скидка;
		ВсегоБезСкидок = Сумма       + ВсегоСкидок;
	КонецЦикла;

	// Вывести Итого
	ОбластьНомера = Макет.ПолучитьОбласть("Итого|НомерСтроки");
	ОбластьКодов  = Макет.ПолучитьОбласть("Итого|КолонкаКодов");
	ОбластьДанных = Макет.ПолучитьОбласть("Итого|Данные");
	ОбластьСкидок = Макет.ПолучитьОбласть("Итого|Скидка");
	ОбластьСуммы  = Макет.ПолучитьОбласть("Итого|Сумма");

	ТабДокумент.Вывести(ОбластьНомера);
	Если ВыводитьКоды Тогда
		ТабДокумент.Присоединить(ОбластьКодов);
	КонецЕсли;
	ТабДокумент.Присоединить(ОбластьДанных);
	Если ЕстьСкидки Тогда
		ОбластьСкидок.Параметры.ВсегоСкидок    = ВсегоСкидок;
		ОбластьСкидок.Параметры.ВсегоБезСкидок = ВсегоБезСкидок;
		ТабДокумент.Присоединить(ОбластьСкидок);
	КонецЕсли;
	ОбластьСуммы.Параметры.Всего = ОбщегоНазначения.ФорматСумм(Сумма);
	ТабДокумент.Присоединить(ОбластьСуммы);

	// Вывести ИтогоНДС
	Если РеквизитыШапки.УчитыватьНДС Тогда
		ОбластьНомера = Макет.ПолучитьОбласть("ИтогоНДС|НомерСтроки");
		ОбластьКодов  = Макет.ПолучитьОбласть("ИтогоНДС|КолонкаКодов");
		ОбластьДанных = Макет.ПолучитьОбласть("ИтогоНДС|Данные");
		ОбластьСкидок = Макет.ПолучитьОбласть("ИтогоНДС|Скидка");
		ОбластьСуммы  = Макет.ПолучитьОбласть("ИтогоНДС|Сумма");

		ТабДокумент.Вывести(ОбластьНомера);
		Если ВыводитьКоды Тогда
			ТабДокумент.Присоединить(ОбластьКодов);
		КонецЕсли;
		ОбластьДанных.Параметры.НДС = ?(РеквизитыШапки.СуммаВключаетНДС, "В том числе НДС:", "Сумма НДС:");
		ТабДокумент.Присоединить(ОбластьДанных);
		Если ЕстьСкидки Тогда
			ТабДокумент.Присоединить(ОбластьСкидок);
		КонецЕсли;
		ОбластьСуммы.Параметры.ВсегоНДС = ОбщегоНазначения.ФорматСумм(СсылкаНаОбъект.Товары.Итог("СуммаНДС"));
		ТабДокумент.Присоединить(ОбластьСуммы);
	КонецЕсли;

	// Вывести Сумму прописью
	СуммаКПрописи=Сумма + ?(РеквизитыШапки.СуммаВключаетНДС, 0, СуммаНДС);
	ОбластьМакета=Макет.ПолучитьОбласть("СуммаПрописью");
	ОбластьМакета.Параметры.ИтоговаяСтрока="Всего наименований "+НомПП+", на сумму "+ОбщегоНазначения.ФорматСумм(СуммаКПрописи, РеквизитыШапки.ВалютаДокумента);
	ОбластьМакета.Параметры.СуммаПрописью=ОбщегоНазначения.СформироватьСуммуПрописью(СуммаКПрописи, РеквизитыШапки.ВалютаДокумента);
	ТабДокумент.Вывести(ОбластьМакета);

	// Вывести подписи
	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(РеквизитыШапки);
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;
КонецФункции

Функция Печать(СтруктураПараметров, КоличествоЭкземпляров=1, НаПринтер=Ложь, ТабДокумент=Неопределено) Экспорт
	Если СтруктураПараметров.ИмяМакета="Накладная" Тогда
		ТабДокумент=Печать_ВозвратаОтПокупателя(СтруктураПараметров);

	ИначеЕсли СтруктураПараметров.ИмяМакета="Бланк" Тогда
		ТабДокумент="БланкТоварногоНаполнения";

	ИначеЕсли СтруктураПараметров.ИмяМакета="ПриходНаРозничныеСкладыВЦенахАТТ" Тогда
		ТабДокумент=ПечатныеФормыСервер.ПриходРасходСРозничныхСкладовВЦенахАТТ(СтруктураПараметров.СсылкаНаОбъект, МодульВалютногоУчета.ПолучитьВалюту("Бух"), Истина);

	ИначеЕсли СтруктураПараметров.ИмяМакета="БухгалтерскаяСправка" Тогда
		ТабДокумент=ПечатныеФормыСервер.БухгалтерскаяСправка(СтруктураПараметров, "Хозрасчетный");		
	КонецЕсли;

	Возврат ТабДокумент;
КонецФункции
