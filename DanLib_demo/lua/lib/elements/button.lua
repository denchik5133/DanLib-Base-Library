local PANEL = {}

surface.CreateFont('DanLib.Button', {
    font = 'Open Sans',
    size = 21,
    weight = 500,
    extended = true
})

function PANEL:Init()
    self:SetFont('DanLib.Button')
    self:SetText('') 

    self:SetTall(25)

    self.m_Text = 'Label'
    self.m_Color = c'Text'

    self:TDLib()
        :ClearPaint()
        :Background(Color(49, 49, 49), 5)
        --:FadeHover()
        --:BarHover(c'Accent')
        :CircleClick(c'AlphaWhite', nil, 35)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'DanLib.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
        --:On('OnCursorEntered', function(s) s:LerpColor('m_Color', c'HoveredText') end)
        --:On('OnCursorExited', function(s) s:LerpColor('m_Color', c'Text') end)
end

function PANEL:Restore()
    self:ClearPaint()
        :Background(Color(49, 49, 49), 5)
        --:FadeHover()
        --:BarHover(c'Accent')
        :CircleClick(c'AlphaWhite', nil, 35)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'DanLib.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
    return self
end

function PANEL:SetBackground(bgColor, hoverColor)
    self:ClearPaint()
        :Background(bgColor or c'DarkBlue')
        --:FadeHover(hoverColor or c'Blue')
        :CircleClick(c'AlphaWhite', nil, 35)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'DanLib.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
    return self
end
 
function PANEL:SetLabel(str)
    self.m_Text = str

    self:InvalidateLayout()

    return self
end

vgui.Register('LIB.Button', PANEL, 'DButton')