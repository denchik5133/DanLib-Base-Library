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



local base = DanLib.Func
local network = DanLib.Network
local Table = DanLib.Table


--- Reads the configuration table from the network and updates the global config.
-- @return moduleCount (number): number of modules received from the network.
-- @return variableCount (number): number of variables retrieved from the network.
local function readTable()
    local variableCount = 0
    local moduleCount = network:ReadUInt(5)

    for i = 1, moduleCount do
        local moduleKey = network:ReadString()
        DanLib.CONFIG[moduleKey] = DanLib.CONFIG[moduleKey] or {}

        for j = 1, network:ReadUInt(5) do
            local variable = network:ReadString()
            local variableType = base.GetConfigType(moduleKey, variable)
            DanLib.CONFIG[moduleKey][variable] = base.ProcessTypeValue(variableType, nil, false)
            variableCount = variableCount + 1
        end
    end
    return moduleCount, variableCount
end


--- Handles the receipt of configuration from the server,
-- clearing the current configuration and updating it.
network:Receive('DanLib:SendConfig', function()
    DanLib.CONFIG = {}
    readTable()
    hook.Run('DanLib:HooksConfigUpdated')
end)


--- Handles configuration updates from the server
-- by checking permissions and updating the configuration.
network:Receive('DanLib:SendConfigUpdate', function()
    if (not base.HasPermission(LocalPlayer(), 'EditSettings')) then return end
    readTable()
    hook.Run('DanLib:HooksConfigUpdated')
    --RunConsoleCommand('spawnmenu_reload')
end)


--- Requests a configuration change.
-- @param module (string): name of the module for which the change is requested.
-- @param variable (string): name of the variable to be changed.
-- @param value (any): the new value of the variable.
function base:SetConfigVariable(module, variable, value)
    if (not base.HasPermission(LocalPlayer(), 'EditSettings')) then return end
    DanLib.ChangedConfig = DanLib.ChangedConfig or {}
    DanLib.ChangedConfig[module] = DanLib.ChangedConfig[module] or {}
    DanLib.ChangedConfig[module][variable] = value
end


--- Gets the modified value of the variable.
-- @param module (string): module name.
-- @param variable (string): variable name.
-- @return (any): the changed value of the variable or nil if no change is found.
function base:RetrieveUpdatedVariable(module, variable)
    if (not DanLib.ChangedConfig or not DanLib.ChangedConfig[module] or not DanLib.ChangedConfig[module][variable]) then return end
    return DanLib.ChangedConfig[module][variable]
    -- return DanLib.ChangedConfig and DanLib.ChangedConfig[module] and DanLib.ChangedConfig[module][variable]
end


--- Handles notifications on the screen by receiving strings
-- from the network and passing them to the notification function.
network:Receive('DanLib:ScreenNotification', function()
    base:ScreenNotification(network:ReadString(), network:ReadString(), network:ReadString(), network:ReadString(), network:ReadString(), network:ReadString())
end)


--- Handles notifications in the side pop-up window.
local function SidePopupNotification()
    base:SidePopupNotification(network:ReadString(), network:ReadString(), network:ReadString())
end
network:Receive('DanLib:SidePopupNotification', SidePopupNotification)



local MESSAGE = DanLib.BaseConfig.ChatType or {}

--- Processes incoming messages and displays them in the chat room.
local function recieve_message()
    local type = network:ReadInt(8) or -1
    local args = network:ReadTable(512)

    local toPrint = {}
    local messageColor, messageText

    if (type == MESSAGE.MESSAGES_TYPE.SUCCESS) then
        messageColor = MESSAGE.SUCCESS_COLOR
        messageText = MESSAGE.SUCCESS_MSG
    elseif (type == MESSAGE.MESSAGES_TYPE.WARNING) then
        messageColor = MESSAGE.WARNING_COLOR
        messageText = MESSAGE.WARNING_MSG
    elseif (type == MESSAGE.MESSAGES_TYPE.ERROR) then
        messageColor = MESSAGE.ERROR_COLOR
        messageText = MESSAGE.ERROR_MSG
    end

    if (messageColor and messageText) then
        Table:Add(toPrint, messageColor)
        Table:Add(toPrint, base:L(messageText))
        Table:Add(toPrint, Color(255, 255, 255, 255))
        Table:Add(toPrint, ' ')
    end

    table.Add(toPrint, args)
    chat.AddText(unpack(toPrint))
end
network:Receive('DanLib:Message', recieve_message)
