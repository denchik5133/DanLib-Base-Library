/***
 *   @addon         DanLib
 *   @version       3.0.0
 *   @release_date  10/4/2023
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *   @description   Universal library for GMod Lua, combining all the necessary features to simplify script development. 
 *                  Avoid code duplication and speed up the creation process with this powerful and convenient library.
 *
 *   @usage         !danlibmenu (chat) | danlibmenu (console)
 *   @license       MIT License
 *   @notes         For feature requests or contributions, please open an issue on GitHub.
 */
 

/***
 *   sh_languages.lua
 *   This module provides functionality for managing multiple languages within the DanLib framework.
 *
 *   The following components are included:
 *   - DanLib.Language.Options: A table containing supported languages and their corresponding codes.
 *   - Language: A table that maps language names to their respective icon materials.
 *   - DanLib.Language.Icon: A function that retrieves the icon for a given language.
 *   - languageMeta: A meta table for language objects that includes methods for language manipulation.
 *   - DanLib.Func:L: A function for retrieving localized strings based on a provided ID.
 *   - DanLib.Func.RegisterLanguage: A function for adding or merging language strings into a specified language.
 *   - DanLib.Func.LoadLanguages: A function for loading language files from a specified directory.
 *
 *   This module is designed to facilitate localization and internationalization of the DanLib framework,
 *   allowing easy management and deployment of multiple languages.
 *
 *   Usage example:
 *   - To retrieve a language icon:
 *     local icon = DanLib.Language.Icon('English')
 *     if icon then
 *         print('Icon for English:', icon)
 *     end
 *
 *   - To register a new language:
 *     DanLib.Func.RegisterLanguage('es', {
 *			['greeting'] = 'Hola'
 *		})
 *
 *   - To get a localized string:
 *     local greeting = DanLib.Func:L('greeting')
 *     print('Localized greeting:', greeting)
 *
 *   - To load language files:
 *     DanLib.Func.LoadLanguages()
 *
 *   @notes: Ensure that language strings are properly defined in the respective language files.
 */



DanLib.Language = DanLib.Language or {}


-- List of supported languages and their codes
DanLib.Language.Options = { 
    ['af'] = 'Afrikaans',
    ['ga'] = 'Irish',
    ['sq'] = 'Albanian',
    ['it'] = 'Italian',
    ['ja'] = 'Japanese',
    ['az'] = 'Azerbaijani',
    ['kn'] = 'Kannada',
    ['eu'] = 'Basque',
    ['ko'] = 'Korean',
    ['bn'] = 'Bengali',
    ['la'] = 'Latin',
    ['be'] = 'Belarusian',
    ['lv'] = 'Latvian',
    ['bg'] = 'Bulgarian',
    ['ca'] = 'Catalan',
    ['mk'] = 'Macedonian',
    ['zh-CN'] = 'Chinese Simplified',
    ['ms'] = 'Malay',
    ['zh-TW'] = 'Chinese Traditional',
    ['mt'] = 'Maltese',
    ['hr'] = 'Croatian',
    ['no'] = 'Norwegian',
    ['cs'] = 'Czech',
    ['fa'] = 'Persian',
    ['da'] = 'Danish',
    ['pl'] = 'Polish',
    ['nl'] = 'Dutch',
    ['ro'] = 'Romanian',
    ['eo'] = 'Esperanto',
    ['ru'] = 'Russian',
    ['et'] = 'Estonian',
    ['sr'] = 'Serbian',
    ['tl'] = 'Filipino',
    ['sk'] = 'Slovak',
    ['fi'] = 'Finnish',
    ['sl'] = 'Slovenian',
    ['fr'] = 'French',
    ['es'] = 'Spanish',
    ['gl'] = 'Galician',
    ['sw'] = 'Swahili',
    ['ka'] = 'Georgian',
    ['de'] = 'German',
    ['ta'] = 'Tamil',
    ['el'] = 'Greek',
    ['te'] = 'Telugu',
    ['gu'] = 'Gujarati',
    ['th'] = 'Thai',
    ['ht'] = 'Haitian Creole',
    ['tr'] = 'Turkish',
    ['iw'] = 'Hebrew',
    ['uk'] = 'Ukrainian',
    ['hi'] = 'Hindi',
    ['ur'] = 'Urdu',
    ['hu'] = 'Hungarian',
    ['vi'] = 'Vietnamese',
    ['is'] = 'Icelandic',
    ['cy'] = 'Welsh',
    ['id'] = 'Indonesian',
    ['yi'] = 'Yiddish'
}


