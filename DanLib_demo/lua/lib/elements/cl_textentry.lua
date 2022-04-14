local PANEL = {}

AccessorFunc(PANEL, 'm_backgroundColor', 'BackgroundColor')
AccessorFunc(PANEL, 'm_rounded', 'Rounded')
AccessorFunc(PANEL, 'm_placeholder', 'Placeholder')
AccessorFunc(PANEL, 'm_textColor', 'TextColor')
AccessorFunc(PANEL, 'm_placeholderColor', 'PlaceholderColor')

function PANEL:Init()

    local theme = Color(27, 27, 27)

	self:SetBackgroundColor(Color(theme.r + 16, theme.g + 16, theme.b + 16))
	self:SetRounded(6)
	self:SetPlaceholder('')
	self:SetTextColor(Color(205, 205, 205, 200))
	self:SetPlaceholderColor(Color(120, 120, 120))

	self.textentry = vgui.Create('DTextEntry', self)
	self.textentry:Dock(FILL)
	self.textentry:DockMargin(8, 8, 8, 8)
	self.textentry:SetFont('font_sans_21')
    self.textentry:SetDrawLanguageID(false)
	self.textentry.Paint = function(pnl, w, h)
		local col = self:GetTextColor()
		
		pnl:DrawTextEntryText(col, col, col)

		if (#pnl:GetText() == 0) then
			draw.SimpleText(self:GetPlaceholder() or '', pnl:GetFont(), 3, pnl:IsMultiline() and 8 or h / 2, self:GetPlaceholderColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end

function PANEL:SetNumeric(bool) self.textentry:SetNumeric(true) end
function PANEL:GetNumeric() return self.textentry:GetNumeric() end
function PANEL:SetUpdateOnType(bool) self.textentry:SetUpdateOnType(true) end
function PANEL:GetUpdateOnType() return self.textentry:GetUpdateOnType() end

function PANEL:SetFont(str)
	self.textentry:SetFont(str)
end

function PANEL:GetFont()
	return self.textentry:GetFont()
end

function PANEL:GetText()
	return self.textentry:GetText()
end

function PANEL:SetText(str)
	self.textentry:SetText(str)
end

function PANEL:SetEnterAllowed(val)
    self.textentry:SetEnterAllowed(val)
end

function PANEL:SetMultiline(val)
    self.textentry:SetMultiline(val)
end

function PANEL:SetPlaceholderText(val)
    self.textentry:SetPlaceholderText(val)
end

function PANEL:SetMultiLine(state)
	self:SetMultiline(state)
	self.textentry:SetMultiline(state)
end

function PANEL:SetLabel(label, left, textColor, offset)
    if (IsValid(self.label)) then self.label:Remove() end
    
    offset = 0

	self.label = self:Add('DLabel')
	self.label:Dock(left and LEFT or RIGHT)
	self.label:DockMargin(left and 10 or -5, 10, (left and -9 or 8) - offset, 10)
	self.label:SetText(label)
	self.label:SetTextColor(textColor or ColorAlpha(self:GetTextColor(), 175))
	self.label:SetFont(self.textentry:GetFont())
	self.label:SizeToContentsX()
end

function PANEL:PerformLayout(w, h)
end

function PANEL:OnMousePressed()
	self.textentry:RequestFocus()
end

function PANEL:Paint(w, h)
	draw.RoundedBox(self:GetRounded(), 0, 0, w, h, self:GetBackgroundColor())
end

vgui.Register('LIB.TextEntry', PANEL)



local PANEL = {}

function lerpColor(frac, from, to)
    return Color(
		Lerp(frac, from.r, to.r),
		Lerp(frac, from.g, to.g),
		Lerp(frac, from.b, to.b),
		Lerp(frac, from.a, to.a)
	)
end

local soundClick = Sound('mvp/click.ogg')
local soundHover = Sound('mvp/hover3.ogg')

surface.CreateFont('mvp.TextBox', {
    font = 'Proxima Nova Rg',
    size = 16,
    extended = true 
})

function PANEL:Init()

	self:SetTall( 22 )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )

	self:SetCursor( 'hand' )
	self:SetFont( 'mvp.TextBox' )

    self:SetTextColor(COLOR_WHITE)
    self:SetCursorColor(COLOR_WHITE)
end

function PANEL:OnCursorEntered()
	surface.PlaySound(soundHover)
end

function PANEL:DoClickInternal()

	surface.PlaySound(soundClick)
end

function PANEL:Paint( w, h )

    draw.RoundedBox(0, 0, 0, w, h, Color(75,75,75))

	if ( self.GetPlaceholderText && self.GetPlaceholderColor && self:GetPlaceholderText() && self:GetPlaceholderText():Trim() != "" && self:GetPlaceholderColor() && ( !self:GetText() || self:GetText() == "" ) ) then

		local oldText = self:GetText()

		local str = self:GetPlaceholderText()
		if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
		str = language.GetPhrase( str )

		self:SetText( str )
		self:DrawTextEntryText( self:GetPlaceholderColor(), self:GetHighlightColor(), self:GetCursorColor() )
		self:SetText( oldText )

		return
	end

	self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
	return false
end

derma.DefineControl( 'mvp.TextBox', 'A standard Button', PANEL, 'DTextEntry' )