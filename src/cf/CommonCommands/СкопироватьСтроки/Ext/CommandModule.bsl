﻿&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	Форма=ПараметрыВыполненияКоманды.Источник;
	Если НЕ ТипЗнч(Форма)=Тип("УправляемаяФорма") Тогда Возврат; КонецЕсли;

	Если КопированиеСтрокКлиент.ВозможноКопированиеСтрок(Форма.ТекущийЭлемент.ТекущаяСтрока) Тогда
		Скопировать(Форма.Объект[Форма.ТекущийЭлемент.Имя], Форма.ТекущийЭлемент.ВыделенныеСтроки);
		КопированиеСтрокКлиент.ОповеститьПользователяОКопированииСтрок(Форма.ТекущийЭлемент.ВыделенныеСтроки.Количество());
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура Скопировать(Знач ТаблицаФормы, Знач ВыделенныеСтроки) Экспорт
	тзБуфер=ТаблицаФормы.Выгрузить();
	тзБуфер.Очистить();
	Для каждого ИдентификаторСтроки Из ВыделенныеСтроки Цикл
		РезультатПоиска=ТаблицаФормы.НайтиПоИдентификатору(ИдентификаторСтроки);
		Если РезультатПоиска=Неопределено Тогда Продолжить; КонецЕсли;
		ЗаполнитьЗначенияСвойств(тзБуфер.Добавить(), РезультатПоиска);
	КонецЦикла;
	МассивСтрок=Новый Массив;
	Для каждого СтрокаКоллекции Из тзБуфер Цикл
		ДанныеСтроки=Новый Структура;
		Для каждого Колонка Из тзБуфер.Колонки Цикл
			ДанныеСтроки.Вставить(Колонка.Имя, СтрокаКоллекции[Колонка.Имя]);
		КонецЦикла;
		МассивСтрок.Добавить(ДанныеСтроки);
	КонецЦикла; 
	СтруктураБуфера=ПараметрыСеанса.БуферОбмена.Получить();
	СтруктураБуфера.Вставить("ТабличнаяЧасть", МассивСтрок);
	ПараметрыСеанса.БуферОбмена=Новый ХранилищеЗначения(СтруктураБуфера);
КонецПроцедуры