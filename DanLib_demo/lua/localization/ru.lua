local language_code = 'Russian'

DanLib.Loc:RegisterLanguage( language_code, 'Russian' )
/*
	Base Menu
*/
DanLib.Loc:AddDefinition(language_code, 'NameBaseMenu', 			'Базовая библиотека DanLib')

/*
	Modules
*/
DanLib.Loc:AddDefinition(language_code, 'modulesmenu', 				'Информация о доступных модулях')

/*
	Settings
*/
DanLib.Loc:AddDefinition(language_code, 'settingsmenu', 			'Базовая конфигурация DanLib меню')

DanLib.Loc:AddDefinition(language_code, 'languageselection', 		'Выберите язык')
DanLib.Loc:AddDefinition(language_code, 'languagedescription', 		'Выберите язык, на котором будут отображаться интерфейсы')

DanLib.Loc:AddDefinition(language_code, 'interfaceselection', 		'Выберите интерфейс')
DanLib.Loc:AddDefinition(language_code, 'interfacedescription', 	'Выберите тему интерфейса, на которой будут отображаться все меню интерфейса')

DanLib.Loc:AddDefinition(language_code, 'interfaceseDark', 			'Темный')
DanLib.Loc:AddDefinition(language_code, 'interfaceseLight', 		'Светлый')
DanLib.Loc:AddDefinition(language_code, 'interfaceseBurgandy', 		'Бургандия')
DanLib.Loc:AddDefinition(language_code, 'interfaceseRose', 			'Розовый')

DanLib.Loc:AddDefinition(language_code, 'chatprefix', 				'Чат префикс')
DanLib.Loc:AddDefinition(language_code, 'chatprefixdescription', 	'Чат команда, используемая для открытия DanLib меню. По умолчанию: !danlibmenu')


/*
	Loading
*/
DanLib.Loc:AddDefinition( language_code, 'invalidoption', 			'Неверные настройки.')
DanLib.Loc:AddDefinition( language_code, 'invalidoptionvaluetype',	'Неверный тип значения параметра.')
DanLib.Loc:AddDefinition( language_code, 'optionsloaded',			'Настройки загружены!')

