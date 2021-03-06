﻿Процедура УстановитьПараметрыСеанса() Экспорт
	ПараметрыСеанса.ТекущийПользователь = УправлениеПользователямиСервер.ОпределитьТекущегоПользователя();;
	ПараметрыСеанса.ВалютаБухУчета = Константы.ВалютаРегламентированногоУчета.Получить();
	ПараметрыСеанса.ВалютаУпрУчета = Константы.ВалютаУправленческогоУчета.Получить();

	//Настройки пользователя по умолчанию
	Запрос=Новый Запрос; СтруктураПараметровПользователя=Новый Структура;
	Запрос.УстановитьПараметр("Пользователь", ПараметрыСеанса.ТекущийПользователь);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ИсточникДанных1.Ссылка Как Настройка,
	|	ИсточникДанных2.Значение Как Значение
	|ИЗ
	|	ПланВидовХарактеристик.НастройкиПользователей КАК ИсточникДанных1
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НастройкиПользователей КАК ИсточникДанных2
	|		ПО ИсточникДанных1.Ссылка = ИсточникДанных2.Настройка
	|		И &Пользователь = ИсточникДанных2.Пользователь
	|ГДЕ
	|	НЕ ИсточникДанных1.ЭтоГруппа И НЕ ИсточникДанных1.ПометкаУдаления
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		стрНастройка=ПланыВидовХарактеристик.НастройкиПользователей.ПолучитьИмяПредопределенного(Выборка.Настройка);
		Если ПустаяСтрока(стрНастройка) Тогда Продолжить; КонецЕсли;
		Значение=Выборка.Значение;
		Если Значение=Null Тогда
			Значение=ПланыВидовХарактеристик.НастройкиПользователей[стрНастройка].ТипЗначения.ПривестиЗначение();
		КонецЕсли;
		СтруктураПараметровПользователя.Вставить(стрНастройка, Значение);
	КонецЦикла;
	ПараметрыСеанса.НастройкиПользователя=Новый ФиксированнаяСтруктура(СтруктураПараметровПользователя);
	
	//Доп.права пользователя
	Запрос=Новый Запрос; СтруктураДопПравПользователя=Новый Структура;
	Запрос.УстановитьПараметр("Пользователь", ПараметрыСеанса.ТекущийПользователь);
	Запрос.УстановитьПараметр("НеОтпускатьТоварСЦенойНижеОпределенногоТипа", ПланыВидовХарактеристик.ПраваПользователей.НеОтпускатьТоварСЦенойНижеОпределенногоТипа);
	Запрос.УстановитьПараметр("ТипыЦенНоменклатурыПустая", Справочники.ТипыЦенНоменклатуры.ПустаяСсылка());
	Запрос.Текст="
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	1 КАК Индекс,
	|	ИсточникДанных1.Ссылка КАК Право,
	|	ВЫБОР
	|		КОГДА ИсточникДанных1.Ссылка = &НеОтпускатьТоварСЦенойНижеОпределенногоТипа
	|			ТОГДА &ТипыЦенНоменклатурыПустая
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК Значение
	|ИЗ
	|	ПланВидовХарактеристик.ПраваПользователей КАК ИсточникДанных1
	|ГДЕ
	|	(НЕ ИсточникДанных1.ЭтоГруппа)
	|	И (НЕ ИсточникДанных1.ПометкаУдаления)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	2,
	|	ИсточникДанных1.Ссылка,
	|	ИсточникДанных2.Значение
	|ИЗ
	|	ПланВидовХарактеристик.ПраваПользователей КАК ИсточникДанных1
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияДополнительныхПравПользователя КАК ИсточникДанных2
	|		ПО ИсточникДанных1.Ссылка = ИсточникДанных2.Право
	|ГДЕ
	|	(НЕ ИсточникДанных1.ЭтоГруппа)
	|	И (НЕ ИсточникДанных1.ПометкаУдаления)
	|	И ИсточникДанных2.Пользователь = ЗНАЧЕНИЕ(Справочник.ГруппыПользователей.ВсеПользователи)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	3,
	|	ИсточникДанных1.Ссылка,
	|	ИсточникДанных2.Значение
	|ИЗ
	|	ПланВидовХарактеристик.ПраваПользователей КАК ИсточникДанных1
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияДополнительныхПравПользователя КАК ИсточникДанных2
	|		ПО ИсточникДанных1.Ссылка = ИсточникДанных2.Право
	|			И (ИсточникДанных2.Пользователь В
	|				(ВЫБРАТЬ
	|					ПользователиГруппы.Ссылка.Ссылка КАК Ссылка
	|				ИЗ
	|					Справочник.ГруппыПользователей.Состав КАК ПользователиГруппы
	|				ГДЕ
	|					ПользователиГруппы.Пользователь = &Пользователь))
	|ГДЕ
	|	(НЕ ИсточникДанных1.ЭтоГруппа)
	|	И (НЕ ИсточникДанных1.ПометкаУдаления)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	4,
	|	ИсточникДанных1.Ссылка,
	|	ИсточникДанных2.Значение
	|ИЗ
	|	ПланВидовХарактеристик.ПраваПользователей КАК ИсточникДанных1
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияДополнительныхПравПользователя КАК ИсточникДанных2
	|		ПО ИсточникДанных1.Ссылка = ИсточникДанных2.Право
	|			И (ИсточникДанных2.Пользователь = &Пользователь)
	|ГДЕ
	|	(НЕ ИсточникДанных1.ЭтоГруппа)
	|	И (НЕ ИсточникДанных1.ПометкаУдаления)
	|
	|УПОРЯДОЧИТЬ ПО
	|	Индекс
	|";
	тзДанныеЗапроса=Запрос.Выполнить().Выгрузить();
	Для каждого СтрокаКоллекции Из тзДанныеЗапроса Цикл
		стрПраво=ПланыВидовХарактеристик.ПраваПользователей.ПолучитьИмяПредопределенного(СтрокаКоллекции.Право);
		Если ПустаяСтрока(стрПраво) Тогда Продолжить; КонецЕсли;
		Значение=СтрокаКоллекции.Значение;
		Если Значение=Null Тогда
			Значение=ПланыВидовХарактеристик.ПраваПользователей[стрПраво].ТипЗначения.ПривестиЗначение();
		КонецЕсли;
		СтруктураДопПравПользователя.Вставить(стрПраво, Значение);
	КонецЦикла; 
	ПараметрыСеанса.ДопПраваПользователя=Новый ФиксированнаяСтруктура(СтруктураДопПравПользователя);
	ПараметрыСеанса.БлокировщикСеансов=Ложь;
