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
local utils = DanLib.Utils


local aliases = {

}

local math = math
local round = math.Round
local max = math.max
local rad = math.rad
local min = math.min
local sin = math.sin
local cos = math.cos
local pow = math.pow
local ceil = math.ceil
local TimeFraction = math.TimeFraction
local floor = math.floor
local clamp = math.Clamp
local easeInOut = math.EaseInOut

local surface = surface
local set_material = surface.SetMaterial
local draw_color = surface.SetDrawColor
local draw_poly = surface.DrawPoly
local draw_line = surface.DrawLine
local draw_texture = surface.SetTexture
local draw_text = surface.DrawText
local draw_textured_rect = surface.DrawTexturedRect
local draw_textured_rect_rotated = surface.DrawTexturedRectRotated
local draw_textured_rect_uv = surface.DrawTexturedRectUV
local draw_rect = surface.DrawRect
local set_font = surface.SetFont
local get_text_size = surface.GetTextSize
local set_text_color = surface.SetTextColor
local draw_outlined_rect = surface.DrawOutlinedRect
local set_text_pos = surface.SetTextPos
local draw_texture_id = surface.GetTextureID

local draw = draw
local draw_text = draw.DrawText
local rounded_box = draw.RoundedBox
local rounded_box_ex = draw.RoundedBoxEx
local simple_text = draw.SimpleText
local no_texture = draw.NoTexture

local render = render
local push_filter_mag = render.PushFilterMag
local push_filter_min = render.PushFilterMin
local pop_filter_mag = render.PopFilterMag
local pop_filter_min = render.PopFilterMin
local depth_range = render.DepthRange
local rmaterial = render.SetMaterial
local update_screen_effect_texture = render.UpdateScreenEffectTexture
local set_stencil_write_mask = render.SetStencilWriteMask
local set_stencil_test_mask = render.SetStencilTestMask
local set_stencil_reference_value= render.SetStencilReferenceValue
local set_stencil_pass_operation = render.SetStencilPassOperation
local set_stencilZ_fail_operation = render.SetStencilZFailOperation
local clear_stencil = render.ClearStencil
local rclear = render.Clear
local set_stencil_compare_function = render.SetStencilCompareFunction
local set_stencil_fail_operation = render.SetStencilFailOperation
local set_stencil_enable = render.SetStencilEnable
local pushRenderTarget = render.PushRenderTarget
local overrideAlphaWriteEnable = render.OverrideAlphaWriteEnable
local overrideBlendFunc = render.OverrideBlendFunc
local popRenderTarget = render.PopRenderTarget
local drawScreenQuad = render.DrawScreenQuad
local getRenderTargetEx = GetRenderTargetEx

local mesh = mesh
local mesh_color = mesh.Color
local mesh_position = mesh.Position
local mesh_advanceVertex = mesh.AdvanceVertex
local mesh_begin = mesh.Begin
local mesh_end = mesh.End

local table = table
local sortByMember = table.SortByMember

local string = string
local len = string.len
local sub = string.sub
local format = string.format
local match = string.match
local rep = string.rep

local bit = bit
local band = bit.band
local lshift = bit.lshift
local bor = bit.bor

local lerp = Lerp
local SW, SH = ScrW, ScrH
local rcolor = Color


do
    --- Scales a value based on the current screen width.
    -- @param value (number): The value to scale.
    -- @return (number): The scaled value.
    function base:Scale(value)
        return round(value * (SW() / 2560))
    end


    --- Scales a value based on the current screen height, ensuring a minimum value of 1.
    -- @param value (number): The value to scale.
    -- @return (number): The scaled value, or 1 if the result is less than 1.
    function base:ScaleH(value)
       return max(value * (SH() / 1080), 1)
    end


    --- Scales the original width and height based on the current screen resolution.
    -- @param originalWidth (number): The original width of the element.
    -- @param originalHeight (number): The original height of the element.
    -- @return (number, number): The new scaled width and height.
    function utils:ScaleSize(originalWidth, originalHeight)
        -- Get the current screen resolution
        local screenWidth, screenHeight = SW(), SH()
        -- Determine the scaling factors
        local widthScale = screenWidth / 1920 -- 1920 - standard width
        local heightScale = screenHeight / 1080 -- 1080 - standard height
        -- We use the minimum scaling factor to preserve proportions
        local scale = min(widthScale, heightScale)
        -- Returning the new sizes
        return originalWidth * scale, originalHeight * scale
    end


    function utils:ScaleWide(w, ref)
        ref = ref or 1600
        return round(w / ref * ScrW())
    end


    function utils:ScaleTall(h, ref)
        ref = ref or 900
        return round(h / ref * ScrH())
    end


    --- Calculates the X position based on a relative percentage of the screen width.
    -- @param t (number): The relative position factor.
    -- @return (number): The calculated X position.
    function utils:PosX(t)
    	return (SW() / 2) * t
    end


    --- Calculates the Y position based on a relative percentage of the screen height.
    -- @param t (number): The relative position factor.
    -- @return (number): The calculated Y position.
    function utils:PosY(t)
    	return (SH() / 2) * t
    end


    --- Scales a width value based on the standard width of 1920.
    -- @param x (number): The reference width value.
    -- @return (number): The scaled width based on the current screen width.
    function utils:Width(x)
    	return 1920 / x * SW()
    end


    --- Scales a height value based on the standard height of 1080.
    -- @param y (number): The reference height value.
    -- @return (number): The scaled height based on the current screen width.
    function utils:Height(y)
    	return 1080 / y * SW()
    end
end


-- Draws a blur effect on a specified panel.
-- @param panel: The panel on which to draw the blur effect.
-- @param intensity: The intensity of the blur effect.
-- @param depth: The number of iterations to apply the blur, affecting the smoothness.
-- @return: None (the function directly modifies the rendering output).
local blurMaterial = DanLib.Config.Materials['Blur']
function utils:DrawBlur(panel, intensity, depth)
    -- Get the screen position of the panel
    local x, y = panel:LocalToScreen(0, 0)

    -- Set the draw color to white
    draw_color(255, 255, 255)

    -- Set the blur material
    set_material(blurMaterial)

    -- Update the screen effect texture once before the loop
    if render then 
        update_screen_effect_texture() 
    end

    -- Loop to create the blur effect
    for i = 1, depth do
        -- Calculate the blur amount for the current iteration
        local blurAmount = (i / depth) * intensity
        blurMaterial:SetFloat('$blur', blurAmount)
        blurMaterial:Recompute()

        -- Draw the textured rectangle with the current blur
        draw_textured_rect(-x, -y, ScrW(), ScrH())
    end
end


-- This function can be useful in various situations, such as when you want to display the number
-- of objects on the screen or when working with coordinates where integer values are needed:
function utils:Round(x)
	return x >= 0 and floor(x + 0.5) or ceil(x - 0.5)
end


-- This feature is useful when creating animations to make
-- them more natural and pleasing to look at:
function utils:Easing(x)
	return x < 0.5 and 4 * x * x * x or 1 - pow(-2 * x + 2, 3) / 2
end


-- The utils:Repeat function is designed to create a repeating list of values.
-- It accepts two parameters: val (the value to be repeated) and amount (the number of repetitions).
-- 
-- Suppose you want to create several objects in the game that have the same properties.
-- Instead of manually specifying the same value, you can use utils:Repeat:
-- 		local positions = { utils:Repeat(Vector(0, 0, 0), 5) }
-- 		This will create a table containing the same value 5 times Vector(0, 0, 0)
function utils:Repeat(val, amount)
	local args = {}
	for i = 1, amount do
		Table:Add(args, val)
	end
	return unpack(args)
end


do
    --- Function for wrapping text by character
    -- @param text: Text string for wrapping
    -- @param remainingWidth: Remaining width for wrapping
    -- @param maxWidth: Maximum width of the string
    -- @return Wrapped text and total width
    local function charWrap(text, remainingWidth, maxWidth)
        local totalWidth = 0

        return text:gsub('.', function(char)
            local charWidth = get_text_size(char)
            totalWidth = totalWidth + charWidth

            -- Wrap when the maximum width has been reached
            if (totalWidth >= remainingWidth) then
                totalWidth = charWidth -- Resetting the width for a new row
                remainingWidth = maxWidth
                return '\n' .. char
            end

            return char
        end), totalWidth
    end

    --- Function for wrapping text by words
    -- @param text: String of text to be wrapped
    -- @param font: Font to be used
    -- @param maxWidth: Maximum width of the string
    -- @return Wrapped text and number of lines
    function utils:TextWrap(text, font, maxWidth, ignoreTags)
        local totalWidth = 0

        font = font or 'danlib_font_18'
        set_font(font)

        local spaceWidth = get_text_size(' ')

        -- Deletes tags if ignoreTags is set to true
        -- Note that using the utils:TextSize or utils:GetTextSize functions
        -- may cause tags to be counted as characters. In some cases this may be
        -- undesirable and interfere with both the proper display of text and the calculation of element size.
        -- It is therefore important to consider the possibility of ignoring tags when calculating text widths and sizes.
        if ignoreTags then
            text = text:gsub('{color:%s*%d+,%s*%d+,%s*%d+}', '') -- Remove colour tags
            text = text:gsub('{/color:}', '') -- Remove closing colour tag
            text = text:gsub('{font:%s*[%w_]+}', '') -- Remove font tags
            text = text:gsub('{/font:}', '') -- Remove closing font tag
        end

        return text:gsub('(%s?[%S]+)', function(word)
            local char = word:sub(1, 1)

            if (char == '\n' or char == '\t') then totalWidth = 0 end

            local wordWidth = get_text_size(word)
            totalWidth = totalWidth + wordWidth

            -- A wrapper if the word is too long
            if (wordWidth >= maxWidth) then
                local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordWidth), maxWidth)
                totalWidth = splitPoint
                return splitWord
            elseif (totalWidth < maxWidth) then
                return word
            end

            -- The wrapper in front of the word
            if (char == ' ') then
                totalWidth = wordWidth - spaceWidth
                return '\n' .. word:sub(2)
            end

            totalWidth = wordWidth
            return '\n' .. word
        end), select(2, text:gsub('\n', '')) + 1 -- Number of lines
    end
