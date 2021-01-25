﻿Функция АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, стрАтрибут)
	ЕстьРеквизит=УправлениеМетаданными.ЕстьРеквизит(стрАтрибут, МетаданныеДокумента);
	Возврат ?(ЕстьРеквизит, НЕ ЗначениеЗаполнено(ДокументОбъект[стрАтрибут]), Ложь);
КонецФункции

Процедура ЗаполнитьАтрибутыШапкиДокумента(ДокументОбъект) Экспорт
	ТипОперации=""; ДокументОбъект.ДополнительныеСвойства.Свойство("ТипОперации", ТипОперации);
    ТекПользователь=ДокументОбъект.ДополнительныеСвойства.ТекущийПользователь;

	МетаданныеДокумента=ДокументОбъект.Метаданные();

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "Организация") Тогда
		Организация=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнаяОрганизация");
		
		ДокументОбъект.Организация=Организация;
		Если ЗначениеЗаполнено(Организация) Тогда
			ОсновнойБанковскийСчет=УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(Организация, "ОсновнойБанковскийСчет");

			Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "БанковскийСчет") Тогда
				ДокументОбъект.БанковскийСчет=ОсновнойБанковскийСчет;
			КонецЕсли;
			
			Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "СчетОрганизации") Тогда
				ДокументОбъект.СчетОрганизации = ОсновнойБанковскийСчет;
			КонецЕсли;
			
			Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "БанковскийСчетОрганизации") Тогда
				ДокументОбъект.БанковскийСчетОрганизации = ОсновнойБанковскийСчет;
			КонецЕсли;
			
			Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ВалютаДокумента") Тогда
				ДокументОбъект.ВалютаДокумента=УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(ОсновнойБанковскийСчет, "ВалютаДенежныхСредств");
			КонецЕсли;
			
			Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "СтруктурнаяЕдиница") Тогда
				ДокументОбъект.СтруктурнаяЕдиница=ОсновнойБанковскийСчет;
			КонецЕсли;
		КонецЕсли; 		
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "Ответственный") Тогда
		ДокументОбъект.Ответственный=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнойОтветственный");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "Подразделение") Тогда
		ДокументОбъект.Подразделение=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновноеПодразделение");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ДоговорЭквайринга") Тогда
		ДокументОбъект.ДоговорЭквайринга=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнойДоговорЭквайринга");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ВидОперации") Тогда
	   Если МетаданныеДокумента.Имя<>"АктСверкиВзаиморасчетов" Тогда
		   ДокументОбъект.ВидОперации=Перечисления[ДокументОбъект.ВидОперации.Метаданные().Имя][0];
	   КонецЕсли;
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "Склад") Тогда
		ДокументОбъект.Склад=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнойСклад");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "Склад") Тогда
		ДокументОбъект.Склад=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнойСклад");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ВидПоступления") Тогда
		ДокументОбъект.ВидПоступления=Перечисления.ВидыПоступленияТоваров.НаСклад;
	КонецЕсли;
	
	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "КассаККМ") Тогда
		ДокументОбъект.КассаККМ = УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнаяКассаККМ");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "СтавкаНДС") Тогда
		ДокументОбъект.СтавкаНДС=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнаяСтавкаНДС");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ЗанимаемыхСтавок") Тогда
		ДокументОбъект.ЗанимаемыхСтавок = 1;
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ДатаС") Тогда
		ДокументОбъект.ДатаС = ДокументОбъект.Дата;
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ПериодРегистрации") Тогда
		ДокументОбъект.ПериодРегистрации = НачалоМесяца(ТекущаяДата());
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ВидПоступления") Тогда
		ДокументОбъект.ВидПоступления = Перечисления.ВидыПоступленияТоваров.НаСклад;
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ВидПередачи") Тогда
		ДокументОбъект.ВидПередачи = Перечисления.ВидыПередачиТоваров.СоСклада;
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "УсловиеПродаж") Тогда
		ДокументОбъект.УсловиеПродаж = УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновноеУсловиеПродаж");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "Касса") Тогда
		ДокументОбъект.Касса=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнаяКасса");
		Если УправлениеМетаданными.ЕстьРеквизит("ВалютаДокумента", МетаданныеДокумента) Тогда
			ДокументОбъект.ВалютаДокумента=УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(ДокументОбъект.Касса, "ВалютаДенежныхСредств");
		КонецЕсли;
	КонецЕсли;

	Если УправлениеМетаданными.ЕстьРеквизит("Контрагент", МетаданныеДокумента) Тогда 
		флВыполнитьЗаполнениеСтруктуры = Ложь; текКонтрагент=ДокументОбъект.Контрагент;

		Если НЕ ЗначениеЗаполнено(текКонтрагент) Тогда
			Если ТипОперации = "Покупка" Тогда
				текКонтрагент=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнойПоставщик");
			ИначеЕсли ТипОперации = "Продажа" Тогда
				текКонтрагент=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнойПокупатель");
			Иначе
				текКонтрагент=Справочники.Контрагенты.ПустаяСсылка();
			КонецЕсли;
			ДокументОбъект.Контрагент=текКонтрагент;
		КонецЕсли;
		
		Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "БанковскийСчетКонтрагента") Тогда
			ДокументОбъект.БанковскийСчетКонтрагента = УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(текКонтрагент, "ОсновнойБанковскийСчет");
		КонецЕсли;

		Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "КонтактноеЛицоКонтрагента") Тогда
			Если ТипЗнч(ДокументОбъект.Контрагент) = Тип("СправочникСсылка.Контрагенты") И ЗначениеЗаполнено(текКонтрагент) Тогда
				ДокументОбъект.КонтактноеЛицоКонтрагента = УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(текКонтрагент, "ОсновноеКонтактноеЛицо");
			Иначе
				ДокументОбъект.КонтактноеЛицоКонтрагента = Справочники.КонтактныеЛицаКонтрагентов.ПустаяСсылка();
			КонецЕсли; 
		КонецЕсли;

		Если УправлениеМетаданными.ЕстьРеквизит("ДоговорКонтрагента", МетаданныеДокумента) Тогда
			Если НЕ ЗначениеЗаполнено(ДокументОбъект.ДоговорКонтрагента) И ТипЗнч(ДокументОбъект.Контрагент) = Тип("СправочникСсылка.Контрагенты") Тогда
				Если ТипОперации="Продажа" Тогда 
					стрВидДоговора="СПокупателем,СКомиссионером";
				ИначеЕсли ТипОперации="Покупка" Тогда 
					стрВидДоговора="СПоставщиком,СКомитентом";
				КонецЕсли;
				СтруктураПраметров=Новый Структура;
				СтруктураПраметров.Вставить("Организация", ?(УправлениеМетаданными.ЕстьРеквизит("Организация", МетаданныеДокумента),ДокументОбъект.Организация, Неопределено));
				СтруктураПраметров.Вставить("Контрагент", ДокументОбъект.Контрагент);
				СтруктураПраметров.Вставить("ВидДоговора", стрВидДоговора);

				ДокументОбъект.ДоговорКонтрагента=УправлениеДиалогамиСервер.ДоступныеДоговорыКонтрагента(СтруктураПраметров, Истина);				
			КонецЕсли;

			Если ЗначениеЗаполнено(ДокументОбъект.ДоговорКонтрагента) Тогда
				//тип сделки имеет смысл устанавливать только в том случае, если заполнен договор
				Если УправлениеМетаданными.ЕстьРеквизит("Сделка", МетаданныеДокумента) Тогда
					ЗаказПокупателя=Истина; прчВидыДоговоров=Перечисления.ВидыДоговоровКонтрагентов;
					ОсновнойДоговорКонтрагента=УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(текКонтрагент, "ОсновнойДоговорКонтрагента");
					ВидДоговора=УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(ОсновнойДоговорКонтрагента, "ВидДоговора");
					Если ВидДоговора=прчВидыДоговоров.СПоставщиком ИЛИ ВидДоговора=прчВидыДоговоров.СКомитентом Тогда
						ЗаказПокупателя=Ложь;
					КонецЕсли;
				КонецЕсли;

				Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ВалютаДокумента") Тогда
					ДокументОбъект.ВалютаДокумента=УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(ДокументОбъект.ДоговорКонтрагента, "ВалютаВзаиморасчетов");
				КонецЕсли;

				Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ТипЦен") Тогда
					ДокументОбъект.ТипЦен=УправлениеКонфигурациейСервер.ПолучитьЗначениеРеквизитаОбъекта(ДокументОбъект.ДоговорКонтрагента, "ТипЦен");
				КонецЕсли;
			КонецЕсли;
		КонецЕсли; // есть реквизит договор
	КонецЕсли;// есть реквизит контрагент

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ВалютаДокумента") Тогда
		ДокументОбъект.ВалютаДокумента = МодульВалютногоУчета.ПолучитьВалюту("Бух");
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "КурсДокумента") Тогда
		СтруктураКурсаДокумента = МодульВалютногоУчета.КурсВалюты(ДокументОбъект.ВалютаДокумента, ДокументОбъект.Дата);
		ДокументОбъект.КурсДокумента = СтруктураКурсаДокумента.Курс;
		Если УправлениеМетаданными.ЕстьРеквизит("КратностьДокумента", МетаданныеДокумента) Тогда
			ДокументОбъект.КратностьДокумента = СтруктураКурсаДокумента.Кратность;
		КонецЕсли;
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "КурсВзаиморасчетов") Тогда
	    СтруктураКурсаДокумента = МодульВалютногоУчета.КурсВалюты(ДокументОбъект.ВалютаДокумента, ДокументОбъект.Дата);
		ДокументОбъект.КурсВзаиморасчетов = СтруктураКурсаДокумента.Курс;
		Если УправлениеМетаданными.ЕстьРеквизит("КратностьВзаиморасчетов", МетаданныеДокумента) Тогда
			ДокументОбъект.КратностьВзаиморасчетов = СтруктураКурсаДокумента.Кратность;
		КонецЕсли;
	КонецЕсли;

	Если АтрибутНеобходимоЗаполнить(ДокументОбъект, МетаданныеДокумента, "ТипЦен") Тогда
		Если ТипОперации="Продажа" Тогда
			ДокументОбъект.ТипЦен=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнойТипЦенПродажи");
		ИначеЕсли ТипОперации="Покупка" Тогда
			ДокументОбъект.ТипЦен=УправлениеПользователямиСервер.ПолучитьЗначениеПоУмолчанию("ОсновнойТипЦенПокупки");
		КонецЕсли;
	КонецЕсли;
	Если УправлениеМетаданными.ЕстьРеквизит("ТипЦен", МетаданныеДокумента) Тогда
		Если ЗначениеЗаполнено(ДокументОбъект.ТипЦен) Тогда
			// Флаги учета налогов заполняем, только если флаг УчитыватьНДС не заполнен.
			Если УправлениеМетаданными.ЕстьРеквизит("УчитыватьНДС", МетаданныеДокумента) И (Не ДокументОбъект.УчитыватьНДС) Тогда
				ДокументОбъект.УчитыватьНДС=Истина;
				Если УправлениеМетаданными.ЕстьРеквизит("СуммаВключаетНДС", МетаданныеДокумента) Тогда
					ТипЦен=ДокументОбъект.ТипЦен;
					Если ТипЦен.Метаданные().Имя="ТипыЦенНоменклатуры" Тогда
						ТипЦен=?(ТипЦен.Рассчитывается, ТипЦен.БазовыйТипЦен, ТипЦен);
					КонецЕсли;
					ДокументОбъект.СуммаВключаетНДС=ТипЦен.ЦенаВключаетНДС;
				КонецЕсли;
			КонецЕсли;
		Иначе
			// Заполним значениями по умолчанию (нет, либо не заполнен ТипЦен).
			// Флаги учета НДС заполняем, только если флаг УчитыватьНДС не заполнен.
			Если УправлениеМетаданными.ЕстьРеквизит("УчитыватьНДС", МетаданныеДокумента) И (Не ДокументОбъект.УчитыватьНДС) Тогда
				ДокументОбъект.УчитыватьНДС=Истина;
				Если УправлениеМетаданными.ЕстьРеквизит("СуммаВключаетНДС", МетаданныеДокумента) И (Не ДокументОбъект.СуммаВключаетНДС) Тогда
					ДокументОбъект.СуммаВключаетНДС=Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

// Общие события (документов\справочников)
Процедура ПриКопировании(Объект, ОбъектКопирования) Экспорт
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ПриКопировании");
КонецПроцедуры

Процедура ОбработкаЗаполнения(Объект, ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка) Экспорт
	Если ДанныеЗаполнения=Неопределено Тогда // Новый объект
		стрТип=УправлениеКоллекциямиЗначенийСервер.СвойствоСтруктуры(Объект.ДополнительныеСвойства, "ТипОбъекта", "");
		Если стрТип="Документ" Тогда ЗаполнитьАтрибутыШапкиДокумента(Объект); КонецЕсли; 

	ИначеЕсли ТипЗнч(ДанныеЗаполнения)=Тип("Структура") Тогда //Новый объект с параметрами отбора
		Для каждого СтрокаКоллекции Из ДанныеЗаполнения Цикл
			стрАтрибут=СтрокаКоллекции.Ключ;
			Если стрАтрибут="ЭтоГруппа" Тогда Продолжить; КонецЕсли; 

			ЗначениеАтрибута=СтрокаКоллекции.Значение;
			Если стрАтрибут="ДокументыПоКонтрагенту" Тогда
				стрАтрибут="Контрагент";
			ИначеЕсли стрАтрибут="ДокументыПоДоговоруКонтрагента" Тогда
				стрАтрибут="Контрагент";
			ИначеЕсли стрАтрибут="МетаСсылка" Тогда
				стрАтрибут="СторнируемыйДокумент";
				стрПолноеИмя=МетаконфигураторСервер.ПолноеИмяОбъектаПоСсылке(СтрокаКоллекции.Значение);
				ЗначениеАтрибута=Документы[стрЗаменить(стрПолноеИмя, "Документ.", "")].ПустаяСсылка();
			КонецЕсли;
			Попытка Объект[стрАтрибут]=ЗначениеАтрибута;
			Исключение
			КонецПопытки; 
		КонецЦикла;
		ОбработкаЗаполнения(Объект, Неопределено, ТекстЗаполнения, СтандартнаяОбработка);
	КонецЕсли;
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ОбработкаЗаполнения");
КонецПроцедуры

