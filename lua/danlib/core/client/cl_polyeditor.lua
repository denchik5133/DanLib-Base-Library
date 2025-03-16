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
 


local Table = DanLib.Table


local POLY
local function PolyEditor(ply, cmd, arg)
	POLY = {}
	
	POLY.SnapTo = 20
	POLY.SnapPoints = {1, 2, 5, 10, 20, 50, 100}
	
	POLY.PolygonData = {{}}
	POLY.CurrentPoly = 1

	POLY.Frame = DanLib.Func.CreateUIFrame()
	POLY.Frame:SetSize(ScrW(),ScrH())
	POLY.Frame:SetPos(0,0)
	POLY.Frame:SetTitle('Poly Editor')
	POLY.Frame:MakePopup()
	
	POLY.Background = DanLib.CustomUtils.Create(POLY.Frame)
	POLY.Background:Pin(FILL, 5)
	POLY.Background:SetCursor('blank')

	function POLY.Background:PaintOver(w,h)
		for k, poly in ipairs(POLY.PolygonData)do
			surface.SetTextColor(255, 255, 255, 255)

			for k1, point in ipairs(poly) do
				surface.SetTextPos(point.x - 35, point.y - 50)
				surface.DrawText('x: ' .. point.x .. '; y: ' .. point.y)
				draw.RoundedBox(4, point.x - 2, point.y - 2, 5, 5, Color(0,200,0,100))
			end
			
			local polygoncopy = {}
			table.CopyFromTo(poly or {}, polygoncopy)

			if (k == POLY.CurrentPoly) then
				Table:Add(polygoncopy, {
					x = math.RoundToNearest(self:ScreenToLocal(gui.MouseX()), POLY.SnapTo),
					y = math.RoundToNearest(self:ScreenToLocal(gui.MouseY() - 15), POLY.SnapTo)
				})
			end

			draw.NoTexture()
			surface.SetDrawColor(0, 0, 200, 180)
			surface.DrawPoly(polygoncopy)
		end
		
		draw.RoundedBox(4, math.RoundToNearest(self:ScreenToLocal(gui.MouseX()), POLY.SnapTo) - 2, math.RoundToNearest(self:ScreenToLocal(gui.MouseY() - 15), POLY.SnapTo) - 2, 5, 5, Color(200, 0, 0, 200))
	end

	function POLY.Background:Paint(w,h)
		draw.NoTexture()
		surface.SetDrawColor(60, 60, 60, 255)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetTextPos(math.RoundToNearest(self:ScreenToLocal(gui.MouseX()), POLY.SnapTo) - 35, math.RoundToNearest(self:ScreenToLocal(gui.MouseY() - 15), POLY.SnapTo) - 50)
		surface.SetTextColor(color_white)
		surface.DrawText('x: '..math.RoundToNearest(self:ScreenToLocal(gui.MouseX()), POLY.SnapTo) .. '; y: ' .. math.RoundToNearest(self:ScreenToLocal(gui.MouseY() - 15), POLY.SnapTo))
		
		surface.SetDrawColor(100, 100, 100, 150)

		for i = POLY.SnapTo, ScrW(), POLY.SnapTo do
			surface.DrawLine(i, 0, i, ScrH())
			surface.DrawLine(0, i, ScrW(), i)
		end
	end

	function POLY.Background:OnMousePressed(mc)
		if (mc == MOUSE_LEFT) then
			Table:Add(POLY.PolygonData[POLY.CurrentPoly], {
				x = math.RoundToNearest(self:ScreenToLocal(gui.MouseX()), POLY.SnapTo),
				y = math.RoundToNearest(self:ScreenToLocal(gui.MouseY() - 15), POLY.SnapTo)
			})
		elseif (mc == MOUSE_RIGHT) then
			local menu = DanLib.Func:UIContextMenu()

				menu:Option('Export', nil, nil, ExportPolyData)

				menu:Option('Add Polygon', nil, nil, function()
					POLY.CurrentPoly = POLY.CurrentPoly + 1
					POLY.PolygonData[POLY.CurrentPoly] = {}
				end)

				menu:Option('Clear', nil, nil, function()
					POLY.PolygonData[POLY.CurrentPoly] = {}
				end)

				menu:Option('Clear All', nil, nil, function()
					POLY.PolygonData = {{}}
					POLY.CurrentPoly = 1
				end)

				local snap = menu:SubOption('Snap To...')

				for k, v in pairs(POLY.SnapPoints)do
					snap:Option(v, nil, nil, function()
						POLY.SnapTo = v
					end)
				end

			menu:Open()
		end
	end
	
	POLY.Instruct = vgui.Create('DLabel', POLY.Background)
	POLY.Instruct:SetText('Click anywhere to place a point.')
	POLY.Instruct:SizeToContents()
	POLY.Instruct:Center()
end

function ExportPolyData()
	local rtrn = 'local polydata = {}'

	for key,poly in ipairs(POLY.PolygonData) do
		rtrn = rtrn .. [[

	polydata[]] .. key .. [[] = {}]]
		for key2, point in ipairs(poly) do
			rtrn = rtrn .. [[

		polydata[]] .. key .. [[][]] .. key2 .. [[] = { x = ]] .. point.x .. [[, y = ]] .. point.y .. [[ }]]
		end
	end

	MsgN(rtrn .. ' --Put all this stuff OUTSIDE your paint hook.\n\ntable.foreachi(polydata, function(k,v) surface.DrawPoly(v) end) --Put this in your paint hook.')
	RunConsoleCommand('showconsole')
end

function math.RoundToNearest(num, point)
	num = math.Round(num)
	local possible = { min = 0, max = 0 }

	for i = 1, point do
		if (math.IsDivisible(num + i, point)) then possible.max = num + i end
		if (math.IsDivisible(num - i, point)) then possible.min = num - i end
	end
	
	if (possible.max - num <= num - possible.min) then
		return possible.max
	else
		return possible.min
	end
	
end

function math.IsDivisible(divisor, dividend)
	return math.fmod(divisor, dividend) == 0
end
concommand.Add('polyeditor', PolyEditor)