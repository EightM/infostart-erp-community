﻿Функция ПараметрыУчетнойПолитики(Переписать=Ложь) Экспорт

	Если Переписать=Ложь Тогда
		Переписать=?(ДополнительныеСвойства.УчетнаяПолитика=Неопределено, Истина, Ложь);
	КонецЕсли;

	Если Переписать Тогда
		ДополнительныеСвойства.УчетнаяПолитика=ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитики(?(ЭтоНовый(), ТекущаяДата(), Дата), Ложь, Организация);
	КонецЕсли;

	Возврат ДополнительныеСвойства.УчетнаяПолитика;

КонецФункции

//Процедура заполнения табличной части по данным подсистемы НДС
Процедура ЗаполнитьСтрокиДокумента() Экспорт
	
	ТаблицаВосстановления = Состав.ВыгрузитьКолонки();
	
	Дерево_НДСДляВосстановления = ЗаполнитьПоДаннымОперативныхРегистровНДС();
	Если Дерево_НДСДляВосстановления.Строки.Количество() = 0 Тогда
		// Не обнаружен НДС к восстановлению.
		Состав.Очистить();
		Возврат;
	КонецЕсли; 
	
	СписокСчетовФактур = ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(Дерево_НДСДляВосстановления.Строки.ВыгрузитьКолонку("СчетФактура"),Истина);
	
	ЗаписиКнигиПокупок = ПолучитьЗаписиКнигиПокупокПоСпискуСФ(СписокСчетовФактур);

	ОпределитьДатуОплатыПоЗаписямКнигиПокупок(Дерево_НДСДляВосстановления, ТаблицаВосстановления, СписокСчетовФактур, ЗаписиКнигиПокупок);
	Для каждого СтрокаВосстановления Из ТаблицаВосстановления Цикл
		ТипСФ = ТипЗнч(СтрокаВосстановления.СчетФактура);
		Если ТипСФ = Тип("ДокументСсылка.ВозвратТоваровПоставщику") Тогда
		    СтрокаВосстановления.НеСохранятьРаспределениеОплат = Истина;
		КонецЕсли; 
		Если ОтразитьВКнигеПродаж Тогда
			СтрокаВосстановления.КодВидаОперации="21";
		Иначе
			СтрокаВосстановления.КодВидаОперации="25";
		КонецЕсли;	
	КонецЦикла; 
	
	Состав.Загрузить(ТаблицаВосстановления);
	
КонецПроцедуры

