﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	
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

Процедура ЗаполнитьВозвратнуюТару() Экспорт
	Если ВидОперации=Перечисления.ВидыОперацийИзменениеЛимитовВозвратнойТары.ЛимитПокупателю Тогда
		ИмяЛимита="ЛимитПокупателю";
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийИзменениеЛимитовВозвратнойТары.ЛимитПоставщика Тогда
		ИмяЛимита="ЛимитПоставщика";
	КонецЕсли;

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДоговорКонтрагента", ДоговорКонтрагента);
	Запрос.Текст="
	|ВЫБРАТЬ
    |	ИсточникДанных.ДоговорКонтрагента,
    |	ИсточникДанных.Номенклатура,
    |	ИсточникДанных."+ИмяЛимита+" КАК Лимит
    |ИЗ
    |	РегистрСведений.ЛимитыВозвратнойТары.СрезПоследних(,ДоговорКонтрагента = &ДоговорКонтрагента) КАК ИсточникДанных
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		НоваяСтрока=ВозвратнаяТара.Добавить();
		НоваяСтрока.Номенклатура=Выборка.Номенклатура;
		НоваяСтрока.Лимит=Выборка.Лимит;
	КонецЦикла;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ЛимитыВозвратнойТары(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_ЛимитыВозвратнойТары(СтруктураШД, СтруктураТД, Отказ)
	тзДвижения=Движения.ЛимитыВозвратнойТары.ВыгрузитьКолонки();
	Для каждого СтрокаКоллекции Из СтруктураТД.ВозвратнаяТара Цикл
		ЗаполнитьЗначенияСвойств(тзДвижения.Добавить(), СтрокаКоллекции);
	КонецЦикла; 
	Движения.ЛимитыВозвратнойТары.Загрузить(тзДвижения);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий

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

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Заголовок=ЗаполнениеДокументов.ПредставлениеДокументаПриПроведении(ЭтотОбъект);

	//Автозаполнение ревизитов шапки\табличных частей
	АвтоЗаполнениеРеквизитовДокумента();

	//Формирование значений реквизитов шапки документа
	СтруктураШД=УправлениеДокументамиСервер.ПолучитьСтруктуруРеквизитовШапки(ЭтотОбъект);

	//Проверяем реквизиты шапки
	ВзаиморасчетыСервер.ПроверитьСоответствиеОрганизацииДоговоруВзаиморасчетов(Организация, ДоговорКонтрагента, СтруктураШД.ДоговорОрганизация, Отказ, Заголовок);

	//Формирование значений реквизитов табличных частей
	СтруктураТД=Новый Структура("ВозвратнаяТара", УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "ВозвратнаяТара"));
	Если ВидОперации=Перечисления.ВидыОперацийИзменениеЛимитовВозвратнойТары.ЛимитПокупателю Тогда
		СтруктураТД.ВозвратнаяТара.Колонки.Лимит.Имя="ЛимитПокупателю";
	Иначе
		СтруктураТД.ВозвратнаяТара.Колонки.Лимит.Имя="ЛимитПоставщика";
	КонецЕсли;

	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства);
