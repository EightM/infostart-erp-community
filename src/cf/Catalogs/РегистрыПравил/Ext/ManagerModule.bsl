﻿////////////////////////////////////////////////////////////////////////////////
// Универсальные процедуры\функции

Функция АтрибутИзСтроки(Знач стрАтрибут) Экспорт
	стрАтрибут=Сред(стрАтрибут, 3);
	стрАтрибут=стрЗаменить(стрАтрибут, "__", Символы.ПС);

	стрТипСсылки=стрЗаменить(СтрПолучитьСтроку(стрАтрибут, 1), "_", ".");

	стрИдентификаторСсылки=СтрПолучитьСтроку(стрАтрибут, 2);
	стрИдентификаторСсылки=стрЗаменить(стрИдентификаторСсылки, "_", "-");

	Возврат XMLЗначение(Тип(стрТипСсылки), стрИдентификаторСсылки);		
КонецФункции

Функция АтрибутВСтроку(АтрибутСсылка) Экспорт
	стрИдентификатор=СтрЗаменить(XMLСтрока(АтрибутСсылка), "-", "_");
	стрТип=СтрЗаменить(XMLТип(ТипЗнч(АтрибутСсылка)).ИмяТипа, ".", "_");
	Возврат "Д_"+стрТип+"__"+стрИдентификатор;	
КонецФункции 

Функция СтруктураОбъекта(ИмяФормы) Экспорт
	стрПуть=СтрЗаменить(ИмяФормы, ".", Символы.ПС);

	СтруктураВозврата=Новый Структура;
	СтруктураВозврата.Вставить("Тип", СтрПолучитьСтроку(стрПуть, 1));
	СтруктураВозврата.Вставить("Вид", СтрПолучитьСтроку(стрПуть, 2));

	Если СтруктураВозврата.Тип="Документ" Тогда
	    СтруктураВозврата.Вставить("ЭтоОбъект", НЕ Метаданные.Документы.Найти(СтруктураВозврата.Вид)=Неопределено);
	ИначеЕсли СтруктураВозврата.Тип="Справочник" Тогда
		СтруктураВозврата.Вставить("ЭтоОбъект", НЕ Метаданные.Справочники.Найти(СтруктураВозврата.Вид)=Неопределено);
	КонецЕсли;

	Возврат СтруктураВозврата;
КонецФункции

Функция ТипОбъекта(Объект, Режим=0, Разделитель=".") Экспорт
	// Режим: 0 - тип объекта, 1 - тип+вид объекта
	Попытка мдОбъект=Объект.Метаданные();
	Исключение Возврат Строка(ТипЗнч(Объект));
	КонецПопытки;

	Если Режим=0 Тогда Возврат СтрЗаменить(мдОбъект.ПолноеИмя(), "."+мдОбъект.Имя, ""); КонецЕсли; 
	
	стрТипВид=мдОбъект.ПолноеИмя();
	Если Разделитель<>"." Тогда стрТипВид=стрЗаменить(стрТипВид, ".", Разделитель); КонецЕсли;

	Возврат стрТипВид;	
КонецФункции

Функция ПустоеЗначение(Значение, ПроверкаНаМутабельныйТип=Ложь) Экспорт
	Если ПроверкаНаМутабельныйТип Тогда
		Результат=Ложь;
		ТипЗначения=ТипЗнч(Значение);
		Если Значение=Неопределено Тогда
			Результат=Истина;
		ИначеЕсли Значение=NULL Тогда
			Результат=Истина;
		ИначеЕсли ТипЗначения=Тип("Строка") Тогда
			Если СокрЛП(Значение)="" Тогда Результат=Истина; КонецЕсли;
		ИначеЕсли ТипЗначения=Тип("Число") Тогда
			Если Значение=0 Тогда Результат=Истина; КонецЕсли;
		ИначеЕсли ТипЗначения=Тип("Дата") Тогда
			Если Значение=Дата('00010101') Тогда Результат=Истина; КонецЕсли;
		ИначеЕсли ТипЗначения=Тип("Булево") Тогда
			Результат=Ложь; // Булево будем считать не пустым
			// Для остальных будем считать значение пустым, если оно равно
			// дефолтному значению своего типа
		Иначе
			Если Значение=Новый(ТипЗначения) Тогда Результат=Истина; КонецЕсли;
		КонецЕсли;
		Возврат Результат;
	КонецЕсли;

	Если ТипЗнч(Значение)=Тип("Булево") Тогда Возврат Ложь; КонецЕсли;
	Возврат Не ЗначениеЗаполнено(Значение);
КонецФункции

Функция ЗначениеРеквизитаОбъекта(Ссылка, ИмяРеквизита) Экспорт
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	"+ИмяРеквизита+" КАК Результат
	|ИЗ
	|	"+Ссылка.Метаданные().ПолноеИмя()+" КАК ИсточникДанных
	|Где
	|	Ссылка = &Ссылка
	|";
	Возврат Запрос.Выполнить().Выгрузить()[0]["Результат"];
	//** Возврат ЗначенияРеквизитовОбъекта(Ссылка, ИмяРеквизита)[ИмяРеквизита];	
КонецФункции 