Функция ЗаполнитьПоДаннымОперативныхРегистровНДС()
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОстаткиНДСКВычету.Организация,
	|	ОстаткиНДСКВычету.СчетФактура КАК СчетФактура,
	|	ОстаткиНДСКВычету.ВидЦенности,
	|	ОстаткиНДСКВычету.СтавкаНДС,
	|	СУММА(-ОстаткиНДСКВычету.СуммаБезНДСОстаток) КАК СуммаБезНДС,
	|	СУММА(-ОстаткиНДСКВычету.НДСОстаток) КАК НДС,
	|	СУММА(-ОстаткиНДСКВычету.СуммаБезНДСОстаток - ОстаткиНДСКВычету.НДСОстаток) КАК СуммаСНДС_КВычету,
	|	ОстаткиНДСКВычету.СчетФактураДата КАК СчетФактураДата,
	|	ЕСТЬNULL(ОстаткиНДСКВычету.СчетФактура.Контрагент, НЕОПРЕДЕЛЕНО) КАК СчетФактураКонтрагент,
	|	ВЫБОР
	|		КОГДА ОстаткиНДСКВычету.СчетФактура.Контрагент ЕСТЬ NULL 
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК СчетФактураСодержитКонтрагента
	|ИЗ
	|	(ВЫБРАТЬ
	|		НДСПредъявленныйОстатки.Организация КАК Организация,
	|		НДСПредъявленныйОстатки.СчетФактура КАК СчетФактура,
	|		НДСПредъявленныйОстатки.ВидЦенности КАК ВидЦенности,
	|		НДСПредъявленныйОстатки.СтавкаНДС КАК СтавкаНДС,
	|		НДСПредъявленныйОстатки.СуммаБезНДСОстаток КАК СуммаБезНДСОстаток,
	|		НДСПредъявленныйОстатки.НДСОстаток КАК НДСОстаток,
	|		НДСПредъявленныйОстатки.СчетФактура.Дата КАК СчетФактураДата
	|	ИЗ
	|		РегистрНакопления.НДСПредъявленный.Остатки(&КонецПериода, Организация = &Организация) КАК НДСПредъявленныйОстатки
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		НДСПредъявленныйРеализация0Остатки.Организация,
	|		НДСПредъявленныйРеализация0Остатки.СчетФактура,
	|		НДСПредъявленныйРеализация0Остатки.ВидЦенности,
	|		НДСПредъявленныйРеализация0Остатки.СтавкаНДС,
	|		-НДСПредъявленныйРеализация0Остатки.СуммаБезНДСОстаток,
	|		-НДСПредъявленныйРеализация0Остатки.НДСОстаток,
	|		НДСПредъявленныйРеализация0Остатки.СчетФактура.Дата
	|	ИЗ
	|		РегистрНакопления.НДСПредъявленныйРеализация0.Остатки(
	|			&КонецПериода,
	|			Организация = &Организация
	|				И (НЕ ВидЦенности В (&ИсключаемыеВидыЦенностей))) КАК НДСПредъявленныйРеализация0Остатки) КАК ОстаткиНДСКВычету
	|
	|СГРУППИРОВАТЬ ПО
	|	ОстаткиНДСКВычету.СтавкаНДС,
	|	ОстаткиНДСКВычету.СчетФактура,
	|	ОстаткиНДСКВычету.ВидЦенности,
	|	ОстаткиНДСКВычету.Организация,
	|	ОстаткиНДСКВычету.СчетФактураДата,
	|	ЕСТЬNULL(ОстаткиНДСКВычету.СчетФактура.Контрагент, НЕОПРЕДЕЛЕНО),
	|	ВЫБОР
	|		КОГДА ОстаткиНДСКВычету.СчетФактура.Контрагент ЕСТЬ NULL 
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ
	|
	|ИМЕЮЩИЕ
	|	СУММА(ОстаткиНДСКВычету.СуммаБезНДСОстаток) + СУММА(ОстаткиНДСКВычету.НДСОстаток) < 0
	|
	|УПОРЯДОЧИТЬ ПО
	|	СчетФактураДата
	|ИТОГИ
	|	СУММА(СуммаБезНДС),
	|	СУММА(НДС),
	|	СУММА(СуммаСНДС_КВычету)
	|ПО
	|	СчетФактура";

	Запрос.УстановитьПараметр("Организация",  Организация);
	Запрос.УстановитьПараметр("КонецПериода", Новый	Граница(КонецДня(Дата), ВидГраницы.Включая));
	
	// Исключаемые из анализа виды ценностей
	ИсключаемыеВидыЦенностей = Новый СписокЗначений;
	ИсключаемыеВидыЦенностей.Добавить(Перечисления.ВидыЦенностей.АвансыПолученные);
	ИсключаемыеВидыЦенностей.Добавить(Перечисления.ВидыЦенностей.АвансыПолученные0);
	
	Запрос.УстановитьПараметр("ИсключаемыеВидыЦенностей", ИсключаемыеВидыЦенностей);
	
	ДеревоРезультата = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	// Определение поставщика
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Организация"		, Организация);
	Запрос.УстановитьПараметр("СчетаФактуры"	, ДеревоРезультата.Строки.ВыгрузитьКолонку("СчетФактура"));
	Запрос.УстановитьПараметр("ПустойКонтрагент", Справочники.Контрагенты.ПустаяСсылка());
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НДСПредъявленныйОбороты.Поставщик,
	|	НДСПредъявленныйОбороты.СчетФактура
	|ИЗ
	|	РегистрНакопления.НДСПредъявленный.Обороты(
	|		,
	|		,
	|		,
	|		Организация = &Организация
	|		    И СчетФактура В (&СчетаФактуры)) КАК НДСПредъявленныйОбороты
	|ГДЕ
	|	НДСПредъявленныйОбороты.Поставщик <> &ПустойКонтрагент";
	
	КонтрагентПоСчетуФактуре = Запрос.Выполнить().Выгрузить();
	
	ДеревоРезультата.Колонки.Добавить("Поставщик", Новый ОписаниеТипов("СправочникСсылка.Контрагенты"));
	
	Для каждого СтрокаОбрабатываемая  Из ДеревоРезультата.Строки Цикл
		СтрокаКонтрагента = КонтрагентПоСчетуФактуре.Найти(СтрокаОбрабатываемая.СчетФактура,"СчетФактура");
		Если не СтрокаКонтрагента = Неопределено Тогда
		    СтрокаОбрабатываемая.Поставщик = СтрокаКонтрагента.Поставщик;
			Для каждого СтрокаРасшифровки Из СтрокаОбрабатываемая.Строки Цикл
				СтрокаРасшифровки.Поставщик = СтрокаОбрабатываемая.Поставщик;
			КонецЦикла; 
		ИначеЕсли СтрокаОбрабатываемая.СчетФактураСодержитКонтрагента Тогда
			СтрокаОбрабатываемая.Поставщик = СтрокаОбрабатываемая.СчетФактураКонтрагент;
			Для каждого СтрокаРасшифровки Из СтрокаОбрабатываемая.Строки Цикл
				СтрокаРасшифровки.Поставщик = СтрокаОбрабатываемая.Поставщик;
			КонецЦикла; 
		КонецЕсли; 
	КонецЦикла;
	
	Возврат ДеревоРезультата;

КонецФункции

