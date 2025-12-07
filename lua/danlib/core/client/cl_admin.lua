/***
 *   @addon         DanLib
 *   @version       2.4.0
 *   @release_date  07/12/2025
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *   @description   Enhanced client config system with staged changes, batch operations
 *
 *   @changelog     2.4.0
 *                  - Added SaveSingleSetting() for immediate single-variable saves
 *                  - Added GetEffectiveConfigValue() to check staged + current values
 *                  - Added GetStagedChangesCount() to track pending changes
 *                  - Added DiscardConfigChanges() to cancel staged changes
 *                  - Added skipHookUpdate parameter to SaveSettings() for welcome tutorial
 *                  - Improved debug logging with conditional output
 *                  - Added validation for unknown variables (prevents silent failures)
 *                  - Function localization for better performance
 *                  - Enhanced error messages with context
 *
 *   @features      Configuration Management:
 *                  - Staged changes (edit multiple settings before saving)
 *                  - Single-setting saves (immediate apply)
 *                  - Batch saves (save all at once)
 *                  - Effective value lookup (staged + current)
 *                  - Change tracking and discard
 *
 *   @license       MIT License
 */



local DBase = DanLib.Func
local DNetwork = DanLib.Network
local DTable = DanLib.Table

local _pairs = pairs
local _print = print
local _tableCount = table.Count
local _LocalPlayer = LocalPlayer
local _strFormat = string.format

-- DEBUG LOGGING SYSTEM
local function _debugLog(level, message)
    if (not DanLib.CONFIG or not DanLib.CONFIG.BASE or not DanLib.CONFIG.BASE.Debugg) then
        return
    end
    
    local prefix = '[DanLib Config]'
    local colorCode = ''
    
    if (level == 'ERROR') then
        colorCode = '[ERROR] '
    elseif (level == 'WARNING') then
        colorCode = '[WARNING] '
    elseif (level == 'SUCCESS') then
        colorCode = '[SUCCESS] '
    elseif (level == 'INFO') then
        colorCode = '[INFO] '
    end
    
    _print(_strFormat('%s %s%s', prefix, colorCode, message))
end

--- Read configuration table from network
-- @return (number, number): moduleCount, variableCount
local function ReadConfigTable()
    local variableCount = 0
    local moduleCount = DNetwork:ReadUInt(5)

    for i = 1, moduleCount do
        local moduleKey = DNetwork:ReadString()
        DanLib.CONFIG[moduleKey] = DanLib.CONFIG[moduleKey] or {}

        local varCount = DNetwork:ReadUInt(5)
        for j = 1, varCount do
            local variable = DNetwork:ReadString()
            local variableType = DBase.GetConfigType(moduleKey, variable)
            
            if variableType then
                DanLib.CONFIG[moduleKey][variable] = DBase.ProcessTypeValue(variableType, nil, false)
                variableCount = variableCount + 1
            else
                _debugLog('WARNING', _strFormat('Unknown variable %s.%s', moduleKey, variable))
            end
        end
    end
    
    return moduleCount, variableCount
end

--- Handle initial config sync from server
DNetwork:Receive('DanLib:SendConfig', function()
    DanLib.CONFIG = {}
    local moduleCount, variableCount = ReadConfigTable()
    
    _debugLog('INFO', _strFormat('Received initial config: %d modules, %d variables', moduleCount, variableCount))
    hook.Run('DanLib:HooksConfigUpdated')
end)

--- Handle config updates from server
DNetwork:Receive('DanLib:SendConfigUpdate', function()
    if (not DBase.HasPermission(_LocalPlayer(), 'EditSettings')) then
        return
    end

    local moduleCount, variableCount = ReadConfigTable()
    
    -- Check if we should skip the hook (for welcome tutorial)
    if DanLib._SkipNextConfigHook then
        DanLib._SkipNextConfigHook = nil
        _debugLog('INFO', 'Skipped config update hook')
        return
    end
    
    _debugLog('INFO', _strFormat('Config updated: %d modules, %d variables', moduleCount, variableCount))
    hook.Run('DanLib:HooksConfigUpdated')
end)

