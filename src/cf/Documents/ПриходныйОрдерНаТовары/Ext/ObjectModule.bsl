﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	КачествоНовый=Справочники.Качество.Новый;
	Если ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.Перемещение Тогда
		Контрагент=Неопределено;
	Иначе
		ДокументПеремещения=Неопределено;
	КонецЕсли;

	Для каждого СтрокаКоллекции Из Товары Цикл
		Если НЕ ЗначениеЗаполнено(СтрокаКоллекции.Качество) Тогда
			СтрокаКоллекции.Качество=КачествоНовый;
		КонецЕсли;
		Если ЗначениеЗаполнено(СтрокаКоллекции.ЕдиницаИзмеренияМест) И СтрокаКоллекции.КоличествоМест=0 Тогда
			СтрокаКоллекции.ЕдиницаИзмеренияМест=Неопределено;
		КонецЕсли;
		Если ДокументПеремещения=Неопределено Или (НЕ ЗначениеЗаполнено(СтрокаКоллекции.ДокументРезерва) И СтрокаКоллекции.ДокументРезерва <> Неопределено) Тогда
		   СтрокаКоллекции.ДокументРезерва=Неопределено;
	  	КонецЕсли;
	КонецЦикла;

	Для каждого СтрокаКоллекции Из ВозвратнаяТара Цикл
		Если ДокументПеремещения=Неопределено Или (НЕ ЗначениеЗаполнено(СтрокаКоллекции.ДокументРезерва) И СтрокаКоллекции.ДокументРезерва <> Неопределено) Тогда
		   СтрокаКоллекции.ДокументРезерва=Неопределено;
	  	КонецЕсли;
	КонецЦикла;	

	
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

////////////////////////////////////////////////////////////////////////////////
// Заполнение табличный частей по документу-основания

Процедура ЗаполнитьТабличнуюЧастьПоЗаказуПоставщикам(ДокументОснование, стрТабличнаяЧасть, УчитыватьОстатки=Ложь) Экспорт
	ТабличнаяЧасть=ДокументОснование[стрТабличнаяЧасть];
	Если ТабличнаяЧасть.Количество()=0 Тогда Возврат; КонецЕсли; 
	
	Если УчитыватьОстатки Тогда
		стрУсловие="Организация = &Организация И Номенклатура В (&Номенклатура) И ЗаказПоставщику = &Заказ";

		МассивХарактеристикНоменклатуры=Новый Массив;
		Если стрТабличнаяЧасть="Товары" Тогда
			МассивХарактеристикНоменклатуры=ТабличнаяЧасть.ВыгрузитьКолонку("ХарактеристикаНоменклатуры");
			Если МассивХарактеристикНоменклатуры.Количество()>0 Тогда
				стрУсловие=стрУсловие+" И ХарактеристикаНоменклатуры В (&ХарактеристикаНоменклатуры)";
			КонецЕсли;
		КонецЕсли;

		Запрос=Новый Запрос;
		Запрос.МенеджерВременныхТаблиц=Новый МенеджерВременныхТаблиц;
		Запрос.УстановитьПараметр("ИсточникДанных", ТабличнаяЧасть.Выгрузить());
		Запрос.УстановитьПараметр("НаДату", МоментВремени());
		Запрос.УстановитьПараметр("Организация", Организация);
		Запрос.УстановитьПараметр("Заказ", ДокументОснование);
		Запрос.УстановитьПараметр("Номенклатура", ТабличнаяЧасть.ВыгрузитьКолонку("Номенклатура"));
		Запрос.УстановитьПараметр("ХарактеристикаНоменклатуры", МассивХарактеристикНоменклатуры);
		Запрос.Текст="
		|ВЫБРАТЬ *
		|ПОМЕСТИТЬ ИсточникДанных
		|ИЗ &ИсточникДанных Как ИсточникДанных
		|;
		|
		|ВЫБРАТЬ
		|	&Заказ Как ЗаказПоставщика,
		|	ИсточникДанных1.Цена,
		|";
		
		Если стрТабличнаяЧасть="Товары" Тогда
		Запрос.Текст=Запрос.Текст+"
		|	ИсточникДанных1.СтавкаНДС,
		|	ИсточникДанных1.ЕдиницаИзмерения,
		|	ИсточникДанных1.ЕдиницаИзмеренияМест,
		|	ИсточникДанных1.КоличествоМест,
		|	ИсточникДанных1.ХарактеристикаНоменклатуры,
		|	ИсточникДанных1.Коэффициент,
		|";
		КонецЕсли;

		Запрос.Текст=Запрос.Текст+"		
		|	ИсточникДанных1.Номенклатура,
		|	ИсточникДанных2.ЗаказОснование Как Заказ,
		|	ИсточникДанных1.Количество КАК КоличествоДок,
		|	ИсточникДанных2.КоличествоОстаток КАК Количество
		|ИЗ
		|	ИсточникДанных КАК ИсточникДанных1
		|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.ЗаказыПоставщикам.Остатки(&НаДату, "+стрУсловие+") Как ИсточникДанных2
		|		ПО ИсточникДанных1.Номенклатура = ИсточникДанных2.Номенклатура
		|		"+?(МассивХарактеристикНоменклатуры.Количество()=0, "", "И ИсточникДанных1.ХарактеристикаНоменклатуры = ИсточникДанных2.ХарактеристикаНоменклатуры")+"
		|";
		тзДвижения=Запрос.Выполнить().Выгрузить();
		Для каждого СтрокаКоллекции Из тзДвижения Цикл
			СтрокаКоллекции.Количество=Мин(СтрокаКоллекции.Количество, СтрокаКоллекции.КоличествоДок);
			Если СтрокаКоллекции.Количество<=0 Тогда Продолжить; КонецЕсли;
			
			НоваяСтрока=ЭтотОбъект[стрТабличнаяЧасть].Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);

			Если НЕ стрТабличнаяЧасть="ВозвратнаяТара" Тогда
				ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(НоваяСтрока, ЭтотОбъект);
				ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(НоваяСтрока, ЭтотОбъект);
			КонецЕсли;
		КонецЦикла;
	Иначе
		ЗаполнитьТабличнуюЧастьПоДокументуОснования(ДокументОснование, стрТабличнаяЧасть);
	КонецЕсли;