КонецПроцедуры

Процедура ПараметрыСеансаОбновить_НастройкиПользователя() Экспорт
	
КонецПроцедуры
 
Функция ОпределитьНаличиеДвиженийПоРегистратору(ДокументСсылка) Экспорт
	Если ДокументСсылка=Неопределено Тогда
		Возврат Новый ТаблицаЗначений;
	КонецЕсли;

	МетаданнныеДокумента=ДокументСсылка.Метаданные();
	Если МетаданнныеДокумента.Движения.Количество() = 0 Тогда
		Возврат Новый ТаблицаЗначений;
	КонецЕсли;

	// для исключения падения для документов, проводящимся более чем по 256 таблицам
	ТекстЗапроса=""; счетчик_таблиц = 0;

	Для Каждого Движение ИЗ МетаданнныеДокумента.Движения Цикл
		// в запросе получаем имена регистров, по которым есть хотя бы одно движение
		// например,
		// ВЫБРАТЬ Первые 1 «РегистрНакопления.ПартииТоваровНаСкладах»
		// ИЗ РегистрНакопления.ПартииТоваровНаСкладах
		// ГДЕ Регистратор = &Регистратор
		
		// имя регистра приводим к Строка(200), см. ниже
		ТекстЗапроса = ТекстЗапроса + "
		|" + ?(ТекстЗапроса = "", "", "ОБЪЕДИНИТЬ ВСЕ ") + "
		|ВЫБРАТЬ ПЕРВЫЕ 1 ВЫРАЗИТЬ(""" + Движение.ПолноеИмя() 
		+  """ КАК Строка(200)) КАК Имя ИЗ " + Движение.ПолноеИмя() 
		+ " ГДЕ Регистратор = &Регистратор";
		
		// если в запрос попадает более 256 таблиц – разбиваем его на две части
		// (вариант документа с проведением по 512 регистрам считаем нежизненным)
		счетчик_таблиц = счетчик_таблиц + 1;
		Если счетчик_таблиц = 256 Тогда Прервать; КонецЕсли;		
	КонецЦикла;
	
	Запрос=Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Регистратор", ДокументСсылка);
	// при выгрузке для колонки «Имя» тип устанавливается по самой длинной строке из запроса
	// при втором проходе по таблице новое имя может не «влезть», по этому сразу в запросе
	// приводится к строка(200)
	ТаблицаЗапроса = Запрос.Выполнить().Выгрузить();
	
	// если количество таблиц не превысило 256 – возвращаем таблицу
	Если счетчик_таблиц = МетаданнныеДокумента.Движения.Количество() Тогда
		Возврат ТаблицаЗапроса;			
	КонецЕсли;
	
	// таблиц больше чем 256, делаем доп. запрос и дополняем строки таблицы.
	
	ТекстЗапроса = "";
	Для Каждого Движение ИЗ МетаданнныеДокумента.Движения Цикл
		
		Если счетчик_таблиц > 0 Тогда
			счетчик_таблиц = счетчик_таблиц - 1;
			Продолжить;
		КонецЕсли;
		
		ТекстЗапроса = ТекстЗапроса + "
		|" + ?(ТекстЗапроса = "", "", "ОБЪЕДИНИТЬ ВСЕ ") + "
		|ВЫБРАТЬ ПЕРВЫЕ 1 """ + Движение.ПолноеИмя() +  """ КАК Имя ИЗ " 
		+ Движение.ПолноеИмя() + " ГДЕ Регистратор = &Регистратор";	
		
	КонецЦикла;
	Запрос.Текст = ТекстЗапроса;
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		СтрокаТаблицы = ТаблицаЗапроса.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТаблицы, Выборка);
	КонецЦикла;
	
	Возврат ТаблицаЗапроса;
	
