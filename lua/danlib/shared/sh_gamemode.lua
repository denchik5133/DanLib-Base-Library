/***
 *   @addon         DanLib
 *   @version       3.0.0
 *   @release_date  10/21/2025
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
 *   sh_gamemode.lua
 *   This file contains utility functions and structures for managing gamemodes within the DanLib project.
 *
 *   The following functions and methods are included:
 *   - CreateGamemode: Creates a new gamemode object with a specified ID.
 *   - Register: Registers the current gamemode in the global gamemodes table.
 *   - SetName: Sets the name of the gamemode.
 *   - SetAuthor: Sets the author of the gamemode.
 *   - SetVersion: Sets the version of the gamemode.
 *   - SetDescription: Sets the description of the gamemode.
 *   - SetLicense: Sets the license of the gamemode.
 *   - SetOnLoadFunction: Sets the function that will be called when the gamemode is loaded.
 *   - SetGetMoneyFunction: Sets the function for getting player's money.
 *   - SetCanAffordFunction: Sets the function for checking if player can afford an amount.
 *   - SetAddMoneyFunction: Sets the function for adding money to player.
 *   - SetTakeMoneyFunction: Sets the function for taking money from player.
 *   - SetFormatMoneyFunction: Sets the function for formatting money display.
 *   - LoadGamemodes: Loads all gamemode files from the specified directory.
 *   - GetGamemode: Retrieves a gamemode by its ID.
 *   - GetAllGamemodes: Returns a table of all registered gamemodes.
 *   - GetActiveGamemode: Returns the currently active gamemode.
 *   - SetActiveGamemode: Sets the active gamemode by ID.
 *
 *   This file is designed to facilitate gamemode management tasks, allowing for easy customization
 *   and organization of economy systems and game mechanics.
 *
 *   Usage example:
 *   - To create a new gamemode:
 *     local myGamemode = DanLib:CreateGamemode('darkrp')
 *     myGamemode:SetName('DarkRP')
 *     myGamemode:SetAuthor('Your Name')
 *     myGamemode:SetVersion('1.0.0')
 *     myGamemode:SetDescription('DarkRP economy integration')
 *     myGamemode:SetGetMoneyFunction(function(player)
 *         return player:getDarkRPVar('money') or 0
 *     end)
 *     myGamemode:SetAddMoneyFunction(function(player, amount)
 *         player:addMoney(amount)
 *     end)
 *     myGamemode:Register()
 *
 *   - To load all gamemodes:
 *     DanLib.Func:LoadGamemodes()
 *
 *   - To get the active gamemode:
 *     local activeGM = DanLib:GetActiveGamemode()
 *     local balance = activeGM:GetMoney(player)
 *
 *   @notes: Ensure that gamemode IDs are unique to avoid conflicts. All gamemode files should be
 *   placed in the specified gamemodes directory for proper loading.
 */



local DBase = DanLib.Func

-- Storage for registered gamemodes
DanLib.Temp.Gamemodes = DanLib.Temp.Gamemodes or {}

