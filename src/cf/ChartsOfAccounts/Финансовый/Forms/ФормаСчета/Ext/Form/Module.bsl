﻿&НаСервере
Функция СтрутураРеквизитов()
	СтруктураВозврата=Новый Структура;
	СтруктураВозврата.Вставить("УчетПоЦФО", Истина);
	
	Запрос=Новый Запрос;
	Запрос.УстановитьПараметр("Родитель", Объект.Ссылка);
	Запрос.Текст="
	|ВЫБРАТЬ
	|	ЕСТЬNULL(МАКСИМУМ(Финансовый.УчетПоЦФО), ЛОЖЬ) КАК УчетПоЦФО
	|ИЗ
	|	ПланСчетов.Финансовый КАК Финансовый
	|ГДЕ
	|	Финансовый.Родитель В ИЕРАРХИИ(&Родитель)
	|";
	Выборка=Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		СтруктураВозврата.УчетПоЦФО=Не Выборка.УчетПоЦФО;
	КонецЕсли;
	
	Возврат СтруктураВозврата; 
КонецФункции

&НаСервере
Функция НайтиРодителяПоКоду(КодРодителя)
	Возврат ПланыСчетов.Хозрасчетный.НайтиПоКоду(КодРодителя);
КонецФункции

&НаКлиенте
Процедура ДосупностьЭлементовФормы()
	Если Не Объект.Предопределенный Тогда
		Если ЗначениеЗаполнено(Объект.Родитель) Тогда
			СтрутураРеквизитовРодителя=ОбщегоНазначенияСервер.ЗначенияРеквизитовОбъекта(Объект.Родитель, "УчетПоЦФО");
			Элементы.УчетПоЦФО.Доступность=СтрутураРеквизитовРодителя.УчетПоЦФО;
			Если Модифицированность Тогда
				Объект.УчетПоЦФО=?(СтрутураРеквизитовРодителя.УчетПоЦФО, Объект.УчетПоЦФО, Ложь);
			КонецЕсли;
		Иначе
			Если НЕ Объект.Ссылка.Пустая() Тогда
				СтрутураВозврата=СтрутураРеквизитов();
				Элементы.УчетПоЦФО.Доступность=СтрутураВозврата.УчетПоЦФО;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииКода()
	Если НЕ Объект.Ссылка.Пустая() Тогда Возврат; КонецЕсли;

	// Если задан субсчет, то в его коде должна быть точка
	Если Найти(Объект.Код, ".") > 0 Тогда
		//Найдем код родителя, для этого найдем последнюю точку в коде счета
		ПозицияТочки = СтрДлина(Объект.Код);
		Пока Сред(Объект.Код, ПозицияТочки, 1) <> "." Цикл
			ПозицияТочки = ПозицияТочки - 1;
		КонецЦикла;

		КодРодителя=Лев(Объект.Код, ПозицияТочки-1);
		РодительПоКоду=НайтиРодителяПоКоду(КодРодителя);

		Если НЕ ЗначениеЗаполнено(РодительПоКоду) Тогда
			ПоказатьПредупреждение(, "План счетов не содержит счета с кодом "+КодРодителя);

		ИначеЕсли НЕ РодительПоКоду=Объект.Ссылка Тогда
			Объект.Родитель=РодительПоКоду;
			СтрутураРеквизитов=ОбщегоНазначенияСервер.ЗначенияРеквизитовОбъекта(РодительПоКоду, "Вид,Забалансовый,Количественный,Валютный");
			ЗаполнитьЗначенияСвойств(Объект, СтрутураРеквизитов);
		КонецЕсли;
	КонецЕсли;
	
	Объект.КодБыстрогоВыбора=СокрЛП(СтрЗаменить(Объект.Код, ".", ""));
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Обработчики событий атрибутов

&НаКлиенте
Процедура Атрибут_ПриИзменении(Элемент)
	Если Элемент.Имя="Код" Тогда
		ПриИзмененииКода();
		ДосупностьЭлементовФормы();
		
	ИначеЕсли Элемент.Имя="Родитель" Тогда
		ДосупностьЭлементовФормы();
		
	ИначеЕсли Элемент.Имя="Количественный" Тогда
		Элементы.ВидыСубконтоКоличественный.Видимость=Объект.Количественный;
		
	ИначеЕсли Элемент.Имя="Валютный" Тогда
		Элементы.ВидыСубконтоВалютный.Видимость=Объект.Валютный;
	КонецЕсли; 
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДосупностьЭлементовФормы();
КонецПроцедуры