Функция ЗначенияРеквизитовОбъекта(Ссылка, Реквизиты) Экспорт
	Если ТипЗнч(Реквизиты)=Тип("Строка") Тогда
		Если ПустаяСтрока(Реквизиты) Тогда Возврат Новый Структура; КонецЕсли;
		СтруктураРеквизитов=Новый Структура(Реквизиты);
		
	ИначеЕсли ТипЗнч(Реквизиты)=Тип("Структура") ИЛИ ТипЗнч(Реквизиты)=Тип("ФиксированнаяСтруктура") Тогда
		СтруктураРеквизитов=Реквизиты;

	ИначеЕсли ТипЗнч(Реквизиты)=Тип("Массив") ИЛИ ТипЗнч(Реквизиты)=Тип("ФиксированныйМассив") Тогда
		СтруктураРеквизитов=Новый Структура;
		Для каждого Реквизит Из Реквизиты Цикл
			СтруктураРеквизитов.Вставить(Реквизит);
		КонецЦикла;
	Иначе
		//*** ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Неверный тип второго параметра Реквизиты: %1'"), Строка(ТипЗнч(Реквизиты)));
	КонецЕсли;

	ТекстПолей="";
	Для Каждого КлючИЗначение Из СтруктураРеквизитов Цикл
		ИмяПоля=?(ЗначениеЗаполнено(КлючИЗначение.Значение), СокрЛП(КлючИЗначение.Значение), СокрЛП(КлючИЗначение.Ключ));
		Псевдоним=СокрЛП(КлючИЗначение.Ключ);
		ТекстПолей=ТекстПолей+?(ПустаяСтрока(ТекстПолей), "", ",")+"
		|"+ИмяПоля+" КАК "+Псевдоним;
	КонецЦикла;
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Текст="
	|ВЫБРАТЬ
	|"+ТекстПолей+"
	|ИЗ
	|	"+Ссылка.Метаданные().ПолноеИмя()+" КАК ПсевдонимЗаданнойТаблицы
	|ГДЕ
	|	ПсевдонимЗаданнойТаблицы.Ссылка = &Ссылка
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	Результат=Новый Структура;
	Для Каждого КлючИЗначение Из СтруктураРеквизитов Цикл
		Результат.Вставить(КлючИЗначение.Ключ);
	КонецЦикла;
	ЗаполнитьЗначенияСвойств(Результат, Выборка);
	
	Возврат Результат;
КонецФункции

Функция ПолучитьРазностьДат(Дата1, Дата2, Масштаб="День") Экспорт
	Запрос=Новый Запрос;
	Запрос.Текст="ВЫБРАТЬ РАЗНОСТЬДАТ(&Дата1, &Дата2, "+Масштаб+") КАК РазностьДат";
	Запрос.УстановитьПараметр("Дата1", Дата1);
	Запрос.УстановитьПараметр("Дата2", Дата2);
	Возврат Запрос.Выполнить().Выгрузить()[0].РазностьДат;	
КонецФункции

Функция ЭтоПредопределенныйЭлемент(Ссылка) Экспорт
	Если Найти(Ссылка.Код, "УправлениеРегистрамиПравил")>0 И Ссылка.Системный Тогда Возврат Истина; КонецЕсли;	
	Возврат Ложь;	
КонецФункции
 
////////////////////////////////////////////////////////////////////////////////
// 

Функция тзИзмерения_Создать(тзХранилищеПравил, СсылкаНаОбъект)
	тзСтруктура=Новый ТаблицаЗначений;
	тзСтруктура.Колонки.Добавить("Объект");
	тзСтруктура.Колонки.Добавить("ИмяКолонки");
	тзСтруктура.Колонки.Добавить("Модуль");
	тзСтруктура.Колонки.Добавить("ОписаниеТипа");
	тзСтруктура.Колонки.Добавить("ТипСоответствия");
	тзСтруктура.Колонки.Добавить("ЗначениеИзмерения");

    Выборка=СформироватьЗапросПоАтрибутамРегистраПравил(СсылкаНаОбъект);
    Пока Выборка.Следующий() Цикл
		НоваяСтрока=тзСтруктура.Добавить();
		НоваяСтрока.Объект=Выборка.Ссылка;
		НоваяСтрока.ИмяКолонки=АтрибутВСтроку(Выборка.Ссылка);
		НоваяСтрока.Модуль=Выборка.ТекстМодуля;
		НоваяСтрока.ТипСоответствия=Выборка.ТипСоответствия;
		НоваяСтрока.ОписаниеТипа=Выборка.ОписаниеТипа.Получить();

		тзХранилищеПравил.Колонки.Добавить(НоваяСтрока.ИмяКолонки, НоваяСтрока.ОписаниеТипа, СокрЛП(НоваяСтрока.Объект));
	КонецЦикла;

	Возврат тзСтруктура;
КонецФункции

Функция тзРесурсы_Создать(тзХранилищеПравил, СсылкаНаОбъект)
	тзСтруктура=Новый ТаблицаЗначений;
	тзСтруктура.Колонки.Добавить("Объект");
	тзСтруктура.Колонки.Добавить("ИмяКолонки");
	тзСтруктура.Колонки.Добавить("Модуль");
	тзСтруктура.Колонки.Добавить("ОписаниеТипа");

    Выборка=СформироватьЗапросПоАтрибутамРегистраПравил(СсылкаНаОбъект);
    Пока Выборка.Следующий() Цикл
		НоваяСтрока=тзСтруктура.Добавить();
		НоваяСтрока.Объект=Выборка.Ссылка;
		НоваяСтрока.ИмяКолонки=АтрибутВСтроку(Выборка.Ссылка);
		НоваяСтрока.Модуль=Выборка.ТекстМодуля;
		НоваяСтрока.ОписаниеТипа=Выборка.ОписаниеТипа.Получить();

		тзХранилищеПравил.Колонки.Добавить(НоваяСтрока.ИмяКолонки, НоваяСтрока.ОписаниеТипа, СокрЛП(НоваяСтрока.Объект));
	КонецЦикла;

	Возврат тзСтруктура;
КонецФункции

