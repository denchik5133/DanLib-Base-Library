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
 


local utils = DanLib.Utils
local customUtils = DanLib.CustomUtils


-- Check if an object is a string
local isstring = isstring
local math = math
local max = math.max
local min = math.min
local Clamp = math.Clamp


local CONTEXT, _ = DanLib.UiPanel()


-- Setting access methods for different properties
AccessorFunc(CONTEXT, 'sOpenSubMenu', 'OpenSubMenu')
AccessorFunc(CONTEXT, 'sDeleteSelf', 'DeleteSelf')
AccessorFunc(CONTEXT, 'sMinimumWidth', 'MinimumWidth')
AccessorFunc(CONTEXT, 'sMaxHeight', 'MaxHeight')


function CONTEXT:Init()
    self:SetIsMenu(true)
    self:SetDrawOnTop(true)
    self:SetDeleteSelf(true)
    self:SetVisible(false)
    self:SetMinimumWidth(utils:ScaleWide(120))
    self:SetMaxHeight(utils:ScaleTall(300))
    self:CustomUtils()
    self:ApplyAttenuation(0.2)
    -- Setting the width of the vertical bar
    self:GetVBar():SetWide(0)
    self:DockMargin(10, 10, 10, 10)

    RegisterDermaMenuForClose(self)
end


-- Adds a panel to the menu
-- @param pnl (Panel) The panel to be added
function CONTEXT:AddPanel(pnl)
    self:AddItem(pnl)
    pnl.ParentMenu = self
end


-- Creates a sub-option button in the menu
-- @param strText (string) The text to display on the button
-- @param strColor (string) The color of the button text
-- @param strIcon (string) The icon to display on the button
-- @return button (Button) The created button
function CONTEXT:CreateOption(strText, strColor, strIcon)
    local con = self
    strText = strText or DanLib.Func:L('#no.data')
    strColor = strColor or DanLib.Func:Theme('title')

    local button = DanLib.Func:CreateButton(self, strText, 'danlib_font_18', strColor)
    button:SetContentAlignment(4)
    button:SetTextInset(strIcon and 42 or 16, 0)
    button:PinMargin(TOP)

    -- Create icon for the button if provided
    if strIcon then
        button.icon = customUtils.Create(button)
        button.icon:SetMouseInputEnabled(false)
        button.icon.Size = 18
        button.icon:ApplyEvent(nil, function(_, w, h)
            local iconSize = button.icon.Size
            utils:DrawIconOrMaterial(w * 0.5 - iconSize * 0.5, h * 0.5 - iconSize * 0.5, iconSize, strIcon, strColor)
        end)
    end

    -- Set submenu for the button
    function button:SetSubMenu(menu)
        self.SubMenu = menu
    end

    -- Create a sub-option
    function button:SubOption()
        local menu = customUtils.Create(nil, 'DanLib.UI.ContextMenu')
        menu:SetVisible(false)
        menu:SetParent(self)
        self:SetSubMenu(menu)
        return menu
    end

    -- Handle cursor hover
    function button:OnCursorEntered()
        local parentMenu = IsValid(self.ParentMenu) and self.ParentMenu or self:GetParent()
        parentMenu:OpenSubMenu(self, self.SubMenu)
    end

    -- Draw the button
    function button:Paint(w, h)
        self:ApplyAlpha(0.3, 255)
        utils:DrawRoundedBox(0, 0, w, h, DanLib.Func:Theme('dmenu_hover', self.alpha))
        self:SetTextColor(strColor)
    end

    -- Handle mouse click
    function button:OnMousePressed(mousecode)
        self.m_MenuClicking = true
        DButton.OnMousePressed(self, mousecode)
    end

    function button:OnMouseReleased(mousecode)
        DButton.OnMouseReleased(self, mousecode)
        if (self.m_MenuClicking and mousecode == MOUSE_LEFT) then
            self.m_MenuClicking = false
            CloseDermaMenus()
        end
    end

    -- Button layout
    function button:PerformLayout(w, h)
        self:SizeToContents()
        self:SetWide(self:GetWide() + 10)

        if strIcon then
            self.icon:SetPos(8, 6)
            self.icon:SetSize(h - 10, h - 10)
        end

        local parentWidth = self:GetParent():GetWide()
        self:SetSize(max(parentWidth, self:GetWide()), 32)
        DButton.PerformLayout(self, w, h)
    end

    return button
end


-- Adds an option to the menu
-- @param strText (string) The text to display on the button
-- @param strColor (string) The color of the button text
-- @param strIcon (string) The icon to display on the button
-- @param onClick (function) The function to call when the button is clicked
-- @return self (CONTEXT) The panel
-- @return pnl (Button) The created button
function CONTEXT:Option(strText, strColor, strIcon, onClick)
    local pnl = self:CreateOption(strText, strColor, strIcon)
    if onClick then pnl:ApplyEvent('DoClick', onClick) end

    self:AddPanel(pnl)
    return self, pnl
end


-- Adds a sub-option to the menu
-- @param strText (string) The text to display on the button
-- @param strColor (string) The color of the button text
-- @param strIcon (string) The icon to display on the button
-- @param onClick (function) The function to call when the button is clicked
-- @return SubMenu (CONTEXT) The created submenu
-- @return pnl (Button) The created button
function CONTEXT:SubOption(strText, strColor, strIcon, onClick)
    local pnl = self:CreateOption(strText, strColor, strIcon)
    local SubMenu = pnl:SubOption(strText, funcFunction)
    if onClick then pnl:ApplyEvent('DoClick', onClick) end

    self:AddPanel(pnl)
    return SubMenu
