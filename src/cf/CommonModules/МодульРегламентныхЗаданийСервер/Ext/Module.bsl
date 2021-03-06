﻿Процедура ПересчетИтоговРегистровНакопления() Экспорт
	НаДату=НачалоМесяца(ТекущаяДата())-1;	
	ПересчетРегистров(РегистрыНакопления, НаДату, Метаданные.СвойстваОбъектов.ВидРегистраНакопления.Остатки);
КонецПроцедуры

Процедура ПересчетРегистров(МенеджерРегистров, НаДату, ОграничениеПоВидуРегистра = Неопределено)
	Для Каждого МенеджерРегистра ИЗ МенеджерРегистров Цикл
		МетаданныеРегистра = Метаданные.НайтиПоТипу(ТипЗнч(МенеджерРегистра));
		Если ОграничениеПоВидуРегистра <> Неопределено И МетаданныеРегистра.ВидРегистра <> ОграничениеПоВидуРегистра Тогда
			Продолжить;
		КонецЕсли;
		ПересчитатьРегистрПоДате(МенеджерРегистра, НаДату);
	КонецЦикла;	
КонецПроцедуры

Процедура ПересчитатьРегистрПоДате(МенеджерРегистра, НаДату)
	Если МенеджерРегистра.ПолучитьПериодРассчитанныхИтогов()<НаДату Тогда
		МенеджерРегистра.УстановитьПериодРассчитанныхИтогов(НаДату);
	Иначе
		МенеджерРегистра.ПересчитатьИтоги();
	КонецЕсли;	
КонецПроцедуры

Процедура ОбновлениеИндексаПолнотекстовогоПоиска() Экспорт
	Если ПолнотекстовыйПоиск.ПолучитьРежимПолнотекстовогоПоиска() = РежимПолнотекстовогоПоиска.Разрешить Тогда
		Если НЕ ПолнотекстовыйПоиск.ИндексАктуален() Тогда
			Попытка	
				ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", УровеньЖурналаРегистрации.Информация,,,"Начато регламентное индексирование порции");
				ПолнотекстовыйПоиск.ОбновитьИндекс(Ложь, Истина);				
				ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", УровеньЖурналаРегистрации.Информация,,,"Закончено регламентное  индексирование порции");
			Исключение
				ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", УровеньЖурналаРегистрации.Ошибка,,,"Во время регламентного обновления индекса произошла неизвестная ошибка: " + ОписаниеОшибки());
			КонецПопытки;
		КонецЕсли;		
	КонецЕсли;	
Конецпроцедуры

Процедура СлияниеИндексаПолнотекстовогоПоиска() Экспорт
	Если ПолнотекстовыйПоиск.ПолучитьРежимПолнотекстовогоПоиска()=РежимПолнотекстовогоПоиска.Разрешить Тогда
		Попытка	
			ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", УровеньЖурналаРегистрации.Информация,,,"Начато регламентное слияние индексов");
			ПолнотекстовыйПоиск.ОбновитьИндекс(Истина);
			ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", УровеньЖурналаРегистрации.Информация,,,"Закончено регламентное слияние индексов");
		Исключение
			ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", УровеньЖурналаРегистрации.Ошибка,,, "Во время регламентного слияния индекса произошла неизвестная ошибка: " + ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;	
Конецпроцедуры

Функция ВыполнитьКодИзСтроки(стрИсходныйКод) Экспорт
	Попытка Выполнить(стрИсходныйКод);
	Исключение
	КонецПопытки;	
	Возврат ОписаниеОшибки();
КонецФункции

///////////////////////////////////////////
// Универсальные регламентные задания
//

Процедура ВыполнитьРегламентныеЗадания() Экспорт 
	Запрос=Новый Запрос;
	Запрос.Текст="
	|ВЫБРАТЬ
	|	РегламентныеЗадания.Ссылка,
	|	РегламентныеЗадания.Расписание,
	|	ЕСТЬNULL(ПоследнееУспешноеВыполнение.Дата, ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)) КАК ДатаПоследнегоВыполнения,
	|	РегламентныеЗадания.ПорядокВыполнения КАК ПорядокВыполнения
	|ИЗ
	|	Справочник.РегламентныеЗадания КАК РегламентныеЗадания
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РегламентныеЗаданияПоследнееУспешноеВыполнение КАК ПоследнееУспешноеВыполнение
	|		ПО (ПоследнееУспешноеВыполнение.РегламентноеЗадание = РегламентныеЗадания.Ссылка)
	|ГДЕ
	|	РегламентныеЗадания.Активное
	//|	И НЕ ЕСТЬNULL(ПоследнееУспешноеВыполнение.Выполняется, ЛОЖЬ)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ПорядокВыполнения
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(Выборка.Расписание) Тогда Продолжить; КонецЕсли;
		Попытка
			Расписание=ЗначениеИзСтрокиВнутр(Выборка.Расписание);
			Если НЕ Расписание.ТребуетсяВыполнение(,Выборка.ДатаПоследнегоВыполнения, Выборка.ДатаПоследнегоВыполнения) Тогда
				Продолжить;
			КонецЕсли;
		Исключение
			Продолжить; // что-то пошло не так
		КонецПопытки;
		ВыполнитьЗаданиеПоНастройке(Выборка.Ссылка);
	КонецЦикла;	
