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

-- Taken from: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/dpropertysheet.lua


local base = DanLib.Func
local utils = DanLib.Utils


local PANEL = {}

AccessorFunc(PANEL, 'm_pPropertySheet', 'PropertySheet')
AccessorFunc(PANEL, 'm_pPanel', 'Panel')

function PANEL:Init()

end

function PANEL:Setup(sText, pPropertySheet, pPanel, strIcon)
	sText = sText or ''
	strColor = strColor or base:Theme('mat')

	self:SetText(sText)
	self:SetTextColor(strColor)
	self:SetPropertySheet(pPropertySheet)
	self:SetPanel(pPanel)

	if strIcon then
		self.Image = DanLib.CustomUtils.Create(self)
		self.Image:Dock(FILL)
		self.Image.Size = base:Scale(32)
        self.Image.Paint = function(sl, w, h)
            utils:DrawIconOrMaterial(w * 0.5 - sl.Size * 0.5, h * 0.5 - sl.Size * 0.5, sl.Size, strIcon, (not self:IsActive() and base:Theme('mat', 150) or color_white))
        end

        self.Image:SetMouseInputEnabled(false)
	end
end

function PANEL:IsActive()
	return self:GetPropertySheet():GetActiveTab() == self
end

function PANEL:DoClick()
	self:GetPropertySheet():SetActiveTab(self)
end

function PANEL:GetTabHeight()
	if (self:IsActive()) then
		return 28
	else
		return 20
	end
end

function PANEL:DragHoverClick(HoverTime)
	self:DoClick()
end

function PANEL:GenerateExample()
	-- Do nothing!
end

PANEL.Paint = function(sl, w, h)
	utils:DrawRect(0, 0, w, h, Color(18, 25, 31))

	local vertices = {
	    {
	    	x = 0,
	    	y = 0
	    },
	    {
	    	x = 10,
	    	y = 0
	    },
	    {
	    	x = 0,
	    	y = 10
	    }
	}

	utils:DrawPoly(vertices, !sl:IsActive() and Color(0, 0, 0, 0) or base:Theme('decor'))
end

