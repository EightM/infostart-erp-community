﻿&НаКлиенте
Процедура ВыполнитьДействие(Команда)
	СтруктураПараметров=Новый Структура;
	СтруктураПараметров.Вставить("ЗапрашиватьКоличествоВесовогоТовара", ЗапрашиватьКоличествоВесовогоТовара);
	СтруктураПараметров.Вставить("ЗапрашиватьКоличествоОбычногоТовара", ЗапрашиватьКоличествоОбычногоТовара);
	СтруктураПараметров.Вставить("ПоказыватьЦены", ПоказыватьЦены);
	СтруктураПараметров.Вставить("ПоказыватьОстатки", ПоказыватьОстатки);
	СтруктураПараметров.Вставить("ПоказыватьПотребности", ПоказыватьПотребности);
	СтруктураПараметров.Вставить("ПоказыватьРезервы", ПоказыватьРезервы);
	
	ЭтаФорма.Закрыть(СтруктураПараметров);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Параметры.Свойство("ЗапрашиватьКоличествоВесовогоТовара", ЗапрашиватьКоличествоВесовогоТовара);
	Параметры.Свойство("ЗапрашиватьКоличествоОбычногоТовара", ЗапрашиватьКоличествоОбычногоТовара);
	Параметры.Свойство("ПоказыватьЦены", ПоказыватьЦены);
	Параметры.Свойство("ПоказыватьОстатки", ПоказыватьОстатки);
	Параметры.Свойство("ПоказыватьПотребности", ПоказыватьПотребности);
	Параметры.Свойство("ПоказыватьРезервы", ПоказыватьРезервы);
КонецПроцедуры
