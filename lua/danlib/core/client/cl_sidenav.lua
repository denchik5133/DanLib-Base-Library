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



local NAVIGATION, Constructor = DanLib.UiPanel()


-- Accessors for icon colors
NAVIGATION:Accessor('IconColor', Constructor.Color)
NAVIGATION:Accessor('IconHover', Constructor.Color)


--- Initializes the navigation panel
function NAVIGATION:Init()
	-- Set default colors
	self:SetIconHover(255, 255, 255)

	-- Layout configuration
	self:Dock(LEFT)
	self:DockPadding(8, 8, 8, 8)
	self:SetWide(50)

	-- Container for the icons
	self.container = self:Add('EditablePanel')
	self.container:Dock(FILL)

	-- Layout for the pages
	self.pages = self.container:Add('DIconLayout')
	self.pages:Dock(FILL)
	self.pages:SetSpaceY(10)

	self.activeTab = nil

	-- Close button with functionality
	local close = self:AddIcon(DanLib.Config.Materials['Close'], DanLib.Func:L('#close'), function()
		self.Container:SetAlpha(180)
		self.Container:AlphaTo(0, 0.3)
        self.MainMenu:SetAlpha(255)
        self.MainMenu:AlphaTo(0, 0.2, 0, function()
            self.MainMenu:Remove()
            DanLib.Func:TutorialSequence(4, 7)
        end)

        if IsValid(DANLIB_TUTORIAL) then
            DANLIB_TUTORIAL:SetAlpha(255)
            DANLIB_TUTORIAL:AlphaTo(0, 0.2)
        end
	end)
	close:Dock(BOTTOM)
end


--- Adds a new tab to the navigation
-- @param ico: The icon for the tab
-- @param name: The display name of the tab
-- @param cback: The callback function when the tab is clicked
function NAVIGATION:AddTab(ico, name, cback)
	return self:AddIcon(ico, name, cback, self.pages)
end


--- Adds an icon to the navigation
-- @param ico: The icon to display
-- @param name: The tooltip text
-- @param cback: The callback function on click
-- @param parent: The parent panel for the icon
-- @return The created icon panel
function NAVIGATION:AddIcon(ico, name, cback, parent)
	local icon = (parent or self.container):Add('EditablePanel'):CustomUtils()
	icon:SetSize(36, 36)
	-- icon:SetColor(self:GetIconColor())
	icon:SetCursor('hand')
	icon.hovered = false
	icon.size = 24
	icon.ActivColor = DanLib.Func:Theme('mat', 150)

	-- Draw the icon
	icon:ApplyEvent(nil, function(sl, w, h)
	    DanLib.Utils:DrawIconOrMaterial(w / 2 - sl.size / 2, h / 2 - sl.size / 2, sl.size, ico, sl.ActivColor)
	end)

	-- Handle hover effects
	icon:ApplyEvent('Think', function(sl)
		if (sl.hovered ~= sl:IsHovered()) then
			sl.hovered = sl:IsHovered()
			sl:Stop()
			sl:ColorTo(sl.hovered and self:GetIconHover() or self:GetIconColor(), 0.3)
		end
	end)

	-- Handle click events
	icon:ApplyEvent('OnMouseReleased', function(sl, mcode)
		if (mcode == MOUSE_LEFT and sl.Click) then
			sl:Click()
			self.activeTab = icon
            self:UpdateActiveTab()
		end
	end)

	icon:ApplyTooltip(name, nil, nil, LEFT)
	icon.Click = cback

	return icon
end


--- Updates the visual state of the active tab
function NAVIGATION:UpdateActiveTab()
    for _, child in ipairs(self.pages:GetChildren()) do
        if (child == self.activeTab) then
            child.ActivColor = DanLib.Func:Theme('mat', 150) -- Colour for the active tab
        else
            child.ActivColor = Color(100, 100, 100) -- Colour for inactive tabs
        end
    end
end


--- Layout function for custom layout logic
function NAVIGATION:PerformLayout(w, h)
	-- Custom layout logic can be added here if needed
end


--- Paint function for custom drawing
function NAVIGATION:Paint(w, h)
	DanLib.Utils:DrawRect(0, 0, w, h, DanLib.Func:Theme('secondary_dark'))
end

NAVIGATION:Register('DanLib.UI.Sidenav')