// Функция инициализации регистра правил
//
// Параметры:
//	СсылкаНаОбъект - Ссылка на объект (регистр правил)
//
// Возвращаемое значение:
//  Результат инициализации: Истина\Ложь
Функция Инициализация(СсылкаНаОбъект) Экспорт
	СтруктураРегистраПравил=СсылкаНаОбъект.Кэш.Получить();
	Если СтруктураРегистраПравил=Неопределено Тогда
		Запрос=Новый Запрос;
		Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
		Запрос.Текст="
		|ВЫБРАТЬ
		|	Хранилище,Измерения,Ресурсы
		|ИЗ
		|   Справочник.РегистрыПравил
		|ГДЕ
		|   Ссылка = &Ссылка
		|";
		Выборка=Запрос.Выполнить().Выбрать(); Выборка.Следующий();
		
		СтруктураРегистраПравил=Новый Структура("Правила,Измерения,Ресурсы");
		СтруктураРегистраПравил.Вставить("Правила", Новый ТаблицаЗначений);
		СтруктураРегистраПравил.Вставить("Измерения", тзИзмерения_Создать(СтруктураРегистраПравил.Правила, Выборка.Измерения));
		СтруктураРегистраПравил.Вставить("Ресурсы", тзРесурсы_Создать(СтруктураРегистраПравил.Правила, Выборка.Ресурсы));

	   	тзБуфер=Выборка.Хранилище.Получить();
		Если НЕ тзБуфер=Неопределено Тогда
			Для каждого СтрокаКоллекции Из тзБуфер Цикл
				ЗаполнитьЗначенияСвойств(СтруктураРегистраПравил.Правила.Добавить(), СтрокаКоллекции);
			КонецЦикла;
		КонецЕсли;

		Объект=СсылкаНаОбъект.ПолучитьОбъект();
		Объект.Кэш=Новый ХранилищеЗначения(СтруктураРегистраПравил);
		Объект.Записать();
	КонецЕсли;

	Возврат СтруктураРегистраПравил;
КонецФункции

// Процедура дополнения системными данными таблицы измерений
//
// Параметры:
//	Измерение - Имя измерния
//	Значение - Значение измерения
//
Процедура ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, Измерение, Значение) Экспорт
	СтрокаТабличнойЧасти=СтруктураРегистраПравил.Измерения.Найти(Измерение);
	Если СтрокаТабличнойЧасти=Неопределено Тогда Возврат; КонецЕсли;
	СтрокаТабличнойЧасти.ЗначениеИзмерения=Значение;
КонецПроцедуры

// Процедура дополнения пользовательскими данными таблицы измерений
//
// Параметры:
//	СтруктураПараметров - Структура параметров для определения режима тестирования
//
Процедура ДополнитьПользовательскимиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, СтруктураПараметров) Экспорт
	//*** Если СтруктураПараметров.Свойство("РежимТестирования") Тогда Возврат; КонецЕсли;
	Если СтруктураРегистраПравил.Измерения=Неопределено Тогда Возврат; КонецЕсли;
	Для каждого СтрокаТаблицыЗначений Из СтруктураРегистраПравил.Измерения Цикл
		стрМодуль=СтрокаТаблицыЗначений.Модуль;
		Если Не ЗначениеЗаполнено(стрМодуль) Тогда Продолжить; КонецЕсли; 
		Если Найти(стрМодуль, "ЗначениеИзмерения")=0 Тогда
			стрМодуль="ЗначениеИзмерения="+стрМодуль;
		КонецЕсли;
		ЗначениеИзмерения=Неопределено; Выполнить(стрМодуль);
		Если ЗначениеИзмерения=Неопределено Тогда Продолжить; КонецЕсли;
		СтрокаТаблицыЗначений.ЗначениеИзмерения=ЗначениеИзмерения;		
	КонецЦикла;
КонецПроцедуры

