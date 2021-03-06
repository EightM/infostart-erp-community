﻿Функция ПересчитатьБухВал(Сумма, Курс, Кратность=1) Экспорт
	Если Курс=0 Или Кратность=0 Тогда
		ОбщегоНазначения.СообщитьОбОшибке("При пересчете обнаружен нулевой курс.");
		Возврат 0;
	КонецЕсли;
	Возврат Окр(Сумма*Кратность/Курс, 2);
КонецФункции

Функция ПересчитатьВалБух(Сумма, Курс, Кратность=1, НаДату) Экспорт
	Если Курс=0 Или Кратность=0 Тогда
		ОбщегоНазначения.СообщитьОбОшибке("При пересчете обнаружен нулевой курс.");
		Возврат 0;
	КонецЕсли;
	СтруктураКурсов=МодульВалютногоУчета.КурсВалюты(МодульВалютногоУчета.ПолучитьВалюту("Бух"), ?(ЗначениеЗаполнено(НаДату), НаДату, ТекущаяДата()));
	Возврат Окр((Сумма*Курс/Кратность)/(СтруктураКурсов.Курс*СтруктураКурсов.Кратность), 2);
КонецФункции

// Эта функция пересчитывает сумму из валюты ВалютаНач по курсу ПоКурсуНач 
// в валюту ВалютаКон по курсу ПоКурсуКон
//
// Параметры:      
//	Сумма          - сумма, которую следует пересчитать;
//	ВалютаНач      - ссылка на элемент справочника Валют;
//                   определяет валюты из которой надо пересчитвать;
//	ВалютаКон      - ссылка на элемент справочника Валют;
//                   определяет валюты в которую надо пересчитвать;
// 	ПоКурсуНач     - курс из которого надо пересчитать;
// 	ПоКурсуКон     - курс в который надо пересчитать;
// 	ПоКратностьНач - кратность из которого надо пересчитать (по умолчанию = 1);
// 	ПоКратностьКон - кратность в который надо пересчитать  (по умолчанию = 1);
//
// Возвращаемое значение: 
//  Сумма, пересчитанная в другую валюту
//
Функция ПересчитатьИзВалютыВВалюту(Сумма, ВалютаНач, ВалютаКон, ПоКурсуНач, ПоКурсуКон, ПоКратностьНач=1, ПоКратностьКон=1) Экспорт

	Если (ВалютаНач = ВалютаКон) Тогда Возврат Сумма; КонецЕсли;

	Если (ПоКурсуНач = ПоКурсуКон) И (ПоКратностьНач = ПоКратностьКон) Тогда Возврат Сумма; КонецЕсли;

	Если ПоКурсуНач=0 Или ПоКурсуКон=0 Или ПоКратностьНач=0 Или ПоКратностьКон=0 Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Процедура ""ПересчитатьИзВалютыВВалюту()"": при пересчете обнаружен нулевой курс.");
		Возврат 0;
	КонецЕсли;

	Возврат Окр((Сумма * ПоКурсуНач * ПоКратностьКон) / (ПоКурсуКон * ПоКратностьНач), 2);

КонецФункции

Функция ПересчитатьИзВалюты(Сумма, ВалютаНач, СтруктураПараметров) Экспорт
	ВалютаКон=СтруктураПараметров.ВалютаУправленческогоУчета;
	ПоКурсуНач=СтруктураПараметров.КурсДокумента;
	ПоКурсуКон=СтруктураПараметров.КурсВалютыУправленческогоУчета;

	ПоКратностьНач=УправлениеКоллекциямиЗначенийСервер.СвойствоСтруктуры(СтруктураПараметров, "КратностьДокумента", 1);
	ПоКратностьКон=УправлениеКоллекциямиЗначенийСервер.СвойствоСтруктуры(СтруктураПараметров, "КратностьВалютыУправленческогоУчета", 1);

	Если (ВалютаНач = ВалютаКон) Тогда Возврат Сумма; КонецЕсли;

	Если (ПоКурсуНач = ПоКурсуКон) И (ПоКратностьНач = ПоКратностьКон) Тогда Возврат Сумма; КонецЕсли;

	Если ПоКурсуНач=0 Или ПоКурсуКон=0 Или ПоКратностьНач=0 Или ПоКратностьКон=0 Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Процедура ""ПересчитатьИзВалютыВВалюту()"": при пересчете обнаружен нулевой курс.");
		Возврат 0;
	КонецЕсли;

	Возврат Окр((Сумма * ПоКурсуНач * ПоКратностьКон) / (ПоКурсуКон * ПоКратностьНач), 2);
КонецФункции

// Возвращает курс валюты на дату
//
// Параметры:
//  Валюта     - Валюта (элемент справочника "Валюты")
//  ДатаКурса  - Дата, на которую следует получить курс
//
// Возвращаемое значение: 
//  Структура, содержащая:
//   Курс      - курс валюты
//   Кратность - кратность валюты
//
Функция ПолучитьКурсВалюты(Валюта, ДатаКурса) Экспорт

	Возврат РегистрыСведений.КурсыВалют.ПолучитьПоследнее(ДатаКурса, Новый Структура("Валюта", Валюта));

КонецФункции

