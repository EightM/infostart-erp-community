﻿&НаКлиенте
Процедура ПрименитьНастройкуКлиент(Команда)
	ПрименитьНастройкуСервер();
	ПоказатьПредупреждение(, "Установка настроек завершена!", 20);
КонецПроцедуры

&НаСервере
Процедура ПрименитьНастройкуСервер()
	дзДанные=РеквизитФормыВЗначение("ДеревоМетаданных");
	Для каждого Ветка1 Из дзДанные.Строки Цикл
		Если Ветка1.Пометка=0 Тогда Продолжить; КонецЕсли;
		Для каждого Ветка2 Из Ветка1.Строки Цикл
			Если Ветка2.Пометка=0 Тогда Продолжить; КонецЕсли;

			ТипВид=СтрРазделить(Ветка2.ИмяМетаданных, ".");
			стрТип=ТипВид[0];
			стрВид=ТипВид[1];

			тзЭлементы=Новый ТаблицаЗначений;
			тзЭлементы.Колонки.Добавить("Идентификатор");
			тзЭлементы.Колонки.Добавить("Представление");
			Для каждого Ветка3 Из Ветка2.Строки Цикл
				Если Ветка3.Пометка=0 Тогда Продолжить; КонецЕсли;
				мдОбъект=Метаданные.Документы[стрВид].Реквизиты[Ветка3.ИмяМетаданных];
				НоваяСтрока=тзЭлементы.Добавить();
				НоваяСтрока.Идентификатор=мдОбъект.Имя;
				НоваяСтрока.Представление=мдОбъект.Представление();
			КонецЦикла;
			Если тзЭлементы.Количество()=0 Тогда Продолжить; КонецЕсли; //Ошибка

			МенеджерЗаписи=РегистрыСведений.НастройкиФормыСписка.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.ИсточникДанных=УправлениеКонфигурациейСервер.ИдентификаторОбъектовМетаданныхСсылка(Ветка2.ИмяМетаданных);
			МенеджерЗаписи.Пользователь=Пользователь;
			МенеджерЗаписи.Прочитать();

			Если НЕ МенеджерЗаписи.Выбран() Тогда
				СтруктураНастроек=Новый Структура;
				СтруктураНастроек.Вставить("Настройки", НастройкаДинамическогоСписка(Ветка2.ИмяМетаданных));
				МенеджерЗаписи.ИсточникДанных=УправлениеКонфигурациейСервер.ИдентификаторОбъектовМетаданныхСсылка(Ветка2.ИмяМетаданных);
				МенеджерЗаписи.Пользователь=Пользователь;
				МенеджерЗаписи.Настройка=Новый ХранилищеЗначения(СтруктураНастроек);
				МенеджерЗаписи.ДинамическоеСчитываниеДанных=Истина;
			КонецЕсли;

			МенеджерЗаписи.Элементы=Новый ХранилищеЗначения(тзЭлементы);			
			МенеджерЗаписи.Записать();
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Функция НастройкаДинамическогоСписка(ИмяОсновнойТаблицы)
	СхемаКомпоновкиДанных=Новый СхемаКомпоновкиДанных;
	ИсточникДанных=СхемаКомпоновкиДанных.ИсточникиДанных.Добавить();
	ИсточникДанных.Имя="ИсточникДанных1";
	ИсточникДанных.ТипИсточникаДанных="Local";
	
	НаборДанныхЗапрос=СхемаКомпоновкиДанных.НаборыДанных.Добавить(Тип("НаборДанныхЗапросСхемыКомпоновкиДанных"));
	НаборДанныхЗапрос.Имя="НаборДанных";
	НаборДанныхЗапрос.ИсточникДанных="ИсточникДанных1";	
	НаборДанныхЗапрос.Запрос="
	|ВЫБРАТЬ
	| *
	|ИЗ
	|	"+ИмяОсновнойТаблицы+" КАК ИсточникДанных
	|";

	КомпоновщикНастроек=Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновкиДанных));
	Возврат КомпоновщикНастроек.ПолучитьНастройки();
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибутов

&НаКлиенте
Процедура Атрибут_ПриИзменении(Элемент)
	Если Элемент.Имя="Пользователь" Тогда
		тпДеревоМетаданных_Заполнить();
	КонецЕсли; 
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий табличного поля "Дерево метаданных"

