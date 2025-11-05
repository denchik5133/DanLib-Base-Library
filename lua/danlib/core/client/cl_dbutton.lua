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
 


local DBase = DanLib.Func
local utils = DanLib.Utils
local DCustomUtils = DanLib.CustomUtils.Create
local form = string.format

--- Creates a button in the specified parent panel.
-- @param parent: The parent panel in which the button will be created.
-- @param text: The text to be displayed on the button. Defaults to an empty string if not provided.
-- @param font: The font to be used for the button text. Defaults to 'danlib_font_20' if not provided.
-- @param textColor: The color of the button text. Defaults to the theme's text color if not provided.
function DBase:CreateButton(parent, text, font, textColor)
    local button = DCustomUtils(parent, 'DButton')
    button:SetText(text or '')
    button:SetTextColor(textColor or DBase:Theme('text'))
    button:SetFont(font or 'danlib_font_20')


    -- Initialize default properties for the button
    button.BackgroundColor = DBase:Theme('button')
    button.HoverColor = DBase:Theme('button_hovered')
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
        local IconSize = DBase:Scale(self.sIconSize)

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
            local iconColor = self.IconColor or DBase:Theme('mat', 100 + hover * 250)
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
-- @param options.rclick function: The function to call when the button is right-clicked.
-- @param options.tooltip table: A table containing tooltip text, color, icon, and position.
-- @param options.icon table: A table containing icon, color, and size.
-- @param options.paint function: A custom paint function for the button.
-- @param options.hoverClick table: A table for hover click effects (ripple effect).
-- @param options.think function: Custom Think function called every frame.
-- @param options.sound table: A table containing sound paths {hoverSound, clickSound}.
-- @return DButton: Returns the button instance for method chaining.
--
-- @note: The `think` function can be used to implement custom behavior that needs to be updated 
-- every frame (e.g., animations, state changes). To use it, provide a function in the options 
-- table under the `think` key. The function will receive the button instance as its first argument.
--
-- @example:
-- DBase.CreateUIButton(parent, {
--     text = { 'Click Me', 'danlib_font_18', nil, nil, Color(255, 255, 255) },
--     background = { Color(50, 50, 50), 6 },
--     hover = { Color(255, 255, 255, 30), 8, 6 },
--     sound = { 'buttons/button15.wav', 'buttons/button14.wav' },
--     click = function() print('Clicked!') end
-- })
function DBase.CreateUIButton(parent, options)
    options = options or {}
    local button = DCustomUtils(parent, 'DButton')
    button:SetText('')
    button:ApplyClearPaint()

    -- Helper to check if key exists in options table
    local function hasKey(key)
        return options[key] ~= nil
    end

    -- Helper function to normalize options (supports both nil and {nil} formats)
    local function normalizeOption(opt)
        return type(opt) == 'table' and opt or {opt}
    end
    
    -- Helper to wrap event with disabled check
    local function wrapDisabledCheck(eventName, originalFunc)
        local original = button[eventName]
        button[eventName] = function(sl, ...)
            if (not sl:GetDisabled() and original) then
                return original(sl, ...)
            end
        end
    end

    -- Auto cursor management based on enabled state
    local originalSetEnabled = button.SetEnabled
    button.SetEnabled = function(sl, enabled)
        originalSetEnabled(sl, enabled)
        sl:SetCursor(enabled and 'hand' or 'no')
        return sl
    end
    button:SetCursor('hand')

    -- Background settings
    if hasKey('background') then
        local background = normalizeOption(options.background)
        local backgroundColor = background[1] and (IsColor(background[1]) and background[1] or DBase:Theme('button')) or Color(0, 0, 0, 0)
        button:ApplyBackground(backgroundColor, background[2] or 6, background[3])
    else
        button:ApplyBackground(DBase:Theme('button'), 6, nil)
    end

    -- Hover settings with Think hook
    local function setupHoverThink()
        local originalThink = button.Think
        button.Think = function(sl)
            if originalThink then originalThink(sl) end
            if sl:GetDisabled() then
                sl.HoverFade = 0
            end
        end
    end

    if hasKey('hover') then
        local hover = normalizeOption(options.hover)
        local hoverColor = hover[1] and (IsColor(hover[1]) and hover[1] or DBase:Theme('button_hovered')) or Color(0, 0, 0, 0)
        
        if hoverColor.a > 0 then
            button:ApplyFadeHover(hoverColor, hover[2], hover[3] or 6)
            setupHoverThink()
        end
    else
        button:ApplyFadeHover(DBase:Theme('button_hovered'), nil, 6)
        setupHoverThink()
    end

    -- Text
    if hasKey('text') then
        local text = normalizeOption(options.text)
        button:ApplyText(text[1], text[2], text[3], text[4], IsColor(text[5]) and text[5] or DBase:Theme('text'), text[6], text[7])
    end

    -- Docking options
    if hasKey('dock') then
        local dock = normalizeOption(options.dock)
        if dock[1] then
            button:Pin(dock[1], dock[2] or 0)
        end
    end

    if hasKey('dock_indent') then
        local dockIndent = normalizeOption(options.dock_indent)
        button:Dock(dockIndent[1])
        button:DockMargin(dockIndent[2] or 0, dockIndent[3] or 0, dockIndent[4] or 0, dockIndent[5] or 0)
    end

    -- Position and size
    if hasKey('pos') then button:SetPos(unpack(options.pos)) end
    if hasKey('size') then button:SetSize(unpack(options.size)) end
    if hasKey('wide') then button:SetWide(options.wide) end
    if hasKey('tall') then button:SetTall(options.tall) end

    -- Sound effects (default enabled)
    local function applySoundsWithDisabledCheck(hoverSound, clickSound)
        button:ApplySound(hoverSound, clickSound)
        if hoverSound then wrapDisabledCheck('OnCursorEntered') end
        if clickSound then wrapDisabledCheck('OnMouseReleased') end
    end

    if hasKey('sound') then
        local sound = normalizeOption(options.sound)
        if (sound[1] or sound[2]) then
            applySoundsWithDisabledCheck(sound[1], sound[2])
        end
    else
        applySoundsWithDisabledCheck('ddi/button-hover.wav', 'ddi/button-click.wav')
    end

    -- Click processing
    if hasKey('click') then
        button:ApplyEvent('DoClick', options.click or function() end)
    end
    if hasKey('rclick') then
        button:ApplyEvent('DoRightClick', options.rclick or function() end)
    end

    -- Tooltip settings
    if hasKey('tooltip') then
        local tooltip = normalizeOption(options.tooltip)
        local tooltipColor = tooltip[2] and IsColor(tooltip[2]) and tooltip[2] or nil
        button:ApplyTooltip(tooltip[1], tooltipColor, tooltip[3], tooltip[4])
    end

    -- Think
    if hasKey('think') then
        button:ApplyEvent('Think', options.think)
    end

    -- Paint with icon
    button:ApplyEvent(nil, function(self, w, h)
        if hasKey('paint') then
            return options.paint(self, w, h)
        end
        
        if hasKey('icon') then
            local icon = normalizeOption(options.icon)
            local iconSize = DBase:Scale(icon[3] or 18)
            local iconColor = IsColor(icon[2]) and icon[2] or DBase:Theme('mat', 150)
            utils:DrawIconOrMaterial((w - iconSize) * 0.5, (h - iconSize) * 0.5, iconSize, icon[1] or '', iconColor)
        end
    end)

    -- Hover click effects
    if hasKey('hoverClick') then
        local hoverClick = normalizeOption(options.hoverClick)
        local hoverClickColor = hoverClick[1] and (IsColor(hoverClick[1]) and hoverClick[1] or nil) or Color(0, 0, 0, 0)
        if (hoverClickColor and hoverClickColor.a > 0) then
            button:ApplyCircleEffect(hoverClickColor, hoverClick[2], hoverClick[3])
            wrapDisabledCheck('OnMousePressed')
        end
    end

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
