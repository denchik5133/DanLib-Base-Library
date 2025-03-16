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
 *   sh_user_modules_load.lua
 *   This file is responsible for loading and managing the configuration of custom modules in the project.
 *
 *   Includes the following functions and structures:
 *    - Definition of data types (Int, String, Bool, Table, Key) and their processing.
 *    - Functions for writing and reading data via network operations.
 *    - Methods for handling module configuration metadata, including registering, setting properties, and adding options.
 *    - Functions for copying values by type and handling configuration variables.
 *    - Loading configuration files and initializing default values.
 *
 *   This file provides a convenient interface for working with the configuration in the client part of the project.
 */


-- Client-side configuration types
DanLib.UserModules = {}
DanLib.USERCONFIG = {}


-- Function handlers for different types
DanLib.TypeHandlers = {
    Int = {
        Serialize = function(value) return tostring(value) end, -- Converts an integer to a string.
        Deserialize = function(value) return tonumber(value) end, -- Converts a string to an integer.
        Validate = function(value) return type(value) == 'number' end, -- Checks if the value is a number.
        Default = 0 -- Default value.
    },
    String = {
        Serialize = function(value) return tostring(value) end, -- Converts a string to a string (no changes).
        Deserialize = function(value) return tostring(value) end, -- Converts a string to a string (no changes).
        Validate = function(value) return type(value) == 'string' end, -- Checks if the value is a string.
        Default = '' -- Default value.
    },
    Bool = {
        Serialize = function(value) return value and 'true' or 'false' end, -- Converts a boolean value to a string.
        Deserialize = function(value) return value == 'true' end, -- Converts a string to a boolean value.
        Validate = function(value) return type(value) == 'boolean' end, -- Checks if the value is a boolean value.
        Default = false -- Default value.
    },
    Table = {
        Serialize = function(value) return util.TableToJSON(value) end, -- Converts a table to a JSON string.
        Deserialize = function(value) return util.JSONToTable(value) or {} end, -- Converts a JSON string to a table.
        Validate = function(value) return type(value) == 'table' end, -- Checks if the value is a table.
        Default = {} -- Default value.
    },
    Key = {
        Serialize = function(value) return tostring(value) end, -- Converts a key to a string.
        Deserialize = function(value) return tostring(value) end, -- Converts a string to a key (no changes).
        Validate = function(value) return type(value) == 'string' end, -- Checks if the value is a string.
        Default = '' -- Default value.
    }
}


--- Gets the type of the configuration variable.
-- @param module: Identifier of the module for which you want to get the type of the variable.
-- @param variable: The name of the variable whose type is to be retrieved.
-- @return string: Returns the type of the variable or nil if no module or variable is found.
function DanLib.GetUserConfigType(module, variable)
    if (not DanLib.UserModules[module] or not DanLib.UserModules[module].Variables) then return end
    return DanLib.UserModules[module].Variables[variable].Type
end


--- Copies the value of a variable by type.
-- @param type: The type of the variable whose value is to be copied.
-- @param value: The value to be copied.
-- @return any: Returns the copied value or the original value if no type is found.
function DanLib.CopyUserTypeValue(type, value)
    if (not type or not DanLib.TypeHandlers[type]) then return value end
    return value -- Here you can implement custom copy logic if needed
end


-- Path to configuration files.
local ConfigPath = 'danlib/config/modules'

-- Create config directory if it doesn't exist
if (not file.Exists(ConfigPath, 'DATA')) then
    file.CreateDir(ConfigPath)
end

