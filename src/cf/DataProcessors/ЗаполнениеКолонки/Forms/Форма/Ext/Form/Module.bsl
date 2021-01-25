﻿&НаСервере
Функция СтроковоеПредставлениеТипа(Тип) Экспорт
	Если ОбщегоНазначенияСервер.ЭтоСсылка(Тип) Тогда
		Представление="";
		ПолноеИмя=Метаданные.НайтиПоТипу(Тип).ПолноеИмя();
		ИмяОбъекта=РазложитьСтрокуВМассивПодстрок(ПолноеИмя, ".")[1];
		
		Если Справочники.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="СправочникСсылка";
		
		ИначеЕсли Документы.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="ДокументСсылка";
		
		ИначеЕсли БизнесПроцессы.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="БизнесПроцессСсылка";
		
		ИначеЕсли ПланыВидовХарактеристик.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="ПланВидовХарактеристикСсылка";
		
		ИначеЕсли ПланыСчетов.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="ПланСчетовСсылка";
		
		ИначеЕсли ПланыВидовРасчета.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="ПланВидовРасчетаСсылка";
		
		ИначеЕсли Задачи.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="ЗадачаСсылка";
		
		ИначеЕсли ПланыОбмена.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="ПланОбменаСсылка";
		
		ИначеЕсли Перечисления.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление="ПеречислениеСсылка";		
		КонецЕсли;
		
		Возврат ?(Представление="", Представление, Представление+"."+ИмяОбъекта);		
	КонецЕсли;
	
	Возврат Строка(Тип);	
КонецФункции

&НаСервере
Функция РазложитьСтрокуВМассивПодстрок(Знач Строка, Знач Разделитель = ",", Знач ПропускатьПустыеСтроки = Неопределено, СокращатьНепечатаемыеСимволы = Ложь) Экспорт
	
	Результат = Новый Массив;
	
	// для обеспечения обратной совместимости
	Если ПропускатьПустыеСтроки = Неопределено Тогда
		ПропускатьПустыеСтроки = ?(Разделитель = " ", Истина, Ложь);
		Если ПустаяСтрока(Строка) Тогда 
			Если Разделитель = " " Тогда
				Результат.Добавить("");
			КонецЕсли;
			Возврат Результат;
		КонецЕсли;
	КонецЕсли;
	//
	
	Позиция = Найти(Строка, Разделитель);
	Пока Позиция > 0 Цикл
		Подстрока = Лев(Строка, Позиция - 1);
		Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Подстрока) Тогда
			Если СокращатьНепечатаемыеСимволы Тогда
				Результат.Добавить(СокрЛП(Подстрока));
			Иначе
				Результат.Добавить(Подстрока);
			КонецЕсли;
		КонецЕсли;
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
		Позиция = Найти(Строка, Разделитель);
	КонецЦикла;
	
	Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Строка) Тогда
		Если СокращатьНепечатаемыеСимволы Тогда
			Результат.Добавить(СокрЛП(Строка));
		Иначе
			Результат.Добавить(Строка);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции 

&НаКлиенте
Процедура ВыполнитьЗаполнение(Команда)
	тпСсылка=ВладелецФормы.Элементы[ТабличнаяЧасть];
	тчСсылка=ВладелецФормы.Объект[ТабличнаяЧасть];
	ВладелецФормы=тпСсылка.ТекущийЭлемент; Счетчик=0;
	Для Каждого ТекущаяСтрока Из тчСсылка Цикл
		НовоеЗначениеЯчейки=ЗначениеЗаполнения;
		тпСсылка.ТекущаяСтрока=ТекущаяСтрока.ПолучитьИдентификатор();
		текЗначение=ТекущаяСтрока[ПолеЗаполнения];
		Если УсловиеЗаполнения="Заполненные" Тогда
			Если НЕ ЗначениеЗаполнено(текЗначение) Тогда Продолжить; КонецЕсли;
		ИначеЕсли УсловиеЗаполнения="НеЗаполненные" Тогда
			Если ЗначениеЗаполнено(текЗначение) Тогда Продолжить; КонецЕсли;
		ИначеЕсли УсловиеЗаполнения="Заменить" Тогда
			Если НЕ текЗначение=СтароеЗначениеЗаполнения Тогда Продолжить; КонецЕсли;	
		КонецЕсли;
		Если Не ПустаяСтрока(МатематическаяОперация) Тогда
			Выполнить("НовоеЗначениеЯчейки=текЗначение"+МатематическаяОперация+"ЗначениеЗаполнения");
			Если ОкруглитьДо>0 Тогда НовоеЗначениеЯчейки=Окр(НовоеЗначениеЯчейки, ОкруглитьДо); КонецЕсли; 
		КонецЕсли;		
		тпСсылка.ИзменитьСтроку();
		ЭтаФорма.ОповеститьОВыборе(НовоеЗначениеЯчейки); Счетчик=Счетчик+1;
		тпСсылка.ЗакончитьРедактированиеСтроки(Ложь);
	КонецЦикла;
	тпСсылка.Обновить();
	
	//ОписаниеОповещения=Новый ОписаниеОповещения("ЗакрытьФормуОбработки", ЭтотОбъект);
	//ПоказатьПредупреждение(ОписаниеОповещения, "Изменено "+СокрЛП(Счетчик)+" строк");
	ПоказатьОповещениеПользователя("Заполнение колонки",, "Изменено "+СокрЛП(Счетчик)+" строк", БиблиотекаКартинок.ДиалогИнформация);	
