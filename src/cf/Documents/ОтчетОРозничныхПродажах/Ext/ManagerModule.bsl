﻿////////////////////////////////////////////////////////////////////////////////
//Управление печатными формами

Процедура СтруктураПечатныхФорм(Структура) Экспорт
	Структура.Вставить("ОтчетККМ", "КМ-6 (Справка отчет кассира-операциониста)");
	Структура.Вставить("РасходСРозничныхСкладовВЦенахАТТ" , "Расход с розничных складов в ценах АТТ");
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

Функция Печать_ОтчетаОПродажахККМ(СтруктураПараметров)
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СтруктураПараметров.СсылкаНаОбъект);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ОплатаПлатежнымиКартами,
	|	ОплатаБанковскимиКредитами
	|ИЗ
	|	Документ.ОтчетОРозничныхПродажах КАК ОтчетОРозничныхПродажах
	|ГДЕ
	|	ОтчетОРозничныхПродажах.Ссылка = &ТекущийДокумент
	|";
	ДанныеДокумента=Запрос.Выполнить().Выбрать();
	ДанныеДокумента.Следующий();
	
	тзОплатаПлатежнымиКартами=ДанныеДокумента.ОплатаПлатежнымиКартами.Выгрузить();
	тзОплатаБанковскимиКредитами=ДанныеДокумента.ОплатаБанковскимиКредитами.Выгрузить();

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СтруктураПараметров.СсылкаНаОбъект);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Док.Ссылка.Номер КАК НомерДокумента,
	|	Док.Ссылка.Дата  КАК ДатаДокумента,
	|	Док.Ссылка.Организация КАК Организация,
	|	Док.Ссылка.КассаККМ КАК КассаККМ,
	|	Док.Ссылка.КассаККМ.Представление КАК ККМПредставление,
	|	СУММА(ВЫБОР КОГДА Док.Сумма > 0 ТОГДА
	|		Док.Сумма + ВЫБОР КОГДА Док.Ссылка.СуммаВключаетНДС ТОГДА 0 ИНАЧЕ Док.СуммаНДС КОНЕЦ
	|	ИНАЧЕ
	|		0
	|	КОНЕЦ) КАК Итого,
	|	СУММА(ВЫБОР КОГДА Док.Сумма > 0 ТОГДА
	|		0
	|	ИНАЧЕ
	|		-Док.Сумма - ВЫБОР КОГДА Док.Ссылка.СуммаВключаетНДС ТОГДА 0 ИНАЧЕ Док.СуммаНДС КОНЕЦ
	|	КОНЕЦ) КАК ИтогоВозврат
	|ИЗ
	|	Документ.ОтчетОРозничныхПродажах.Товары КАК Док
	|ГДЕ
	|	Док.Ссылка = &ТекущийДокумент
	|СГРУППИРОВАТЬ ПО
	|	Док.Ссылка.Номер,
	|	Док.Ссылка.Дата,
	|	Док.Ссылка.Организация,
	|	Док.Ссылка.КассаККМ,
	|	Док.Ссылка.КассаККМ.Представление
	|";
	Результат = Запрос.Выполнить();

	Шапка=Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ОтчетОРозничныхПродажах_ОтчетККМ";

	Макет = ИнициализацияМакета(СтруктураПараметров, "ОтчетККМ");

	СведенияОПокупателе = КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.Организация, Шапка.ДатаДокумента);

	ОбластьМакета=Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ОбластьМакета.Параметры.ОрганизацияПредставление = ПечатныеФормыСервер.ОписаниеОрганизации(СведенияОПокупателе);
	ОбластьМакета.Параметры.ДатаДокумента            = Шапка.ДатаДокумента;
	ОбластьМакета.Параметры.ОрганизацияПоОКПО        = СведенияОПокупателе.КодПоОКПО;
	ОбластьМакета.Параметры.ОрганизацияИНН           = СведенияОПокупателе.ИНН;
	ОбластьМакета.Параметры.ПрограммаУчета           = "1С:Предприятие 8";
	ОбластьМакета.Параметры.НомерДокумента           = ОбщегоНазначенияСервер.НомерНаПечать(СтруктураПараметров.СсылкаНаОбъект);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета=Макет.ПолучитьОбласть("Шапка");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета=Макет.ПолучитьОбласть("Строка");

	ТаблицаСтрок=Результат.Выгрузить();
	Для Каждого Строка Из ТаблицаСтрок Цикл
		ОбластьМакета.Параметры.Заполнить(Строка);
		ОбластьМакета.Параметры.Итого=Шапка.Итого - тзОплатаПлатежнымиКартами.Итог("Сумма") - тзОплатаБанковскимиКредитами.Итог("Сумма");
		ТабДокумент.Вывести(ОбластьМакета);
	КонецЦикла;

	ОбластьМакета = Макет.ПолучитьОбласть("Итог");

	СуммаИтого = ТаблицаСтрок.Итог("Итого") - тзОплатаПлатежнымиКартами.Итог("Сумма") - тзОплатаБанковскимиКредитами.Итог("Сумма");
	СуммаИтогоВозврат = ТаблицаСтрок.Итог("ИтогоВозврат");

	ОбластьМакета.Параметры.Итого = СуммаИтого;
	ОбластьМакета.Параметры.ИтогоВозврат = СуммаИтогоВозврат;

	ОбластьМакета.Параметры.СуммаВыручкиПрописью = ОбщегоНазначения.СформироватьСуммуПрописью(СуммаИтого - СуммаИтогоВозврат, МодульВалютногоУчета.ПолучитьВалюту("Бух"));
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Подвал");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Оборот");

	Руководители = ПечатныеФормыСервер.ОтветственныеЛицаОрганизации(Шапка.Организация, Шапка.ДатаДокумента, СтруктураПараметров.СсылкаНаОбъект);
	Руководитель = Руководители.Руководитель;
	Бухгалтер    = Руководители.ГлавныйБухгалтер;
	ОбластьМакета.Параметры.ФИОРуководителя = Руководитель;
  
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;
КонецФункции

Функция Печать(СтруктураПараметров, КоличествоЭкземпляров=1, НаПринтер=Ложь, ТабДокумент=Неопределено) Экспорт
	Если СтруктураПараметров.ИмяМакета="ОтчетККМ" Тогда
		ТабДокумент=Печать_ОтчетаОПродажахККМ(СтруктураПараметров);

	ИначеЕсли СтруктураПараметров.ИмяМакета="РасходСРозничныхСкладовВЦенахАТТ" Тогда
		ТабДокумент=ПечатныеФормыСервер.ПриходРасходСРозничныхСкладовВЦенахАТТ(СтруктураПараметров.СсылкаНаОбъект, МодульВалютногоУчета.ПолучитьВалюту("Бух"), Ложь);
	КонецЕсли;

	Возврат ТабДокумент;
КонецФункции