-- Module metatable
local ModuleMeta = {
    --- Registers a new module.
    Register = function(self)
        DanLib.UserModules[self.ID] = self
        return self
    end,

    --- Sets the title of the module.
    -- @param title (string): Module title.
    SetTitle = function(self, title)
        self.Title = title
        return self
    end,

    --- Sets the module icon.
    -- @param icon (string): Module icon.
    SetIcon = function(self, icon)
        self.Icon = icon
        return self
    end,

    --- Sets the description of the module.
    -- @param description (string): Module description.
    SetDescription = function(self, description)
        self.Description = description
        return self
    end,

    --- Sets the color of the module.
    -- @param color: The color of the module.
    SetColor = function(self, color)
        self.Color = color
        return self
    end,

    --- Adds a configuration option to the module.
    -- This function allows you to define a new configuration option for the module, 
    -- specifying its properties and behavior. The added option can be used to customize 
    -- the module's functionality through user-defined settings.
    --
    -- @param variable: The name of the variable.
    -- @param name: Human-readable name of the variable.
    -- @param description: Description of the variable.
    -- @param type: The type of the variable (Int, String, Bool, Table, Key).
    -- @param default: Default value.
    -- @param vguiElement: VGUI element (optional).
    -- @param getOptions: Function to get options (optional).
    -- @param action: Action to be performed when the value is changed (optional).
    AddOption = function(self, variable, name, description, type, default, vguiElement, getOptions, action)
        self.Variables[variable] = {
            Name = name,
            Description = description,
            Type = type,
            Default = default,
            VguiElement = vguiElement or (type == DanLib.Type.Table && 'EditablePanel'),
            GetOptions = getOptions,
            Default = default,
            Action = action or nil,
            Order = table.Count(self.Variables) + 1
        }

        -- Validating the default value
        local handler = DanLib.TypeHandlers[type]
        if (handler and not handler.Validate(default)) then
            error('Default value for ' .. variable .. ' is not valid!')
        end

        -- Create an object for chain call
        local option = { Variable = variable, Module = self }
        -- Method for setting minimum and maximum values
        function option:SetMinMax(minValue, maxValue)
            if (self.Module.Variables[self.Variable].Type == DanLib.Type.Int) then
                self.Module.Variables[self.Variable].Min = minValue
                self.Module.Variables[self.Variable].Max = maxValue
            end
            return self.Module
        end

        -- Method for checking key bindings
        function option:ValidateKeyBinding(bannedKeys)
            if (self.Module.Variables[self.Variable].Type == DanLib.Type.Key) then
                self.Module.Variables[self.Variable].bannedKeys = bannedKeys
            end
            return self.Module
        end

        return option -- Return option object for chaining call
    end,

    --- Sets the sort order of the module.
    -- @param sortOrder: Sort order.
    SetSortOrder = function(self, sortOrder)
        self.SortOrder = sortOrder
        return self
    end,

    --- Gets the sorted module variables.
    -- @return sorted: Sorted list of variables.
    GetSorted = function(self)
        local sorted = {}
        for k, v in pairs(self.Variables) do
            local data = table.Copy(v)
            data.Key = k
            table.insert(sorted, data)
        end
        table.SortByMember(sorted, 'Order', true)
        return sorted
    end,

    --- Gets the value of a variable.
    -- @param variable: The name of the variable.
    GetValue = function(self, variable)
        local varData = self.Variables[variable]
        if (not varData) then return nil end
        
        local handler = DanLib.TypeHandlers[varData.Type]
        if (not handler) then return varData.Default end

        local value = DanLib.USERCONFIG[self.ID][variable]

        -- If the value is nil, return the default value
        if (value == nil) then
            return varData.Default
        end

        -- If the value exists, return it
        return value
    end,

    -- Reset a single variable to its default value
    ResetValue = function(self, variable)
        local varData = self.Variables[variable]
        if (not varData) then return end

        DanLib.SaveUserConfig()
    end,

    ResetAll = function(self)
        for variable, data in pairs(self.Variables) do
            local varData = self.Variables[variable]
            if (not varData) then return end
            
            -- Reset variable value to default value
            DanLib.USERCONFIG[self.ID][variable] = varData.Default
        end

        -- Saving the configuration after resetting all values
        DanLib.SaveUserConfig()
    end

}

ModuleMeta.__index = ModuleMeta

-- Create a new module
function DanLib.CreateUserModule(id)
    local module = {
        ID = id,
        Variables = {},
        SortOrder = 0
    }
    setmetatable(module, ModuleMeta)
    return module
end

-- Save configuration to file
function DanLib.SaveUserConfig()
    for moduleID, module in pairs(DanLib.UserModules) do
        local data = {}
        for varName, varData in pairs(module.Variables) do
            local value = DanLib.USERCONFIG[moduleID][varName]
            if (value ~= nil) then
                local handler = DanLib.TypeHandlers[varData.Type]
                if handler then
                    data[varName] = handler.Serialize(value)
                end
            end
        end

        local json = util.TableToJSON(data, true)
        file.Write(ConfigPath .. '/' .. moduleID .. '.txt', json)
    end
end

-- Load configuration from file
function DanLib.LoadUserConfig()
    for moduleID, module in pairs(DanLib.UserModules) do
        DanLib.USERCONFIG[moduleID] = {}
        
        local path = ConfigPath .. '/' .. moduleID .. '.txt'
        local json = file.Read(path, 'DATA')

        if json then
            local data = util.JSONToTable(json) or {}
            for varName, varData in pairs(module.Variables) do
                local handler = DanLib.TypeHandlers[varData.Type]
                if handler then
                    local savedValue = data[varName]
                    if (savedValue ~= nil) then
                        DanLib.USERCONFIG[moduleID][varName] = handler.Deserialize(savedValue)
                    else
                        DanLib.USERCONFIG[moduleID][varName] = varData.Default
                    end
                end
            end
        else
            -- Set defaults if no saved config exists
            for varName, varData in pairs(module.Variables) do
                DanLib.USERCONFIG[moduleID][varName] = varData.Default
            end
        end
    end
end


local configPath = 'danlib/user_modules'

-- Function for loading modules on the client
local function LoadModules()
    for _, file in ipairs(file.Find(configPath .. '/*.lua', 'LUA')) do
        AddCSLuaFile(configPath .. '/' .. file)
        include(configPath .. '/' .. file)
        -- print('[UserConfig] Loaded module: ' .. file)
    end
end

-- Call the module loading function
LoadModules()
DanLib.LoadUserConfig() -- Loading configuration after loading modules


-- Initialize when player joins
hook.Add('InitPostEntity', 'UserConfig', function()
    --print('[UserConfig] Initializing client configuration system...')
    LoadModules() -- Load all modules
    DanLib.LoadUserConfig() -- Load saved configurations
    --print('[UserConfig] Configuration system initialized!')
end)

-- Refresh configurations periodically
-- timer.Create('UserConfig_AutoRefresh', 300, 0, function()
--     if not LocalPlayer():IsValid() then return end
--     DanLib.LoadUserConfig()
-- end)

-- Automatically save config when game is closing
hook.Add('ShutDown', 'SaveUserConfig', function()
    DanLib.SaveUserConfig()
end)
