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


local material = Material

local surface = surface
local draw_material = surface.SetMaterial
local draw_color = surface.SetDrawColor
local draw_poly = surface.DrawPoly
local draw_rect = surface.DrawRect
local draw_textured_rect = surface.DrawTexturedRect
local draw_textured_rect_rotated = surface.DrawTexturedRectRotated
local draw_textured_rect_uv = surface.DrawTexturedRectUV

local draw = draw
local no_texture = draw.NoTexture
local rounded_box = draw.RoundedBox
local rounded_box_ex = draw.RoundedBoxEx
local simple_text = draw.SimpleText
local draw_text = draw.DrawText

local table = table
local insert = table.insert

local math = math
local rad = math.rad
local cos = math.cos
local sin = math.sin
local round = math.Round

local color = Color
local color_alpha = ColorAlpha
local lerp = Lerp
local frame_time = FrameTime


--- Constants
local screenBlur = material('pp/blurscreen')
local gradientLeft = material('vgui/gradient-l')
local gradientUp = material('vgui/gradient-u')
local gradientRight = material('vgui/gradient-r')
local gradientDown = material('vgui/gradient-d')



do
    --- @credits: 
    --    https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/draw.lua
    --    https://gist.github.com/MysteryPancake/e8d367988ef05e59843f669566a9a59f

    --- @type Material
    local MaskMaterial = CreateMaterial('!bluemask', 'UnlitGeneric', {
        ['$translucent'] = 1,
        ['$vertexalpha'] = 1,
        ['$alpha'] = 1,
    })


    --- @type Color
    local whiteColor = Color(255, 255, 255, 255)
    local renderTarget


    --- Draws a rounded mask.
    -- @param cornerRadius: The radius of the rounded corners.
    -- @param x: X coordinate of the top left corner.
    -- @param y: Y coordinate of the top left corner.
    -- @param w: Width of the mask.
    -- @param h: Height of the mask.
    -- @param draw_func: Function to draw the contents of the mask.
    -- @param roundTopLeft: Rounding of the top left corner.
    -- @param roundTopRight: Round the top right corner.
    -- @param roundBottomLeft: Rounding of the bottom left corner.
    -- @param roundBottomRight: Rounding of the bottom right corner.
    local function rounded_mask(cornerRadius, x, y, w, h, draw_func, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
        if (not renderTarget) then
            renderTarget = GetRenderTargetEx('DDI_ROUNDEDBOX', ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_NONE, 2, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)
        end

        render.PushRenderTarget(renderTarget)
        render.OverrideAlphaWriteEnable(true, true)
        render.Clear(0, 0, 0, 0)

        draw_func()

        render.OverrideBlendFunc(true, BLEND_ZERO, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLEND_ZERO)
        draw.RoundedBoxEx(cornerRadius, x, y, w, h, whiteColor, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
        render.OverrideBlendFunc(false)
        render.OverrideAlphaWriteEnable(false)
        render.PopRenderTarget()

        MaskMaterial:SetTexture('$basetexture', renderTarget)

        no_texture()
        draw_color(255, 255, 255, 255)
        draw_material(MaskMaterial)
        render.SetMaterial(MaskMaterial)
        render.DrawScreenQuad()
    end


    --- Draws a rounded mask with equal corners.
    -- @param cornerRadius: The radius of the rounded corners.
    -- @param x: X coordinate of the top left corner.
    -- @param y: Y coordinate of the top left corner.
    -- @param w: Width of the mask.
    -- @param h: Height of the mask.
    -- @param dFunc: Function to draw the contents of the mask.
    local function draw_rounded_mask(cornerRadius, x, y, w, h, dFunc)
        rounded_mask(cornerRadius, x, y, w, h, dFunc, true, true, true, true)
    end


    --- Draws a rounded mask with custom corners.
    -- @param cornerRadius: The radius of the rounded corners.
    -- @param x: X coordinate of the top left corner.
    -- @param y: Y coordinate of the top left corner.
    -- @param w: Width of the mask.
    -- @param h: Height of the mask.
    -- @param dFunc: Function to draw the contents of the mask.
    -- @param roundTopLeft: Rounding of the top left corner.
    -- @param roundTopRight: Round the top right corner.
    -- @param roundBottomLeft: Rounding of the bottom left corner.
    -- @param roundBottomRight: Rounding of the bottom right corner.
    local function draw_rounded_ex_mask(cornerRadius, x, y, w, h, dFunc, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
        rounded_mask(cornerRadius, x, y, w, h, dFunc, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
    end
end


--- Draws a circle on the screen.
-- @param sx: The X-coordinate of the centre of the circle.
-- @param sy: The Y-coordinate of the center of the circle.
-- @param radius: The radius of the circle.
-- @param seg: The number of segments to draw the circle. The default value is 30.
-- @param color: The colour of the circle. The default colour is white.
-- @param angle: The angle of rotation of the circle in radians. The default value is 0.
-- @return: Table with the coordinates of the vertices of the circle.
local function draw_circle(sx, sy, radius, seg, color, angle)
    -- Set the default colour
    color = color or color_white
    -- Set the default number of segments
    seg = seg or 30

    local cir = {}
    -- Angle in radians
    local ang = -rad(angle or 0)
    local c = cos(ang)
    local s = sin(ang)

    -- Circle vertex generation
    for i = 0, 360, 360 / seg do
        local radd = rad(i)
        local x = cos(radd)
        local y = sin(radd)

        local tempx = x * radius * c - y * radius * s + sx
        y = x * radius * s + y * radius * c + sy
        x = tempx

        -- u or v -- Placeholder for texture coordinates
        cir[#cir + 1] = { x = x, y = y, u = 0, v = 0 }
    end

    -- Checking that the circle contains at least one vertex
    if (#cir > 0) then -- (cir and #cir > 0)
        -- Turning off the texture for rendering
        no_texture()
        -- Set the colour for rendering
        draw_color(color)
        -- Drawing a circle
        draw_poly(cir)
    end

    return cir  -- Return the table with the vertices of the circle
end


--- Function for drawing a rectangle with rounded corners
local function draw_rounded_rect(w, h)
    -- Draw a rounded rectangle
    local poly = {}

    local x = w / 2
    local y = h / 2
    local radius = h / 1.5
    local vertices = 90

    table.insert(poly, { x = x, y = y })

    for i = 0, vertices do
        local a = rad((i / vertices) * -360) + 90
        table.insert(poly, { x = x + sin(a) * radius, y = y + cos(a) * radius })
    end

    local a = rad(0)
    table.insert(poly, { x = x + sin(a) * radius, y = y + cos(a) * radius })

    return poly
end

-- local function draw_rounded_rect(x, y, w, h, r)
--     local tbl = {
--         {x + r, y},
--         {x + w - r, y},
--         {x + w, y + r},
--         {x + w, y + h - r},
--         {x + w - r, y + h},
--         {x + r, y + h},
--         {x, y + h - r},
--         {x, y + r},
--     }
    
--     return tbl
-- end



DanLib.CustomUtils = DanLib.CustomUtils or {}

--- Utility Functions
local CustomUtils = {}


--- Draws a filled circle at the specified coordinates.
-- @param cx: The x-coordinate of the center of the circle.
-- @param cy: The y-coordinate of the center of the circle.
-- @param radius: The radius of the circle.
-- @param color: The color of the circle.
CustomUtils.DrawFilledCircle = function(cx, cy, radius, color)
    local points = {}

    for angle = 0, 360 do
        local rad = rad(angle)
        points[#points + 1] = { x = cx + cos(rad) * radius, y = cy + sin(rad) * radius }
    end

    -- draw_color(color)
    no_texture()
    draw_poly(points)
end


--- Draws an arc segment.
-- @param cx: The x-coordinate of the center of the arc.
-- @param cy: The y-coordinate of the center of the arc.
-- @param startAngle: The starting angle of the arc in degrees.
-- @param sweepAngle: The angle to sweep in degrees.
-- @param radius: The radius of the arc.
-- @param color: The color of the arc.
-- @param segments: The number of segments to use for drawing the arc.
CustomUtils.DrawArcSegment = function(cx, cy, startAngle, sweepAngle, radius, color, segments)
    segments = segments or 80
    local points = {}

    insert(points, { x = cx, y = cy })
    for i = 0, segments do
        local angle = rad(startAngle + (i / segments) * sweepAngle)
        insert(points, { x = cx + cos(angle) * radius, y = cy + sin(angle) * radius })
    end

    draw_color(color)
    no_texture()
    draw_poly(points)
end


--- Performs linear interpolation between two colors.
-- @param fraction: The interpolation fraction (0 to 1).
-- @param startColor: The starting color.
-- @param endColor: The ending color.
-- @return The interpolated color.
CustomUtils.ColorLerp = function(fraction, startColor, endColor)
    return color(
        lerp(fraction, startColor.r, endColor.r),
        lerp(fraction, startColor.g, endColor.g),
        lerp(fraction, startColor.b, endColor.b),
        lerp(fraction, startColor.a, endColor.a)
    )
end


--- Checks if the panel is currently hovered.
-- @param panel: The panel to check.
-- @return True if the panel is hovered, false otherwise.
CustomUtils.IsHovered = function(panel)
    return panel:IsHovered()
end


--- Checks if the panel or any of its children are currently hovered.
-- @param panel: The panel to check.
-- @return True if the panel or its children are hovered, false otherwise.
CustomUtils.IsHoveredOrChild = function(panel)
    return panel:IsHovered() or panel:IsChildHovered()
end



--- Panel Class Functions
local panelClasses = {}


--- Extends the panel with new functionalities for events.
-- @param panel: The panel to extend.
-- @param eventName: The name of the event to hook into.
-- @param callback: The callback function to run when the event is triggered.
function panelClasses:ApplyEvent(eventName, callback)
    -- Set the default value for eventName if it is not specified
    eventName = eventName or 'Paint' -- If eventName is not set, we use 'Paint'
    local originalEvent = self[eventName]

    self[eventName] = function(sl, ...)
        if originalEvent then originalEvent(sl, ...) end
        callback(sl, ...)
    end
end


--- Sets a transition for a specified property of the panel.
-- @param propertyName: The name of the property to transition.
-- @param speed: The speed of the transition.
-- @param targetFunc: The function that determines the target value.
function panelClasses:SetTransition(propertyName, speed, targetFunc)
    targetFunc = self.TransitionFunc or targetFunc

    self[propertyName] = 0
    self:ApplyEvent('Think', function(self)
        self[propertyName] = lerp(frame_time() * speed, self[propertyName], targetFunc(self) and 1 or 0)
    end)
end


--- Applies a fade effect on hover to the panel.
-- @param panel: The panel to apply the effect to.
-- @param color: The color to fade to.
-- @param speed: The speed of the fade transition.
-- @param radius: The corner radius for rounded boxes.
function panelClasses:ApplyFadeHover(color, speed, radius)
    color = color or color(255, 255, 255, 30)
    speed = speed or 8

    self:SetTransition('HoverFade', speed, CustomUtils.IsHovered)
    self:ApplyEvent(nil, function(sl, w, h)
        local fadeColor = color_alpha(color, color.a * sl.HoverFade)

        if (radius and radius > 0) then
            rounded_box(radius, 0, 0, w, h, fadeColor)
        else
            draw_color(fadeColor)
            draw_rect(0, 0, w, h)
        end
    end)
end


-- Draws a blur effect on a specified panel.
-- @param panel: The panel on which to draw the blur effect.
-- @param intensity: The intensity of the blur effect.
-- @param depth: The number of iterations to apply the blur, affecting the smoothness.
-- @return: None (the function directly modifies the rendering output).
function panelClasses:ApplyBlur(intensity, depth)
    intensity = intensity or 1
    depth = depth or 1

    self:ApplyEvent(nil, function(sl, w, h)
        -- Get the screen position of the panel
        local x, y = sl:LocalToScreen(0, 0)

        -- Set the draw color to white
        draw_color(255, 255, 255)

        -- Set the blur material
        draw_material(screenBlur)

        -- Loop to create the blur effect
        for i = 1, depth do
            -- Calculate the blur amount for the current iteration
            local blurAmount = (i / depth) * intensity
            screenBlur:SetFloat('$blur', blurAmount)
            screenBlur:Recompute()

            render.UpdateScreenEffectTexture()
            -- Draw the textured rectangle with the current blur
            draw_textured_rect(-x, -y, ScrW(), ScrH())
        end
    end)
end


--- Applies the background to the panel with the specified parameters.
-- @param panel The panel to which the background will be applied.
-- @param color Background color.
-- @param roundness Corner rounding radius (default is 0).
-- @param roundness Specifies which corners should be rounded (TOP, BOTTOM, LEFT, RIGHT or nil for all corners).
function panelClasses:ApplyBackground(colour, roundness, round)
    colour = colour or Color(10, 10, 10, 100)

    self:ApplyEvent(nil, function(sl, w, h)
        if (roundness && roundness > 0) then
            if (round != nil) then
                if (round == TOP) then
                    rounded_box_ex(roundness, 0, 0, w, h, colour, true, true, false, false)
                elseif (round == BOTTOM) then
                    rounded_box_ex(roundness, 0, 0, w, h, colour, false, false, true, true)
                elseif (round == LEFT) then
                    rounded_box_ex(roundness, 0, 0, w, h, colour, true, false, true, false)
                elseif (round == RIGHT) then
                    rounded_box_ex(roundness, 0, 0, w, h, colour, false, true, false, true)
                end
            else
                rounded_box(roundness, 0, 0, w, h, colour)
            end
        else
            -- If no radius is specified, just draw a rectangle
            draw_color(colour)
            draw_rect(0, 0, w, h)
        end
    end)
end


--- Applies a hover effect to a panel using a horizontal bar.
-- @param color: The color of the bar. Defaults to white (255, 255, 255, 255, 255).
-- @param height: The height of the bar. The default is 2.
-- @param speed: Transition speed. Default 6.
function panelClasses:ApplyBarHover(color, height, speed)
    color = color or Color(255, 255, 255, 255)
    height = height or 2
    speed = speed or 6

    self:SetTransition('BarHover', speed, CustomUtils.IsHovered)
    self:ApplyEvent('PaintOver', function(sl, w, h)
        local bar = round(w * sl.BarHover)
        draw_color(color)
        draw_rect(w / 2 - bar / 2, h - height, bar, height)
    end)
end


--- Applies a hover effect to the panel using fill.
-- @param color: Fill color. Defaults to translucent white (255, 255, 255, 255, 30).
-- @param dir: Direction of the fill. The default is BOTTOM.
-- @param speed: Transition speed. Default is 8.
-- @param mat: Fill material. If not specified, normal fill is used.
function panelClasses:ApplyFillHover(color, dir, speed, mat)
    color = color or Color(255, 255, 255, 30)
    dir = dir or BOTTOM
    speed = speed or 8

    self:SetTransition('FillHover', speed, CustomUtils.IsHovered)
    self:ApplyEvent('PaintOver', function(sl, w, h)
        draw_color(color)

        local x, y, fw, fh
        if (dir == LEFT) then
            x, y, fw, fh = 0, 0, round(w * sl.FillHover), h
        elseif (dir == TOP) then
            x, y, fw, fh = 0, 0, w, round(h * sl.FillHover)
        elseif (dir == RIGHT) then
            local prog = round(w * sl.FillHover)
            x, y, fw, fh = w - prog, 0, prog, h
        elseif (dir == BOTTOM) then
            local prog = round(h * sl.FillHover)
            x, y, fw, fh = 0, h - prog, w, prog
        end

        if (mat) then
            draw_material(mat)
            draw_textured_rect(x, y, fw, fh)
        else
            draw_rect(x, y, fw, fh)
        end
    end)
end


--- Creates a circle button effect when clicked.
-- @param color: The color of the circle effect.
-- @param speed: The speed of the circle's animation.
-- @param maxRadius: The maximum radius of the circle.
function panelClasses:ApplyCircleEffect(color, speed, maxRadius)
    color = color or Color(255, 255, 255, 50)
    speed = speed or 5

    self.CircleRadius, self.CircleAlpha, self.ClickX, self.ClickY = 0, 0, 0, 0
    self:ApplyEvent(nil, function(sl, w, h)
        if (sl.CircleAlpha >= 1) then
            draw_color(color_alpha(color, sl.CircleAlpha))
            no_texture()
            CustomUtils.DrawFilledCircle(sl.ClickX, sl.ClickY, sl.CircleRadius)
            sl.CircleRadius = lerp(frame_time() * speed, sl.CircleRadius, maxRadius or w)
            sl.CircleAlpha = lerp(frame_time() * speed, sl.CircleAlpha, 0)
        end
    end)
    self:ApplyEvent('DoClick', function(sl)
        sl.ClickX, sl.ClickY = sl:CursorPos()
        sl.CircleRadius = 0
        sl.CircleAlpha = color.a
    end)
end


--- Pin the panel to a specified dock position with optional margin.
-- @param dock: The docking position (default is FILL).
-- @param margin: The margin around the panel (default is 0).
-- @param dontInvalidate: If true, the parent will not be invalidated (default is false).
function panelClasses:Pin(dock, margin, dontInvalidate)
    dock = dock or FILL
    margin = margin or 0

    self:Dock(dock)
    if (margin > 0) then
        self:DockMargin(margin, margin, margin, margin)
    end

    if (not dontInvalidate) then
        self:InvalidateParent(true)
    end
end


--- Snaps the panel at the specified position, subject to optional indents.
-- @param dock: Snap position (default is FILL).
-- @param marginLeft: Left margin (default is 0).
-- @param marginTop: Top margin (default is 0).
-- @param marginRight: Indent to the right (default is 0).
-- @param marginBottom: Indent from bottom (default is 0).
function panelClasses:PinMargin(dock, marginLeft, marginTop, marginRight, marginBottom)
    dock = dock or FILL
    marginLeft = marginLeft or 0
    marginTop = marginTop or 0
    marginRight = marginRight or 0
    marginBottom = marginBottom or 0

    self:Dock(dock)
    self:DockMargin(marginLeft, marginTop, marginRight, marginBottom)
end


--- Sets the panel width equal to the width of the parent element
-- or the width of the screen if there is no parent.
-- @return void
function panelClasses:ApplyWide()
    local parentWidth = self:GetParent() and self:GetParent():GetWide() or ScrW()
    self:SetWide(parentWidth)
end


--- Sets the height of the panel equal to the height of the parent element
-- or the height of the screen if there is no parent.
-- @return void
function panelClasses:ApplyTall()
    local parentHeight = self:GetParent() and self:GetParent():GetTall() or ScrH()
    self:SetTall(parentHeight)
end


function panelClasses:ApplySound(pathHover, pathClick)
    -- pathHover = pathHover or 'ddi/button-hover.wav'
    -- pathClick = pathClick or 'ddi/button-click.wav'

    if pathHover then
        self:ApplyEvent('OnCursorEntered', function(sl)
            surface.PlaySound(pathHover)
        end)
    end

    if pathClick then
        self:ApplyEvent('OnRelease', function(sl) -- OnMouseReleased
            surface.PlaySound(pathClick)
        end)
    end
end


--- Applies text to a panel with the given parameters.
-- @param text The text to be displayed.
-- @param font The font of the text (default is 'danlib_font_18').
-- @param x Position on the X axis (default is the centre of the panel).
-- @param y Y-axis position (default is the centre of the panel).
-- @param colour Text colour (default is white).
-- @param xAlign X-axis alignment (default centre).
-- @param yAlign Y-axis alignment (default centre).
function panelClasses:ApplyText(text, font, x, y, color, xAlign, yAlign)
    font = font or 'danlib_font_18'
    color = color or Color(255, 255, 255, 255)
    xAlign = xAlign or TEXT_ALIGN_CENTER
    yAlign = yAlign or TEXT_ALIGN_CENTER

    self:ApplyEvent(nil, function(sl, w, h)
        -- Set x and y to default if they are nil
        x = x or (w * 0.5)
        y = y or (h * 0.5)

        simple_text(text, font, x, y, color, xAlign, yAlign)
    end)
end


--- Creates a panel with a circular avatar.
-- @param pParent: The parent panel to which this panel will be attached.
-- @param cornerRadius: The rounding radius of the avatar corners. If false, the default drawing method is used.
-- @return PANEL: Returns the created panel with a round avatar.
function panelClasses:ApplyAvatar(rounded, cornerRadius, outlineColor)
    rounded = rounded or false
    cornerRadius = cornerRadius or 4
    outlineColor = outlineColor or DanLib.Func:Theme('frame')

    self.Avatar = vgui.Create('AvatarImage', self)
    self.Avatar:SetPaintedManually(true)

    --- Performs the layout of the panel elements.
    -- Sets the avatar size and position, and calculates the polygon.
    self.PerformLayout = function(sl)
        sl.Avatar:SetSize(sl:GetWide(), sl:GetTall())
    end

    --- Sets the player for the avatar.
    -- @param pPlayer: The player whose avatar will be displayed.
    -- @param Size: Avatar size.
    self.SetPlayer = function(sl, pPlayer, size)
        sl.Avatar:SetPlayer(pPlayer, size)
    end
    
    --- Sets the Steam ID for the avatar.
    -- @param SteamID64: Steam Player ID.
    -- @param Size: Avatar size.
    self.SetSteamID = function(sl, id, size)
        sl.Avatar:SetSteamID(id, size)
    end

    --- Draws a panel using a stentile.
    -- Creates a stentil mask and draws an avatar.
    -- @param w: Panel width.
    -- @param h: Panel height.
    self.Paint = function(sl, w, h)
        if rounded then
            -- We use the standard drawing method
            render.ClearStencil()
            render.SetStencilEnable(true)

            render.SetStencilWriteMask(1)
            render.SetStencilTestMask(1)

            render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
            render.SetStencilPassOperation(STENCILOPERATION_ZERO)
            render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
            render.SetStencilReferenceValue(1)

            draw_circle(w / 2, h / 2, h / 2, w / 2, Color(0, 0, 0, 255))

            render.SetStencilFailOperation(STENCILOPERATION_ZERO)
            render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
            render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
            render.SetStencilReferenceValue(1)

            sl.Avatar:PaintManual()

            render.SetStencilEnable(false)
            render.ClearStencil()
        else
            DanLib.Utils:DrawRoundedMask(cornerRadius, 0, 0, w, h, function()
                rounded_box(cornerRadius, 0, 0, w, h, Color(0, 0, 0, 150))
                sl.Avatar:PaintManual()
            end)

            -- local x, y = sl:LocalToScreen(0, 0)
            -- DanLib.Outline:Draw(cornerRadius, x, y, w, h, outlineColor, nil, 1)
        end
    end
end


--- Applies the circle pattern to the panel.
-- @param color: Color of the circle. The default is white (255, 255, 255, 255, 255).
function panelClasses:ApplyCircle(color)
    color = color or Color(255, 255, 255, 255)

    self:ApplyEvent(nil, function(_, w, h)
        -- draw.NoTexture()
        -- surface.SetDrawColor(color)
        -- drawCircle(w * 0.5, h * 0.5, math.min(w, h) * 0.5)

        draw_circle(w * 0.5, h * 0.5, math.min(w, h) * 0.5, nil, color)
    end)
end


--- Applies a delete event to the panel.
-- Deletes the specified target if it is valid.
-- @param target: The target to delete. The default is the panel itself.
function panelClasses:ApplyRemove(target)
    target = target or self
    self:ApplyEvent('DoClick', function()
        if IsValid(target) then target:Remove() end
    end)
end


-- @param duration (nember): The time in seconds it should take to reach the alpha.
-- @param alpha (nember): The alpha value (0-255) to approach.
function panelClasses:ApplyAttenuation(duration, alpha)
    duration = duration or 0.2
    alpha = alpha or 255

    self:SetAlpha(0)
    self:AlphaTo(alpha, duration, 0)
end


--- Hides the vertical scrollbar.
-- Sets the width of the vertical scrollbar to 0 and hides it.
function panelClasses:ApplyHideBar()
    local vbar = self:GetVBar()
    vbar:SetWide(0)
    vbar:Hide()
end


--- Clears the panel drawing function.
-- Sets the panel drawing function to nil, resulting in no drawing.
function panelClasses:ApplyClearPaint()
    self.Paint = nil
end


--- Sets the transition function for the panel.
-- @param func: Function to be used for transitions.
function panelClasses:SetTransitionFunc(func)
    self.TransitionFunc = func
end


--- Clears the transition function for the panel.
-- Sets the transition function to nil, which disables transitions.
function panelClasses:ClearTransitionFunc()
    self.TransitionFunc = nil
end


--- Sets the function to add or overwrite.
-- @param func: The function to be used to add or overwrite.
function panelClasses:SetAppendOverwrite(func)
    self.AppendOverwrite = func
end


--- Clears the add or overwrite function.
-- Sets the add or overwrite function to nil.
function panelClasses:ClearAppendOverwrite()
    self.AppendOverwrite = nil
end


--- Configures the text field to be ready for editing.
-- Disables background fill and sets the add or overwrite function.
function panelClasses:ApplyReadyTextbox()
    self:SetPaintBackground(false)
    self:SetAppendOverwrite('PaintOver')
    self:SetTransitionFunc(function(sl) return sl:IsEditing() end)
end


-- Meta Function to Register Classes
local meta = FindMetaTable('Panel')
function meta:CustomUtils()
    self.Class = function(panel, className, ...)
        local classFunc = panelClasses[className]
        assert(classFunc, '[Custom Utils]: Class ' .. className .. ' does not exist.')
        classFunc(panel, ...)
        return panel
    end

    for name, func in pairs(panelClasses) do
        self[name] = function(self, ...) return self:Class(name, ...) end
    end
    return self
end


--- Creates a new panel with specified class.
-- @param parent: The parent panel to attach the new panel to.
-- @param classname: The name of the class to create (defaults to 'EditablePanel').
-- @return The created panel item.
function DanLib.CustomUtils.Create(parent, classname)
    -- If parent is nil, return nil and do nothing
    parent = parent or nil

    -- If classname is not specified, we use 'EditablePanel' by default
    classname = classname or 'EditablePanel'

    -- Creating a new panel element based on the specified class
    local panel = vgui.Create(classname, parent)

    -- Applying the CustomUtils method to the created panel
    panel:CustomUtils()

    -- Return the created panel item
    return panel
end