--- Gamemode metatable with all methods
local GamemodeMeta = {
    --- Registers the current gamemode in the global gamemodes table.
    -- This function validates the gamemode and adds it to DanLib.Temp.Gamemodes.
    -- Warns if a gamemode with the same ID already exists and overwrites it (useful for development/hot-reload).
    -- @self: The gamemode object being registered.
    -- @return (boolean): true if registration was successful, false otherwise.
    Register = function(self)
        if (not self.ID or type(self.ID) ~= 'string' or self.ID == '') then
            DBase:PrintType('Error', 'Gamemode registration failed: Invalid or missing gamemode ID')
            return false
        end
        
        -- Check for duplicate registration
        if DanLib.Temp.Gamemodes[self.ID] then
            DBase:PrintType('Warning', 'Gamemode "' .. self.ID .. '" already registered, overwriting...')
            DBase:PrintType('Warning', 'This is probably a bug! Since this should not happen outside of development!')
        end
        
        -- Validate that required economy functions are set
        if (not self._GetMoneyFunc) then
            DBase:PrintType('Warning', 'Gamemode "' .. self.ID .. '" registered without GetMoney function')
        end
        if (not self._AddMoneyFunc) then
            DBase:PrintType('Warning', 'Gamemode "' .. self.ID .. '" registered without AddMoney function')
        end
        if (not self._TakeMoneyFunc) then
            DBase:PrintType('Warning', 'Gamemode "' .. self.ID .. '" registered without TakeMoney function')
        end
        
        DanLib.Temp.Gamemodes[self.ID] = self
        -- DBase:PrintType('Success', 'Registered gamemode "' .. self.ID .. '@' .. (self.Version or '0.0.0') .. '"')
        
        -- Trigger hook for gamemode registration
        hook.Run('DanLib:GamemodeRegistered', self)
        
        return true
    end,

    --- Sets the name of the gamemode.
    -- @self: The gamemode object.
    -- @name (string): The name to be assigned to the gamemode.
    -- @return (table): Returns self for method chaining.
    SetName = function(self, name)
        if (type(name) ~= 'string') then
            DBase:PrintType('Error', 'Gamemode name must be a string')
            return self
        end
        self.Name = name
        return self
    end,

    --- Sets the author of the gamemode.
    -- @self: The gamemode object.
    -- @author (string): The author to be assigned to the gamemode.
    -- @return (table): Returns self for method chaining.
    SetAuthor = function(self, author)
        if (type(author) ~= 'string') then
            DBase:PrintType('Error', 'Gamemode author must be a string')
            return self
        end
        self.Author = author
        return self
    end,

    --- Sets the version of the gamemode.
    -- @self: The gamemode object.
    -- @version (string): The version to be assigned to the gamemode (e.g., "1.0.0").
    -- @return (table): Returns self for method chaining.
    SetVersion = function(self, version)
        if (type(version) ~= 'string') then
            DBase:PrintType('Error', 'Gamemode version must be a string')
            return self
        end
        self.Version = version
        return self
    end,

    --- Sets the description of the gamemode.
    -- @self: The gamemode object.
    -- @description (string): The description to be assigned to the gamemode.
    -- @return (table): Returns self for method chaining.
    SetDescription = function(self, description)
        if (type(description) ~= 'string') then
            DBase:PrintType('Error', 'Gamemode description must be a string')
            return self
        end
        self.Description = description
        return self
    end,

    --- Sets the license of the gamemode.
    -- @self: The gamemode object.
    -- @license (string): The license to be assigned to the gamemode (e.g., "MIT", "GPL-3.0").
    -- @return (table): Returns self for method chaining.
    SetLicense = function(self, license)
        if (type(license) ~= 'string') then
            DBase:PrintType('Error', 'Gamemode license must be a string')
            return self
        end
        self.License = license
        return self
    end,

    --- Sets the function that will be called when the gamemode is loaded.
    -- @self: The gamemode object.
    -- @func (function): Function to be executed on gamemode load.
    -- @return (table): Returns self for method chaining.
    SetOnLoadFunction = function(self, func)
        if (type(func) ~= 'function') then
            DBase:PrintType('Error', 'OnLoad parameter must be a function')
            return self
        end
        self._OnLoadFunc = func
        return self
    end,

    --- Sets the function for getting player's money balance.
    -- @self: The gamemode object.
    -- @func (function): Function that takes a player and returns their balance (number).
    -- @return (table): Returns self for method chaining.
    SetGetMoneyFunction = function(self, func)
        if (type(func) ~= 'function') then
            DBase:PrintType('Error', 'GetMoney parameter must be a function')
            return self
        end
        self._GetMoneyFunc = func
        return self
    end,

    --- Sets the function for checking if player can afford an amount.
    -- @self: The gamemode object.
    -- @func (function): Function that takes a player and amount, returns boolean.
    -- @return (table): Returns self for method chaining.
    SetCanAffordFunction = function(self, func)
        if (type(func) ~= 'function') then
            DBase:PrintType('Error', 'CanAfford parameter must be a function')
            return self
        end
        self._CanAffordFunc = func
        return self
    end,

    --- Sets the function for adding money to player.
    -- @self: The gamemode object.
    -- @func (function): Function that takes a player and amount to add.
    -- @return (table): Returns self for method chaining.
    SetAddMoneyFunction = function(self, func)
        if (type(func) ~= 'function') then
            DBase:PrintType('Error', 'AddMoney parameter must be a function')
            return self
        end
        self._AddMoneyFunc = func
        return self
    end,

    --- Sets the function for taking money from player.
    -- @self: The gamemode object.
    -- @func (function): Function that takes a player and amount to take.
    -- @return (table): Returns self for method chaining.
    SetTakeMoneyFunction = function(self, func)
        if (type(func) ~= 'function') then
            DBase:PrintType('Error', 'TakeMoney parameter must be a function')
            return self
        end
        self._TakeMoneyFunc = func
        return self
    end,

    --- Sets the function for formatting money display.
    -- @self: The gamemode object.
    -- @func (function): Function that takes a player and amount, returns formatted string.
    -- @return (table): Returns self for method chaining.
    SetFormatMoneyFunction = function(self, func)
        if (type(func) ~= 'function') then
            DBase:PrintType('Error', 'FormatMoney parameter must be a function')
            return self
        end
        self._FormatMoneyFunc = func
        return self
    end,

    --- Gets the player's money balance.
    -- @self: The gamemode object.
    -- @player (Player): The player entity.
    -- @return (number): The player's current balance.
    GetMoney = function(self, player)
        if (not IsValid(player)) then
            DBase:PrintType('Error', 'GetMoney: Invalid player')
            return 0
        end
        
        if (not self._GetMoneyFunc) then
            DBase:PrintType('Error', 'Gamemode "' .. self.ID .. '" has no GetMoney function defined')
            return 0
        end
        
        return self._GetMoneyFunc(player) or 0
    end,

    --- Checks if the player can afford a specific amount.
    -- @self: The gamemode object.
    -- @player (Player): The player entity.
    -- @amount (number): The amount to check.
    -- @return (boolean): true if player can afford, false otherwise.
    CanAfford = function(self, player, amount)
        if (not IsValid(player)) then
            DBase:PrintType('Error', 'CanAfford: Invalid player')
            return false
        end
        
        if (type(amount) ~= 'number' or amount < 0) then
            DBase:PrintType('Error', 'CanAfford: Amount must be a non-negative number')
            return false
        end
        
        if (not self._CanAffordFunc) then
            -- Default implementation using GetMoney
            return self:GetMoney(player) >= amount
        end
        
        return self._CanAffordFunc(player, amount)
    end,

    --- Adds money to the player.
    -- @self: The gamemode object.
    -- @player (Player): The player entity.
    -- @amount (number): The amount to add (can be negative to subtract).
    -- @return (boolean): true if successful, false otherwise.
    AddMoney = function(self, player, amount)
        if (not IsValid(player)) then
            DBase:PrintType('Error', 'AddMoney: Invalid player')
            return false
        end
        
        if (type(amount) ~= 'number') then
            DBase:PrintType('Error', 'AddMoney: Amount must be a number')
            return false
        end
        
        if (not self._AddMoneyFunc) then
            DBase:PrintType('Error', 'Gamemode "' .. self.ID .. '" has no AddMoney function defined')
            return false
        end
        
        self._AddMoneyFunc(player, amount)
        hook.Run('DanLib:GamemodeMoneyAdded', player, amount, self)
        return true
    end,

    --- Takes money from the player.
    -- @self: The gamemode object.
    -- @player (Player): The player entity.
    -- @amount (number): The amount to take (typically positive).
    -- @return (boolean): true if successful, false otherwise.
    TakeMoney = function(self, player, amount)
        if (not IsValid(player)) then
            DBase:PrintType('Error', 'TakeMoney: Invalid player')
            return false
        end
        
        if (type(amount) ~= 'number') then
            DBase:PrintType('Error', 'TakeMoney: Amount must be a number')
            return false
        end
        
        if (not self._TakeMoneyFunc) then
            DBase:PrintType('Error', 'Gamemode "' .. self.ID .. '" has no TakeMoney function defined')
            return false
        end
        
        self._TakeMoneyFunc(player, amount)
        hook.Run('DanLib:GamemodeMoneyTaken', player, amount, self)
        return true
    end,

    --- Formats money for display.
    -- @self: The gamemode object.
    -- @player (Player): The player entity.
    -- @amount (number): The amount to format.
    -- @return (string): Formatted money string.
    FormatMoney = function(self, player, amount)
        if (not self._FormatMoneyFunc) then
            -- Default formatting
            return tostring(amount)
        end
        
        return self._FormatMoneyFunc(player, amount)
    end,

    --- Get gamemode information as a table.
    -- @self: The gamemode object.
    -- @return (table): Table with gamemode information.
    GetInfo = function(self)
        return {
            ID = self.ID,
            Name = self.Name or 'Unnamed',
            Author = self.Author or 'Unknown',
            Version = self.Version or '0.0.0',
            Description = self.Description or 'No description',
            License = self.License or 'Unknown',
            HasEconomy = (self._GetMoneyFunc ~= nil)
        }
    end
}

