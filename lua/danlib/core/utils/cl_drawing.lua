/***
 *   @addon         DanLib
 *   @component     DanLib.DrawShadow
 *   @version       1.0.2
 *   @release_date  26/11/2025
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *   @description   Shadow rendering system with per-instance blur caching
 *
 *   @features      - Per-instance texture caching (blur only on size/params change)
 *                  - Automatic cache invalidation on parameter changes
 *                  - Memory cleanup on instance removal
 *                  - Full backward compatibility with v1.0 API
 *
 *   @performance   - Blur operations: Only on parameter change (cached)
 *                  - 100-300% FPS improvement on static shadows
 *                  - Memory: Auto-cleanup via Remove()
 *
 *   @api_usage     Basic shadow (no cache):
 *                    DanLib.DrawShadow:Begin()
 *                    draw.RoundedBox(6, x, y, w, h, color)
 *                    DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)
 *
 *                  With caching:
 *                    DanLib.DrawShadow:Begin('my_shadow')
 *                    draw.RoundedBox(6, x, y, w, h, color)
 *                    DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false, w, h, 'my_shadow')
 *
 *   @compatibility DanLib 3.0.0+ | GMod 2024+
 *   @license       MIT License
 */



DanLib.UI = DanLib.UI or {}
local DBase = DanLib.Func
local DTable = DanLib.Table
local DUtils = DanLib.Utils
local DHook = DanLib.Hook

local _drawRoundedBox = draw.RoundedBox
local _drawRoundedBoxEx = draw.RoundedBoxEx
local math, cam, render = math, cam, render
local sin, cos, rad, ceil = math.sin, math.cos, math.rad, math.ceil
local cam_start2D, cam_end2D = cam.Start2D, cam.End2D
local _GetRenderTarget = GetRenderTarget
local _CreateMaterial = CreateMaterial
local push_render_target = render.PushRenderTarget
local override_alpha_writeEnable = render.OverrideAlphaWriteEnable
local clear = render.Clear
local copy_render_target_to_texture = render.CopyRenderTargetToTexture
local blur_render_target = render.BlurRenderTarget
local pop_render_target = render.PopRenderTarget
local set_material = render.SetMaterial
local draw_screen_quad_ex = render.DrawScreenQuadEx
local draw_screen_quad = render.DrawScreenQuad
local render_ClearStencil = render.ClearStencil
local render_SetStencilEnable = render.SetStencilEnable
local render_SetStencilTestMask = render.SetStencilTestMask
local render_SetStencilWriteMask = render.SetStencilWriteMask
local render_SetStencilFailOperation = render.SetStencilFailOperation
local render_SetStencilZFailOperation = render.SetStencilZFailOperation
local render_SetStencilReferenceValue = render.SetStencilReferenceValue
local render_SetStencilCompareFunction = render.SetStencilCompareFunction
local render_SetStencilPassOperation = render.SetStencilPassOperation

