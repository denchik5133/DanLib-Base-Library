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
local networkUtil = DanLib.NetworkUtil
local network = DanLib.Network
local dHook = DanLib.Hook


-- Register network strings for rank management
networkUtil:AddString(tag .. '.OpenTestRank')
networkUtil:AddString(tag .. '.NetSetRank')
networkUtil:AddString(tag .. '.NetRequestChangeRank')
networkUtil:AddString(tag .. '.NotifyNoOwner')
networkUtil:AddString(tag .. '.SendRankData')
networkUtil:AddString(tag .. '.RequestRankData')
networkUtil:AddString(tag .. '.SetupOwner')


--- Initializes player rank data from a file.
-- @return: The player's rank data.
function DanLib.MetaPlayer:InitPlayerRank()
    local path = 'danlib/rank/' .. self:SteamID64() .. '.txt'
    if (not file.Exists(path, 'DATA')) then 
        file.Write(path, '[]') 
    end

    local data = networkUtil:JSONToTable(file.Read(path) or '[]')
    return data
end


--- Initializes the server owner from a file and sends it to the player.
-- @param pPlayer: The player requesting the owner ID.
function base.InitOwnerServer()
    local filePath = 'danlib/owner.txt'
    local file = file.Read(filePath, 'DATA')

    if (not file) then
        base:PrintType('Logs', 'The file is not found or cannot be read.')
        return ''
    end

    local ownerID = string.Trim(file)
    if (ownerID == '') then
        -- base:PrintType('Logs', 'File is empty after trimming.')
    end

    return ownerID
end


--- Checks if the player has owner access.
-- @return: true if the player has access, false otherwise.
local function checkOwnerAccess(pPlayer)
    -- Player validity check
    if (not IsValid(pPlayer)) then 
        print('Invalid player, access is denied.')
        return false 
    end

    local owner = base.InitOwnerServer()

    -- If owner value is empty, return false
    if (owner == nil or owner == '') then 
        print('Owner is null or empty, access is denied.')
        return false 
    end

    -- Remove extra spaces
    owner = string.Trim(owner)
    local playerSteamID = string.Trim(pPlayer:SteamID())

    -- Comparing the owner's SteamID with the player's SteamID
    -- print('Comparing the owner: "' .. owner .. '" with the player: "' .. playerSteamID .. '"') -- To debug
    return owner == playerSteamID
end


-- Saves player rank data to a file.
-- @param pPlayer: The player whose data is being saved.
-- @param tData: The data to save.
local function savePlayer(pPlayer, tData)
    local path = 'danlib/rank/' .. pPlayer:SteamID64() .. '.txt'
    local data = networkUtil:TableToJSON(tData, true)
    file.Write(path, data)
end


--- Checks if the player is an owner, and assigns the rank 'rank_owner' if so.
-- @param pPlayer: The player to be checked.
function base.AssignOwnerRank(pPlayer)
    -- NULL check
    if (not IsValid(pPlayer)) then
        return false
    end

    local ownerID = base.InitOwnerServer() -- Get the owner ID

    -- If the owner ID is empty, return false
    if (not ownerID or ownerID == '') then
        print('Owner ID is null or empty, access is denied.')
        return false
    end

    -- Compare SteamID of the owner with SteamID of the player
    if (string.Trim(ownerID) == string.Trim(pPlayer:SteamID())) then
        -- Assign rank to 'rank_owner'
        local data = pPlayer:InitPlayerRank()
        data.Rank = 'rank_owner'
        pPlayer:SetNWString(tag .. '.RankID', 'rank_owner')
        savePlayer(pPlayer, data)  -- Save player data
        print(pPlayer:Name() .. ' has been assigned the rank of owner.')
        return true
    end

    return false
end


--- Gets a list of all rank files in the directory and their contents.
-- @return: Table with user names and their data.
local function request_rank_data(len, pPlayer)
    local path = 'danlib/rank/*' -- Path to the directory with files
    local files, _ = file.Find(path, 'DATA') -- Get the list of files
    
    local userRankData = {} -- Table for storing user data

    for _, fileName in ipairs(files) do
        local steamID64 = fileName:match('^(%d+)%..*') -- Extract SteamID64 from the file name
        if steamID64 then
            local data = file.Read('danlib/rank/' .. fileName, 'DATA') -- Read file contents
            userRankData[steamID64] = networkUtil:JSONToTable(data) -- Convert JSON to table
        end
    end

    network:Start(tag .. '.SendRankData')
    network:WriteTable(userRankData) -- Send the data back to the client
    network:SendToPlayer(pPlayer) -- Send only to the player who requested it
end
network:Receive(tag .. '.RequestRankData', request_rank_data)


--- Initializes the rank data directory if it doesn't exist.
-- Returns true if successful.
function base.RankData()
    local path = 'danlib/rank/'
    if (not file.Exists(path, 'DATA')) then 
        file.CreateDir(path) 
    end
    return true
end
base.RankData()


--- Handles rank change requests from players.
-- @param sender: The player who requested the change.
local function RequestChange(_, sender)
    local target = network:ReadEntity()
    local rank = network:ReadString()

    if (not sender:IsValid() or not target:IsValid()) then return  end
    if (not base.HasPermission(sender, 'EditRanks')) then
        base:CreatePopupNotifi(sender, base:L('#access.denied'), base:L('#access.ver'), 'ERROR', 6)
        return
    end

    -- Initiate network message to set rank
    network:Start(tag .. '.NetSetRank')
    network:WriteEntity(target)
    network:WriteString(rank)
    network:SendToPlayer(sender)
end
network:Receive(tag .. '.NetRequestChangeRank', RequestChange)


