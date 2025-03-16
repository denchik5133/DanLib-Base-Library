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
 *	 @source 		https://github.com/Jaffies/paint/blob/main/lua/paint/main_cl.lua
 */


---@diagnostic disable: deprecated
---Paint library for GMod!
---
---Purpose: drop in replacement to all surface/draw functions. Now there's no need to use them
---
---	Features:
---
---		1) Enchanced lines, with support of linear gradients.
---
---		2) Enchanced rounded boxes. They support stencils, materials and outlines.
---
---		3) Circles. Super fast.
---
--- 	4) Batching. Everything here can be batched to save draw calls. Saves a lot of performance.
---
--- 	5) This library is SUPER fast. Some functions here are faster than default ones.
---
--- 	6) Rectangle support, with support of per-corner gradienting
---
--- 	7) Coordinates do not end up being rounded. Good for markers and other stuff.
---
--- Coded by [@jaffies](https://github.com/jaffies), aka [@mikhail_svetov](https://github.com/jaffies) (formely @michael_svetov) in discord.
--- Thanks to [A1steaksa](https://github.com/Jaffies/paint/pull/1), PhoenixF, [Riddle](https://github.com/Jaffies/paint/pull/2) and other people in gmod discord for various help
---
--- Please, keep in mind that this library is still in development. 
--- You can help the project by contributing to it at [github repository](https://github.com/jaffies/paint)
---@class paint # paint library. Provides ability to draw shapes with mesh power
---@field lines paint.lines # lines module of paint library. Can make batched and gradient lines out of the box
---@field roundedBoxes DanLib.RoundedBoxe # roundedBoxes provide better rounded boxes drawing because it makes them via meshes/polygons you name it.
---@field rects paint.rects # Rect module, gives rects with ability to batch and gradient per corner support
---@field outlines DanLib.Outline # outline module, gives you ability to create hollow outlines with  
---@field batch DanLib.batch Unfinished module of batching. Provides a way to create IMeshes 
---@field examples paint.examples example library made for help people understand how paint library actually works. Can be opened via ``lua_run examples.showHelp()``
---@field blur paint.blur blur library, provides a nice way to retrieve a cheap blur textures/materials
---@field api paint.api 
---@field circles paint.circles Circles! killer.
---@field svg paint.svg
---@field downsampling paint.downsampling

---@alias gradients Color | {[1] : Color, [2]: Color, [3]: Color, [4]: Color, [5]: Color?}
---@alias linearGradient Color | {[1]: Color, [2]: Color}

do
	-- this fixes rendering issues with batching

	---Internal variable made for batching to store Z pos meshes won't overlap each other
	---@private Internal variable. Not meant to use outside
	local Z = 0

	---resets Z to 0
	function DanLib.resetZ()
		Z = 0
	end

	--- Increments Z, meaning that next draw operation will be on top of others while batching (because of it's Z position heh)
	---@return number Z # current Z position
	function DanLib.incrementZ()
		Z = Z + 1
		if (Z > 16384) then DanLib.resetZ() end
		return DanLib.getZ()
	end

	--- Calculates Z position, depending of Z value. Made for batching
	---@return number z # calculated Z position. Is not equal to Z
	function DanLib.getZ()
		return -1 + Z / 8192
	end
end

do -- Additional stuff to scissor rect.
    -- needed for panels, i.e. multiple DScrollPanels clipping.
    local tab = {}
    local len = 0
    local setScissorRect = render.SetScissorRect
    local max = math.max
    local min = math.min

    --- Pushes new scissor rect boundaries to stack. Simmilar to Push ModelMatrix/RenderTarget/Filter(Mag/Min)
    ---@see render.PushRenderTarget # A simmilar approach to render targets.
    ---@param x number # start x position
    ---@param y number # start y position
    ---@param endX number # end x position. Must be bigger than x
    ---@param endY number # end y position. Must be bigger than y
    function DanLib.pushScissorRect(x, y, endX, endY)
        local prev = tab[len]
        if prev then
            x = max(prev[1], x)
            y = max(prev[2], y)
            endX = min(prev[3], endX)
            endY = min(prev[4], endY)
        end

        len = len + 1
        tab[len] = {x, y, endX, endY}
        setScissorRect(x, y, endX, endY, true)
    end

    --- Pops last scissor rect's boundaries from the stack. Simmilar to Pop ModelMatrix/RenderTarget/Filter(Mag/Min)
    ---@see DanLib.pushScissorRect
    function DanLib.popScissorRect()
        tab[len] = nil
        len = max(0, len - 1)

        local newTab = tab[len]
        if newTab then
            setScissorRect(newTab[1], newTab[2], newTab[3], newTab[4], true)
        else
            setScissorRect(0, 0, 0, 0, false)
        end
    end
end

do
	local vector = Vector()
	local coloredMaterial = CreateMaterial( "testMaterial" .. SysTime(), "UnlitGeneric", {
	  ["$basetexture"] = "color/white",
	  ["$model"] = 1,
	  ["$translucent"] = 1,
	  ["$vertexalpha"] = 1,
	  ["$vertexcolor"] = 1
	})

	local recompute = coloredMaterial.Recompute
	local setVector = coloredMaterial.SetVector
	local setUnpacked = vector.SetUnpacked
	local currentR, currentG, currentB, currentA = 255, 255, 255, 255

	---This function provides you a material with solid color, allowing you to replicate ``render.SetColorModulation``/``surface.SetDrawColor``
	---
	---Meant to be used to have paint's shapes have animated colors without rebuilding mesh every time color changes 
	---
	---It will tint every color of shape, but not override it. Meaning that yellow color wont be overriden to blue.
	---
	---instead it will be black because red/green components will be multiplied to 0, and blue component (which is 0, because its yellow) will be mutliplied by 1. Which equeals 0
	---
	---**Note:** You will have to call this function every time the color of coloredMaterial changes, because it uses 1 material and sets its color to what you want
	---Example:
	---```lua
	---DanLib.Outline:Draw(32, 100, 100, 256, 256, {color_white, color_transparent}, DanLib.getColoredMaterial( HSVToColor(RealTime() * 100, 1, 1) ), 16 )
	-----[[It will make halo/shadow with animated color]]
	---```
	---@param color Color color that material will have
	---@return IMaterial coloredMaterial
	function DanLib.getColoredMaterial(color)
		local r, g, b, a = color.r, color.g, color.b, color.a
		if (currentR ~= r or currentG ~= g or currentB ~= b or currentA ~= a) then
			currentR, currentG, currentB, currentA = r, g, b, a
			setUnpacked(vector, r / 255, g / 255, b / 255)
			setVector(coloredMaterial, '$color', vector)
			recompute(coloredMaterial)
		end

		return coloredMaterial
	end
end

do
	-- Helper functions
	-- startPanel - pops model matrix and pushes
	local matrix = Matrix()
	local setField = matrix.SetField
	local pushModelMatrix = cam.PushModelMatrix
	local popModelMatrix = cam.PopModelMatrix

	---@type Panel
	local panelTab = FindMetaTable('Panel')
	local getSize = panelTab.GetSize
	local pushScissorRect = DanLib.pushScissorRect
	local popScissorRect = DanLib.popScissorRect
	local setScissorRect = render.SetScissorRect

	---
	---Unfortunately, the paint library cannot integrate seamlessly with VGUI and Derma in the way that the surface and draw libraries do.
	---This is because Meshes, which are used by the paint library, can only use absolute screen coordinates whereas the surface and draw libraries are automatically provided with panel-relative coordinates by the VGUI system.
	---
	---In addition, meshes cannot be clipped with the default VGUI clipping system and will behave as though it is disabled.
	---
	---To work around these limitations, you can use this function.
	---@param panel Panel # The panel to draw on.
	---@param pos? boolean # Set to true to autoamtically adjust all future paint operations to be relative to the panel.  Default: true
	---@param boundaries? boolean # Set to true to enable ScissorRect to the size of the panel. Default: false
	function DanLib.startPanel(panel, pos, boundaries, multiply)
		local x, y = panel:LocalToScreen(0, 0)
		if (pos or pos == nil) then
			setField(matrix, 1, 4, x)
			setField(matrix, 2, 4, y)
			pushModelMatrix(matrix, multiply)
		end

		if boundaries then
			local w, h = getSize(panel)
			pushScissorRect(x, y, x + w, y + h)
		end
	end

	---@see DanLib.startPanel # Note: You need to have same arguments for position and boundaries between start and end panel functions.
	---@param pos? boolean # Set to true to autoamtically adjust all future paint operations to be relative to the panel.  Default: true
	---@param boundaries? boolean # Set to true to enable ScissorRect to the size of the panel. Default: false
	function DanLib.endPanel(pos, boundaries)
		if (pos or pos == nil) then popModelMatrix() end
		if boundaries then popScissorRect() end
	end

	do -- since startPanel and endPanel sound stupid and i figured it out only now, i'll make an aliases for them
		DanLib.beginPanel = DanLib.startPanel
		DanLib.stopPanel = DanLib.endPanel

		-- DanLib.beginPanel -> DanLib.endPanel (like in Pascal language, or mesh.Begin -> mesh.End)
		-- DanLib.startPanel -> DanLib.stopPanel (start/stop sound cool in pairs)
	end

	local getPanelPaintState = surface.GetPanelPaintState

	---# Starts new VGUI context 
	---A modern alternative to DanLib.startPanel without the need to pass a reference of panel
	---and without the need to manually clip ``DScrollPanel``s.  
	---## Example:  
	---```lua
	---function PANEL:Paint(w, h)
	---	DanLib.startVGUI()
	---		DanLib.RoundedBoxe:Draw(32, 0, 0, w, h, color_white)
	---		--Any other stuff here. Note that surface.* (or surface.* derived) functions will double it's positioning.
	---		--This is all because of surface internal positioning + matrix translation.
	---		--You will need to use only paint.* functions inside paint.start/endVGUI() block.
	---	DanLib.endVGUI()
	---end
	---```
	---@see DanLib.startPanel
	function DanLib.startVGUI()
		local state = getPanelPaintState()
		setField(matrix, 1, 4, state.translate_x)
		setField(matrix, 2, 4, state.translate_y)
		pushModelMatrix(matrix, true)

		if state.scissor_enabled then
			setScissorRect(state.scissor_left, state.scissor_top, state.scissor_right, state.scissor_bottom, true)
		end
	end

	---# Ends new VGUI context 
	---A modern alternative to DanLib.startPanel without the need to pass a reference of panel
	---and without the need to manually clip ``DScrollPanel``s.  
	---@see DanLib.startPanel
	function DanLib.endVGUI()
		popModelMatrix()
		setScissorRect(0, 0, 0, 0, false)
	end

	--- Simple helper function which makes bilinear interpolation
	---@private Internal variable. Not meant to use outside
	---@param x number # x is fraction between 0 and 1. 0 - left side, 1 - right side
	---@param y number # y is fraction between 0 and 1. 0 - top side, 1 - bottom side
	---@param leftTop integer
	---@param rightTop integer
	---@param rightBottom integer
	---@param leftBottom integer
	---@return number result # result of bilinear interpolation
	function DanLib.bilinearInterpolation(x, y, leftTop, rightTop, rightBottom, leftBottom)
		if leftTop == rightTop and leftTop == rightBottom and leftTop == leftBottom then return leftTop end -- Fix (sometimes 255 alpha could get 254, probably double prescision isn't enought or smth like that)
		local top = leftTop == rightTop and leftTop or ( (1 - x) * leftTop + x * rightTop)
		local bottom = leftBottom == rightBottom and leftBottom or ((1 - x) * leftBottom + x * rightBottom) -- more precise checking
		return (1 - y) * top + y * bottom
	end
end

do
	---@class paint.verts
	---@field x number
	---@field y number
	---@field color Color?
	---@field u number?
	---@field v number? # If `u` component is not nil, then it has to be nil too.

	local meshConstructor = Mesh
	local meshBegin = mesh.Begin
	local meshEnd = mesh.End
	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshTexCoord = mesh.TexCoord
	local meshAdvanceVertex = mesh.AdvanceVertex
	local colorWhite = color_white
	local PRIMITIVE_POLYGON = MATERIAL_POLYGON

	---Generates IMesh in order to be cached. Uses modified PolygonVertex struct like DanLib.drawPoly.
	---@param vertices paint.verts[] # Same structure as Struct/PolygonVertex, but also it has `color` component, which default to `color_white`
	---@see surface.drawPoly
	---@return IMesh
	function DanLib.generatePoly(vertices)
		local len = #vertices

		local iMesh = meshConstructor()

		meshBegin(iMesh, PRIMITIVE_POLYGON, len)
			for i = 1, len do
				local v = vertices[i]
				local color = v.color or colorWhite
				meshPosition(v.x, v.y, 0)
				meshColor(color.r, color.g, color.b, color.a)

				if v.u then meshTexCoord(0, v.u, v.v) end
				meshAdvanceVertex()
			end
		meshEnd()

		return iMesh
	end

	local defaultMat = Material('vgui/white')
	local renderSetMaterial = render.SetMaterial

	---Draws polygon, simmirarly to surface.DrawPoly, but made via paint library with color argument addition.
	---@param vertices paint.verts[] # Same structure as Struct/PolygonVertex, but also it has `color` component, which default to `color_white`
	---@param material IMaterial? Material which will be used. Default is ``vgui/white``
	---@see surface.DrawPoly
	function DanLib.drawPoly(vertices, material)
		local len = #vertices
		renderSetMaterial(material or defaultMat)
		meshBegin(PRIMITIVE_POLYGON, len)
			for i = 1, len do
				local v = vertices[i]

				local color = v.color or colorWhite
				meshPosition(v.x, v.y, 0)
				meshColor(color.r, color.g, color.b, color.a)

				if v.u then
					meshTexCoord(0, v.u, v.v)
				end

				meshAdvanceVertex()
			end
		meshEnd()
	end
end

do
	local tab = {}

	-- When designing paint library i forgot that some third party libraries could use colors in pretty the same hacky way as i was
	-- This func will move all color refs to outer table instead of mofifying color itself
	---@param len integer
	---@param color Color
	function DanLib.getColorTable(len, color)
		for i = 1, len do
			tab[i] = color
		end

		return tab
	end
end
