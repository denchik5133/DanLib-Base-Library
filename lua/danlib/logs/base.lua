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
 


-- Configuration
local CONFIG = DanLib.Func.CreateLogs('Configuration')
CONFIG:SetDescription('Configuration changes. This parameter allows you to track who changes the configuration of the base.')
CONFIG:SetColor(Color(255, 165, 0))
CONFIG:SetSort(1)
CONFIG:SetSetup(function()
	if (SERVER) then
		DanLib.Hook:Add('DanLib:HooksConfigUpdated', 'Logs.SaveConfig', function(pPlayer, tbl)
		    local function TableTo()
				return DanLib.NetworkUtil:TableToJSON(tbl, true)
			end

			DanLib.Func:GetDiscordLogs('Configuration', DanLib.Func:L('save_config', {
				player = pPlayer:Nick(),
				steamid = pPlayer:SteamID(),
				steamid64 = pPlayer:SteamID64(),
				table = TableTo()
			}))
		end)
	end
end)
CONFIG:Register()


-- RANKS
local RANK = DanLib.Func.CreateLogs('EditRank')
RANK:SetDescription("Changing a player's rank.")
RANK:SetColor(Color(0, 165, 0))
RANK:SetSort(2)
RANK:SetSetup(function()
	if (SERVER) then
		DanLib.Hook:Add('DanLib.Rank.Changed', 'Logs.Rank', function(pPlayer, old_rank, new_rank, author)
	    	local color = Color(0, 165, 0)
			local fields = {
				{name = 'To whom', value = pPlayer:Name(), inline = true},
				{name = 'Old Rank', value = old_rank, inline = true},
				{name = 'New Rank', value = new_rank, inline = true},
				{name = 'Author', value = author:Name(), inline = true},
			}

			DanLib.Func:GetDiscordLogs('EditRank', DanLib.Func:L('#rank.log.changed'), fields, color)
		end)
	end
end)
RANK:Register()