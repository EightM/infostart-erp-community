﻿&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	Если НЕ ЗначениеЗаполнено(ПараметрКоманды) Тогда Возврат; КонецЕсли;

	стрФорма=ПараметрыВыполненияКоманды.Источник.ИмяФормы;
	МассивСтрок=СтрРазделить(ПараметрыВыполненияКоманды.Источник.ИмяФормы, ".");
	Если МассивСтрок.Количество()<2 Тогда Возврат; КонецЕсли;

	ПараметрыФормы=Новый Структура;
	ПараметрыФормы.Вставить("Владелец", ПредопределенноеЗначение("Справочник.ИдентификаторыОбъектовМетаданных."+МассивСтрок[0]+"_"+МассивСтрок[1]));
	ПараметрыФормы.Вставить("Ссылка", ПараметрКоманды);
	ОткрытьФорму("Справочник.Плагины.Форма.ВыборПлагина", ПараметрыФормы,ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры
