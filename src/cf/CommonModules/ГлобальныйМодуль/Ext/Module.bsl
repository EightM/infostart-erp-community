﻿#Если Сервер И НЕ Клиент И НЕ ВнешнееСоединение Тогда

Функция глЗначениеПеременной(Имя) Экспорт
	Кэш=ПараметрыСеанса.ОбщиеЗначения.Получить();
	КэшИзменен=Ложь;
	ПолученноеЗначение=ОбщегоНазначения.ПолучитьЗначениеПеременной(Имя, Кэш, КэшИзменен);

	Если КэшИзменен Тогда
		ПараметрыСеанса.ОбщиеЗначения = Новый ХранилищеЗначения(Кэш);
	КонецЕсли;
	
	Возврат ПолученноеЗначение;	
КонецФункции

Процедура глЗначениеПеременнойУстановить(Имя, Значение, ОбновлятьВоВсехКэшах = Ложь) Экспорт
	Кэш=ПараметрыСеанса.ОбщиеЗначения.Получить();	
	ОбщегоНазначения.УстановитьЗначениеПеременной(Имя, Кэш, Значение);
	ПараметрыСеанса.ОбщиеЗначения=Новый ХранилищеЗначения(Кэш);		
КонецПроцедуры

#КонецЕсли