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



local clamp = math.Clamp
local max = math.max

local mouseX = gui.MouseX
local mouseY = gui.MouseY

local SW = ScrW
local SH = ScrH

local base = DanLib.Func
local PANEL, _ = DanLib.UiPanel()
local utils = DanLib.Utils
local customUtils = DanLib.CustomUtils

DanLib.Frames = {}

-- Function for setting onCloseFunc
function PANEL:SetOnCloseFunc(func)
    self.onCloseFunc = func
end

--- Closes the frame with the option to call the callback function.
function PANEL:CloseFrame()
    if self.onCloseFunc then self.onCloseFunc() end

    if self.removeOnClose then
        self:SetAlpha(255)
        self:AlphaTo(0, 0.2, 0, function()
            self:Remove()
        end)
    else
        self:SetVisible(false)
    end
end

function PANEL:Init()
    self:CustomUtils()
    self:ApplyAttenuation(0.2)

    -- Flag for transparency tracking
    self.IsTransparent = false
    -- Flag to track the change in size
    self.IsResizing = false
    -- Customising the control buttons
    self.btnMaxim:Hide()
    self.btnMinim:Hide()
    self.lblTitle:SetText('')
    self.removeOnClose = true
    -- Sets whether or not the shadow effect bordering the DFrame should be drawn.
    self:SetPaintShadow(true)
    -- Sets the dock padding of the panel.
    -- The dock padding is the extra space that will be left around the edge when child elements are docked inside this element.
    self:DockPadding(0, 0, 0, 0)
    -- Sets whether or not the DFrame can be resized by the user.
    -- This is achieved by clicking and dragging in the bottom right corner of the frame.
    -- self:SetSizable(true)
    -- Sets whether the DFrame is restricted to the boundaries of the screen resolution.
    self:SetScreenLock(true)
    self.btnClose:SetVisible(false)

    -- Creating the top panel
    self.top = customUtils.Create(self)
    self.top:Pin(TOP)
    self.top:SetTall(30)
    self.top:DockPadding(0, 0, 0, 2)
    self.top:SetCursor('arrow')
    -- self.top:ApplyBackground(base:Theme('secondary'))
    self.top:ApplyEvent(nil, function(sl, w, h)
        utils:DrawRoundedTopBox(0, 0, w, h, base:Theme('secondary'))
    end)

    -- Handling drag and drop
    local function startDragging()
        self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
    end

    self.top.OnMousePressed = startDragging
    self.top.OnMouseReleased = function() self.Dragging = nil end

    -- Creating a header
    self.title = customUtils.Create(self.top, 'DLabel')
    self.title:PinMargin(LEFT, 10)
    self.title:SetFont('danlib_font_20')
    self.title:SetTextColor(base:Theme('text'))

    -- Creating a close button
    self.closeBtn = base:CreateButton(self.top)
    self.closeBtn:Pin(RIGHT)
    self.closeBtn:SetWide(30)
    self.closeBtn:ApplyTooltip(base:L('#close'), nil, nil, TOP)
    self.closeBtn:icon('jWj7VqX', 24)
    self.closeBtn:SetHoverTum(true)
    self.closeBtn:SetBackgroundColor(Color(0, 0, 0, 0))
    self.closeBtn.DoClick = function() self:CloseFrame() end
end

--- Sets the function for the settings button.
-- @param show (boolean): Whether to show the button.
-- @param func (function): Function to execute when pressed.
function PANEL:SetSettingsFunc(func)
    self.settingsBtn = base:CreateButton(self.top)
    self.settingsBtn:Pin(RIGHT)
    self.settingsBtn:SetWide(30)
    self.settingsBtn:ApplyTooltip(base:L('#settings'), nil, nil, TOP)
    self.settingsBtn:icon('lgHTnoN', 24)
    self.settingsBtn:SetHoverTum(true)
    self.settingsBtn:SetBackgroundColor(Color(0, 0, 0, 0))
    self.settingsBtn.DoClick = func or function() end
end

-- Создание кнопки прозрачности
function PANEL:Transparency()
    self.transparencyBtn = base:CreateButton(self.top)
    self.transparencyBtn:Pin(RIGHT)
    self.transparencyBtn:SetWide(30)
    self.transparencyBtn:ApplyTooltip('Toggle transparency', nil, nil, TOP)
    self.transparencyBtn:icon('K3QJsue', 24)
    self.transparencyBtn:SetHoverTum(true)
    self.transparencyBtn:SetBackgroundColor(Color(0, 0, 0, 0))

    local initialTransparency = 80 -- Transparency level on display
    self.transparencyBtn.DoClick = function()
        self.IsTransparent = not self.IsTransparent
        if self.IsTransparent then
            self:SetVisible(true)
            self:AlphaTo(initialTransparency, 0.2) -- Return to full visibility
        else
            self:AlphaTo(255, 0.2) -- Set transparency level
        end
    end
end