КонецПроцедуры

Процедура ВыполнитьЗаданиеПоНастройке(Задание) Экспорт
	ДатаВыполнения=ТекущаяДата();

	// поставим пометку о текущем выполнении
	НаборЗаписей=РегистрыСведений.РегламентныеЗаданияПоследнееУспешноеВыполнение.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.РегламентноеЗадание.Установить(Задание);
	НаборЗаписей.Прочитать();
	Если НаборЗаписей.Количество()=0 Тогда // Это задание ещё ни разу не выполнялось, потому создаем новую запись
		РедактируемаяЗапись=НаборЗаписей.Добавить(); 
		РедактируемаяЗапись.РегламентноеЗадание=Задание;
		РедактируемаяЗапись.Дата=ДатаВыполнения; // дата выполнениея - текущая, по этой дате мы потом поймем, что это первое выполнение
		РедактируемаяЗапись.Выполняется=Истина; // если не выполняется - устанавливаем признак, что задание выполняется
	Иначе
		РедактируемаяЗапись=НаборЗаписей[0];
		Если РедактируемаяЗапись.Выполняется Тогда Возврат; КонецЕсли; // может случиться так, что это задание уже выполняется проверим и не будем выполнять его
	КонецЕсли;
	НаборЗаписей.Записать();

	ЗаданиеУспешноВыполнено=Ложь; ОшибкаВыполнения="";

	// инициализируем возвращаемые параметры на случай выполнения процедуры общего модуля
	стрВыполняемыйМодуль=СокрЛП(Задание.ВыполняемыйМетод);
	Если НЕ ПустаяСтрока(стрВыполняемыйМодуль) Тогда
		СтруктураПараметров=Новый Структура;
		Для каждого СтрокаКоллекции Из Задание.Параметры Цикл
			СтруктураПараметров.Вставить(СтрокаКоллекции.Имя, СтрокаКоллекции.Значение);
			стрВыполняемыйМодуль=СтрЗаменить(стрВыполняемыйМодуль, "{"+СтрокаКоллекции.Имя+"}", "СтруктураПараметров["""+СтрокаКоллекции.Имя+"""]");
		КонецЦикла;
		Попытка
			Выполнить(стрВыполняемыйМодуль);
			ЗаданиеУспешноВыполнено=ИСТИНА;
		Исключение
			ЗаданиеУспешноВыполнено=ЛОЖЬ;
			ОшибкаВыполнения=ОписаниеОшибки();
		КонецПопытки;
	КонецЕсли;
	
	ДатаВыполнения=ТекущаяДата();
	
	// отметим выполнение
	НаборЗаписей=РегистрыСведений.РегламентныеЗаданияПоследнееУспешноеВыполнение.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.РегламентноеЗадание.Установить(Задание);
	НаборЗаписей.Прочитать();

	Если ЗаданиеУспешноВыполнено Тогда
		НаборЗаписей.Очистить();
		НоваяЗапись=НаборЗаписей.Добавить();
		НоваяЗапись.РегламентноеЗадание=Задание;
		НоваяЗапись.Дата=ДатаВыполнения;
		НоваяЗапись.Выполняется=Ложь;
	Иначе
		// если задание не выполнилось
		Если НаборЗаписей.Количество()=0 Тогда
			// такого быть не может - в начале данной процедуры мы создали запись
		ИначеЕсли НаборЗаписей[0].Дата = ДатаВыполнения Тогда
			// если это запись созданая в начале данной процедуры - удаляем её
			НаборЗаписей.Очистить();
		Иначе
			// сбрасываем флаг выполнения
			РедактируемаяЗапись=НаборЗаписей[0];
			РедактируемаяЗапись.Выполняется=Ложь;
		КонецЕсли;
	КонецЕсли;
	НаборЗаписей.Записать();

	// запишем лог
	НаборЗаписей=РегистрыСведений.РегламентныеЗаданияРезультатВыполнения.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Период.Установить(ДатаВыполнения);
	НаборЗаписей.Отбор.РегламентноеЗадание.Установить(Задание);
	//Отбор=НаборЗаписей.Отбор.Найти("РегламентноеЗадание");
	//Отбор.Использование	= ИСТИНА;
	//Отбор.ВидСравнения	= ВидСравнения.Равно;
	//Отбор.Значение		= Задание;

	//Отбор=НаборЗаписей.Отбор.Найти("Период");
	//Отбор.Использование	= ИСТИНА;
	//Отбор.ВидСравнения	= ВидСравнения.Равно;
	//Отбор.Значение	\	= ДатаВыполнения;
	НаборЗаписей.Прочитать();
	НаборЗаписей.Очистить();
	
	НоваяЗапись=НаборЗаписей.Добавить();
	НоваяЗапись.РегламентноеЗадание=Задание;
	НоваяЗапись.Период=ДатаВыполнения;
	НоваяЗапись.УспешноеВыполнение=ЗаданиеУспешноВыполнено;
	НоваяЗапись.ОшибкаВыполнения=?(ЗаданиеУспешноВыполнено, "", ОшибкаВыполнения);
	НаборЗаписей.Записать();
КонецПроцедуры