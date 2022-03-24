local PANEL = {}

AccessorFunc(PANEL, 'm_backgroundColor', 'BackgroundColor')
AccessorFunc(PANEL, 'm_rounded', 'Rounded')
AccessorFunc(PANEL, 'm_placeholder', 'Placeholder')
AccessorFunc(PANEL, 'm_textColor', 'TextColor')
AccessorFunc(PANEL, 'm_placeholderColor', 'PlaceholderColor')

function PANEL:Init()

	self.MainText = "Option Title"
	self.SecondaryText = "Option Description String Goes Here"
	self.optionString = "nnn"
	self.numeric = false
	self.stripSpaces = false

    local theme = Color(55, 55, 55)

	self:SetBackgroundColor(Color(theme.r + 16, theme.g + 16, theme.b + 16))
	self:SetRounded(0)
	self:SetPlaceholder('')
	self:SetTextColor(Color(205, 205, 205, 200))
	self:SetPlaceholderColor(Color(120, 120, 120))

	self.textentry = vgui.Create('DTextEntry', self)
	self.textentry:Dock(FILL)
	self.textentry:DockMargin(5, 0, 5, 0)
	self.textentry:SetFont('font_sans_21')
    self.textentry:SetDrawLanguageID(false)
	self.textentry.Paint = function(pnl, w, h)
		local col = self:GetTextColor()
		
		pnl:DrawTextEntryText(col, col, col)

		if (#pnl:GetText() == 0) then
			draw.SimpleText(self:GetPlaceholder() or '', pnl:GetFont(), 3, pnl:IsMultiline() and 8 or h / 2, self:GetPlaceholderColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	self.textentry.OnEnter = function( val )
        self.textentry:SetTextColor( Color( 0, 200, 0, 255 ) )
        if self.textentry then
            self.textentry:SetValue( val:GetText():gsub( " ", "" ) )
            DanLib:SendOptionUpdate( self.optionString, val:GetText():gsub( " ", "" ) )
        else
            self.textentry:SetValue( val:GetText() )
            DanLib:SendOptionUpdate( self.optionString, val:GetText() )
        end
    end

    local function SetInitialValue()
        self.textentry:SetValue( DanLib.Options[self.optionString].value )
    end
end

function PANEL:SetNumeric(bool) 
	self.textentry:SetNumeric(true) 
	self.numeric = bool
end
function PANEL:GetNumeric() return self.textentry:GetNumeric() end
function PANEL:SetUpdateOnType(bool) self.textentry:SetUpdateOnType(true) end
function PANEL:GetUpdateOnType() return self.textentry:GetUpdateOnType() end

function PANEL:SetFont(str) self.textentry:SetFont(str) end
function PANEL:GetFont() return self.textentry:GetFont() end
function PANEL:GetText() return self.textentry:GetText() end
function PANEL:SetText(str) self.textentry:SetText(str) end

function PANEL:SetEnterAllowed(val)
    self.textentry:SetEnterAllowed(val)
end

function PANEL:SetMultiline(val)
    self.textentry:SetMultiline(val)
end

function PANEL:SetPlaceholderText(val)
    self.textentry:SetPlaceholderText(val)
end

function PANEL:SetOptionString( str )
	self.optionString = str
end

function PANEL:GetOptionString()
	return self.optionString
end

function PANEL:SetPrimaryText( str )
	self.MainText = str
end

function PANEL:SetSecondaryText( str )
	self.SecondaryText = str
end

function PANEL:SetValue( str )
	if self.stripSpaces then
		self.textentry:SetValue( tostring(str):gsub( " ", "" ) )
	else
		self.textentry:SetValue( tostring(str) )
	end
end

function PANEL:StripSpaces( bool )
	self.stripSpaces = bool
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

	--[[if self.textentry:IsEditing() then
		surface.SetFont( "font_sans_21" )
		surface.SetTextColor(color_white)
		surface.SetTextPos( 0, 0 )
		surface.DrawText('Press Enter to save the changes')
	end]]
end

vgui.Register('DanLibUI.TextEntry', PANEL)