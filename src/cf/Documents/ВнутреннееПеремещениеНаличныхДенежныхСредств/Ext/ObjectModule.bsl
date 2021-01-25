﻿//////////////////////////////////////////////////////////////////////////////////
// Проведение по регистрам

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ДенежныеСредства(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_ДенежныеСредства(СтруктураШД, СтруктураТД, Отказ)
	тзДанные=Движения.ДенежныеСредства.ВыгрузитьКолонки();

	//Расход
	НоваяСтрока=тзДанные.Добавить();
	НоваяСтрока.БанковскийСчетКасса=Касса;
	НоваяСтрока.ВидДенежныхСредств=Перечисления.ВидыДенежныхСредств.Наличные;
	НоваяСтрока.ВидДвижения=ВидДвиженияНакопления.Расход;

	//Приход
	НоваяСтрока=тзДанные.Добавить();
	НоваяСтрока.БанковскийСчетКасса=КассаПолучатель;
	НоваяСтрока.ВидДенежныхСредств=Перечисления.ВидыДенежныхСредств.Наличные;
	НоваяСтрока.ВидДвижения=ВидДвиженияНакопления.Приход;

	тзДанные.ЗаполнитьЗначения(Дата, "Период");
	тзДанные.ЗаполнитьЗначения(Ссылка, "Регистратор");
	тзДанные.ЗаполнитьЗначения(Истина, "Активность");
	тзДанные.ЗаполнитьЗначения(Организация, "Организация");

	тзДанные.ЗаполнитьЗначения(СуммаДокумента, "Сумма"+?(Касса.ВалютаДенежныхСредств=ДополнительныеСвойства.ВалютаБухУчета, "", "Упр"));

	Движения.ДенежныеСредства.Загрузить(тзДанные);
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////
// Проведение по регистрам (по нескольким регистрам одного типа)

Процедура ДвижениеПоРегистру_УчетДенежныхСведств(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ДенежныеСредства(СтруктураШД, СтруктураТД, Отказ);
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

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Заголовок=ЗаполнениеДокументов.ПредставлениеДокументаПриПроведении(ЭтотОбъект);

	ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", Новый Структура);
	ДополнительныеСвойства.Вставить("СтруктураТД", Новый Структура);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства);