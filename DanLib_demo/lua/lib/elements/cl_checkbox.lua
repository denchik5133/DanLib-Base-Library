local function drawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local PANEL = {}
function PANEL:Init()
	self:SetHeight(10)
	self:SetWidth(10)
	self.Gray1 = Color(80,80,80,255)
	self.Gray2 = Color(200,200,200,255)
	self.Green1 = Color(80,110,80,255)
	self.Green2 = Color(160,255,160,255)
	self.circlePos = 3 + self:GetTall() / 2
	self.circleNewPos = self.circlePos
end
function PANEL:Paint()
	local r = self:GetTall() / 2
	if self:GetChecked() then
		draw.RoundedBox( 24, 5, (self:GetTall() / 2) - ( (self:GetTall() / 1.5) / 2 ) , self:GetWide() - 10, self:GetTall() / 1.5, self.Green1 )
		surface.SetDrawColor( self.Green2 )	
		draw.NoTexture()
		self.circleNewPos = math.floor(self:GetWide() - (r+3))
	else
		draw.RoundedBox( 24, 5, (self:GetTall() / 2) - ( (self:GetTall() / 1.5) / 2 ) , self:GetWide() - 10, self:GetTall() / 1.5, self.Gray1 )
		surface.SetDrawColor( self.Gray2 )	
		draw.NoTexture()
		self.circleNewPos = math.ceil(3 + r)
	end
	if self.circleNewPos > self.circlePos then
		self.circlePos = self.circlePos + 1
	elseif self.circleNewPos < self.circlePos then
		self.circlePos = self.circlePos - 1		
	end
	drawCircle( self.circlePos, self:GetTall() / 2 , r, 32 )
end
vgui.Register( 'DanLibUI.Checkbox', PANEL, 'DCheckBox' )


local PANEL = {}
function PANEL:Init()
	self.Checked = false
	self:SetText('')

	self:SetHeight(10)
	self:SetWidth(10)
	self.Gray1 = Color(80,80,80,255)
	self.Gray2 = Color(200,200,200,255)
	self.Green1 = Color(80,110,80,255)
	self.Green2 = Color(160,255,160,255)
	self.circlePos = 3 + self:GetTall() / 2
	self.circleNewPos = self.circlePos
end

function PANEL:DoClick()
	self.Checked = not self.Checked

	if self.onChanged then
		self.onChanged(self.Checked)
	end
end

function PANEL:Paint()
	local r = self:GetTall() / 2
	if self.Checked then
		draw.RoundedBox( 24, 5, (self:GetTall() / 2) - ( (self:GetTall() / 1.5) / 2 ) , self:GetWide() - 10, self:GetTall() / 1.5, self.Green1 )
		surface.SetDrawColor( self.Green2 )	
		draw.NoTexture()
		self.circleNewPos = math.floor(self:GetWide() - (r+3))
	else
		draw.RoundedBox( 24, 5, (self:GetTall() / 2) - ( (self:GetTall() / 1.5) / 2 ) , self:GetWide() - 10, self:GetTall() / 1.5, self.Gray1 )
		surface.SetDrawColor( self.Gray2 )	
		draw.NoTexture()
		self.circleNewPos = math.ceil(3 + r)
	end
	if self.circleNewPos > self.circlePos then
		self.circlePos = self.circlePos + 1
	elseif self.circleNewPos < self.circlePos then
		self.circlePos = self.circlePos - 1		
	end
	drawCircle( self.circlePos, self:GetTall() / 2 , r, 32 )
end
vgui.Register( "DanLibUI.CheckCheckbox", PANEL, "DCheckBox" )