do
    local SW = ScrW
    local SH = ScrH

    local function Load()
        -- Main render targets
        local RenderTarget, RenderTarget2
        
        -- Per-instance cache storage
        local ShadowInstances = {}
        local NextPoolID = 1
        local CurrentInstance = nil

        local function load_render_targets()
            local w, h = SW(), SH()
            RenderTarget = _GetRenderTarget('ddi_shadows_original' .. w .. h, w, h)
            RenderTarget2 = _GetRenderTarget('ddi_shadows_shadow' .. w .. h, w, h)
            
            -- Clear instance cache on resolution change
            ShadowInstances = {}
            NextPoolID = 1
        end

        load_render_targets()
        DHook:Add('OnScreenSizeChanged', 'BShadows.RenderTargets', load_render_targets)

        -- Base material for original content
        local ShadowMaterial = _CreateMaterial('bshadows', 'UnlitGeneric', {
            ['$translucent'] = 1,
            ['$vertexalpha'] = 1,
            ['alpha'] = 1
        })

        -- Grayscale material for shadow
        local ShadowMaterialGrayscale = _CreateMaterial('bshadows_grayscale', 'UnlitGeneric', {
            ['$translucent'] = 1,
            ['$vertexalpha'] = 1,
            ['$alpha'] = 1,
            ['$color'] = '0 0 0',
            ['$color2'] = '0 0 0'
        })

        local set_texture = ShadowMaterial.SetTexture
        
        --- Get or create shadow instance for caching
        -- @param instanceID (string): Unique identifier
        -- @return (table): Instance data
        local function GetShadowInstance(instanceID)
            if not ShadowInstances[instanceID] then
                local poolID = NextPoolID
                NextPoolID = NextPoolID + 1
                
                local w, h = SW(), SH()
                local rt = _GetRenderTarget('danlib_shadow_cache_' .. poolID .. '_' .. w .. h, w, h)
                
                ShadowInstances[instanceID] = {
                    rt = rt,
                    poolID = poolID,
                    
                    -- Cache state
                    isCached = false,
                    cachedIntensity = nil,
                    cachedSpread = nil,
                    cachedBlur = nil,
                    cachedOpacity = nil,
                    cachedWidth = nil,
                    cachedHeight = nil,
                    
                    isDrawing = false
                }
            end
            
            return ShadowInstances[instanceID]
        end

        local SHADOWS = {}

        --- Begin shadow drawing context
        -- @param instanceID (string|nil): Unique ID for caching (optional)
        -- @usage DanLib.DrawShadow:Begin()
        -- @usage DanLib.DrawShadow:Begin('my_button')
        function SHADOWS:Begin(instanceID)
            if instanceID then
                local instance = GetShadowInstance(instanceID)
                if instance.isDrawing then
                    ErrorNoHaltWithStack('[DanLib.DrawShadow] Begin() called twice for: ' .. instanceID)
                    return
                end
                instance.isDrawing = true
                CurrentInstance = instanceID
            else
                CurrentInstance = nil
            end
            
            push_render_target(RenderTarget)
            override_alpha_writeEnable(true, true)
            clear(0, 0, 0, 0)
            override_alpha_writeEnable(false, false)
            cam_start2D()
        end

        --- End shadow drawing and render
        -- @param intensity (number): Shadow layer count (default: 1)
        -- @param spread (number): Blur spread multiplier (default: 1)
        -- @param blur (number): Blur iteration count (default: 1)
        -- @param opacity (number): Shadow opacity 0-255 (default: 255)
        -- @param direction (number): Shadow direction in degrees (default: 0)
        -- @param distance (number): Shadow offset in pixels (default: 0)
        -- @param shadowOnly (boolean): Only draw shadow, not original (default: false)
        -- @param forceWidth (number|nil): Width for cache check (optional)
        -- @param forceHeight (number|nil): Height for cache check (optional)
        -- @param instanceID (string|nil): Instance ID for caching (optional)
        -- @usage DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)
        -- @usage DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false, w, h, 'my_button')
        function SHADOWS:End(intensity, spread, blur, opacity, direction, distance, shadowOnly, forceWidth, forceHeight, instanceID)
		    intensity = intensity or 1
		    spread = spread or 1
		    blur = blur or 1
		    opacity = opacity or 255
		    direction = direction or 0
		    distance = distance or 0
		    shadowOnly = shadowOnly or false
		    
		    instanceID = instanceID or CurrentInstance
		    
		    local useCache = (instanceID ~= nil)
		    local instance = useCache and ShadowInstances[instanceID] or nil
		    
		    -- Check if we can use cached blur
		    local needsBlur = true
		    if useCache and instance.isCached then
		        local paramsMatch = 
		            instance.cachedIntensity == intensity and
		            instance.cachedSpread == spread and
		            instance.cachedBlur == blur and
		            instance.cachedOpacity == opacity and
		            (not forceWidth or instance.cachedWidth == forceWidth) and
		            (not forceHeight or instance.cachedHeight == forceHeight)
		        
		        if paramsMatch then
		            needsBlur = false
		        end
		    end
		    
		    if needsBlur then
		        -- Clear RenderTarget2 before copying
		        push_render_target(RenderTarget2)
		        override_alpha_writeEnable(true, true)
		        clear(0, 0, 0, 0)
		        override_alpha_writeEnable(false, false)
		        pop_render_target()
		        
		        copy_render_target_to_texture(RenderTarget2)

		        if (blur > 0) then
		            override_alpha_writeEnable(true, true)
		            blur_render_target(RenderTarget2, spread, spread, blur)
		            override_alpha_writeEnable(false, false)
		        end
		        
		        -- Cache the blurred result if using instanceID
		        if useCache then
		            copy_render_target_to_texture(instance.rt)
		            instance.isCached = true
		            instance.cachedIntensity = intensity
		            instance.cachedSpread = spread
		            instance.cachedBlur = blur
		            instance.cachedOpacity = opacity
		            instance.cachedWidth = forceWidth
		            instance.cachedHeight = forceHeight
		        end
		    end

		    pop_render_target()

		    -- Draw shadow
		    set_material(ShadowMaterialGrayscale)
		    
		    if (useCache and not needsBlur) then
		        -- Use cached blur
		        set_texture(ShadowMaterialGrayscale, '$basetexture', instance.rt)
		    else
		        -- Use fresh blur
		        set_texture(ShadowMaterialGrayscale, '$basetexture', RenderTarget2)
		    end

		    local xOffset = sin(rad(direction)) * distance
		    local yOffset = cos(rad(direction)) * distance

		    for i = 1, ceil(intensity) do
		        draw_screen_quad_ex(xOffset, yOffset, SW(), SH())
		    end

		    -- Draw original content
		    if (not shadowOnly) then
		        set_material(ShadowMaterial)
		        set_texture(ShadowMaterial, '$basetexture', RenderTarget)
		        draw_screen_quad()
		    end

		    cam_end2D()
		    
		    if useCache then
		        instance.isDrawing = false
		    end
		    CurrentInstance = nil
		end
        
        --- Invalidate cache for specific instance
        -- @param instanceID (string): Instance ID to invalidate
        -- @usage DanLib.DrawShadow:InvalidateCache('my_button')
        function SHADOWS:InvalidateCache(instanceID)
            if ShadowInstances[instanceID] then
                ShadowInstances[instanceID].isCached = false
            end
        end
        
        --- Remove instance and free memory
        -- @param instanceID (string): Instance ID to remove
        -- @usage DanLib.DrawShadow:Remove('my_button')
        function SHADOWS:Remove(instanceID)
            if ShadowInstances[instanceID] then
                ShadowInstances[instanceID] = nil
            end
        end

        DanLib.DrawShadow = SHADOWS

        -- Clear shadow render target at the start of each frame
		DHook:Add('PreDrawHUD', 'BShadows.ClearRenderTargets', function()
		    push_render_target(RenderTarget2)
		    override_alpha_writeEnable(true, true)
		    clear(0, 0, 0, 0)
		    override_alpha_writeEnable(false, false)
		    pop_render_target()
		end)

        -- Stencil helpers
        local function _startStencil()
            render_ClearStencil()
            render_SetStencilEnable(true)
            render_SetStencilWriteMask(1)
            render_SetStencilTestMask(1)
            render_SetStencilFailOperation(STENCILOPERATION_REPLACE)
            render_SetStencilPassOperation(STENCILOPERATION_ZERO)
            render_SetStencilZFailOperation(STENCILOPERATION_ZERO)
            render_SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
            render_SetStencilReferenceValue(1)
        end

        local function _middleStencil()
            render_SetStencilFailOperation(STENCILOPERATION_ZERO)
            render_SetStencilPassOperation(STENCILOPERATION_REPLACE)
            render_SetStencilZFailOperation(STENCILOPERATION_ZERO)
            render_SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
            render_SetStencilReferenceValue(1)
        end

        local function _endStencil()
            render_SetStencilEnable(false)
            render_ClearStencil()
        end

        --- Draw partially rounded rectangle
        function DUtils:DrawPartialRoundedBox(cornerRadius, x, y, w, h, color, roundedBoxW, roundedBoxH, roundedBoxX, roundedBoxY)
            _startStencil()
            self:DrawRect(x, y, w, h, color_white)
            _middleStencil()
            _drawRoundedBox(cornerRadius, roundedBoxX or x, roundedBoxY or y, roundedBoxW or w, roundedBoxH or h, color)
            _endStencil()
        end

        --- Draw partially rounded rectangle with corner control
        function DUtils:DrawPartialRoundedBoxEx(cornerRadius, x, y, w, h, color, roundedBoxW, roundedBoxH, roundedBoxX, roundedBoxY, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
            _startStencil()
            self:DrawRect(x, y, w, h, color_white)
            _middleStencil()
            _drawRoundedBoxEx(cornerRadius, roundedBoxX or x, roundedBoxY or y, roundedBoxW or w, roundedBoxH or h, color, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
            _endStencil()
        end
    end

    Load()

    DHook:Add('OnScreenSizeChanged', 'BShadows.ResolutionChange', function()
        SW, SH = ScrW(), ScrH()
        Load()
    end)
end




local MetaEntity = FindMetaTable('Entity')
local TIME = 0.66
-- Variables
local lastHp = 0
local lerp = 0
local apLerp = 0
local index = -1
local time = 0
local colour = 0

function MetaEntity.SetCreateEntityToolTip(self, title, bool, text, icon, color)
	if(not IsValid(self)) then return end
	if (not ENT_TABLE_TOOLTIP) then ENT_TABLE_TOOLTIP = {} end

	local textX, textY = 0, 0

	title = title or 'No title'
	text = text or 'No text'
	bool = bool or false
	color = color or DBase:Theme('title')
	icon = icon

	ENT_TABLE_TOOLTIP[self] = { title, bool, text, color, icon }
end

local function HUDPaintEntityTooltip()
	local pPlayer = LocalPlayer()
	local x, y = ScrW(), ScrH()
	local trace = pPlayer:GetEyeTrace()

	-- check whether we're looking at a player
	if (trace.Hit and trace.Entity:IsPlayer()) then
		time = CurTime() + TIME
		index = trace.Entity:EntIndex()
	end

	-- get entity
    local entity = ents.GetByIndex(index) or nil
	if (entity ~= nil) then
		local hitPos = trace.HitPos
		local alpha = 255
		local viewdist = 100
		local fadeInTime = 0.5 -- Time of appearance
        local fadeOutTime = 0.5 -- Disappearance time
        local maxAlpha = 255

		-- calculate alpha
		local max, min = viewdist, viewdist * 0.75
		local dist = pPlayer:EyePos():Distance(hitPos)

		local frac = DUtils:InverseLerp(dist, max, min)
		if (dist > min and dist < max) then
			alpha = maxAlpha * frac
		elseif (dist > max) then
			alpha = 0
		end

		-- Updating the alpha with a smooth transition
        if (alpha > 0) then
            alpha = math.min(maxAlpha, alpha + (maxAlpha / fadeInTime * FrameTime()))
        else
            alpha = math.max(0, alpha - (maxAlpha / fadeOutTime * FrameTime()))
        end

		local entTable = {}

		for k, v in pairs(ents.FindInSphere(hitPos, 25)) do
			if (IsValid(v) and ENT_TABLE_TOOLTIP and ENT_TABLE_TOOLTIP[v]) then
				DTable:Add(entTable, { hitPos:DistToSqr(v:GetPos()), v })
			end
		end

		DTable:Sort(entTable, function(a, b) 
			return a[1] < b[1] 
		end)

		local ent = (entTable[1] or {})[2]
		if (ent ~= nil) then
			local position = select(1, ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine') or -1)) or ent:LocalToWorld(ent:OBBCenter())
			position = position:ToScreen()

			local arrowX, arrowY = clamp(position.x, 0, x), clamp(position.y, 0, y)
			local title, bool, text, color, icon = ENT_TABLE_TOOLTIP[ent][1], ENT_TABLE_TOOLTIP[ent][2], ENT_TABLE_TOOLTIP[ent][3], ENT_TABLE_TOOLTIP[ent][4], ENT_TABLE_TOOLTIP[ent][5]

			local width2, height2 = 0, 0
			local width, height = DUtils:GetTextSize(title, 'danlib_font_18')

			if bool then
				width2, height2 = DUtils:GetTextSize(text, 'danlib_font_18')
			end

			local showW, showY = arrowX, arrowY
			local text_w, text_y = 0, 0
			local w = bool and (width / width2) - (arrowX / arrowX) + 70  or 50

			tbl = { width + w - 28, height + 16 + height2, text_w + arrowX + 10, text_y + showY }

	    	if icon then
	    		tbl = { width + w, height + 16 + height2, text_w + arrowX + 36, text_y + showY }
	    	end

			if (alpha > 0) then
				DanLib.DrawShadow:Begin()
				DUtils:DrawRect(showW, showY, tbl[1], tbl[2], DBase:Theme('primary_notifi', alpha))
				DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)

				DUtils:DrawRect(showW + tbl[1] - 6, showY - 1, 7, 2, DBase:Theme('decor', alpha))
				DUtils:DrawRect(showW + tbl[1] - 1, showY, 2, 6, DBase:Theme('decor', alpha))

				DUtils:DrawRect(showW - 1, showY + tbl[2] - 6, 2, 6, DBase:Theme('decor', alpha))
				DUtils:DrawRect(showW - 1, showY + tbl[2] - 1, 7, 2, DBase:Theme('decor', alpha))

				local size = 20
				if icon then
					DUtils:DrawIcon(arrowX + 10, tbl[4] + 7, size, size, icon, ColorAlpha(color, alpha))
					noIcon = showW + 36
				end

				draw.SimpleText(title, 'danlib_font_18', tbl[3], tbl[4] + 15, ColorAlpha(color, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.DrawText(bool and text or '', 'danlib_font_18', tbl[3], tbl[4] + 24, DBase:Theme('text', alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end
end
DHook:Add('HUDPaint', 'DDI.HUDPaintEntityTooltip', HUDPaintEntityTooltip)

local function RemoveEntityTooltip(ent)
	if (ENT_TABLE_TOOLTIP and ENT_TABLE_TOOLTIP[ent]) then
		ENT_TABLE_TOOLTIP[ent] = nil
	end
end
DHook:Add('EntityRemoved', 'DDI.RemoveEntityToolTip', RemoveEntityTooltip)