// Процедура вызывается из ЗаполнитьСтрокиДокумента.
// По списку счетов-фактур определяет суммы не использованных ранее распределенных оплат.
Функция ПолучитьЗаписиКнигиПокупокПоСпискуСФ(СписокСчетовФактур)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НДСЗаписиКнигиПокупокОбороты.Поставщик КАК Поставщик,
	|	НДСЗаписиКнигиПокупокОбороты.СчетФактура КАК СчетФактура,
	|	НДСЗаписиКнигиПокупокОбороты.ВидЦенности,
	|	НДСЗаписиКнигиПокупокОбороты.СтавкаНДС,
	|	НДСЗаписиКнигиПокупокОбороты.ДатаОплаты КАК ДатаОплаты,
	|	НДСЗаписиКнигиПокупокОбороты.ДокументОплаты КАК ДокументОплаты,
	|	СУММА(НДСЗаписиКнигиПокупокОбороты.СуммаБезНДСОборот) КАК СуммаБезНДС,
	|	СУММА(НДСЗаписиКнигиПокупокОбороты.НДСОборот) КАК НДС,
	|	НДСЗаписиКнигиПокупок.Период КАК КорректируемыйПериод
	|ИЗ
	|	РегистрНакопления.НДСЗаписиКнигиПокупок.Обороты(
	|		,
	|		&КонецПериода,
	|		Период,
	|		Организация = &Организация
	|			И СчетФактура В (&СписокСчетовФактур)) КАК НДСЗаписиКнигиПокупокОбороты
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.НДСЗаписиКнигиПокупок КАК НДСЗаписиКнигиПокупок
	|		ПО НДСЗаписиКнигиПокупокОбороты.Поставщик = НДСЗаписиКнигиПокупок.Поставщик
	|			И НДСЗаписиКнигиПокупокОбороты.СчетФактура = НДСЗаписиКнигиПокупок.СчетФактура
	|			И НДСЗаписиКнигиПокупокОбороты.ВидЦенности = НДСЗаписиКнигиПокупок.ВидЦенности
	|			И НДСЗаписиКнигиПокупокОбороты.СтавкаНДС = НДСЗаписиКнигиПокупок.СтавкаНДС
	|			И НДСЗаписиКнигиПокупокОбороты.ДатаОплаты = НДСЗаписиКнигиПокупок.ДатаОплаты
	|			И НДСЗаписиКнигиПокупокОбороты.ДокументОплаты = НДСЗаписиКнигиПокупок.ДокументОплаты
	|
	|СГРУППИРОВАТЬ ПО
	|	НДСЗаписиКнигиПокупокОбороты.ВидЦенности,
	|	НДСЗаписиКнигиПокупокОбороты.ДокументОплаты,
	|	НДСЗаписиКнигиПокупокОбороты.СтавкаНДС,
	|	НДСЗаписиКнигиПокупокОбороты.ДатаОплаты,
	|	НДСЗаписиКнигиПокупокОбороты.Поставщик,
	|	НДСЗаписиКнигиПокупокОбороты.СчетФактура,
	|	НДСЗаписиКнигиПокупок.Период
	|
	|УПОРЯДОЧИТЬ ПО
	|	НДСЗаписиКнигиПокупокОбороты.СчетФактура.Дата,
	|	ДатаОплаты,
	|	НДСЗаписиКнигиПокупокОбороты.ДокументОплаты.Дата
	|ИТОГИ
	|	СУММА(СуммаБезНДС),
	|	СУММА(НДС)
	|ПО
	|	СчетФактура";
	
	Запрос.УстановитьПараметр("КонецПериода", 		Новый	Граница(КонецДня(Дата), ВидГраницы.Включая));
	Запрос.УстановитьПараметр("Организация", 		Организация);
	Запрос.УстановитьПараметр("СписокСчетовФактур", СписокСчетовФактур);
	
	ЗаписиКнигиПокупок = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);

	Возврат ЗаписиКнигиПокупок;	

КонецФункции // ПолучитьДанныеОРаспределенныхОплатахПоСпискуСФ()
 
