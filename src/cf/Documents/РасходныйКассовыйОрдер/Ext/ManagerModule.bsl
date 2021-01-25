﻿////////////////////////////////////////////////////////////////////////////////
//Управление печатными формами

Процедура СтруктураПечатныхФорм(Структура) Экспорт
	Структура.Вставить("РКО", "Расходный кассовый ордер");
	Структура.Вставить("Заявление", "Заявление подотчетника");
КонецПроцедуры

Функция ИнициализацияМакета(СтруктураПараметров, стрМакет)
	Если СтруктураПараметров.Свойство("Макет") Тогда
		Возврат СтруктураПараметров.Макет;
	КонецЕсли;
	Макет=СтруктураПараметров.МакетШаблон;
	Если Макет=Неопределено Тогда
		Если Метаданные.ОбщиеМакеты.Найти(стрМакет)=Неопределено Тогда
			Макет=ПолучитьМакет(стрМакет);
		Иначе
			Макет=ПолучитьОбщийМакет(стрМакет);
		КонецЕсли;
	КонецЕсли;
	Возврат Макет;
КонецФункции

Функция Печать_РКО(СтруктураПараметров)
	СсылкаНаОбъект=СтруктураПараметров.СсылкаНаОбъект;
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст="ВЫБРАТЬ
	|	Номер,
	|	Дата                          КАК ДатаДокумента,
	|	РасчетныйДокумент,
	|	ВидОперации,
	|	Касса,
	|	Организация,	
	|	Организация                   КАК ЮрФизЛицо,
	|	Организация                   КАК Руководители,
	|	Подразделение,
	|	Подразделение.Представление   КАК ПредставлениеПодразделения,
	|	СуммаДокумента                КАК Сумма,
	|	Контрагент,
	|	Контрагент.Представление      КАК ФИОПолучателя,
	|	Выдать,
	|	Приложение,
	|	ПоДокументу,
	|	Основание
	|ИЗ
	|	Документ.РасходныйКассовыйОрдер КАК РасходныйКассовыйОрдер
	|
	|ГДЕ
	|	РасходныйКассовыйОрдер.Ссылка = &ТекущийДокумент
	|";
	Шапка=Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	ТабДокумент=Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_РасходныйКассовыйОрдер_КО2";
	
	Макет=ИнициализацияМакета(СтруктураПараметров, "КО2");
	ОбластьМакета=Макет.ПолучитьОбласть("Шапка");

	СведенияОбОрганизации=КонтактнаяИнформацияСервер.СведенияОЮрФизЛице(Шапка.ЮрФизЛицо, Шапка.ДатаДокумента);
	
	// Выводим шапку накладной
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ОбластьМакета.Параметры.ПредставлениеОрганизации   = ПечатныеФормыСервер.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование,");
	ОбластьМакета.Параметры.ПредставлениеПодразделения = Шапка.ПредставлениеПодразделения;
	ОбластьМакета.Параметры.СуммаПрописью     = ?(НЕ Шапка.Касса.ВалютаДенежныхСредств = МодульВалютногоУчета.ПолучитьВалюту("Бух"), ОбщегоНазначения.СформироватьСуммуПрописью(Шапка.Сумма, Шапка.Касса.ВалютаДенежныхСредств), РубКопПрописью(Шапка.Сумма));
	ОбластьМакета.Параметры.ОрганизацияПоОКПО = СведенияОбОрганизации.КодПоОКПО;
	ОбластьМакета.Параметры.ДатаДокумента     = Шапка.ДатаДокумента;
	ОбластьМакета.Параметры.НомерДокумента    = ОбщегоНазначенияСервер.НомерНаПечать(СсылкаНаОбъект);
	//ОбластьМакета.Параметры.Получил
	
	КодыСчетСубсчет=ОпределитьКодыСчетСубсчет(СтруктураПараметров);
	
	ОбластьМакета.Параметры.ДебетСубСчет=КодыСчетСубсчет.Дебет;
	ОбластьМакета.Параметры.КредитСубСчет=КодыСчетСубсчет.Кредит;

	Руководители = ПечатныеФормыСервер.ОтветственныеЛицаОрганизации(Шапка.Руководители, КонецДня(Шапка.ДатаДокумента), СсылкаНаОбъект);
	Руководитель = Руководители.Руководитель;
	РуководительДолжность = Руководители.РуководительДолжность;
	Бухгалтер    = Руководители.ГлавныйБухгалтер;
	Кассир       = Руководители.Кассир;

	ОбластьМакета.Параметры.ФИОРуководителя       = Руководитель;
	ОбластьМакета.Параметры.ДолжностьРуководителя = РуководительДолжность;

	ОбластьМакета.Параметры.ФИОГлавногоБухгалтера = Бухгалтер;
	ОбластьМакета.Параметры.ФИОКассира            = Кассир;
	
	ТекстОснование=Шапка.Основание;
	
	Если ТекстОснование="" И ЗначениеЗаполнено(Шапка.РасчетныйДокумент) Тогда
		ТекстОснование=Лев(Строка(Шапка.РасчетныйДокумент),Найти(Строка(Шапка.РасчетныйДокумент),Строка(Шапка.РасчетныйДокумент.Дата))-1)+Формат(Шапка.РасчетныйДокумент.Дата,"ДФ=dd.MM.yyyy");
	КонецЕсли;

	ОбластьМакета.Параметры.Основание = ТекстОснование;
	ОбластьМакета.Параметры.Приложение = Шапка.Приложение;
	
	ОбластьМакета.Параметры.ФИОПолучателя = Шапка.Выдать;
	Попытка
		ОбластьМакета.Параметры.РеквизитыДокументаУдостоверяющегоЛичность = ?(ЗначениеЗаполнено(Шапка.ПоДокументу),Шапка.ПоДокументу,?(Шапка.Контрагент.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо,Шапка.Контрагент.ДокументУдостоверяющийЛичность,""));
	Исключение
	КонецПопытки;

	Если СтруктураПараметров.Свойство("МодульПечати") Тогда
		стрТекстМодуля=СтруктураПараметров.МодульПечати.ПараметрыПечатнойФормы.ТекстМодуля;
		Если Не ПустаяСтрока(стрТекстМодуля) Тогда Выполнить(стрТекстМодуля); КонецЕсли;
	КонецЕсли;	

	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;