// Функция получения таблицы соответствия
//
// Параметры:
//	Нет
//
// Возвращаемое значение:
//  Таблица соответствий
//
Функция ПолучитьТаблицуСоответствий(СтруктураРегистраПравил)
    стСоответствия=Новый Структура;
	тзСоответствия=Новый ТаблицаЗначений;
	тзПравилаКопия=СтруктураРегистраПравил.Правила.Скопировать();

	//Добавим колонки "измерения" в таблицу соответствий
	ТипЧисло=Новый ОписаниеТипов("Число");
	Для Каждого СтрокаКоллекции Из СтруктураРегистраПравил.Измерения Цикл
		стрКолонка=СтрокаКоллекции.ИмяКолонки;
		тзСоответствия.Колонки.Добавить(стрКолонка, ТипЧисло);
		стрТипСоответствия=СтрокаКоллекции.ТипСоответствия;
		Если стрТипСоответствия="От" Или стрТипСоответствия="До" Тогда
			тзПравилаКопия.Сортировать(стрКолонка+?(стрТипСоответствия="До", " Убыв", " Возр"));
			стСоответствия.Вставить(стрКолонка, тзПравилаКопия[0][стрКолонка]);
		КонецЕсли;
	КонецЦикла;

	//Добавим колонки "ресурсы" в таблицу соответствий
	Для Каждого СтрокаКоллекции Из СтруктураРегистраПравил.Ресурсы Цикл
		тзСоответствия.Колонки.Добавить(СтрокаКоллекции.ИмяКолонки, СтрокаКоллекции.ОписаниеТипа);
	КонецЦикла;

	//Заполняем таблицу соответствий
	УровеньСоответствияПоУмолчанию=1000;
	Для Каждого СтрокаПравила Из СтруктураРегистраПравил.Правила Цикл
		фСоответствие=0; ОбъектСтрокаСоответствия=тзСоответствия.Добавить();

		Для Каждого СтрокаАтрибута Из СтруктураРегистраПравил.Измерения Цикл
			ЗначениеИзмерения=СтрокаАтрибута.ЗначениеИзмерения;
			ЗначениеКолонки=СтрокаПравила[СтрокаАтрибута.ИмяКолонки];

			// TODO продумать для разных типов соответствий -
			//как они должны себя вести при пустых значениях измерений в правилах и/или пустых значений переданных измерений
			//пока использую правило: Если входное значение неопределено, то нет однозначных правил (кроме правила "для всех"):
			//Необходимо ввести понятие ЮНИВЕРСУМ
			
			//{ Артур
			Если Не ЗначениеЗаполнено(ЗначениеКолонки) Тогда //Подходит любое значение измерения
				Продолжить;
			ИначеЕсли Не ЗначениеЗаполнено(ЗначениеИзмерения) Тогда
				фСоответствие=-1; Прервать;
			КонецЕсли;
			//} Артур

			Если ТипЗнч(ЗначениеКолонки)=Тип("Строка")Тогда ЗначениеКолонки=СокрЛП(ЗначениеКолонки); КонецЕсли;

			// Для измерений детерминанта, обязательных к заполнению, необходимо добавить следующее:
			// При пустом значении входного вектора и пустом значении РП
			//степень соответствия = УровеньСоответствияПоУмолчанию.
			стрТипСоответствия=СокрЛП(СтрокаАтрибута.ТипСоответствия);
			Если стрТипСоответствия="До" Тогда //Диапазон потолок
				ВерхняяГраница=стСоответствия[СтрокаАтрибута.ИмяКолонки];
				фСоответствие=?(ЗначениеИзмерения>ЗначениеКолонки, -1, ВерхняяГраница-ЗначениеКолонки+1);
			ИначеЕсли стрТипСоответствия="От" Тогда //Диапазон пол
				НижняяГраница=стСоответствия[СтрокаАтрибута.ИмяКолонки];
				фСоответствие=?(ЗначениеКолонки>ЗначениеИзмерения, -1, ЗначениеКолонки-НижняяГраница+1);
			ИначеЕсли стрТипСоответствия="НачалоСтроки" Тогда //Начало строки
				ЗначениеКолонки=СтрЗаменить(ЗначениеКолонки, ";", Символы.ПС);
				Для ъ=1 По СтрЧислоСтрок(ЗначениеКолонки) Цикл
					стрЗначение=ВРЕГ(СокрЛП(стрПолучитьСтроку(ЗначениеКолонки, ъ)));
					Если стрЗначение=ВРЕГ(ЗначениеИзмерения) Тогда фСоответствие=1000; Прервать; КонецЕсли; //24.04.13
					фСоответствие=?(стрЗначение=ВРЕГ(Лев(ЗначениеИзмерения, СтрДлина(стрЗначение))), СтрДлина(стрЗначение), -1);
					Если фСоответствие<>-1 Тогда Прервать; КонецЕсли;
				КонецЦикла;
				//фСоответствие=?(ЗначениеКолонки=Лев(ЗначениеИзмерения,СтрДлина(ЗначениеКолонки)), СтрДлина(ЗначениеКолонки),-1);
			ИначеЕсли стрТипСоответствия="КонецСтроки" Тогда //Конец строки
				ЗначениеКолонки=СтрЗаменить(ЗначениеКолонки, ";", Символы.ПС);
				Для ъ=1 По СтрЧислоСтрок(ЗначениеКолонки) Цикл
					стрЗначение=ВРЕГ(СокрЛП(стрПолучитьСтроку(ЗначениеКолонки, ъ)));
					фСоответствие=?(стрЗначение=ВРЕГ(Прав(ЗначениеИзмерения, СтрДлина(стрЗначение))), СтрДлина(стрЗначение), -1);
					Если фСоответствие<>-1 Тогда Прервать; КонецЕсли;
				КонецЦикла;
				//фСоответствие=?(ЗначениеКолонки=Прав(ЗначениеИзмерения,СтрДлина(ЗначениеКолонки)),СтрДлина(ЗначениеКолонки),-1);
			ИначеЕсли стрТипСоответствия="Путь" Тогда //Путь
				фСоответствие=-1; поз=Найти(ЗначениеКолонки, ЗначениеИзмерения);
				Если поз>0 Тогда фСоответствие=УровеньСоответствияПоУмолчанию-поз; КонецЕсли;
				//фСоответствие=-1;
				//Если Лев(ЗначениеИзмерения, СтрДлина(ЗначениеКолонки))=ЗначениеКолонки Тогда
				//	фСоответствие=УровеньСоответствияПоУмолчанию-СтрЧислоВхождений(ЗначениеИзмерения, ".");
				//КонецЕсли;
			ИначеЕсли стрТипСоответствия="СписокДанных" Тогда
				Если ТипЗнч(ЗначениеИзмерения)=Тип("СписокЗначений") Тогда
					РезультатПоиска=ЗначениеИзмерения.НайтиПоЗначению(ЗначениеКолонки);
					фСоответствие=?(РезультатПоиска=Неопределено, -1, ЗначениеИзмерения.Индекс(РезультатПоиска)+1);
				КонецЕсли;
			Иначе
				фСоответствие=?(ЗначениеИзмерения=ЗначениеКолонки, УровеньСоответствияПоУмолчанию, -1);
				Если фСоответствие=-1 Тогда
					стрТипВид=ТипОбъекта(ЗначениеКолонки, 1, Символы.ПС);
					стрТип=стрПолучитьСтроку(стрТипВид, 1);
					стрВид=стрПолучитьСтроку(стрТипВид, 2);
					Если стрТип="Справочник"  Тогда
						стрВидИерархии=Строка(Метаданные.Справочники[стрВид].ВидИерархии);
						Если стрВидИерархии="ИерархияЭлементов" Тогда
							фСоответствие=?(ЗначениеИзмерения.ПринадлежитЭлементу(ЗначениеКолонки)=1, ЗначениеКолонки.Уровень()+1, -1);
						ИначеЕсли стрВидИерархии="ИерархияГруппИЭлементов" Тогда
							Если ЗначениеКолонки.ЭтоГруппа Тогда //Если ЗначениеРеквизитаОбъекта(ЗначениеКолонки, "ЭтоГруппа") Тогда
								фСоответствие=?(ЗначениеИзмерения.ПринадлежитЭлементу(ЗначениеКолонки)=1, ЗначениеКолонки.Уровень()+1, -1);
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;

			Если фСоответствие=-1 Тогда Прервать; КонецЕсли;

			ОбъектСтрокаСоответствия[СтрокаАтрибута.ИмяКолонки]=фСоответствие;
		КонецЦикла;

		Если фСоответствие=-1 Тогда
			тзСоответствия.Удалить(ОбъектСтрокаСоответствия);
			Продолжить;
		КонецЕсли;

		//Заполним ресурсы таблицы соответствия текущей строки
		Для Каждого СтрокаКоллекции Из СтруктураРегистраПравил.Ресурсы Цикл
			ОбъектСтрокаСоответствия[СтрокаКоллекции.ИмяКолонки]=СтрокаПравила[СтрокаКоллекции.ИмяКолонки];
		КонецЦикла;		
	КонецЦикла;

	Возврат тзСоответствия;
