﻿Перем мПериод          Экспорт; // Период движений
Перем мТаблицаДвижений Экспорт; // Таблица движений

Процедура ДобавитьДвижение(ЗаполнитьДатуСобытия = истина) Экспорт
	
	мТаблицаДвижений.ЗаполнитьЗначения( мПериод, "Период");
	мТаблицаДвижений.ЗаполнитьЗначения( Истина,  "Активность");
	
	Если мТаблицаДвижений.Колонки.Найти("ДатаСобытия") = Неопределено Тогда
		мТаблицаДвижений.Колонки.Добавить("ДатаСобытия");
		ЗаполнитьДатуСобытия = истина;
	КонецЕсли; 
	
	Если ЗаполнитьДатуСобытия Тогда
		мТаблицаДвижений.ЗаполнитьЗначения( мПериод, "ДатаСобытия");
	КонецЕсли; 
	
	ОбщегоНазначения.ВыполнитьДвижениеПоРегистру(ЭтотОбъект);

КонецПроцедуры

Процедура ВыполнитьПриход() Экспорт
	ОбщегоНазначения.ВыполнитьДвижениеПоРегистру(ЭтотОбъект, ВидДвиженияНакопления.Приход);
КонецПроцедуры

Процедура ВыполнитьРасход() Экспорт
	ОбщегоНазначения.ВыполнитьДвижениеПоРегистру(ЭтотОбъект, ВидДвиженияНакопления.Расход);
КонецПроцедуры

Процедура ВыполнитьДвижения() Экспорт
	Загрузить(мТаблицаДвижений);
КонецПроцедуры
              