end


do
    --- Draws two texts on the screen
    -- @param x: X-coordinate for the text
    -- @param y: Y-coordinate for the text
    -- @param topText: The text to be displayed on top.
    -- @param topFont: Font for the top text
    -- @param topColor: Colour for the top text
    -- @param bottomText: Text to be displayed at the bottom
    -- @param bottomFont: Font for bottom text
    -- @param bottomColor: Colour for the bottom text
    -- @param alignment: Text alignment (left by default)
    -- @param centerSpacing: Adjust the distance between two texts
    -- @param maxWidth: Maximum width for the text (optional)
    function utils:DrawDualText(x, y, topText, topFont, topColor, bottomText, bottomFont, bottomColor, alignment, centerSpacing, maxWidth)
        topFont = topFont or 'danlib_font_20'
        topColor = topColor or Color(0, 127, 255, 255)
        bottomFont = bottomFont or 'danlib_font_18'
        bottomColor = bottomColor or color_white
        alignment = alignment or TEXT_ALIGN_LEFT
        centerSpacing = centerSpacing or 0

        -- Function for trimming text with addition '...'
        local function truncateText(text, font, maxWidth)
            -- If maxWidth is not set, return the text unchanged
            if (maxWidth == nil) then return text end

            local textWidth = self:TextSize(text, font).w
            if (textWidth <= maxWidth) then
                return text
            else
                local ellipsis = '...'
                local ellipsisWidth = self:TextSize(ellipsis, font).w
                local truncatedText = text

                -- Delete characters until the text is smaller than maxWidth
                while self:TextSize(truncatedText, font).w + ellipsisWidth > maxWidth do
                    truncatedText = truncatedText:sub(1, -2) -- Delete the last character
                end

                return truncatedText .. ellipsis
            end
        end

        -- Text cropping if maxWidth is set
        topText = truncateText(topText, topFont, maxWidth)
        bottomText = truncateText(bottomText, bottomFont, maxWidth)

        -- Returns the height
        local topHeight = self:TextSize(topText, topFont).h
        local bottomHeight = self:TextSize(bottomText, bottomFont).h

        -- Centre text vertically
        local totalHeight = topHeight + bottomHeight + centerSpacing
        local topY = y - (totalHeight / 2) -- Top text
        local bottomY = topY + topHeight + centerSpacing -- Lower text

        draw_text(topText, topFont, x, topY, topColor, alignment)
        draw_text(bottomText, bottomFont, x, bottomY, bottomColor, alignment)
    end


    --- Draws two texts on the screen without truncation
    -- @param x: X-coordinate for the text
    -- @param y: Y-coordinate for the text
    -- @param topText: The text to be displayed on top.
    -- @param topFont: Font for the top text
    -- @param topColor: Colour for the top text
    -- @param bottomText: Text to be displayed at the bottom
    -- @param bottomFont: Font for bottom text
    -- @param bottomColor: Colour for the bottom text
    -- @param alignment: Text alignment (left by default)
    -- @param centerSpacing: Adjust the distance between two texts
    -- @param maxWidth: Maximum width for the text (optional)
    function utils:DrawDualTextWrap(x, y, topText, topFont, topColor, bottomText, bottomFont, bottomColor, alignment, centerSpacing, maxWidth)
        x = x or 0
        y = y or 0
        topFont = topFont or 'danlib_font_20'
        topColor = topColor or Color(0, 127, 255, 255)
        bottomFont = bottomFont or 'danlib_font_18'
        bottomColor = bottomColor or color_white
        alignment = alignment or TEXT_ALIGN_LEFT
        centerSpacing = centerSpacing or 0

        -- Text processing without cropping
        bottomText = self:TextWrap(bottomText, bottomFont, maxWidth)

        -- Height revert
        local topHeight = self:TextSize(topText, topFont).h
        local bottomHeight = self:TextSize(bottomText, bottomFont).h

        -- Centre text vertically
        local totalHeight = topHeight + bottomHeight + centerSpacing
        local topY = y - (totalHeight / 2) -- Top text
        local bottomY = topY + topHeight + centerSpacing -- Lower text

        draw_text(topText, topFont, x, topY, topColor, alignment)
        draw_text(bottomText, bottomFont, x, bottomY, bottomColor, alignment)
    end


    --- Draws multicoloured text with word hyphenation
    -- @source https://github.com/Be1zebub/Small-GLua-Things/blob/master/multicolor-text.lua
    -- @param x: X-coordinate for text
    -- @param y: Y-coordinate for text
    -- @param font: Font for text
    -- @param text: Table containing text segments (lines or colours)
    -- @param maxWidth: The maximum width of the text before moving it.
    -- @return: New x and y coordinates after drawing the text
    function utils:DrawMultiColorText(x, y, font, text, maxWidth)
        set_text_color(255, 255, 255)
        set_text_pos(x, y)

        local baseX = x
        local w, h = self:GetTextSize('W', font)
        local lineHeight = h
        if (maxW and x > 0) then maxW = maxW + x end

        for _, v in ipairs(text) do
            if isstring(v) then
                w, h = self:GetTextSize(v, font)
                if (maxW and x + w > maxW) then
                    v:gsub('(%s?[%S]+)', function(word)
                        w, h = self:GetTextSize(word, font)
                        if (x + w >= maxW) then
                            x, y = baseX, y + lineHeight
                            word = word:gsub('^%s+', '')
                            w, h = self:GetTextSize(word, font)

                            if (x + w >= maxW) then
                                word:gsub('[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*', function(char)
                                    w, h = self:GetTextSize(char, font)
                                    if (x + w >= maxW) then x, y = baseX, y + lineHeight end

                                    set_text_pos(x, y)
                                    surface.DrawText(char)
                                    x = x + w
                                end)
                                return
                            end
                        end

                        set_text_pos(x, y)
                        surface.DrawText(word)
                        x = x + w
                    end)
                else
                    set_text_pos(x, y)
                    surface.DrawText(v)
                    x = x + w
                end
            else
                set_text_color(v.r, v.g, v.b, v.a)
            end
        end

        return x, y
    end


    --- Draws text with an accompanying icon for added visual appeal.
    -- @param text (string): The text to display.
    -- @param font (string): The font to use (optional).
    -- @param ColorText (Color): The color of the text (optional).
    -- @param icon (string or Material): The icon to display (optional).
    -- @param size (number): The size of the icon (optional).
    -- @param ColorIcon (Color): The color of the icon (optional).
    -- @param x (number): The x-coordinate for positioning.
    -- @param y (number): The y-coordinate for positioning.
    -- @param AlignX (number): The horizontal alignment (optional).
    -- @param AlignY (number): The vertical alignment (optional).
    function utils:DrawIconText(text, font, ColorText, icon, size, ColorIcon, x, y, AlignX, AlignY)
        font = font or 'danlib_font_20'
        size = size or 18

        local ColorDefault = color_white
        ColorText = ColorText or ColorDefault
        ColorIcon = ColorIcon or ColorDefault

        local w, h = self:GetTextSize(text, font)

        if icon then
            if (AlignX == TEXT_ALIGN_LEFT) then
                simple_text(text, font, size + x, y, ColorText, AlignX, AlignY)
                self:DrawIconOrMaterial(x, y * 0.5, size, icon, ColorIcon)
            elseif (AlignX == TEXT_ALIGN_RIGHT) then
                simple_text(text, font, x - size + 16, y, ColorText, AlignX, AlignY)
                self:DrawIconOrMaterial(x, y * 0.5, size, icon, ColorIcon)
            else
                simple_text(text, font, x + (size / 2) + 20, y, ColorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                self:DrawIconOrMaterial(x - w + (x / w), y - 20, size, icon, ColorIcon)
            end
        else
            simple_text(text, font, x, y, ColorText, AlignX, AlignY)
        end
    end


    --- Draws two pieces of text with customizable fonts, colors, and alignment.
    -- @param tText1: The first text string to be drawn.
    -- @param fFont1: The font used for the first text. Defaults to 'danlib_font_18'.
    -- @param cColor1: The color of the first text. Defaults to white (255, 255, 255, 255).
    -- @param tText2: The second text string to be drawn.
    -- @param fFont2: The font used for the second text. Defaults to 'danlib_font_18'.
    -- @param cColor2: The color of the second text. Defaults to white (255, 255, 255, 255).
    -- @param x: The x-coordinate for positioning the text.
    -- @param y: The y-coordinate for positioning the text.
    -- @param alignx: Horizontal alignment of the text (e.g., TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER).
    -- @param aligny: Vertical alignment of the text (not utilized in this function but can be included for future use).
    function utils:DrawSomeText(tText1, fFont1, cColor1, tText2, fFont2, cColor2, x, y, alignx, aligny)
        -- Set default font and color
        local FontDefault = 'danlib_font_18'
        fFont1 = fFont1 or FontDefault
        fFont2 = fFont2 or FontDefault

        local ColorDefault = color_white
        cColor1 = cColor1 or ColorDefault
        cColor2 = cColor2 or ColorDefault

        -- Get the width of both texts
        local w1 = self:TextSize(tText1, fFont1).w
        local w2 = self:TextSize(tText2, fFont2).w

        -- Draw the first text based on the alignment
        draw_text(tText1, fFont1, x, y, cColor1, alignx, aligny)

        -- Calculate the position for the second text based on alignment
        local offsetX = 4  -- Space between the texts
        if (alignx == TEXT_ALIGN_LEFT) then
            x = x + w1 + offsetX
        elseif (alignx == TEXT_ALIGN_RIGHT) then
            x = x - w2 - offsetX
        else  -- Center alignment
            x = x + (w1 + w2) * 0.5 + offsetX
        end

        -- Draw the second text
        draw_text(tText2, fFont2, x, y, cColor2, alignx, aligny)
    end
end


--- Calculates the inverse linear interpolation of a value within a range.
-- @param number pos The position to interpolate.
-- @param number p1 The start of the range.
-- @param number p2 The end of the range.
-- @return number The normalized value between 0 and 1, or 1 if range is zero.
function utils:InverseLerp(pos, p1, p2)
	local range = 0
	range = p2 - p1

	if (range == 0) then return 1 end
	return ((pos - p1) / range)
end


--- Draws a loading animation with circles.
-- @param number w The width of the area to draw in.
-- @param number h The height of the area to draw in.
-- @param Color color The color of the circles (optional).
function utils:DrawLoad(w, h, color)
	color = color or DanLib.Config.Theme['Blue']
	local mat = Material('vgui/circle')

    for i = 0, 3 do
        -- Set the drawing color and material
        draw_color(color)
        set_material(mat)

        -- Calculate the position and draw the textured rectangle
        local x = w * 0.5 - i * 16 + 12
        local y = h * 0.5 + 4 - 8 - clamp(sin((CurTime() - 0.2 * i) * 4), 0, 1) * 25
        draw_textured_rect(x, y, 16, 16)
    end
end


do
    --- Safely formats text for drawing.
    -- @param text (string): The text to format.
    -- @return (string): The formatted text, or the original text if not matching.
    -- @source: https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_drawfunctions.lua
    local function safeText(text)
        return match(text, '^#([a-zA-Z_]+)$') and text .. ' ' or text
    end


    --- Draws non-parsed text on the screen.
    -- @param text (string): The text to draw.
    -- @param font (string): The font to use.
    -- @param x (number): The x-coordinate.
    -- @param y (number): The y-coordinate.
    -- @param color (Color): The color of the text.
    -- @param xAlign (number): The horizontal alignment.
    function utils:DrawNonParsedText(text, font, x, y, color, xAlign)
        return draw_text(safeText(text), font, x, y, color, xAlign)
    end
end


--- Draws an outline around a rectangle.
-- @param x (number): The x-coordinate of the rectangle.
-- @param y (number): The y-coordinate of the rectangle.
-- @param w (number): The width of the rectangle.
-- @param h (number): The height of the rectangle.
-- @param color (Color): The color of the outline (optional).
function utils:DrawOutline(x, y, w, h, color)
	color = color or color_white
    local intSize = w / 13
    draw_color(color)
    draw_rect(x, y, intSize, 1) -- Top
    draw_rect(x, y, 1, intSize) -- Left
    draw_rect(x + w - intSize, y + h - 1, intSize, 1) -- Bottom
    draw_rect(x + w - 1, y + h - intSize, 1, intSize) -- Right
end


--- Draws a rectangle with an outline.
-- @param x (number): The x-coordinate of the rectangle.
-- @param y (number): The y-coordinate of the rectangle.
-- @param w (number): The width of the rectangle.
-- @param h (number): The height of the rectangle.
-- @param color (Color) The color of the rectangle (optional).
-- @param number width The width of the outline (optional).
function utils:OutlinedRect(x, y, w, h, color, width)
	draw_color(color or color_white)
    draw_outlined_rect(x or 0, y or 0, w or 0, h or 0)
end


--- Gets the size of the specified text in the given font.
-- @param text (string): The text to measure.
-- @param font (string): The font to use (optional).
-- @return table: A table containing the width and height of the text.
function utils:GetTextSize(text, font)
    text = text or 'No data'
    font = font or 'danlib_font_22'
    set_font(font)
    return get_text_size(text)
end


--- Returns the width and height of the specified text in the given font.
-- @param text (string): The text to measure.
-- @param font (string): The font to use (optional).
-- @return table A table with width (w) and height (h) of the text.
function utils:TextSize(text, font)
    font = font or 'danlib_font_20'
    set_font(font)
    local width, height = get_text_size(text)
    return { w = width, h = height }
end


--- Draws a filled rectangle.
-- @param x (number): The x-coordinate of the rectangle.
-- @param y (number): The y-coordinate of the rectangle.
-- @param w (number): The width of the rectangle.
-- @param h (number): The height of the rectangle.
-- @param color (Color): The color of the rectangle (optional).
function utils:DrawRect(x, y, w, h, color)
	color = color or color_white
	draw_color(color)
	draw_rect(x, y, w, h)
end


--- Draws a line between two points.
-- @param x (number): The starting x-coordinate.
-- @param y (number): The starting y-coordinate.
-- @param eX (number): The ending x-coordinate.
-- @param eY (number): The ending y-coordinate.
-- @param color (Color): The color of the line (optional).
function utils:DrawLine(x, y, eX, eY, color)
	color = color or color_white

	draw_color(color)
	draw_line(x, y, eX, eY)
end


do
    -- Set the standard rounding value
    local defaultRoundness = 6


    --- Function to draw a rounded box with the ability to adjust the rounding of the corners
    -- @param x: X-coordinate of the top left corner
    -- @param y: Y-coordinate of the upper left corner
    -- @param w: Width of box
    -- @param h: Height of box
    -- @param colour: Box colour
    -- @param roundTopLeft: Indicates whether the top left corner should be rounded or not
    -- @param roundTopRight: Indicates whether the top right corner should be rounded or not.
    -- @param roundBottomLeft: Indicates if the bottom left corner should be rounded.
    -- @param roundBottomRight: Indicates whether to round the bottom right corner
    local function draw_rounded_box_ex(x, y, w, h, color, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
        -- Limit the rounding value so that it does not exceed half of the height
        local roundness = clamp(defaultRoundness, 0, h * 0.5)

        -- Checking for zero value of width or height
        if (w <= 0 or h <= 0) then return end

        -- If rounding is not required, draw a rectangle
        if (roundness == 0) then
            draw_color(color)
            draw_rect(x, y, w, h)
        else
            -- Drawing a rounded rectangle
            rounded_box_ex(roundness, x, y, w, h, color, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
        end
    end


    --- Simplified function for drawing a fully rounded box
    -- @param x: X-coordinate of the top left corner
    -- @param y: Y-coordinate of the top left corner
    -- @param w: Width of the box
    -- @param h: Height of box
    -- @param colour: Box colour
    function utils:DrawRoundedBox(x, y, w, h, color)
        -- Draw a rounded box with fully rounded corners
        draw_rounded_box_ex(x, y, w, h, color, true, true, true, true)
    end


    --- Function to draw a box with only the top corners rounded
    -- @param x: X-coordinate of the top left corner
    -- @param y: Y-coordinate of the top left corner
    -- @param w: Width of the box
    -- @param h: Height of the box
    -- @param colour: Box colour
    function utils:DrawRoundedTopBox(x, y, w, h, color)
        -- Draw a box with only the top corners rounded
        draw_rounded_box_ex(x, y, w, h, color, true, true, false, false)
    end


    --- Function to draw a box with only the bottom corners rounded
    -- @param x: X-coordinate of the top left corner
    -- @param y: Y-coordinate of the top left corner
    -- @param w: Width of the box
    -- @param h: Height of the box
    -- @param colour: Box colour
    function utils:DrawRoundedBottomBox(x, y, w, h, color)
        -- Draw a box with only the bottom corners rounded
        draw_rounded_box_ex(x, y, w, h, color, false, false, true, true)
    end


    --- Function to draw a box with only the left corners rounded
    -- @param x: X-coordinate of the top left corner
    -- @param y: Y-coordinate of the top left corner
    -- @param w: Width of the box
    -- @param h: Height of the box
    -- @param colour: Box colour
    function utils:DrawRoundedLeftBox(x, y, w, h, color)
        -- Draw a box with only the left corners rounded
        draw_rounded_box_ex(x, y, w, h, color, true, false, true, false)
    end


    --- Function to draw a box with only the right corners rounded
    -- @param x: X-coordinate of the top left corner
    -- @param y: Y-coordinate of the top left corner
    -- @param w: Width of the box
    -- @param h: Height of the box
    -- @param colour: Box colour
    function utils:DrawRoundedRightBox(x, y, w, h, color)
        -- Draw a box with only the right corners rounded
        draw_rounded_box_ex(x, y, w, h, color, false, true, false, true)
    end
end


--- Draws a polygon on the screen.
-- @param vertices: A table of vertices defining a polygon. Each vertex must be represented as a table with coordinates {x, y}.
-- @param color: The colour of the polygon. The default colour is white (255, 255, 255, 255, 255).
function utils:DrawPoly(vertices, color)
	-- Set the default colour if not passed in
	color = color or color_white

	-- Check that the vertex table is not empty and contains at least one vertex
	if (vertices and #vertices > 0) then
		-- Turning off the texture for rendering
		no_texture()
		-- Set the colour for rendering
		draw_color(color)
		-- Draw a polygon using an array of vertices
		draw_poly(vertices)
	end
end


do
    --- Draws a material at a specified position with optional rotation.
    -- @param x (number): The x-coordinate of the material.
    -- @param y (number): The y-coordinate of the material.
    -- @param w (number): The width of the material.
    -- @param h (number): The height of the material.
    -- @param color (Color): The color of the material (optional).
    -- @param mat (Material): The material to draw (optional).
    -- @param ang (number): The angle for rotation (optional).
    function utils:DrawMaterial(x, y, w, h, color, mat, ang)
        color = color or color_white
        mat = mat or Material('error')

        draw_color(color)
        set_material(mat)
        
        if ang then
            draw_textured_rect_rotated(x, y, w, h, ang)
        else
            draw_textured_rect(x, y, w, h)
        end
    end


    --- Draws an icon or material based on the provided parameters.
    -- @param x (number): The x-coordinate for drawing.
    -- @param y (number): The y-coordinate for drawing.
    -- @param size (number): The size of the icon/material.
    -- @param strIcon (string|Material): The icon or material to draw.
    -- @param strIconCol (Color): The color of the icon/material (optional).
    function utils:DrawIconOrMaterial(x, y, size, strIcon, strIconCol)
        if isstring(strIcon) then
            self:DrawIcon(x, y, size, size, strIcon, strIconCol or base:Theme('mat', 200))
        else
            self:DrawMaterial(x, y, size, size, strIconCol or base:Theme('mat', 200), strIcon)
        end
    end
end


do
    --- Sets the parameters for the operation of the cStepsil.
    -- @param stencilValue: Value for stencil, defaults to 1.
    local function SetupStencil(stencilValue)
        set_stencil_write_mask(1)
        set_stencil_test_mask(1)
        set_stencil_fail_operation(STENCILOPERATION_REPLACE)
        set_stencil_pass_operation(STENCILOPERATION_ZERO)
        set_stencilZ_fail_operation(STENCILOPERATION_ZERO)
        set_stencil_compare_function(STENCILCOMPARISONFUNCTION_NEVER)
        set_stencil_reference_value(stencilValue)
    end


    --- Performs operations on the mask and draw function.
    -- @param mask: Function for drawing a mask.
    -- @param func: Function for rendering in the mask area.
    -- @param stencil: Value for stencil, defaults to 1.
    function utils:DrawMask(mask, func, stencil)
    	-- Use the default value if not passed.
        stencil = stencil or 1

        clear_stencil()
        set_stencil_enable(true)

        -- Customising the stencil for the mask.
        SetupStencil(stencil)

	        -- Drawing the mask.
	        draw_color(color_white)
	        no_texture()
	        mask()

        -- Set parameters for drawing inside the mask.
        set_stencil_fail_operation(STENCILOPERATION_ZERO)
        set_stencil_pass_operation(STENCILOPERATION_REPLACE)
        set_stencilZ_fail_operation(STENCILOPERATION_ZERO)
        set_stencil_compare_function(STENCILCOMPARISONFUNCTION_EQUAL)
        set_stencil_reference_value(stencil)

	        -- We perform drawing in the mask area.
	        func()

        set_stencil_enable(false)
        -- Clearing the stencil.
        clear_stencil()
    end


    --- Performs operations with the inverse mask and draw function.
    -- @param maskFn: Function for drawing the mask.
    -- @param drawFn: Function for rendering in the inverse region of the mask.
    function utils:DrawMaskInverse(maskFn, drawFn)
        clear_stencil()
        set_stencil_enable(true)
        depth_range(0, 1)

	        -- Customising the stencil for the mask.
	        SetupStencil(1)
	        -- Drawing the mask.
	        maskFn()

        -- Set parameters for drawing outside the mask.
        set_stencil_fail_operation(STENCILOPERATION_REPLACE)
        set_stencil_pass_operation(STENCILOPERATION_REPLACE)
        set_stencilZ_fail_operation(STENCILOPERATION_ZERO)
        set_stencil_compare_function(STENCILCOMPARISONFUNCTION_EQUAL)
        set_stencil_reference_value(0)

        	-- We perform drawing in the inverse region of the mask.
        	drawFn()

        depth_range(0, 1)
        set_stencil_enable(false)
        -- Clearing the stencil.
        clear_stencil()
    end
end


do
    -- Gradient helper functions
    -- By Bo Anderson
    -- Licensed under Mozilla Public License v2.0

    --[[
    Test scripts:
        lua_run_cl hook.Add("HUDPaint", "test", function() utils:DrawLinearGradient(100, 200, 100, 100, Color(255, 0, 0), Color(255, 255, 0), false) utils:DrawLinearGradient(250, 200, 100, 100, Color(0, 255, 0), Color(0, 0, 255), true) end)
        lua_run_cl hook.Add("HUDPaint", "test2", function() utils:DrawLinearGradient(100, 350, 100, 100, Color(255, 255, 255), Color(0, 0, 0), true) utils:DrawLinearGradient(250, 350, 100, 100, Color(0, 0, 0, 255), Color(0, 0, 0, 0), false) end)
        lua_run_cl hook.Add("HUDPaint", "test3", function() utils:VerticalGradient(100, 500, 100, 100, { {offset = 0, color = Color(255, 0, 0)}, {offset = 0.5, color = Color(255, 255, 255)}, {offset = 1, color = Color(0, 255, 0)} }, false) end)
        lua_run_cl hook.Add("HUDPaint", "test4", function() utils:VerticalGradient(250, 500, 100, 100, { {offset = 0, color = Color(0, 0, 255)}, {offset = 0.5, color = Color(255, 255, 0)}, {offset = 1, color = Color(255, 0, 0)} }, true) end)
    ]]

    local mat_white = Material('vgui/white')

    --[[
        The stops argument is a table of GradientStop structures.
        Example:
            utils:DrawLinearGradient(0, 0, 100, 100, {
                {offset = 0, color = Color(255, 0, 0)},
                {offset = 0.5, color = Color(255, 255, 0)},
                {offset = 1, color = Color(255, 0, 0)}
            }, false)
        == GradientStop structure ==
        Field  |  Type  | Description
        ------ | ------ | ---------------------------------------------------------------------------------------
        offset | number | Where along the gradient should this stop occur, scaling from 0 (beginning) to 1 (end).
        color  | table  | Color structure of what color this stop should be.
    ]]
    function utils:DrawLinearGradient(x, y, w, h, stops)
        if (#stops == 0) then
            return
        elseif (#stops == 1) then
            draw_color(stops[1].color)
            draw_rect(x, y, w, h)
            return
        end

        sortByMember(stops, 'offset', true)

        rmaterial(mat_white)
        mesh_begin(MATERIAL_QUADS, #stops - 1)
        for i = 1, #stops - 1 do
            local offset1 = clamp(stops[i].offset, 0, 1)
            local offset2 = clamp(stops[i + 1].offset, 0, 1)

            if (offset1 == offset2) then continue end

            local deltaX1, deltaY1, deltaX2, deltaY2
            local color1 = stops[i].color
            local color2 = stops[i + 1].color

            local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
            local r2, g2, b2, a2
            local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a
            local r4, g4, b4, a4

            r2, g2, b2, a2 = r3, g3, b3, a3
            r4, g4, b4, a4 = r1, g1, b1, a1
            deltaX1 = offset1 * w
            deltaY1 = 0
            deltaX2 = offset2 * w
            deltaY2 = h

            mesh_color(r1, g1, b1, a1)
            mesh_position(Vector(x + deltaX1, y + deltaY1))
            mesh_advanceVertex()

            mesh_color(r2, g2, b2, a2)
            mesh_position(Vector(x + deltaX2, y + deltaY1))
            mesh_advanceVertex()

            mesh_color(r3, g3, b3, a3)
            mesh_position(Vector(x + deltaX2, y + deltaY2))
            mesh_advanceVertex()

            mesh_color(r4, g4, b4, a4)
            mesh_position(Vector(x + deltaX1, y + deltaY2))
            mesh_advanceVertex()
        end
        mesh_end()
    end

    --- You can draw vertical gradients with the function above, however,
    --- The type of vertical I want kinda differs from what is already made,
    --- So instead of messing with the function above(since I use it in a lot of places)
    --- I just altered the formula with the function below instead.
    function utils:VerticalGradient(x, y, w, h, stops)
        if (#stops == 0) then
            return
        elseif (#stops == 1)then
            draw_color(stops[1].color)
            draw_rect(x, y, w, h)
            return
        end

        sortByMember(stops, 'offset', true)

        rmaterial(mat_white)
        mesh_begin(MATERIAL_QUADS, #stops - 1)
        for i = 1, #stops - 1 do
            local offset1 = clamp(stops[i].offset, 0, 1)
            local offset2 = clamp(stops[i + 1].offset, 0, 1)

            if (offset1 == offset2) then continue end

            local deltaX1, deltaY1, deltaX2, deltaY2
            local color1 = stops[i].color
            local color2 = stops[i + 1].color

            local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
            local r2, g2, b2, a2
            local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a
            local r4, g4, b4, a4

            r2, g2, b2, a2 = r1, g1, b1, a1
            r4, g4, b4, a4 = r3, g3, b3, a3

            deltaX1 = offset1 * w
            deltaY1 = 0
            deltaX2 = offset2 * w
            deltaY2 = h

            mesh_color(r1, g1, b1, a1)
            mesh_positionmesh_position(Vector(x + deltaX1, y + deltaY1))
            mesh_advanceVertex()

            mesh_color(r2, g2, b2, a2)
            mesh_positionmesh_position(Vector(x + deltaX2, y + deltaY1))
            mesh_advanceVertex()

            mesh_color(r3, g3, b3, a3)
            mesh_positionmesh_position(Vector(x + deltaX2, y + deltaY2))
            mesh_advanceVertex()

            mesh_color(r4, g4, b4, a4)
            mesh_positionmesh_position(Vector(x + deltaX1, y + deltaY2))
            mesh_advanceVertex()
        end
        mesh_end()
    end


    --- Creates a simple linear gradient.
    -- @param x: X coordinate of the upper left corner of the gradient.
    -- @param y: Y coordinate of the upper left corner of the gradient.
    -- @param w: The width of the gradient.
    -- @param h: The height of the gradient.
    -- @param startColor: The starting colour of the gradient.
    -- @param endColor: The final colour of the gradient.
    -- @param horizontal: Gradient direction (horizontal if true).
    -- @param material: The material used for rendering.
    function utils:SimpleLinearGradient(x, y, w, h, startColor, endColor, horizontal, material)
        DanLib.LinearGradient(x, y, w, h, {
            { offset = 0, color = startColor },
            { offset = 1, color = endColor }
        }, horizontal, material)
    end


    -- Obtain the white coloured material used in the GUI.
    -- This material is often used as a base background or to create gradients.
    local mat_white = Material('vgui/white')


    --- Draws a linear gradient.
    -- @param x: X coordinate of the upper left corner of the gradient.
    -- @param y: Y coordinate of the upper left corner of the gradient.
    -- @param w: The width of the gradient.
    -- @param h: The height of the gradient.
    -- @param steps: A table of gradient steps containing the colours and their offsets.
    -- @param horizontal: Gradient direction (horizontal if true).
    -- @param material: The material used for rendering.
    function utils:LinearGradient(x, y, w, h, steps, horizontal, material)
        if (#steps == 0) then return end

        if (#steps == 1) then
            draw_color(steps[1].color)
            draw_rect(x, y, w, h)
            return
        end

        rmaterial(material or mat_white)
        mesh_begin(MATERIAL_QUADS, #steps - 1)

        for i = 1, #steps - 1 do
            local offset1 = clamp(steps[i].offset, 0, 1)
            local offset2 = clamp(steps[i + 1].offset, 0, 1)

            -- Skip iteration if the offsets are equal to
            if (offset1 == offset2) then
                -- Just continuing on to the next iteration
                -- This can be done by simply skipping the rest of the code
            else
                local deltaX1, deltaY1, deltaX2, deltaY2
                local color1, color2 = steps[i].color, steps[i + 1].color

                -- Retrieve colour values once
                local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
                local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a

                if horizontal then
                    deltaX1, deltaY1 = offset1 * w, 0
                    deltaX2, deltaY2 = offset2 * w, h
                else
                    deltaX1, deltaY1 = 0, offset1 * h
                    deltaX2, deltaY2 = w, offset2 * h
                end

                mesh_color(r1, g1, b1, a1)
                mesh_position(Vector(x + deltaX1, y + deltaY1))
                mesh_advanceVertex()

                mesh_color(r3, g3, b3, a3)
                mesh_position(Vector(x + deltaX2, y + deltaY1))
                mesh_advanceVertex()

                mesh_color(steps[i + 1].color.r, steps[i + 1].color.g, steps[i + 1].color.b, steps[i + 1].color.a)
                mesh_position(Vector(x + deltaX2, y + deltaY2))
                mesh_advanceVertex()

                mesh_color(steps[i].color.r, steps[i].color.g, steps[i].color.b, steps[i].color.a)
                mesh_position(Vector(x + deltaX1, y + deltaY2))
                mesh_advanceVertex()
            end
        end

        mesh_end()
    end


    -- Obtain a texture for corners with a radius of 8 pixels.
    -- This texture is used to create rounded corners in the interface.
    local tex_corner8 = draw_texture_id('gui/corner8')
    -- Obtain a texture for corners with a radius of 16 pixels.
    -- This texture is used to create wider rounded corners in the interface.
    local tex_corner16 = draw_texture_id('gui/corner16')


    --- Draws a rounded gradient.
    -- @param panel: The panel to which the gradient is applied.
    -- @param bordersize: The size of the borders.
    -- @param x: X coordinate of the top left corner.
    -- @param y: Y coordinate of the top left corner.
    -- @param w: Width of the area.
    -- @param h: Height of the area.
    -- @param colour1: First colour of the gradient.
    -- @param colour2: Second gradient colour.
    function utils:DrawRoundedGradient(panel, bordersize, x, y, w, h, color1, color2)
        x, y, w, h = round(x), round(y), round(w), round(h)
        bordersize = min(round(bordersize), floor(w / 2))

        local lx, ly = IsValid(panel) and panel:LocalToScreen(x, y) or x, y

        self:DrawLinearGradient(lx + bordersize, ly, w - bordersize * 2, h, {
            { offset = 0, color = color1 },
            { offset = 1, color = color2 }
        })

        set_text_color(color1)
        draw_rect(x, y + bordersize, bordersize, h - bordersize * 2)

        set_text_color(color2)
        draw_rect(x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2)

        local tex = bordersize > 8 and tex_corner16 or tex_corner8
        draw_texture(tex)
        draw_textured_rect_uv(x + w - bordersize, y, bordersize, bordersize, 1, 0, 0, 1)
        draw_textured_rect_uv(x + w - bordersize, y + h - bordersize, bordersize, bordersize, 1, 1, 0, 0)

        draw_color(color1)
        draw_textured_rect_uv(x, y, bordersize, bordersize, 0, 0, 1, 1)
        draw_textured_rect_uv(x, y + h - bordersize, bordersize, bordersize, 0, 1, 1, 0)
    end


    -- @param x (nember): The X integer coordinate.
    -- @param y (nember): The Y integer coordinate.
    -- @param width (nember): The integer width of the rectangle.
    -- @param height (nember): The integer height of the rectangle.
    -- @param startU (nember): The U texture mapping of the rectangle origin.
    -- @param startV (nember): The V texture mapping of the rectangle origin.
    -- @param endU (nember): The U texture mapping of the rectangle end.
    -- @param endV (nember): The V texture mapping of the rectangle end.
    function utils:DrawTextureGradient(x, y, width, height, startU, startV, endU, endV, color, texture)
        color = color or base:Theme('secondary_dark')
        texture = texture or 'vgui/alpha-back'

        draw_texture(draw_texture_id(texture))
        draw_color(color)
        draw_textured_rect_uv(x, y, width, height, startU, startV, endU, endV)
    end


    --- Draws a gradient rectangle on the screen.
    -- @param x (number) X-axis position.
    -- @param y (number) Y-axis position.
    -- @param w (number) Width of the rectangle.
    -- @param h (number) Height of the rectangle.
    -- @param dir (string) Gradient direction ('BOTTOM', 'LEFT', 'RIGHT', 'TOP').
    -- @param colour (Color) The colour of the gradient (white by default).
    function utils:DrawGradient(x, y, w, h, dir, color)
        color = color or color_white -- Set default colour if not specified

        -- Define a table for comparing gradient directions and materials
        local gradientMaterials = {
            [BOTTOM] = DanLib.Config.Materials['grad_u'],
            [LEFT] = DanLib.Config.Materials['grad_l'],
            [RIGHT] = DanLib.Config.Materials['grad_r'],
        }

        -- Get a gradient material depending on the direction, or use the default value
        local gradient = gradientMaterials[dir] or DanLib.Config.Materials['grad_d']

        -- Drawing the gradient material
        self:DrawMaterial(x, y, w, h, color, gradient)
    end
end


do
	--- Draws a circle on the screen.
	-- @param sx: The X-coordinate of the centre of the circle.
	-- @param sy: The Y-coordinate of the center of the circle.
	-- @param radius: The radius of the circle.
	-- @param seg: The number of segments to draw the circle. The default value is 30.
	-- @param color: The colour of the circle. The default colour is white.
	-- @param angle: The angle of rotation of the circle in radians. The default value is 0.
	-- @return: Table with the coordinates of the vertices of the circle.
	function utils:DrawCircle(sx, sy, radius, seg, color, angle)
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


	--- Calculates the coordinates of the vertices of the circle.
	-- @param sx: The X-coordinate of the centre of the circle.
	-- @param sy: The Y-coordinate of the center of the circle.
	-- @param radius: The radius of the circle.
	-- @param seg: The number of segments to calculate the circle. The default value is 30.
	-- @param angle: The angle of rotation of the circle in radians. The default value is 0.
	-- @return: Table with the coordinates of the vertices of the circle.
	function utils:CalculateCircle(sx, sy, radius, seg, angle)
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

	    -- Return the table with the vertices of the circle
	    return cir
	end


	--- Draws an arc on the screen.
	-- @param x: The X-coordinate of the arc centre.
	-- @param y: The Y-coordinate of the arc center.
	-- @param ang: Angle of arc origin in degrees.
	-- @param p: Arc length in degrees.
	-- @param rad: Radius of arc.
	-- @param color: Arc colour. The default colour is white.
	-- @param seg: The number of segments to draw the arc. The default value is 80.
	-- @source: TDLib https://github.com/Threebow/tdlib/blob/master/tdlib.lua#L39
	function utils:DrawArcT(x, y, ang, p, rad, color, seg)
		-- Set the default number of segments
	    seg = seg or 80
	    -- Set the default colour
	    color = color or color_white
	    -- Correcting the angle
	    ang = (-ang) + 180
	    local circle = {}

	    -- Add the starting point of the arc
	    Table:Add(circle, { x = x, y = y })

	    -- Arc point generation
	    for i = 0, seg do
	        local a = rad((i / seg) * -p + ang)
	        Table:Add(circle, { x = x + sin(a) * rad, y = y + cos(a) * rad })
	    end

	    -- Set the colour and disable the texture for rendering
        no_texture()
        -- Set the colour for rendering
        draw_color(color)
        -- Drawing the arc
        draw_poly(circle)
	end


    --- Draws a wedge of a circle, used for the forward FOV indicator.
    -- @param x (number): The x-coordinate of the center of the wedge.
    -- @param y (number): The y-coordinate of the center of the wedge.
    -- @param radius (number): The radius of the wedge.
    -- @param angle (number): The angle of the wedge in degrees.
    -- @param direction (number): The direction of the wedge in radians.
    -- @param res (number): The resolution or number of segments to create the wedge.
    -- @return (table): A table containing the points that define the wedge.
    function utils:DrawWedge(x, y, radius, angle, direction, res)
        local points = {}
        Table:Add(points, { x = x, y = y })  -- Add the center point

        local processedRes = ceil(angle * res)  -- Calculate the number of segments

        for i = 0, processedRes do
            -- Calculate the current angle in radians
            local currentAngle = rad(i * (angle / processedRes) + direction)
            -- Calculate the current point's coordinates
            local curX = x + cos(currentAngle) * radius
            local curY = y + sin(currentAngle) * radius
            Table:Add(points, { x = curX, y = curY })  -- Add the calculated point to the table
        end

        return points  -- Return the table of points
    end


    --- Draws a masked border shape at a specified position.
    -- @param xpos (number): The x-coordinate for the border.
    -- @param ypos (number): The y-coordinate for the border.
    -- @param color (Color): The color of the border (optional).
    function utils:MaskBorder(xpos, ypos, color)
        color = color or color_white

        local mask = {
            { x = xpos,  y = ypos },
            { x = xpos + 5, y = ypos + 10 },
            { x = xpos - 10, y = ypos + 45 },
            { x = xpos - 20, y = ypos + 50 },
        }
        draw_color(color)
        no_texture()
        draw_poly(mask)
    end
end


do
    local Icon, size2, ang

    -- Load the material for the icon
    base:GetMaterial('CiiJ0Kg', function(mat)
        Icon = mat
    end)


    --- Draws a loading icon at the specified position with rotation.
    -- @param x (number): The x-coordinate for the loading icon.
    -- @param y (number): The y-coordinate for the loading icon.
    -- @param size (number): The size of the loading icon.
    -- @param speed (number): The speed of the rotation (optional).
    -- @param col (Color): The color of the loading icon (optional).
    -- @param center (boolean): If true, centers the icon (optional).
    -- @param earse (boolean): If true, applies easing to the rotation (optional).
    function utils:Loading(x, y, size, speed, col, center, earse)
        -- if (loading:GetMaterial() == nil) then return end -- Ensure material is loaded

        col = col or color_white -- Default color
        speed = speed or 100 -- Default speed
        size2 = center and 0 or size * 0.5 -- Calculate offset based on centering

        -- Calculate the angle for rotation
        if earse then
            ang = easeInOut(((-CurTime() * speed) % 360) / 360, 0.5, 0.5) * 360
        else
            ang = -CurTime() % 360 * speed
        end

        -- Draw the loading icon
        draw_color(col.r, col.g, col.b, col.a)
        set_material(Icon)
        draw_textured_rect_rotated(x + size2, y + size2, size, size, ang)
    end


    --- Checks if a string is a valid URL.
    -- @param str (string): The string to check.
    -- @return (boolean): Returns true if the string is a valid URL, false otherwise.
    function base:IsURL(str)
        return str:find('https?://[%w-_%.%?%.:/%+=&]+') and true or false
    end
end


do
    --- Manipulates the given color by adjusting its hue, saturation, and value.
    -- @param color (Color): The original color to manipulate.
    -- @param deltaH (number): The change in hue (degrees, 0-360).
    -- @param deltaS (number): The change in saturation (0 to 1).
    -- @param deltaV (number): The change in value (0 to 1).
    -- @return (Color): The new color after manipulation.
    function utils:ManipulateColor(color, deltaH, deltaS, deltaV)
        -- Convert the original color to HSV
        local h, s, v = ColorToHSV(color)
        
        -- Adjust the hue, saturation, and value while clamping the results to valid ranges
        local newH = clamp(h + deltaH, 0, 360) -- Clamp hue to [0, 360]
        local newS = clamp(s + deltaS, 0, 1) -- Clamp saturation to [0, 1]
        local newV = clamp(v + deltaV, 0, 1) -- Clamp value to [0, 1]
        
        -- Convert back to color from the manipulated HSV values and return
        return HSVToColor(newH, newS, newV)
    end

    -- function utils:ManipulateColor(color, deltaH, deltaS, deltaV)
    --     local h, s, v = ColorToHSV(color)
    --     return HSVToColor(clamp(h + deltaH, 0, 360), clamp(s + deltaS, 0, 1), clamp(v + deltaV, 0, 1))
    -- end


    --- Adjusts the color values to improve visibility and returns a Color object.
    -- This function modifies the RGB values if they are below a certain threshold 
    -- to ensure they are rendered correctly in the GMod environment.
    -- @param r (number): The red component of the color (0-255).
    -- @param g (number): The green component of the color (0-255).
    -- @param b (number): The blue component of the color (0-255).
    -- @param a (number): The alpha (transparency) component of the color (0-255).
    -- @return (Color): A Color object with the adjusted values.
    function utils:UiColor(r, g, b, a)
        r = r < 90 and (0.916 * r + 7.8252) or r
        g = g < 90 and (0.916 * g + 7.8252) or g
        b = b < 90 and (0.916 * b + 7.8252) or b
        return rcolor(r, g, b, a)
    end


    --- Linear interpolation between two colours.
    -- @param frac (number) A value from 0 to 1 specifying the degree of interpolation.
    -- @param from (Color) Starting colour.
    -- @param to (Color) The final colour.
    -- @return (Color) The resulting colour after interpolation.
    function utils:LerpColor(frac, from, to)
        -- Check that the frac is between 0 and 1
        frac = clamp(frac, 0, 1)

        -- Perform linear interpolation for each colour component
        local r = lerp(frac, from.r, to.r)
        local g = lerp(frac, from.g, to.g)
        local b = lerp(frac, from.b, to.b)
        local a = lerp(frac, from.a, to.a)

        return self:UiColor(r, g, b, a)
    end


    -- @source   Link: https://pastebin.pl/view/1f4f3e55
    local colorCorrection = {
        [0] = 0, 5, 8, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
        22, -- lost 15
        23, 24, 25, 26, 27, 28,
        28, -- lost 22
        29, 30, 31, 32, 33, 34, 35,
        35, -- lost 30
        36, 37, 38, 39, 40, 41, 42,
        42, -- lost 38
        43, 44, 45, 46, 47, 48, 49, 50, 51,
        51, -- lost 48
        52, 53, 54, 55, 56, 57, 58, 59, 60,
        60, -- lost 58
        61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73,
        73, -- lost 72
        74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88,
        88, -- lost 88
        89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
        109, -- lost 110
        111,
        111, -- lost 112
        113,
        113, -- lost 114
        114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132,
        133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151,
        152, 153, 154, 155, 156, 157,
        157, -- lost 159
        158, 159, 160, 162, 163, 164, 165,
        165, -- lost 167
        167, 168,
        168, -- lost 170
        170,
        170, -- lost 172
        172,
        172, -- lost 174
        174,
        174, -- lost 176
        176, 177,
        177, -- lost 179
        178, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197,
        198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216,
        217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 236, 237,
        237, -- lost 238
        238, 239, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255
    }
     
    --- Corrects RGB values using a predefined color correction table.
    -- This function ensures that the color values are within a valid range and 
    -- applies a correction based on the colorCorrection table to enhance rendering.
    -- @param r (number): The red component of the color (0-255).
    -- @param g (number): The green component of the color (0-255).
    -- @param b (number): The blue component of the color (0-255).
    -- @param a (number): The alpha (transparency) component of the color (0-255).
    -- @return (Color): A Color object with the corrected values.
    function utils:ColorCorrected(r, g, b, a)
        r = r or 0
        g = g or 0
        b = b or 0
        a = a or 255
        return self:UiColor(colorCorrection[clamp(floor(tonumber(r)), 0, 255)], colorCorrection[clamp(floor(tonumber(g)), 0, 255)], colorCorrection[clamp(floor(tonumber(b)), 0, 255)], clamp(floor(tonumber(a)), 0, 255))
    end


    --- Converts a hexadecimal colour to a Color object
    -- @param hex (string): Hexadecimal colour (e.g., '#754fd6')
    -- @param alpha (number): Alpha channel (optional, default 255)
    -- @return Color: Color object with the corresponding values
    function utils:HexColor(hex, alpha)
        hex = hex:gsub('#', '')
        return self:UiColor(tonumber('0x'.. hex:sub(1, 2)), tonumber('0x'.. hex:sub(3, 4)), tonumber('0x'.. hex:sub(5, 6)), alpha or 255)
    end


    --- Converts RGB values to decimal representation
    -- @param r (number): Red component (0-255)
    -- @param g (number): Green component (0-255)
    -- @param b (number): Blue component (0-255)
    -- @return number: Decimal representation of colour
    --
    -- Example:
    --      local colorDecimal = base.ColorDecimal(21, 21, 21)  -- Get the decimal value of the colour
    --      local material = CreateMaterial('my_material', 'UnlitGeneric', {
    --          ['$basetexture'] = 'white',
    --          ['$color'] = colorDecimal  -- Use the decimal value of the colour
    --      })
    function utils:ColorDeciminal(r, g, b)
        r = band(lshift(r, 16), 0xFF0000)
        g = band(lshift(g, 8), 0x00FF00)
        b = band(b, 0x0000FF)
        return bor(bor(r, g), b)
    end


    --- Converts HSL to RGB
    -- @param h (number): Colour tone (0-360)
    -- @param s (number): Saturation (0-100)
    -- @param l (number): Brightness (0-100)
    -- @return number, number, number: RGB values (0-255)
    function utils:HSLtoRGB(h, s, l)
        local r, g, b

        if (s == 0) then
            r, g, b = l, l, l -- achromatic
        else
            local function hue2rgb(p, q, t)
                if (t < 0) then t = t + 1 end
                if (t > 1) then t = t - 1 end
                if (t < 1 / 6) then return p + (q - p) * 6 * t
                elseif (t < 1 / 2) then return q
                elseif (t < 2 / 3) then return p + (q - p) * (2/3 - t) * 6
                else return p
                end
            end

            local q = l < 0.5 and l * (1 + s) or l + s - l * s
            local p = 2 * l - q
            r = hue2rgb(p, q, h / 360 + 1/3)
            g = hue2rgb(p, q, h / 360)
            b = hue2rgb(p, q, h / 360 - 1/3)
        end

        return floor(r * 255), floor(g * 255), floor(b * 255)
    end


    --- Converts RGB to HSL
    -- @param r (number): Red component (0-255)
    -- @param g (number): Green component (0-255)
    -- @param b (number): Blue component (0-255)
    -- @return number, number, number: HSL values (h: 0-360, s: 0-100, l: 0-100)
    function utils:RGBtoHSL(r, g, b)
        r = r / 255
        g = g / 255
        b = b / 255

        local max = max(r, g, b)
        local min = min(r, g, b)
        local h, s, l = 0, 0, (max + min) / 2

        if (max == min) then
            h = 0 -- achromatic
        else
            local d = max - min
            s = l > 0.5 and d / (2 - max - min) or d / (max + min)
            if (max == r) then
                h = (g - b) / d + (g < b and 6 or 0)
            elseif (max == g) then
                h = (b - r) / d + 2
            elseif (max == b) then
                h = (r - g) / d + 4
            end
            h = h / 6
        end

        return floor(h * 360), floor(s * 100), floor(l * 100)
    end


    --- Converts HSV to RGB
    -- @param h (number): Colour tone (0-360)
    -- @param s (number): Saturation (0-1)
    -- @param v (number): Value (brightness) (0-1)
    -- @return number, number, number: RGB values (0-255)
    function utils:HSVtoRGB(h, s, v)
        local r, g, b
        local i = floor(h / 60) % 6
        local f = h / 60 - floor(h / 60)
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)

        if (i == 0) then
            r, g, b = v, t, p
        elseif (i == 1) then
            r, g, b = q, v, p
        elseif (i == 2) then
            r, g, b = p, v, t
        elseif (i == 3) then
            r, g, b = p, q, v
        elseif (i == 4) then
            r, g, b = t, p, v
        elseif (i == 5) then
            r, g, b = v, p, q
        end

        return floor(r * 255), floor(g * 255), floor(b * 255)
    end


    --- Converts CMYK to RGB
    -- @param c (number): Percentage of cyan (0-1)
    -- @param m (number): Percentage of magenta (0-1)
    -- @param y (number): Percent yellow (0-1)
    -- @param k (number): Percentage of black (0-1)
    -- @return number, number, number: RGB values (0-255)
    function utils:CMYKtoRGB(c, m, y, k)
        local r = 255 * (1 - c) * (1 - k)
        local g = 255 * (1 - m) * (1 - k)
        local b = 255 * (1 - y) * (1 - k)
        return r, g, b
    end


    --- Converts RGB to CMYK
    -- @param r (number): Red component (0-255)
    -- @param g (number): Green component (0-255)
    -- @param b (number): Blue component (0-255)
    -- @return number, number, number, number, number: CMYK values (c: 0-100, m: 0-100, y: 0-100, k: 0-100)
    function utils:RGBtoCMYK(r, g, b)
        local c = 1 - (r / 255)
        local m = 1 - (g / 255)
        local y = 1 - (b / 255)
        local k = min(c, min(m, y))
        
        if (k < 1) then
            c = (c - k) / (1 - k)
            m = (m - k) / (1 - k)
            y = (y - k) / (1 - k)
        else
            c, m, y = 0, 0, 0
        end

        return floor(c * 100), floor(m * 100), floor(y * 100), floor(k * 100)
    end


    --- Parses colour values from a string depending on the specified format.
    -- @param input (string): A string containing comma-separated colour values.
    -- @param type (string): The type of format to use for parsing.
    --                       Possible values are 'CMYK', 'HSV', 'HSL', 'HEX', 'RGB'.
    -- @return number, number, number, number, number, number: Returns the appropriate colour components.
    --                                                         For HEX, returns (r, g, b, a), where a is 255 (full opacity).
    --                                                         For RGB, returns (r, g, b, a) with a = 255 by default.
    --                                                         If the format is not recognised, returns (nil, nil, nil, nil, nil).
    function utils:ParseColor(input, type)
        if (type == 'CMYK') then
            local c, m, y, k = input:match('(%d+),%s*(%d+),%s*(%d+),%s*(%d+)')
            return tonumber(c), tonumber(m), tonumber(y), tonumber(k)
        elseif (type == 'HSV') then
            local h, s, v = input:match('(%d+),%s*(%d+),%s*(%d+)')
            return tonumber(h), tonumber(s), tonumber(v)
        elseif (type == 'HSL') then
            local h, s, l = input:match('(%d+),%s*(%d+),%s*(%d+)')
            return tonumber(h), tonumber(s), tonumber(l)
        elseif (type == 'HEX') then
            if input:match('^#?([0-9A-Fa-f]{6})$') then
                local hex = input:gsub('#', '')
                local r = tonumber(hex:sub(1, 2), 16)
                local g = tonumber(hex:sub(3, 4), 16)
                local b = tonumber(hex:sub(5, 6), 16)
                return r, g, b, 255 -- Full opacity by default
            end
            return nil, nil, nil, nil
        elseif (type == 'RGB') then
            -- Removing extra spaces and separating values
            input = input:gsub('^%s*(.-)%s*, ', '%1') -- Removing spaces at the beginning and end
            input = input:gsub('%s*,%s*', ',') -- Removing spaces around a comma
            input = input:gsub('%s+', '') -- Removing extra spaces

            -- Checking for numbers and commas only
            if (not input:match('^[%d,]*$')) then return nil, nil, nil, nil end

            -- Separation of values
            local values = {}
            for value in string.gmatch(input, '([^,]+)') do
                table.Table:Add(values, value)
            end

            -- Limiting the number of values to 4 (r, g, b, a)
            if (#values > 4) then return nil, nil, nil, nil end

            -- Convert values to numbers and replace empty values with 0
            local r, g, b, a = 0, 0, 0, 255 -- Default values (a = 255 for full opacity)
            for i = 1, #values do
                if (values[i] and values[i] ~= '') then
                    local num = tonumber(values[i])
                    if num then
                        if (num < 0 or num > 255) then return nil, nil, nil, nil end
                        if i == 1 then r = num
                        elseif (i == 2) then g = num
                        elseif (i == 3) then b = num
                        elseif (i == 4) then a = num
                        end
                    else
                        return nil, nil, nil, nil
                    end
                end
            end

            -- Return parsed RGB values
            return r, g, b, a
        end

        return nil, nil, nil, nil -- Return nil if the type is not recognised
    end
end


do
	--- Draws the arc.
    -- @param cx: X coordinate of the arc centre.
    -- @param cy: Y coordinate of the arc centre.
    -- @param radius: The radius of the arc.
    -- @param thickness: Arc thickness.
    -- @param startang: Start angle in degrees.
    -- @param endang: End angle in degrees.
    -- @param roughness: The level of detail of the arc.
    -- @param colour: Arc colour.
	function utils:DrawArc(cx, cy, radius, thickness, startang, endang, roughness, color)
	    draw_color(color or color_white)
	    self:SurfaceDrawArc(self:PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness))
	end


	--- Draws a pre-prepared arc.
    -- @param arc: A table of points representing the arc.
	function utils:SurfaceDrawArc(arc)
	    for k, v in ipairs(arc) do
	        draw_poly(v)
	    end
	end


	--- Prepares the points for the arc.
    -- @param cx: X coordinate of the arc centre.
    -- @param cy: Y coordinate of the arc centre.
    -- @param radius: Arc radius.
    -- @param thickness: Arc thickness.
    -- @param startang: Start angle in degrees.
    -- @param endang: End angle in degrees.
    -- @param roughness: The level of detail of the arc.
    -- @return: A table containing the triangles to draw the arc.
	function utils:PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)
        local triarc = {}
        -- Setting the minimum detail
        local step = max(roughness or 1, 1)
        startang = startang or 0
        endang = endang or 0

        -- Determining the direction of corner traversal
        if (startang > endang) then step = -step end

        -- Points of the inner arc
        local inner = {}
        local r = radius - thickness

        -- Creating the points of the inner arc
        for deg = startang, endang, step do
            local rad = rad(deg)
            local ox, oy = cx + (cos(rad) * r), cy + (-sin(rad) * r)
            Table:Add(inner, { x = ox, y = oy, u = (ox - cx) / radius + 0.5, v = (oy - cy) / radius + 0.5 })
        end

        -- Points of the outer arc
        local outer = {}

        -- Creating external arc points
        for deg = startang, endang, step do
            local rad = rad(deg)
            local ox, oy = cx + (cos(rad) * radius), cy + (-sin(rad) * radius)
            Table:Add(outer, { x = ox, y = oy, u = (ox - cx) / radius + 0.5, v = (oy - cy) / radius + 0.5 })
        end

        -- Point Triangulation
        for tri = 1, #inner * 2 do
            local p1 = outer[floor(tri / 2) + 1]
            local p3 = inner[floor((tri + 1) / 2) + 1]
            local p2

            if (tri % 2 == 0) then
                p2 = outer[floor((tri + 1) / 2)]
            else
                p2 = inner[floor((tri + 1) / 2)]
            end

            Table:Add(triarc, { p1, p2, p3 })
        end

        return triarc
    end
end


do
    -- Crop text if it exceeds the specified width
    -- @param maxWidth: The maximum width for the text
    -- @param text: Source text to be cropped
    -- @param font: The font used to calculate the text size
    -- @return: Trimmed text if it exceeds the specified width
    function utils:TruncatedText(maxWidth, text, font)
        -- Set default values
        text = text or 'a'
        font = font or 'danlib_font_18'

        -- Get the size of the dots
        local dots = '...'
        local dotsSize = self:TextSize(dots, font).w

        -- If the text fits within the maxWidth, return it as is
        if (self:TextSize(text, font).w <= maxWidth) then
            return text
        end

        -- Initialize variables for trimming
        local trimmedText = ""
        local currentWidth = 0

        -- Iterate through each character in the text
        for i = 1, #text do
            local char = text:sub(i, i)
            local charWidth = self:TextSize(char, font).w

            -- Check if adding this character would exceed the maxWidth
            if (currentWidth + charWidth + dotsSize > maxWidth) then
                break
            end

            -- Add the character to the trimmed text
            trimmedText = trimmedText .. char
            currentWidth = currentWidth + charWidth
        end

        -- Add dots to indicate trimming
        return trimmedText .. dots
    end


	DanLib.ScrollingText = {}

    --- Draws scrolling text on the screen.
    -- @param scr: The unique identifier for the scrolling text. If nil, a new scrolling text entry is created.
    -- @param text: The text to be scrolled across the screen.
    -- @param font: The font used to render the text.
    -- @param x: The x-coordinate for the text position.
    -- @param y: The y-coordinate for the text position.
    -- @param color: The color of the text.
    -- @param ax: The horizontal alignment of the text (default is 0).
    -- @param ay: The vertical alignment of the text (default is 0).
    -- @return: The unique identifier for the scrolling text, or -1 if the scrolling text has completed.
    --
    -- Example of using the DrawScrollingText function:
    --  
    --  local scrID = utils:DrawScrollingText(nil, 'Hello, World!', 'danlib_font_20', 100, 200, Color(255, 255, 255), 0, 0)
    -- 
    -- local function DrawScrollingTextExample()
    --     if scrID then
    --         scrID = utils:DrawScrollingText(scrID, 'Hello, World!', 'danlib_font_20', 100, 200, Color(255, 255, 255), 0, 0)
    --     end
    -- end

    -- DanLib.Hook:Add('HUDPaint', 'DrawScrollingTextExample', DrawScrollingTextExample)
    function utils:DrawScrollingText(scr, text, font, x, y, color, ax, ay)
        ax = ax or 0
        ay = ay or 0

        -- Create a new scrolling text entry if none exists
        if (not scr) then
            scr = #DanLib.ScrollingText + 1
            DanLib.ScrollingText[scr] = { ['text'] = '', ['count'] = 0, ['next'] = SysTime() }
            return scr
        end

        -- Validate the scrolling text entry
        if (not DanLib.ScrollingText[scr]) then return end

        local nowText = DanLib.ScrollingText[scr]['text']
        local w, h = self:GetTextSize(nowText, font)

        -- Draw the current text
        simple_text(nowText, font, x, y, color, ax, ay)

        -- Update the text if the time has come to scroll the next character
        if (DanLib.ScrollingText[scr].next <= SysTime() and DanLib.ScrollingText[scr]['count'] < #text) then
            DanLib.ScrollingText[scr].next = SysTime() + 0.05
            DanLib.ScrollingText[scr]['text'] = DanLib.ScrollingText[scr]['text'] .. text:sub(DanLib.ScrollingText[scr]['count'] + 1, DanLib.ScrollingText[scr]['count'] + 1)
            DanLib.ScrollingText[scr]['count'] = DanLib.ScrollingText[scr]['count'] + 1
        end

        -- Cleanup if the text has finished scrolling
        if (DanLib.ScrollingText[scr]['count'] >= #text) then
            DanLib.ScrollingText[scr] = nil
            return -1
        end

        return scr
    end
end


do
	/***
     * Credits: 
     * 		https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/draw.lua
     * 		https://gist.github.com/MysteryPancake/e8d367988ef05e59843f669566a9a59f
     */

    --- @type Material
    local MaskMaterial = CreateMaterial('!bluemask', 'UnlitGeneric', {
        ['$translucent'] = 1,
        ['$vertexalpha'] = 1,
        ['$alpha'] = 1,
    })


    --- @type Color
    local whiteColor = color_white
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
    local function drawRoundedMask(cornerRadius, x, y, w, h, draw_func, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
        if (not renderTarget) then
            renderTarget = getRenderTargetEx('DDI_ROUNDEDBOX', ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_NONE, 2, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)
        end

        pushRenderTarget(renderTarget)
        overrideAlphaWriteEnable(true, true)
        rclear(0, 0, 0, 0)

        draw_func()

        overrideBlendFunc(true, BLEND_ZERO, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLEND_ZERO)
        rounded_box_ex(cornerRadius, x, y, w, h, whiteColor, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
        overrideBlendFunc(false)
        overrideAlphaWriteEnable(false)
        popRenderTarget()

        MaskMaterial:SetTexture('$basetexture', renderTarget)

        no_texture()
        draw_color(255, 255, 255, 255)
        set_material(MaskMaterial)
        rmaterial(MaskMaterial)
        drawScreenQuad()
    end


    --- Draws a rounded mask with equal corners.
    -- @param cornerRadius: The radius of the rounded corners.
    -- @param x: X coordinate of the top left corner.
    -- @param y: Y coordinate of the top left corner.
    -- @param w: Width of the mask.
    -- @param h: Height of the mask.
    -- @param dFunc: Function to draw the contents of the mask.
    function utils:DrawRoundedMask(cornerRadius, x, y, w, h, dFunc)
        drawRoundedMask(cornerRadius, x, y, w, h, dFunc, true, true, true, true)
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
    function utils:DrawRoundedExMask(cornerRadius, x, y, w, h, dFunc, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
        drawRoundedMask(cornerRadius, x, y, w, h, dFunc, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight)
    end
end


do
	--- Calculates the points of an arc.
	-- @param x (number): The X coordinate of the arc's center.
	-- @param y (number): The Y coordinate of the arc's center.
	-- @param ang (number): The starting angle of the arc in degrees.
	-- @param p (number): The angle to which the arc extends in degrees.
	-- @param rad (number): The radius of the arc.
	-- @param seg (number): The number of segments to divide the arc into (default is 80).
	-- @return table: A table containing the coordinates of the arc points.
    local function calculateArc(x, y, ang, p, rad, seg)
        seg = seg or 80
        ang = (-ang) + 180

        local circle = {}
        Table:Add(circle, { x = x, y = y })

        for i = 0, seg do
            local a = rad((i / seg) * -p + ang)
            Table:Add(circle, { x = x + sin(a) * rad, y = y + cos(a) * rad })
        end

        return circle
    end
    
    --- Generates arcs with varying roundness and thickness.
	-- This function creates several arcs based on predefined roundness and thickness values.
	-- It uses the stencil buffer for rendering the arcs.
    for roundness = 32, 8, -8 do
        local index = roundness / 8
        local multiplier = roundness * 2 / pow(2, index)
    
        if (index == 1) then multiplier = multiplier * 2 end
    
        for thickness = 1, 4 do
            local scaledThickness = thickness * 64
            local id = 'arc_' .. thickness .. '_' .. roundness
    
            spoly.Generate(id, function(w, h)
                local startAng = 0
                local endAng = 90
                local radius = h
                local x, y = 0, h

                local arcInner = calculateArc(x - scaledThickness, y + scaledThickness, startAng, endAng, radius, 128, true)
                local arcOuter = calculateArc(x, y, startAng, endAng, radius, 128, true)
            
                set_stencil_write_mask(255)
                set_stencil_test_mask(255)
                set_stencil_reference_value(0)
                set_stencil_pass_operation(STENCIL_KEEP)
                set_stencilZ_fail_operation(STENCIL_KEEP)
                clear_stencil()

                set_stencil_enable(true)
                set_stencil_reference_value(1)
                set_stencil_compare_function(STENCIL_NEVER)
                set_stencil_fail_operation(STENCIL_REPLACE)

                    draw_poly(arcInner)

                set_stencil_compare_function(STENCIL_GREATER)
                set_stencil_fail_operation(STENCIL_KEEP)
                set_stencilZ_fail_operation(STENCIL_KEEP)

                    draw_poly(arcOuter)

                set_stencil_enable(false)
            end) 
        end
    end


    --- Draws an outlined rounded rectangle.
    -- @param r (number): The radius of the corners of the rectangle.
    -- @param x (number): The X coordinate of the top-left corner of the rectangle.
    -- @param y (number): The Y coordinate of the top-left corner of the rectangle.
    -- @param w (number): The width of the rectangle.
    -- @param h (number): The height of the rectangle.
    -- @param thickness (number): The thickness of the outline (default is 1).
    -- @param color (table): The color of the outline in RGBA format.
    function utils:DrawOutlinedRoundedRect(r, x, y, w, h, thickness, color)
        -- Set default thickness if not provided
        local thickness = thickness or 1
        -- Generate a unique identifier for the arc
        local id = 'arc_' .. thickness .. '_' .. r

        -- Adjust thickness based on the radius
        thickness = floor(r * 0.15)

        -- Ensure width is an integer
        local w = ceil(w)
        -- Ensure height is an integer
        local h = ceil(h)

        -- Calculate half of the radius
        local half = round(r * .5)
        -- Set the drawing color if provided
        if color then draw_color(color) end

        -- Draw the rounded corners using the arc identifier
        -- Top-left corner
        spoly.DrawRotated(id, x + half, y + half, r, r, 90)
        -- Top-right corner
        spoly.DrawRotated(id, x + w - half, y + half, r, r, 0)
        -- Bottom-right corner
        spoly.DrawRotated(id, x + w - half, y + h - half, r, r, 270)
        -- Bottom-left corner
        spoly.DrawRotated(id, x + half, y + h - half, r, r, 180)

        -- Draw the sides of the rectangle
        -- Top side
        draw_rect(x + r, y, (w - r * 2), thickness)
        -- Right side
        draw_rect(x + w - thickness, y + r, thickness, (h - r * 2))
        -- Bottom side
        draw_rect(x + r, y + h - thickness, (w - r * 2), thickness)
        -- Left side
        draw_rect(x, y + r, thickness, (h - r * 2))
    end
end


-- Function for drawing a square with an icon
function utils:DrawSquareWithIcon(x, y, color, size, iconMaterial, roundness)
    x = x or 0
    y = y or 0
    color = color or self:UiColor(0, 0, 0, 100)
    size = size or 24
    iconMaterial = iconMaterial or Material('error')

    if (roundness && roundness > 0) then
        rounded_box(roundness, x, y, size, size, color)
        -- self:DrawOutlinedRoundedRect(roundness, x, y, size, size, 4, base:Theme('frame'))
    else
        -- If no radius is specified, just draw a rectangle
        self:DrawRect(x, y, size, size, color)
    end

    -- Calculating the size of the icon
    local iconSize = size * 0.5 -- The size of the icon will be half the size of the square
    local iconX = x + (size - iconSize) / 2 -- Centre the icon at X
    local iconY = y + (size - iconSize) / 2 -- Centre the icon in Y

    if isstring(iconMaterial) then
        self:DrawIcon(iconX, iconY, iconSize, iconSize, iconMaterial, base:Theme('mat', 150))
    else
        self:DrawMaterial(iconX, iconY, iconSize, iconSize, base:Theme('mat', 150), iconMaterial)
    end
end


--- Plays a sound from the DanLib sound configuration.
-- @param soundName string: The name of the sound to play.
-- @return boolean: Returns true if the sound was played successfully, false otherwise.
-- @throws error: If the specified sound does not exist in the configuration.
function base:PlaySound(soundName)
    -- Validate input
    if (type(soundName) ~= 'string' or soundName == '') then
        error('Invalid sound name provided. It must be a non-empty string.')
    end

    -- Check if the sound exists in the configuration
    local soundPath = DanLib.Config.Sound[soundName]
    if (not soundPath) then
        error('Sound "' .. soundName .. '" does not exist in the sounds table.')
    end

    -- Play the sound
    surface.PlaySound(soundPath)

    return true -- Indicate successful playback
end
