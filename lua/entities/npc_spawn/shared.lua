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



ENT.Base = 'base_ai' 
ENT.Type = 'ai'
 
ENT.PrintName = 'NPC spawning tool'
ENT.Category = '[DDI] NPC spaws'
ENT.Author = 'denchik'
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false


--- Setting up data tables for the network.
-- This function is used to define network variables,
-- which can be used to synchronise entity state between server and clients.
function ENT:SetupDataTables()
    --- @type number
    -- @param NPCKeyVar (Int): The NPC key used to identify the NPC in the configuration.
    self:NetworkVar('Int', 0, 'NPCKeyVar')
end