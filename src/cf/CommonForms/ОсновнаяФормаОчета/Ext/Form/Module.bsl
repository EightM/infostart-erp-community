﻿&НаКлиенте
Процедура ВыполнитьДействие(Кнопка)
	стрИмя=?(ТипЗнч(Кнопка)=Тип("Строка"), Кнопка, Кнопка.Имя);

	Если стрИмя="Сформировать" Тогда
		ОбновитьОтчет();
		
	ИначеЕсли стрИмя="ВычислитьСумму" Тогда
		ПоказатьРасчетЯчеек(Результат);
		
	ИначеЕсли стрИмя="Поделиться" Тогда
		ОткрытьФорму("РегистрСведений.Share.Форма.ФормаЗаписи",Новый Структура("ТабличныйДокумент", Результат),,УникальныйИдентификатор,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
	ИначеЕсли стрИмя="ВыбратьПериод" Тогда
		ОписаниеОповещения=Новый ОписаниеОповещения("ОбработчикОповещения_ВыборПериода", ЭтотОбъект);
		ОткрытьФорму("ОбщаяФорма.ВыборПериода", Новый Структура("ДатаНачала,ДатаКонца", ДатаНачала, ДатаКонца), ЭтаФорма, УникальныйИдентификатор,,, ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьРасчетЯчеек(ТабличныйДокумент)
	ПараметрыФормы=Новый Структура;
	ПараметрыФормы.Вставить("ТабличныйДокумент", ТабличныйДокумент);
	ПараметрыФормы.Вставить("ВыделенныеОбласти", ВыделенныеОбласти(ТабличныйДокумент));
	ОткрытьФорму("ОбщаяФорма.ПоказателиВыделенныхЯчеек", ПараметрыФормы, ЭтаФорма, Истина,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

&НаКлиенте
Функция ВыделенныеОбласти(ТабличныйДокумент)
	Результат = Новый Массив;
	Для Каждого ВыделеннаяОбласть Из ТабличныйДокумент.ВыделенныеОбласти Цикл
		Если ТипЗнч(ВыделеннаяОбласть) <> Тип("ОбластьЯчеекТабличногоДокумента") Тогда
			Продолжить;
		КонецЕсли;
		Структура = Новый Структура("Верх, Низ, Лево, Право, ТипОбласти");
		ЗаполнитьЗначенияСвойств(Структура, ВыделеннаяОбласть);
		Результат.Добавить(Структура);
	КонецЦикла;
	Возврат Результат;
КонецФункции

&НаСервере
Функция ПараметрыНастройки(Ссылка)
	СтруктураПараметров=Новый Структура;
	СтруктураПараметров.Вставить("НастройкиКомпоновщика", Ссылка.Настройка.Получить());	
	СтруктураПараметров.Вставить("ДатаНачала", Ссылка.ДатаНачала);
	СтруктураПараметров.Вставить("ДатаКонца", Ссылка.ДатаКонца);
	Возврат СтруктураПараметров;
КонецФункции

&НаСервере
Процедура ОбновитьОтчет() Экспорт
	мдОтчет=Метаданные.Отчеты[ИмяОтчета];

	ОтчетМенеджер=Отчеты[ИмяОтчета];
	Попытка СтруктраПараметров=ОтчетМенеджер.ПараметрыОтчета();
	Исключение СтруктраПараметров=Новый Структура;
	КонецПопытки;

	//Очистим пользовательские настрйки если они были
	//Для каждого СтрокаКоллекции Из Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы Цикл
	//	Если ТипЗнч(СтрокаКоллекции)=Тип("СтруктураНастроекКомпоновкиДанных") Тогда
	//		СтрокаКоллекции.Структура.Очистить();
	//	Иначе
	//		СтрокаКоллекции.Элементы.Очистить();
	//	КонецЕсли;
	//КонецЦикла;

	стрЗаголовок=?(СтруктраПараметров.Свойство("Заголовок"), СтруктраПараметров.Заголовок, мдОтчет.Представление());
	Если ЗначениеЗаполнено(ДатаНачала) Тогда
		стрЗаголовок=стрЗаголовок+" "+УправлениеКонфигурациейСервер.ОписаниеПериода(ДатаНачала, ДатаКонца);
	Иначе
		стрЗаголовок=стрЗаголовок+" на "+Формат(ДатаКонца, "ДФ=dd.MM.yyyy");
	КонецЕсли;

	//Установим параметр "Заголовок"
	Параметр=Отчет.КомпоновщикНастроек.Настройки.ПараметрыВывода.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("Заголовок"));
	Параметр.Использование=Истина;
	Параметр.Значение=стрЗаголовок;

	//Установим параметр "Дата начала"
	Параметр=Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти(Новый ПараметрКомпоновкиДанных("НачалоПериода"));
	Если НЕ Параметр=Неопределено Тогда
		Параметр.Значение=НачалоДня(ДатаНачала);
		Параметр.Использование=Истина;
	КонецЕсли;

	//Установим параметр "Дата конца"
	Параметр=Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти(Новый ПараметрКомпоновкиДанных("КонецПериода"));
	Если НЕ Параметр=Неопределено Тогда
		ИспользоватьГриницу=?(СтруктраПараметров.Свойство("ИспользоватьГриницу"), СтруктраПараметров.ИспользоватьГриницу, Ложь);
		Если ИспользоватьГриницу Тогда
			Параметр.Значение=Новый Граница(КонецДня(ДатаКонца), ВидГраницы.Включая);
		Иначе
			Параметр.Значение=КонецДня(ДатаКонца);
		КонецЕсли;
		Параметр.Использование=Истина;
	КонецЕсли;

	//Макет оформления
 	Параметр=Отчет.КомпоновщикНастроек.Настройки.ПараметрыВывода.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("МакетОформления"));
	Параметр.Использование=Истина;
	Параметр.Значение="МакетОформленияСКД"; 	
 
	//*** Отчеты.УправлениеОтчетамиСКД.УстановитьПараметрыГруппировкиРегистратор(СхемаКомпоновкиДанных, Отчет.КомпоновщикНастроек);
	ЭтаФорма.СкомпоноватьРезультат(РежимКомпоновкиРезультата.Фоновый);	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики оповещения

&НаКлиенте
Процедура ОбработчикОповещения_ВыборНастройки(Параметр1, Параметр2) Экспорт
	Если ТипЗнч(Параметр1)=Тип("СправочникСсылка.ВариантыОтчетов") Тогда
		СтруктураПараметров=ПараметрыНастройки(Параметр1);
		Если СтруктураПараметров.Свойство("ДатаНачала") Тогда
			Если ЗначениеЗаполнено(СтруктураПараметров.ДатаНачала) Тогда
				Попытка ДатаНачала=Вычислить(СтруктураПараметров.ДатаНачала);
				Исключение ДатаНачала=Дата(СтруктураПараметров.ДатаНачала+" 00:00:00");
				КонецПопытки;
			КонецЕсли;
		КонецЕсли; 
		Если СтруктураПараметров.Свойство("ДатаКонца") Тогда
			Если ЗначениеЗаполнено(СтруктураПараметров.ДатаКонца) Тогда
				Попытка ДатаКонца=Вычислить(СтруктураПараметров.ДатаКонца);
				Исключение ДатаКонца=Дата(СтруктураПараметров.ДатаКонца+" 23:59:59");
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;

		Если СтруктураПараметров.Свойство("НастройкиКомпоновщика") Тогда
			Отчет.КомпоновщикНастроек.ЗагрузитьНастройки(СтруктураПараметров.НастройкиКомпоновщика);
		КонецЕсли;
	КонецЕсли;

	//*** ОбновитьОтчет();
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОповещения_ВыборПериода(Параметр1, Параметр2) Экспорт
	Если Параметр1=Неопределено Тогда Возврат; КонецЕсли;
	ЗаполнитьЗначенияСвойств(ЭтаФорма, Параметр1);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если ПустаяСтрока(Заголовок) Тогда
		Если Лев(ЭтаФорма.ИмяФормы, 6)="Отчет." Тогда
			ИмяОтчета=СтрРазделить(ЭтаФорма.ИмяФормы, ".")[1];
			Заголовок=Метаданные.Отчеты[ИмяОтчета];
		КонецЕсли;
	КонецЕсли;
	
	ОтчетМенеджер=Отчеты[ИмяОтчета];
	Попытка СтруктраПараметров=ОтчетМенеджер.ПараметрыОтчета();
	Исключение СтруктраПараметров=Новый Структура;
	КонецПопытки;
	
	Если СтруктраПараметров.Свойство("НаДату") Тогда
		ОтчетНаДату=Истина; //СтруктраПараметров.НаДату;
	КонецЕсли;

	Элементы.ГруппаПериод.Видимость=Не ОтчетНаДату;	
	Элементы.ГруппаДата.Видимость=ОтчетНаДату;

	ДатаКонца=ТекущаяДата();
КонецПроцедуры

//&НаСервере
//Процедура ПриСохраненииВариантаНаСервере(Настройки)
//	//Сообщить(111);
//КонецПроцедуры

&НаСервере
Процедура ПередЗагрузкойВариантаНаСервере(Настройки)
	Если Настройки=Неопределено Тогда Возврат; КонецЕсли;

	Если Настройки.ДополнительныеСвойства.Свойство("ДатаНачала") Тогда
		Если ЗначениеЗаполнено(Настройки.ДополнительныеСвойства.ДатаНачала) Тогда
			Попытка ДатаНачала=Вычислить(Настройки.ДополнительныеСвойства.ДатаНачала);
			Исключение ДатаНачала=Дата(Настройки.ДополнительныеСвойства.ДатаНачала+" 00:00:00");
			КонецПопытки;
		КонецЕсли;
	КонецЕсли; 
	Если Настройки.ДополнительныеСвойства.Свойство("ДатаКонца") Тогда
		Если ЗначениеЗаполнено(Настройки.ДополнительныеСвойства.ДатаКонца) Тогда
			Попытка ДатаКонца=Вычислить(Настройки.ДополнительныеСвойства.ДатаКонца);
			Исключение ДатаКонца=Дата(Настройки.ДополнительныеСвойства.ДатаКонца+" 23:59:59");
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;
	Если Настройки.ДополнительныеСвойства.Свойство("Заголовок") Тогда
		Заголовок=Настройки.ДополнительныеСвойства.Заголовок;
	КонецЕсли;
КонецПроцедуры