Процедура ОпределитьДатуОплатыПоЗаписямКнигиПокупок(Дерево_НДСДляВосстановления, ТаблицаРезультатов, СписокСчетовФактур, ЗаписиКнигиПокупок)
	
	УчетнаяПолитика=ПараметрыУчетнойПолитики(Истина);
	
	Для каждого СтрокаСФ Из Дерево_НДСДляВосстановления.Строки Цикл
		НаборЗаписейКнигиПокупокПоСФ = ЗаписиКнигиПокупок.Строки.Найти(СтрокаСФ.СчетФактура,"СчетФактура");
		
		Если НаборЗаписейКнигиПокупокПоСФ = Неопределено тогда
			// Сокращеный вариант - записи книги не обнаружены, отражаем по текущим данным,
			// без указания документа и даты оплаты.
			Для каждого ЗаписьПОСФ Из СтрокаСФ.Строки Цикл
				СтрокаРезультата = ТаблицаРезультатов.Добавить();
				СтрокаРезультата.СчетФактура	= ЗаписьПОСФ.СчетФактура;
				СтрокаРезультата.Поставщик		= ЗаписьПОСФ.Поставщик;
				СтрокаРезультата.ВидЦенности	= ЗаписьПОСФ.ВидЦенности;
				СтрокаРезультата.СтавкаНДС		= ЗаписьПОСФ.СтавкаНДС;

				СтрокаРезультата.СуммаБезНДС	= ЗаписьПОСФ.СуммаБезНДС;
				СтрокаРезультата.НДС			= ЗаписьПОСФ.НДС;
				Если Дата >= '20060530' И Не ОтразитьВКнигеПродаж Тогда
					СтрокаРезультата.ЗаписьДополнительногоЛиста = Истина;
					Если ЗаписьПОСФ.СчетФактураДата > '20060101' Тогда
						СтрокаРезультата.КорректируемыйПериод = ЗаписьПОСФ.СчетФактураДата;
					КонецЕсли;
				КонецЕсли;
			
			КонецЦикла; 
			
			Продолжить;
		КонецЕсли;
		
		Для каждого ЗаписьПОСФ Из СтрокаСФ.Строки Цикл
			Отбор = новый Структура("Поставщик, ВидЦенности, СтавкаНДС",ЗаписьПОСФ.Поставщик, ЗаписьПОСФ.ВидЦенности, ЗаписьПОСФ.СтавкаНДС);
			
			ЗаписиКнигиПоОтбору = НаборЗаписейКнигиПокупокПоСФ.Строки.НайтиСтроки(Отбор);
			
			Для каждого СторнируемаяЗаписьКнигиПокупок Из ЗаписиКнигиПоОтбору Цикл
				КВосстановлению_БезНДС = макс(0,мин(ЗаписьПОСФ.СуммаБезНДС, СторнируемаяЗаписьКнигиПокупок.СуммаБезНДС));
				КВосстановлению_НДС = макс(0,мин(ЗаписьПОСФ.НДС, СторнируемаяЗаписьКнигиПокупок.НДС));
				Если КВосстановлению_БезНДС =0 и КВосстановлению_НДС =0 Тогда
				    Продолжить;
				КонецЕсли; 
				
				СтрокаРезультата = ТаблицаРезультатов.Добавить();
				СтрокаРезультата.СчетФактура	= ЗаписьПОСФ.СчетФактура;
				СтрокаРезультата.Поставщик		= ЗаписьПОСФ.Поставщик;
				СтрокаРезультата.ВидЦенности	= ЗаписьПОСФ.ВидЦенности;
				СтрокаРезультата.СтавкаНДС		= ЗаписьПОСФ.СтавкаНДС;

				СтрокаРезультата.СуммаБезНДС	= КВосстановлению_БезНДС;
				СтрокаРезультата.НДС			= КВосстановлению_НДС;
				
				СтрокаРезультата.ДатаОплаты		= СторнируемаяЗаписьКнигиПокупок.ДатаОплаты;
				СтрокаРезультата.ДокументОплаты	= СторнируемаяЗаписьКнигиПокупок.ДокументОплаты;
				
				Если Не ОтразитьВКнигеПродаж Тогда
					СтрокаРезультата.ЗаписьДополнительногоЛиста = Истина;
					Если ЗаписьПОСФ.СчетФактураДата < '20060101' Тогда
						СтрокаРезультата.КорректируемыйПериод = ?(НЕ ЗначениеЗаполнено(СторнируемаяЗаписьКнигиПокупок.ДатаОплаты), '00010101', 
																	Макс(ЗаписьПОСФ.СчетФактураДата, СторнируемаяЗаписьКнигиПокупок.ДатаОплаты));
					Иначе										
						СтрокаРезультата.КорректируемыйПериод = ЗаписьПОСФ.СчетФактураДата;
					КонецЕсли;
					Если ?(УчетнаяПолитика.НДСНалоговыйПериод=Перечисления.Периодичность.Месяц, 
							КонецМесяца(СтрокаРезультата.КорректируемыйПериод) = КонецМесяца(Дата),
							КонецКвартала(СтрокаРезультата.КорректируемыйПериод) = КонецКвартала(Дата)) Тогда
						СтрокаРезультата.ЗаписьДополнительногоЛиста = Ложь;
						СтрокаРезультата.КорректируемыйПериод = '00010101';
					КонецЕсли;
				КонецЕсли;
				
				ЗаписьПОСФ.СуммаБезНДС						= ЗаписьПОСФ.СуммаБезНДС - КВосстановлению_БезНДС;
				ЗаписьПОСФ.НДС								= ЗаписьПОСФ.НДС - КВосстановлению_НДС;
				
				СторнируемаяЗаписьКнигиПокупок.СуммаБезНДС	= СторнируемаяЗаписьКнигиПокупок.СуммаБезНДС - КВосстановлению_БезНДС;
				СторнируемаяЗаписьКнигиПокупок.НДС 			= СторнируемаяЗаписьКнигиПокупок.НДС - КВосстановлению_НДС;
				
			КонецЦикла; 
			
			Если ЗаписьПОСФ.СуммаБезНДС>0 или ЗаписьПОСФ.НДС>0 Тогда
			
				СтрокаРезультата = ТаблицаРезультатов.Добавить();
				СтрокаРезультата.СчетФактура	= ЗаписьПОСФ.СчетФактура;
				СтрокаРезультата.Поставщик		= ЗаписьПОСФ.Поставщик;
				СтрокаРезультата.ВидЦенности	= ЗаписьПОСФ.ВидЦенности;
				СтрокаРезультата.СтавкаНДС		= ЗаписьПОСФ.СтавкаНДС;
				Если Дата >= '20060530' И Не ОтразитьВКнигеПродаж Тогда
					СтрокаРезультата.ЗаписьДополнительногоЛиста = Истина;
					Если ЗаписьПОСФ.СчетФактураДата >= '20060101' Тогда
						СтрокаРезультата.КорректируемыйПериод = ЗаписьПОСФ.СчетФактураДата;
					КонецЕсли;
				КонецЕсли;

				СтрокаРезультата.СуммаБезНДС	= ЗаписьПОСФ.СуммаБезНДС;
				СтрокаРезультата.НДС			= ЗаписьПОСФ.НДС;

			КонецЕсли; 
			
		КонецЦикла;	
			
	КонецЦикла;	
	
