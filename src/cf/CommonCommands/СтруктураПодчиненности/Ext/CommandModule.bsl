﻿&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	Если ТипЗнч(ПараметрКоманды)=Тип("Массив") Тогда
		Ссылка=ПараметрКоманды.Получить(0);
	Иначе
		Ссылка=ПараметрКоманды;
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(Ссылка) Тогда
		ПоказатьПредупреждение(, "Документ не записан.", 20);
		Возврат;
	КонецЕсли;
	ОткрытьФорму("РегистрСведений.СтруктураПодчиненности.Форма.ФормаСтруктураПодчиненности", Новый Структура("Ссылка", Ссылка), ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка,, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры