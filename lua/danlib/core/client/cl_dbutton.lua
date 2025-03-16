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


/***
 *   cl_dbutton.lua
 *   This file is responsible for creating customizable buttons in the DanLib project.
 *
 *   It includes the following functions:
 *   - Create a button with text, icon, and hover effects.
 *   - Set background color and hover color for the button.
 *   - Add icon functionality with customizable size and color.
 *   - Paint the button with appropriate styles based on its state (hovered, disabled).
 *
 *   The file provides a convenient interface for creating buttons in the project.
 */
 


local base = DanLib.Func
local utils = DanLib.Utils
local form = string.format

--- Creates a button in the specified parent panel.
-- @param parent: The parent panel in which the button will be created.
-- @param text: The text to be displayed on the button. Defaults to an empty string if not provided.
-- @param font: The font to be used for the button text. Defaults to 'danlib_font_20' if not provided.
-- @param textColor: The color of the button text. Defaults to the theme's text color if not provided.
function base:CreateButton(parent, text, font, textColor)
    local button = DanLib.CustomUtils.Create(parent, 'DButton')
    button:SetText(text or '')
    button:SetTextColor(textColor or base:Theme('text'))
    button:SetFont(font or 'danlib_font_20')


    -- Initialize default properties for the button
    button.BackgroundColor = base:Theme('button')
    button.HoverColor = base:Theme('button_hovered')
    button.sIconSize = 24
    button.hover = 0


    --- Sets the background color of the button.
    -- @param color: The color to set as the background.
    -- @return Button: Returns the button instance for method chaining.
    function button:SetBackgroundColor(color)
        self.BackgroundColor = color
        return self
    end


    --- Sets the hover color of the button.
    -- @param color: The color to set when the button is hovered.
    -- @return Button: Returns the button instance for method chaining.
    function button:SetHoverColor(color)
        self.HoverColor = color
        return self
    end


    --- Sets the hover toggle state of the button.
    -- @param tum: Boolean indicating whether hover effects should be applied.
    -- @return Button: Returns the button instance for method chaining.
    function button:SetHoverTum(tum)
        self.HoverTum = tum
        return self
    end


    --- Sets the icon of the button.
    -- @param icon: The icon to be displayed on the button.
    -- @param size: The size of the icon.
    -- @param color: The color of the icon.
    -- @return Button: Returns the button instance for method chaining.
    function button:icon(icon, size, color)
        self.sIcon = icon
        self.sIconSize = size or self.sIconSize
        self.IconColor = color
        return self
    end


    --- Paint function for the button.
    -- This function is responsible for rendering the button's appearance.
    -- @param w: The width of the button.
    -- @param h: The height of the button.
    function button:Paint(w, h)
        local IconSize = base:Scale(self.sIconSize)

        -- Hover effect
        if self:IsHovered() then
            self.hover = math.min(self.hover + 6, 200)
        else
            self.hover = math.max(self.hover - 6, 0)
        end

        local hover = self.hover / 100
        local hoverColor = ColorAlpha(self.HoverColor, hover * 250)

        -- Background
        utils:DrawRect(0, 0, w, h, self.BackgroundColor)

        if (not self:GetDisabled()) then
            if (not self.HoverTum) then
                utils:DrawRect(0, 0, w, h, hoverColor)
            end
        end

        if self.sIcon then
            local iconColor = self.IconColor or base:Theme('mat', 100 + hover * 250)
            local iconPosX = w * 0.5 - IconSize * 0.5
            local iconPosY = h * 0.5 - IconSize * 0.5
            utils:DrawIconOrMaterial(iconPosX, iconPosY, IconSize, self.sIcon, iconColor)
        end

        return self
    end

    return button
end