КонецПроцедуры

//&НаКлиенте
//Процедура ЗакрытьФормуОбработки(Параметр1) Экспорт 
//	Если ЭтаФорма.Открыта()Тогда
//		ЭтаФорма.Закрыть();
//	КонецЕсли;
//КонецПроцедуры 

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибтов

&НаКлиенте
Процедура Атрибут_ПриИзменении(Элемент)
	Если Элемент.Имя="ЗначениеЗаполнения" Тогда 
		ИсходнаяСтрока="Значение заполнения"; 
		Если НЕ ЗначениеЗаполнения=СтароеЗначениеЗаполнения Тогда
			СтрокаСтароеЗначение=" (Старое значение: "+Строка(СтароеЗначениеЗаполнения)+" )"; 
			Элементы.ГруппаЗначение.Заголовок=ИсходнаяСтрока+СтрокаСтароеЗначение; 
		Иначе	
			Элементы.ГруппаЗначение.Заголовок=ИсходнаяСтрока;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	//тчТовары=ДанныеФормыВЗначение(Параметры.Объект, Тип("ДокументОбъект.РеализацияТоваровУслуг")).Товары;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если НЕ ТипЗнч(ВладелецФормы)=Тип("УправляемаяФорма") Тогда
		ПоказатьПредупреждение(, "Форма не открывается без параметров!"); Отказ=Истина; Возврат;
	КонецЕсли;
	
	Если НЕ ТипЗнч(ВладелецФормы.ТекущийЭлемент.ТекущийЭлемент)=Тип("ПолеФормы") Тогда
		ПоказатьПредупреждение(, "Форма не открывается без параметров!"); Отказ=Истина; Возврат;
	КонецЕсли;
	
	Если НЕ ВладелецФормы.ТекущийЭлемент.ТекущийЭлемент.Вид=ВидПоляФормы.ПолеВвода Тогда
		ПоказатьПредупреждение(, "Не является полем ввода!"); Отказ=Истина; Возврат;
	КонецЕсли;
	
	Если ВладелецФормы.ТекущийЭлемент.ТекущийЭлемент.ТолькоПросмотр Тогда
		ПоказатьПредупреждение(, "Текущая колонка только для просмотра!"); Отказ=Истина; Возврат;
	КонецЕсли;
		
	ТабличнаяЧасть=ВладелецФормы.ТекущийЭлемент.Имя;
	ТекущееПоле=ВладелецФормы.ТекущийЭлемент.ТекущийЭлемент.Имя;
	ПолеЗаполнения=СтрЗаменить(ТекущееПоле, ТабличнаяЧасть, "");
	ЗначениеЗаполнения=ВладелецФормы.ТекущийЭлемент.ТекущиеДанные[ПолеЗаполнения];
	СтароеЗначениеЗаполнения=ЗначениеЗаполнения;
	ТипЗначенияЗаполнения=СтроковоеПредставлениеТипа(ТипЗнч(ЗначениеЗаполнения)); 
	
	ЭтаФорма.Элементы.ЗначениеЗаполнения.ОграничениеТипа=Новый ОписаниеТипов(ТипЗначенияЗаполнения); 
	ЭтаФорма.Элементы.ЗначениеЗаполнения.ВыбиратьТип=Ложь;
	
	УсловиеЗаполнения="Все"; //МатематическаяОперация="*";
	
	Элементы.ГруппаМатОперации.Доступность=ТипЗначенияЗаполнения="Число";
КонецПроцедуры