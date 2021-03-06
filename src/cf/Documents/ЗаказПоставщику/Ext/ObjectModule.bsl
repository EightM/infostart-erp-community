﻿Процедура АвтоЗаполнениеРеквизитовДокумента() Экспорт 
	Если Услуги.Количество() > 0 И ДоговорКонтрагента.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом Тогда
		Услуги.Очистить();
	КонецЕсли;
	
	//Товары
	Для каждого СтрокаТабличнойЧасти Из Товары Цикл
		Если НЕ УчитыватьНДС Тогда
			СтрокаТабличнойЧасти.СтавкаНДС=Перечисления.СтавкиНДС.БезНДС;
		КонецЕсли;
		Если ЗначениеЗаполнено(СтрокаТабличнойЧасти.ЕдиницаИзмеренияМест) И СтрокаТабличнойЧасти.КоличествоМест = 0 Тогда
			СтрокаТабличнойЧасти.ЕдиницаИзмеренияМест=Неопределено;
		КонецЕсли;
	КонецЦикла;
	
	//Услуги
	Для каждого СтрокаТабличнойЧасти Из Услуги Цикл
		Если НЕ УчитыватьНДС Тогда
			СтрокаТабличнойЧасти.СтавкаНДС=Перечисления.СтавкиНДС.БезНДС;
		КонецЕсли;	
	КонецЦикла;

	СуммаДокумента = ЦенообразованиеСервер.ПолучитьСуммуДокументаСНДС(ЭтотОбъект, "Товары") + ЦенообразованиеСервер.ПолучитьСуммуДокументаСНДС(ЭтотОбъект, "Услуги");
	СуммаНДС = ЦенообразованиеСервер.ПолучитьНДСДокумента(ЭтотОбъект);
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

Процедура ЗаполнитьТабличнуюЧастьПоОстаткам(ТабличнаяЧасть, ЗаказПокупателя = Неопределено) Экспорт
	Если ЗначениеЗаполнено(ЗаказПокупателя.ДатаОтгрузки) И ЗначениеЗаполнено(ДатаПоступления) И (ЗаказПокупателя.ДатаОтгрузки < ДатаПоступления) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Отгрузку по заказу покупателя необходимо осуществить раньше даты поступления по данному документу!");
		Возврат;
	КонецЕсли;

	ЭтоТовары=ТабличнаяЧасть=Товары;

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("ТипЦен", ТипЦен);
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("ДатаОстатков", ОбщегоНазначения.ПолучитьДатуОстатков(ЭтотОбъект));
	Запрос.УстановитьПараметр("ЗаказПокупателя", ЗаказПокупателя);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Номенклатура,
	|	ИсточникДанных.Номенклатура.СтавкаНДС КАК СтавкаНДС,		
	|	ИсточникДанных.ХарактеристикаНоменклатуры,
	|	ИсточникДанных.ЗаказПокупателя,
	|	ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков КАК ЕдиницаИзмерения,
	|	ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент КАК Коэффициент,
	|	ИсточникДанных.СуммаОстаток КАК Сумма,
	|	ИсточникДанных.КоличествоОстаток КАК Заказано
	|ИЗ
	|	РегистрНакопления.ЗаказыПокупателей.Остатки(&ДатаОстатков, ЗаказПокупателя = &ЗаказПокупателя) КАК ИсточникДанных
	|ГДЕ 
	|	НЕ ИсточникДанных.Номенклатура.Услуга
	|";
	
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Количество=?(Выборка.Заказано=NULL, 0, Выборка.Заказано);
		Если Количество <= 0 Тогда Продолжить; КонецЕсли;
		
		СтрокаТабличнойЧасти=ТабличнаяЧасть.Добавить();
		СтрокаТабличнойЧасти.Номенклатура=Выборка.Номенклатура;
		СтрокаТабличнойЧасти.Заказ=Выборка.ЗаказПокупателя;
		Если ЭтоТовары Тогда
			СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры=Выборка.ХарактеристикаНоменклатуры;
			СтрокаТабличнойЧасти.ЕдиницаИзмерения=Выборка.ЕдиницаИзмерения;
			СтрокаТабличнойЧасти.СтавкаНДС=Выборка.СтавкаНДС;
			СтрокаТабличнойЧасти.Коэффициент=Выборка.Коэффициент;				
			СтрокаТабличнойЧасти.Количество=Количество * Выборка.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент/Выборка.Коэффициент;
		Иначе
			СтрокаТабличнойЧасти.Количество=Количество;														
		КонецЕсли;
		Если СтрокаТабличнойЧасти.Цена=0 Тогда
			СтрокаТабличнойЧасти.Цена=ЦенообразованиеСервер.ПолучитьЦенуНоменклатуры(СтрокаТабличнойЧасти.Номенклатура, ?(ЭтоТовары, СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры, Неопределено), ТипЦен, ТекущаяДата(), СтрокаТабличнойЧасти.ЕдиницаИзмерения);

			Если ЭтоТовары Тогда
				ОбработкаТабличныхЧастей.ЗаполнитьСтавкуНДСТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект, "Приобретение");
			КонецЕсли;

			ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);

			Если ЭтоТовары Тогда
				ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);
			КонецЕсли;
		КонецЕсли;		
	КонецЦикла;

КонецПроцедуры

Процедура ЗаполнитьТабличнуюЧастьПоОстаткамВнутреннийЗаказ(ТабличнаяЧасть, ВнутреннийЗаказ = Неопределено) Экспорт
	Если ЗначениеЗаполнено(ВнутреннийЗаказ.ДатаОтгрузки) И ЗначениеЗаполнено(ДатаПоступления) И ВнутреннийЗаказ.ДатаОтгрузки < ДатаПоступления Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Отгрузку по внутреннему заказу необходимо осуществить раньше даты поступления по данному документу!");
		Возврат;
	КонецЕсли;

	ЭтоТовары = ТабличнаяЧасть = Товары;
	
	ТекстЗапросаПоНоменклатуре = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ Номенклатура 
	|   ИЗ  Документ.ВнутреннийЗаказ." + ?(ЭтоТовары, "Товары", "ВозвратнаяТара") + "
	|   ГДЕ Документ.ВнутреннийЗаказ." + ?(ЭтоТовары, "Товары", "ВозвратнаяТара") + ".Ссылка = &ВнутреннийЗаказ";

	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("ВнутреннийЗаказ", ВнутреннийЗаказ);
	Запрос.УстановитьПараметр("ДатаОстатков", ОбщегоНазначения.ПолучитьДатуОстатков(ЭтотОбъект));
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Номенклатура,
	|	ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков             КАК ЕдиницаХраненияОстатков,
	|	ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент КАК Коэффициент,
	|	ИсточникДанных.Номенклатура.СтавкаНДС                           КАК СтавкаНДС,
	|	ИсточникДанных.ХарактеристикаНоменклатуры,
	|	ИсточникДанных.ВнутреннийЗаказ,
	|	ИсточникДанных.КоличествоОстаток КАК Заказано
	|ИЗ
	|	РегистрНакопления.ВнутренниеЗаказы.Остатки(&ДатаОстатков, Номенклатура В ("+ТекстЗапросаПоНоменклатуре+") И ВнутреннийЗаказ = &ВнутреннийЗаказ) КАК ИсточникДанных
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Количество=?(Выборка.Заказано=NULL, 0, Выборка.Заказано);
		Если Количество <= 0 Тогда Продолжить; КонецЕсли;
		
		СтрокаТабличнойЧасти=ТабличнаяЧасть.Добавить();
		СтрокаТабличнойЧасти.Номенклатура=Выборка.Номенклатура;
		СтрокаТабличнойЧасти.Количество=Количество;
		СтрокаТабличнойЧасти.Заказ=Выборка.ВнутреннийЗаказ;
			
		Если ЭтоТовары Тогда
			СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры=Выборка.ХарактеристикаНоменклатуры;
			СтрокаТабличнойЧасти.ЕдиницаИзмерения=Выборка.ЕдиницаХраненияОстатков;
			СтрокаТабличнойЧасти.СтавкаНДС=Выборка.СтавкаНДС;
			СтрокаТабличнойЧасти.Коэффициент=Выборка.Коэффициент;
		КонецЕсли;
		Если СтрокаТабличнойЧасти.Цена=0 Тогда
			СтрокаТабличнойЧасти.Цена=ЦенообразованиеСервер.ПолучитьЦенуНоменклатуры(СтрокаТабличнойЧасти.Номенклатура, ?(ЭтоТовары, СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры, Неопределено), ТипЦен, ТекущаяДата(), СтрокаТабличнойЧасти.ЕдиницаИзмерения);
			ОбработкаТабличныхЧастей.РассчитатьСуммуТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);
			Если ЭтоТовары Тогда
				ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);
			КонецЕсли;
		КонецЕсли;		
	КонецЦикла;
