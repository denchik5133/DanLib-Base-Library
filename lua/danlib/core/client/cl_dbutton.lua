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
function DBase.CreateUIButton(parent, options)
    parent = parent or nil
    options = options or {}
    local button = DCustomUtils(parent, 'DButton')
    button:SetText('')
    button:ApplyClearPaint()

    -- Helper to check if key exists in options table
    local function hasKey(key)
        for k in pairs(options) do
            if (k == key) then
                return true
            end
        end
        return false
    end

    -- Helper function to normalize options (supports both nil and {nil} formats)
    local function normalizeOption(opt)
        if (opt == nil) then
            return {nil}
        elseif (type(opt) == 'table') then
            return opt
        else
            return { opt }
        end
    end

    -- Background settings
    if hasKey('background') then
        local background = normalizeOption(options.background)
        local backgroundColor
        
        if background[1] then
            backgroundColor = IsColor(background[1]) and background[1] or DBase:Theme('button')
        else
            backgroundColor = Color(0, 0, 0, 0)
        end
        
        local cornerRadius = background[2] or 6
        local rounding = background[3]
        button:ApplyBackground(backgroundColor, cornerRadius, rounding)
    else
        -- Key not present - use default
        button:ApplyBackground(DBase:Theme('button'), 6, nil)
    end

    -- Hover settings
    if hasKey('hover') then
        local hover = normalizeOption(options.hover)
        local hoverColor
        
        if hover[1] then
            hoverColor = IsColor(hover[1]) and hover[1] or DBase:Theme('button_hovered')
        else
            hoverColor = Color(0, 0, 0, 0)
        end
        
        local hoverSpeed = hover[2]
        local hoverRad = hover[3] or 6
        
        if hoverColor.a > 0 then
            button:ApplyFadeHover(hoverColor, hoverSpeed, hoverRad)
            
            local originalThink = button.Think
            button.Think = function(sl)
                if originalThink then
                    originalThink(sl)
                end
                if sl:GetDisabled() then
                    sl.HoverFade = 0
                end
            end
        end
    else
        -- Key not present - use default
        local hoverColor = DBase:Theme('button_hovered')
        button:ApplyFadeHover(hoverColor, nil, 6)
        
        local originalThink = button.Think
        button.Think = function(sl)
            if originalThink then
                originalThink(sl)
            end
            if sl:GetDisabled() then
                sl.HoverFade = 0
            end
        end
    end

    -- Text
    if hasKey('text') then
        local text = normalizeOption(options.text)
        local textStr = text[1]
        local textFont = text[2]
        local textX = text[3]
        local textY = text[4]
        local textColor = (IsColor(text[5])) and text[5] or DBase:Theme('text')
        local textXalign = text[6]
        local textYalign = text[7]
        button:ApplyText(textStr, textFont, textX, textY, textColor, textXalign, textYalign)
    end

    -- Docking options
    if hasKey('dock') then
        local dock = normalizeOption(options.dock)
        if dock[1] then
            local dockPos = dock[1]
            local indent = dock[2] or 0
            button:Pin(dockPos, indent)
        end
    end

    if hasKey('dock_indent') then
        local dockIndent = normalizeOption(options.dock_indent)
        local dockPos = dockIndent[1]
        local indent1 = dockIndent[2] or 0
        local indent2 = dockIndent[3] or 0
        local indent3 = dockIndent[4] or 0
        local indent4 = dockIndent[5] or 0
        button:Dock(dockPos)
        button:DockMargin(indent1, indent2, indent3, indent4)
    end

    -- Position setting
    if hasKey('pos') then
        button:SetPos(unpack(options.pos))
    end

    -- Setting the button size
    if hasKey('size') then
        button:SetSize(unpack(options.size))
    end

    if hasKey('wide') then
        button:SetWide(options.wide)
    end

    if hasKey('tall') then
        button:SetTall(options.tall)
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
        local text = tooltip[1]
        local color = tooltip[2]
        local tooltipColor = (color and IsColor(color)) and color or nil
        local icon = tooltip[3]
        local indent = tooltip[4]
        button:ApplyTooltip(text, tooltipColor, icon, indent)
    end

    if hasKey('think') then
        button:ApplyEvent('Think', function(self, w, h)
            return options.think(self, w, h)
        end)
    end

    -- Button drawing function
    button:ApplyEvent(nil, function(self, w, h)
        if hasKey('paint') then
            return options.paint(self, w, h)
        end
        
        if hasKey('icon') then
            local icon = normalizeOption(options.icon)
            local iconStr = icon[1] or ''
            local iconColor = (IsColor(icon[2])) and icon[2] or DBase:Theme('mat', 150)
            local iconSize = icon[3] or 18
            local IconSize = DBase:Scale(iconSize)
            local iconPosX = w * 0.5 - IconSize * 0.5
            local iconPosY = h * 0.5 - IconSize * 0.5
            utils:DrawIconOrMaterial(iconPosX, iconPosY, IconSize, iconStr, iconColor)
        end
        
        return self
    end)

    -- Hover click effects
    if hasKey('hoverClick') then
        local hoverClick = normalizeOption(options.hoverClick)
        local hoverClickColor
        
        if hoverClick[1] then
            hoverClickColor = IsColor(hoverClick[1]) and hoverClick[1] or nil
        else
            hoverClickColor = Color(0, 0, 0, 0)
        end

        local hoverClickSpeed = hoverClick[2]
        local hoverClickRadius = hoverClick[3]
        
        if (hoverClickColor and hoverClickColor.a > 0) then
            button:ApplyCircleEffect(hoverClickColor, hoverClickSpeed, hoverClickRadius)
            
            local originalOnMousePressed = button.OnMousePressed
            button.OnMousePressed = function(sl, keyCode)
                if (not sl:GetDisabled() and originalOnMousePressed) then
                    originalOnMousePressed(sl, keyCode)
                end
            end
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
