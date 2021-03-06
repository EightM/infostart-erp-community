﻿Процедура УстановитьСубконтоПоСчету(Счет, Субконто, ИмяСубконто, ЗначениеСубконто, Сообщать = Ложь, Заголовок = "", ВидыСубконтоСчета = Неопределено) Экспорт
	Если Счет = Неопределено ИЛИ Счет.Пустая() Тогда Возврат; КонецЕсли;

	Если ВидыСубконтоСчета = Неопределено Тогда
	     ВидыСубконтоСчета = Счет.ВидыСубконто;
	КонецЕсли; 
	ТолькоОбороты=Ложь;
	Если ТипЗнч(ИмяСубконто) = Тип("Число") Тогда
		Если ИмяСубконто > ВидыСубконтоСчета.Количество() Тогда Возврат; КонецЕсли;
		ВидСубк = ВидыСубконтоСчета[ИмяСубконто - 1].ВидСубконто;
		ТолькоОбороты=ВидыСубконтоСчета[ИмяСубконто - 1].ТолькоОбороты;
	Иначе
		ВидСубк = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные[ИмяСубконто];
		Если ВидыСубконтоСчета.Найти(ВидСубк) = Неопределено Тогда
			Если Сообщать тогда
				Сообщить("Вид субконто <" + ВидСубк + "> для счета """+Счет.Код +" ("+Счет.Наименование+")"" не определен.");
			КонецЕсли;
			Возврат;
		КонецЕсли;
	КонецЕсли;

	Если ВидСубк.ТипЗначения.СодержитТип(ТипЗнч(ЗначениеСубконто)) Тогда
		Если НЕ ЗначениеЗаполнено(ЗначениеСубконто) И ТолькоОбороты=Ложь Тогда
			Сообщить("На счете "+Счет+"  Не заполнено субконто "+ВидСубк);
		КонецЕсли;	
		Субконто.Вставить(ВидСубк, ЗначениеСубконто);
	ИначеЕсли Сообщать тогда
		Сообщить("Неверное значение """ + ЗначениеСубконто + """ для вида субконто <" + ВидСубк + ">");
	КонецЕсли;

КонецПроцедуры