КонецПроцедуры

Процедура ЗаполнитьТоварыПоЗаказуПокупателю(ЗаказПокупателя) Экспорт
	ЗаполнитьТабличнуюЧастьПоОстаткам(Товары, ЗаказПокупателя);
КонецПроцедуры

Процедура ЗаполнитьВозвратнуюТаруПоЗаказуПокупателю(ЗаказПокупателя) Экспорт
	ЗаполнитьТабличнуюЧастьПоОстаткам(ВозвратнаяТара, ЗаказПокупателя);
КонецПроцедуры

Процедура ЗаполнитьТабличнуюЧастьПотребностями(ТабличнаяЧасть, ДокументСсылка) Экспорт
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("ДокументРезерва", ДокументСсылка);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Склад,
	|	ИсточникДанных.Номенклатура,
	|	ИсточникДанных.ХарактеристикаНоменклатуры,
	|	ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков             КАК ЕдиницаИзмерения,
	|	ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент КАК Коэффициент,
	|	ИсточникДанных.Номенклатура.СтавкаНДС                           КАК СтавкаНДС,	
	|	СУММА(ИсточникДанных.КоличествоОстаток) КАК Количество
	|ИЗ
	|	РегистрНакопления.УчетПотребностей.Остатки(&МоментВремени, ДокументРезерва = &ДокументРезерва) КАК ИсточникДанных
	|
	|СГРУППИРОВАТЬ ПО
	|	ИсточникДанных.Склад,
	|	ИсточникДанных.Номенклатура,
	|	ИсточникДанных.ХарактеристикаНоменклатуры,
	|	ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков,
	|	ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент,
	|	ИсточникДанных.Номенклатура.СтавкаНДС
	|";
	тзДанныеЗапроса=Запрос.Выполнить().Выгрузить();
	Для каждого СтрокаКоллекции Из тзДанныеЗапроса Цикл
		ЗаполнитьЗначенияСвойств(ТабличнаяЧасть.Добавить(), СтрокаКоллекции);
	КонецЦикла; 
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Подготовка таблиц для проведения
 
