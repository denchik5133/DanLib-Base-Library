/***
 *   @addon         DanLib
 *   @component     NPCSpawnPersistence
 *   @version       1.0.0
 *   @release_date  29/11/2025
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *   
 *   @description   Persistent NPC spawn management system with support for:
 *                  - Automatic saving/loading of spawn points to data/danlib
 *                  - Asynchronous batch spawning (prevents lag with 100+ NPCs)
 *                  - Per-map spawn tracking and management
 *                  - Animation persistence after cleanup/respawn
 *                  - Console commands for spawn management
 *   
 *   @performance   - Batch spawning: 5 NPCs per 0.05s (prevents server freeze)
 *                  - Localized global functions for reduced lookup time
 *                  - Double animation application for reliable sync
 *                  - Asynchronous I/O operations
 *
 *   @compatibility DanLib 3.0.0+ | GMod 2024+
 *   @license       MIT License
 */



local DBase = DanLib.Func
local DTable = DanLib.Table
local DNetworkUtil = DanLib.NetworkUtil
local SPAWN_FILE = 'danlib/npc_spawns.json'

-- Localized global functions for performance
local _IsValid = IsValid
local _tostring = tostring
local _pairs = pairs
local _ipairs = ipairs
local _print = print
local _mathMin = math.min
local _ostime = os.time
local _format = string.format
local _GetMap = game.GetMap
local _Create = ents.Create
local _FindByClass = ents.FindByClass

-- CONFIGURATION CONSTANTS
local BATCH_SIZE = 5 -- NPCs spawned per batch
local BATCH_DELAY = 0.05 -- Delay between batches (seconds)
local SPAWN_DELAY = 0.5 -- Delay before spawning after cleanup
local ANIMATION_DELAY_1 = 0.5 -- First animation application delay
local ANIMATION_DELAY_2 = 1.0 -- Second animation application delay

--- Global table for storing NPC spawn data across map sessions
-- @type table<string, table>
DanLib.NPCSpawns = DanLib.NPCSpawns or {}

--- Loads NPC spawn data from persistent storage file.
-- Creates an empty spawn table if the file doesn't exist.
-- @return void
local function _loadSpawns()
    if (not file.Exists(SPAWN_FILE, 'DATA')) then
        DanLib.NPCSpawns = {}
        _print('[DanLib] No NPC spawn file found, starting fresh')
        return
    end
    
    local json = file.Read(SPAWN_FILE, 'DATA')
    if (not json or json == '') then
        _print('[DanLib] NPC spawn file is empty')
        DanLib.NPCSpawns = {}
        return
    end
    
    -- Safe JSON parsing with error handling
    local success, data = pcall(DNetworkUtil.JSONToTable, DNetworkUtil, json)
    if (success and data) then
        DanLib.NPCSpawns = data
        _print('[DanLib] Loaded ' .. DTable:Count(DanLib.NPCSpawns) .. ' NPC spawns')
    else
        _print('[DanLib] ERROR: Failed to parse NPC spawns JSON, resetting database')
        DanLib.NPCSpawns = {}
        
        -- Backup corrupted file
        local backupFile = 'danlib/npc_spawns_backup_' .. _ostime() .. '.json'
        file.Write(backupFile, json)
        _print('[DanLib] Corrupted file backed up to: ' .. backupFile)
    end
end


--- Saves current NPC spawn data to persistent storage file.
-- Creates the data directory if it doesn't exist.
-- @return void
local function _saveSpawns()
    if (not file.Exists('danlib', 'DATA')) then
        file.CreateDir('danlib')
    end
    
    local json = DNetworkUtil:TableToJSON(DanLib.NPCSpawns, true)
    file.Write(SPAWN_FILE, json)
    _print('[DanLib] Saved ' .. DTable:Count(DanLib.NPCSpawns) .. ' NPC spawns')
end

