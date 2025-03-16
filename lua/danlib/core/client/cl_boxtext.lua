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

-- Source: https://github.com/Herover/fancytext/blob/master/lua/autorun/sh_fancytext.lua
if IsValid(DemoTextMenu) then DemoTextMenu:Remove() end
local function DemoBoxText()
	if IsValid(DemoTextMenu) then DemoTextMenu:Remove() end

	DemoTextMenu = DanLib.Func.CreateUIFrame()
	DemoTextMenu:SetSize(600, 340)
	DemoTextMenu:SetTitle('Demo BoxText')
	DemoTextMenu:Center()
	DemoTextMenu:MakePopup()
	DemoTextMenu:EnableUserResize()
	DemoTextMenu:SetMinWMinH(600, 340)
	
	local TEXTBOX = DanLib.CustomUtils.Create(DemoTextMenu, 'DanLib.UI.BoxText')
	TEXTBOX:Pin(FILL, 5)
	TEXTBOX:SetFontInternal('danlib_font_18')
	TEXTBOX:AppendText('Hello my name is Tom im 30 years old and I like to roll in the grass every saturday morning before breakfast.')
	TEXTBOX:AppendText('Hej mit navn er Tom jeg er 30 år gammel og kan godt lide at rulle i græsset hver lørdag morgen før morgenmad.')
	TEXTBOX:AppendText('A tiny text for you.\n')
	TEXTBOX:AppendText('This sentence is')
	-- TEXTBOX:SideToggle()

	TEXTBOX:AppendImage({ mat = Material('icon16/error.png'), w = 16, h = 16 })

	TEXTBOX:AppendText('added using')

	TEXTBOX:AppendFunc(function(h)
		local panel = vgui.Create('AvatarImage')
		panel:SetSize(h, h)
		panel:SetPlayer(LocalPlayer(), 16)
		return { panel = panel, h = h, w = h }
	end)

	TEXTBOX:AppendText(' 2 calls\n')
	TEXTBOX:InsertColorChange(255, 0, 0, 255)
	TEXTBOX:AppendText('1+1')
	TEXTBOX:InsertColorChange(255, 255, 255, 255)
	TEXTBOX:AppendText(' is 2 but ')
	TEXTBOX:InsertColorChange(255, 0, 0, 255)
	TEXTBOX:AppendText('2+2')
	TEXTBOX:InsertColorChange(255, 255, 255, 255)
	TEXTBOX:AppendText(' is 4 while ')
	TEXTBOX:InsertColorChange( 255, 0, 0, 255)
	TEXTBOX:AppendText('4+4')
	TEXTBOX:InsertColorChange(255, 255, 255, 255)
	TEXTBOX:AppendText(' is 8 and ')
	TEXTBOX:InsertColorChange(255, 0, 0, 255)
	TEXTBOX:AppendText('8+8')
	TEXTBOX:InsertColorChange(255, 255, 255, 255)
	TEXTBOX:AppendText(' is 16 which is nice and all but lets eat now that we know all this wonderfull stuff.')
	TEXTBOX:InsertColorChange(0, 255, 0, 255)
	TEXTBOX:AppendText(' Ok? Goood because you need this hehehehe\n')
	TEXTBOX:AppendText(' Ok? Goood because you need this hehehehe\n')
	TEXTBOX:InsertColorChange(255, 0, 255, 255)
	TEXTBOX:AppendText("Så gik den vidst ikke længere hva' det var ellers godt og sundt for alle de indblandede, man må håbe at de ikke kom slemt til skade eller såden noget. Det kan vi jo ikke lide vel? Ok jeg må hellere hoppe fra nu farveller mester løgsovs.\n")
	TEXTBOX:AppendText("Så gik den vidst ikke længere hva' det var ellers godt og sundt for alle de indblandede, man må håbe at de ikke kom slemt til skade eller såden noget. Det kan vi jo ikke lide vel? Ok jeg må hellere hoppe fra nu farveller mester løgsovs.\n")
	TEXTBOX:AppendText("Så gik den vidst ikke længere hva' det var ellers godt og sundt for alle de indblandede, man må håbe at de ikke kom slemt til skade eller såden noget. Det kan vi jo ikke lide vel? Ok jeg må hellere hoppe fra nu farveller mester løgsovs.\n")
	TEXTBOX:AppendText("Så gik den vidst ikke længere hva' det var ellers godt og sundt for alle de indblandede, man må håbe at de ikke kom slemt til skade eller såden noget. Det kan vi jo ikke lide vel? Ok jeg må hellere hoppe fra nu farveller mester løgsovs.\n")
end
concommand.Add('DemoBoxText', DemoBoxText)





local PANEL = {}