--- Includes the ability to resize by the user.
function PANEL:EnableUserResize()
    self.UserResize = customUtils.Create(self)
    self.UserResize:SetMouseInputEnabled(true)
    self.UserResize:SetCursor('sizenwse')
    self.UserResize:SetSize(18, 18)
    self.UserResize:MoveToFront()
    function self.UserResize:OnMousePressed(m)
        self.Dragging = true 
        self.IsResizing = true
    end

    local the = self
    function self.UserResize:Think()
        if (self.Dragging == true) then
            if input.IsMouseDown(MOUSE_LEFT) then
                local x, y = gui.MousePos()
                if (not self.StartingCoords) then self.StartingCoords = {x, y} end
                if (not self.StartingSize) then self.StartingSize = { the:GetSize() } end

                -- Get screen dimensions
                local screenW, screenH = ScrW(), ScrH()
                -- Calculate new dimensions
                local newWidth = math.max(the:GetMinWidth() or 200, math.min(screenW, self.StartingSize[1] + (x - self.StartingCoords[1])))
                local newHeight = math.max(the:GetMinHeight() or 200, math.min(screenH, self.StartingSize[2] + (y - self.StartingCoords[2])))
                -- Set window dimensions
                -- Check if the cursor is within screen bounds
                if (x >= 0 and x <= screenW and y >= 0 and y <= screenH) then
                    -- Set window dimensions only if within screen bounds
                    the:SetSize(newWidth, newHeight)
                end
                the:InvalidateChildren(true)
            else
                self.StartingCoords = nil
                self.StartingSize = nil
                self.Dragging = false
                self.IsResizing = false

                local function recursive(ren)
                    for _, v in ipairs(ren) do
                        if v.RerenderMarkups then v:RerenderMarkups() end
                        recursive(v:GetChildren())
                    end
                end
                recursive(the:GetChildren())
            end
        end
    end

    -- Drawing the resize icon
    self.UserResize:ApplyEvent(nil, function(sl, w, h)
        local size = 16
        utils:DrawIcon(w / 2 - size / 2, h / 2 - size / 2, size, size, 'QAAyhNn', base:Theme('mat'))
    end)
end