-- Table containing language icons
local Language = { 
	['Afrikaans'] = Material('danlib/language/afrikaans.png'),
	['Irish'] = Material('danlib/language/irish.png'),
	['Albanian'] = Material('danlib/language/albanian.png'),
	['Italian'] = Material('danlib/language/italian.png'),
	['Japan'] = Material('danlib/language/japan.png'),
	['Austria'] = Material('danlib/language/austria.png'),
	['Azerbaijani'] = Material('danlib/language/azerbaijani.png'),
	['Kannada'] = Material('danlib/language/kannada.png'),
	['Basque'] = Material('danlib/language/basque.png'),
	['Korea'] = Material('danlib/language/korea.png'),
	['Bengali'] = Material('danlib/language/bengali.png'),
	['Latin'] = Material('danlib/language/latin.png'),
	['Belarusian'] = Material('danlib/language/belarusian.png'),
	['Latvian'] = Material('danlib/language/latvian.png'),
	['Bulgaria'] = Material('danlib/language/bulgaria.png'),
	['Catalan'] = Material('danlib/language/catalan.png'),
	['Macedonian'] = Material('danlib/language/macedonian.png'),
	['China'] = Material('danlib/language/china.png'),
	['Malay'] = Material('danlib/language/malay.png'),
	['Maltese'] = Material('danlib/language/maltese.png'),
	['Croatian'] = Material('danlib/language/croatian.png'),
	['Czech'] = Material('danlib/language/czech.png'),
	['Persian'] = Material('danlib/language/persian.png'),
	['Danish'] = Material('danlib/language/danish.png'),
	['Finland'] = Material('danlib/language/finland.png'),
	['Polish'] = Material('danlib/language/polish.png'),
	['Dutch'] = Material('danlib/language/dutch.png'),
	['France'] = Material('danlib/language/france.png'),
	['Spain'] = Material('danlib/language/spain.png'),
	['Romania'] = Material('danlib/language/romania.png'),
	['English'] = Material('danlib/language/english.png'),
	['Esperanto'] = Material('danlib/language/esperanto.png'),
	['Italy'] = Material('danlib/language/italy.png'),
	['Sweden'] = Material('danlib/language/sweden.png'),
	['Russian'] = Material('danlib/language/russian.png'),
	['Estonian'] = Material('danlib/language/estonian.png'),
	['Serbian'] = Material('danlib/language/serbian.png'),
	['Filipino'] = Material('danlib/language/filipino.png'),
	['Slovak'] = Material('danlib/language/slovak.png'),
	['Finnish'] = Material('danlib/language/finnish.png'),
	['Slovenian'] = Material('danlib/language/slovenian.png'),
	['French'] = Material('danlib/language/french.png'),
	['Spanish'] = Material('danlib/language/spanish.png'),
	['Galician'] = Material('danlib/language/galician.png'),
	['Swahili'] = Material('danlib/language/swahili.png'),
	['Georgian'] = Material('danlib/language/georgian.png'),
	['German'] = Material('danlib/language/german.png'),
	['Tamil'] = Material('danlib/language/tamil.png'),
	['Greek'] = Material('danlib/language/greek.png'),
	['Telugu'] = Material('danlib/language/telugu.png'),
	['Gujarati'] = Material('danlib/language/gujarati.png'),
	['Thai'] = Material('danlib/language/thai.png'),
	['Haitian'] = Material('danlib/language/haitian.png'),
	['Turkish'] = Material('danlib/language/turkish.png'),
	['Portugal'] = Material('danlib/language/portugal.png'),
	['Hebrew'] = Material('danlib/language/hebrew.png'),
	['Ukrainian'] = Material('danlib/language/ukrainian.png'),
	['Hindi'] = Material('danlib/language/hindi.png'),
	['Urdu'] = Material('danlib/language/urdu.png'),
	['Hungarian'] = Material('danlib/language/hungarian.png'),
	['Vietnamese'] = Material('danlib/language/vietnamese.png'),
	['Icelandic'] = Material('danlib/language/icelandic.png'),
	['Welsh'] = Material('danlib/language/welsh.png'),
	['Indonesian'] = Material('danlib/language/indonesian.png'),
	['Yiddish'] = Material('danlib/language/yiddish.png'),
	['Ethiopia'] = Material('danlib/language/ethiopia.png'),
	['Norway'] = Material('danlib/language/norway.png'),
	['Gibraltar'] = Material('danlib/language/gibraltar.png'),
	['Salvador'] = Material('danlib/language/salvador.png')
}

--- Function to get the icon of a language
-- @param icon: The name of the language for which you want to get an icon.
-- @return: Language icon if found, otherwise returns an error icon.
DanLib.Language.Icon = function(icon)
	return Language[icon] or Language[Material('Error')]
end


local gsub = string.gsub
local tostring = tostring
local pairs = pairs

DanLib.Temp.Languages = {}

--- Retrieves a localized string based on the provided ID.
-- @param id: The identifier for the string to retrieve.
-- @param ...: Additional parameters for string formatting.
-- @return: The localized string, or a default "langmissing" message if not found.
function DanLib.Func:L(ID, params)
    local tbl = DanLib.Temp.Languages[DanLib.CONFIG.BASE.Languages or 'English'] or DanLib.Temp.Languages['English']
    local String = ((tbl or {})[ID] or DanLib.Temp.Languages['English'][ID]) or self:L('#langmissing')
    local configTable = (DanLib.CONFIG.BASE.Languages or {})[DanLib.CONFIG.BASE.Languages or 'English']

    if (configTable and configTable[2] and configTable[2][ID]) then
        String = configTable[2][ID]
    end

    -- Replacing variables from params
    if params then
        for key, value in pairs(params) do
            String = String:gsub('{' .. key .. '}', value)
        end
    end

    return String
end


--- Adds or merges language strings into the specified language key.
-- @param langKey: The key of the language to which strings should be added.
-- @param stringTable: A table of strings to add.
function DanLib.Func.RegisterLanguage(langKey, stringTable)
	if (not DanLib.Temp.Languages[langKey]) then
		DanLib.Temp.Languages[langKey] = stringTable
	else
		table.Merge(DanLib.Temp.Languages[langKey], stringTable)
	end
end


local LangFile = 'danlib/languages/'

--- Loads language files from the specified directory.
function DanLib.Func.LoadLanguages()
	DanLib.Temp.Languages = DanLib.Temp.Languages or {}
	local files, directories = file.Find(LangFile .. '*', 'LUA')

	for k, v in pairs(directories) do
		for key, val in pairs(file.Find(LangFile .. v .. '/*', 'LUA')) do
			AddCSLuaFile(LangFile .. v .. '/' .. val)
			include(LangFile .. v .. '/' .. val)
		end
	end
end
