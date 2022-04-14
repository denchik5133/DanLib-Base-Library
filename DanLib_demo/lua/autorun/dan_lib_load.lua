LIB = LIB or {} -- IN NO CASE DO NOT TOUCH
LIB = {
    Config = {
        Style = {},
        Theme = {},
        Description = {},
        Different = {},
    },
    Utils = {},
    Localization = {},
}

LIB.NameBasis = 'The DanLib Base Library '
LIB.Autor = 'denchik'
LIB.Version = 'Demo'
LIB.Dir = 'lib'

include('lib/func/sh_nw.lua')
AddCSLuaFile('lib/func/sh_nw.lua')
MsgC(Color(30, 144, 255), '[DanLib] ', Color(255, 215, 0), ' NW loaded.\n')

include('lib/func/sh_pon.lua')
AddCSLuaFile('lib/func/sh_pon.lua')
MsgC(Color(30, 144, 255), '[DanLib] ', Color(255, 215, 0), ' PON loaded.\n')

include('lib/func/sh_netstream.lua')
AddCSLuaFile('lib/func/sh_netstream.lua')
MsgC(Color(30, 144, 255), '[DanLib] ', Color(255, 215, 0), ' NetStream v2 loaded.\n')

MsgC(Color(30, 144, 255), '[DanLib] ', Color(255, 215, 0), ' started loading. Author: '..LIB.Autor..' Version: '..LIB.Version..'\n')

function LIB.Load(dir)
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

LIB.Load(LIB.Dir)
LIB.Load(LIB.Dir.. '/chat')
LIB.Load(LIB.Dir.. '/func')
LIB.Load(LIB.Dir.. '/vgui')
LIB.Load(LIB.Dir.. '/download')
LIB.Load(LIB.Dir.. '/elements')

if SERVER then
	util.AddNetworkString('Dan.Lib.Msg')
	util.AddNetworkString('Paws.lib.Loaded')
	util.AddNetworkString('lib_menu_base')
end

hook.Run('LIB::ConfigLoaded') -- AND IT IS NOT IN ANY CASE NOT TO TOUCH
hook.Run('LIB::ModulesLoaded') -- AND IT IS NOT IN ANY CASE NOT TO TOUCH