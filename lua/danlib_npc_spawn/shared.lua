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
    --- @type string
    -- @param NPCKeyVar (String): The NPC key used to identify the NPC in the configuration.
    self:NetworkVar('String', 0, 'NPCKeyVar') -- Int → String
end