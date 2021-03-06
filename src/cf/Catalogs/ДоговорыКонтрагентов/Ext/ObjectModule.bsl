﻿Функция СуществуютСсылки() Экспорт
	Возврат ПолныеПрава.ПроверитьНаличиеСсылокНаДоговорКонтрагента(Ссылка);
КонецФункции

Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	Если ОбменДанными.Загрузка Тогда Возврат; КонецЕсли; 
	
	// Проверим, заполнена ли валюта.
	Если НЕ ЗначениеЗаполнено(ВалютаВзаиморасчетов) Тогда
		Сообщить("Не указана валюта договора.", СтатусСообщения.Важное);
		Отказ = Истина;
	КонецЕсли;
	// Проверим, заполнена ли организация.
	Если НЕ ЗначениеЗаполнено(Организация) Тогда
		Сообщить("Не указана организация, от которой заключен договор.", СтатусСообщения.Важное);
		Отказ = Истина;
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(ВидДоговора) Тогда
		Сообщить("Не указан вид договора.", СтатусСообщения.Важное);
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ПередЗаписью(Отказ)
	// Проверим можно ли изменять реквизиты договора.
	// Проверка осуществляется только если записывается уже существующий договор
	Если НЕ ОбменДанными.Загрузка И НЕ ЭтоНовый() Тогда
		Если ЭтоГруппа Тогда
			// Для группы владельца менять нельзя
			Если Владелец <> Ссылка.Владелец Тогда
				Сообщить("Нельзя изменять контрагента для группы договоров.", СтатусСообщения.Важное);
				Отказ = Истина;
			КонецЕсли; 
		Иначе
			// Проверим возможность смены владельца для договора
			Если Владелец <> Ссылка.Владелец Тогда
				Запрос=Новый Запрос;
				Запрос.УстановитьПараметр("Договор", Ссылка);
				Запрос.Текст="
				|ВЫБРАТЬ ПЕРВЫЕ 1
				|	ДокументыПоДоговоруКонтрагента.Ссылка
				|ИЗ
				|	КритерийОтбора.ДокументыПоДоговоруКонтрагента(&Договор) КАК ДокументыПоДоговоруКонтрагента
				|";
				Результат=Запрос.Выполнить();
				ЕстьДокументыПоДоговору=НЕ Результат.Пустой();

				#Если Клиент Тогда
				Если ЕстьДокументыПоДоговору Тогда
					////стрТекстВопроса="Существуют документы, оформленные по договору, продолжить?";
					////Отчет=Вопрос(стрТекстВопроса, РежимДиалогаВопрос.ДаНет, 10, КодВозвратаДиалога.Нет, "");
					////Если Отчет=КодВозвратаДиалога.Нет Тогда Отказ = Истина; Возврат; КонецЕсли; 

					Сообщить("Существуют документы, оформленные по договору """ + Наименование + """.
							|Необходимо перепровести документы.", СтатусСообщения.Важное);
				КонецЕсли; 
				#КонецЕсли
			КонецЕсли; 

			// Проверим возможность смены способа ведения взаиморасчетов и валюты взаиморасчетов
			 Если ВалютаВзаиморасчетов <> Ссылка.ВалютаВзаиморасчетов 
			 ИЛИ ВидДоговора <> Ссылка.ВидДоговора
			 ИЛИ Организация <> Ссылка.Организация
			 ИЛИ ДопУсловияДоговора <> Ссылка.ДопУсловияДоговора Тогда

				Если ЭтотОбъект.СуществуютСсылки() Тогда
					Сообщить("Существуют документы, проведенные по договору """+Наименование+""".
							 |Реквизиты ""Организация"", ""Ведение взаиморасчетов"", ""Валюта взаиморасчетов"", ""Вид договора""
							 |и ""Условия выполнения договора"" не могут быть изменены, элемент не записан.", 
							 СтатусСообщения.Важное);
					//Отказ = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	// Проверим заполнение и очистим неиспользуемые реквизиты элемента договора.
	Если Не ЭтоГруппа Тогда ПроверитьЗаполнениеРеквизитов(Отказ); КонецЕсли;
КонецПроцедуры

