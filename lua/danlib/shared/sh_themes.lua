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
 *   sh_themes.lua
 *   This file contains utility functions and structures for managing themes within the DanLib project.
 *
 *   The following functions and methods are included:
 *   - CreateTheme: Creates a new theme object with a specified ID.
 *   - Register: Registers the current theme in the global themes table.
 *   - SetName: Sets the name of the theme.
 *   - SetAuthor: Sets the author of the theme.
 *   - SetVersion: Sets the version of the theme.
 *   - SetDescription: Sets the description of the theme.
 *   - SetStrings: Merges additional strings into the theme's string table.
 *   - LoadThemes: Loads all theme files from the specified directory.
 *   - Theme: Retrieves the color associated with a specific key from the current theme.
 *
 *   This file is designed to facilitate theme management tasks, allowing for easy customization
 *   and organization of visual elements in the game environment.
 *
 *   Usage example:
 *   - To create a new theme:
 *     local myTheme = DanLib.Func.CreateTheme('my_custom_theme')
 *     myTheme:SetName('My Custom Theme')
 *     myTheme:SetAuthor('Your Name')
 *     myTheme:SetVersion('1.0')
 *     myTheme:SetDescription('This is a custom theme for my game.')
 *     myTheme:SetStrings({
 *			['primaryColor'] = Color(255, 0, 0)
 *	   })
 *     myTheme:Register()
 *
 *   - To load all themes:
 *     DanLib.Func.LoadThemes()
 *
 *   - To get a color from the current theme:
 *     local color = DanLib.Func:Theme('primaryColor', 150)
 *     print('Primary color with alpha:', color)
 *
 *   @notes: Ensure that theme IDs are unique to avoid conflicts. All theme files should be placed
 *   in the specified themes directory for proper loading.
 */

 

DanLib.Temp.Themes = {}

local ThemeMeta = {
	--- Registers the current theme in the global themes table.
    -- This function adds the theme to the DanLib.Temp.Themes table using its ID.
    -- @self: The theme object being registered.
	Register = function(self)
        DanLib.Temp.Themes[self.ID] = self
	end,

	--- Sets the name of the theme.
    -- @self: The theme object.
    -- @name (string): The name to be assigned to the theme.
	SetName = function(self, name)
        self.Name = name
	end,

	--- Sets the author of the theme.
    -- @self: The theme object.
    -- @author (string): The author to be assigned to the theme.
	SetAuthor = function(self, author)
		self.Author = author
	end,

	--- Sets the version of the theme.
    -- @self: The theme object.
    -- @version (string): The version to be assigned to the theme.
	SetVersion = function(self, version)
		self.Version = version
	end,

	--- Sets the description of the theme.
    -- @self: The theme object.
    -- @description (string): The description to be assigned to the theme.
	SetDescription = function(self, description)
        self.Description = description
	end,

	--- Merges additional strings into the theme's string table.
    -- @self: The theme object.
    -- @strings (table): A table containing strings to be added to the theme.
	SetStrings = function(self, strings)
        table.Merge(self.Strings, strings)
	end
}

ThemeMeta.__index = ThemeMeta


--- Creates a new theme object with the specified ID.
-- @param id (string): The identifier for the new theme.
-- @return (table): A new theme object with methods for setting properties.
function DanLib.Func.CreateTheme(id)
	local themes = { ID = id, Strings = {} }
	setmetatable(themes, ThemeMeta)
	return themes
end


local path = 'danlib/themes/'

--- Loads all theme files from the specified directory.
-- This function searches for Lua files in the 'danlib/themes/' directory,
-- adds them to the client-side, and includes them for execution.
function DanLib.Func.LoadThemes()
	local themeFiles = file.Find(path .. '*', 'LUA')
    for k, file in ipairs(themeFiles) do
		AddCSLuaFile(path .. file)
		include(path .. file)
	end
end


local CurrentTheme, ThemeStrings, color

--- Retrieves the color associated with a specific key from the current theme.
-- If the current theme is not set, it defaults to the base theme.
-- @param key (string): The key for the desired color in the theme.
-- @param alpha (number|nil): Optional alpha value to modify the color's transparency.
-- @return (Color): The color object associated with the key, or a default color if not found.
function DanLib.Func:Theme(key, alpha)
	if (CurrentTheme != DanLib.CONFIG.BASE.Themes) then
		CurrentTheme = DanLib.CONFIG.BASE.Themes
		ThemeStrings = DanLib.Temp.Themes[DanLib.CONFIG.BASE.Themes].Strings
	end

	color = ThemeStrings[key] or Color(0, 0, 0, 200)

	if (alpha) then
		color = Color(color.r, color.g, color.b, alpha)
	end
	return color
end