КонецПроцедуры // РаспределитьОплатыПоДеревуСФ()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
//
Функция ПодготовитьТаблицуВосстановления(РезультатЗапроса)

	ТаблицаВосстановления = РезультатЗапроса.Выгрузить();
	ТаблицаВосстановления.Колонки.Добавить("СчетУчетаНДС");
	
	Для Каждого СтрокаТЧ Из ТаблицаВосстановления Цикл
		Если Не СтрокаТЧ.ЗаписьДополнительногоЛиста Тогда
			СтрокаТЧ.КорректируемыйПериод =  '00010101000000';
		КонецЕсли;
		
		Для каждого СтрокаПроводки Из СтрокаТЧ.ТОП.ПроводкиБУ Цикл
			СчетКредит=СтрокаПроводки.СчетКредит;
			Если ЗначениеЗаполнено(СчетКредит) И СчетКредит.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.НДСпоПриобретеннымЦенностям) Тогда
				СтрокаТЧ.СчетУчетаНДС=СчетКредит; Прервать;
			КонецЕсли;
			СчетДебет=СтрокаПроводки.СчетДебет;			
			Если ЗначениеЗаполнено(СчетДебет) И СчетДебет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.НДСпоПриобретеннымЦенностям) Тогда
				СтрокаТЧ.СчетУчетаНДС=СчетДебет; Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат ТаблицаВосстановления;

КонецФункции // ПодготовитьТаблицуПоОплатам()