Процедура ПриЗаписи(Объект, Отказ) Экспорт
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ПриЗаписи", Отказ);
КонецПроцедуры

Процедура ПередЗаписью(Объект, Отказ, РежимЗаписи=Неопределено, РежимПроведения=Неопределено) Экспорт
	Если Не РежимЗаписи=Неопределено Тогда //Документ
		Если ТипЗнч(Объект)=Тип("ДокументОбъект.БухгалтерскаяСправка") Тогда
			Если УправлениеДокументамиСервер.ИмяПредопределенногоПодвида(Объект.Подвид)="Корректировка" Тогда
				Сообщить("Документ был создан автоматически, изменение документа запрещено!");
				Отказ=Истина; Возврат;
			КонецЕсли; //Временно			
		КонецЕсли;

		Если Объект.ЭтоНовый() И УправлениеМетаданными.ЕстьРеквизит("Автор", Объект.Метаданные()) Тогда
			Объект.Автор=ПараметрыСеанса.ТекущийПользователь;
		КонецЕсли;

		//Если УправлениеМетаданными.ЕстьРеквизит("ПоследнийАвтор", Объект.Метаданные()) Тогда
		//	Объект.ПоследнийАвтор=ПараметрыСеанса.ТекущийПользователь;
		//КонецЕсли;

		Объект.ДополнительныеСвойства.Вставить("УдалятьДвижения", Объект.Проведен);
	КонецЕсли;
	
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ПередЗаписью", Отказ);
КонецПроцедуры