PANEL.PaintOver = function(sl, w, h)
	-- Notifi = 10

	-- if (Notifi and Notifi > 0) then
	-- 	local AccSizeX, AccSizeY = utils:GetTextSize(Notifi, 'danlib_font_16')
	-- 	local nX, nY, nW, nH = w - AccSizeX - 10, 4, AccSizeX + 8, 14

	-- 	draw.RoundedBox(10, nX, nY, nW, nH, Color(255, 0, 0))
	-- 	draw.SimpleText(Notifi, 'danlib_font_16', nX + AccSizeX + 4, nY + (nH * 0.5) - 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	-- end
end
derma.DefineControl('DDI.SheetTab', 'A Tab for use on the PropertySheet', PANEL, 'DButton')









local PANEL = {}

AccessorFunc(PANEL, 'm_pActiveTab', 'ActiveTab')
AccessorFunc(PANEL, 'm_fFadeTime', 'FadeTime')

function PANEL:Init()
	local Container = DanLib.CustomUtils.Create(self)-- :DrawTheme(Color(20, 20, 20, 200))
	Container:Dock(LEFT)
	Container:SetWide(base:Scale(62))

	local tabScroller = DanLib.CustomUtils.Create(Container)-- :DrawTheme(Color(20, 20, 20, 100)) -- vgui.Create('DHorizontalScroller', Container)
	tabScroller:Dock(FILL)

	self.animFade = Derma_Anim('Fade', self, self.CrossFade)

	self.Items = {}
	self.Container = Container
	self.tabScroller = tabScroller
end

function PANEL:AddSheet(sText, parent, material, sColor, sTooltip)
	sText = sText or ''
	sColor = sColor or base:Theme('text')

	if (!IsValid(parent)) then
		ErrorNoHalt('DDI.PropertySheet:AddSheet tried to add invalid parent!')
		debug.Trace()
		return
	end

	local Sheet = {}

	Sheet.Name = sText

	Sheet.Button = vgui.Create('DDI.SheetTab', self.tabScroller)
	Sheet.Button:ApplyTooltip(sTooltip, nil, material)
	Sheet.Button:Setup(sText, self, parent, material)

	Sheet.Button:Dock(TOP)
	Sheet.Button:DockMargin(0, 0, 0, 4)
	Sheet.Button:SetTall(base:Scale(55))

	Sheet.Panel = parent

	Sheet.Panel:Dock(FILL)
	Sheet.Panel:DockMargin(4, 0, 0, 0)
	Sheet.Panel.Paint = function(sl, w, h)
		utils:DrawRect(0, 0, w, h, base:Theme('background'))
	end

	Sheet.Panel:SetVisible(false)

	parent:SetParent(self)

	Table:Add(self.Items, Sheet)

	if (not self:GetActiveTab()) then
		self:SetActiveTab(Sheet.Tab)
		Sheet.Panel:SetVisible(true)
	end

	return Sheet
end

function PANEL:SetActiveTab(active)
	if (!IsValid(active) or self.m_pActiveTab == active) then
		return
	end

	if (IsValid(self.m_pActiveTab)) then
		-- Only run this callback when we actually switch a tab, not when a tab is initially set active
		self:OnActiveTabChanged(self.m_pActiveTab, active)

		if (self:GetFadeTime() > 0) then
			self.animFade:Start(self:GetFadeTime(), {
				OldTab = self.m_pActiveTab,
				NewTab = active
			})
		else
			self.m_pActiveTab:GetPanel():SetVisible(false)
		end
	end

	self.m_pActiveTab = active
	self:InvalidateLayout()
end

function PANEL:OnActiveTabChanged(old, new)
	-- For override
end

function PANEL:Think()
	self.animFade:Run()
end

function PANEL:GetItems()
	return self.Items
end

function PANEL:CrossFade(anim, delta, data)
	if (!data or !IsValid(data.OldTab) or !IsValid(data.NewTab)) then
		return
	end

	local old = data.OldTab:GetPanel()
	local new = data.NewTab:GetPanel()

	if (!IsValid(old) && !IsValid(new)) then
		return
	end

	if (anim.Finished) then
		if (IsValid(old)) then
			old:SetAlpha(255)
			old:SetZPos(0)
			old:SetVisible(false)
		end

		if (IsValid(new)) then
			new:SetAlpha(255)
			new:SetZPos(0)
			new:SetVisible(true) -- In case new == old
		end

		return
	end

	if (anim.Started) then
		if (IsValid(old)) then
			old:SetAlpha(255)
			old:SetZPos(0)
		end

		if (IsValid(new)) then
			new:SetAlpha(0)
			new:SetZPos(1)
		end

	end

	if (IsValid(old)) then
		old:SetVisible(true)
		if (!IsValid(new)) then 
			old:SetAlpha(255 * (1 - delta))
		end
	end

	if (IsValid(new)) then
		new:SetVisible(true)
		new:SetAlpha(255 * delta)
	end
end

function PANEL:PerformLayout()
	local ActiveTab = self:GetActiveTab()

	if (!IsValid(ActiveTab)) then
		return
	end

	-- Update size now, so the height is definitiely right.
	ActiveTab:InvalidateLayout(true)

	local ActivePanel = ActiveTab:GetPanel()

	for k, v in pairs(self.Items) do
		if (v.Button:GetPanel() == ActivePanel) then
			if (IsValid(v.Button:GetPanel())) then
				v.Button:GetPanel():SetVisible(true)
			end
		else
			if (IsValid(v.Button:GetPanel())) then
				v.Button:GetPanel():SetVisible(false)
			end
		end
	end

	-- Give the animation a chance
	self.animFade:Run()

end

function PANEL:SwitchToName(name)
	for k, v in pairs(self.Items) do
		if (v.Name == name) then
			v.Button:DoClick()

			return true
		end
	end

	return false
end

function PANEL:SetupCloseButton(func)
	local CloseButton = base:CreateButton(self.Container)

	CloseButton:SetTall(base:Scale(50))
	CloseButton:PinMargin(BOTTOM, nil, 4)
	CloseButton:SetBackgroundColor(Color(18, 25, 31))
	CloseButton:icon(DanLib.Config.Materials['Close'])
	CloseButton:doClick(function()
		if (func) then func() end
	end)
end

function PANEL:CloseTab(tab, bRemovePanelToo)
	for k, v in pairs(self.Items) do
		if (v.Button != tab) then continue end
		table.remove(self.Items, k)
	end

	for k, v in pairs(self.tabScroller.Panels) do
		if (v != tab) then continue end
		table.remove(self.tabScroller.Panels, k)
	end

	-- self.tabScroller:InvalidateLayout(true)

	if (tab == self:GetActiveTab()) then self.m_pActiveTab = self.Items[#self.Items].Button end

	local pnl = tab:GetPanel()
	if (bRemovePanelToo) then pnl:Remove() end

	tab:Remove()

	self:InvalidateLayout(true)

	return pnl
end
derma.DefineControl('DDI.PropertySheet', '', PANEL)