--- Adds a new NPC spawn point to the persistent database.
-- Generates a unique spawn ID and stores position, angle, NPC key, and map name.
-- @param ent (Entity): The NPC entity to save as a spawn point
-- @return string|nil spawnID - Unique identifier for the spawn, or nil if entity is invalid
-- @example
--      local spawnID = DBase:AddNPCSpawn(npcEntity)
function DBase:AddNPCSpawn(ent)
    if (not _IsValid(ent)) then
        return 
    end
    
    local spawnID = _tostring(ent:EntIndex()) .. '_' .. _ostime()
    
    DanLib.NPCSpawns[spawnID] = {
        pos = ent:GetPos(),
        ang = ent:GetAngles(),
        npcKey = ent:GetNPCKeyVar(),
        map = _GetMap()
    }
    
    -- Saving the ID in the entity for later deletion
    ent.SpawnID = spawnID
    
    _saveSpawns()
    return spawnID
end

--- Removes a spawn point from the persistent database by its ID.
-- @param spawnID (string): Unique identifier of the spawn to remove
-- @return boolean success - True if spawn was found and removed, false otherwise
-- @example
--      local removed = DBase:RemoveNPCSpawn('123_1764386175')
function DBase:RemoveNPCSpawn(spawnID)
    if DanLib.NPCSpawns[spawnID] then
        DanLib.NPCSpawns[spawnID] = nil
        _saveSpawns()
        return true
    end
    return false
end

--- Creates all saved NPC spawn points for the current map asynchronously.
-- Spawns NPCs in batches to prevent server lag on maps with many spawns.
-- @return void
-- @performance
--      Batch size: 5 NPCs per iteration
--      Delay between batches: 0.05 seconds
--      Prevents server freeze when spawning 100+ NPCs
local function _spawnAllNPCs()
    local currentMap = _GetMap()
    local toSpawn = {}
    
    -- Collect all spawns for current map with valid NPC configs
    for spawnID, data in _pairs(DanLib.NPCSpawns) do
        if (data.map == currentMap and DanLib.CONFIG.BASE.NPCs[data.npcKey]) then
            toSpawn[#toSpawn + 1] = {
                id = spawnID,
                data = data
            }
        end
    end
    
    local totalCount = #toSpawn
    local currentIndex = 1
    local batchSize = BATCH_SIZE
    
    -- Internal batch spawning function for asynchronous NPC
    local function spawnBatch()
        for i = currentIndex, _mathMin(currentIndex + batchSize - 1, totalCount) do
            local spawn = toSpawn[i]
            local npc = _Create('danlib_npc_spawn')
            npc:SetPos(spawn.data.pos)
            npc:SetAngles(spawn.data.ang)
            npc:Spawn()
            npc:SetNPCKey(spawn.data.npcKey)
            npc.SpawnID = spawn.id
        end
        
        currentIndex = currentIndex + batchSize
        
        if (currentIndex <= totalCount) then
            DBase:TimerSimple(0.05, spawnBatch)
        else
            _print('[DanLib] Spawned ' .. totalCount .. ' NPCs on map ' .. currentMap)
        end
    end
    
    if totalCount > 0 then
        spawnBatch()
    else
        _print('[DanLib] No NPCs to spawn on map ' .. currentMap)
    end
end

-- Load spawn data when server initializes
_loadSpawns()

--- Removes all NPC entities from the current map without deleting spawn data.
-- Only affects active entities, spawn points remain in database.
-- @return number count - Number of NPCs removed from the map
-- @example
--      local removed = DBase:RemoveAllNPCs()
--      print('Removed ' .. removed .. ' NPCs')
function DBase:RemoveAllNPCs()
    local count = 0
    for _, ent in _ipairs(_FindByClass('danlib_npc_spawn')) do
        if _IsValid(ent) then
            ent:Remove()
            count = count + 1
        end
    end
    return count
end

--- Respawns all NPCs by removing existing entities and creating them from spawn data.
-- Useful for applying configuration changes or fixing broken NPCs.
-- @return number removed - Number of old NPC entities that were removed
-- @example
--      DBase:RespawnAllNPCs()
function DBase:RespawnAllNPCs()
    local removed = self:RemoveAllNPCs()
    DBase:TimerSimple(0.1, function()
        _spawnAllNPCs()
    end)
    return removed
