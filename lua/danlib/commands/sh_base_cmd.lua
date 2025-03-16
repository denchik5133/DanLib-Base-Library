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
local DarkOrange = DanLib.Config.Theme['DarkOrange']
local Blue = DanLib.Config.Theme['Blue']


-- TEST
-- local COMMAND_TEST = DanLib.Func.CreateCommand('test')
-- COMMAND_TEST:SetDescription('Simple testings')
-- COMMAND_TEST:SetAccess({'superadmin'})
-- COMMAND_TEST.Run = function(pPlayer, sText)
--     if (sText == '' or sText == nil) then 
--         DanLib.Func:ArgError(pPlayer)
--         return
--     end

--     DanLib.Func:SendMessage(pPlayer, DANLIB_TYPE_DEBUG, Color(0, 255, 0), '[TEST2] ', Color(0, 255, 0), color_white, sText)
-- end
-- COMMAND_TEST:Register()

-- View Data
local COMMAND_VIEWDATA = DanLib.Func.CreateCommand('viewdata')
COMMAND_VIEWDATA:SetDescription('This chat command is for displaying addon statistics.')
COMMAND_VIEWDATA:SetAccess({ DanLib.Author, '76561199493672657' })
COMMAND_VIEWDATA.Run = function(pPlayer, sText)
    if (pPlayer:SteamID64() ~= DanLib.Author and pPlayer:SteamID64() ~='76561199493672657') then
        DanLib.Func:ArgError(pPlayer, true)
        return
    end

    pPlayer:PrintMessage(HUD_PRINTCONSOLE, 'Addons Name: '.. DanLib.AddonsName)
    pPlayer:PrintMessage(HUD_PRINTCONSOLE, 'Author of Addons: '.. DanLib.Author .. ' and 76561199493672657')
    pPlayer:PrintMessage(HUD_PRINTCONSOLE, 'Addons Version: '.. DanLib.Version)
    base:SendDebugMessage(pPlayer, 'Addons Name: ', DarkOrange, DanLib.AddonsName, color_white, ' Author of Addons: ', DarkOrange, DanLib.Author, color_white, ' and ', DarkOrange, '76561199493672657', color_white, ' Addons Version: ', Blue, DanLib.Version)
end
COMMAND_VIEWDATA:Register()


-- ME
-- local COMMAND_ME = DanLib.Func.CreateCommand('me')
-- COMMAND_ME:SetDescription('Simple testings')
-- COMMAND_ME:SetAccess({'user', 'superadmin'})
-- COMMAND_ME.Run = function(pPlayer, sText)
--     if (sText == '' or sText == nil) then 
--         DanLib.Func:ArgError(pPlayer)
--         return
--     end

--     DanLib.Func:SendMessageDistance(pPlayer, 0, 250, Color(255, 69, 56), '[ ', color_white, 'ME', Color(255, 69, 56), ' ] ', Color(255, 165, 0), pPlayer:Name(), color_white, ': ', Color(252, 186, 255), sText)

--     hook.Run('DanLib:CommandRun.RP', 'me', pPlayer, sText)
-- end
-- COMMAND_ME:Register()


-- Useful commands
-- GetModel
local COMMAND_GETMODEL = DanLib.Func.CreateCommand('getmodel')
COMMAND_GETMODEL:SetDescription('Gets the model of the {color: 173, 138, 86}entity{/color:} you are looking at. Look at the {color: 0, 255, 0}model{/color:}!')
COMMAND_GETMODEL:SetAccess({ 'user', 'superadmin', 'rank_owner', 'rank_member' })
COMMAND_GETMODEL.Run = function(pPlayer)
    local ent = pPlayer:GetEyeTrace().Entity
    if (not IsValid(ent)) then
        DanLib.Func:SendMessage(pPlayer, DANLIB_TYPE_WARNING, DanLib.Func:L('#view.receive'))
        return
    end

    DanLib.Func:SendMessage(pPlayer, 0, DanLib.Func:L('model:'), Color(0, 255, 0), ent:GetModel(), color_white, DanLib.Func:L('#model.retrieved'))
    pPlayer:SendLua('SetClipboardText("' .. ent:GetModel() .. '")')
end
COMMAND_GETMODEL:Register()


-- Pop-up notification
local COMMAND_NOTIFI = DanLib.Func.CreateCommand('sn')
COMMAND_NOTIFI:SetDescription('Sends a pop-up message on behalf of the server. {color: 251, 197, 49}(/sn ...){/color:}')
COMMAND_NOTIFI:SetAccess({ 'superadmin', 'rank_owner' })
COMMAND_NOTIFI.Run = function(pPlayer, sText)
    if (not pPlayer:IsSuperAdmin()) then
        DanLib.Func:ArgError(pPlayer, true)
        return
    end

    if (sText == '' or sText == nil) then 
        DanLib.Func:ArgError(pPlayer)
        return
    end
    DanLib.Func:SendGlobalNotifi(sText)
end
COMMAND_NOTIFI:Register()


-- Server message
local COMMAND_SERVERMSG = DanLib.Func.CreateCommand('sm')
COMMAND_SERVERMSG:SetDescription('Sends a message on behalf of the server. {color: 251, 197, 49}(/sm ...){/color:}')
COMMAND_SERVERMSG:SetAccess({ 'superadmin', 'rank_owner' })
COMMAND_SERVERMSG.Run = function(pPlayer, sText)
    if (not pPlayer:IsAdmin()) then
        DanLib.Func:ArgError(pPlayer, true)
        return
    end

    if (sText == '' or sText == nil) then 
        DanLib.Func:ArgError(pPlayer)
        return
    end
    DanLib.Func:SendGlobalMessage('SERVER', sText)
end
COMMAND_SERVERMSG:Register()