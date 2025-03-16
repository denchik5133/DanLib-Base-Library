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

 

-- Top-level library containing all DanLib libraries. β
DanLib = DanLib or {}

-- Load permissions manager
local function InitPostEntityLoaded()
	DanLib.InitPostEntityLoaded = true
end

hook.Add('InitPostEntity', 'DanLib:InitPostEntityLoaded', function()
    InitPostEntityLoaded()
end)


local function InitializeLoaded()
	DanLib.InitializeLoaded = true
end

hook.Add('Initialize', 'DanLib:InitializeLoaded', function()
    InitializeLoaded()
end)


local function LoadClientConfig()
    DanLib.BaseClientConfig = DanLib.BaseClientConfig or {}
    hook.Run('DanLib:LoadClientConfig')
end
LoadClientConfig()


hook.Add('DanLib:LoadClientConfig', 'DanLib:LoadClientConfig', function()
    -- AddCSLuaFile('danlib/core/config/sh_clientconfig.lua')
    -- include('danlib/core/config/sh_clientconfig.lua')
end)




concommand.Add('danlib_restart', function(pPlayer)
    DanLib = DanLib or {}
    DanLib.Loading.Start()

    if SERVER then
        if (IsValid(pPlayer) and pPlayer:IsPlayer()) then
            DanLib.Func:SendCompleteConfig(pPlayer)
        end
    end
end)
