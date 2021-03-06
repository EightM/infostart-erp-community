﻿Перем мПериод          Экспорт; // Период движений
Перем мТаблицаДвижений Экспорт; // Таблица движений

Процедура ДобавитьДвижение() Экспорт
	мТаблицаДвижений.ЗаполнитьЗначения( мПериод, "Период");
	мТаблицаДвижений.ЗаполнитьЗначения( Истина,  "Активность");

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

