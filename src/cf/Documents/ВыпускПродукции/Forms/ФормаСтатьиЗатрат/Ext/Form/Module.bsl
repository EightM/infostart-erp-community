﻿&НаСервереБезКонтекста
Функция СформироватьСтруктураТабличнойЧасти(ИмяТабличнойЧасти)
	Структура=Новый Структура;
	Для каждого мдРеквизит Из Метаданные.Документы.ВыпускПродукции.ТабличныеЧасти[ИмяТабличнойЧасти].Реквизиты Цикл
		Структура.Вставить(мдРеквизит.Имя);
	КонецЦикла; 
	Возврат Структура;
КонецФункции

&НаКлиенте
Процедура ОК(Команда)
	СтруктураВозврата=СформироватьСтруктураТабличнойЧасти(ИмяТЧ);
	СтруктураВозврата.Вставить("ИмяТЧ", ИмяТЧ);
	СтруктураВозврата.Вставить("Редактирование", Редактирование);
	ЗаполнитьЗначенияСвойств(СтруктураВозврата, ЭтаФорма);
	ЭтаФорма.Закрыть(СтруктураВозврата);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Редактирование=Ложь;
	Если Не Параметры.ДанныеСтроки=Неопределено Тогда
		ЗаполнитьЗначенияСвойств(ЭтаФорма, Параметры.ДанныеСтроки);
		Редактирование=Истина;
	КонецЕсли; 
	ИмяТЧ=Параметры.ИмяТЧ;
	Заголовок="Редактирование статьи затрат";
КонецПроцедуры