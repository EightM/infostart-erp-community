﻿Функция ОбработатьВведенныйШтрихкод(Штрихкод) Экспорт
	мПрефиксВесовогоТовара=Константы.ПрефиксВесовогоТовара.Получить();
	мДлинаКодаВесовогоТовара=Константы.ДлинаКодаВесовогоТовара.Получить();

	СтруктураВозврата=Новый Структура;
	СтруктураВозврата.Вставить("Номенклатура");
	СтруктураВозврата.Вставить("ХарактеристикаНоменклатуры");
	СтруктураВозврата.Вставить("СерияНоменклатуры");
	СтруктураВозврата.Вставить("Качество");
	СтруктураВозврата.Вставить("ЕдиницаИзмерения");
	СтруктураВозврата.Вставить("Количество", 1);	
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Штрихкод", Штрихкод);
	Запрос.Текст="
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|    РегШК.Владелец                   КАК Номенклатура,
	|    РегШК.ЕдиницаИзмерения           КАК ЕдиницаИзмерения,
	|    РегШК.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|    РегШК.СерияНоменклатуры          КАК СерияНоменклатуры,
	|    РегШК.Качество                   КАК Качество
	|ИЗ
	|    РегистрСведений.Штрихкоды        КАК РегШК
	|ГДЕ
	|    РегШК.Штрихкод = &Штрихкод
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Если ТипЗнч(Выборка.Номенклатура) = Тип("СправочникСсылка.ИнформационныеКарты") Тогда
		Иначе // Если ТипЗнч(РезультатЗапроса.Владелец) = Тип("СправочникСсылка.Номенклатура")
			ЗаполнитьЗначенияСвойств(СтруктураВозврата, Выборка);
			Возврат СтруктураВозврата;
		КонецЕсли;
	КонецЕсли;

	стрТипШК="EAN13";
	МодульМенеджерОборудованияВызовСервера=ОбщегоНазначенияСервер.ОбщийМодуль("МенеджерОборудованияВызовСервера");
	Если НЕ МодульМенеджерОборудованияВызовСервера=Неопределено Тогда
		стрТипШК=МодульМенеджерОборудованияВызовСервера.ОпределитьТипШтрихкода(Штрихкод);
	КонецЕсли;

	Если ЗначениеЗаполнено(мПрефиксВесовогоТовара) И ЗначениеЗаполнено(мДлинаКодаВесовогоТовара) И стрТипШК="EAN13" И Лев(Штрихкод, 2)="2"+мПрефиксВесовогоТовара Тогда
		КодТовара=Сред(Штрихкод, 3, мДлинаКодаВесовогоТовара); //Сред(Штрихкод, 5, 3);
		КоличествоТовара=Строка(Число(Лев(Прав(Штрихкод, мДлинаКодаВесовогоТовара), мДлинаКодаВесовогоТовара-1)));
		КоличествоТовара=СтрЗаменить(КоличествоТовара, Символы.НПП, "");

		Коэф=?(Лев(Штрихкод, 2)="2"+СокрЛП(мПрефиксВесовогоТовара), 1000, 1);
		//Коэф=СтрЗаменить(Коэф, Символы.НПП, "");

		Запрос=Новый Запрос;
		Запрос.УстановитьПараметр("КачествоПустаяСсылка", Справочники.Качество.ПустаяСсылка());
		Запрос.УстановитьПараметр("КачествоНовый",        Справочники.Качество.Новый);
		Запрос.УстановитьПараметр("Код",                  Число(КодТовара));
		Запрос.УстановитьПараметр("Коэф", Коэф);
		Запрос.Текст="
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|    РегКВТ.Номенклатура                         КАК Номенклатура,
		|    РегКВТ.Номенклатура.ЕдиницаХраненияОстатков КАК ЕдиницаИзмерения,
		|    РегКВТ.ХарактеристикаНоменклатуры           КАК ХарактеристикаНоменклатуры,
		|    "+КоличествоТовара+"/&Коэф            КАК Количество,
		|    РегКВТ.СерияНоменклатуры                    КАК СерияНоменклатуры,
		|    ВЫБОР
		|        КОГДА РегКВТ.Качество = &КачествоПустаяСсылка ТОГДА
		|            &КачествоНовый
		|        ИНАЧЕ
		|            РегКВТ.Качество
		|    КОНЕЦ                                       КАК Качество
		|ИЗ
		|    РегистрСведений.КодыВесовогоТовара          КАК РегКВТ
		|ГДЕ
		|    РегКВТ.Код = &Код
		|";
		Выборка=Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			ЗаполнитьЗначенияСвойств(СтруктураВозврата, Выборка);
			Возврат СтруктураВозврата;
		КонецЕсли;
	КонецЕсли;

	Возврат СтруктураВозврата;
КонецФункции
