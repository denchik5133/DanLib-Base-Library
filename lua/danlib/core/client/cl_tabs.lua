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
 *   cl_tabs.lua
 *   This file is responsible for creating and managing a tabbed interface in the DanLib project.
 *
 *   It provides functionality to:
 *   - Initialize a tabbed interface with navigation buttons.
 *   - Add tabs with associated panels.
 *   - Switch between tabs with animations.
 *   - Set the active tab and customize appearance.
 *
 *   The file provides a convenient interface for working with tabs in the project.
 */



local ui = DanLib.UI
local TABS, _ = DanLib.UiPanel()


--- Initializes the tabbed interface.
function TABS:Init()
	self:Dock(FILL)
	self:DockMargin(0, 0, 0, 0)
	
	self.buttonScrollPanel = self:Add('DanLib.UI.HorizontalScroll')
	self.buttonScrollPanel:Dock(TOP)
	self.buttonScrollPanel:SetTall(30)
	self.buttonScrollPanel:CustomUtils()
	self.buttonScrollPanel:ToggleScrollBar()
	self.buttonScrollPanel:ApplyBackground(Color(23, 33, 43))
	
	self.selectedBtn = nil
	self.selectedPanel = nil
	self.selectedIndex = 1
	self.tabCount = 0
	self.tabs = {}
	self.tabButtons = {}
	self.animSpeed = 0.4
end


--- Sets the speed of tab animations.
-- @param speed: The speed for the tab movement animations.
function TABS:SetMoveSpeed(speed)
	self.animSpeed = speed
end


--- Performs layout calculations for the tabs and panels.
-- @param w: The width of the tab panel.
-- @param h: The height of the tab panel.
function TABS:PerformLayout(w, h)
	for k, v in pairs(self.tabs) do
		if (not IsValid(v)) then continue end
		local x, y = v:GetPos()
		v:SetSize(w, h - self.buttonScrollPanel:GetTall() - 8)
		v:SetPos((k - self.selectedIndex) * w + (self:GetPos()), y)
	end
end


--- Adds a new tab with an associated panel.
-- @param text: The text to display on the tab.
-- @param parent: The parent associated with the tab.
-- @param wide: Optional width for the tab.
-- @return: The created tab button.
function TABS:AddTab(parent, text, docs, icon, activeColor, wide)
	local text_w = DanLib.Utils:TextSize(text, 'danlib_font_18').w
	local button = self.buttonScrollPanel:Add('DButton'):CustomUtils()
	button:Pin(LEFT)
	local size_b = icon and 42 or 20
	button:SetWide(text_w + size_b)
	button:SetText('')
	if docs then button:ApplyTooltip(docs or '', nil, nil, TOP) end

	local x, y = parent:GetPos()
	parent:Dock(NODOCK)
	parent:SetVisible(true)
	parent:SetPos(x, self.buttonScrollPanel:GetTall() + 8)
	parent:InvalidateParent(true)
	parent:InvalidateLayout(true)

	if (self.tabCount == 0) then
		self.selectedPanel = parent
		self.selectedBtn = button
	end

	button.text = text
	button:ApplyClearPaint()
	button:ApplyEvent(nil, function(sl, w, h)
		sl:ApplyAlpha(0.4, 10, false, false, self.selectedBtn == button, 155, 0.2)
		DanLib.Utils:DrawRect(0, h - 2, w, 2, ColorAlpha(activeColor or DanLib.Func:Theme('decor2'), sl.alpha))

		local iconColor = DanLib.Func:Theme('mat', sl.alpha)
		local textAlpha = 100 + sl.alpha
		local iconSize = 18
		local iconPosX = w * 0.5 - iconSize * 0.5
        local iconPosY = h * 0.5 - iconSize * 0.5
		if icon then
            DanLib.Utils:DrawIconOrMaterial(8, h * 0.5 - iconSize * 0.5, iconSize, icon, iconColor)
        end
		draw.SimpleText(text, 'danlib_font_18', icon and 32 or 10, self.buttonScrollPanel:GetTall() / 2, DanLib.Func:Theme('title', textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end)

	local tabIndex = self.tabCount + 1
	button:ApplyEvent('DoClick', function(sl)
		self:SelectTab(tabIndex)
	end)

	self.tabCount = tabIndex
	self.tabs[#self.tabs + 1] = parent
	self.tabButtons[#self.tabButtons + 1] = button

	return button
end


--- Selects a tab and animates the transition.
-- @param tabIndex: The index of the tab to select.
function TABS:SelectTab(tabIndex)
    self.selectedIndex = tabIndex
    local parent = self.tabs[tabIndex]
    local tab = self.tabButtons[tabIndex]

    if (self.selectedPanel == parent) then return end

    for k, v in pairs(self.tabs) do
        local x, y = v:GetPos()
        v:MoveTo((k - tabIndex) * v:GetWide() + self:GetPos(), y, self.animSpeed, 0, -1, function()
            self:InvalidateLayout(true)
            v:InvalidateChildren(true)
        end)
    end

    self.selectedPanel = parent
    self.selectedBtn = tab
end



--- Sets the active tab with animation.
-- @param tabIndex: The index of the tab to activate.
function TABS:SetActive(tabIndex)
	if (tabIndex < 1 or tabIndex > self.tabCount) then
		print('Invalid tab index: ' .. tabIndex)
		return
	end

	-- Switch to the first tab first
	if (self.selectedIndex ~= 1) then
		self:SelectTab(1) -- Switch to the first tab
	end
	
	-- After a short delay, switch to the desired tab
	DanLib.Func:TimerSimple(self.animSpeed, function() 
		self:SelectTab(tabIndex) -- Then switch to the specified tab
	end)
end

TABS:Register('DanLib.UI.Tabs')






local function tabs()
	local Frame = DanLib.Func.CreateUIFrame()
	Frame:SetSize(400, 400)
	Frame:Center()
	Frame:MakePopup()
	Frame:SetTitle('Tabs panel')

	local tabs = Frame:Add('DanLib.UI.Tabs')

	-- Create panels for tabs
	local testPanel = vgui.Create('DanLib.UI.Dashboard', tabs)
	local testPanel2 = vgui.Create('DanLib.UI.Dashboard', tabs)
	local testPanel3 = vgui.Create('DanLib.UI.Credits', tabs)
	local testPanel4 = vgui.Create('DanLib.UI.Dashboard', tabs)
	local testPanel5 = vgui.Create('DanLib.UI.Credits', tabs)
	local testPanel6 = vgui.Create('DanLib.UI.Dashboard', tabs)

	-- Add tabs
	tabs:AddTab(testPanel, 'Test Panel')
	tabs:AddTab(testPanel2, 'Test Panel 2')
	tabs:AddTab(testPanel3, 'Test Panel 3')
	tabs:AddTab(testPanel4, 'Test Panel 4')
	tabs:AddTab(testPanel5, 'Test Panel 5')
	tabs:AddTab(testPanel6, 'Test Panel 6')

	-- Set the active tab
	tabs:SetActive(3) -- This will open a third tab
end

concommand.Add('CreateTabsPanel', tabs)
