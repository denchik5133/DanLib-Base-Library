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



local base = DanLib.Func

base:CreateFont('danlib_font_icon_24', 24, 'Font Awesome 5 Pro Solid')


-- Example of use
local url = 'https://raw.githubusercontent.com/denchik5133/DDI-Other-Informations/refs/heads/main/DDI/DanLib/icon_collection.json'

-- Receiving data with callback
-- base:FetchApiContent(url, function(data)
--     -- Function for data output
--     for k, v in pairs(data['icon_collection'] or {}) do
--         print(k, v.name, v.code)  -- Data processing
--     end
-- end)


if IsValid(iconFrame) then iconFrame:Remove() end
local function iconsList()
	if IsValid(iconFrame) then iconFrame:Remove() end

	local frame = base.CreateUIFrame()
	iconFrame = frame
	frame:SetSize(700, 500)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle('Icons List')

	local mainNavPanel = DanLib.CustomUtils.Create(frame):Pin(FILL, 14)
	local tabs = mainNavPanel:Add('DanLib.UI.Tabs'):CustomUtils()

	local collection = base.CreateGridPanel(tabs)
    collection:SetColumns(10)
    collection:SetHorizontalMargin(10)
    collection:SetVerticalMargin(10)
    tabs:AddTab(collection, 'Collection', nil, nil, nil)

    local regular = base.CreateGridPanel(tabs)
    regular:SetColumns(10)
    regular:SetHorizontalMargin(10)
    regular:SetVerticalMargin(10)
    tabs:AddTab(regular, 'Regular', nil, nil, nil)

    local brands = base.CreateGridPanel(tabs)
    brands:SetColumns(10)
    brands:SetHorizontalMargin(10)
    brands:SetVerticalMargin(10)
    tabs:AddTab(brands, 'Brands', nil, nil, nil)

    -- Creating a loading panel with animation
	local loadingPanel = DanLib.CustomUtils.Create(frame)
	loadingPanel:Pin()
	loadingPanel:ApplyBackground(Color(0, 0, 0, 150))

    base:FetchApiContent(url, function(data)
    	loadingPanel:Remove()

    	for k, v in ipairs(data['icon_collection'] or {}) do
		    local text = utf8.char(tonumber(string.format('%s%s', '0x', v.code)))
		    local c = base.CreateUIButton(nil, {
		    	background = { Color(103, 193, 245, 100), 6 },
		    	hover = { Color(103, 193, 245), nil, 6 },
		    	tall = 48,
		    	text = { text, 'danlib_font_icon_24' },
		    	tooltip = { v.name },
		    	click = function() base:ClipboardText(v.code) end
		    })
		    collection:AddCell(c, nil, false)
		end

		for k, v in pairs(data['icon_regular'] or {}) do
			local text = utf8.char(tonumber(string.format('%s%s', '0x', v.code)))
		    local r = base.CreateUIButton(nil, {
		    	background = { Color(103, 193, 245, 100), 6 },
		    	hover = { Color(103, 193, 245), nil, 6 },
		    	tall = 48,
		    	text = { text, 'danlib_font_icon_24' },
		    	tooltip = { v.name },
		    	click = function() base:ClipboardText(v.code) end
		    })
		    regular:AddCell(r, nil, false)
		end

		for k, v in pairs(data['icon_brands'] or {}) do
			local text = utf8.char(tonumber(string.format('%s%s', '0x', v.code)))
		    local b = base.CreateUIButton(nil, {
		    	background = { Color(103, 193, 245, 100), 6 },
		    	hover = { Color(103, 193, 245), nil, 6 },
		    	tall = 48,
		    	text = { text, 'danlib_font_icon_24' },
		    	tooltip = { v.name },
		    	click = function() base:ClipboardText(v.code) end
		    })
		    brands:AddCell(b, nil, false)
		end
	end)
end
-- iconsList()