local font = 'danlib_font_18'
local color = base:Theme('decor')
function PANEL:PaintOver(w, h)
    if self.IsResizing then
        utils:DrawRect(0, 0, w, h, Color(10, 10, 10, 240))

        draw.SimpleText('Editing the size ', font, w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(string.format('(%dpx x %dpx)', w, h), font, w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(w .. 'px', font, w / 2, h - 15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(h .. 'px', font, w - 15, h / 2, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText(w .. 'px', font, w / 2, 15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(h .. 'px', font, 15, h / 2, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

--- Sets the icon for the frame.
-- @param str (string): Path to the icon.
function PANEL:SetIcon(str)
    self.imgIcon = str
end

--- Sets the minimum dimensions for resizing the frame.
-- @param width (number): Minimum width.
-- @param height (number): Minimum height.
function PANEL:SetMinWMinH(width, height)
    self:SetMinWidth(width)
    self:SetMinHeight(height)
end

--- Performs the layout of frame elements.
-- @param w (number): The width of the frame.
-- @param h (number): The height of the frame.
function PANEL:PerformLayout(w, h)
    -- self.top:SetWide(self:GetWide())
    for _, child in pairs(self:GetChildren()) do child:InvalidateLayout(true) end
    if IsValid(self.UserResize) then self.UserResize:AlignRight(0) self.UserResize:AlignBottom(0) end
    if self.PostPerformLayout then self:PostPerformLayout() end
end

--- Sets the title of the frame.
-- @param str (string): Header.
function PANEL:SetTitle(str)
    self.title:SetText(str or '')
    self.title:SizeToContents()
end

--- Draws the frame.
-- @param w (number): Frame width.
-- @param h (number): The height of the frame.
function PANEL:Paint(w, h)
    if (not self.disableShadows) then
        DanLib.DrawShadow:Begin()
        local x, y = self:LocalToScreen(0, 0)
        utils:DrawRoundedBox(x, y, w, h, self.Background or base:Theme('background'))
        DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)
    else
        utils:DrawRoundedBox(0, 0, w, h, base:Theme('background'))
    end
end

--- Shows or hides the close button.
-- @param show (boolean): Whether to show the button.
function PANEL:ShowCloseButton(show)
    self.closeBtn:SetVisible(show)
end

--- Sets the frame background.
-- @param background (Color): The colour of the background.
function PANEL:SetBackground(background)
    self.Background = background
end

--- Disables or enables shadows.
-- @param disable (boolean): Whether to disable shadows.
function PANEL:DisableShadows(disable)
    self.disableShadows = disable
end

PANEL:SetBase('DFrame')
PANEL:Register('DanLib.UI.Frame')



--- Creates a new frame with the specified parent.
-- @param parent (Panel): Parent element, defaults to nil.
-- @return (DFrame): New frame created.
function base.CreateUIFrame(parent)
    parent = parent or nil

    local DFrame = customUtils.Create(parent, 'DanLib.UI.Frame')
    return DFrame
end











local ui = DanLib.UI
local BASIS, _ = DanLib.UiPanel()

function BASIS:Init()
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:SetTitle('')
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.1)
    self:SetDrawHeader(true)

    self.backButton = base:CreateButton(self)
    self.backButton:Pin()
    self.backButton:SetBackgroundColor(Color(0, 0, 0, 0))
    self.backButton:SetHoverTum(true)
    self.backButton:SetCursor('arrow')
    self.backButton.DoClick = function()
        self:Close()
    end

    self.mainPanel = customUtils.Create(self)
    self.mainPanel:SetSize(ScrW() * 0.15, 0)
    self.mainPanel:Center()
    -- self.mainPanel:ApplyShadow(10, true)
    self.mainPanel.Paint = function(sl, w, h)
        if (not sl.disableShadows) then
            local x, y = sl:LocalToScreen(0, 0)
            DanLib.DrawShadow:Begin()
            utils:DrawRoundedBox(x, y, w, h, base:Theme('background'))
            DanLib.DrawShadow:End(1, 1, 1)
        else
            utils:DrawRoundedBox(0, 0, w, h, base:Theme('background'))
        end
    end

    self.mainPanel.OnSizeChanged = function(sl)
        sl:Center()
    end

    self.top = customUtils.Create(self.mainPanel)
    self.top:Pin(TOP)
    self.top:SetTall(30)
    self.top:DockPadding(0, 0, 0, 2)
    self.top.size = 16
    self.top.Paint = function(sl, w, h)
        if (not self.headerShouldDraw) then return end
        
        utils:DrawRoundedTopBox(0, 0, w, h, base:Theme('line_up'))
        draw.SimpleText(self.headerText or '', 'danlib_font_20', self.strIcon and 34 or 10, h / 2 - 1, base:Theme('text'), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if self.strIcon then
            utils:DrawIconOrMaterial(10, h / 2 - sl.size / 2, sl.size, self.strIcon, self.strIconCol)
        end
    end

    self.closeBtn = base:CreateButton(self.top)
    self.closeBtn:Pin(RIGHT, 2)
    self.closeBtn:SetWide(30)
    self.closeBtn:ApplyTooltip(base:L('#close'), nil, nil, TOP)
    self.closeBtn:icon('jWj7VqX', 18)
    self.closeBtn:SetHoverTum(true)
    self.closeBtn:SetBackgroundColor(Color(0, 0, 0, 0))
    self.closeBtn.DoClick = function()
        self:Close()
    end

    -- Creating a settings button
    self.settingsBtn = base:CreateButton(self.top)
    self.settingsBtn:Pin(RIGHT)
    self.settingsBtn:SetWide(30)
    self.settingsBtn:SetHoverTum(true)
    self.settingsBtn:SetBackgroundColor(Color(0, 0, 0, 0))
    self.settingsBtn:SetVisible(false)

    self.initFinished = true
    self.mainPanel.targetH = self.top:GetTall()
    self.mainPanel:SetTall(self.mainPanel.targetH)

    self.startTime = SysTime()
end

function BASIS:Close()
    self.FullyOpened = false

    if self.OnClose then
        self:OnClose()
    end

    self:AlphaTo(0, 0.2)
    self.mainPanel:SizeTo(self.mainPanel:GetWide(), 0, 0.2, 0, -1, function()
        self:Remove()
    end)
end

function BASIS:DisableShadows(disable)
    self.disableShadows = disable
end

function BASIS:SetHeader(header)
    self.headerText = header
end

function BASIS:SetDrawHeader(shouldDraw)
    self.headerShouldDraw = shouldDraw
end

function BASIS:SetPopupWide(width)
    self.mainPanel:SetWide(width)
end

function BASIS:GetPopupWide()
    return self.mainPanel:GetWide()
end

function BASIS:icon(i, c)
    self.strIcon = i
    self.strIconCol = c
end

function BASIS:GetPopupTall()
    return self.mainPanel.targetH
end

function BASIS:CloseButtonShow(show)
    self.closeBtn:SetVisible(show)
end

--- Sets the function for the settings button.
-- @param show (boolean): Whether to show the button.
-- @param func (function): Function to execute when pressed.
function BASIS:SetSettingsFunc(show, text, icon, func)
    self.settingsBtn:SetVisible(show)
    self.settingsBtn:icon(icon or 'lgHTnoN', 18)
    self.settingsBtn:ApplyTooltip(text or nil, nil, nil, TOP)
    self.settingsBtn.DoClick = func or function() end
end

function BASIS:BackgroundCloseButtonShow(show)
    self.backButton:SetVisible(show)
end

function BASIS:SetExtraHeight(extraH)
    self.mainPanel.targetH = self.top:GetTall() + extraH
    self.mainPanel:SizeTo(self.mainPanel:GetWide(), self.mainPanel.targetH, 0.3, 0, -1, function()
        self.FullyOpened = true

        if (self.OnOpen) then
            self:OnOpen()
        end
    end)
end

function BASIS:OnChildAdded(panel)
    if (not self.initFinished) then
        return
    end

    panel:SetParent(self.mainPanel)
end

function BASIS:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.startTime)
end


BASIS:SetBase('DFrame')
BASIS:Register('DanLib.UI.PopupBasis')