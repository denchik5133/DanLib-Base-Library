--[[
Only allowed to use in Addons by
​Mattis 'Mattzimann' Krämer
]]--

AddCSLuaFile()

AnimationSWEP = {}

if CLIENT then
    AnimationSWEP.GestureAngles = {}
    AnimationSWEP.GestureAngles["surrunder"] = {
        ["ValveBiped.Bip01_L_Forearm"] = Angle(25,-65,25),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-25,-65,-25),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-70,-180,70),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(70,-180,-70),
    }

    AnimationSWEP.GestureAngles["arms_infront"] = {
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-43.779933929443,-107.18412780762,15.918969154358),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(20.256689071655, -57.223915100098, -6.1269416809082),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-28.913911819458, -59.408206939697, 1.0253102779388),
        ["ValveBiped.Bip01_R_Thigh"] = Angle(4.7250719070435, -6.0294013023376, -0.46876749396324),
        ["ValveBiped.Bip01_L_Thigh"] = Angle(-7.6583762168884, -0.21996378898621, 0.4060270190239),
        ["ValveBiped.Bip01_L_Forearm"] = Angle(51.038677215576, -120.44165039063, -18.86986541748),
        ["ValveBiped.Bip01_R_Hand"] = Angle(14.424224853516, -33.406204223633, -7.2624106407166),
        ["ValveBiped.Bip01_L_Hand"] = Angle(25.959447860718, 31.564517974854, -14.979378700256),
    }

    AnimationSWEP.GestureAngles["arms_back"] = {
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(3.809, 15.382, 2.654),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-63.658, 1.8 , -84.928),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(3.809, 15.382, 2.654),
        ["ValveBiped.Bip01_L_Forearm"] = Angle(53.658, -29.718, 31.455),
        ["ValveBiped.Bip01_R_Thigh"] = Angle(4.829, 0, 0),
        ["ValveBiped.Bip01_L_Thigh"] = Angle(-8.89, 0, 0),
    }

    

    local function applyAnimation(ply, targetValue, class)
        if not IsValid(ply) then return end
        if ply.animationSWEPAngle ~= targetValue then
            ply.animationSWEPAngle = Lerp(FrameTime() * 5, ply.animationSWEPAngle, targetValue)
        end

        local oldanimationclass = ply:GetNWString("oldanimationClass")
        if oldanimationclass ~= class and AnimationSWEP.GestureAngles[oldanimationclass] then
        	for boneName, angle in pairs(AnimationSWEP.GestureAngles[oldanimationclass]) do
            local bone = ply:LookupBone(boneName)

            if bone then
                ply:ManipulateBoneAngles( bone, angle * 0)
            end
       		end
        end

       	ply:SetNWString("oldanimationClass",class)

       if AnimationSWEP.GestureAngles[class] then
        for boneName, angle in pairs(AnimationSWEP.GestureAngles[class]) do
            local bone = ply:LookupBone(boneName)

            if bone then
                ply:ManipulateBoneAngles( bone, angle * ply.animationSWEPAngle)
            end
        end
   		end

        if math.Round(ply.animationSWEPAngle, 2) == targetValue and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "keys" then
            ply:SetNWString("animationClass", "")
        end
    end

    hook.Add("Think", "AnimationSWEP.Think", function ()
       	for _, ply in pairs( player.GetHumans() ) do
            local animationClass = ply:GetNWString("animationClass")

            if animationClass ~= "" then
                if not ply.animationSWEPAngle then
                    ply.animationSWEPAngle = 0
                end

                if ply:GetNWBool("animationStatus") then
                    applyAnimation(ply, 1, animationClass)
                else
                    applyAnimation(ply, 0, animationClass)
                end
            end

    		
    	end
	end)
else

	local function VelocityIsHigher(ply, value)
		local x, y, z = math.abs(ply:GetVelocity().x), math.abs(ply:GetVelocity().y), math.abs(ply:GetVelocity().z)
		if x > value or y > value or z > value then
			return true
		else
			return false
		end
	end

    hook.Add("SetupMove", "AnimationSWEP.SetupMove", function(ply, moveData, cmd)
        if ply:GetNWBool("animationStatus") then
        	local deactivateOnMove = ply:GetNWInt("deactivateOnMove", 5)
        	
	            if VelocityIsHigher(ply, deactivateOnMove) then
	                AnimationSWEP:Toggle(ply, false)
	            end

	            if ply:KeyDown(IN_DUCK) then
	                AnimationSWEP:Toggle(ply, false)
	            end

	            if ply:KeyDown(IN_USE) then
	                AnimationSWEP:Toggle(ply, false)
	            end

	            if ply:KeyDown(IN_JUMP) then
	                AnimationSWEP:Toggle(ply, false)
	            end
        end
    end)

    function AnimationSWEP:Toggle(ply, crossing, class, deactivateOnMove)
        if crossing then
            ply:SetNWBool("animationStatus", true)
            
            if class then
                ply:SetNWString("animationClass", class)
            end
            
            ply:SetNWInt("deactivateOnMove", deactivateOnMove)
        else
            ply:SetNWBool("animationStatus", false)
            ply:SetNWInt("deactivateOnMove", 5)
        end
    end

    concommand.Add("anim", function(ply, cmd, args, sargs)
        if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() != "keys" then ply:ChatPrint("НАХУЙ ПОСЛАН БЛЯТЬ") return end

        if not ply:GetNWBool("animationStatus") then
            if not ply:Crouching() and ply:GetVelocity():Length() < 5 and not ply:InVehicle() then
                AnimationSWEP:Toggle(ply, true, args[1], 120)
            end
        else
            AnimationSWEP:Toggle(ply, false)
        end
    end)
end