КонецФункции

Функция ПодготовитьСтруктуруПараметров(СсылкаНаОбъект, ПроизвольнаяСтруктураПараметров) Экспорт
	Если НЕ ПроизвольнаяСтруктураПараметров.Свойство("РежимТестирования_Произвольный") Тогда Возврат ПроизвольнаяСтруктураПараметров; КонецЕсли;
	
	СтруктураРегистраПравил=Инициализация(СсылкаНаОбъект);
	
	нужнаяСтруктураПараметров = Новый Структура;
	
	Для каждого ключЗначение Из ПроизвольнаяСтруктураПараметров Цикл
		имяОбъекта = ключЗначение.Ключ;
		Значение = ключЗначение.Значение;
		строкаИзмеренияИлиРесурса = СтруктураРегистраПравил.Измерения.Найти(имяОбъекта, "НаименованиеОбъекта");
		Если строкаИзмеренияИлиРесурса <> Неопределено Тогда
			строкаИзмеренияИлиРесурса.ЗначениеИзмерения = Значение;
		Иначе
			строкаИзмеренияИлиРесурса=СтруктураРегистраПравил.Ресурсы.Найти(имяОбъекта, "НаименованиеОбъекта");
			Если НЕ строкаИзмеренияИлиРесурса=Неопределено Тогда 
				//строкаИзмеренияИлиРесурса.ЗначениеРесурса = Значение;
			Иначе
				нужнаяСтруктураПараметров.Вставить(имяОбъекта, ключЗначение.Значение);
				Продолжить; 
			КонецЕсли; 
		КонецЕсли; 
		нужнаяСтруктураПараметров.Вставить(строкаИзмеренияИлиРесурса.ИмяКолонки, ключЗначение.Значение);
	КонецЦикла; 
	
	нужнаяСтруктураПараметров.Вставить("РежимТестирования", Истина);
	Возврат нужнаяСтруктураПараметров;
КонецФункции //Артур (для произвольного тестирования)

// Функция получения правила
//
// Параметры:
//	СтруктураПараметров - Структура параметров
//	ВернутьТаблицуСоответствия - Условие возвращения таблтцы соответствия
//
// Возвращаемое значение:
//  Струткура корня(Имя\значение) / таблица соответствия
//
Функция ПолучитьПравило(СтруктураРегистраПравил, СтруктураПараметров, ВернутьТаблицуСоответствия=Ложь) Экспорт
	Если СтруктураРегистраПравил.Правила = Неопределено Тогда Возврат Новый Структура; КонецЕсли;
	Если СтруктураРегистраПравил.Правила.Количество()=0 Тогда Возврат Новый Структура; КонецЕсли; 

	тзСоответствия=ПолучитьТаблицуСоответствий(СтруктураРегистраПравил);

	Если тзСоответствия.Колонки.Количество()=0 Тогда Возврат Новый Структура; КонецЕсли;
	Если тзСоответствия.Количество()=0 Тогда Возврат Новый Структура; КонецЕсли;

	Если тзСоответствия.Количество()>1 Тогда
		стрСортировкаДетерминант="";
		Для Каждого СтрокаКоллекции Из СтруктураРегистраПравил.Измерения Цикл
			стрСортировкаДетерминант=стрСортировкаДетерминант+?(стрСортировкаДетерминант="", "", ",")+СтрокаКоллекции.ИмяКолонки+" Убыв";
		КонецЦикла;
		тзСоответствия.Сортировать(стрСортировкаДетерминант);
	КонецЕсли;

	РежимТестирования=СтруктураПараметров.Свойство("РежимТестирования");

	Если ВернутьТаблицуСоответствия Тогда Возврат тзСоответствия; КонецЕсли; 

	стКорень=Новый Структура;

	//Получить первое значение корня:
	Для Каждого СтрокаКоллекции Из СтруктураРегистраПравил.Ресурсы Цикл
		стрКолонка=СтрокаКоллекции.ИмяКолонки;
		ЗначениеРесурса=тзСоответствия[0][стрКолонка];
		стКорень.Вставить(стрКолонка, ЗначениеРесурса);

		Если РежимТестирования Тогда Продолжить; КонецЕсли; 

		//Если ресурсам(корню) назначены какие нибудь действия - выполняем их
		стрМодуль=СтрокаКоллекции.Модуль;
		Если Не ПустаяСтрока(стрМодуль) Тогда
			стрМодуль=стрЗаменить(стрМодуль, "{ЗначениеРесурса}", "ЗначениеРесурса");
			Выполнить(стрМодуль);
		КонецЕсли;
	КонецЦикла;
	
	Возврат стКорень;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции общего назначения

