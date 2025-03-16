/***
 *   @addon         DanLib
 *   @version       2.1.8
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
 *   cl_panel.lua
 *   This file defines the PANEL class for creating and managing UI panels 
 *   within the DanLib project. It provides a framework for developers to 
 *   create custom panels by inheriting from existing VGUI classes.
 *
 *   It includes the following functionalities:
 *   - Initializing a new Panel instance with optional metadata.
 *   - Registering the Panel class with VGUI, allowing for inheritance 
 *     from base classes.
 *   - Setting up accessors for class and base class properties.
 *   - Implementing a flexible inheritance mechanism using metatables,
 *     enabling the use of multiple base classes.
 *
 *   The file enhances the UI development capabilities by providing a 
 *   structured way to create and manage custom panels, making it easier 
 *   for developers to build complex user interfaces in their GLua projects.
 *
 *   Example usage:
 *
 *   -- Create a new panel class that inherits from a base class
 *   local MyCustomPanel = DanLib:Panel({
 *       Class = 'MyCustomPanel'
 *   })
 *
 *   -- Set the base class if needed
 *   MyCustomPanel:SetBase('DPanel') -- Inherit from DPanel
 *
 *   -- Register the panel class with VGUI
 *   MyCustomPanel:Register()
 *
 *   function MyCustomPanel:Paint(w, h)
 *       -- Custom rendering logic here
 *       surface.SetDrawColor(255, 0, 0, 255) -- Red color
 *       surface.DrawRect(0, 0, w, h) -- Draw the panel
 *   end
 *
 *   -- Create an instance of the panel and set its position
 *   local panelInstance = MyCustomPanel:new()
 *   panelInstance:SetPos(100, 100)
 *   panelInstance:SetSize(300, 200)
 *   panelInstance:MakePopup() -- Make the panel interactive
 */


local PANEL_Meta = FindMetaTable('Panel')
local Table = DanLib.Table
local PANEL, constructor = DanLib.UiClass.Create()


--- Accessor for the class name of the panel
-- @return: The class name of the panel
PANEL:Accessor('Class')

--- Accessor for the base class of the panel
-- @return: The base class name of the panel
PANEL:Accessor('Base')


--- Initializes a new Panel instance
-- @param new: The new panel instance being created
-- @param metadata: Metadata for the panel, including its class name
function PANEL.init(new, metadata)
	if metadata.Class then
		new:SetClass(metadata.Class)
	end

	new:SetBase('EditablePanel')
	new.Accessor = PANEL.Accessor
end


--- Registers the panel class with VGUI
-- @param class: The name of the class to register
-- @param base: Optional base class(es) to inherit from
function PANEL:Register(class, base)
	class = class or self:GetClass()
	self:SetClass(class)
	vgui.Register(class, self, self:GetBase())

	if base then
		if (istable(base) == false) then
			base = {base}
		end

		local EditablePanel = self:GetBase() == 'EditablePanel'
		local has_base = false

		for i, b in ipairs(base) do
			if (EditablePanel == false) then
				EditablePanel = b == 'EditablePanel'
			end

			base[i] = vgui.GetControlTable(b)

			if (has_base == false and self:GetBase() == b) then
				has_base = true
			end
		end

		if (has_base == false) then
			Table:Add(base, vgui.GetControlTable(self:GetBase()))
		end

		if (EditablePanel == false) then
			Table:Add(base, vgui.GetControlTable('EditablePanel'))
		end

		if (#base < 2) then return end

		getmetatable(vgui.GetControlTable(class)).__index = function(_, k)
			for _, b in ipairs(base) do
				if (b[k] ~= nil) then
					return b[k]
				end
			end
			return PANEL_Meta[k]
		end
	end
end


--- Creates a new panel instance with optional metadata
-- @param metadata: Optional metadata for the panel (e.g., class name)
-- @return: A new panel instance and the constructor function
function DanLib.UiPanel(metadata)
	return PANEL:new({}, metadata or {}), constructor
end