Процедура ПередУдалением(Объект, Отказ) Экспорт
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ПередУдалением", Отказ);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий "Документы"

Процедура ОбработкаПроведения(Объект, Отказ, РежимПроведения) Экспорт
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ОбработкаПроведения", Отказ);
КонецПроцедуры

Процедура ПриУстановкеНовогоНомера(Объект, СтандартнаяОбработка, Префикс) Экспорт
	УправлениеПрефиксамиСервер.Сформировать(Объект, Префикс);
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ПриУстановкеНовогоНомера");
КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Объект, Отказ) Экспорт
	УправлениеДокументамиСервер.УдалитьДвиженияРегистратора(Объект, Отказ);
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ОбработкаУдаленияПроведения", Отказ);
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Объект, Отказ, ПроверяемыеРеквизиты) Экспорт
	РегистрыПравилСервер.ВыполнитьПравило(Неопределено, Объект, "ОбработкаПроверкиЗаполнения", Отказ);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий "Справочники"

Процедура ПриУстановкеНовогоКода(Объект, СтандартнаяОбработка, Префикс) Экспорт
	ОбщегоНазначения.ДобавитьПрефиксУзла(Префикс);	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий "Регистры сведений"

Процедура РегистрСведений_ПриЗаписи(Объект, Отказ, Замещение) Экспорт
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий "Регистры накопления"

Процедура РегистрНакопления_ПередЗаписью(Источник, Отказ, Замещение) Экспорт
	РегистрыСведений.НастройкаЗаписейРегистров.ВыполнитьНастройки(Источник, Отказ, Замещение);
КонецПроцедуры

Процедура РегистрНакопления_ПриЗаписи(Источник, Отказ, Замещение) Экспорт
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий "Регистры бухгалтерии"

Процедура РегистрБухгалтерии_ПередЗаписью(Источник, Отказ, Замещение) Экспорт
	РегистрыСведений.НастройкаЗаписейРегистров.ВыполнитьНастройки(Источник, Отказ, Замещение);
КонецПроцедуры

Процедура РегистрБухгалтерии_ПриЗаписи(Источник, Отказ, Замещение) Экспорт
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий "Константы"

Процедура Константы_ПриЗаписиПриЗаписи(Объект, Отказ) Экспорт
КонецПроцедуры