КонецФункции

Процедура ЗаписатьНаборЗаписейНаСервере(ИмяРегистра, Регистратор, ТаблицаДвижений = Неопределено) Экспорт	
	
	Набор = РегистрыНакопления[ИмяРегистра].СоздатьНаборЗаписей();
	Набор.Отбор.Регистратор.Установить(Регистратор);
	Если ТаблицаДвижений <> Неопределено Тогда
		Набор.мТаблицаДвижений = ТаблицаДвижений;
		ОбщегоНазначения.ВыполнитьДвижениеПоРегистру(Набор);
	КонецЕсли;
	Набор.Записать();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ ПРОВЕРКИ ПРИ ЗАПИСИ НОМЕНКЛАТУРЫ

// Функция проверяет, существуют ли ссылки на единицу измерения в движениях регистров накопления.
// Если есть - нельзя менять коэффицент
//
// Параметры:
//  СуществуютСсылки - булево, переменная, в которой сохраняется результат работы функции, чтобы
//                     при последующих вызовах заново не считать функцию.
//
// Возвращаемое значение:
//  Истина - если есть движения, Ложь - если нет.
//
Функция Номенклатура_СуществуютСсылки(Ссылка, СуществуютСсылки) Экспорт

	Если НЕ ЗначениеЗаполнено(Ссылка) Тогда
		Возврат Ложь;
	ИначеЕсли СуществуютСсылки <> Неопределено Тогда
		Возврат СуществуютСсылки; // уже было рассчитано
	КонецЕсли;
	
	ТипНоменклатура = Тип("СправочникСсылка.Номенклатура");
	
	Запрос=Новый Запрос();
	Запрос.УстановитьПараметр("ТекущийВладелец", Ссылка);
	Запрос.Текст="";

	Для Каждого РегистрНакопления Из Метаданные.РегистрыНакопления Цикл
		Для Каждого РеквизитРегистра Из РегистрНакопления.Измерения Цикл
			Если РеквизитРегистра.Тип.СодержитТип(ТипНоменклатура) Тогда
				Если Запрос.Текст <> "" Тогда
					Запрос.Текст = Запрос.Текст + "
					|ОБЪЕДИНИТЬ ВСЕ
					|";
				КонецЕсли;
				Запрос.Текст = Запрос.Текст + "
				|ВЫБРАТЬ ПЕРВЫЕ 1
				|	1 КАК Результат
				|ИЗ
				|	РегистрНакопления." + РегистрНакопления.Имя + " КАК Рег
				|ГДЕ
				|	Рег." + РеквизитРегистра.Имя + " = &ТекущийВладелец
				|";
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;

	Возврат Не Запрос.Выполнить().Пустой();

КонецФункции