end

--- Updates models and animations of all existing NPCs without respawning.
-- Applies changes from configuration to already spawned entities.
-- @return number count - Number of NPCs that were successfully updated
-- @example
--      local updated = DBase:UpdateAllNPCs()
function DBase:UpdateAllNPCs()
    local count = 0
    for _, ent in _ipairs(_FindByClass('danlib_npc_spawn')) do
        if _IsValid(ent) then
            local npcKey = ent:GetNPCKeyVar()
            if DanLib.CONFIG.BASE.NPCs[npcKey] then
                local config = DanLib.CONFIG.BASE.NPCs[npcKey]
                ent:SetModel(config.Model or 'models/breen.mdl')
                
                local anim = ent:LookupSequence(config.Animation or 'idle_all_scared')
                if (anim > 0) then
                    ent:ResetSequence(anim)
                end
                count = count + 1
            end
        end
    end
    return count
end

-- Clears all spawn points for the current map from the database.
-- Also removes all active NPC entities. This action is irreversible.
-- @return number count - Number of spawn points that were deleted
-- @warning This permanently deletes spawn data from the save file!
-- @example
--      local cleared = DBase:ClearMapSpawns()
function DBase:ClearMapSpawns()
    local currentMap = _GetMap()
    local count = 0
    
    for spawnID, data in _pairs(DanLib.NPCSpawns) do
        if (data.map == currentMap) then
            DanLib.NPCSpawns[spawnID] = nil
            count = count + 1
        end
    end
    
    if (count > 0) then
        _saveSpawns()
        self:RemoveAllNPCs()
    end
    
    return count
end

--- Hook: Spawns all saved NPCs after server initialization.
-- @hook InitPostEntity
-- @delay 1 second after entity initialization
hook.Add('InitPostEntity', 'DanLib_SpawnNPCs', function()
    DBase:TimerSimple(1, _spawnAllNPCs)
end)

--- Applies animations to all NPC entities on the map.
-- Helper function to avoid code duplication.
-- @return number count - Number of NPCs that had animations applied
local function _applyAllAnimations()
    local count = 0
    for _, ent in _ipairs(_FindByClass('danlib_npc_spawn')) do
        if _IsValid(ent) then
            ent:ApplyAnimation()
            count = count + 1
        end
    end
    return count
end

hook.Add('PostCleanupMap', 'DanLib_RespawnNPCs', function()
    DBase:TimerSimple(SPAWN_DELAY, function()
        _spawnAllNPCs()
        
        DBase:TimerSimple(ANIMATION_DELAY_1, function()
            _applyAllAnimations()
            
            DBase:TimerSimple(ANIMATION_DELAY_2, _applyAllAnimations)
        end)
    end)
end)


-- CONSOLE COMMANDS

--- Console command: Respawns all NPCs on the current map.
-- Removes old entities and creates new ones from spawn data.
-- @permission SpawnNPC
-- @param pPlayer (Player): The player executing the command (nil if from server console)
-- @param cmd (string): Command name
-- @param args (table): Command arguments (unused)
-- @usage danlib_npc_respawn
concommand.Add('danlib_npc_respawn', function(pPlayer, cmd, args)
    if (_IsValid(pPlayer) and not DBase.HasPermission(pPlayer, 'SpawnNPC')) then
        DBase:SidePopupNotifi(pPlayer, 'No permission', 'ERROR', 3)
        return
    end
    
    local removed = DBase:RespawnAllNPCs()
    local msg = _format('Respawned all NPCs (removed %s old entities)', removed)
    
    if _IsValid(pPlayer) then
        DBase:SidePopupNotifi(pPlayer, msg, 'ADMIN', 5)
    else
        _print('[DanLib] ' .. msg)
    end
end)