КонецПроцедуры

Процедура ЗаполнитьТабличнуюЧастьПоДокументуОснования(ДокументОснование, стрТабличнаяЧасть) Экспорт
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ДокументОснование", ДокументОснование);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных."+стрТабличнаяЧасть+" Как ТабличнаяЧасть
	|ИЗ
	|	Документ."+ДокументОснование.Метаданные().Имя+" КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Ссылка = &ДокументОснование
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Если Не Выборка.Следующий() Тогда Возврат; КонецЕсли;

	тзТабличнаяЧать=Выборка.ТабличнаяЧасть.Выгрузить();
	Для каждого СтрокаКоллекции Из тзТабличнаяЧать Цикл
		НоваяСтрока=ЭтотОбъект[стрТабличнаяЧасть].Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		//НоваяСтрока.Качество=Справочники.Качество.Новый;
	КонецЦикла;
КонецПроцедуры

Функция ПодготовитьТаблицуДляТоварамВРезервеПоОрдерам(ТабТовары)

	ТаблицаПоТоварамКПолучению = ТабТовары.Скопировать();
	Сч = 0;
	Пока Сч < ТаблицаПоТоварамКПолучению.Количество() Цикл
		СтрокаТаблицы = ТаблицаПоТоварамКПолучению.Получить(Сч);
		Если Не ЗначениеЗаполнено(СтрокаТаблицы.ДокументРезерва) ИЛИ ТипЗнч(СтрокаТаблицы.ДокументРезерва) <> Тип("ДокументСсылка.ПриходныйОрдерНаТовары") Тогда
			ТаблицаПоТоварамКПолучению.Удалить(СтрокаТаблицы);
		Иначе 
			Сч = Сч + 1;
		КонецЕсли; 
	КонецЦикла;
	
	ТаблицаПоТоварамКПолучению.Колонки.ДокументРезерва.Имя = "ДокументПолучения";
	
	Возврат ТаблицаПоТоварамКПолучению;

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ);
	// Движения по регистру "Учет ТМЦ (потребности)"
	ДвижениеПоРегистру_УчетПотребностей(СтруктураШД, СтруктураТД, Отказ);	

    // Движения по регистру "Учет ТМЦ"
	ДвижениеПоРегистру_УчетТМЦ(СтруктураШД, СтруктураТД, Отказ);

	// Движения по регистру "Учет ТМЦ (Списанные товары)
	ДвижениеПоРегистру_СписанныеТовары(СтруктураШД, СтруктураТД, Отказ);

	// Движения по регистру "Учет ТМЦ (партии)"
	ДвижениеПоРегистру_УчетПартийТМЦ(СтруктураШД, СтруктураТД, Отказ);

	// Движения по регистру "Учет ТМЦ (к получению на склады)"
	ДвижениеПоРегистру_ТоварыКПолучениюНаСклады(СтруктураШД, СтруктураТД, Отказ);
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетТМЦ(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ТоварыНаСкладах") Тогда Возврат; КонецЕсли;

	тзДвижения=Движения.ТоварыНаСкладах.ВыгрузитьКолонки();
	Для каждого СтрокаКоллекции Из СтруктураТД.Товары Цикл
		ЗаполнитьЗначенияСвойств(тзДвижения.Добавить(), СтрокаКоллекции)
	КонецЦикла;
	
	Для каждого СтрокаКоллекции Из СтруктураТД.Тара Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.Качество=Справочники.Качество.Новый;
	КонецЦикла; 

	тзДвижения.ЗаполнитьЗначения(Дата, "Период");
	тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
	тзДвижения.ЗаполнитьЗначения(ВидДвиженияНакопления.Приход, "ВидДвижения");
	тзДвижения.ЗаполнитьЗначения(Склад, "Склад");
	Движения.ТоварыНаСкладах.Загрузить(тзДвижения);
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетПартийТМЦ(СтруктураШД, СтруктураТД, Отказ)
	Если БезПраваПродажи Тогда Возврат; КонецЕсли;
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ПартииТоваровНаСкладах") Тогда Возврат; КонецЕсли;

	Если ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.Перемещение Тогда
		СтруктураШД.Вставить("Отказ", Отказ);
		СтруктураШД.Вставить("ТаблицаСписания", Движения.СписанныеТовары.Выгрузить());
		УправлениеЗапасамиПартионныйУчет.ДвижениеПартийТоваров(Ссылка, СтруктураШД);

	Иначе // Если товары можно продавать приходуем партии в управленческом учете со статусом "По ордеру"

		тзДвижения=Движения.ПартииТоваровНаСкладах.ВыгрузитьКолонки();
		
		Для каждого СтрокаКоллекции Из СтруктураТД.Товары Цикл
			НоваяСтрока=тзДвижения.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		КонецЦикла;
		
		Для каждого СтрокаКоллекции Из СтруктураТД.Тара Цикл
			НоваяСтрока=тзДвижения.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
			НоваяСтрока.Качество=Справочники.Качество.Новый;
		КонецЦикла;
		
		Если тзДвижения.Количество()>0 Тогда
			тзДвижения.ЗаполнитьЗначения(Дата, "Период");
			тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
			тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
			тзДвижения.ЗаполнитьЗначения(Организация, "Организация");
			тзДвижения.ЗаполнитьЗначения(Склад, "Склад");
			тзДвижения.ЗаполнитьЗначения(Ссылка, "ДокументОприходования");
			тзДвижения.ЗаполнитьЗначения(Перечисления.СтатусыПартийТоваров.ПоОрдеру, "СтатусПартии");

		    Движения.ПартииТоваровНаСкладах.Загрузить(тзДвижения);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры	
	
Процедура ДвижениеПоРегистру_СписанныеТовары(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.Перемещение Или БезПраваПродажи Тогда
		Возврат;
	КонецЕсли;
	НомерСтроки=1; тзДвижения=Движения.СписанныеТовары.ВыгрузитьКолонки();

	Для каждого СтрокаКоллекции Из СтруктураТД.Товары Цикл
		НоваяСтрока=тзДвижения.Добавить(); НомерСтроки=НомерСтроки+1;
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.НомерСтрокиДокумента=НомерСтроки;
	КонецЦикла;

	Для каждого СтрокаКоллекции Из СтруктураТД.Тара Цикл
		НоваяСтрока=тзДвижения.Добавить(); НомерСтроки=НомерСтроки+1;
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);
		НоваяСтрока.ДопустимыйСтатус2=Перечисления.СтатусыПартийТоваров.Купленный;
		НоваяСтрока.Качество=Справочники.Качество.Новый;
		НоваяСтрока.НомерСтрокиДокумента=НомерСтроки;
	КонецЦикла;

	тзДвижения.ЗаполнитьЗначения(СтруктураШД.СкладОтправитель, "Склад");
	тзДвижения.ЗаполнитьЗначения(Дата, "Период");
	тзДвижения.ЗаполнитьЗначения(Ссылка, "Регистратор");
	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");
	тзДвижения.ЗаполнитьЗначения(Перечисления.СтатусыПартийТоваров.ВозвратнаяТара, "ДопустимыйСтатус1");
	тзДвижения.ЗаполнитьЗначения(Подразделение, "Подразделение");
	тзДвижения.ЗаполнитьЗначения(Организация, "Организация");
	тзДвижения.ЗаполнитьЗначения(ДокументПеремещения, "ОсновнойДокумент");
	тзДвижения.ЗаполнитьЗначения(Перечисления.КодыОперацийПартииТоваров.СписаниеПоОрдеру, "КодОперацииПартииТоваров");
	
	Движения.СписанныеТовары.Загрузить(тзДвижения);
	Движения.СписанныеТовары.Записать(Истина);
КонецПроцедуры

Процедура ДвижениеПоРегистру_ТоварыКПолучениюНаСклады(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "ТоварыКПолучениюНаСклады") Тогда Возврат; КонецЕсли;
	
	Заголовок=ДополнительныеСвойства.Заголовок;

	ТаблицаПоТоварам=СтруктураТД.Товары;
	ТаблицаПоТаре=СтруктураТД.Тара;

	СтруктТаблицДокумента = Новый Структура;
	СтруктТаблицДокумента.Вставить("ТаблицаПоТоварам", ТаблицаПоТоварам);
	СтруктТаблицДокумента.Вставить("ТаблицаПоТаре",    ТаблицаПоТаре);
	
	ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(Движения.ТоварыКПолучениюНаСклады, СтруктТаблицДокумента);
	
	ДокПеремещения = ?(ВидОперации = Перечисления.ВидыОперацийПриходныйОрдер.Перемещение,   ДокументПеремещения, Ссылка);
	
	ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "ДокументПолучения", ДокПеремещения);
	ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "Склад",             Склад);
	ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "СтатусПартии",      Перечисления.СтатусыПартийТоваров.Купленный,      "ТаблицаПоТоварам");
	ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "СтатусПартии",      Перечисления.СтатусыПартийТоваров.ВозвратнаяТара, "ТаблицаПоТаре");
	ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "Качество",          Справочники.Качество.Новый,                       "ТаблицаПоТаре");
	Если БезПраваПродажи Тогда
		ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "ДокументРезерва", Ссылка);
	КонецЕсли;
	
	ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(Движения.ТоварыКПолучениюНаСклады, ВидДвиженияНакопления.Приход, ТаблицыДанныхДокумента, Дата);
	
	Если ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.Перемещение Тогда
		// Для резервов по ордеру надо сделать приход по регистру "Товары к получению на склады"
		ТаблицаПоТоварамКПолучению = ПодготовитьТаблицуДляТоварамВРезервеПоОрдерам(ТаблицаПоТоварам);
		ТаблицаПоТареКПолучению    = ПодготовитьТаблицуДляТоварамВРезервеПоОрдерам(ТаблицаПоТаре);
			
		Если ТаблицаПоТоварамКПолучению.Количество() > 0 ИЛИ ТаблицаПоТареКПолучению.Количество() > 0 Тогда
			СтруктТаблицДокумента=Новый Структура;
			СтруктТаблицДокумента.Вставить("ТаблицаПоТоварам", ТаблицаПоТоварамКПолучению);
			СтруктТаблицДокумента.Вставить("ТаблицаПоТаре",    ТаблицаПоТареКПолучению);
			
			ТаблицыДанныхДокумента=ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(Движения.ТоварыКПолучениюНаСклады, СтруктТаблицДокумента);
			
			ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "Склад",        Склад);
			ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "СтатусПартии", Перечисления.СтатусыПартийТоваров.Купленный,      "ТаблицаПоТоварам");
			ОбщегоНазначения.УстановитьЗначениеВТаблицыДокумента(ТаблицыДанныхДокумента, "СтатусПартии", Перечисления.СтатусыПартийТоваров.ВозвратнаяТара, "ТаблицаПоТаре");

			ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(Движения.ТоварыКПолучениюНаСклады, ВидДвиженияНакопления.Приход, ТаблицыДанныхДокумента, Дата);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ДвижениеПоРегистру_УчетПотребностей(СтруктураШД, СтруктураТД, Отказ)
	Если НЕ Константы.УчетПотребностей.Получить() Тогда Возврат; КонецЕсли; 
	Если НЕ УправлениеДокументамиСервер.РазрешитьДвиженияПоРегистру(СтруктураШД, "УчетПотребностей") Тогда Возврат; КонецЕсли;
	
	тзТМЦ=СтруктураТД.Товары.СкопироватьКолонки("Активность,Период,Регистратор,ВидТабличнойЧасти,Организация,Склад,ДокументРезерва,Номенклатура,ХарактеристикаНоменклатуры,Количество");
	
	МассивСерийНоменклатуры=Новый Массив;
	МассивСерийНоменклатуры.Добавить(Справочники.СерииНоменклатуры.ПустаяСсылка());
	МассивХарактеристикНоменклатуры=Новый Массив;		
	МассивСкладов=Новый Массив;
    МассивТоваров=Новый Массив;

	МассивСделок=Новый Массив;
	Для каждого СтрокаКоллекции Из Сделки Цикл
		Если НЕ ТипЗнч(СтрокаКоллекции.Сделка)=Тип("ДокументСсылка.ЗаказПоставщику") Тогда
			МассивСделок.Добавить(СтрокаКоллекции.Сделка);
		КонецЕсли; 
	КонецЦикла; 
	
	Для каждого СтрокаКоллекции1 Из СтруктураТД Цикл
		Если НЕ СтрокаКоллекции1.Ключ="Товары" И НЕ СтрокаКоллекции1.Ключ="Тара" Тогда Продолжить; КонецЕсли;

		Для каждого СтрокаКоллекции2 Из СтрокаКоллекции1.Значение Цикл
			ЗаполнитьЗначенияСвойств(тзТМЦ.Добавить(), СтрокаКоллекции2);
			Если СтрокаКоллекции1.Ключ="Товары" Тогда
				Если ЗначениеЗаполнено(СтрокаКоллекции2.ХарактеристикаНоменклатуры) Тогда
					МассивХарактеристикНоменклатуры.Добавить(СтрокаКоллекции2.ХарактеристикаНоменклатуры);
				КонецЕсли;
				Если ЗначениеЗаполнено(СтрокаКоллекции2.Склад) Тогда
					МассивСкладов.Добавить(СтрокаКоллекции2.Склад);
				КонецЕсли;			
			КонецЕсли; 
			МассивТоваров.Добавить(СтрокаКоллекции2.Номенклатура);
		КонецЦикла;
	КонецЦикла;

	Если тзТМЦ.Количество()=0 Тогда Возврат; КонецЕсли; 

	//***ОбщегоНазначения.ОчиститьДвиженияРегистраПоРегистратору(Ссылка, "УчетПотребностей");

	стрУсловие="Организация = Организация И Склад В (&Склад) И Номенклатура В (&Номенклатура)";
    Если МассивХарактеристикНоменклатуры.Количество()>0 Тогда
		стрУсловие=стрУсловие+" И ХарактеристикаНоменклатуры В (&ХарактеристикаНоменклатуры)";
	КонецЕсли; 

	Если НЕ МассивСделок.Количество()=0 Тогда
		стрУсловие=стрУсловие+" И ДокументРезерва В (&Сделка)";
	КонецЕсли;
	
	Запрос=Новый Запрос;
	Запрос.МенеджерВременныхТаблиц=Новый МенеджерВременныхТаблиц;
	Запрос.УстановитьПараметр("ИсточникДанных", тзТМЦ);
	Запрос.УстановитьПараметр("ВидДвижения", ВидДвиженияНакопления.Расход);
	Запрос.УстановитьПараметр("НаДату", МоментВремени());
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Склад", МассивСкладов);
	Запрос.УстановитьПараметр("Номенклатура", МассивТоваров);
	Запрос.УстановитьПараметр("ХарактеристикаНоменклатуры", МассивХарактеристикНоменклатуры);
	Запрос.УстановитьПараметр("Сделка", МассивСделок);
	Запрос.Текст="
	|ВЫБРАТЬ *
	|ПОМЕСТИТЬ ИсточникДанных
	|ИЗ &ИсточникДанных Как ИсточникДанных
	|;
	|
	|ВЫБРАТЬ
	|	&ВидДвижения,
	|	ИсточникДанных1.Активность,
	|	ИсточникДанных1.Период,
	|	ИсточникДанных1.Регистратор,
	|	ИсточникДанных1.ВидТабличнойЧасти,
	|	ИсточникДанных1.Склад,
	|	ИсточникДанных1.Номенклатура,
	|	ИсточникДанных1.ХарактеристикаНоменклатуры,
	|	ИсточникДанных2.ДокументРезерва Как ДокументРезерва,
	|	ИсточникДанных1.Организация,
	|	ИсточникДанных1.Количество КАК КоличествоДок,
	|	ИсточникДанных2.КоличествоОстаток КАК Количество
	|ИЗ
	|	ИсточникДанных КАК ИсточникДанных1
	|	ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.УчетПотребностей.Остатки(&НаДату, "+стрУсловие+") Как ИсточникДанных2
	|		ПО ИсточникДанных1.Склад = ИсточникДанных2.Склад
	|		И ИсточникДанных1.Организация = ИсточникДанных2.Организация
	|		И ИсточникДанных1.Номенклатура = ИсточникДанных2.Номенклатура
	|		И (ИсточникДанных1.ДокументРезерва = ИсточникДанных2.ДокументРезерва Или ИсточникДанных1.ДокументРезерва = Неопределено Или ИсточникДанных2.ДокументРезерва = Неопределено)
	|		"+?(МассивХарактеристикНоменклатуры.Количество()=0, "", "И ИсточникДанных1.ХарактеристикаНоменклатуры = ИсточникДанных2.ХарактеристикаНоменклатуры")+"
	|";
	тзДвижения=Запрос.Выполнить().Выгрузить();
	Для каждого СтрокаКоллекции Из тзДвижения Цикл
		СтрокаКоллекции.Количество=Мин(СтрокаКоллекции.Количество, СтрокаКоллекции.КоличествоДок);
	КонецЦикла;
	МассивСтрок=тзДвижения.НайтиСтроки(Новый Структура("Количество", 0));
	Для каждого СтрокаКоллекции Из МассивСтрок Цикл
		тзДвижения.Удалить(МассивСтрок);
	КонецЦикла; 

	Движения.УчетПотребностей.Загрузить(тзДвижения);
	
	//Учет резервов ТМЦ
	Если Константы.УчетРезервов.Получить() Тогда
		тзДвижения.Колонки.ДокументРезерва.Имя="Заказ";
		тзДвижения.ЗаполнитьЗначения(ВидДвиженияНакопления.Приход, "ВидДвижения");
		Движения.УчетРезервовТМЦ.Загрузить(тзДвижения);
	КонецЕсли; 	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий

Процедура ОбработкаЗаполнения(Основание)
	Если Не ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание) Тогда Возврат; КонецЕсли;
	
	Если ТипЗнч(Основание)=Тип("ДокументСсылка.ЗаказПоставщику") Тогда
		ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.ОтПоставщика;
		ЗаполнитьТабличнуюЧастьПоЗаказуПоставщикам(Основание, "Товары", Основание.Проведен);
		ЗаполнитьТабличнуюЧастьПоЗаказуПоставщикам(Основание, "ВозвратнаяТара", Основание.Проведен);

	ИначеЕсли ТипЗнч(Основание)=Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
		ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.ОтПокупателя;
		ЗаполнитьТабличнуюЧастьПоДокументуОснования(Основание, "Товары");
		ЗаполнитьТабличнуюЧастьПоДокументуОснования(Основание, "ВозвратнаяТара")		

	ИначеЕсли ТипЗнч(Основание)=Тип("ДокументСсылка.РасходныйОрдерНаТовары") Тогда
		ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.Перемещение;
		ЗаполнитьТабличнуюЧастьПоДокументуОснования(Основание, "Товары");
		ЗаполнитьТабличнуюЧастьПоДокументуОснования(Основание, "ВозвратнаяТара")		

	ИначеЕсли ТипЗнч(Основание)=Тип("ДокументСсылка.ПеремещениеТоваров") Тогда
		ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.Перемещение;
		Склад=Основание.СкладПолучатель;
		ДокументПеремещения=Основание;

		Запрос=Новый Запрос;
		Запрос.УстановитьПараметр("ДокументОснование", Основание);
		Запрос.УстановитьПараметр("Склад", Склад);
		Запрос.УстановитьПараметр("СтатусПартии", Перечисления.СтатусыПартийТоваров.Купленный);		
		Запрос.Текст="
		|ВЫБРАТЬ
		|	Остатки.Номенклатура,
		|	Остатки.СерияНоменклатуры,
		|	Остатки.ХарактеристикаНоменклатуры,
		|	Остатки.Качество,
		|	Остатки.ДокументРезерва,
		|	Остатки.Номенклатура.ЕдиницаХраненияОстатков Как ЕдиницаИзмерения,
		|	Остатки.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент Как Коэффициент,
		|	Остатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.ТоварыКПолучениюНаСклады.Остатки(, ДокументПолучения = &ДокументОснование 
		|                                                        И СтатусПартии = &СтатусПартии
		|                                                        И Склад = &Склад) КАК Остатки
		|ГДЕ
		|	Остатки.КоличествоОстаток <> 0		
		|";
		Выборка=Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			СтрокаТабличнойЧасти=Товары.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаТабличнойЧасти, Выборка);
			СтрокаТабличнойЧасти.Количество=-Выборка.КоличествоОстаток;
			ОбработкаТабличныхЧастей.РассчитатьКоличествоМестТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);
		КонецЦикла;

		Запрос.УстановитьПараметр("СтатусПартии", Перечисления.СтатусыПартийТоваров.ВозвратнаяТара);
		Запрос.Текст="
		|ВЫБРАТЬ
		|	Остатки.Номенклатура,
		|	Остатки.ДокументРезерва,
		|	Остатки.КоличествоОстаток  КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.ТоварыКПолучениюНаСклады.Остатки(, ДокументПолучения = &ДокументОснование 
		|                                                       И Склад = &Склад
		|                                                       И СтатусПартии = &СтатусПартии) КАК Остатки
		|";
		Выборка=Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			СтрокаТабличнойЧасти=ВозвратнаяТара.Добавить();
			СтрокаТабличнойЧасти.Номенклатура=Выборка.Номенклатура;
			СтрокаТабличнойЧасти.Количество=-Выборка.КоличествоОстаток;
			СтрокаТабличнойЧасти.ДокументРезерва=Выборка.ДокументРезерва;
		КонецЦикла;
	КонецЕсли;

	ОбработкаТабличныхЧастей.ЗаполнитьТиповыеОперации(ЭтотОбъект);