// Функция проверяет, существуют ли ссылки на серию  в движениях регистров накопления.
//
// Параметры:
//
// Возвращаемое значение:
//  Истина - если есть движения, Ложь - если нет.
//
Функция Номенклатура_СуществуютСсылкиНаСерииВРегистрахНакопления(Ссылка) Экспорт
	
	ТипСерия = Тип("СправочникСсылка.СерииНоменклатуры");
	
	Запрос=Новый Запрос();
	Запрос.УстановитьПараметр("Номенклатура", Ссылка);	
	Запрос.Текст="";

	Для Каждого РегистрНакопления Из Метаданные.РегистрыНакопления Цикл
		Для Каждого РеквизитРегистра Из РегистрНакопления.Измерения Цикл
			Если РеквизитРегистра.Тип.СодержитТип(ТипСерия) Тогда
				Если Запрос.Текст <> "" Тогда
					Запрос.Текст = Запрос.Текст + "
					|ОБЪЕДИНИТЬ ВСЕ
					|";
				КонецЕсли;
				Запрос.Текст = Запрос.Текст + "
				|ВЫБРАТЬ ПЕРВЫЕ 1
				|	1 КАК Результат
				|ИЗ
				|	РегистрНакопления." + РегистрНакопления.Имя + " КАК Рег
				|ГДЕ
				|	Рег." +РеквизитРегистра.Имя + " <> ЗНАЧЕНИЕ(Справочник.СерииНоменклатуры.ПустаяСсылка)
				|	И Рег." + РеквизитРегистра.Имя + ".Владелец = &Номенклатура
				|";
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;

	Возврат Не Запрос.Выполнить().Пустой();

КонецФункции

// Функция проверяет, существуют ли ссылки на вид номенклатуры в справочнике "Номенклатура".
// Если есть - нельзя менять коэффицент
//
// Параметры:
//  СуществуютСсылки - булево, переменная, в которой сохраняется результат работы функции, чтобы
//                     при последующих вызовах заново не считать функцию.
//
// Возвращаемое значение:
//  Истина - если есть движения, Ложь - если нет.
//
Функция ВидыНоменклатуры_СуществуютСсылкиВНоменклатуре(Ссылка, СуществуютСсылки) Экспорт

	Если НЕ ЗначениеЗаполнено(Ссылка) Тогда
		Возврат Ложь;
	ИначеЕсли СуществуютСсылки <> Неопределено Тогда
		Возврат СуществуютСсылки; // уже было рассчитано
	КонецЕсли;
	
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("ТекущийЭлемент", Ссылка);
	Запрос.Текст = "
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	Номенклатура.Ссылка
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.ВидНоменклатуры = &ТекущийЭлемент
	|";	
	СуществуютСсылки = НЕ Запрос.Выполнить().Пустой();

	Возврат СуществуютСсылки;
КонецФункции

Функция Кассы_СуществуютСсылки(Касса) Экспорт
	Запрос=Новый Запрос();
	Запрос.УстановитьПараметр("Касса", Касса);
	Запрос.Текст=" 
	|ВЫБРАТЬ РАЗЛИЧНЫЕ ПЕРВЫЕ 1
	|	РегистрНакопления.ДенежныеСредства.Регистратор КАК Документ
	|ИЗ
	|	РегистрНакопления.ДенежныеСредства
	|ГДЕ
	|	РегистрНакопления.ДенежныеСредства.БанковскийСчетКасса = &Касса
	|";
	Возврат НЕ Запрос.Выполнить().Пустой();
КонецФункции

Процедура ОбработатьУстановкуВозможногоПрефиксаИнформационнойБазы(Значение) Экспорт
	Если ПустаяСтрока(Значение) Тогда Возврат; КонецЕсли;
	
	Запрос=Новый Запрос();
	Запрос.УстановитьПараметр("Префикс", Значение);
	Запрос.Текст="
	|ВЫБРАТЬ Первые 1 1
	|	
	|ИЗ
	|	РегистрСведений.ПрефиксыИнформационныхБаз КАК ПрефиксыИнформационныхБаз
	|ГДЕ
	|	ПрефиксыИнформационныхБаз.Префикс = &Префикс
	|";
	РезультатЗапроса=Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда Возврат; КонецЕсли;
	
	НаборЗаписейРегистра=РегистрыСведений.ПрефиксыИнформационныхБаз.СоздатьНаборЗаписей();
	НаборЗаписейРегистра.Отбор.Префикс.Установить(Значение);
	
	СтрокаРегистра=НаборЗаписейРегистра.Добавить();
	СтрокаРегистра.Префикс=Значение;

	НаборЗаписейРегистра.Записать();	
КонецПроцедуры

//Процедура ОпределитьФактИспользованияРИБ() Экспорт
//	//Проверка использования РИБ1 (полный)
//	Запрос=Новый Запрос;
//	Запрос.УстановитьПараметр("ЭтотУзел", ПланыОбмена.Полный.ЭтотУзел());
//	Запрос.Текст="
//	|ВЫБРАТЬ
//	|	ИсточникДанных.Ссылка
//	|ИЗ
//	|	ПланОбмена.Полный КАК ИсточникДанных
//	|ГДЕ
//	|	ИсточникДанных.Ссылка <> &ЭтотУзел
//	|
//	|";
//	ПараметрыСеанса.ИспользованиеРИБ1=НЕ Запрос.Выполнить().Пустой();
//	ПараметрыСеанса.ПрефиксУзлаРИБ=Константы.ПрефиксУзлаРИБ.Получить();	
//	ПараметрыСеанса.ИдентификаторРИБ="";