Функция СформироватьЗапросПоАтрибутамРегистраПравил(РодительВыборки) Экспорт
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("РодительВыборки", РодительВыборки);
    Запрос.Текст="
	|ВЫБРАТЬ
	|	РегистрыПравил.Ссылка,
    |	РегистрыПравил.ОписаниеТипа,
    |	РегистрыПравил.ТекстМодуля,
    |	РегистрыПравил.Наименование,
    |	РегистрыПравил.ТипСоответствия,
	|	РегистрыПравил.Код,
	|	РегистрыПравил.Порядок
    |ИЗ
    |	Справочник.РегистрыПравил КАК РегистрыПравил
    |ГДЕ
    |	РегистрыПравил.ПометкаУдаления = ЛОЖЬ
    |	И РегистрыПравил.ЭтоГруппа = ЛОЖЬ
    |	И РегистрыПравил.Родитель = &РодительВыборки
	|
	|УПОРЯДОЧИТЬ ПО
    |	РегистрыПравил.Порядок
	|";	
    Возврат Запрос.Выполнить().Выбрать();
КонецФункции

Процедура СкопироватьЭлементыПравила(РодительПриемник, РодительИсточник, Идентификатор, тзДанные=Неопределено)
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Родитель", РодительИсточник);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных.Ссылка
	|ИЗ
	|	Справочник.РегистрыПравил КАК ИсточникДанных
	|ГДЕ
	|	ИсточникДанных.Родитель = &Родитель
	|	И ИсточникДанных.ПометкаУдаления = Ложь
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		НовыйЭлемент=Выборка.Ссылка.ПолучитьОбъект().Скопировать();
		НовыйЭлемент.Код=Идентификатор+стрЗаменить(Выборка.Ссылка.Код, Выборка.Ссылка.Родитель.Родитель.Код, "");
		НовыйЭлемент.Системный=Ложь;
		НовыйЭлемент.Родитель=РодительПриемник;
		НовыйЭлемент.Записать();

		Если тзДанные=Неопределено Тогда Продолжить; КонецЕсли; 
		ОбъектКолонка=тзДанные.Колонки.Найти(АтрибутВСтроку(Выборка.Ссылка));
		Если Не ОбъектКолонка=Неопределено Тогда
			ОбъектКолонка.Имя=АтрибутВСтроку(НовыйЭлемент.Ссылка);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры
 
Процедура СкопироватьПравило(СсылкаНаПравило, Идентификатор) Экспорт
	НачатьТранзакцию();

	НовыйЭлемент=СсылкаНаПравило.ПолучитьОбъект().Скопировать();
	НовыйЭлемент.Родитель=Справочники.РегистрыПравил.ПустаяСсылка();
	НовыйЭлемент.Наименование=СокрЛП(НовыйЭлемент.Наименование)+" (копия)";
	НовыйЭлемент.Системный=Ложь;
	НовыйЭлемент.Код=Идентификатор;
	НовыйЭлемент.Записать();

	НовыйЭлемент_Изм=Справочники.РегистрыПравил.СоздатьГруппу();
	НовыйЭлемент_Изм.Код=Идентификатор+"_Изм";
	НовыйЭлемент_Изм.Наименование="Измерения";
	НовыйЭлемент_Изм.Родитель=НовыйЭлемент.Ссылка;
	НовыйЭлемент_Изм.Системный=Ложь;
	НовыйЭлемент_Изм.Записать();

	НовыйЭлемент_Рес=Справочники.РегистрыПравил.СоздатьГруппу();
	НовыйЭлемент_Рес.Код=Идентификатор+"_Рес";
	НовыйЭлемент_Рес.Наименование="Ресурсы";
	НовыйЭлемент_Рес.Родитель=НовыйЭлемент.Ссылка;
	НовыйЭлемент_Рес.Системный=Ложь;
	НовыйЭлемент_Рес.Записать();

	НовыйЭлемент.Измерения=НовыйЭлемент_Изм.Ссылка;
	НовыйЭлемент.Ресурсы  =НовыйЭлемент_Рес.Ссылка;		
	НовыйЭлемент.Записать();

	тзДанные=НовыйЭлемент.Хранилище.Получить();
	Если НЕ ТипЗнч(тзДанные)=Тип("ТаблицаЗначений") Тогда
		тзДанные=Неопределено;
	КонецЕсли;

	СкопироватьЭлементыПравила(НовыйЭлемент_Изм.Ссылка, СсылкаНаПравило.Измерения, Идентификатор, тзДанные);
	СкопироватьЭлементыПравила(НовыйЭлемент_Рес.Ссылка, СсылкаНаПравило.Ресурсы  , Идентификатор, тзДанные);

	Если Не тзДанные=Неопределено Тогда
		НовыйЭлемент.Хранилище=Новый ХранилищеЗначения(тзДанные);
		НовыйЭлемент.Записать();
	КонецЕсли;

	ЗафиксироватьТранзакцию();
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Доп.процедуры

