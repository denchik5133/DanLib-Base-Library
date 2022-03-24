local PANEL = {}

function PANEL:Init()
    self:TDLib()
        :ClearPaint()
        --:Background(DanLib.Config.Theme.Background)
end

vgui.Register('DanLibUI.Panel', PANEL, 'EditablePanel')