--- Stage a configuration change (doesn't save immediately)
-- @param module (string): Module name
-- @param variable (string): Variable name
-- @param value (any): New value
-- @return (bool): Success status
function DBase:SetConfigVariable(module, variable, value)
    if (not DBase.HasPermission(_LocalPlayer(), 'EditSettings')) then
        return false
    end

    DanLib.ChangedConfig = DanLib.ChangedConfig or {}
    DanLib.ChangedConfig[module] = DanLib.ChangedConfig[module] or {}
    DanLib.ChangedConfig[module][variable] = value
    
    return true
end

--- Get a staged configuration value
-- @param module (string): Module name
-- @param variable (string): Variable name
-- @return (any): Staged value or nil
function DBase:RetrieveUpdatedVariable(module, variable)
    if (not DanLib.ChangedConfig or not DanLib.ChangedConfig[module]) then
        return nil
    end
    
    return DanLib.ChangedConfig[module][variable]
end

--- Get effective config value (staged or current)
-- @param module (string): Module name
-- @param variable (string): Variable name
-- @return (any): Effective value
function DBase:GetEffectiveConfigValue(module, variable)
    -- Check staged changes first
    local stagedValue = DBase:RetrieveUpdatedVariable(module, variable)
    if (stagedValue ~= nil) then
        return stagedValue
    end
    
    -- Fall back to current config
    if DanLib.CONFIG[module] then
        return DanLib.CONFIG[module][variable]
    end
    
    return nil
end

--- Discard all staged configuration changes
-- @return (bool): Whether any changes were discarded
function DBase:DiscardConfigChanges()
    if DanLib.ChangedConfig then
        local count = _tableCount(DanLib.ChangedConfig)
        DanLib.ChangedConfig = nil
        DBase:PrintType('Info', 'Discarded ' .. count .. ' staged change(s)')
        return true
    end
    
    return false
end

--- Get count of staged changes
-- @return (number): Number of staged changes
function DBase:GetStagedChangesCount()
    if (not DanLib.ChangedConfig) then
        return 0
    end
    
    local count = 0
    for module, vars in _pairs(DanLib.ChangedConfig) do
        for variable, value in _pairs(vars) do
            count = count + 1
        end
    end
    
    return count
end

--- Save a single configuration setting immediately
-- @param module (string): Module name
-- @param variable (string): Variable name
-- @param value (any): New value
-- @return (bool): Success status
function DBase:SaveSingleSetting(module, variable, value)
    if (not DBase.HasPermission(_LocalPlayer(), 'EditSettings')) then 
        return false
    end
    
    -- Validate module and variable exist
    local variableType = DBase.GetConfigType(module, variable)
    if (not variableType) then
        DBase:PrintType('Error', 'Invalid module or variable: ' .. module .. '.' .. variable)
        return false
    end
    
    -- Send to server
    DNetwork:Start('DanLib:RequestSaveConfigChanges')
    DNetwork:WriteUInt(1, 5) -- 1 module
    DNetwork:WriteString(module)
    DNetwork:WriteUInt(1, 5) -- 1 variable
    DNetwork:WriteString(variable)
    DBase.ProcessTypeValue(variableType, value, true)
    DNetwork:SendToServer()
    
    -- Clear from staged changes
    if (DanLib.ChangedConfig and DanLib.ChangedConfig[module]) then
        DanLib.ChangedConfig[module][variable] = nil
        
        if (_tableCount(DanLib.ChangedConfig[module]) == 0) then
            DanLib.ChangedConfig[module] = nil
        end
        
        if (_tableCount(DanLib.ChangedConfig) == 0) then
            DanLib.ChangedConfig = nil
        end
    end
    
    DBase:PrintType('Info', 'Saving ' .. module .. '.' .. variable)
    return true
end

--- Save multiple configuration settings
-- @param settingsTable (table): { MODULE = { variable = value } }
-- @param skipHookUpdate (bool): If true, skip config update hook (for welcome tutorial)
-- @return (bool): Success status
function DBase:SaveSettings(settingsTable, skipHookUpdate)
    if (not DBase.HasPermission(_LocalPlayer(), 'EditSettings')) then 
        return false
    end
    
    if (not settingsTable or _tableCount(settingsTable) == 0) then
        DBase:PrintType('Warning', 'No settings to save')
        return false
    end
    
    -- Set skip hook flag if requested
    if skipHookUpdate then
        DanLib._SkipNextConfigHook = true
    end
    
    -- Send to server
    DNetwork:Start('DanLib:RequestSaveConfigChanges')
    DNetwork:WriteUInt(_tableCount(settingsTable), 5)
    
    for moduleKey, moduleData in _pairs(settingsTable) do
        DNetwork:WriteString(moduleKey)
        DNetwork:WriteUInt(_tableCount(moduleData), 5)
        
        for variable, value in _pairs(moduleData) do
            DNetwork:WriteString(variable)
            local variableType = DBase.GetConfigType(moduleKey, variable)
            
            if variableType then
                DBase.ProcessTypeValue(variableType, value, true)
            else
                _debugLog('WARNING', _strFormat('Skipping unknown variable %s.%s', moduleKey, variable))
            end
        end
    end
    
    DNetwork:SendToServer()
    
    -- Clear staged changes
    DanLib.ChangedConfig = nil
    
    -- If skipping hook, apply changes locally immediately
    if skipHookUpdate then
        for moduleKey, moduleData in _pairs(settingsTable) do
            DanLib.CONFIG[moduleKey] = DanLib.CONFIG[moduleKey] or {}
            for variable, value in _pairs(moduleData) do
                DanLib.CONFIG[moduleKey][variable] = value
            end
        end
    end
    
    DBase:PrintType('Info', 'Saving ' .. _tableCount(settingsTable) .. ' module(s)')
    return true
end

-- NOTIFICATION HANDLERS
DNetwork:Receive('DanLib:ScreenNotification', function()
    DBase:ScreenNotification(DNetwork:ReadString(), DNetwork:ReadString(), DNetwork:ReadString(), DNetwork:ReadString(), DNetwork:ReadString(), DNetwork:ReadString())
end)

DNetwork:Receive('DanLib:SidePopupNotification', function()
    DBase:SidePopupNotification(DNetwork:ReadString(), DNetwork:ReadString(), DNetwork:ReadString())
end)

-- CHAT MESSAGE HANDLER
local MESSAGE = DanLib.BaseConfig.ChatType or {}
DNetwork:Receive('DanLib:Message', function()
    local msgType = DNetwork:ReadInt(8) or -1
    local args = DNetwork:ReadTable(512)

    local toPrint = {}
    local messageColor, messageText

    if (msgType == MESSAGE.MESSAGES_TYPE.SUCCESS) then
        messageColor = MESSAGE.SUCCESS_COLOR
        messageText = MESSAGE.SUCCESS_MSG
    elseif (msgType == MESSAGE.MESSAGES_TYPE.WARNING) then
        messageColor = MESSAGE.WARNING_COLOR
        messageText = MESSAGE.WARNING_MSG
    elseif (msgType == MESSAGE.MESSAGES_TYPE.ERROR) then
        messageColor = MESSAGE.ERROR_COLOR
        messageText = MESSAGE.ERROR_MSG
    end

    if (messageColor and messageText) then
        DTable:Add(toPrint, messageColor)
        DTable:Add(toPrint, DBase:L(messageText))
        DTable:Add(toPrint, Color(255, 255, 255))
        DTable:Add(toPrint, ' ')
    end

    table.Add(toPrint, args)
    chat.AddText(unpack(toPrint))
end)
