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
local dHook = DanLib.Hook
local Table = DanLib.Table
local config = DanLib.Config
local network = DanLib.Network
local networkUtil = DanLib.NetworkUtil


--- Hook for handling player initial spawn event.
-- This function sends the complete configuration to the player when they first spawn.
-- @param pPlayer: The player who has just spawned.
local function load_player_config(pPlayer)
    base:SendCompleteConfig(pPlayer)
end
dHook:Add('PlayerInitialSpawn', 'DanLib.SendPlayerConfig', load_player_config)


--- Adds a network string for screen notifications.
networkUtil:AddString('DanLib:ScreenNotification')

--- Adds a network string for side popup notifications.
networkUtil:AddString('DanLib:SidePopupNotification')


--- Creates a popup notification for the specified player.
-- @param pPlayer: The player to whom the notification will be sent.
-- @param title: The title of the notification.
-- @param message: The message content of the notification.
-- @param msgType: The type of notification (e.g., 'WARNING', 'INFO').
-- @param time: Duration for which the notification will be displayed (in seconds).
function base:CreatePopupNotifi(pPlayer, title, message, msgType, time)
    network:Start('DanLib:ScreenNotification')
    network:WriteString(title or '')
    network:WriteString(message or '')
    network:WriteString(msgType or 'ERROR')
    network:WriteString(time or 5)
    network:SendToPlayer(pPlayer)
end


--- Creates a side popup notification for the specified player.
-- @param pPlayer: The player to whom the notification will be sent.
-- @param bool: A boolean indicating whether the message is a table or a string.
-- @param message: The message content (can be a string or table).
-- @param msgType: The type of notification (default is 'ERROR').
-- @param time: Duration for which the notification will be displayed (default is 5 seconds).
function base:SidePopupNotifi(pPlayer, message, msgType, time)
    network:Start('DanLib:SidePopupNotification')
    network:WriteString(message or '')
    network:WriteString(msgType or 'ERROR')
    network:WriteString(time or 5)
    network:SendToPlayer(pPlayer)
end


--- Sends a message to all players with the tag [Console].
-- @param ...: The message content to be sent to all players.
function base:SendConsoleMessage(...) 
    for _, v in pairs(player.GetAll()) do
        self:SendMessage(v, DANLIB_TYPE_DEBUG, config.Theme['Red'], '[Console] ', color_white, ...)
    end
end


--- Sends a message with a specific tag to a single player.
-- @param pPlayer: The player to whom the message will be sent.
-- @param tag: The tag to be displayed with the message.
-- @param ...: The message content to be sent to the player.
function base:SendGlobalMessage(tag, ...)
    for _, v in pairs(player.GetAll()) do
        self:SendMessage(v, DANLIB_TYPE_DEBUG, config.Theme['DarkOrange'], '[', config.Theme['White'], tag, config.Theme['DarkOrange'], '] ', config.Theme['White'], ...)
    end
end


--- Sends a message to a specific player.
-- @param pPlayer: The player to whom the message will be sent.
-- @param ....: The content of the message to be sent to the player.
function base:SendMessageTag(pPlayer, tag, ...)
    self:SendMessage(pPlayer, DANLIB_TYPE_DEBUG, config.Theme['DarkOrange'], '[', config.Theme['White'], tag, config.Theme['DarkOrange'], '] ', config.Theme['White'], ...)
end


--- Sends a debug message to a specific player.
-- @param pPlayer: The player to whom the debug message will be sent.
-- @param ...: The debug message content to be sent to the player.
function base:SendDebugMessage(pPlayer, ...)
    self:SendMessage(pPlayer, DANLIB_TYPE_DEBUG, config.Theme['Red'], '[Debug] ', config.Theme['White'], ...)
end


--- Sends a global notification to all players.
-- @param text: The text content of the notification to be sent to all players.
function base:SendGlobalNotifi(text)
    for _, v in pairs(player.GetAll()) do
        self:CreatePopupNotifi(v, 'SERVER', text, 'WARNING', 6)
    end
end