--- Creates a button in the specified parent panel with customizable options.
-- @param parent Panel: The parent panel in which the button will be created.
-- @param options table: A table containing various customizable options for the button.
-- @param options.text string: The text displayed on the button (default: '').
-- @param options.textColor Color: The color of the button text (default: Theme text color).
-- @param options.font string: The font used for the button text (default: 'danlib_font_18').
-- @param options.background table: A table containing background color and rounding options.
-- @param options.hover table: A table for hover color and animation properties.
-- @param options.dock table: A table for docking options (position and indent).
-- @param options.dock_indent table: A table for docking with specific margins.
-- @param options.pos table: A table containing x and y position for the button.
-- @param options.size table: A table containing width and height for the button.
-- @param options.wide number: The width of the button.
-- @param options.tall number: The height of the button.
-- @param options.click function: The function to call when the button is clicked.
-- @param options.tooltip table: A table containing tooltip text, color, icon, and position.
-- @param options.icon string: The icon displayed on the button (default: '').
-- @param options.iconSize number: The size of the icon (default: 18).
-- @param options.iconColor Color: The color of the icon (default: Theme material color).
-- @param options.paint function: A custom paint function for the button.
-- @param options.hoverClick table: A table for hover click effects.
-- @return DButton: Returns the button instance for method chaining.
--
-- @note: The `think` function can be used to implement custom behavior that needs to be updated 
-- every frame (e.g., animations, state changes). To use it, provide a function in the options 
-- table under the `think` key. The function will receive the button instance as its first argument.
function base.CreateUIButton(parent, options)
    parent = parent or nil
    options = options or {} -- Ensure options is not nil

    local button = DanLib.CustomUtils.Create(parent, 'DButton')
    button:SetText('')
    button:ApplyClearPaint()

    -- Background settings
    local backgroundColor
    if options.background then
        if options.background[1] then
            backgroundColor = IsColor(options.background[1]) and options.background[1] or base:Theme('button')
        else
            backgroundColor = Color(0, 0, 0, 0) -- If background is {nil}, set backgroundColor to nil
            button:ApplyClearPaint()
        end
    else
        backgroundColor = base:Theme('button') -- Default color if background is not provided
    end

    local cornerRadius = options.background and options.background[2]
    local rounding = options.background and options.background[3]
    button:ApplyBackground(backgroundColor, cornerRadius, rounding)


    -- Hover settings
    local hoverColor
    if options.hover then
        if options.hover[1] then
            hoverColor = IsColor(options.hover[1]) and options.hover[1] or base:Theme('button_hovered')
        else
            hoverColor = Color(0, 0, 0, 0) -- If hover is {nil}, set hoverColor to nil
        end
    else
        hoverColor = base:Theme('button_hovered') -- Default color if hover is not provided
    end

    local hoverSpeed = (options.hover and options.hover[2]) or nil
    local hoverRad = (options.hover and options.hover[3]) or nil
    button:ApplyFadeHover(hoverColor, hoverSpeed, hoverRad)

    -- Text
    if options.text then
        local text = (options.text and options.text[1]) or nil
        local textFont = (options.text[2] and options.text[2]) or nil
        local textX = (options.text[3] and options.text[3]) or nil
        local textH = (options.text[4] and options.text[4]) or nil
        local textColor = (options.text and IsColor(options.text[5])) and options.text[5] or base:Theme('text')
        local textXalign = (options.text[6] and options.text[6]) or nil
        local textYalign = (options.text[7] and options.text[7]) or nil
        button:ApplyText(text, textFont, textX, textH, textColor, textXalign, textYalign)
    end

    -- Docking options
    if options.dock then
        local dock = options.dock[1] -- Position (e.g. 'TOP', 'LEFT', etc...)
        local indent = options.dock[2] or 0 -- Indentation, defaults to 0 if not specified
        button:Pin(dock, indent)
    end

    if options.dock_indent then
        local dock = options.dock_indent[1] -- Position (e.g. 'TOP', 'LEFT', etc...)
        local indent1 = options.dock_indent[2] or 0 -- Indent (Left), default 0 if not specified
        local indent2 = options.dock_indent[3] or 0 -- Indent (Top), defaults to 0 if not specified
        local indent3 = options.dock_indent[4] or 0 -- Indent (Right), default 0 if not specified
        local indent4 = options.dock_indent[5] or 0 -- Indent (Bottom), default 0 if not specified
        button:Dock(dock)
        button:DockMargin(indent1, indent2, indent3, indent4)
    end

    -- Position setting
    if options.pos then
        button:SetPos(unpack(options.pos))
    end

    -- Setting the button size
    if options.size then
        button:SetSize(unpack(options.size))
    end

    if options.wide then
        button:SetWide(options.wide)
    end

    if options.tall then
        button:SetTall(options.tall)
    end

    -- Click processing
    if options.click then
        button:ApplyEvent('DoClick', options.click or function() end)
    end

    if options.rclick then
        button:ApplyEvent('DoRightClick', options.rclick or function() end)
    end

    -- button:ApplySound('ddi/button-hover.wav', 'ddi/button-click.wav')

    -- Tooltip settings
    if options.tooltip then
        local text = options.tooltip[1] -- Text (For example: 'Hello!')
        local color = options.tooltip[2] -- color (For example: Color(255, 255, 255))
        local tooltipColor = (color and IsColor(color)) and color or nil
        local icon = options.tooltip[3] -- Icon (For example: '5eUOM3U' or Material('path/to/icon.png'))
        local indent = options.tooltip[4] -- Position (For example: 'TOP', 'LEFT', etc...)
        button:ApplyTooltip(text, tooltipColor, icon, indent)
    end


    if options.think then
        button:ApplyEvent('Think', function(self, w, h)
            return options.think(self, w, h)
        end)
    end

    -- Button drawing function
    button:ApplyEvent(nil, function(self, w, h)
        -- If a custom Paint function is provided, use it
        if options.paint then
            return options.paint(self, w, h)
        end

        -- Icon settings
        if options.icon then
            local icon = options.icon[1] or ''
            local iconColor = (options.icon and IsColor(options.icon[2])) and options.icon[2] or base:Theme('mat', 150)
            local iconSize = (options.icon and options.icon[3]) or 18
            -- If the custom function is not provided, use the standard implementation
            local IconSize = base:Scale(iconSize)
            local iconPosX = w * 0.5 - IconSize * 0.5
            local iconPosY = h * 0.5 - IconSize * 0.5
            utils:DrawIconOrMaterial(iconPosX, iconPosY, IconSize, icon, iconColor)
        end

        return self
    end)

    -- Hover click effects
    local hoverClickColor
    if options.hoverClick then
        if options.hoverClick[1] then
            hoverClickColor = IsColor(options.hoverClick[1]) and options.hoverClick[1] or nil
        else
            hoverClickColor = Color(0, 0, 0, 0) -- If hoverClick is {nil}, set hoverClickColor to nil
        end
    else
        hoverClickColor = nil
    end

    local hoverClickSpeed = options.hoverClick and options.hoverClick[2]
    local hoverClickRadius = options.hoverClick and options.hoverClick[3]
    button:ApplyCircleEffect(hoverClickColor, hoverClickSpeed, hoverClickRadius)

    return button