--- Console command: Updates models and animations of all NPCs without respawning.
-- Applies configuration changes to existing entities.
-- @permission SpawnNPC
-- @param pPlayer (Player): The player executing the command (nil if from server console)
-- @param cmd (string): Command name
-- @param args (table): Command arguments (unused)
-- @usage danlib_npc_update
concommand.Add('danlib_npc_update', function(pPlayer, cmd, args)
    if (_IsValid(pPlayer) and not DBase.HasPermission(pPlayer, 'SpawnNPC')) then
        DBase:SidePopupNotifi(pPlayer, 'No permission', 'ERROR', 3)
        return
    end
    
    local count = DBase:UpdateAllNPCs()
    local msg = 'Updated ' .. count .. ' NPCs'
    
    if _IsValid(pPlayer) then
        DBase:SidePopupNotifi(pPlayer, msg, 'CONFIRM', 3)
    else
        _print('[DanLib] ' .. msg)
    end
end)

--- Console command: Removes all NPC entities from the map.
-- Does NOT delete spawn data - NPCs will respawn on map restart.
-- @permission SpawnNPC
-- @param pPlayer (Player): The player executing the command (nil if from server console)
-- @param cmd (string): Command name
-- @param args (table): Command arguments (unused)
-- @usage danlib_npc_remove_all
concommand.Add('danlib_npc_remove_all', function(pPlayer, cmd, args)
    if (_IsValid(pPlayer) and not DBase.HasPermission(pPlayer, 'SpawnNPC')) then
        DBase:SidePopupNotifi(pPlayer, 'No permission', 'ERROR', 3)
        return
    end
    
    local count = DBase:RemoveAllNPCs()
    local msg = _format('Removed %s NPCs from map', count)
    
    if _IsValid(pPlayer) then
        DBase:SidePopupNotifi(pPlayer, msg, 'WARNING', 4)
    else
        _print('[DanLib] ' .. msg)
    end
end)

--- Console command: Permanently clears all spawn data for the current map.
-- Removes both active NPCs and their spawn points from the database.
-- @permission SpawnNPC
-- @param pPlayer (Player): The player executing the command (nil if from server console)
-- @param cmd (string): Command name
-- @param args (table): Command arguments (unused)
-- @warning This permanently deletes spawn data and cannot be undone!
-- @usage danlib_npc_clear_map
concommand.Add('danlib_npc_clear_map', function(pPlayer, cmd, args)
    if (_IsValid(pPlayer) and not DBase.HasPermission(pPlayer, 'SpawnNPC')) then
        DBase:SidePopupNotifi(pPlayer, 'No permission', 'ERROR', 3)
        return
    end
    
    local count = DBase:ClearMapSpawns()
    local msg = _format('Cleared %s spawns for %s', count, _GetMap())
    
    if _IsValid(pPlayer) then
        DBase:SidePopupNotifi(pPlayer, msg, 'ERROR', 5)
    else
        _print('[DanLib] ' .. msg)
    end
end)

--- Console command: Displays statistics about NPC spawns.
-- Shows total spawns, spawns for current map, and active entities.
-- @permission (SpawnNPC)
-- @param pPlayer (Player): The player executing the command (nil if from server console)
-- @param cmd (string): Command name
-- @param args (table): Command arguments (unused)
-- @usage danlib_npc_stats
-- @output NPC Stats | Map: gm_construct | Saved: 5/12 | Active: 5
concommand.Add('danlib_npc_stats', function(pPlayer, cmd, args)
    if (_IsValid(pPlayer) and not DBase.HasPermission(pPlayer, 'SpawnNPC')) then
        return
    end
    
    local currentMap = _GetMap()
    local totalSpawns = DTable:Count(DanLib.NPCSpawns)
    local mapSpawns = 0
    local activeNPCs = #_FindByClass('danlib_npc_spawn')
    
    for _, data in _pairs(DanLib.NPCSpawns) do
        if (data.map == currentMap) then
            mapSpawns = mapSpawns + 1
        end
    end
    
    local msg = _format('NPC Stats | Map: %s | Saved: %d/%d | Active: %d',currentMap, mapSpawns, totalSpawns, activeNPCs)

    if _IsValid(pPlayer) then
        DBase:SidePopupNotifi(pPlayer, msg, 'ADMIN', 6)
    else
        _print('[DanLib] ' .. msg)
    end
end)