//	//Проверка использования РИБ2 (пользовательский)
//	Запрос=Новый Запрос;
//	Запрос.УстановитьПараметр("ЭтотУзел", ПланыОбмена.Пользовательский.ЭтотУзел());
//	Запрос.Текст="
//	|ВЫБРАТЬ
//	|	ИсточникДанных.Ссылка
//	|ИЗ
//	|	ПланОбмена.Полный КАК ИсточникДанных
//	|ГДЕ
//	|	ИсточникДанных.Ссылка <> &ЭтотУзел
//	|
//	|";
//	ПараметрыСеанса.ИспользованиеРИБ2=НЕ Запрос.Выполнить().Пустой();
//КонецПроцедуры

// функция по пользователю ИБ определяет есть ли у него Windows авторизация
Функция НаличиеУПользователяWindowsАвторизации(Знач ИмяПользователяИБ) Экспорт
	
	Если ПустаяСтрока(ИмяПользователяИБ) Тогда Возврат Ложь; КонецЕсли;
	
	// находим пользователя ИБ
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ИмяПользователяИБ);
	Если ПользовательИБ = Неопределено Тогда Возврат Ложь; КонецЕсли;

	Возврат ПользовательИБ.АутентификацияОС;
	
КонецФункции

Функция ПроверитьНаличиеСсылокНаДоговорКонтрагента(ДоговорКонтрагента) Экспорт
	
	Запрос=Новый Запрос();
	Запрос.УстановитьПараметр("ДоговорКонтрагента", ДоговорКонтрагента);
	Запрос.Текст="
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	РегистрСведений.УсловияПоставокПоДоговорамКонтрагентовПоНоменклатуре.ДоговорКонтрагента
	|ГДЕ
	|	ДоговорКонтрагента = &ДоговорКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	РегистрНакопления.ВзаиморасчетыСКонтрагентами.ДоговорКонтрагента
	|ГДЕ
	|	ДоговорКонтрагента = &ДоговорКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	РегистрНакопления.ЗаказыПокупателей.ДоговорКонтрагента
	|ГДЕ
	|	ДоговорКонтрагента = &ДоговорКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	РегистрНакопления.ЗаказыПоставщикам.ДоговорКонтрагента
	|ГДЕ
	|	ДоговорКонтрагента = &ДоговорКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	РегистрНакопления.ПартииТоваровПереданные.ДоговорКонтрагента
	|ГДЕ
	|	ДоговорКонтрагента = &ДоговорКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	РегистрНакопления.ТоварыПереданные.ДоговорКонтрагента
	|ГДЕ
	|	ДоговорКонтрагента = &ДоговорКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	РегистрНакопления.ТоварыПолученные.ДоговорКонтрагента
	|ГДЕ
	|	ДоговорКонтрагента = &ДоговорКонтрагента
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	РегистрНакопления.Продажи.ДоговорКонтрагента
	|ГДЕ
	|	ДоговорКонтрагента = &ДоговорКонтрагента
	|
	|";
	Возврат НЕ Запрос.Выполнить().Пустой();	
КонецФункции

// ПАРТИОННЫЙ УЧЕТ

Функция ПолучитьПараметрыДокументовОприходования(МассивДокументов, Период)  Экспорт
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", МассивДокументов);
	Запрос.УстановитьПараметр("ДатаКурса", Период);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	Пост.ДоговорКонтрагента КАК ДоговорПоставки,
	|	Пост.Сделка,
	|	Пост.ДоговорКонтрагента.ВалютаВзаиморасчетов КАК Валюта,
	|	КурсыВалютСрезПоследних.Курс,
	|	КурсыВалютСрезПоследних.Кратность,
	|	Пост.Ссылка
	|ИЗ
	|	Документ.ПоступлениеТоваровУслуг КАК Пост
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(&ДатаКурса, ) КАК КурсыВалютСрезПоследних
	|		ПО Пост.ДоговорКонтрагента.ВалютаВзаиморасчетов = КурсыВалютСрезПоследних.Валюта
	|ГДЕ
	|	Пост.Ссылка В(&Ссылка)
	|";
	Возврат Запрос.Выполнить().Выбрать();
КонецФункции