Функция СформироватьТаблицу_Товары(СтруктураШД, Отказ, Заголовок)
	тзДанные=Товары.Выгрузить();
	Для каждого СтрокаКоллекции Из тзДанные Цикл
		СтрокаКоллекции.Количество=СтрокаКоллекции.Количество * СтрокаКоллекции.Коэффициент /СтрокаКоллекции.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент;
		Если СтрокаКоллекции.Номенклатура.Набор Тогда
			стрСообщение="В строке номер """+СокрЛП(СтрокаКоллекции.НомерСтроки)+""" табличной части ""Товары"": ";
			стрСообщение=стрСообщение+"содержится набор-пакет. Наборов-пакетов здесь быть не должно!";
			ОбщегоНазначения.СообщитьОбОшибке(стрСообщение, Отказ, Заголовок);
		КонецЕсли;
	КонецЦикла;	
	Возврат тзДанные;
КонецФункции

Функция СформироватьТаблицу_Услуги(СтруктураШД, Отказ, Заголовок)
	Если НЕ СтруктураШД.ВидДоговора=Неопределено И (СтруктураШД.ВидДоговора=Перечисления.ВидыДоговоровКонтрагентов.СКомитентом Или ДоговорКонтрагента.ВидДоговора=Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Документ передачи на комиссию не может содержать услуг!", Отказ, Заголовок);
	КонецЕсли;

	тзДанные=Услуги.Выгрузить();	
	Для каждого СтрокаКоллекции Из тзДанные Цикл
		стрНачалоСообщения="В строке номер """+СокрЛП(СтрокаКоллекции.НомерСтроки)+""" табличной части ""Услуги"": ";
		Если НЕ СтрокаКоллекции.Номенклатура.Услуга Тогда
			ОбщегоНазначения.СообщитьОбОшибке(стрНачалоСообщения + "содержится номенклатура, не являющаяся услугой. Здесь могут быть только услуги!", Отказ, Заголовок);
		КонецЕсли;
		Если СтрокаКоллекции.Номенклатура.Набор Тогда
			ОбщегоНазначения.СообщитьОбОшибке(стрНачалоСообщения + "содержится набор-пакет. Наборов-пакетов здесь быть не должно!", Отказ, Заголовок);
		КонецЕсли;			
		Если СтрокаКоллекции.Номенклатура.Комплект Тогда
			ОбщегоНазначения.СообщитьОбОшибке(стрНачалоСообщения + "содержится набор-комплект. Наборов-комплектов здесь быть не должно!", Отказ, Заголовок);
		КонецЕсли;
	КонецЦикла;

	Возврат тзДанные;	
КонецФункции

Функция СформироватьТаблицу_ТараВТ(СтруктураШД, Отказ, Заголовок)
	тзДанные=ВозвратнаяТара.Выгрузить();
	Для каждого СтрокаКоллекции Из тзДанные Цикл
		стрНачалоСообщения="В строке номер """+СокрЛП(СтрокаКоллекции.НомерСтроки)+""" табличной части ""Возвратная тара"": ";
		Если СтрокаКоллекции.Номенклатура.Набор Тогда
			ОбщегоНазначения.СообщитьОбОшибке(стрНачалоСообщения + "содержится набор-пакет. Наборов-пакетов здесь быть не должно!", Отказ, Заголовок);
		КонецЕсли;
		Если СтрокаКоллекции.Номенклатура.Услуга Тогда
			ОбщегоНазначения.СообщитьОбОшибке(стрНачалоСообщения + "содержится услуга. Услуг здесь быть не должно!", Отказ, Заголовок);
		КонецЕсли;
		Если СтрокаКоллекции.Номенклатура.Комплект Тогда
			ОбщегоНазначения.СообщитьОбОшибке(стрНачалоСообщения + "содержится набор-комплект. Наборов-комплектов здесь быть не должно!", Отказ, Заголовок);
		КонецЕсли;
	КонецЦикла;

	Возврат тзДанные;	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Движения по регистрам 

Процедура ДвиженияПоРегистрам(СтруктураШД, СтруктураТД, Отказ)
	ДвижениеПоРегистру_ЗаказыПоставщикам(СтруктураШД, СтруктураТД, Отказ);	
КонецПроцедуры

Процедура ДвижениеПоРегистру_ЗаказыПоставщикам(СтруктураШД, СтруктураТД, Отказ)	
	тзДвижения=Движения.ЗаказыПоставщикам.ВыгрузитьКолонки();

	Для каждого СтрокаКоллекции Из СтруктураТД.Товары Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);	
		НоваяСтрока.ЗаказОснование=СтрокаКоллекции.Заказ;
		Если НЕ ЗначениеЗаполнено(НоваяСтрока.ЗаказОснование) Тогда
			НоваяСтрока.ЗаказОснование=ДокументОснование;
		КонецЕсли;
	КонецЦикла;

	Для каждого СтрокаКоллекции Из СтруктураТД.Услуги Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);	
		Если НЕ ЗначениеЗаполнено(НоваяСтрока.ЗаказОснование) Тогда
			НоваяСтрока.ЗаказОснование=ДокументОснование;
		КонецЕсли;
	КонецЦикла;
	
	Для каждого СтрокаКоллекции Из СтруктураТД.ВозвратнаяТара Цикл
		НоваяСтрока=тзДвижения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);	
		НоваяСтрока.ЗаказОснование=СтрокаКоллекции.Заказ;
		Если НЕ ЗначениеЗаполнено(НоваяСтрока.ЗаказОснование) Тогда
			НоваяСтрока.ЗаказОснование=ДокументОснование;
		КонецЕсли;		
	КонецЦикла; 
	
	тзДвижения.ЗаполнитьЗначения(Дата, "Период");
	тзДвижения.ЗаполнитьЗначения(Истина, "Активность");	
	тзДвижения.ЗаполнитьЗначения(Организация, "Организация");
	тзДвижения.ЗаполнитьЗначения(Ссылка, "ЗаказПоставщику");
	тзДвижения.ЗаполнитьЗначения(ДоговорКонтрагента, "ДоговорКонтрагента");
	
	Движения.ЗаказыПоставщикам.Загрузить(тзДвижения);
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

Процедура ОбработкаЗаполнения(Основание)
	Если Не ЗаполнениеДокументов.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание) Тогда Возврат; КонецЕсли;

	Если ТипЗнч(Основание)=Тип("ДокументСсылка.ЗаказНаПроизводство") Тогда
		ОсновнаяСтавкаНДС=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнаяСтавкаНДС");
		Если НЕ ЗначениеЗаполнено(ОсновнаяСтавкаНДС) Тогда
			ОсновнаяСтавкаНДС=Перечисления.СтавкиНДС.НДС20;
		КонецЕсли; 
		Для Каждого СтрокаТабличнойЧасти Из Основание.Комплектующие Цикл
			НоваяСтрока=Товары.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТабличнойЧасти);
			НоваяСтрока.СтавкаНДС=ОсновнаяСтавкаНДС;
			ОбработкаТабличныхЧастей.РассчитатьСуммуНДСТабЧасти(НоваяСтрока, ЭтотОбъект);
		КонецЦикла;
	Иначе
		ЗаполнениеДокументов.ЗаполнитьТабличныеЧастиДокументаПоОснованию(ЭтотОбъект, Основание);
	КонецЕсли;

	//Договор по умолчанию (если договор основания не проходит по виду договора)
	МассивВидовДоговора=Новый Массив; ЗаполнитьДоговорПоУмолчанию=Ложь;
	МассивВидовДоговора.Вставить(Перечисления.ВидыДоговоровКонтрагентов.СКомитентом);
	МассивВидовДоговора.Вставить(Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком);
	
	Если ЗначениеЗаполнено(ДоговорКонтрагента) Тогда
		Если МассивВидовДоговора.Найти(ДоговорКонтрагента.ВидДоговора)=Неопределено Тогда
			ЗаполнитьДоговорПоУмолчанию=Истина;
		КонецЕсли;
	Иначе
		ЗаполнитьДоговорПоУмолчанию=Истина;
	КонецЕсли;

	Если ЗаполнитьДоговорПоУмолчанию Тогда
		СтруктураПраметров=Новый Структура;
		СтруктураПраметров.Вставить("Организация", Организация);
		СтруктураПраметров.Вставить("Контрагент", Контрагент);
		СтруктураПраметров.Вставить("ВидДоговора", МассивВидовДоговора);
	    ДоговорКонтрагента=УправлениеДиалогамиСервер.ДоступныеДоговорыКонтрагента(СтруктураПраметров, Истина);				
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Заголовок=ЗаполнениеДокументов.ПредставлениеДокументаПриПроведении(ЭтотОбъект);

	//Автозаполнение ревизитов шапки\табличных частей
	АвтоЗаполнениеРеквизитовДокумента();

	//Формирование значений реквизитов шапки документа
	СтруктураШД=УправлениеДокументамиСервер.СформироватьСтруктуруШД(ЭтотОбъект);

	//Проверка значений реквизитов шапки документа
	ВзаиморасчетыСервер.ПроверитьСоответствиеОрганизацииДоговоруВзаиморасчетов(Организация, ДоговорКонтрагента, СтруктураШД.ДоговорОрганизация, Отказ, Заголовок);
	
	//Формирование значений табличный частей документа
	СтруктураТД=Новый Структура;
	СтруктураТД.Вставить("Товары"		 , СформироватьТаблицу_Товары(СтруктураШД, Отказ, Заголовок));
	СтруктураТД.Вставить("Услуги"		 , СформироватьТаблицу_Услуги(СтруктураШД, Отказ, Заголовок));
	СтруктураТД.Вставить("ВозвратнаяТара", СформироватьТаблицу_ТараВТ(СтруктураШД, Отказ, Заголовок));

	//Прочие проверки	
	Если Товары.Количество() > 0 ИЛИ ВозвратнаяТара.Количество() > 0 Тогда
		ПроверяемыеРеквизиты.Добавить("Склад");
	КонецЕсли;
	
	Если УчитыватьНДС Тогда
		ПроверяемыеРеквизиты.Добавить("Товары.СтавкаНДС");
		ПроверяемыеРеквизиты.Добавить("Услуги.СтавкаНДС");
	КонецЕсли;

	УправлениеЗапасами.КорректировкаМассиваОбязательныхПолей(ЭтотОбъект, "Товары"		 , ПроверяемыеРеквизиты, Склад.ВидСклада);
	УправлениеЗапасами.КорректировкаМассиваОбязательныхПолей(ЭтотОбъект, "Услуги"		 , ПроверяемыеРеквизиты, Склад.ВидСклада);
	УправлениеЗапасами.КорректировкаМассиваОбязательныхПолей(ЭтотОбъект, "ВозвратнаяТара", ПроверяемыеРеквизиты, Склад.ВидСклада);
	
	//Инициализация доп.свойств документа	
    ДополнительныеСвойства.Вставить("Заголовок", Заголовок);
	ДополнительныеСвойства.Вставить("СтруктураШД", СтруктураШД);
	ДополнительныеСвойства.Вставить("СтруктураТД", СтруктураТД);	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства);