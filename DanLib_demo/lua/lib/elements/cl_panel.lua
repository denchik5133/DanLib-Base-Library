local PANEL = {}

function PANEL:Init()
    self:TDLib()
        :ClearPaint()
        --:Background(LIB.Config.Theme.Background)
end

vgui.Register('LIB.Panel', PANEL, 'EditablePanel')

