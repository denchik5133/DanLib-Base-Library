/***
 *   @addon         DanLib
 *   @version       3.0.0
 *   @release_date  10/4/2023
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *
 *   @description   Universal library for GMod Lua, combining all the necessary features to simplify script development. 
 *                  Avoid code duplication and speed up the creation process with this powerful and convenient library.
 *
 *   @usage         !danlibmenu (chat) | danlibmenu (console)
 *   @license       MIT License
 *   @notes         For feature requests or contributions, please open an issue on GitHub.
 */



local base = DanLib.Func
local networkUtil = DanLib.NetworkUtil
local network = DanLib.Network
local dHook = DanLib.Hook


-- Declaring network strings for sending and receiving configurations
networkUtil:AddString('DanLib:SendConfig')
networkUtil:AddString('DanLib:SendConfigUpdate')
networkUtil:AddString('DanLib:RequestSaveConfigChanges')


--- Function for writing the configuration table to the network stream
-- @param pPlayer: The player to whom the configuration is sent
-- @param configTable: Configuration table to be written
local function WriteConfigTable(pPlayer, configTable)
    network:WriteUInt(table.Count(configTable), 5)

    for k, v in pairs(configTable) do
        network:WriteString(k)
        network:WriteUInt(table.Count(v), 5)

        for key, val in pairs(v) do
            network:WriteString(key)
            local variableType = base.GetConfigType(k, key)
            base.ProcessTypeValue(variableType, val, true)
        end
    end
end


--- Function to send an updated configuration to the player
-- @param pPlayer: Player to whom the updated configuration is sent
-- @param changedConfig: Modified configuration to be sent
local function send_updated_config(pPlayer, changedConfig)
    network:Start('DanLib:SendConfigUpdate')
    WriteConfigTable(pPlayer, changedConfig)
    network:SendToPlayer(pPlayer)
end


--- Function for sending the complete configuration to the player
-- @param pPlayer: The player to whom the configuration is sent
function base:SendCompleteConfig(pPlayer)
    network:Start('DanLib:SendConfig')
    WriteConfigTable(pPlayer, DanLib.CONFIG)
    network:SendToPlayer(pPlayer)
end


--- Function for saving configuration changes
-- @param _: Unused argument (usually used in network functions)
-- @param pPlayer: The player who initiated the configuration save
local function HandleConfigSave(_, pPlayer)
    if (not base.HasPermission(pPlayer, 'EditSettings')) then
        base:CreatePopupNotifi(pPlayer, base:L('#access.denied'), base:L('#access.ver'), 'ERROR', 6)
        return 
    end

    local tbl = {}
    local moduleCount = network:ReadUInt(5)

    for i = 1, moduleCount do
        local Key = network:ReadString()
        tbl[Key] = {}

        for i = 1, network:ReadUInt(5) do
            local variable = network:ReadString()
            local variableType = base.GetConfigType(Key, variable)
            tbl[Key][variable] = base.ProcessTypeValue(variableType, nil, false)
        end
    end

    for k, v in pairs(tbl) do
        if (not DanLib.CONFIG[k]) then continue end

        for key, val in pairs(v) do
            DanLib.CONFIG[k][key] = val
        end

        file.Write('danlib/config/' .. k .. '.txt', networkUtil:TableToJSON(DanLib.CONFIG[k], true))
    end

    -- Send the updated configuration to all players
    send_updated_config(player.GetAll(), tbl)
    -- Run the hook to update the configuration
    hook.Run('DanLib:HooksConfigUpdated', pPlayer, tbl)
end
-- Registering the configuration save processing function
network:Receive('DanLib:RequestSaveConfigChanges', HandleConfigSave)
