﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	Для Каждого СтрокаКоллекции Из Товары Цикл
		Если ЗначениеЗаполнено(СтрокаКоллекции.ЕдиницаИзмеренияМест) И СтрокаКоллекции.КоличествоМест=0 Тогда
			СтрокаКоллекции.ЕдиницаИзмеренияМест=Неопределено;
		КонецЕсли;		
	КонецЦикла;
	СуммаДокумента=Товары.Итог("Сумма");
КонецПроцедуры

Функция ПараметрыУчетнойПолитики(Переписать=Ложь) Экспорт

	Если Переписать=Ложь Тогда
		Переписать=?(ДополнительныеСвойства.УчетнаяПолитика=Неопределено, Истина, Ложь);
	КонецЕсли;

	Если Переписать Тогда
		ДополнительныеСвойства.УчетнаяПолитика=ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(ЭтоНовый(), ТекущаяДата(), Дата), Ложь, Организация);
	КонецЕсли;

	Возврат ДополнительныеСвойства.УчетнаяПолитика;

КонецФункции

// Процедура выполняет заполнение табличной части. Если передан документ основание то
//  заполнение производится по документу основанию, иначе по всем.
//
// Параметры:
//  ДокументОснование - ссылка на документ основание.
//
Процедура ЗаполнитьТовары(ДокументОснование = Неопределено) Экспорт
	КурсДокумента      = ЗаполнениеДокументов.КурсДокумента(ЭтотОбъект, ДополнительныеСвойства.ВалютаБухУчета);
	КратностьДокумента = ЗаполнениеДокументов.КратностьДокумента(ЭтотОбъект, ДополнительныеСвойства.ВалютаБухУчета);

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДоговорКонтрагента", ДоговорКонтрагента);
	Запрос.УстановитьПараметр("Сделка", ?(ЗначениеЗаполнено(Сделка), Сделка, Неопределено));
	Запрос.УстановитьПараметр("ДокументПередачи",      ДокументОснование);
	Запрос.УстановитьПараметр("СтатусПередачи",        Перечисления.СтатусыПолученияПередачиТоваров.НаКомиссию);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Остатки.ДоговорКонтрагента,
	|	Остатки.ДоговорКонтрагента.ВалютаВзаиморасчетов КАК ВалютаВзаиморасчетов,
	|	Остатки.Номенклатура,
	|	Остатки.ХарактеристикаНоменклатуры,
	|	Остатки.СерияНоменклатуры,
	|	СУММА(Остатки.КоличествоОстаток)                КАК КоличествоОстаток,
	|	СУММА(Остатки.СуммаВзаиморасчетовОстаток)       КАК СтоимостьОстаток
	|ИЗ
	|	РегистрНакопления.ТоварыПереданные.Остатки(,
	|                                                 ДоговорКонтрагента = &ДоговорКонтрагента
	|												И Сделка             = &Сделка
	|												И СтатусПередачи     = &СтатусПередачи
	|" + ?(НЕ ЗначениеЗаполнено(ДокументОснование), "", "И Номенклатура в (ВЫБРАТЬ РАЗЛИЧНЫЕ Номенклатура 
	|                                                      ИЗ Документ.РеализацияТоваровУслуг.Товары ГДЕ Документ.РеализацияТоваровУслуг.Товары.Ссылка = &ДокументПередачи)") + "
	|	                                                     ) КАК Остатки
	|ГДЕ
	| 	Остатки.КоличествоОстаток > 0
	|
	|СГРУППИРОВАТЬ ПО
	|	Остатки.ДоговорКонтрагента,
	|	Остатки.Номенклатура,
	|	Остатки.ХарактеристикаНоменклатуры,
	|	Остатки.СерияНоменклатуры
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		СтрокаТабличнойЧасти=Товары.Добавить();
		СтрокаТабличнойЧасти.Номенклатура               = Выборка.Номенклатура;
		СтрокаТабличнойЧасти.ЕдиницаИзмерения           = СтрокаТабличнойЧасти.Номенклатура.ЕдиницаХраненияОстатков;
		СтрокаТабличнойЧасти.Коэффициент                = СтрокаТабличнойЧасти.ЕдиницаИзмерения.Коэффициент;
		СтрокаТабличнойЧасти.Количество                 = Выборка.КоличествоОстаток;
		СтрокаТабличнойЧасти.Сумма                      = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(Выборка.СтоимостьОстаток,
		                                                     Выборка.ВалютаВзаиморасчетов,
		                                                     ВалютаДокумента,
		                                                     КурсВзаиморасчетов,
		                                                     КурсДокумента,
		                                                     КратностьВзаиморасчетов,
		                                                     КратностьДокумента);
		СтрокаТабличнойЧасти.СуммаСтарая                = СтрокаТабличнойЧасти.Сумма;
		СтрокаТабличнойЧасти.Цена                       = СтрокаТабличнойЧасти.Сумма / СтрокаТабличнойЧасти.Количество;
		СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры = Выборка.ХарактеристикаНоменклатуры;
		СтрокаТабличнойЧасти.СерияНоменклатуры          = Выборка.СерияНоменклатуры;
	КонецЦикла;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_ТоварыПереданные(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_ТоварыПереданные(СтруктураШД, СтруктураТД, Отказ)
	тзДвижения=Движения.ТоварыПереданные.ВыгрузитьКолонки();
	Для каждого СтрокаКоллекции Из СтруктураТД.Товары Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.Количество=-НоваяСтрока.Количество;

		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);		
		НоваяСтрока.СуммаВзаиморасчетов=СтрокаКоллекции.Сумма;
	КонецЦикла; 

	тзДвижения.ЗаполнитьЗначения(Сделка, "Сделка");
	тзДвижения.ЗаполнитьЗначения(Перечисления.СтатусыПолученияПередачиТоваров.НаКомиссию, "СтатусПередачи");
	
	Движения.ТоварыПереданные.Загрузить(тзДвижения);
