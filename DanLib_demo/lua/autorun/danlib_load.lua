--Check if the addon has been loaded before.
if DanLib then
	hook.Run("DanLib::AddonReload")
end

AddCSLuaFile('autorun/sh_danlib_loader.lua')
include('autorun/sh_danlib_loader.lua')

--Create a global workspace table.
DanLib = DanLib or {} -- IN NO CASE DO NOT TOUCH
DanLib = {
	AddonsName = DanLib_AddonsName,
	Author = DanLib_Author,
	Version = DanLib_Version,
	Outdated = false,
	LatestVersion = DanLib and DanLib.LatestVersion or '',
    Config = {
        Style = {},
        Theme = {},
        Description = {},
        Different = {},
        Localization = {},
    },
    Configuration = {
    	Config = {},
		ConfigOptions = {},
    },
    Utils = {},
    Modules = {},
    Func = {},
    Localization = {},
}

DanLibUI = DanLibUI or {}

DanLib.Dir = 'lib'

include('lib/func/sh_nw.lua')
AddCSLuaFile('lib/func/sh_nw.lua')

include('lib/func/sh_pon.lua')
AddCSLuaFile('lib/func/sh_pon.lua')

include('lib/func/sh_netstream.lua')
AddCSLuaFile('lib/func/sh_netstream.lua')


function DanLib.Load(dir)
	local files = file.Find(dir.. '/'.. '*', 'LUA')
	for k, v in pairs(files) do
		if string.StartWith(v, 'cl') then
			if CLIENT then
				local load = include(dir.. '/'.. v)
				if load then load() end
			end
			AddCSLuaFile(dir.. '/'.. v)
		end

		if string.StartWith(v, 'sv') then
			if SERVER then
				local load = include(dir.. '/'.. v)
				if load then load() end
			end
		end

		if string.StartWith(v, 'sh') then
			local load = include(dir.. '/'.. v)
			if load then load() end

			AddCSLuaFile(dir.. '/'.. v)
		end

		MsgC(Color(30, 144, 255), '[DanLib] ', Color(255, 215, 0), ' Files "', dir, '/', v, Color(255, 215, 0), '" loaded.\n')
	end
end

DanLib.Load(DanLib.Dir)
DanLib.Load(DanLib.Dir.. '/chat')
DanLib.Load(DanLib.Dir.. '/func')
DanLib.Load(DanLib.Dir.. '/vgui')
DanLib.Load(DanLib.Dir.. '/download')
DanLib.Load(DanLib.Dir.. '/elements')
DanLib.Load(DanLib.Dir.. '/localizations')
DanLib.Load(DanLib.Dir.. '/languages')

if SERVER then
	util.AddNetworkString('DanLib.Msg')
	util.AddNetworkString('Paws.lib.Loaded')
	util.AddNetworkString('danlib_menu_base')
	util.AddNetworkString('danLibmenu_introduction')
	util.AddNetworkString('DanLibСheckInt')
	util.AddNetworkString('danlib_networkoptions')
	util.AddNetworkString('danlib_networkpunishments')
	util.AddNetworkString('danlib_networkpresets')

	--Pool network messages.
	util.AddNetworkString('DanLib::UpdatePlayerConfig')
	util.AddNetworkString('DanLib_SaveConfiguration')
	util.AddNetworkString('DanLib::ConfigurationSaved')
	util.AddNetworkString('DanLib::RequestConfig')
	util.AddNetworkString('DanLib::ConfigRequester')
end

hook.Run('DanLib::ConfigLoaded') -- AND IT IS NOT IN ANY CASE NOT TO TOUCH
hook.Run('DanLib::ModulesLoaded') -- AND IT IS NOT IN ANY CASE NOT TO TOUCH

function DanLib.CheckUpdates()
	http.Fetch("https://raw.githubusercontent.com/Blu-x92/LunasFlightSchool/master/lfs_base/lua/autorun/lfs_basescript.lua", function(contents,size) 
		local LatestVersion = tonumber( string.match( string.match( contents, "DanLib.Version%s=%s%d+" ) , "%d+" ) ) or 0

		if LatestVersion == 0 then
			print("[DanLib] latest version could not be detected, You have Version: "..DanLib.GetVersion())
		else
			if DanLib.GetVersion() >= LatestVersion then
				print("[DanLib] is up to date, Version: "..DanLib.GetVersion())
			else
				print("[DanLib] a newer version is available! Version: "..LatestVersion..", You have Version: "..DanLib.GetVersion())
				print("[DanLib] get the latest version at https://github.com/Blu-x92/LunasFlightSchool")
				
				if CLIENT then 
					timer.Simple(18, function() 
						chat.AddText( Color( 255, 0, 0 ), "[DanLib] a newer version is available!" )
					end)
				end
			end
		end
	end)
end

function DanLib.GetVersion()
	return DanLib.Version
end

hook.Add( "InitPostEntity", "!!!lfscheckupdates", function()
	timer.Simple(20, function() DanLib.CheckUpdates() end)
end )