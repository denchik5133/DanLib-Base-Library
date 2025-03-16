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


-- Written by Team Ulysses, http://ulyssesmod.net/
module('Utime', package.seeall)

local metaPlayer = DanLib.MetaPlayer

function metaPlayer:get_ddi_time()
	return self:GetNWFloat('ddi_time')
end

function metaPlayer:set_ddi_time(num)
	self:SetNWFloat('ddi_time', num)
end

function metaPlayer:get_ddi_time_start()
	return self:GetNWFloat('ddi_time_start')
end

function metaPlayer:set_ddi_time_start(num)
	self:SetNWFloat('ddi_time_start', num)
end

function metaPlayer:set_ddi_session_time()
	return CurTime() - self:get_ddi_time_start()
end

function metaPlayer:get_ddi_time()
	return self:get_ddi_time() + CurTime() - self:get_ddi_time_start()
end