﻿////////////////////////////////////////////////////////////////////////////////////////
//ПРОЦЕДУРЫ - ОБРАБОТЧИКИ ЭЛЕМЕНТОВ ФОРМЫ

&НаКлиенте
Процедура РегламентныеЗаданияВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если Элементы.РегламентныеЗадания.ТекущиеДанные=Неопределено Тогда Возврат; КонецЕсли;

	СтруктураПараметров=Новый Структура;
	СтруктураПараметров.Вставить("УникальныйИдентификатор", Элементы.РегламентныеЗадания.ТекущиеДанные.УникальныйИдентификатор);
	ОткрытьФорму(ЭтотОбъект.ИмяФормы+"РегламентногоЗадания", СтруктураПараметров, ЭтотОбъект,,,,Новый ОписаниеОповещения("ОбновитьФорму", ЭтаФорма)); 				
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьФорму(РезультатЗакрытия=Неопределено, ДополнительныеПараметры=Неопределено) Экспорт 
	ОбновитьСписокРегламентныхЗаданийНаСервере();
	ОбновитьСписокФоновыхЗаданийНаСервере();	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////////////
//ПРОЦЕДУРЫ - ОБРАБОТЧИКИ КОМАНД ФОРМЫ

//Обновление Регламентные задания
&НаСервере
Процедура ОбновитьСписокРегламентныхЗаданийНаСервере()
	
	Объект.РегламентныеЗадания.Очистить();
	
	МассивЗаданий=РегламентныеЗадания.ПолучитьРегламентныеЗадания();
	
	Для Каждого Элемент Из МассивЗаданий Цикл		
		НоваяСтрока=Объект.РегламентныеЗадания.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока,Элемент);		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокРегламентныхЗаданий(Команда)
	
	ОбновитьСписокРегламентныхЗаданийНаСервере();
	
КонецПроцедуры

//Добавление нового регламентного задания
&НаКлиенте
Процедура ДобавитьЗадание(Команда)
	
	ОткрытьФорму(ЭтотОбъект.ИмяФормы+"РегламентногоЗадания",,ЭтотОбъект,,,,Новый ОписаниеОповещения("ОбновитьФорму", ЭтотОбъект) ); 
	
КонецПроцедуры

//Удаление регламентного задания
&НаСервере
Процедура УдалитьЗаданиеНаСервере(УникальныйИдентификатор)
	
	Идентификатор = Новый УникальныйИдентификатор(УникальныйИдентификатор);
	Задание=РегламентныеЗадания.НайтиПоУникальномуИдентификатору(Идентификатор);
	Задание.Удалить();	
	
	ОбновитьСписокРегламентныхЗаданийНаСервере();
	ОбновитьСписокФоновыхЗаданийНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьЗадание(Команда)
	
	Если Элементы.РегламентныеЗадания.ТекущиеДанные<>Неопределено Тогда
		
		ТекущаяСтрока=Элементы.РегламентныеЗадания.ТекущиеДанные;			
		Если ТекущаяСтрока.Предопределенное Тогда
			Сообщить("Нельзя удалять предопределенные задания");	
		Иначе
			УдалитьЗаданиеНаСервере(ТекущаяСтрока.УникальныйИдентификатор);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

//Выполнение регламентного задания
&НаСервере
Процедура ВыполнитьЗаданиеНаСервере(УникальныйИдентификатор)
	
	Идентификатор = Новый УникальныйИдентификатор(УникальныйИдентификатор);
	Задание = РегламентныеЗадания.НайтиПоУникальномуИдентификатору(Идентификатор);
	Если Задание.Использование Тогда
		
		//проверика на выполнение в текущий момент
		Отбор=Новый Структура;
		Отбор.Вставить("Ключ",Строка(Задание.УникальныйИдентификатор));
		Отбор.Вставить("Состояние ",СостояниеФоновогоЗадания.Активно);		
		МассивЗаданий=ФоновыеЗадания.ПолучитьФоновыеЗадания(Отбор);
		
		Если МассивЗаданий.Количество()=0 Тогда 
			НаименованиеФоновогоЗадания = "Запуск вручную: "+ Задание.Метаданные.Синоним;
			ФоновоеЗадание = ФоновыеЗадания.Выполнить(Задание.Метаданные.ИмяМетода, Задание.Параметры, Строка(Задание.УникальныйИдентификатор), НаименованиеФоновогоЗадания);
		Иначе
			Сообщить("Задание уже запущено");
		КонецЕсли;
		
	КонецЕсли;
	
	ОбновитьСписокРегламентныхЗаданийНаСервере();
	ОбновитьСписокФоновыхЗаданийНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьЗадание(Команда)
	
	Если Элементы.РегламентныеЗадания.ТекущиеДанные<>Неопределено Тогда		
		ТекущаяСтрока=Элементы.РегламентныеЗадания.ТекущиеДанные;	
		ВыполнитьЗаданиеНаСервере(ТекущаяСтрока.УникальныйИдентификатор);		
	КонецЕсли;	
	
КонецПроцедуры

//События комант  Фоновые задания

&НаСервере
Процедура ОбновитьСписокФоновыхЗаданийНаСервере()
	Объект.ФоновыеЗадания.Очистить();
	
	МассивЗаданий=ФоновыеЗадания.ПолучитьФоновыеЗадания();	
	Для Каждого СтрокаКоллекции Из МассивЗаданий Цикл
		НоваяСтрока=Объект.ФоновыеЗадания.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКоллекции);	
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокФоновыхЗаданий(Команда)
	ОбновитьСписокФоновыхЗаданийНаСервере();	
КонецПроцедуры

//Отмена фонового задания
&НаСервере
Процедура ОтменитьЗаданиеНаСервере(УникальныйИдентификатор)
	Задание=ФоновыеЗадания.НайтиПоУникальномуИдентификатору(Новый УникальныйИдентификатор(УникальныйИдентификатор));
	Задание.Отменить();

	ОбновитьСписокРегламентныхЗаданийНаСервере();
	ОбновитьСписокФоновыхЗаданийНаСервере();	
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьЗадание(Команда)
	Если НЕ Элементы.ФоновыеЗадания.ТекущиеДанные=Неопределено Тогда		
		ОтменитьЗаданиеНаСервере(Элементы.ФоновыеЗадания.ТекущиеДанные.УникальныйИдентификатор);		
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОбновитьСписокРегламентныхЗаданийНаСервере();
	ОбновитьСписокФоновыхЗаданийНаСервере();	
КонецПроцедуры