КонецФункции

Функция Печать_Заявление(СтруктураПараметров)
	СсылкаНаОбъект=СтруктураПараметров.СсылкаНаОбъект;
	
	ТабДокумент=Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_РасходныйКассовыйОрдер_Заявление";
	Макет=ИнициализацияМакета(СтруктураПараметров, "Заявление");
	
	Макет.Параметры.Организация=СсылкаНаОбъект.Организация.Наименование;
	Руководители=ПечатныеФормыСервер.ОтветственныеЛицаОрганизации(СсылкаНаОбъект.Организация, КонецДня(СсылкаНаОбъект.Дата), СсылкаНаОбъект);
	
	СтруктураФИОРуководителя=ПечатныеФормыСервер.ФамилияИмяОтчество(Руководители.РуководительФизЛицо, СсылкаНаОбъект.Дата);

    Попытка стрПол=СокрЛП(Руководители.РуководительФизЛицо.Пол);
	Исключение стрПол="";
	КонецПопытки; 

	Макет.Параметры.ФИОРуководителя=УправлениеКонфигурациейСервер.ВыполнитьСклонениеСлова(СтруктураФИОРуководителя.Фамилия, стрПол, "Фамилия").Дательный+" "+Лев(СтруктураФИОРуководителя.Имя, 1)+"."+Лев(СтруктураФИОРуководителя.Отчество, 1)+".";
	Макет.Параметры.ФИОРуководителя2=Руководители.Руководитель;
	Если ТипЗнч(СсылкаНаОбъект.Контрагент)=Тип("СправочникСсылка.ФизическиеЛица") Тогда
		Если ЗначениеЗаполнено(СсылкаНаОбъект.Контрагент) Тогда
			СтруктураФИО=ПечатныеФормыСервер.ФамилияИмяОтчество(СсылкаНаОбъект.Контрагент, СсылкаНаОбъект.Дата); стрПол=СокрЛП(СсылкаНаОбъект.Контрагент.Пол);
			Макет.Параметры.ФИОФизЛица=УправлениеКонфигурациейСервер.ВыполнитьСклонениеСлова(СтруктураФИО.Фамилия, стрПол, "Фамилия").Дательный+" "+Лев(СтруктураФИО.Имя, 1)+"."+Лев(СтруктураФИО.Отчество, 1)+".";
		КонецЕсли;
	КонецЕсли;

	Макет.Параметры.Дата=Формат(СсылкаНаОбъект.Дата,"ДЛФ=DD");
	Макет.Параметры.Сумма=СокрЛП(СсылкаНаОбъект.СуммаДокумента)+" руб.";
	Макет.Параметры.СуммаПрописью=РубКопПрописью(СсылкаНаОбъект.СуммаДокумента);
	ТабДокумент.Вывести(Макет);

	Возврат ТабДокумент;	
КонецФункции	
	
Функция РубКопПрописью(Сумма)
	Возврат ЧислоПрописью(Сумма, , "рубль,рубля,рублей,м,копейка,копейки,копеек,ж");
КонецФункции

Функция ОпределитьКодыСчетСубсчет(СтруктураПараметров) 
	КодыСчетов=Новый Структура;
	КодыСчетов.Вставить("Дебет", "");
	КодыСчетов.Вставить("Кредит", "");

	ТОП=СтруктураПараметров.СсылкаНаОбъект.РасшифровкаПлатежа[0].ТОП;
	Если Не ТОП.Пустая() Тогда
		Если ТОП.ПроводкиБУ.Количество()>0 Тогда
			Прводка=ТОП.ПроводкиБУ[0];
			КодыСчетов.Дебет=Прводка.СчетДебет;
			КодыСчетов.Кредит=Прводка.СчетКредит;
		КонецЕсли;
	КонецЕсли;	
	Возврат КодыСчетов;	
КонецФункции

Функция Печать(СтруктураПараметров, КоличествоЭкземпляров=1, НаПринтер=Ложь, ТабДокумент=Неопределено) Экспорт
	Если СтруктураПараметров.ИмяМакета="РКО" Тогда
		ТабДокумент=Печать_РКО(СтруктураПараметров);

	ИначеЕсли СтруктураПараметров.ИмяМакета="Заявление" Тогда
		ТабДокумент=Печать_Заявление(СтруктураПараметров);
	КонецЕсли;

	Возврат ТабДокумент;
КонецФункции