end




-- https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/dcolorpalette.lua

local BUTTON, Constructor = DanLib.UiPanel()
local matGrid = DanLib.Config.Materials['alpha_grid']

AccessorFunc(BUTTON, 'm_bBorder', 'DrawBorder', FORCE_BOOL)
AccessorFunc(BUTTON, 'm_bSelected', 'Selected', FORCE_BOOL)
AccessorFunc(BUTTON, 'm_Color', 'Color')
AccessorFunc(BUTTON, 'm_PanelID', 'ID')
AccessorFunc(BUTTON, 'm_formatRGB', 'FormatRGB')

function BUTTON:Init()
    self:SetSize(10, 10)
    self:SetMouseInputEnabled(true)
    self:SetText('')
    self:SetCursor('hand')
    self:SetZPos(0)
    self:SetColor(Color(255, 0, 255))
    self:SetFormatRGB('RGB')
end

function BUTTON:IsDown()
    return self.Depressed
end

function BUTTON:SetColor(color, hideTooltip)
    if (not hideTooltip) then
        local formatType = self:GetFormatRGB() -- Get the current colour format
        local colorStr

        -- Format the string for the tooltip depending on the type
        if (formatType == 'RGB') then
            colorStr = form('R: %d\nG: %d\nB: %d\nA: %d', color.r, color.g, color.b, color.a)
        elseif (formatType == 'HEX') then
            colorStr = form('HEX: #%02X%02X%02X', color.r, color.g, color.b)
        elseif (formatType == 'CMYK') then
            local c, m, y, k = utils:RGBtoCMYK(color.r, color.g, color.b)
            colorStr = form('C: %d\nM: %d\nY: %d\nK: %d', c, m, y, k)
        elseif (formatType == 'HSV') then
            local h, s, v = ColorToHSV(color)
            colorStr = form('H: %d\nS: %d\nV: %d\nA: %d', h, s, v, color.a)
        elseif (formatType == 'HSL') then
            local h, s, l = utils:RGBtoHSL(color.r, color.g, color.b)
            colorStr = form('H: %d\nS: %d\nL: %d\nA: %d', h, s, l, color.a)
        end

        -- Output a tooltip with a formatted string
        if colorStr then
            self:ApplyTooltip(colorStr, nil, nil, TOP)
        end
    end
    self.m_Color = color
end

function BUTTON:Paint(w, h)
    if (self:GetColor().a < 255) then -- Grid for Alpha
        local size = math.max(128, math.max(w, h))
        local x, y = w / 2 - size / 2, h / 2 - size / 2
        utils:DrawMaterial(x, y, size, size, color_white, matGrid)
    end
    
    local panelColor = self:GetColor()
    utils:DrawRoundedBox(0, 0, w, h, Color(panelColor.r, panelColor.g, panelColor.b, panelColor.a))
    return false
end

BUTTON:SetBase('DLabel')
BUTTON:Register('DanLib.UI.ColorButton')