--- Sends a message to players within the specified distance.
-- @param pPlayer: The player from whom the message originates.
-- @param type: Message type.
-- @param distance: Maximum distance to send the message.
-- @param message: Additional arguments for the message.
function base:SendMessageDistance(pPlayer, type, distance, message) 
    if (not IsValid(pPlayer)) then return end

    local args = { message }
    if (distance == 0) then
        for _, v in pairs(player.GetAll()) do
            self:SendMessage(v, type, unpack(args))
        end
    else
        for _, v in ipairs(player.GetAll()) do
            if IsValid(v) and v:GetPos():Distance(pPlayer:GetPos()) <= distance then
                self:SendMessage(v, type, unpack(args))
            end
        end
    end
end


--- Sends a private message to a player with the title.
-- @param pPlayer: The player to whom the private message is sent.
-- @param title: The title of the message.
-- @param ...: Additional arguments for the message.
function base:SendPersonalMessage(pPlayer, title, ...)
    self:SendMessage(pPlayer, DANLIB_TYPE_DEBUG, base:Theme('decor'), '< ', DanLib.Config.Theme['White'], title, base:Theme('decor'), ' >  ', DanLib.Config.Theme['White'], ...)
end


--- Opens the menu for the player based on the assigned key.
-- @param pPlayer: The player for whom the menu will be opened.
local function OpenMenu(pPlayer, menuKey)
    if (DanLib.CONFIG.BASE.OpenMenu == menuKey) then
        network:Start('DanLib:BaseMenu')
        network:SendToPlayer(pPlayer)
    end
end


--- Hook for showing the help menu.
dHook:Add('ShowHelp', 'OpenMenu.ShowHelp', function(pPlayer) OpenMenu(pPlayer, 'F1') end)

--- Hook for showing the team menu.
dHook:Add('ShowTeam', 'OpenMenu.ShowTeam', function(pPlayer) OpenMenu(pPlayer, 'F2') end)

--- Hook for showing spare menu 1.
dHook:Add('ShowSpare1', 'OpenMenu.ShowSpare1', function(pPlayer) OpenMenu(pPlayer, 'F3') end)

--- Hook for showing spare menu 2.
dHook:Add('ShowSpare2', 'OpenMenu.ShowSpare2', function(pPlayer) OpenMenu(pPlayer, 'F4') end)


--- Parses the command input from the player.
-- @param pPlayer: The player who sent the command.
-- @param text: The command text sent by the player.
-- @return: An empty string if a command was successfully executed, otherwise returns nil.
local function HandlePlayerCommand(pPlayer, text)
    -- Define the command prefix
    local prefix = string.sub(text, 1, 1)

    -- Check if the text starts with the prefix '/' or '!'
    if (prefix == '/' or prefix == '!') then
        -- Remove the prefix from the command text
        text = string.sub(text, 2)

        -- Split the command text into arguments
        local args = string.Split(text, ' ')
        local cmd = args[1]      
        local text2 = Table:Concat(args, ' ', 2)

        -- Create a team
        local cmd2 = base.CreateCommand(cmd, true)
        if (cmd2 != nil) then
            -- Get SteamID and convert to SteamID64
            local steamID = pPlayer:SteamID()
            local steamID64 = pPlayer:SteamID64()
            local group = pPlayer:GetUserGroup()
            local rank = pPlayer:get_danlib_rank()

            local hasAccess = false
            if cmd2 and cmd2.access then
                if (type(cmd2.access) == 'table') then
                    hasAccess = Table:HasValue(cmd2.access, steamID64) or Table:HasValue(cmd2.access, steamID) or Table:HasValue(cmd2.access, group) or Table:HasValue(cmd2.access, rank)
                elseif (type(cmd2.access) == 'string') then
                    hasAccess = cmd2.access == steamID64 or cmd2.access == group
                end
            end

            -- If the player does not have access, but access is not defined, allow command execution
            if (not hasAccess and cmd2.access) then
                base:SendDebugMessage(pPlayer, base:L('#access.ver'))
                return ''
            end

            cmd2:OnRun(pPlayer, text2, args)
            return ''
        end
    end

    -- If no prefix is found, run the generic command hook
    dHook:ProtectedRun('DanLib:CommandRun.All', 'chat', pPlayer, text)
end 


--- Hook for processing player chat commands.
-- @param pPlayer: The player who sent the message.
-- @param text: The text sent by the player.
-- @return: The result of the command parsing.
dHook:Add('PlayerSay', 'DanLib:CommandsHook', function(pPlayer, text)
    return HandlePlayerCommand(pPlayer, text)  
end)
