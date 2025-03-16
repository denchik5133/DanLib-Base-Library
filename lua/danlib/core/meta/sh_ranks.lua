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
local Table = DanLib.Table
local metaPlayer = DanLib.MetaPlayer
local network = DanLib.Network


-- Get current rank for a player
function metaPlayer:get_danlib_rank()
    return self:GetNWString('DanLib.RankID', 'rank_member')
end


-- Function to get the player's rank name
function metaPlayer:get_danlib_rank_name()
    -- Get the player's rank identifier
    local rankID = self:get_danlib_rank()
    
    -- Getting rank data from the configuration
    local ranks = DanLib.ConfigMeta.BASE:GetValue('Ranks') or {}
    
    -- Check if this rank ID exists in the configuration
    if ranks[rankID] then
        return ranks[rankID].Name -- Return the rank name
    else
        return 'Member' -- Return the default "Member" if no rank is found
    end
end


-- Function to get the player's rank color
function metaPlayer:get_danlib_rank_color()
    -- Get the player's rank identifier
    local rankID = self:get_danlib_rank()
    
    -- Getting rank data from the configuration
    local ranks = DanLib.ConfigMeta.BASE:GetValue('Ranks') or {}
    
    -- Check if this rank ID exists in the configuration
    if ranks[rankID] then
        return ranks[rankID].Color or Color(0, 151, 230, 255) -- Return the rank color or default to white
    else
        return Color(0, 151, 230, 255) -- Return default color (white) if no rank is found
    end
end


--- Gets a list of permissions for the current player rank.
-- @return: Table with permissions for the player's rank.
function metaPlayer:get_danlib_rank_permissions()
    -- Get the player's rank identifier
    local rankID = self:get_danlib_rank()
    
    -- Getting rank data from the configuration
    local ranks = DanLib.ConfigMeta.BASE:GetValue('Ranks') or {}

    -- Check if the player has the rank 'rank_owner'
    if (rankID == 'rank_owner') then
        -- If it's the owner, return all permissions
        -- Return the special key to indicate that the owner has all permissions
        return { all_access = true }
    end
    
    -- Check if there is a rank
    if ranks[rankID] then
        local permissions = ranks[rankID].Permission or {}
        return permissions -- Return permissions for rank
    else
        return {} -- Return empty table if no rank is found
    end
end


--- Checks if a player has a specific permission based on their rank.
-- @param pPlayer: The player to check.
-- @param permission: The permission to check for.
-- @return: true if the player has permission, false otherwise.
function base.HasPermission(pPlayer, permission)
    -- Get player's rank identifier
    local rankID = pPlayer:get_danlib_rank()
    if (not rankID) then
        print('Rank identifier not found')
        return false
    end

    -- Check if the player is the owner
    if (rankID == 'rank_owner') then
        return true -- Owners have access to all permits at all times
    end

    -- Get rank data
    local ranks = DanLib.ConfigMeta.BASE:GetValue('Ranks') or {}
    local playerRank = ranks[rankID]

    -- Check if the rank exists and if it has permissions
    if (not playerRank) then
        print('Rank not found')
        return false
    end

    -- Check if the requested permission exists
    if (DanLib.BaseConfig.Permissions[permission] == nil) then
        print('Permission not found, access denied')
        return false
    end

    -- Check if the requested permission exists for the given rank
    local hasPermission = playerRank.Permission[permission] == true
    -- print('Checking the permission for the rank identifier:', rankID, ' Result: ', hasPermission)
    return hasPermission
end



--- Gets statistics on the ranks of players on the server.
-- @return: Table with the number of players at each rank.
--
--- Example of outputting statistics by ranks to the console
--    local statistics = base.GetRankStatistics()
--    for rankID, data in pairs(statistics) do
--        print('Rank: ' .. data.RankName .. ' - Players: ' .. data.Count)
--    end
function base.GetRankStatistics()
    local rankStats = {}
    local players = player.GetAll() -- Get all players on the server

    for _, player in ipairs(players) do
        local rankID = player:get_danlib_rank() -- Get player's rank
        if (not rankStats[rankID]) then
            rankStats[rankID] = { 
                Count = 0, 
                RankName = player:get_danlib_rank_name() 
            } -- Initialise if the rank has not been added yet
        end
        rankStats[rankID].Count = rankStats[rankID].Count + 1 -- Increase the player count for this rank
    end

    return rankStats -- Return table with statistics
end


if (CLIENT) then
    --- Command to set a player's rank from the client.
    -- @param pPlayer: The player executing the command.
    -- @param cmd: The command being executed.
    -- @param args: The arguments passed to the command.
    -- @param str: The command string.
    local function setrank(pPlayer, cmd, args, str)
        if (not base.HasPermission(pPlayer, 'EditRanks')) then
            base:ScreenNotification(base:L('#access.denied'), base:L('#access.ver'), 'ERROR', 6)
            return
        end

        if (#args < 2) then
            print('ERROR: Command syntax: danlib_setrank <player_name> <rank_id>')
            return
        end

        local target = base:FindPlayer(args[1])
        if (not target) then
            print('ERROR: Name not found! Command syntax: danlib_setrank <player_name> <rank_id>')
            return
        end

        local tbl = DanLib.ConfigMeta.BASE:GetValue('Ranks') or {}
        if (not tbl or not tbl[args[2]]) then
            print('ERROR: No ID rank found for "' .. args[2] .. '"!')
            return
        end

        -- Initiate network message to set rank
        network:Start('DanLib.NetSetRank')
        network:WriteEntity(target)
        network:WriteString(args[2])
        network:SendToServer()
    end


    --- Provides autocomplete suggestions for player names.
    -- @param command: Unused parameter.
    -- @param str: The input string for autocomplete.
    -- @return: A table of suggested completions.
    local function autocomplete(command, str)
        str = str:sub(2, -1) -- Remove the leading '/' from the command
        local tbl = {}

        -- Split the input into words to determine which argument is being completed
        local args = string.Split(str, " ")
        if (#args == 1) then
            -- Completing player names
            for _, v in pairs(player.GetHumans()) do
                Table:Add(tbl, v:Name() .. ' ') -- Use player name for completion
            end
        elseif (#args == 2) then
            -- Completing rank IDs
            local rankIdInput = args[2] -- Get the second argument (rank ID)
            local ranks = DanLib.ConfigMeta.BASE:GetValue('Ranks') or {}

            for id, _ in pairs(ranks) do
                if id:find(rankIdInput) then
                    Table:Add(tbl, id .. ' ') -- Add matching rank ID to suggestions
                end
            end
        end

        return tbl
    end

    -- Register the command with autocomplete
    concommand.Add('danlib_setrank', setrank, autocomplete)
end