--- Initializes player rank on spawn.
-- @param pPlayer: The player being initialized.
local function InitSpawn(pPlayer)
    base:TimerSimple(5, function()
        -- Verify and assign the owner's rank, if necessary
        -- If the owner's rank is assigned, exit
        if base.AssignOwnerRank(pPlayer) then return end

        local data = pPlayer:InitPlayerRank()
        if (data and data.Rank) then
            pPlayer:SetNWString(tag .. '.RankID', data.Rank)
        end
    end)
end
dHook:Add('PlayerInitialSpawn', 'InitSpawn', InitSpawn)


--- Sets a player's rank.
-- @param _: Unused parameter.
-- @param actor: The player who is setting the rank.
local function set_rank(_, actor)
    local pPlayer = network:ReadEntity()
    local rank = network:ReadString()

    if (not IsValid(pPlayer)) then
        base:SendMessageTag(actor, tag, 'The player is not in the database or he is not on the server!')
        return
    end

    local orange = Color(255, 165, 0)
    local blue = Color(0, 151, 230)
    local yellow = Color(255, 215, 0)
    local white = color_white

    if (not base.RankData()) then
        base.RankData()
    end

    -- Check if the player is the owner
    if (not checkOwnerAccess(pPlayer)) then
        base:SendMessageTag(actor, tag, 'You cannot change the rank of player ', orange, pPlayer:Name(), white, ' as he is determined by the server ', blue, 'Owner', white, '!')
        return
    end

    local data = pPlayer:InitPlayerRank()
    local old_rank = pPlayer:get_danlib_rank()

    if data then
        -- Checking for rank changes
        if (old_rank == rank) then
            base:SendMessageTag(actor, tag, white, 'The rank of player ', yellow, pPlayer:Name(), white, ' is already ', blue, rank, white, '. No changes made.')
            return
        end

        -- Setting a new rank
        data.Rank = rank
        pPlayer:SetNWString(tag .. '.RankID', rank)
        savePlayer(pPlayer, data)

        base:PrintType('Logs', 'You have changed the rank for ', blue, pPlayer:Name(), white, '. His new rank is ', blue, rank, white, '.')
        base:SendMessageTag(actor, tag, orange, 'You ', white, 'changed a player ', yellow, pPlayer:Name(), white, ' rank ', blue, old_rank, white, ' ➞ ', blue, rank, white, '.')
        base:SendMessageTag(pPlayer, tag, base:L('#rank.changed'), blue, old_rank, white, ' ➞ ', blue, rank, white, '! Gave out: ', orange, actor:Name(), white, '.')
        dHook:ProtectedRun(tag .. '.Rank.Changed', pPlayer, old_rank, rank, actor)
    end
end
network:Receive(tag .. '.NetSetRank', set_rank)


--- Saves the server owner ID to a file.
-- @param data: The data to save.
local function save_owner_file(data)
    local path = 'danlib/owner.txt'
    if (not file.Write(path, data)) then
        base:PrintError('Failed to write owner data to file.')
    end
end


--- Removes the owner file from the server.
-- @param pPlayer: The player attempting to execute the command.
local function remove_owner_file(pPlayer)
    if IsValid(pPlayer) then
        base:SendMessageTag(pPlayer, tag, 'This command can be executed only by server ', Color(0, 151, 230), 'console', color_white, '!')
        return
    end

    local path = 'danlib/owner.txt'
    if file.Exists(path, 'DATA') then
        file.Write(path, '') -- Clear the file
        base:PrintType('Logs', "The owner's file has been deleted.")
    end
end
concommand.Add('danlib_remove_owner', remove_owner_file)


--- Sets up the server owner.
-- @param pPlayer: The player attempting to set up the owner.
local function setup_owner(_, pPlayer)
    if (not base.RankData()) then base.RankData() end
    local owner = base.InitOwnerServer()
    local data = pPlayer:InitPlayerRank()
    local old_rank = pPlayer:get_danlib_rank()

    if owner then
        owner = pPlayer:SteamID()
        save_owner_file(owner)

        data.Rank = 'rank_owner'
        pPlayer:SetNWString(tag .. '.RankID', 'rank_owner')
        savePlayer(pPlayer, data)

        base:PrintType('Logs', 'User ', pPlayer:Name(), ' has been determined to be the Owner of the server.')
        base:SendMessageTag(pPlayer, tag, 'User ', Color(255, 165, 0), pPlayer:Name(), color_white, ' has been determined to be the ', Color(0, 151, 230), 'Owner', color_white, ' of the server.')
    end
end
network:Receive(tag .. '.SetupOwner', setup_owner)


-- Checking the availability of the owner and sending a notification to the client
local function check_owner_and_notify(pPlayer)
    local owner = base.InitOwnerServer(pPlayer)
    local notificationType = owner == '' and 'no_owner' or 'owner_set'

    network:Start(tag .. '.NotifyNoOwner')
    network:WriteString(notificationType)
    network:SendToPlayer(pPlayer)
end

-- Timer for periodic check of the owner
local function periodic_owner_check(pPlayer)
    local timerName = 'CheckOwnerTimer_' .. pPlayer:EntIndex() -- Use EntIndex as a unique identifier
    timer.Create(timerName, 5, 0, function() -- Check every 5 seconds
        if IsValid(pPlayer) then
            check_owner_and_notify(pPlayer) -- Check the owner for the current player
        else
            timer.Remove(timerName) -- Deleting the timer if the player has switched off
        end
    end)
end

-- Calling a check when a player connects
dHook:Add('PlayerInitialSpawn', 'CheckOwnerOnSpawn', function(pPlayer)
    check_owner_and_notify(pPlayer) -- Initial check
    periodic_owner_check(pPlayer) -- Start periodic check
end)