КонецПроцедуры	

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий модуля

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	УправлениеДокументамиСервер.ПередПроведением(Отказ, РежимПроведения, ЭтотОбъект);
	Если Отказ Тогда Возврат; КонецЕсли;
	
	СтруктураШД=ДополнительныеСвойства.СтруктураШД;
	СтруктураТД=ДополнительныеСвойства.СтруктураТД;

	Если ДополнительныеСвойства.Свойство("РегистрыДляПроведения") Тогда
		Для каждого СтрокаМассива Из ДополнительныеСвойства.РегистрыДляПроведения Цикл
			Выполнить("ДвижениеПоРегистру_"+СтрокаМассива+"(СтруктураШД, СтруктураТД, Отказ);");
		КонецЦикла;
		Возврат;
	КонецЕсли;
	
	ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ОбработкаЗаполнения(Основание)
	Если Не ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание) Тогда Возврат; КонецЕсли; 
	
	Если ТипЗнч(Основание)=Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
		Если НЕ ДоговорКонтрагента.ВидДоговора=Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером Тогда Возврат; КонецЕсли;
		Если Основание.Проведен Тогда
			Сделка=Основание.Сделка;
			ЗаполнитьТовары(Основание);
		КонецЕсли;

	ИначеЕсли ТипЗнч(Основание)=Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		Сделка=Основание;
		Если Основание.Проведен Тогда
			ЗаполнитьТовары();
		КонецЕсли;
	КонецЕсли;

	ОбработкаТабличныхЧастей.ЗаполнитьТиповыеОперации(ЭтотОбъект);
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Заголовок=ЗаполнениеДокументов.ПредставлениеДокументаПриПроведении(ЭтотОбъект);

	//Автозаполнение ревизитов шапки\табличных частей
	АвтоЗаполнениеРеквизитовДокумента();

	//Формирование значений реквизитов шапки документа
	СтруктураШД=УправлениеДокументамиСервер.ПолучитьСтруктуруРеквизитовШапки(ЭтотОбъект);
	
	ВзаиморасчетыСервер.ПроверитьСоответствиеОрганизацииДоговоруВзаиморасчетов(Организация, ДоговорКонтрагента, СтруктураШД.ДоговорОрганизация, Отказ, Заголовок);
	Если Отказ Тогда Возврат; КонецЕсли;

	//Формирование значений реквизитов табличных частей
	стрТекстЗапроса="Док.СуммаСтарая * (-1) Как СуммаВзаиморасчетов,";
	тзТовары=УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "Товары", стрТекстЗапроса);
	Если НЕ СтруктураШД.ВалютаВзаиморасчетов=ВалютаДокумента Тогда
		Для каждого СтрокаТаблицы Из тзТовары Цикл
			СтрокаТаблицы.Сумма=ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.Сумма, ВалютаДокумента, СтруктураШД.ВалютаВзаиморасчетов, СтруктураШД.КурсДокумента, КурсВзаиморасчетов, СтруктураШД.КратностьДокумента, КратностьВзаиморасчетов);
			СтрокаТаблицы.СуммаВзаиморасчетов=ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.СуммаВзаиморасчетов, ВалютаДокумента, СтруктураШД.ВалютаВзаиморасчетов, СтруктураШД.КурсДокумента, КурсВзаиморасчетов, СтруктураШД.КратностьДокумента, КратностьВзаиморасчетов);
		КонецЦикла;
	КонецЕсли;
	СтруктураТД=Новый Структура("Товары", тзТовары);

	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства, "Продажа");