end


-- Hides the menu
function CONTEXT:Hide()
    local openmenu = self:GetOpenSubMenu()
    if openmenu then openmenu:Hide() end

    self:SetVisible(false)
    self:SetOpenSubMenu(nil)
end


-- Opens a submenu
-- @param item (Panel) The item that triggered the submenu
-- @param menu (CONTEXT) The submenu to open
function CONTEXT:OpenSubMenu(item, menu)
    -- Close the currently open submenu if it exists and does not match the new one
    local openmenu = self:GetOpenSubMenu()
    if IsValid(openmenu) then
        if (openmenu == menu) then return end
        self:CloseSubMenu(openmenu)
    end

    -- Check if the menu is valid
    if (not IsValid(menu)) then return end

    -- Open a new submenu
    local x, y = item:LocalToScreen(self:GetWide() + 4, 0)
    menu:Open(x, y, item)
    self:SetOpenSubMenu(menu)
end

-- Closes a submenu
-- @param menu (CONTEXT) The submenu to close
function CONTEXT:CloseSubMenu(menu)
    if IsValid(menu) then
        menu:Hide()
        self:SetOpenSubMenu(nil)
    end
end


-- Draws the panel
-- @param w (number) The width of the panel
-- @param h (number) The height of the panel
function CONTEXT:Paint(w, h)
    DanLib.DrawShadow:Begin()
    local x, y = self:LocalToScreen()
    utils:DrawRoundedBox(x, y, w, h, DanLib.Func:Theme('dmenu'))
    DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)
end


-- Arranges elements in the panel
-- @param w (number) The width of the panel
-- @param h (number) The height of the panel
function CONTEXT:PerformLayout(w, h)
    local minWidth = self:GetMinimumWidth()
    local maxHeight = self:GetMaxHeight()
    local totalHeight = 0

    for _, v in ipairs(self:GetCanvas():GetChildren()) do
        v:InvalidateLayout(true)
        minWidth = max(minWidth, v:GetWide())
    end

    self:SetWide(minWidth)

    for _, v in ipairs(self:GetCanvas():GetChildren()) do
        v:SetWide(minWidth)
        v:SetPos(0, totalHeight)
        v:InvalidateLayout(true)
        totalHeight = totalHeight + v:GetTall()
    end

    totalHeight = min(totalHeight, maxHeight)
    self:SetTall(totalHeight)
end


-- Opens the menu
-- @param x (number) The x-coordinate to open the menu at
-- @param y (number) The y-coordinate to open the menu at
function CONTEXT:Open(x, y)
    RegisterDermaMenuForClose(self)

    local manual = x and y
    x = x or gui.MouseX()
    y = y or gui.MouseY()

    self:InvalidateLayout(true)

    local w, h = self:GetWide(), self:GetTall()
    self:SetSize(w, h)

    -- Adjust coordinates to fit within screen boundaries
    y = (y + h > ScrH()) and (manual and ScrH() or y - h) or y
    x = (x + w > ScrW()) and (manual and ScrW() or x - w) or x
    y = max(y, 1)
    x = max(x, 1)

    -- Adjust position for modal parent
    local p = self:GetParent()
    if IsValid(p) and p:IsModal() then
        x, y = p:ScreenToLocal(x, y)
        y = min(y, p:GetTall() - h)
        x = min(x, p:GetWide() - w)
        y = max(y, 1)
        x = max(x, 1)
    end

    self:SetPos(x, y)
    self:MakePopup()
    self:SetVisible(true)
    self:SetKeyboardInputEnabled(true)
end

CONTEXT:SetBase('DScrollPanel')
CONTEXT:Register('DanLib.UI.ContextMenu')


-- Creates a UI context menu
-- @param parent (Panel) The parent panel for the context menu
-- @return context (PANEL) The created context menu
function DanLib.Func:UIContextMenu(parent)
    parent = parent or nil
    local context = customUtils.Create(parent, 'DanLib.UI.ContextMenu')
    context:SetParent(parent)
    return context
end











if IsValid(contextFrame) then contextFrame:Remove() end
local function contextTest()
    if IsValid(contextFrame) then contextFrame:Remove() end

    local frame = DanLib.Func.CreateUIFrame()
    contextFrame = frame
    frame:SetSize(400, 400)
    frame:Center()
    frame:MakePopup()

    local button = DanLib.Func.CreateUIButton(frame, {
        dock = {FILL},
        background = {nil},
        hover = {nil},
        -- hoverClick = {nil},
        click = function(sl)
            local menu = DanLib.Func:UIContextMenu()

            menu:Option('Text test', Color(23, 70, 200), nil, function() 
                print('Text test')
            end)

            local snap = menu:SubOption('Text test 2', nil, nil, function()
                print('Text test 2')
            end)
            snap:Option('Text sub test 2', Color(255, 0, 0), nil, function()
                print('Text sub test 3')
            end)

            menu:Option('Text test 3', Color(0, 255, 0), nil, function()
                print('Text test 3')
            end)

            local snap2 = menu:SubOption('Text test 4', nil, nil, function()
                print('Text test 4')
            end)
            local subsnap = snap2:SubOption('Text sub test 4', Color(255, 110, 0), nil, function()
                print('Text sub test 4')
            end)
            subsnap:Option('Text sub test 2', Color(255, 0, 0), nil, function()
                print('Text sub test 3')
            end)
            
            menu:Open()
        end
    })
end
-- contextTest()