function PANEL:Init()
	-- We cant run surface.GetTextSize if the panel is made too early
	self.sepwide, self.chartall = 18, 18

	DanLib.Func:TimerSimple(0.5, function()	
		local wide, tall = surface.GetTextSize(' ')
		self.sepwide = wide
		self.chartall = tall
	end)

	self.lines, self.maxlines, self.curwide, self.curwide, self.margin, self.maxwide, self.scroll = {}, false, 0, 5, 5, 0, 0
	self.fontInternal = false
	-- default font
	self.font = 'danlib_font_18'

	self.pnlCanvas = DanLib.CustomUtils.Create(self)
	self.pnlCanvas:SetMouseInputEnabled(true)
	self.pnlCanvas.PerformLayout = function(sl)
		-- Inner element seems to block parent, bubble!
		self.pnlCanvas.OnMouseReleased = self.OnMouseReleased
		self:_PerformLayout()
		self:InvalidateParent()
	end

	local me = self
	self.pnlCanvas.Paint = function(sl, w, h)
		local color = Color(255, 255, 255, 255)
		local font = me.fontInternal or self.font
		local last_item = false
		
		if font then surface.SetFont(font) end

		local spacer, ctall = surface.GetTextSize( ' ' )
		me.sepwide = spacer
		me.chartall = ctall

		local liney = -ctall

		for l_n = 1, #me.lines do
			l_v = me.lines[l_n]
			local lastx = 0

			if (liney + 2 * me.chartall > me.VBar:GetScroll() and liney + 2 * me.chartall < me.VBar:GetScroll() + me:GetTall() + me.chartall) then
				local h, w = 0, 0

				for i_n = 1, #l_v do
					i_v = l_v[i_n]

					if (i_v[1] == 'text') then
						w = i_v[2].w
						h = i_v[2].h

						self:PaintTextpart(i_v[2].text, font, lastx, liney + ctall, color)
					elseif i_v[1] == 'image' then
						w = i_v[2].w
						h = i_v[2].h

						DanLib.Utils:DrawMaterial(lastx, liney + i_v[2].h, i_v[2].w, i_v[2].h, color_white, i_v[2].mat)
					elseif (i_v[1] == 'textcolor') then
						color = i_v[2]
						w = 0
						h = 0
					elseif (i_v[1] == 'font') then
						spacer, ctall = surface.GetTextSize(' ')
						me.sepwide, me.chartall = spacer, ctall
						font = i_v[2]
						w, h = 0, 0
					elseif (i_v[1] == 'blank') then
						w, h = i_v[2].w, i_v[2].h
					elseif (i_v[1] == 'panel') then
						w, h = i_v[2].w, i_v[2].h
						i_v[2].panel:SetPos(lastx, liney + i_v[2].h)
						i_v[2].panel:SetVisible(true)
					end

					lastx = lastx + w
					last_item = i_v
				end
			else
				for i_n = 1, #l_v do
					i_v = l_v[i_n]

					if (i_v[1] == 'panel') then 
						i_v[2].panel:SetVisible(false)
					elseif (i_v[1] == 'font') then
						spacer, ctall = surface.GetTextSize(' ')
						me.sepwide = spacer
						me.chartall = ctall
						font = i_v[2]
					elseif (i_v[1] == 'textcolor') then
						color = i_v[2]
					end
				end
			end

			liney = liney + me.chartall
		end
	end
	
	-- Create the scroll bar
	self.VBar = DanLib.CustomUtils.Create(self, 'DVScrollBar')
	self.VBar:Pin(RIGHT)
	self.VBar:SetHideButtons(true)

	local alpha = 0
	self.VBar.Paint = function(sl, w, h)
		--DanLib.Utils:DrawRect(0, 0, w, h, DanLib.Func:Theme('scroll'))
	end

	self.VBar.btnGrip.Paint = function(sl, w, h)
		if (sl:IsHovered()) then
		   alpha = math.Clamp(alpha + 6, 0, 255)
		else
		   alpha = math.Clamp(alpha - 6, 0, 100)
		end

		DanLib.Utils:DrawRect(0, 0, w, h, DanLib.Func:Theme('secondary', 150 + alpha))
	end
end


function PANEL:SideToggle()
	self.sideToggle = true
	self.VBar:Dock(LEFT)
end


function PANEL:Tick()

end


function PANEL:Paint(w, h)

end


function PANEL:Think()
	
end


function PANEL:SizeToContents()
	self:SetSize(self.pnlCanvas:GetSize())
end


function PANEL:GetVBar()
	return self.VBar
end


function PANEL:GetCanvas()
	return self.pnlCanvas
end


function PANEL:InnerWidth()
	return self:GetCanvas():GetWide()
end


function PANEL:GetContentWide()
  	return self.maxwide
end