&НаСервере
Функция тпДеревоМетаданных_ДобавитьСтроку(СтрокаЭлементы, ОбъектМД, Пометка, Картинка)
	Если Лев(ОбъектМД.Имя, 1)="_" Тогда Возврат Неопределено; КонецЕсли;

	НоваяСтрока=СтрокаЭлементы.Добавить();
	НоваяСтрока.Пометка=Пометка;
	НоваяСтрока.Картинка=Картинка;
	НоваяСтрока.Синоним=ОбъектМД.Синоним;
	НоваяСтрока.ИмяМетаданных=ОбъектМД.ПолноеИмя();

	//************************
	МенеджерЗаписи=РегистрыСведений.НастройкиФормыСписка.СоздатьМенеджерЗаписи();	
	МенеджерЗаписи.ИсточникДанных=УправлениеКонфигурациейСервер.ИдентификаторОбъектовМетаданныхСсылка(ОбъектМД.ПолноеИмя());
	МенеджерЗаписи.Пользователь=Пользователь;
	МенеджерЗаписи.Прочитать();
	Если МенеджерЗаписи.Выбран() Тогда
		тзЭлементы=МенеджерЗаписи.Элементы.Получить();
	КонецЕсли;
	//************************

	Ветка=НоваяСтрока.ПолучитьЭлементы(); //Добавляем реквизиты (lee)	
	Для каждого СтрокаКоллекции Из Метаданные.Документы[ОбъектМД.Имя].Реквизиты Цикл
		НоваяСтрока=Ветка.Добавить();
		НоваяСтрока.Картинка=БиблиотекаКартинок.Реквизит;
		НоваяСтрока.Синоним=СтрокаКоллекции.Представление();
		НоваяСтрока.ИмяМетаданных=СтрокаКоллекции.Имя;
		Если НЕ тзЭлементы=Неопределено Тогда
			НоваяСтрока.Пометка=НЕ тзЭлементы.Найти(СтрокаКоллекции.Имя, "Идентификатор")=Неопределено;
		КонецЕсли;
	КонецЦикла;

	Возврат НоваяСтрока;	
КонецФункции

&НаСервере
Процедура тпДеревоМетаданных_ОткрытьВеткуДереваМД(ИдентификаторЭлементаДерева)
	ЭлементДерева=ДеревоМетаданных.НайтиПоИдентификатору(ИдентификаторЭлементаДерева);
	КоллекцияЭлементы=ЭлементДерева.ПолучитьЭлементы();

	КоллекцияМД=Метаданные[ЭлементДерева.ИмяМетаданных];
	Для Каждого ОбъектМД Из КоллекцияМД Цикл
		тпДеревоМетаданных_ДобавитьСтроку(КоллекцияЭлементы, ОбъектМД, ЭлементДерева.Пометка, ЭлементДерева.Картинка);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура тпДеревоМетаданных_УстановитьПометкуПодчиненным(Элемент)
	Для Каждого ПодчиненнаяСтрока Из Элемент.ПолучитьЭлементы() Цикл
		ПодчиненнаяСтрока.Пометка=Элемент.Пометка;
		тпДеревоМетаданных_УстановитьПометкуПодчиненным(ПодчиненнаяСтрока);
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура тпДеревоМетаданных_ОбновитьСостояниеПометки(Элемент)
	Если Элемент=Неопределено Тогда Возврат; КонецЕсли;

	ЕстьОтмеченные=Ложь; ЕстьНеотмеченные=Ложь;
	Для Каждого ПодчиненныйЭлемент Из Элемент.ПолучитьЭлементы() Цикл
		Если ПодчиненныйЭлемент.Пометка Тогда
			ЕстьОтмеченные=Истина;
		Иначе
			ЕстьНеотмеченные=Истина;
		КонецЕсли;
	КонецЦикла;

	Элемент.Пометка=?(ЕстьОтмеченные И ЕстьНеотмеченные, 2, ?(ЕстьОтмеченные, 1, 0));
	тпДеревоМетаданных_ОбновитьСостояниеПометки(Элемент.ПолучитьРодителя());	
КонецПроцедуры

&НаСервере
Процедура тпДеревоМетаданных_Заполнить()
	ДеревоМетаданных.ПолучитьЭлементы().Очистить();

	СписокМетаданных=Новый СписокЗначений; //Соответствие (Метаданные -> Картинка)
	//СписокМетаданных.Добавить ("Справочники", "Справочники", Истина, БиблиотекаКартинок.Справочник);
	СписокМетаданных.Добавить("Документы", "Документы", Ложь, БиблиотекаКартинок.Документ);

	КореньДереваЭлементы=ДеревоМетаданных.ПолучитьЭлементы();
	Для Каждого МД Из СписокМетаданных Цикл
		НоваяСтрока=КореньДереваЭлементы.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, МД);
		НоваяСтрока.Синоним=МД.Представление;
		НоваяСтрока.ИмяМетаданных=МД.Значение;
		тпДеревоМетаданных_ОткрытьВеткуДереваМД(НоваяСтрока.ПолучитьИдентификатор());
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура тпДеревоМетаданных_ПриИзменении(Элемент)
	ТекущиеДанные=Элемент.ТекущиеДанные;
	Если ТекущиеДанные.Пометка=2 Тогда
		ТекущиеДанные.Пометка=0;
	КонецЕсли;
	тпДеревоМетаданных_УстановитьПометкуПодчиненным(ТекущиеДанные); // Изменяем состояние "вниз" (подчиненным)	
	тпДеревоМетаданных_ОбновитьСостояниеПометки(ТекущиеДанные.ПолучитьРодителя()); // Изменяем состояние "вверх" (для установки флажков серым)	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	тпДеревоМетаданных_Заполнить();
КонецПроцедуры