// Функция формирования структуры параметров
//
// Параметры:
//	Источник - Ссылка на объект
//	стрСобытие - Имя события
//	Отказ - отказ от действия
//
// Возвращаемое значение:
//  Структура сформированных параметров
//
Функция СформироватьСтруктуруПараметров(Источник, стрСобытие, Отказ=Неопределено) Экспорт
	СтруктураПараметров=Новый Структура;
	СтруктураПараметров.Вставить("ЭтотОбъект", Источник);
	СтруктураПараметров.Вставить("Отказ", Отказ);
	СтруктураПараметров.Вставить("Событие", Перечисления.СобытияСистемы[стрСобытие]);
	СтруктураПараметров.Вставить("ПутьКДанным", Источник.Метаданные().ПолноеИмя());
	Возврат СтруктураПараметров;
КонецФункции

Функция ДополнитьСтруктуруПараметров(СтруктураПараметров, Источник, стрСобытие) Экспорт
	//мдОбъект=Источник.Метаданные();
	СтруктураПараметров.Вставить("ЭтотОбъект", Источник);
	СтруктураПараметров.Вставить("Событие", Перечисления.СобытияСистемы[стрСобытие]);
	//СтруктураПараметров.Вставить("ПолныйПутьКДанным", мдОбъект.ПолноеИмя());
	//СтруктураПараметров.Вставить("ПутьКДанным", мдОбъект.Имя);
	СтруктураПараметров.Вставить("ПутьКДанным", Источник.Метаданные().ПолноеИмя());
	Возврат СтруктураПараметров;
КонецФункции

Функция ЭтоРегистрПравил(Источник) Экспорт
	//Возврат ТипЗнч(Источник)=Тип("СправочникОбъект.РегистрыПравил");
	Возврат Источник.Метаданные().Имя="РегистрыПравил";
КонецФункции

// Функция получения значения измерения
//
// Параметры:
//	Структура - Структура измерений
//	Ключ - Имя измерения
//	ЗначениеПоУмолчанию - Значение по умолчанию
//
// Возвращаемое значение:
//  Значение измерния
//
Функция ЗначениеИзмерения(Структура, Ключ, ЗначениеПоУмолчанию=Неопределено)
	Значение=ЗначениеПоУмолчанию;
	Если Структура.Свойство(Ключ, Значение) Тогда
		Значение=Структура[Ключ];
	КонецЕсли;
	Возврат Значение;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Выполнить регистр правил "Управление регистрами правил"

// Функция управления регистрами правил
//
// Параметры:
//	СтруктураПараметров - структура входящих параметров
//	Отказ - Истина/Ложь
//
// Возвращаемое значение:
//  Структура исходящих параметров
//
Функция ВыполнитьПравило_УправлениеРегистрамиПравил(СтруктураПараметров, Отказ=Ложь) Экспорт
	УправлениеРегистрамиПравил=Справочники.РегистрыПравил.НайтиПоКоду("УправлениеРегистрамиПравил");
	Если УправлениеРегистрамиПравил.Пустая() Тогда Возврат СтруктураПараметров; КонецЕсли; //Ошибка

	СтруктураРегистраПравил=Инициализация(УправлениеРегистрамиПравил);

	//Измерение "Событие"
	СсылкаИзмерение=Справочники.РегистрыПравил.НайтиПоКоду("УправлениеРегистрамиПравил_Событие",, УправлениеРегистрамиПравил.Измерения);
	ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, СсылкаИзмерение, Перечисления.СобытияСистемы[ЗначениеИзмерения(СтруктураПараметров, "Событие")]);

	//Измерение "Источник данных"
	СсылкаИзмерение=Справочники.РегистрыПравил.НайтиПоКоду("УправлениеРегистрамиПравил_ИсточникДанных",, УправлениеРегистрамиПравил.Измерения);
	ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, СсылкаИзмерение, ЗначениеИзмерения(СтруктураПараметров, "ИсточникДанных"));

	//Измерения произвольные
	ДополнитьПользовательскимиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, СтруктураПараметров);

	тзСоответствия=ПолучитьПравило(СтруктураРегистраПравил, СтруктураПараметров, Истина);

	СсылкаРесурс=Справочники.РегистрыПравил.НайтиПоКоду("УправлениеРегистрамиПравил_РегистрПравил",,УправлениеРегистрамиПравил.Ресурсы);

	Для каждого СтрокаСоответствия Из тзСоответствия Цикл
		РезультатПравила=Новый Структура;
		Для Каждого СтрокаРесурса Из СтруктураРегистраПравил.Ресурсы Цикл
			стрКолонка=СтрокаРесурса.ИмяКолонки;
			ЗначениеРесурса=СтрокаСоответствия[стрКолонка];
			РезультатПравила.Вставить(стрКолонка, ЗначениеРесурса);
			//Если ресурсам(корню) назначены какие нибудь действия - выполняем  их
			стрМодуль=СтрокаРесурса.Модуль;
			Если Не ПустаяСтрока(стрМодуль) Тогда
				стрМодуль=стрЗаменить(стрМодуль, "{ЗначениеРесурса}", "ЗначениеРесурса");
				Выполнить(стрМодуль);
			КонецЕсли;
		КонецЦикла;
		Если РезультатПравила.Количество()>0 Тогда
			стрКолонка=АтрибутВСтроку(СсылкаРесурс);
			СсылкаНаРегистрПравил=РезультатПравила[стрКолонка];
			Если НЕ ЗначениеЗаполнено(СсылкаНаРегистрПравил) Тогда Продолжить; КонецЕсли; //11.02.14

			ВыполнитьПравило(СсылкаНаРегистрПравил, СтруктураПараметров, Отказ);

			Если СтруктураПараметров.Свойство("Отказ") Тогда
				Отказ=СтруктураПараметров.Отказ;
				Если Отказ Тогда Прервать; КонецЕсли;
			КонецЕсли;
			//*** СтруктураПараметров.Вставить("РезультатПравила", РезультатПравила);
		КонецЕсли;
	КонецЦикла;        

	Возврат СтруктураПараметров;