function PANEL:SetW(w)
  	self:SetWide(w)
 	self:GetCanvas():SetWide(w)
end


function PANEL:Rebuild()
	-- Although this behaviour isn't exactly implied, center vertically too
	if (self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall()) then
		self:GetCanvas():SetPos(0, (self:GetTall() - self:GetCanvas():GetTall()) * 0.5)
	end
end


function PANEL:_PerformLayout()
	self.scroll = self.VBar:GetScroll()
	local vbarvisible = self.VBar:IsVisible()
	
	if self.PerformLayout then self:PerformLayout() end

	local Wide = self:GetWide()
	local Tall = self:GetTall()
	local YPos = 0
	
	self.pnlCanvas:SetTall(#self.lines * self.chartall or 7)
	
	self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
	YPos = self.VBar:GetOffset()
		
	self.pnlCanvas:SetPos(self.sideToggle and 20 or 0, self.scroll)
	self.pnlCanvas:SetWide(self.sideToggle and Wide or Wide - 20)
	
	self.VBar:SetScroll(self.scroll)
	self.VBar:SetVisible(vbarvisible)
end


function PANEL:OnMouseWheeled(dlta)
	return self.VBar:OnMouseWheeled(dlta)
end


function PANEL:OnVScroll(iOffset)
	self.pnlCanvas:SetPos(self.sideToggle and 20 or 0, iOffset)
end


function PANEL:Clear()
	return self.pnlCanvas:Clear()
end


function PANEL:GotoTextEnd()
	self.VBar:SetScroll(self.pnlCanvas:GetTall())
end


function PANEL:SetVerticalScrollbarEnabled(bool)
	self.VBar:SetEnabled(bool)
	self.VBar:SetVisible(bool)
end


function PANEL:SetFontInternal(font)
	self:InsertFontChange(font)
	self.fontInternal = font
end


function PANEL:AppendItem(item)
	if (type(item) == 'string') then return self:AppendText(item) end

	if (self.maxlines and #self.lines > self.maxlines) then
		table.remove(self.lines, 1)
	end

	local wide = item[2].w

	if (self.curwide + wide < self:GetWide() - self.margin * 2) then
		-- If above passes, theres enough room to add another word
		self.curwide = self.curwide + wide
		Table:Add(self.lines[#self.lines], item)
    	self.maxwide = math.max(self.curwide, self.maxwide)
	else
		-- Otherwise add another line before inserting part
    	Table:Add(self.lines, {})
    	self.maxwide = math.max(self.curwide, self.maxwide)
		self.curwide = wide
		Table:Add(self.lines[#self.lines], item)
	end
	
	self:_PerformLayout()
end


function PANEL:AppendText(text)
	-- Split newlines in sections
	local etext = string.Explode('\n', text)
	surface.SetFont(self.fontInternal and self.fontInternal or self.font)

	-- Loop lines
	for l, line in pairs(etext) do
		-- Split spaces, perhaps find another way to split seperators
		local parts = string.Explode(' ', line)

		for n, part in pairs(parts) do
			local wide, tall = surface.GetTextSize(part)
			-- I dont know why this is possible
			if (part != '' and part != ' ') then
				self:AppendItem({ 'text', { text = part, w = wide, h = tall }})
				self:AppendItem({ 'blank', { w = 4, h = tall }})
			end
		end

		-- Begin new line, except if it's the last line
		if (l != #etext) then
      	self.maxwide = math.max(self.curwide, self.maxwide)
			self.lines[#self.lines + 1] = {}
			self.curwide = 0
		end
	end
  
  	self.maxwide = math.max(self.curwide, self.maxwide)
	self:_PerformLayout()
end


function PANEL:AppendImage(info)
	self:AppendItem({ 'image', info })
	self:_PerformLayout()
end


function PANEL:AppendFunc(fn)
	local info = fn(self.chartall)
	info.panel:SetParent(self.pnlCanvas)

	self.pnlCanvas:Add(info.panel)
	self:AppendItem({ 'panel', info })
end


function PANEL:InsertColorChange(r, g, b, a)
  	if (#self.lines == 0) then Table:Add(self.lines, {}) end
	Table:Add(self.lines[#self.lines], { 'textcolor', Color(r, g, b, a) })
end


function PANEL:InsertFontChange(font)
  	if (#self.lines == 0) then Table:Add(self.lines, {})	end
	Table:Add(self.lines[#self.lines], { 'font', font })
	surface.SetFont(font)
end


function PANEL:PaintTextpart(text, font, x, y, colour)
	surface.SetFont(font)
	surface.SetTextPos(x, y)
	surface.SetTextColor(colour)
	surface.DrawText(text)
end

function PANEL:OnMouseReleased() end
vgui.Register('DanLib.UI.BoxText', PANEL)