// Проверяет наличие установленного курс и кратности валюты на 1 января 1980 года.
// В случае отсутствия устанавливает курс и кратность равными единице.
//
// Параметры:
//  Валюта - ссылка на элемент справочника Валют
//
Процедура ПроверитьКорректностьКурсаНа01_01_1980(Валюта) Экспорт

	ДатаКурса = Дата(1980, 1, 1);
	СтруктураКурса = ПолучитьКурсВалюты(Валюта, ДатаКурса);

	Если (СтруктураКурса.Курс = 0) Или (СтруктураКурса.Кратность = 0) Тогда
		// установим курс и кратность = 1 на 01.01.1980, чтобы не было ошибок при создании документов
		РегистрКурсыВалют=РегистрыСведений.КурсыВалют.СоздатьМенеджерЗаписи();
		РегистрКурсыВалют.Период    = ДатаКурса;
		РегистрКурсыВалют.Валюта    = Валюта;
		РегистрКурсыВалют.Курс      = 1;
		РегистрКурсыВалют.Кратность = 1;
		РегистрКурсыВалют.Записать();
	КонецЕсли;

КонецПроцедуры

Функция ПолучитьВалюту(стрВалюта="Бух") Экспорт
	ВалютаУчета=ПараметрыСеанса["Валюта"+стрВалюта+"Учета"];
	Если ВалютаУчета.Пустая() Тогда // если не нашли значит берем из базы
		стрИмя=?(стрВалюта="Бух", "ВалютаРегламентированногоУчета", "ВалютаУправленческогоУчета");
		ВалютаУчета=Константы[стрИмя].Получить();
	КонецЕсли;
	Возврат ВалютаУчета;
КонецФункции

Процедура ПересчитатьСуммыВалюты(СтруктураШД, СуммаДок, СуммаБух, СуммаВал) Экспорт
	//ВалютаРегламентированногоУчета=СтруктураШД.ВалютаРегламентированногоУчета;
	ВалютаРегламентированногоУчета=МодульВалютногоУчета.ПолучитьВалюту("Бух"); //2018

	Если СтруктураШД.ВалютаДокумента=ВалютаРегламентированногоУчета Тогда
		СуммаБух=СуммаДок;
		Если НЕ СтруктураШД.ВалютаВзаиморасчетов=ВалютаРегламентированногоУчета Тогда
			СуммаВал=ПересчитатьИзВалютыВВалюту(СуммаДок, ВалютаРегламентированногоУчета, СтруктураШД.ВалютаВзаиморасчетов, 1, СтруктураШД.КурсВзаиморасчетов, 1, СтруктураШД.КратностьВзаиморасчетов);
		КонецЕсли;
	Иначе
		СуммаВал=СуммаДок;
		СуммаБух=ПересчитатьИзВалютыВВалюту(СуммаДок, СтруктураШД.ВалютаВзаиморасчетов, ВалютаРегламентированногоУчета, СтруктураШД.КурсВзаиморасчетов, 1, СтруктураШД.КратностьВзаиморасчетов, 1);
	КонецЕсли;	
КонецПроцедуры

Функция КурсДокумента(ДокументОбъект, ВалютаРегламентированногоУчета) Экспорт
	Если НЕ ДокументОбъект.ВалютаДокумента=ВалютаРегламентированногоУчета Тогда
		МетаданныеДокумента=ДокументОбъект.Метаданные();
		Если УправлениеМетаданными.ЕстьРеквизит("КурсДокумента", МетаданныеДокумента) Тогда
			Возврат ДокументОбъект.КурсДокумента;
		КонецЕсли;
		Если УправлениеМетаданными.ЕстьРеквизит("КурсВзаиморасчетов", МетаданныеДокумента) Тогда
			Возврат ДокументОбъект.КурсВзаиморасчетов;
		КонецЕсли;
	КонецЕсли;
	Возврат 1;
КонецФункции

Функция КратностьДокумента(ДокументОбъект, ВалютаРегламентированногоУчета) Экспорт
	Если НЕ ДокументОбъект.ВалютаДокумента=ВалютаРегламентированногоУчета Тогда
		МетаданныеДокумента=ДокументОбъект.Метаданные();
		Если УправлениеМетаданными.ЕстьРеквизит("КратностьДокумента", МетаданныеДокумента) Тогда
			Возврат ДокументОбъект.КратностьДокумента;
		КонецЕсли;
		Если УправлениеМетаданными.ЕстьРеквизит("КратностьВзаиморасчетов", МетаданныеДокумента) Тогда
			Возврат ДокументОбъект.КратностьВзаиморасчетов;
		КонецЕсли;
	КонецЕсли;
	Возврат 1;
КонецФункции

// Возвращает курс валюты на дату
//
// Параметры:
//  Валюта     - Валюта (элемент справочника "Валюты")
//  ДатаКурса  - Дата, на которую следует получить курс
//
// Возвращаемое значение: 
//  Структура, содержащая:
//   Курс      - курс валюты
//   Кратность - кратность валюты
//
Функция КурсВалюты(Валюта, ДатаКурса) Экспорт
	Возврат РегистрыСведений.КурсыВалют.ПолучитьПоследнее(ДатаКурса, Новый Структура("Валюта", Валюта));
КонецФункции
