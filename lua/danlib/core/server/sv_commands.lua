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



local network = DanLib.Network

concommand.Add('danlibmenu', function(pPlayer)
    network:Start('DanLib:BaseMenu')
    network:SendToPlayer(pPlayer)
end)

DanLib.Hook:Add('PlayerSay', 'DanLib.hooksOpenConfig', function(pPlayer, text)
    if (text:lower():sub(1, 1) ~= '!' or text:lower():sub(2, #DanLib.CONFIG.BASE.ChatCommand + 1) ~= DanLib.CONFIG.BASE.ChatCommand) then return end
    
    network:Start('DanLib:BaseMenu')
    network:SendToPlayer(pPlayer)
    return ''
end)

concommand.Add('player_coordinates', function(pPlayer)
    local pos, ang = pPlayer:GetPos(), pPlayer:GetAngles()
    pPlayer:PrintMessage(HUD_PRINTCONSOLE, string.format('{pos = Vector(%g, %g, %g), ang = Angle(%g, %g, %g)},', pos.x, pos.y, pos.z, ang.x, ang.y, ang.z))
end)