﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	
КонецПроцедуры

Функция ПараметрыУчетнойПолитики(Переписать=Ложь) Экспорт

	Если Переписать=Ложь Тогда
		Переписать=?(ДополнительныеСвойства.УчетнаяПолитика=Неопределено, Истина, Ложь);
	КонецЕсли;

	Если Переписать Тогда
		ДополнительныеСвойства.УчетнаяПолитика=ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(ЭтоНовый(), ТекущаяДата(), Дата), Ложь);
	КонецЕсли;

	Возврат ДополнительныеСвойства.УчетнаяПолитика;

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ЗаказыПоставщикам(СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_ЗаказыПокупателей(СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_ВнутренниеЗаказы (СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_УчетПотребностей (СтруктураШД, СтруктураТД, Отказ);
	ДвижениеПоРегистру_УчетРезервовТМЦ	(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_ВнутренниеЗаказы(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ ТипЗаказа=Перечисления.ТипыЗаказов.ВнутреннийЗаказ Тогда Возврат; КонецЕсли;
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументСсылка",  Ссылка);
	Запрос.УстановитьПараметр("МоментДокумента", МоментВремени());
	Запрос.УстановитьПараметр("СписокЗаказов",   Заказы.ВыгрузитьКолонку("Заказ"));
	Запрос.УстановитьПараметр("Период",  Дата);
	Запрос.УстановитьПараметр("Активность",  Истина);
	Запрос.УстановитьПараметр("ВидДвижения",  ВидДвиженияНакопления.Расход);
	Запрос.Текст="
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	&Активность,
	|	&ДокументСсылка Как Регистратор,
	|	&ВидДвижения,
	|	&Период,
	|	ИсточникДанных.Склад,
	|	ИсточникДанных.Подразделение,
	|	ИсточникДанных.ВнутреннийЗаказ,
	|	ИсточникДанных.Организация,
	|	ИсточникДанных.Номенклатура,
	|	ИсточникДанных.ХарактеристикаНоменклатуры,
	|	ИсточникДанных.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.ВнутренниеЗаказы.Остатки(&МоментДокумента, ВнутреннийЗаказ В (&СписокЗаказов)) КАК ИсточникДанных
	|";
	тзЗаказы=Запрос.Выполнить().Выгрузить();

	Если НЕ тзЗаказы.Количество()=0 Тогда
		Движения.ВнутренниеЗаказы.Загрузить(тзЗаказы);
	КонецЕсли;	
КонецПроцедуры

Процедура ДвижениеПоРегистру_ЗаказыПоставщикам(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ ТипЗаказа=Перечисления.ТипыЗаказов.ЗаказПоставщику Тогда Возврат; КонецЕсли;

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументСсылка",  Ссылка);
	Запрос.УстановитьПараметр("МоментДокумента", МоментВремени());
	Запрос.УстановитьПараметр("СписокЗаказов",   Заказы.ВыгрузитьКолонку("Заказ"));
	Запрос.УстановитьПараметр("Период",  Дата);
	Запрос.УстановитьПараметр("Активность",  Истина);
	Запрос.УстановитьПараметр("ВидДвижения",  ВидДвиженияНакопления.Расход);
	Запрос.Текст="
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	&Активность,
	|	&ДокументСсылка Как Регистратор,
	|	&ВидДвижения,
	|	&Период,
	|	ИсточникДанных.Организация,
	|	ИсточникДанных.ДоговорКонтрагента,
	|	ИсточникДанных.ЗаказПоставщику,
	|	ИсточникДанных.ЗаказОснование,
	|	ИсточникДанных.Номенклатура,
	|	ИсточникДанных.ХарактеристикаНоменклатуры,
	|	ИсточникДанных.КоличествоОстаток КАК Количество,
	|	ИсточникДанных.СуммаОстаток КАК Сумма
	|ИЗ
	|	РегистрНакопления.ЗаказыПоставщикам.Остатки(&МоментДокумента, ЗаказПоставщику В (&СписокЗаказов)) КАК ИсточникДанных
	|";
	тзЗаказы=Запрос.Выполнить().Выгрузить();

	Если НЕ тзЗаказы.Количество()=0 Тогда
		Движения.ЗаказыПоставщикам.Загрузить(тзЗаказы);
	КонецЕсли;
КонецПроцедуры

Процедура ДвижениеПоРегистру_ЗаказыПокупателей(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ ТипЗаказа=Перечисления.ТипыЗаказов.ЗаказПокупателя Тогда Возврат; КонецЕсли;
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументСсылка",  Ссылка);
	Запрос.УстановитьПараметр("МоментДокумента", МоментВремени());
	Запрос.УстановитьПараметр("СписокЗаказов",   Заказы.ВыгрузитьКолонку("Заказ"));
	Запрос.УстановитьПараметр("Период",  Дата);
	Запрос.УстановитьПараметр("Активность",  Истина);
	Запрос.УстановитьПараметр("ВидДвижения",  ВидДвиженияНакопления.Расход);
	Запрос.Текст="
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	&Активность,
	|	&ДокументСсылка Как Регистратор,
	|	&ВидДвижения,
	|	&Период,
	|	ИсточникДанных.Организация,
	|	ИсточникДанных.ДоговорКонтрагента,
	|	ИсточникДанных.ЗаказПокупателя,
	|	ИсточникДанных.ЗаказПокупателя.Организация КАК Организация,
	|	ИсточникДанных.Номенклатура,
	|	ИсточникДанных.ХарактеристикаНоменклатуры,
	|	ИсточникДанных.Склад,
	|	ИсточникДанных.КоличествоОстаток КАК Количество,
	|	ИсточникДанных.СуммаОстаток КАК Сумма
	|ИЗ
	|	РегистрНакопления.ЗаказыПокупателей.Остатки(&МоментДокумента, ЗаказПокупателя В (&СписокЗаказов)) КАК ИсточникДанных
	|";
	тзЗаказы=Запрос.Выполнить().Выгрузить();
	Если НЕ тзЗаказы.Количество()=0 Тогда
		Движения.ЗаказыПокупателей.Загрузить(тзЗаказы);
	КонецЕсли;
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетПотребностей(СтруктураШД, СтруктураТД, Отказ)
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументСсылка",  Ссылка);
	Запрос.УстановитьПараметр("МоментДокумента", МоментВремени());
	Запрос.УстановитьПараметр("СписокЗаказов",   Заказы.ВыгрузитьКолонку("Заказ"));
	Запрос.УстановитьПараметр("Период",  Дата);
	Запрос.УстановитьПараметр("Активность",  Истина);
	Запрос.УстановитьПараметр("ВидДвижения",  ВидДвиженияНакопления.Расход);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	&Активность,
	|	&ДокументСсылка Как Регистратор,
	|	&ВидДвижения,
	|	&Период,
	|	Склад,
	|   ДокументРезерва,
	|   Номенклатура,
	|   ХарактеристикаНоменклатуры,
	|   Организация,
	|   КоличествоОстаток КАК Количество
	|ИЗ
	|   РегистрНакопления.УчетПотребностей.Остатки(&МоментДокумента, ДокументРезерва В (&СписокЗаказов))
	|";
	тзПотребности=Запрос.Выполнить().Выгрузить();
	Если НЕ тзПотребности.Количество()=0 Тогда
		Движения.УчетПотребностей.Загрузить(тзПотребности);
	КонецЕсли;
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетРезервовТМЦ(СтруктураШД, СтруктураТД, Отказ)
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументСсылка",  Ссылка);
	Запрос.УстановитьПараметр("МоментДокумента", МоментВремени());
	Запрос.УстановитьПараметр("СписокЗаказов",   Заказы.ВыгрузитьКолонку("Заказ"));
	Запрос.УстановитьПараметр("Период",  Дата);
	Запрос.УстановитьПараметр("Активность",  Истина);
	Запрос.УстановитьПараметр("ВидДвижения",  ВидДвиженияНакопления.Расход);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	&Активность,
	|	&ДокументСсылка Как Регистратор,
	|	&ВидДвижения,
	|	&Период,
	|	Склад,
	|   Заказ,
	|   Номенклатура,
	|   ХарактеристикаНоменклатуры,
	|   СерияНоменклатуры,
	|   Организация,
	|   КоличествоОстаток КАК Количество
	|ИЗ
	|   РегистрНакопления.УчетРезервовТМЦ.Остатки(&МоментДокумента, Заказ В (&СписокЗаказов))
	|";
	тзПотребности=Запрос.Выполнить().Выгрузить();
	Если НЕ тзПотребности.Количество()=0 Тогда
		Движения.УчетРезервовТМЦ.Загрузить(тзПотребности);
	КонецЕсли;
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

	Если ТипЗнч(Основание)=Тип("ДокументСсылка.ВнутреннийЗаказ") Тогда
		ТипЗаказа=Перечисления.ТипыЗаказов.ВнутреннийЗаказ;

	ИначеЕсли ТипЗнч(Основание)=Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		ТипЗаказа=Перечисления.ТипыЗаказов.ЗаказПокупателя;

	ИначеЕсли ТипЗнч(Основание)=Тип("ДокументСсылка.ЗаказПоставщику") Тогда
		ТипЗаказа=Перечисления.ТипыЗаказов.ЗаказПоставщику;
	КонецЕсли;
	
	НоваяСтрока=Заказы.Добавить();
	НоваяСтрока.Заказ=Основание;
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Заголовок=ЗаполнениеДокументов.ПредставлениеДокументаПриПроведении(ЭтотОбъект);
	Для Каждого СтрокаКоллекции Из Заказы Цикл
		Если СтрокаКоллекции.Заказ.Дата > Дата Тогда
			СтрокаСообщения="Дата и время Заказа в строке " + СокрЛП(СтрокаКоллекции.НомерСтроки)+" больше даты и времени документа!";
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаСообщения, Отказ, Заголовок);
		КонецЕсли;
	КонецЦикла;
	Если Отказ Тогда Возврат; КонецЕсли; 
	
	//Автозаполнение ревизитов шапки\табличных частей
	АвтоЗаполнениеРеквизитовДокумента();
	
	//Формирование значений реквизитов шапки документа
	СтруктураШД=УправлениеДокументамиСервер.ПолучитьСтруктуруРеквизитовШапки(ЭтотОбъект);
	
	//Формирование значений реквизитов таблиц документа
	СтруктураТД=Новый Структура;
	
	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства);