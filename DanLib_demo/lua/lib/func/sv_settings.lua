/*

--[[-------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------]]

-- Create a table to check the types.
local typeFunction = {
	[DanLib_Config_Bool] = isbool,
	[DanLib_Config_String] = isstring,
	[DanLib_Config_Number] = isnumber,
	[DanLib_Config_Table] = isstring,
	[DanLib_Config_Color] = function( colorTbl )
		if !istable(colorTbl) then return false end
		if !colorTbl.r or !colorTbl.g or !colorTbl.b or !colorTbl.a then return end
		return true
	end,
}

local serverFields = {
	["Name"] = "Unknown Server",
	["Address"] = "00.00.000.00",
	["Port"] = "27015",
	["Map"] = "gm_construct",
	["Gamemode"] = "DarkRP",
	["Slots"] = "32",
}

-- Create a function to verify a configtable.
function DanLib.VerifyConfig( globalConfig, usergroupsConfig, hiddenTeams, orderedTeams, servers )

	-- Create a var if there was any changes made.
	local changesMade = false

	-- Loop through DanLib.ConfigValues.Config.
	for k,v in pairs(DanLib.ConfigValues.Config) do

		-- Make sure the configuration isn't missing any value.
		if globalConfig[k] == nil or (typeFunction[v.TypeEnum] and typeFunction[v.TypeEnum](globalConfig[k]) == false) or (v.TypeEnum == DanLib_Config_Table and !table.HasValue(v.AllowedValues, globalConfig[k])) then

			-- Print that we added a missing configuration value.
			EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CONSOLE, "Reset missing/invalid configuration value '" .. k .. "'." )

			-- Add the missing configuration.
			globalConfig[k] = v.Default

			-- Update changesMade.
			changesMade = true

		end

	end

	-- Loop through usergroupsConfig.
	for groupName,groupConfig in pairs(usergroupsConfig) do

		-- Loop through all the usergroups.
		for configName,configTable in pairs(DanLib.ConfigValues.Usergroups) do

			-- Make sure the configuration isn't missing any value.
			if groupConfig[configName] == nil or (typeFunction[configTable.TypeEnum] and typeFunction[configTable.TypeEnum](groupConfig[configName]) == false) then

				-- Print that we added a missing configuration value.
				EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CONSOLE, "Reset missing/invalid configuration value '" .. configName .. "' for usergroup '" .. groupName .. "'.")

				-- Add the missing configuration.
				usergroupsConfig[groupName][configName] = configTable.Default

				-- Update changesMade.
				changesMade = true

			end

		end

		-- Loop through the usergroup.
		for k2,v2 in pairs(groupConfig) do

			-- Make sure the configuration isn't having any unnecessary values.
			if !DanLib.ConfigValues.Usergroups[k2] then

				-- Print that we added a missing configuration value.
				EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CONSOLE, "Removed unused configuration value '" .. k2 .. "' for usergroup '" .. groupName .. "'.")

				-- Add the missing configuration.
				usergroupsConfig[groupName][k2] = nil

				-- Update changesMade.
				changesMade = true

			end

		end

	end

	-- Loop through globalConfig.
	for k,v in pairs(globalConfig) do

		-- Make sure the configuration isn't having any unnecessary values.
		if !DanLib.ConfigValues.Config[k] then

			-- Print that we added a missing configuration value.
			EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CONSOLE, "Removed unused configuration value '" .. k .. "'.")

			-- Add the missing configuration.
			globalConfig[k] = nil

			-- Update changesMade.
			changesMade = true

		end

	end

	-- Loop through hiddenTeams.
	for k,v in pairs(hiddenTeams) do
		if !isnumber(k) or !isstring(v) then
			hiddenTeams[k] = nil
			changesMade = true
		end
	end

	-- Loop through orderedTeams.
	for k,v in pairs(orderedTeams) do
		if !isnumber(k) or !isstring(v) then
			orderedTeams[k] = nil
			changesMade = true
		end
	end

	-- Loop through the servers
	for k,v in pairs(servers) do

		-- Make sure the table dont have any illegal keys.
		for k2,v2 in pairs(v) do

			if !serverFields[k2] then
				servers[k][k2] = nil
				changesMade = true
			end

		end

		--Loop through all the required fields.
		for k2,v2 in pairs(serverFields) do

			if !v[k2] then
				v[k2] = v2
				changesMade = true
			end

		end

	end

	-- Return the updated configurations and if there was any changes made.
	return changesMade, globalConfig, usergroupsConfig, hiddenTeams, orderedTeams, servers

end

-- Create a function to save the configuration.
function DanLib.SaveConfig( globalConfig, usergroupsConfig, hiddenTeams, orderedTeams, servers )

	-- Convert the tables into JSOn.
	globalConfig = util.TableToJSON(globalConfig)
	usergroupsConfig = util.TableToJSON(usergroupsConfig)
	local teamConfig = util.TableToJSON({["hiddenTeams"] = hiddenTeams, ["orderedTeams"] = orderedTeams})
	servers = util.TableToJSON(servers)

	-- Make sure that the conversation was successfull.
	if !globalConfig or !usergroupsConfig or !teamConfig or !servers then
		error("Failed to save configuration: Couldn't convert from table to JSON.")
	end

	-- Write the configuration.
	file.Write("danlib/config.txt", globalConfig)
	file.Write("danlib/usergroups.txt", usergroupsConfig)
	file.Write("danlib/teams.txt", teamConfig)
	file.Write("danlib/servers.txt", servers)

end

-- Create a function to read the configuration.
function DanLib.ReadConfig(  )

	-- Attempt to read the configuration.
	local globalConfig = file.Read("danlib/config.txt","DATA")
	local usergroupsConfig = file.Read("danlib/usergroups.txt","DATA")
	local teamConfig = file.Read("danlib/teams.txt","DATA")
	local serversConfig = file.Read("danlib/servers.txt","DATA")

	-- Convert the configurations from JSON to a table.
	globalConfig = util.JSONToTable(globalConfig)
	usergroupsConfig = util.JSONToTable(usergroupsConfig)
	teamConfig = util.JSONToTable(teamConfig)
	serversConfig = util.JSONToTable(serversConfig)

	-- Make sure we read the configurations successfully.
	if !globalConfig or !usergroupsConfig or !teamConfig or !serversConfig then
		error("Failed to read DanLib configuration.")
	end

	-- Cache the config.
	DanLib.Configuration.Config = globalConfig
	DanLib.Configuration.Usergroups = usergroupsConfig
	DanLib.Configuration.HiddenTeams = teamConfig.hiddenTeams
	DanLib.Configuration.OrderedTeams = teamConfig.orderedTeams
	DanLib.Configuration.Servers = serversConfig

	-- Return the data.
	return globalConfig, usergroupsConfig, teamConfig.hiddenTeams, teamConfig.orderedTeams, serversConfig

end

-- Create a function to send the config to the player.
function DanLib.UpdatePlayerConfig( rf )

	-- Check if we have a rf.
	if !rf then
		rf = RecipientFilter()
		rf:AddAllPlayers()
	end

	-- Start sending the message.
	net.Start("DanLib::SendConfiguration")
		net.WriteTable({
			Config = DanLib.Configuration.Config,
			Usergroups = DanLib.Configuration.Usergroups,
			Teams = {Hidden = DanLib.Configuration.HiddenTeams,Ordered = DanLib.Configuration.OrderedTeams},
			Servers = DanLib.Configuration.Servers
		})
	net.Send(rf)

end

--[[-------------------------------------------------------------------------
Read Config
---------------------------------------------------------------------------]]

-- Create a function to create the datafiles.
local function createDataFiles( )

	-- Create the directory.
	file.CreateDir("danlib")

	-- Generate a default configuration.
	local configData = {}

	-- Loop through DanLib.ConfigValues.Config.
	for k,v in pairs(DanLib.ConfigValues.Config) do

		-- Insert the data.
		configData[k] = v.Default

	end

	local superAdmin = {}

	for k,v in pairs(DanLib.ConfigValues.Usergroups) do

		-- Insert the data.
		superAdmin[k] = v.Default

	end

	-- Save the config.
	file.Write("danlib/config.txt", util.TableToJSON(configData))
	file.Write("danlib/usergroups.txt", util.TableToJSON({["superadmin"] = superAdmin}))
	file.Write("danlib/teams.txt", util.TableToJSON({["hiddenTeams"] = {},["orderedTeams"] = {}}))
	file.Write("danlib/servers.txt", util.TableToJSON({}))

end

-- Check if there is a danlib folder.
if !file.Exists("danlib","DATA") then

	createDataFiles()

end

-- Read and verify the configurations.
local changesMade, newGlobalConfig, newUsergroupsConfig, hiddenTeams, orderedTeams, serversConfig = DanLib.VerifyConfig( DanLib.ReadConfig(  ) )

-- Check if any changes were made to the configuration.
if changesMade then

	-- Save the new configuration.
	DanLib.SaveConfig(newGlobalConfig, newUsergroupsConfig, hiddenTeams, orderedTeams, serversConfig)

end

-- Cache the configuration.
DanLib.Configuration.Config = newGlobalConfig
DanLib.Configuration.Usergroups = newUsergroupsConfig
DanLib.Configuration.HiddenTeams = hiddenTeams
DanLib.Configuration.OrderedTeams = orderedTeams
DanLib.Configuration.Servers = serversConfig

--[[-------------------------------------------------------------------------
Configuration Networking
---------------------------------------------------------------------------]]

-- Pool netmsgs.
util.AddNetworkString("DanLib::RequestConfiguration")
util.AddNetworkString("DanLib::SendConfiguration")

-- Create a table for those who need their configuration.
local configurationQueue = {}

local configTimerActive = false

-- Add a receiver for DanLib::RequestConfiguration.
net.Receive("DanLib::RequestConfiguration",function( _, ply )

	-- Insert the player into configurationQueue
	configurationQueue[ply] = true

	if !configTimerActive then

		-- Set configTimerActive.
		configTimerActive = true

		-- Create a timer.
		timer.Simple(2, function(  )

			-- Set configTimerActive,
			configTimerActive = false

			-- Craete a RecipientFilter.
			local rf = RecipientFilter()

			-- Loop through configurationQueue.
			for k,v in pairs(configurationQueue) do

				-- Make sure the player is valid.
				if !IsValid(k) then continue end

				-- Add the player.
				rf:AddPlayer(k)

			end

			-- Send the configuration to everyone who requested it.
			DanLib.UpdatePlayerConfig( rf )

			-- Reset configurationQueue.
			configurationQueue = {}

		end)

	end

end)

--[[-------------------------------------------------------------------------
Configurator Manager
---------------------------------------------------------------------------]]

-- Pool network messages.
util.AddNetworkString("DanLib::SendConfig")
util.AddNetworkString("DanLib::ResetConfig")

net.Receive("DanLib::SendConfig", function( len, ply )

	-- Check if the player has an active network cooldown.
	if DanLib.HasCooldown(ply, "SendConfig", 3) then return end

	--Check so the player is the owner of the addon or has config access.
	if DanLib.Owner != ply:SteamID64() and !DanLib.GetUsergroupConfigValue( ply, "ConfigurationAccess" ) then return end

	-- Decompress the data.
	local data = net.ReadTable()

	-- Make sure we got all values.
	if !data.Config or !data.Usergroups or !data.Teams or !data.Teams.Hidden or !data.Teams.Ordered or !data.Servers then
		EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CHAT, "Failed to save configuration. (Missing Values)", ply )
		return
	end

	-- Verify the config.
	local _, newGeneralConfig, newUsergroupsConfig, newHiddenTeams, newOrderedTeams, newServers = DanLib.VerifyConfig( data.Config, data.Usergroups, data.Teams.Hidden, data.Teams.Ordered, data.Servers )

	-- Save the configuration.
	DanLib.SaveConfig( newGeneralConfig, newUsergroupsConfig, newHiddenTeams, newOrderedTeams, newServers )

	-- Read the new configuration.
	DanLib.ReadConfig()

	-- Update the player.
	EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CHAT, "Successfully saved the configuration.", ply )

	-- Create a recipentfilter.
	local rf = RecipientFilter()

	-- Get all players.
	rf:AddAllPlayers()

	-- Remove the current player.
	rf:RemovePlayer(ply)

	-- Tell everyone that the DanLib config was updated.
	EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CHAT, "Script has been reloaded due to a configuration change.", rf )

	-- Update all players.
	DanLib.UpdatePlayerConfig( )

	-- Call a hook that the config was updated.
	hook.Run("DanLib::ConfigUpdated")

end)

net.Receive("DanLib::ResetConfig", function( len, ply )

	-- Check if the player has an active network cooldown.
	if DanLib.HasCooldown(ply, "SendConfig", 3) then return end

	--Check so the player is the owner of the addon or has config access.
	if DanLib.Owner != ply:SteamID64() and !DanLib.GetUsergroupConfigValue( ply, "ConfigurationAccess" ) then return end

	-- Reset the config.
	createDataFiles( )

	-- Read the new configuration.
	DanLib.ReadConfig()

	-- Update the player.
	EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CHAT, "Successfully reset the configuration.", ply )

	-- Create a recipentfilter.
	local rf = RecipientFilter()

	-- Get all players.
	rf:AddAllPlayers()

	-- Remove the current player.
	rf:RemovePlayer(ply)

	-- Tell everyone that the edgescoreboard config was updated.
	EdgeScoreboard.Notify( EDGESCOREBOARD_NOTIFY_CHAT, "Script has been reloaded due to a configuration change.", rf )

	-- Update all players.
	DanLib.UpdatePlayerConfig( )

	-- Call a hook that the config was updated.
	hook.Run("DanLib::ConfigUpdated")

end)

--[[-------------------------------------------------------------------------
Chat Command
---------------------------------------------------------------------------]]

hook.Add("PlayerSay","DanLib::ConfigCommand",function( ply, text )

	if string.lower(text) == "!DanLib_Config" then
		ply:ConCommand("DanLib_Config")
	end

end)

*/