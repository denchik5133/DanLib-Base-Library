include('shared.lua')

-- Localize
local _IsValid = IsValid
local _LocalPlayer = LocalPlayer
local _CurTime = CurTime
local _FrameTime = FrameTime
local _mathApproach = math.Approach
local _mathNormalizeAngle = math.NormalizeAngle

local DIST_SQR = 250 * 250

--- Entity Initialisation.
function ENT:Initialize()
    self.Distance = 0
    self.NextThinkTime = 0
    self.CachedPlayer = nil
    
    -- Variables for smooth head rotation
    self.TargetYaw = 0
    self.CurrentYaw = 0
    
    -- Caching the config
    self.NPCConfig = nil
    self.LastNPCKey = ''
    self.AnimationSet = false
end

--- Updating the object's status.
function ENT:Think()
    local npcKey = self:GetNPCKeyVar() or ''
    
    -- We APPLY animation if the key has changed OR has not yet been applied.
    if (npcKey ~= '' and (npcKey ~= self.LastNPCKey or not self.AnimationSet)) then
        self.NPCConfig = DanLib.CONFIG.BASE.NPCs[npcKey]
        self.LastNPCKey = npcKey
        self.AnimationSet = false
        
        if (self.NPCConfig and self.NPCConfig.Animation) then
            local anim = self:LookupSequence(self.NPCConfig.Animation)
            if (anim and anim > 0) then
                self:ResetSequence(anim)
                self.AnimationSet = true
            end
        end
    end
    
    local curTime = _CurTime()
    -- We update the TARGET only 10 times per second
    if (curTime >= self.NextThinkTime) then
        self.NextThinkTime = curTime + 0.1
        
        -- Caching localPlayer()
        if (not _IsValid(self.CachedPlayer)) then
            self.CachedPlayer = _LocalPlayer()
        end
        local pPlayer = self.CachedPlayer
        
        -- Early return for long distances
        if pPlayer:GetPos():DistToSqr(self:GetPos()) > DIST_SQR then 
            self.TargetYaw = 0
            if (self.Distance ~= 0) then 
                self.Distance = 0 
            end
            return
        end 

        local pPos = pPlayer:EyePos()
        local ang = (pPos - self:EyePos()):Angle()
        local yaw = _mathNormalizeAngle(ang.y - self:GetAngles().y)
        
        -- Saving the TARGET angle
        self.TargetYaw = yaw
        self:SetEyeTarget(pPos)
    end
    
    -- SMOOTH interpolation (increased speed!)
    self.CurrentYaw = _mathApproach(self.CurrentYaw, self.TargetYaw, _FrameTime() * 120)
    self:SetPoseParameter('head_yaw', self.CurrentYaw)
end

--- Entity Drawing.
function ENT:Draw()
    self:DrawModel()
end

--- Resetting the cache when changing the NetworkVar
function ENT:OnNPCKeyVarChanged(varname, oldval, newval)
    self.AnimationSet = false
    self.LastNPCKey = ''
    self.NPCConfig = nil
end