КонецПроцедуры

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
	стрТекстЗапроса="
	|ДокументПеремещения.СкладПолучатель Как СкладПолучатель,
	|ДокументПеремещения.СкладОтправитель Как СкладОтправитель,
	|";
	СтруктураШД=УправлениеДокументамиСервер.ПолучитьСтруктуруРеквизитовШапки(ЭтотОбъект,,стрТекстЗапроса);	

	Если ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.Перемещение Тогда
		Если НЕ СтруктураШД.Склад=СтруктураШД.СкладПолучатель Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Склад документа должен соответствовать складу-получателю документа перемещения!", Отказ, Заголовок);
			Если Отказ Тогда Возврат; КонецЕсли;
		КонецЕсли;		
	КонецЕсли;
	
	Если ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.ОтПодотчетника Тогда
		ПроверяемыеРеквизиты.Добавить("ФизЛицо");
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийПриходныйОрдер.Перемещение Тогда
		ПроверяемыеРеквизиты.Добавить("ДокументПеремещения");
	КонецЕсли;

	СтруктураТД=Новый Структура;
	СтруктураТД.Вставить("Товары", УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "Товары", "ДокументРезерва.БезПраваПродажи Как РезервБезПраваПродажи, 0 Как СуммаПродажная,"));
	СтруктураТД.Вставить("Тара", УправлениеДокументамиСервер.ПолучитьСтруктуруТЧ(ЭтотОбъект, "ВозвратнаяТара", "ДокументРезерва.БезПраваПродажи Как РезервБезПраваПродажи,"));
	
	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);		
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства, "Покупка");