// Проверяет правильность заполнения строк табличной части.
//
//
Процедура ПроверитьЗаполнениеТабличнойЧастиСостав(ТаблицаВосстановления, Отказ, Заголовок)
	// При установленном флаге "ЗаписьДополнительногоЛиста" должен быть заполнен реквизит "КорректируемыйПериод"
	Для Каждого СтрокаТЧ Из Состав Цикл
		СтрокаНачалаСообщенияОбОшибке="В строке номер """+СокрЛП(СтрокаТЧ.НомерСтроки)+""" табличной части ""Состав"": ";
		Если СтрокаТЧ.ЗаписьДополнительногоЛиста И НЕ ЗначениеЗаполнено(СтрокаТЧ.КорректируемыйПериод) Тогда
			СтрокаСообщения = "Не заполнено значение реквизита ""Корректируемый период""!";
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + СтрокаСообщения, Отказ, Заголовок);
		КонецЕсли;	
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьПараметрыРасчетовПоСчетуФактуре(СчетФактура, ПараметрыСчетовФактур) 
	Если ПараметрыСчетовФактур = неопределено Тогда
		ПараметрыСчетовФактур= новый Соответствие;
	КонецЕсли; 
	
	ПараметрыСФ = ПараметрыСчетовФактур[СчетФактура];
	
	Если ПараметрыСФ = Неопределено Тогда
		 СтруктураПараметров = Новый Структура();
		 
		 ПараметрыСФ = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(СчетФактура);
		 Если ПараметрыСФ.Свойство("ДоговорКонтрагента") Тогда
		 	СтруктураПараметров.Вставить("ДоговорКонтрагента",ПараметрыСФ.ДоговорКонтрагента);
			Если ПараметрыСФ.Свойство("ВалютаВзаиморасчетов") Тогда
			 	СтруктураПараметров.Вставить("ВалютаВзаиморасчетов",ПараметрыСФ.ВалютаВзаиморасчетов);
			Иначе 
				СтруктураПараметров.Вставить("ВалютаВзаиморасчетов",СтруктураПараметров.ДоговорКонтрагента.ВалютаВзаиморасчетов);
			КонецЕсли;
			Если ПараметрыСФ.Свойство("КурсВзаиморасчетов") Тогда
			 	СтруктураПараметров.Вставить("КурсВзаиморасчетов",ПараметрыСФ.КурсВзаиморасчетов);
			Иначе
				СтруктураПараметров.Вставить("КурсВзаиморасчетов",ЗаполнениеДокументов.КурсДокумента(СчетФактура,ДополнительныеСвойства.ВалютаБухУчета));
			КонецЕсли;
			
			Если ПараметрыСФ.Свойство("КратностьВзаиморасчетов") Тогда
			 	СтруктураПараметров.Вставить("КратностьВзаиморасчетов",ПараметрыСФ.КратностьВзаиморасчетов);
			Иначе
				СтруктураПараметров.Вставить("КратностьВзаиморасчетов",ЗаполнениеДокументов.КратностьДокумента(СчетФактура,ДополнительныеСвойства.ВалютаБухУчета));
			КонецЕсли;
			ПараметрыСчетовФактур.Вставить(СчетФактура,СтруктураПараметров);
			 
			ПараметрыСФ = СтруктураПараметров;
		 Иначе
			 // Невозможно определить договор. Нужные параметры не могут быть собраны.
			 ПараметрыСчетовФактур.Вставить(СчетФактура,Ложь);
			 ПараметрыСФ = Неопределено;
		 КонецЕсли; 
		 
	ИначеЕсли ПараметрыСФ = Ложь тогда
		ПараметрыСФ = Неопределено;
	КонецЕсли; 
	
	Возврат ПараметрыСФ;
	
КонецФункции

// По результату запроса по шапке документа формируем движения по регистрам.
//
//
Процедура ДвиженияПоРегистрам(СтруктураШД, ТаблицаВосстановления, Отказ, Заголовок) Экспорт
	Перем ПараметрыСчетовФактур;
	
	Если ТаблицаВосстановления.Количество()=0 Тогда Возврат; КонецЕсли; 
	
	Если СтруктураШД.ОтразитьВКнигеПродаж Тогда
		//////////////////////////////////////////////////////
		// Восстановление в книге продаж
		ТаблицаДвижений_НДСЗаписиКнигиПродаж = Движения.НДСЗаписиКнигиПродаж.Выгрузить();
		СоответствиеКолонок = Новый Структура("Покупатель ,СуммаБезНДС ,НДС", "Поставщик","СуммаБезНДСКнигаПродаж","НДСКнигаПродаж");
		ТаблицаДвижений_НДСЗаписиКнигиПродаж.Очистить();
		
		УчетНДС.ПереименованиеКолонок(ТаблицаДвижений_НДСЗаписиКнигиПродаж, СоответствиеКолонок );
		
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаВосстановления, ТаблицаДвижений_НДСЗаписиКнигиПродаж);
		ТаблицаДвижений_НДСЗаписиКнигиПродаж.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПродажи.ВосстановлениеНДС,"Событие");
		ТаблицаДвижений_НДСЗаписиКнигиПродаж.ЗаполнитьЗначения(СтруктураШД.Дата,"ДатаСобытия");
		
		УчетНДС.ПереименованиеКолонок(ТаблицаДвижений_НДСЗаписиКнигиПродаж, СоответствиеКолонок, Истина);
			
		Движения.НДСЗаписиКнигиПродаж.мПериод = СтруктураШД.Дата;
		Движения.НДСЗаписиКнигиПродаж.мТаблицаДвижений = ТаблицаДвижений_НДСЗаписиКнигиПродаж;
		Движения.НДСЗаписиКнигиПродаж.ДобавитьДвижение();
		// Восстановление в книге продаж
		//////////////////////////////////////////////////////
	
	Иначе
		//////////////////////////////////////////////////////
		// Сторнирование записей книги покупок
		ТаблицаДвижений_НДСЗаписиКнигиПокупок = Движения.НДСЗаписиКнигиПокупок.ВыгрузитьКолонки();
		ТаблицаДвижений_НДСЗаписиКнигиПокупок.Индексы.Добавить("ЗаписьДополнительногоЛиста");
			
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаВосстановления, ТаблицаДвижений_НДСЗаписиКнигиПокупок);
		ТаблицаДвижений_НДСЗаписиКнигиПокупок.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПокупки.ВосстановленНДС,"Событие");
		ТаблицаДвижений_НДСЗаписиКнигиПокупок.ЗаполнитьЗначения(СтруктураШД.Дата,"ДатаСобытия");
			
		// Событие для восстановления определяется по признаку записи доп. листа
		// В декларациях старых периодов это будет отражаться как уменьшение суммы вычета
		ЗаписиДопЛистов = ТаблицаДвижений_НДСЗаписиКнигиПокупок.НайтиСтроки(Новый Структура("ЗаписьДополнительногоЛиста", Истина));
		Для каждого СтрокаЗаписиКниги Из ЗаписиДопЛистов Цикл
			СтрокаЗаписиКниги.Событие = Перечисления.СобытияПоНДСПокупки.ПредъявленНДСКВычету;
		КонецЦикла; 
		
		Движения.НДСЗаписиКнигиПокупок.мПериод = СтруктураШД.Дата;
		Движения.НДСЗаписиКнигиПокупок.мТаблицаДвижений = ТаблицаДвижений_НДСЗаписиКнигиПокупок;
		Движения.НДСЗаписиКнигиПокупок.ДобавитьДвижение();
		// Сторнирование записей книги покупок
		//////////////////////////////////////////////////////
	КонецЕсли;
	
	//////////////////////////////////////////////////////
	// Сторнирование расхода по регистру НДС предъявленный
	ТаблицаДвижений_НДСПредъявленный = Движения.НДСПредъявленный.ВыгрузитьКолонки();
		
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаВосстановления, ТаблицаДвижений_НДСПредъявленный);
	ТаблицаДвижений_НДСПредъявленный.ЗаполнитьЗначения(Перечисления.СобытияПоНДСПокупки.ВосстановленНДС,"Событие");
	ТаблицаДвижений_НДСПредъявленный.ЗаполнитьЗначения(СтруктураШД.Дата,"ДатаСобытия");
		
	Движения.НДСПредъявленный.мПериод 		   = СтруктураШД.Дата;
	Движения.НДСПредъявленный.мТаблицаДвижений = ТаблицаДвижений_НДСПредъявленный;
	Движения.НДСПредъявленный.ВыполнитьРасход();
	// Сторнирование записей книги покупок
	/////////////////////////////////////////////////
		
	// Виды ценностей с особым порядком распределения оплат - по НДС выплаченному в бюджет
	ВидыЦенностей_ОплатаПоНДС = Новый СписокЗначений;
	ВидыЦенностей_ОплатаПоНДС.Добавить(Перечисления.ВидыЦенностей.НалоговыйАгентАренда);
	ВидыЦенностей_ОплатаПоНДС.Добавить(Перечисления.ВидыЦенностей.НалоговыйАгентИностранцы);
		
	// Виды ценностей с особым порядком распределения оплат - оплата не определяется
	ВидыЦенностей_БезОплаты = Новый СписокЗначений;
	ВидыЦенностей_БезОплаты.Добавить(Перечисления.ВидыЦенностей.ТаможенныеПлатежи);
	ВидыЦенностей_БезОплаты.Добавить(Перечисления.ВидыЦенностей.АвансыПолученные);
	ВидыЦенностей_БезОплаты.Добавить(Перечисления.ВидыЦенностей.АвансыПолученные0);
		
	// получаем таблицу идентичную по структуре движениям регистра "НДСРасчетыСПоставщиками"
	
	ТаблицаДвижения_НДСРасчетыСПоставщиками = Движения.НДСРасчетыСПоставщиками.ВыгрузитьКолонки();
	
	Для Каждого Строка Из ТаблицаВосстановления Цикл
		Если (Строка.СуммаБезНДС = 0) и (Строка.НДС = 0) Тогда продолжить; КонецЕсли;
		
		/////////////////////////////////////////////////
		// Сторнирование зачета оплат
		Если не ВидыЦенностей_БезОплаты.НайтиПоЗначению(Строка.ВидЦенности) = Неопределено  Тогда
			// Восстановление НДС по указанному виду ценности не влияет на расчеты.
		Иначе
			Если Строка.НеСохранятьРаспределениеОплат тогда
				//Получим информацию по счету-фактуре
				ПараметрыСчетаФактуры = ПолучитьПараметрыРасчетовПоСчетуФактуре(Строка.СчетФактура,ПараметрыСчетовФактур);
				
				Если ПараметрыСчетаФактуры = Неопределено Тогда
				    Строка.НеСохранятьРаспределениеОплат = Ложь;
					ОбщегоНазначения.СообщитьОбОшибке("Не хватает информации для выделения задолженности по строке № "+Строка.НомерСтроки+". Фиксируется распределенная оплата.",, Заголовок, СтатусСообщения.Внимание);
				Иначе
					//Выделение задолженности
					СтрокаДвижения = ТаблицаДвижения_НДСРасчетыСПоставщиками.Добавить();

					СтрокаДвижения.Период       = СтруктураШД.Дата;
					СтрокаДвижения.Организация  = СтруктураШД.Организация;
					СтрокаДвижения.Поставщик    = Строка.Поставщик;
					СтрокаДвижения.ДоговорКонтрагента    = ПараметрыСчетаФактуры.ДоговорКонтрагента;
					
					СтрокаДвижения.Документ  	= Строка.СчетФактура;
						
					Если ВидыЦенностей_ОплатаПоНДС.НайтиПоЗначению(Строка.ВидЦенности) = Неопределено  Тогда
						СтрокаДвижения.РасчетыСБюджетом = Ложь;
						СтрокаДвижения.Сумма = Строка.СуммаБезНДС + Строка.НДС;
					Иначе
						СтрокаДвижения.РасчетыСБюджетом = Истина;
						СтрокаДвижения.Сумма = Строка.НДС;
					КонецЕсли;
					СтрокаДвижения.ВидДвижения = ВидДвиженияНакопления.Расход;
					
					//Выделение оплаты
					СтрокаДвиженияОплаты = ТаблицаДвижения_НДСРасчетыСПоставщиками.Добавить();
					ЗаполнитьЗначенияСвойств(СтрокаДвиженияОплаты,СтрокаДвижения);
					
					СтрокаДвиженияОплаты.Документ = Строка.ДокументОплаты;
						
					СтрокаДвиженияОплаты.ВидДвижения = ВидДвиженияНакопления.Приход;
				КонецЕсли; 
			КонецЕсли;
			
		КонецЕсли;
		// Сторнирование зачета оплат
		/////////////////////////////////////////////////
			
	КонецЦикла; // Пока Выборка.Следующий() Цикл

	Если не ТаблицаДвижения_НДСРасчетыСПоставщиками.Количество() = 0 тогда
		ТаблицаДвижения_НДСРасчетыСПоставщиками.ЗаполнитьЗначения(СтруктураШД.Дата,"ДатаСобытия");
		Движения.НДСРасчетыСПоставщиками.мПериод 		   = СтруктураШД.Дата;
		Движения.НДСРасчетыСПоставщиками.мТаблицаДвижений = ТаблицаДвижения_НДСРасчетыСПоставщиками;
		Движения.НДСРасчетыСПоставщиками.ВыполнитьРасход();
	КонецЕсли;
КонецПроцедуры

// Процедура формирует структуру шапки документа и дополнительных полей.
//
Процедура ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШД, Отказ = Ложь) Экспорт
	СтруктураШД = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
КонецПроцедуры

// Процедура формирует таблицы документа, вляиющие на состояние расчетов с контрагентами.
//
Процедура ПодготовитьТаблицыДокумента(СтруктураШД, ТаблицаВосстановления) Экспорт
	
	// Подготовим данные необходимые для проведения и проверки заполнения табличной части.
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Организация",		"Ссылка.Организация");
	СтруктураПолей.Вставить("Поставщик",		"Поставщик");
	СтруктураПолей.Вставить("СчетФактура",		"СчетФактура");
	СтруктураПолей.Вставить("ВидЦенности",		"ВидЦенности");
	СтруктураПолей.Вставить("СтавкаНДС",		"СтавкаНДС");
	СтруктураПолей.Вставить("ДокументОплаты",	"ДокументОплаты");
	СтруктураПолей.Вставить("ДатаОплаты",		"ДатаОплаты");
	СтруктураПолей.Вставить("СуммаБезНДС",		"СуммаБезНДС*(-1)");
	СтруктураПолей.Вставить("НДС",				"НДС*(-1)");
	СтруктураПолей.Вставить("НеСохранятьРаспределениеОплат","НеСохранятьРаспределениеОплат");
	СтруктураПолей.Вставить("ЗаписьДополнительногоЛиста",	"ЗаписьДополнительногоЛиста");
	СтруктураПолей.Вставить("КорректируемыйПериод",			"КорректируемыйПериод");
	СтруктураПолей.Вставить("ТОП",			"ТОП");
	СтруктураПолей.Вставить("КодВидаОперации",			"КодВидаОперации");
	Если СтруктураШД.ОтразитьВКнигеПродаж Тогда
		СтруктураПолей.Вставить("СуммаБезНДСКнигаПродаж",	"СуммаБезНДС");
		СтруктураПолей.Вставить("НДСКнигаПродаж",			"НДС");
	КонецЕсли; 

	РезультатЗапроса = УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "Состав", СтруктураПолей);
	ТаблицаВосстановления = ПодготовитьТаблицуВосстановления(РезультатЗапроса);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Перем СтруктураШД, ТаблицаВосстановления;
	УправлениеДокументамиСервер.ПередПроведением(Отказ, РежимПроведения, ЭтотОбъект);
	Если Отказ Тогда Возврат; КонецЕсли; 

	Заголовок=ДополнительныеСвойства.Заголовок;
	ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШД, Отказ);

	ПодготовитьТаблицыДокумента(СтруктураШД, ТаблицаВосстановления);
	ПроверитьЗаполнениеТабличнойЧастиСостав(ТаблицаВосстановления, Отказ, Заголовок);
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(СтруктураШД, ТаблицаВосстановления, Отказ, Заголовок);
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Операторы основной программы

УправлениеДокументамиСервер.ИнициализацияМодуля(ДополнительныеСвойства, "Продажа");