КонецФункции 

////////////////////////////////////////////////////////////////////////////////
// Выполнить регистр правил "Склонение слов"

Функция ВыполнитьПравило_СклонениеСлов(Слово, Род="", КатегорияСлова="Фамилия") Экспорт
	рпСклонениеСлов=Справочники.РегистрыПравил.НайтиПоКоду("СклонениеСлов");

	СтруктураПараметров=Новый Структура;
	СтруктураПараметров.Вставить("Слово", Слово);

	//Определение последней буквы
	СтрокаСогласных="БВГДЖЗКЛМНПРСТФХЦЧШЩ";
	ПоследняяБуква=Прав(ВРег(Слово), 1);
	ТипПоследнейБуквы=?(Найти(СтрокаСогласных, ПоследняяБуква)>0, "Согласная", "");
	//Определение последней буквы

	СтруктураРегистраПравил=Инициализация(рпСклонениеСлов);
	
	ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, Справочники.РегистрыПравил.НайтиПоКоду("СклонениеСлов_ДлинаСловаОт"), СтрДлина(Слово));
	ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, Справочники.РегистрыПравил.НайтиПоКоду("СклонениеСлов_ДлинаСловаДо"), СтрДлина(Слово));
	ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, Справочники.РегистрыПравил.НайтиПоКоду("СклонениеСлов_КатегорияСлова"), КатегорияСлова);
	ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, Справочники.РегистрыПравил.НайтиПоКоду("СклонениеСлов_ОкончаниеСлова"), Слово);
	ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, Справочники.РегистрыПравил.НайтиПоКоду("СклонениеСлов_Род"), Род);
	ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, Справочники.РегистрыПравил.НайтиПоКоду("СклонениеСлов_ТипПоследнейБуквы"), ТипПоследнейБуквы);
	ДополнитьПользовательскимиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, СтруктураПараметров);

	РезультатПравила=ПолучитьПравило(СтруктураРегистраПравил, СтруктураПараметров);

	стрНачалоСлова=Слово;

	СтруктураВозврата=Новый Структура; Индекс=0;
	Для каждого СтрокаКоллекции Из РезультатПравила Цикл
		Если Индекс=0 Тогда
			текЗначениеРесурса=СтрокаКоллекции.Значение;
			Если текЗначениеРесурса="Именительный_1" Тогда
				стрНачалоСлова=Лев(Слово, СтрДлина(Слово)-1);
			ИначеЕсли текЗначениеРесурса="Именительный_2" Тогда
				стрНачалоСлова=Лев(Слово, СтрДлина(Слово)-2);
			ИначеЕсли текЗначениеРесурса="Именительный_3" Тогда
				стрНачалоСлова=Лев(Слово, СтрДлина(Слово)-3);
			ИначеЕсли текЗначениеРесурса="Именительный_4" Тогда
				стрНачалоСлова=Лев(Слово, СтрДлина(Слово)-4);
			КонецЕсли;
			Индекс=1; Продолжить; 
		КонецЕсли;
		Объект=АтрибутИзСтроки(СтрокаКоллекции.Ключ); 
		
		стрИмя=Объект.Код;
		//стрИмя=Справочники.РегистрыПравил.ПолучитьИмяПредопределенного(Объект);
		//стрИмя=стрЗаменить(стрИмя, "СклонениеСлов_Ресурсы_", "");
		Если Не ЗначениеЗаполнено(стрИмя) Тогда Продолжить; КонецЕсли; 
		СтруктураВозврата.Вставить(стрИмя, стрНачалоСлова+СтрокаКоллекции.Значение); 
	КонецЦикла;
	
	Возврат СтруктураВозврата;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Выполнить регистр правил

// Функция выполнения правила
//
// Параметры:
//	СсылкаНаРегистрПравил - ссылка на регистр правил
//  СтруктураПараметров - структура входящих параметров
//  Отказ - истина/ложь
//  ИмяРегистраПравил - имя регистра правил
//
// Возвращаемое значение:
//  РезультатПравила - результат выполнения
//
Функция ВыполнитьПравило(СсылкаНаРегистрПравил, СтруктураПараметров, Отказ=Ложь, СтруктураРегистраПравил=Неопределено) Экспорт
	Если СтруктураРегистраПравил=Неопределено Тогда
		СтруктураРегистраПравил=Инициализация(СсылкаНаРегистрПравил);
		ДополнитьПользовательскимиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, СтруктураПараметров);
	КонецЕсли;	
	
	Если СтруктураПараметров.Свойство("ПредопределенныеПараметры") Тогда
		Если ТипЗнч(СтруктураПараметров.ПредопределенныеПараметры)=Тип("Соответствие") Тогда
			Для каждого СтрокаКоллекции Из СтруктураПараметров.ПредопределенныеПараметры Цикл
				ДополнитьСистемнымиДаннымиТаблицуИзмерений(СтруктураРегистраПравил, СтрокаКоллекции.Ключ, СтрокаКоллекции.Значение);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;

	РезультатПравила=ПолучитьПравило(СтруктураРегистраПравил, СтруктураПараметров);
	Если СтруктураПараметров.Свойство("Отказ") Тогда Отказ=СтруктураПараметров.Отказ; КонецЕсли;

	Возврат РезультатПравила;
КонецФункции