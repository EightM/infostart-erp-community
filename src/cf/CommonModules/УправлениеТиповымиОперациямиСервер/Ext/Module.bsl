﻿Функция ЗначенияПоУмолчаниию(ТОП, тзДанные=Неопределено) Экспорт
	Если тзДанные=Неопределено Тогда
		тзДанные=Новый ТаблицаЗначений;
		тзДанные.Колонки.Добавить("Реквизит");
		тзДанные.Колонки.Добавить("Значение");
		тзДанные.Колонки.Добавить("Фиксировать");
	КонецЕсли;
	Для каждого СтрокаКоллекции Из ТОП.ЗначенияПоУмолчанию Цикл
		Если тзДанные.Найти(СтрокаКоллекции.Реквизит, "Реквизит")=Неопределено Тогда
			ЗаполнитьЗначенияСвойств(тзДанные.Добавить(), СтрокаКоллекции);
		КонецЕсли;
	КонецЦикла;
	Если НЕ ТОП.Родитель.Пустая() Тогда
		Возврат ЗначенияПоУмолчаниию(ТОП.Родитель, тзДанные);
	КонецЕсли;
	Возврат тзДанные;
	
КонецФункции 

Процедура УстановитьТиповуюОперацию(СтрокаТабличнойЧасти, ДокументОбъект, ДокументФорма, ИмяТабличнойЧасти="") Экспорт
	СсылкаНаРегистрПравил=Справочники.РегистрыПравил.НайтиПоКоду("ТиповыеОперации");
	Если СсылкаНаРегистрПравил.Пустая() Тогда Возврат; КонецЕсли;

	СтруктураПараметров=Новый Структура;
	СтруктураПараметров.Вставить("ЭтаФорма", ДокументФорма);
	СтруктураПараметров.Вставить("ЭтотОбъект", ДокументОбъект);
	СтруктураПараметров.Вставить("СтрокаТабличнойЧасти", СтрокаТабличнойЧасти);

	мдОбъект=ДокументОбъект.Метаданные();

	//Определяем номенклатуру и табличную часть
	СтруктураПараметров.Вставить("Номенклатура", "");
	СтруктураПараметров.Вставить("ИмяТабличнойЧасти", ИмяТабличнойЧасти);
	Если Не ПустаяСтрока(ИмяТабличнойЧасти) Тогда
		Если ТипЗнч(СтрокаТабличнойЧасти)=Тип("СтрокаДереваЗначений") Тогда
			СтруктураПараметров.Номенклатура=СтрокаТабличнойЧасти.Объект;
		Иначе	
			Если УправлениеМетаданными.ЕстьРеквизит("Номенклатура", мдОбъект, ИмяТабличнойЧасти) Тогда
				СтруктураПараметров.Номенклатура=СтрокаТабличнойЧасти.Номенклатура;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	//Определяем вид операции
	СтруктураПараметров.Вставить("ВидОперации", "");
	Если УправлениеМетаданными.ЕстьРеквизит("ВидОперации", мдОбъект) Тогда
		СтруктураПараметров.ВидОперации=ДокументОбъект.ВидОперации;
	КонецЕсли;
	
	//Определяем контрагента
	СтруктураПараметров.Вставить("Контрагент", "");
	Если УправлениеМетаданными.ЕстьРеквизит("Контрагент", мдОбъект) Тогда
		СтруктураПараметров.Контрагент=ДокументОбъект.Контрагент;
	КонецЕсли;

	//Определяем организацию
	СтруктураПараметров.Вставить("Организация", "");
	Если УправлениеМетаданными.ЕстьРеквизит("Организация", мдОбъект) Тогда
		СтруктураПараметров.Организация=ДокументОбъект.Организация;
	КонецЕсли;

	//Определяем вид документа
	СтруктураПараметров.Вставить("ВидДокумента", УправлениеКонфигурациейСервер.ИдентификаторОбъектовМетаданныхСсылка("Документ_"+мдОбъект.Имя));

	//Выплняем регистр правил
	спРезультат=Справочники.РегистрыПравил.ВыполнитьПравило(СсылкаНаРегистрПравил, СтруктураПараметров);

	Если спРезультат.Количество()=0 Тогда Возврат; КонецЕсли; 
	
	//спРезультат[СсылкаНаРегистрПравил.Кэш.Получить().Ресурсы[0].ИмяКолонки]; //Как вариант получения ресурса
	
	Для каждого СтрокаКоллекции Из спРезультат Цикл
		СтрокаТабличнойЧасти.ТОП=СтрокаКоллекции.Значение;
		Прервать;
	КонецЦикла;

	//Значения по умолчанию
	стрТабличнаяЧасть=УправлениеМетаданными.ИмяТабличнойЧастиПоСсылкеНаСтроку(СтрокаТабличнойЧасти);
	тзДанные=УправлениеТиповымиОперациямиСервер.ЗначенияПоУмолчаниию(СтрокаТабличнойЧасти.ТОП);
	Для каждого СтрокаКоллекции Из тзДанные Цикл
		стрРеквизит=СокрЛП(СтрокаКоллекции.Реквизит);
		Если УправлениеМетаданными.ЕстьРеквизит(стрРеквизит, мдОбъект, стрТабличнаяЧасть) Тогда
			Если ЗначениеЗаполнено(СтрокаТабличнойЧасти[стрРеквизит]) Тогда
				Если СтрокаКоллекции.Фиксировать Тогда
					СтрокаТабличнойЧасти[стрРеквизит]=СтрокаКоллекции.Значение;
				КонецЕсли;
			Иначе
				СтрокаТабличнойЧасти[стрРеквизит]=СтрокаКоллекции.Значение;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;			
КонецПроцедуры