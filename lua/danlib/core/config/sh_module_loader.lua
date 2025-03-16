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
 *   sh_module_loader.lua
 *   This file is responsible for loading and managing the configuration of modules in the DanLib project.
 *
 *   It includes the following functions and structures:
 *   - Definition of data types (Int, String, Bool, Table, Key) and their processing.
 *   - Functions for writing and reading data through network operations.
 *   - Methods for working with module configuration metadata, including registration, setting properties and adding options.
 *   - Functions for copying type values and handling configuration variables.
 *   - Loading configuration files and initialising default values.
 *
 *   This file provides a convenient interface for working with configuration in the project.
 */
 


--- Gets the type of the configuration variable.
-- @param module: Identifier of the module for which you want to get the type of the variable.
-- @param variable: The name of the variable whose type is to be retrieved.
-- @return string: Returns the type of the variable or nil if no module or variable is found.
function DanLib.Func.GetConfigType(module, variable)
    if (not DanLib.ConfigMeta[module] or not DanLib.ConfigMeta[module].Variables) then return end
    return DanLib.ConfigMeta[module].Variables[variable].Type
end


--- Copies the value of a variable by type.
-- @param type: The type of the variable whose value is to be copied.
-- @param value: The value to be copied.
-- @return any: Returns the copied value or the original value if no type is found.
function DanLib.Func.CopyTypeValue(type, value)
    if (not type or not DanLib.FunctionType[type] or not DanLib.FunctionType[type].CopyFunc) then return value end
    return DanLib.FunctionType[type].CopyFunc(value)
end


--- Processes the value of a variable depending on its type.
-- @param type: The type of the variable (e.g. Int, String, Bool, etc.).
-- @param value: The value of the variable to write or read.
-- @param isWrite: Flag indicating whether the value should be written (true) or read (false).
-- @return any: Returns the read value if isWrite is false.
function DanLib.Func.ProcessTypeValue(type, value, isWrite)
    if (not type or not DanLib.FunctionType[type]) then return end
    
    if isWrite then
        DanLib.FunctionType[type].NetWrite(value)
    else
        return DanLib.FunctionType[type].NetRead()
    end
end


-- MODULE META
DanLib.ConfigMeta = {}

local ConfigModuleMeta = {
	--- Registers the module in the configuration metadata.
    -- @return self: Returns the current module object for the call chain.
	Register = function(self)
        DanLib.ConfigMeta[self.ID] = self
        return self
	end,

	--- Sets the module title.
    -- @param title: Module Header.
    -- @return self: Returns the current module object for the call chain.
	SetTitle = function(self, title)
        self.Title = title
        return self
	end,

	--- Sets the module icon.
    -- @param icon: Module icon.
    -- @return self: Returns the current module object for the call chain.
	SetIcon = function(self, icon)
        self.Icon = icon
        return self
	end,

	--- Sets the author of the module.
    -- @param author: Module author.
    -- @return self: Returns the current module object for the call chain.
	SetAuthor = function(self, author)
		self.Author = author
        return self
	end,

	--- Sets the module version.
    -- @param version: Module version.
    -- @return self: Returns the current module object for the call chain.
	SetVersion = function(self, version)
		self.Version = version
        return self
	end,

	--- Sets the colour of the module.
    -- @param color: Module colour.
    -- @return self: Returns the current module object for the call chain.
	SetColor = function(self, color)
		self.Color = color
        return self
	end,

	--- Sets the module description.
    -- @param description: Module description.
    -- @return self: Returns the current module object for the call chain.
	SetDescription = function(self, description)
        self.Description = description
        return self
	end,

	--- Sets the directory for include files.
    -- @param path: Path to the directory.
    -- @return self: Returns the current module object for the call chain.
	SetIncludeDir = function(self, path)
		self.IncludeDir = path

		--DanLib.loader.IncludeDir(path, true)
        return self
	end,

	--- Sets the file to include.
    -- @param path: The path to the file.
    -- @return self: Returns the current module object for the call chain.
	SetInclude = function(self, path)
		self.Include = path

		--DanLib.loader.Include(path) // (self.ID .. '/' .. path)
        return self
	end,

	--- Sets the sort order of the module.
    -- @param sortOrder: Sort order.
    -- @return self: Returns the current module object for the call chain.
	SetSortOrder = function(self, sortOrder)
        self.SortOrder = sortOrder
        return self
	end,

	--- Adds an option to the module.
    -- @param variable: Variable name.
    -- @param name: The name of the option.
    -- @param description: Description of the option.
    -- @param type: Option type.
    -- @param default: Default value.
    -- @param vguiElement: Interface element for the option.
    -- @param getOptions: Function to get options.
    -- @param action: Function to execute or string to register with vgui.
    -- @return self: Returns the current module object for the call chain.
	AddOption = function(self, variable, name, description, type, default, vguiElement, getOptions, action)
        self.Variables[variable] = {
			Name = name,
			Description = description,
			Type = type,
			VguiElement = vguiElement or (type == DanLib.Type.Table && 'EditablePanel'),
			GetOptions = getOptions,
			Default = default,
			Action = action or nil,
			Order = table.Count(self.Variables) + 1
		}
        return self
	end,

	--- Gets the sorted module variables.
    -- @return table: Returns a table of sorted variables.
	GetSorted = function(self)
		local sortedVariables = {}
        for k, v in pairs(self.Variables) do
			local data = v
			data.Key = k
			table.insert(sortedVariables, data)
		end
		table.SortByMember(sortedVariables, 'Order', true)

		return sortedVariables
	end,

	--- Gets the default value for the variable.
    -- @param variable: The name of the variable.
    -- @return any: Returns the default value.
	GetDefaultValue = function(self, variable)
		return self.Variables[variable].Default
	end,

	--- Gets the current value of the configuration variable.
    -- @param variable: Name of the variable.
    -- @return any: Returns the current value of the variable.
	GetValue = function(self, variable)
		return DanLib.Func.CopyTypeValue(self.Variables[variable].Type, DanLib.CONFIG[self.ID][variable] or self.Variables[variable].Default)
	end
}
ConfigModuleMeta['__index'] = ConfigModuleMeta


--- Creates a new configuration module.
-- @param id: Module identifier.
-- @return table: Returns the created module.
function DanLib.Func.CreateModule(id)
	local module = {
		ID = id,
		Variables = {},
		SortOrder = 0
	}
	
	setmetatable(module, ConfigModuleMeta)
	
	return module
end


local ConfigFile = 'danlib/config'
local ModuleFile = 'danlib/modules'
local SharedFile = 'danlib/shared'

--- Loads files from the specified directory.
-- @param directory: Path to the directory with the files.
local function LoadFiles(directory)
    for _, file in ipairs(file.Find(directory .. '/*.lua', 'LUA')) do
        AddCSLuaFile(directory .. '/' .. file)
        include(directory .. '/' .. file)
    end
end

LoadFiles(ModuleFile)
LoadFiles(SharedFile)


if (not file.Exists(ConfigFile, 'DATA')) then
	file.CreateDir(ConfigFile)
end


DanLib.CONFIG = {}
--- Initialises the configuration metadata.
local function configMeta()
	for k, v in pairs(DanLib.ConfigMeta) do
		local savedModule = DanLib.NetworkUtil:JSONToTable(file.Read(ConfigFile .. '/' .. k .. '.txt', 'DATA') or '') or {}

		local module = {}
		for key, val in pairs(v.Variables) do
			module[key] = savedModule[key] or val.Default
		end

		DanLib.CONFIG[k] = module
	end
end
configMeta()