GamemodeMeta.__index = GamemodeMeta


--- Creates a new gamemode object with the specified ID.
-- @param id (string): The unique identifier for the new gamemode.
-- @return (table): A new gamemode object with methods for setting properties.
function DBase.CreateGamemode(id)
    if (not id or type(id) ~= 'string' or id == '') then
        DBase:PrintType('Error', 'CreateGamemode: Invalid gamemode ID')
        return nil
    end
    
    -- Check if gamemode already exists
    if (DanLib.Temp.Gamemodes[id]) then
        DBase:PrintType('Warning', 'Gamemode "' .. id .. '" already exists. Use existing instance or unregister first.')
        return DanLib.Temp.Gamemodes[id]
    end
    
    local gamemode = {
        ID = id,
        Name = 'Unnamed Gamemode',
        Author = 'Unknown',
        Version = '0.0.0',
        Description = 'No description',
        License = 'Unknown'
    }
    
    setmetatable(gamemode, GamemodeMeta)
    return gamemode
end


local path = 'danlib/gamemodes/'

--- Loads all gamemode files from the specified directory.
-- This function searches for Lua files in the 'danlib/gamemodes/' directory,
-- adds them to the client-side, and includes them for execution.
function DBase.LoadGamemodes()
    local gamemodeFiles = file.Find(path .. '*.lua', 'LUA')
    
    if (not gamemodeFiles or #gamemodeFiles == 0) then
        DBase:PrintType('Warning', 'No gamemode files found in ' .. path)
        return
    end
    
    -- self:PrintType('Info', 'Loading ' .. #gamemodeFiles .. ' gamemode file(s)...')
    
    for k, file in ipairs(gamemodeFiles) do
        AddCSLuaFile(path .. file)
        include(path .. file)
    end
    
    -- self:PrintType('Success', 'Loaded ' .. table.Count(DanLib.Temp.Gamemodes) .. ' gamemode(s)')
end

--- Returns a table of all registered gamemodes.
-- @return (table): Table containing all registered gamemodes.
function DBase:GetAllGamemodes()
    return DanLib.Temp.Gamemodes
end

--- Retrieves a gamemode by its ID.
-- @param id (string): The gamemode ID to retrieve.
-- @return (table|nil): The gamemode object or nil if not found.
function DBase:GetGamemode(id)
    if (not id or type(id) ~= 'string') then
        self:PrintType('Error', 'GetGamemode: Invalid gamemode ID')
        return nil
    end
    return self:GetAllGamemodes()[id]
end

--- Returns the currently active gamemode.
-- @return (table|nil): The active gamemode object or nil if none set.
function DBase:GetActiveGamemode()
    return self:GetAllGamemodes()[DanLib.CONFIG.BASE.Gamemode]
end

--- Sets the active gamemode by ID.
-- @param id (string): The gamemode ID to set as active.
-- @return (boolean): true if successful, false otherwise.
function DBase:SetActiveGamemode(id)
    if (not id or type(id) ~= 'string') then
        self:PrintType('Error', 'SetActiveGamemode: Invalid gamemode ID')
        return false
    end
    
    if (not self:GetAllGamemodes()[id]) then
        self:PrintType('Error', 'SetActiveGamemode: Gamemode "' .. id .. '" not found')
        return false
    end
    
    local oldGamemode = self:GetActiveGamemode()

    -- Call OnLoad function if defined
    local gamemode = self:GetAllGamemodes()[id]
    if (gamemode._OnLoadFunc) then
        gamemode._OnLoadFunc()
    end
    
    hook.Run('DanLib:GamemodeChanged', gamemode, oldGamemode)
    self:PrintType('Success', 'Active gamemode set to "' .. id .. '"')
    
    return true
end

--- Helper functions for working with active gamemode
--- Gets the balance of a player using the active gamemode.
-- @param player (Player): The player entity.
-- @return (number): The player's balance.
function DBase.GetBalance(player)
    local gm = self:GetActiveGamemode()
    if (not gm) then
        return 0
    end
    return gm:GetMoney(player)
end

--- Gets the formatted balance of a player using the active gamemode.
-- @param player (Player): The player entity.
-- @return (string): The player's formatted balance.
function DanLib:GetBalanceFormatted(player)
    local gm = self:GetActiveGamemode()
    if (not gm) then
        return '0'
    end
    return gm:FormatMoney(player, gm:GetMoney(player))
end

--- Checks if a player can afford an amount using the active gamemode.
-- @param player (Player): The player entity.
-- @param amount (number): The amount to check.
-- @return (boolean): true if player can afford, false otherwise.
function DBase.CanAfford(player, amount)
    local gm = self:GetActiveGamemode()
    if (not gm) then
        return false
    end
    return gm:CanAfford(player, amount)
end

--- Adds money to a player using the active gamemode.
-- @param player (Player): The player entity.
-- @param amount (number): The amount to add.
-- @return (boolean): true if successful, false otherwise.
function DanLib:AddMoney(player, amount)
    local gm = self:GetActiveGamemode()
    if (not gm) then
        return false
    end
    return gm:AddMoney(player, amount)
end

--- Takes money from a player using the active gamemode.
-- @param player (Player): The player entity.
-- @param amount (number): The amount to take.
-- @return (boolean): true if successful, false otherwise.
function DanLib:TakeMoney(player, amount)
    local gm = self:GetActiveGamemode()
    if (not gm) then
        return false
    end
    return gm:TakeMoney(player, amount)
end

--- Formats money using the active gamemode.
-- @param player (Player): The player entity.
-- @param amount (number): The amount to format.
-- @return (string): Formatted money string.
function DBase:FormatMoney(player, amount)
    local gm = self:GetActiveGamemode()
    if (not gm) then
        return tostring(amount)
    end
    return gm:FormatMoney(player, amount)
end
