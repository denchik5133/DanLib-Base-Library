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



local tag = 'DanLib'
local base = DanLib.Func
local Table = DanLib.Table
local network = DanLib.Network


--- Formats message arguments with support for colour tags.
-- This function accepts an arbitrary number of arguments, including strings, colour objects and tables,
-- and returns a formatted list of arguments.
-- It handles special colour tags in the format "{color:r,g,b,a}",
-- where r, g, b and a are colour values (from 0 to 255).
-- If no colour tags are specified in the string, the text is added with the default colour (white).
-- If the closing tag "{/color:}" is found, the colour is reset to the default colour.
--
-- @param ...: Arbitrary number of message arguments, which can be strings,
-- colour objects, or tables.
-- @return: A table containing the formatted arguments, including text and colour objects.
--
-- @todo: Add processing of other tags. Enhance the current tag with spaces and use without a.
local function gormatMessageArgs(...)
    local formattedArgs = {}
    local colorPattern = '{color:(%d+),(%d+),(%d+),(%d+)}'
    local defaultColor = Color(255, 255, 255, 255) -- Default colour
    local currentColor = defaultColor -- Initial colour

    for _, message in ipairs({...}) do
        if type(message) == 'string' then
            local startPos = 1

            while true do
                local startTag, endTag, r, g, b, a = string.find(message, colorPattern, startPos)
                local closeTagPos = string.find(message, '{/color:}', startPos)

                -- If there are no tags, exit the loop
                if (not startTag and not closeTagPos) then
                    break
                end

                -- If a closing tag is found, add text before it and reset the colour
                if closeTagPos and (not startTag or closeTagPos < startTag) then
                    if closeTagPos > startPos then
                        Table:Add(formattedArgs, string.sub(message, startPos, closeTagPos - 1))
                    end
                    currentColor = defaultColor -- Reset colour to default colour
                    Table:Add(formattedArgs, currentColor) -- Add default colour
                    startPos = closeTagPos + #'{/color:}'
                else
                    -- Add text before the opening tag
                    if (startTag > startPos) then
                        Table:Add(formattedArgs, string.sub(message, startPos, startTag - 1))
                    end

                    -- Add coloured text
                    currentColor = Color(tonumber(r), tonumber(g), tonumber(b), tonumber(a or 255))
                    Table:Add(formattedArgs, currentColor)

                    -- Update the position for the next search
                    startPos = endTag + 1
                end
            end

            -- Add the rest of the string after the last tag
            if (startPos <= #message) then
                Table:Add(formattedArgs, string.sub(message, startPos))
            end

        elseif (type(message) == 'userdata' and message:IsColor()) then
            -- If it is a colour object, just add it
            currentColor = message
            Table:Add(formattedArgs, currentColor)

        elseif (type(message) == 'table') then
            -- If it's a table, add it as it is
            Table:Add(formattedArgs, message)

        else
            base:PrintError('A string, colours or table is expected, received: ' .. type(message))
        end
    end

    return formattedArgs
end


--- Sends a message to a player or group of players.
-- @param pPlayer: The player to whom the message is sent (or nil for all players).
-- @param msgType: Message Type.
-- @param message: Additional arguments for the message.
function base:SendMessage(pPlayer, msgType, ...)
    local args = gormatMessageArgs(...) -- Formatting arguments

    -- Sending a message
    if SERVER then
        network:Start(tag .. ':Message')
        network:WriteInt(msgType, 8)
        network:WriteTable(args)
        network:SendToPlayer(pPlayer)
    elseif CLIENT then
        network:Start(tag .. ':Message')
        network:WriteEntity(pPlayer)
        network:WriteInt(msgType, 8)
        network:WriteTable(args)
        network:SendToServer()
    end
end  


--- Gets the name of a key by its code.
-- @param key: Key code.
-- @return: Key name or 'UNKNOWN KEY' if the code is not recognised.
function base:GetKeyName(key)
    if (not isnumber(key)) then return 'UNKNOWN KEY' end

    if (key >= MOUSE_MIDDLE) then
        return ({
            [MOUSE_MIDDLE] = 'MIDDLE MOUSE',
            [MOUSE_4] = 'MOUSE 4',
            [MOUSE_5] = 'MOUSE 5',
            [MOUSE_WHEEL_UP] = 'MOUSE WHEEL UP',
            [MOUSE_WHEEL_DOWN] = 'MOUSE WHEEL DOWN'
        })[key] or 'UNKNOWN MOUSE'
    else
        return input.GetKeyName(key) and input.GetKeyName(key):upper() or 'UNKNOWN KEY'
    end
end


--- Gets the player's admin group.
-- @param pPlayer: The player to get the group for.
-- @return: The name of the admin group or an empty string.
function base:GetAdminGroup(pPlayer)
    if (serverguard) then
        return serverguard.player:GetRank(pPlayer)
    else
        return pPlayer:GetNWString('usergroup', '')
    end

    return ''
end


--- Checks if the player has administrator access.
-- @param pPlayer: The player for whom you want to check access.
-- @return: true if the player is a super administrator, otherwise nil.
function base:HasAdminAccess(pPlayer)
    return IsValid(pPlayer) and pPlayer:IsSuperAdmin() or false
end


--- Edits the NPC for the player.
-- @param pPlayer: The player who is editing the NPC.
-- @param args: Arguments to edit the NPC.
function base:NPCsEditor(pPlayer, args)
    if SERVER then
        network:Start(tag .. '.Tool.SpawnNPCs')
        network:WriteTable(args)
        network:SendToPlayer(pPlayer)
    elseif CLIENT then
        network:Start(tag .. '.Tool.SpawnNPCs')
        network:WriteTable(args)
        network:WriteEntity(pPlayer)
        network:SendToServer()
    end
end