local language_code = 'English' 

DanLib.Loc:RegisterLanguage(language_code, 'English')
/*
	Base Menu
*/
DanLib.Loc:AddDefinition(language_code, 'NameBaseMenu', 			'The DanLib Base Library')


/*
	Modules
*/
DanLib.Loc:AddDefinition(language_code, 'modulesmenu', 				'Information about available modules')

/*
	Settings
*/
DanLib.Loc:AddDefinition(language_code, 'settingsmenu', 			'Basic configuration of the DanLib menu')

DanLib.Loc:AddDefinition(language_code, 'languageselection', 		'Select a language')
DanLib.Loc:AddDefinition(language_code, 'languagedescription', 		'Select the language in which the interfaces will be displayed')

DanLib.Loc:AddDefinition(language_code, 'interfaceselection', 		'Select the interface')
DanLib.Loc:AddDefinition(language_code, 'interfacedescription', 	'Select the interface theme on which all interface menus will be displayed')

DanLib.Loc:AddDefinition(language_code, 'interfaceseDark', 			'Dark')
DanLib.Loc:AddDefinition(language_code, 'interfaceseLight', 		'Light')
DanLib.Loc:AddDefinition(language_code, 'interfaceseBurgandy', 		'Burgandy')
DanLib.Loc:AddDefinition(language_code, 'interfaceseRose', 			'Rose')

DanLib.Loc:AddDefinition(language_code, 'chatprefix', 				'Chat prefix')
DanLib.Loc:AddDefinition(language_code, 'chatprefixdescription', 	'The chat command used to open the DanLib menu. By default: !danlibmenu')


/*
	Loading
*/
DanLib.Loc:AddDefinition(language_code, 'invalidoption', 			'Incorrect settings.')
DanLib.Loc:AddDefinition(language_code, 'invalidoptionvaluetype',	'Invalid parameter value type.')
DanLib.Loc:AddDefinition(language_code, 'optionsloaded',			'Settings loaded!')

