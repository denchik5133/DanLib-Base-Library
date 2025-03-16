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
 


--- DanLib Pages class for creating, managing, and accessing UI pages
local page, page_builder = DanLib.UiClass.Create()


--- Initializes a new page instance
-- @param instance: The new page instance being created
-- @param name: The unique name of the page
function page.Init(instance, name)
	instance:SetName(name)
end


-- Accessors for page properties
page:Accessor('Order', page_builder.Number)
page:Accessor('Icon', page_builder.Icon)
page:Accessor('Name', page_builder.String)
page:Accessor('KeyboardInput', page_builder.Boolean, {default = false})


-- Default function implementations for page events
page.OnClick = function() end
page.AccessСheck = function() end
page.Create = function() end


-- DanLib Pages management
DanLib.Pages = DanLib.Pages or {}
DanLib.Pages_Map = DanLib.Pages_Map or {}


--- Creates a new page instance or retrieves an existing one
-- @param name: The unique name of the page
-- @return: The page instance
function DanLib.Func.CreatePage(name)
	local instance = DanLib.Pages_Map[name]

	if (instance == nil) then
		instance = page:new({}, name), page_builder
		instance.id = #DanLib.Pages + 1
		DanLib.Pages_Map[name] = instance
		DanLib.Pages[instance.id] = DanLib.Pages_Map[name]
	end

	return instance
end
