AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

--- Entity Initialisation.
function ENT:Initialize()
	self:SetModel('models/breen.mdl')
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	
	-- Animation cache on the server
	self.CachedAnimation = nil
	self.LastAppliedSequence = -1
end

--- NPC Key Installation.
function ENT:SetNPCKey(key)
    self:SetNPCKeyVar(key)
    
    local config = DanLib.CONFIG.BASE.NPCs[key]
    if config then
        -- Installing the model
        if config.Model then
            self:SetModel(config.Model)
        end
        
        -- CACHING the animation name
        self.CachedAnimation = config.Animation
        
        -- We apply it immediately
        timer.Simple(0.05, function()
            if IsValid(self) then
                self:ApplyAnimation()
            end
        end)
    else
        self:SetModel('models/breen.mdl')
        self.CachedAnimation = nil
    end
end

--- Animation application function
function ENT:ApplyAnimation()
    if (not self.CachedAnimation) then
        local npcKey = self:GetNPCKeyVar()
        if (npcKey and npcKey ~= '') then
            local config = DanLib.CONFIG.BASE.NPCs[npcKey]
            if config then
                self.CachedAnimation = config.Animation
            end
        end
    end
    
    if self.CachedAnimation then
        local anim = self:LookupSequence(self.CachedAnimation)
        if (anim and anim > 0) then
            self:ResetSequence(anim)
            self.LastAppliedSequence = anim
        end
    end
end

--- Redefining Think() on the server
function ENT:Think()
    -- Forcibly holding animation
    if (self.LastAppliedSequence and self.LastAppliedSequence > 0) then
        local currentSeq = self:GetSequence()
        if (currentSeq ~= self.LastAppliedSequence) then
            self:ResetSequence(self.LastAppliedSequence)
        end
    end
    
    self:NextThink(CurTime() + 0.5) -- We check every 0.5 seconds
    return true
end

--- Handling incoming interaction.
function ENT:AcceptInput(ply, caller)
	if (caller.timer or 0) > CurTime() then
		return
	end
	caller.timer = CurTime() + 1

	if (not self:GetNPCKeyVar() or not DanLib.CONFIG.BASE.NPCs[self:GetNPCKeyVar()]) then
		return
	end

	local config = DanLib.CONFIG.BASE.NPCs[self:GetNPCKeyVar()]
	local typeTable = DanLib.BaseConfig.EntityTypesFunc[config.FuncType or '']

	if (typeTable and typeTable.UseFunc) then
		typeTable.UseFunc(caller, self, self:GetNPCKeyVar())
	end
end

--- Damage Receipt Handling.
function ENT:OnTakeDamage(dmgInfo)
	return 0
end