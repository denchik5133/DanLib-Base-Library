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
 


local DBase = DanLib.Func
local DCustomUtils = DanLib.CustomUtils.Create


local SCROLLBAR = DanLib.UiPanel()

AccessorFunc(SCROLLBAR, 'm_HideButtons', 'HideButtons')

function SCROLLBAR:Init()
    self.Offset = 0
    self.Scroll = 0
    self.SmoothScroll = 0
    self.CanvasSize = 1
    self.BarSize = 1

    self.btnGrip = DCustomUtils(self, 'DScrollBarGrip')
    self:SetSize(15, 15)
    self:SetHideButtons(false)
end

function SCROLLBAR:SetEnabled(b)
    if (not b) then
        self.Offset = 0
        self:SetScroll(0)
        self.HasChanged = true
    end

    self:SetMouseInputEnabled(b)
    self:SetVisible(b)

    if (self.Enabled ~= b) then
        self:GetParent():InvalidateLayout()

        if self:GetParent().OnScrollbarAppear then
            self:GetParent():OnScrollbarAppear()
        end
    end

    self.Enabled = b
end

function SCROLLBAR:Value()
    return self.Pos
end

function SCROLLBAR:BarScale()
    if (self.BarSize == 0) then
        return 1
    end

    return self.BarSize / (self.CanvasSize + self.BarSize)
end

function SCROLLBAR:SetUp(_barsize_, _canvassize_)
    self.BarSize = _barsize_
    self.CanvasSize = math.max(_canvassize_ - _barsize_, 1)
    self:SetEnabled(_canvassize_ > _barsize_)
    self:InvalidateLayout()
end

function SCROLLBAR:OnMouseWheeled(dlta)
    if (not self:IsVisible()) then
        return false
    end

    if (self.Scroll < 0 or self.Scroll > self.CanvasSize) then
        return self.SmoothScroll
    end

    local OldSmoothScroll = self.SmoothScroll
    local force = 2
    self.SmoothScroll = math.Clamp(self.SmoothScroll - dlta * force, -self.CanvasSize, self.CanvasSize)

    return OldSmoothScroll ~= self.SmoothScroll
end

function SCROLLBAR:Think()
    if (self.SmoothScroll == 0) then
        return
    end

    local speed = FrameTime() * 10

    if (self.SmoothScroll > 0) then
        self.SmoothScroll = math.Clamp(self.SmoothScroll - speed, 0, self.CanvasSize)
    else
        self.SmoothScroll = math.Clamp(self.SmoothScroll + speed, -self.CanvasSize, 0)
    end

    self.Scroll = math.Clamp(self.Scroll + self.SmoothScroll, 0, self.CanvasSize)

    if (self.SmoothScroll > 0) then
        if (self.Scroll >= self.CanvasSize) then
            self.SmoothScroll = 0
        end
    elseif (self.Scroll <= 0) then
        self.SmoothScroll = 0
    end

    self:InvalidateLayout()

    local func = self:GetParent().OnVScroll
    if func then
        func(self:GetParent(), self:GetOffset())
    else
        self:GetParent():InvalidateLayout()
    end
end

function SCROLLBAR:AddScroll(dlta)
    local OldScroll = self:GetScroll()
    dlta = dlta * 25
    self:SetScroll(self:GetScroll() + dlta)

    return OldScroll ~= self:GetScroll()
end

function SCROLLBAR:SetScroll(scrll)
    if (not self.Enabled) then
        self.Scroll = 0
        return
    end

    self.Scroll = math.Clamp(scrll, 0, self.CanvasSize)
    self:InvalidateLayout()

    local func = self:GetParent().OnVScroll
    if func then
        func(self:GetParent(), self:GetOffset())
    else
        self:GetParent():InvalidateLayout()
    end
end

function SCROLLBAR:AnimateTo(scrll, length, delay, ease)
    local anim = self:NewAnimation(length, delay, ease)
    anim.StartPos = self.Scroll
    anim.TargetPos = scrll
    anim.Think = function(anim, pnl, fraction)
        pnl:SetScroll(Lerp(fraction, anim.StartPos, anim.TargetPos))
    end
end

function SCROLLBAR:GetScroll()
    if (not self.Enabled) then
        self.Scroll = 0
    end

    return self.Scroll
end

function SCROLLBAR:GetOffset()
    if (not self.Enabled) then
        return 0
    end

    return self.Scroll * -1
end

function SCROLLBAR:Paint(w, h)
    derma.SkinHook('Paint', 'VScrollBar', self, w, h)
    return true
end

function SCROLLBAR:OnMousePressed()
    local _, y = self:CursorPos()
    local PageSize = self.BarSize
    self.SmoothScroll = 0

    if (y > self.btnGrip.y) then
        self:SetScroll(self:GetScroll() + PageSize)
    else
        self:SetScroll(self:GetScroll() - PageSize)
    end
end

function SCROLLBAR:OnMouseReleased()
    self.Dragging = false
    self.DraggingCanvas = nil
    self:MouseCapture(false)
    self.SmoothScroll = 0
    self.btnGrip.Depressed = false
end

function SCROLLBAR:OnCursorMoved(x, y)
    if (not self.Enabled) then
        return
    end

    if (not self.Dragging) then
        return
    end

    local _, y = self:ScreenToLocal(0, gui.MouseY())
    y = y - self.HoldPos

    local TrackSize = self:GetTall() - self.btnGrip:GetTall()
    y = y / TrackSize
    self.SmoothScroll = 0
    self:SetScroll(y * self.CanvasSize)
end

function SCROLLBAR:Grip()
    if (not self.Enabled) then
        return
    end

    if (self.BarSize == 0) then
        return
    end

    self:MouseCapture(true)
    self.Dragging = true
    local _, y = self.btnGrip:ScreenToLocal(0, gui.MouseY())
    self.HoldPos = y
    self.btnGrip.Depressed = true
end

function SCROLLBAR:PerformLayout()
    local _wide = self:GetWide()
    local _scroll = self:GetScroll() / self.CanvasSize
    local _barSize = math.max(self:BarScale() * self:GetTall(), 10)
    local _track = self:GetTall() - _barSize
    _track = _track + 1
    _scroll = _scroll * _track
    self.btnGrip:SetPos(0, _scroll)
    self.btnGrip:SetSize(_wide, _barSize)
end

SCROLLBAR:Register('DanLib.UI.ScrollBar')





local SCROLL = DanLib.UiPanel()
AccessorFunc(SCROLL, 'Padding', 'Padding')
AccessorFunc(SCROLL, 'pnlCanvas', 'Canvas')

function SCROLL:Init()
    self.pnlCanvas = DCustomUtils(self)
    self.pnlCanvas:ApplyEvent('OnMousePressed', function(sl, code)
        sl:GetParent():OnMousePressed(code)
    end)
    self.pnlCanvas:SetMouseInputEnabled(true)

    self.pnlCanvas.PerformLayout = function(pnl)
        self:PerformLayout()
        self:InvalidateParent()
    end

    self.VBar = DCustomUtils(self, 'DanLib.UI.ScrollBar')
    self.VBar:SetWide(10)
    self.VBar:Dock(RIGHT)
    self:SetPadding(0)
    self:SetMouseInputEnabled(true)
    -- This turns off the engine drawing
    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)
    self:SetPaintBackground(false)

    local VBar = self:GetVBar()
    local alpha = 0
    local cornerRadius = 6
    VBar:CustomUtils()
    VBar:ApplyClearPaint()
    VBar.btnGrip.Paint = function(sl, w, h)
        alpha = (sl:IsHovered() or sl.Depressed) and math.Clamp(alpha + 5, 0, 100) or math.Clamp(alpha - 5, 0, 100)
        draw.RoundedBox(cornerRadius, 0, 0, w, h, DBase:Theme('scroll_dark'))
        surface.SetAlphaMultiplier(alpha / 255)
            draw.RoundedBox(cornerRadius, 0, 0, w, h, DBase:Theme('decor'))
        surface.SetAlphaMultiplier(1)
        self.PaintBackground = true
    end
    VBar.btnGrip:SetCursor('hand')
    VBar:SetCursor('hand')

    self:SetWide(self:GetWide() * 0.75)
    VBar:SetWide(VBar:GetWide() * 0.75)
end

function SCROLL:ToggleScrollBar()
    self:GetVBar():SetWide(0)
end

function SCROLL:AddItem(pnl)
    pnl:SetParent(self:GetCanvas())
end

function SCROLL:OnChildAdded(child)
    self:AddItem(child)
end

function SCROLL:SizeToContents()
    self:SetSize(self.pnlCanvas:GetSize())
end

function SCROLL:GetVBar()
    return self.VBar
end

function SCROLL:GetCanvas()
    return self.pnlCanvas
end

function SCROLL:InnerWidth()
    return self:GetCanvas():GetWide()
end

function SCROLL:Rebuild()
    self:GetCanvas():SizeToChildren(false, true)

    -- Although this behaviour isn't exactly implied, center vertically too
    if (self.m_bNoSizing and self:GetCanvas():GetTall() < self:GetTall()) then
        self:GetCanvas():SetPos(0, (self:GetTall() - self:GetCanvas():GetTall()) * 0.5)
    end
end

function SCROLL:OnMouseWheeled(dlta)
    return self.VBar:OnMouseWheeled(dlta)
end

function SCROLL:OnVScroll(iOffset)
    self.pnlCanvas:SetPos(0, iOffset)
end

function SCROLL:ScrollToChild(panel)
    self:PerformLayout()
    local x, y = self.pnlCanvas:GetChildPosition(panel)
    local w, h = panel:GetSize()
    y = y + h * 0.5
    y = y - self:GetTall() * 0.5
    self.VBar:AnimateTo(y, 0.5, 0, 0.5)
end

function SCROLL:PerformLayout()
    local _tall = self.pnlCanvas:GetTall()
    local _wide = self:GetWide()
    local y_pos = 0
    self:Rebuild()
    self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
    y_pos = self.VBar:GetOffset()

    if (self.VBar.Enabled) then
        _wide = _wide - self.VBar:GetWide()
    end

    self.pnlCanvas:SetPos(0, y_pos)
    self.pnlCanvas:SetWide(_wide)
    self:Rebuild()

    if (_tall ~= self.pnlCanvas:GetTall()) then
        self.VBar:SetScroll(self.VBar:GetScroll()) -- Make sure we are not too far down!
    end
end

function SCROLL:Clear()
    return self.pnlCanvas:Clear()
end

local OldPerformLayout = function(self)
    local _tall = self.pnlCanvas:GetTall()
    local _wide = self:GetWide()
    local y_pos = 0
    self:Rebuild()
    self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
    y_pos = self.VBar:GetOffset()

    if (self.VBar.Enabled) then
        _wide = _wide - self.VBar:GetWide()
    end

    self.pnlCanvas:SetPos(0, y_pos)
    self.pnlCanvas:SetWide(_wide)
    self:Rebuild()

    if (_tall ~= self.pnlCanvas:GetTall()) then
        self.VBar:SetScroll(self.VBar:GetScroll()) -- Make sure we are not too far down!
    end
end

function SCROLL:NewPerformLayout()
    local _tall = self.pnlCanvas:GetTall()
    local _wide = self:GetWide()
    local y_pos = 0
    self:Rebuild()
    self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
    y_pos = self.VBar:GetOffset()

    if self.VBar.Enabled then
        _wide = _wide - self.VBar:GetWide()
    end

    self.pnlCanvas:SetPos(self.VBar:GetWide(), y_pos)
    self.pnlCanvas:SetWide(_wide)
    self:Rebuild()

    if _tall ~= self.pnlCanvas:GetTall() then
        self.VBar:SetScroll(self.VBar:GetScroll())
    end
end

function SCROLL:OldOnVScroll(iOffset)
    self.pnlCanvas:SetPos(0, iOffset)
end

function SCROLL:NewOnVScroll(iOffset)
    self.pnlCanvas:SetPos(self.VBar:GetWide(), iOffset)
end

function SCROLL:SetLeft(b)
    local VBar = self:GetVBar()
    VBar:Dock(b and LEFT or RIGHT)
    self.PerformLayout = b and NewPerformLayout or OldPerformLayout
    self.OnVScroll = b and NewOnVScroll or OldOnVScroll
end

SCROLL:SetBase('DPanel')
SCROLL:Register('DanLib.UI.Scroll')






local CANVAS = DanLib.UiPanel()

AccessorFunc(CANVAS, 'm_iSpace', 'Space')

function CANVAS:Init()
    self.container = self:Add('Panel')
    self:SetSpace(ScreenScale(2))
end

function CANVAS:PerformLayout(w, h)
    self:UpdateSize()
end

function CANVAS:GetPanels()
    return self.container:GetChildren()
end

function CANVAS:CalculateTall()
    local panels = self:GetPanels()
    local count = #panels
    local size = 0

    for index, child in ipairs(panels) do
        if child:IsVisible() then
            local _, top, _, bottom = child:GetDockMargin()

            size = size + child:GetTall()
            size = size + top
            size = size + (index ~= count and bottom or 0)
        end
    end

    return size
end

function CANVAS:UpdateSize()
    local w, h = self:GetWide(), self:CalculateTall()
    self.container:SetSize(w, h)
end

function CANVAS:AddPanel(panel)
    panel:SetParent(self.container)
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, self:GetSpace())

    local class = panel.ClassName or 'Panel'
    if (not class:find('onyx')) then
        onyx.gui.Extend(panel)
    end

    panel:InjectEventHandler('PerformLayout')
    panel:On('PerformLayout', function()
        self:UpdateSize()
    end)

    panel:Call('OnPanelAdded', nil, panel)
end

function CANVAS:OnPanelAdded()

end

CANVAS:Register('DanLib.UI.ScrollCanvas')




--- Horizontal scroll bar
local HORIZONTALSCROLL = DanLib.UiPanel()

function HORIZONTALSCROLL:Init()
    local alpha = 0
    local cornerRadius = 6

    self.scrollBar = DCustomUtils(self)
    self.scrollBar:SetTall(8)
    self.scrollBar:ApplyBackground(DBase:Theme('scroll'), cornerRadius)

    self.scrollBar.grip = DCustomUtils(self.scrollBar, 'DButton')
    self.scrollBar.grip:SetText('')
    self.scrollBar.grip:SetPos(0, 0)
    self.scrollBar.grip:SetSize(0, self.scrollBar:GetTall())
    self.scrollBar.grip:ApplyClearPaint()
    self.scrollBar.grip:ApplyEvent(nil, function(sl, w, h)
        alpha = (sl:IsHovered() or sl.Depressed) and math.Clamp(alpha + 5, 0, 100) or math.Clamp(alpha - 5, 0, 100)
        draw.RoundedBox(cornerRadius, 0, 0, w, h, DBase:Theme('scroll_dark'))
        surface.SetAlphaMultiplier(alpha / 255)
            draw.RoundedBox(cornerRadius, 0, 0, w, h, DBase:Theme('decor'))
        surface.SetAlphaMultiplier(1)
    end)
    self.scrollBar.grip:ApplyEvent('SetScrollX', function(sl, x)
        sl:SetX(math.Clamp(x, 0, self:GetWide() - sl:GetWide()))
    end)
    self.scrollBar.grip:ApplyEvent('OnMousePressed', function(sl)
        sl.mouseStartX = gui.MouseX()
        sl.startX = sl:GetX()
        sl.isDragging = true
    end)
    self.scrollBar.grip:ApplyEvent('OnMouseReleased', function(sl)
        sl.isDragging = false
        sl.mouseStartX = nil
    end)
    self.scrollBar.grip:ApplyEvent('Think', function(sl)
        if (not sl.isDragging) then return end
        if (not input.IsMouseDown(MOUSE_LEFT)) then
            sl.isDragging = false
            sl.mouseStartX = nil
            return
        end
        self:SetScroll((sl.startX + gui.MouseX() - sl.mouseStartX) / (self:GetWide() - sl:GetWide()))
    end)

    self.canvas = DCustomUtils(self)
    self.canvas:SetPos(0, 0)
    self.canvas:SetSize(0, self:GetTall())
    self.canvas:SetZPos(-100)
end

function HORIZONTALSCROLL:OnMouseWheeled(delta)
    self:SetScrollX(self:GetScrollX() + (50 * delta))
end

function HORIZONTALSCROLL:SetScrollX(x)
    local maxX = self:GetWide() - self.canvas:GetWide()
    local newX = math.Clamp(x, maxX, 0)
    self.canvas:SetX(newX)
    self.scrollBar.grip:SetScrollX((self:GetWide() - self.scrollBar.grip:GetWide()) * (math.abs(newX) / math.abs(maxX)))
end

function HORIZONTALSCROLL:GetScrollX()
    return self.canvas:GetX()
end

function HORIZONTALSCROLL:SetScroll(percent)
    self.scrollPercent = math.Clamp(percent, 0, 1)
    local maxX = self:GetWide() - self.canvas:GetWide()
    local newX = math.Clamp(maxX * self.scrollPercent, maxX, 0)
    self.canvas:SetX(newX)
    self.scrollBar.grip:SetScrollX(percent * (self:GetWide() - self.scrollBar.grip:GetWide()))
end

function HORIZONTALSCROLL:GetScroll()
    return self.scrollPercent or 0
end

function HORIZONTALSCROLL:ToggleScrollBar()
    self.scrollBar:SetTall(0)
    self.scrollBar.grip:SetSize(0, 0)
end

function HORIZONTALSCROLL:PerformLayout(w, h)
    self.canvas:SizeToChildren(true)
    self.canvas:SetSize(self.canvas:GetWide(), h)

    if (not IsValid(self.scrollBar)) then return end
    self.scrollBar:SetWide(w)
    self.scrollBar:SetPos(0, h - self.scrollBar:GetTall())
    self:CheckShouldEnable()
end



-- @notes The animation doesn't work properly.
-- @todo Find time to finish it
function HORIZONTALSCROLL:ScrollToChild(child)
    if (not IsValid(child)) then 
        print('Invalid child')
        return 
    end

    local childParent = child:GetParent()
    if (not IsValid(childParent)) then
        -- print('Child parent is invalid')
        return
    end

    -- print('Child Parent:', childParent)

    -- Get the position of the child element and its width
    local childX = child:GetX()  -- Use GetX() to get the X-axis position
    local childWidth = child:GetWide()

    -- print('Child X:', childX, 'Child Width:', childWidth)

    -- Ignore elements with X coordinates equal to 0
    if childX == 0 then
        -- print('Ignoring child at position 0')
        return
    end

    -- Get the current scroll position
    local scrollX = self:GetScrollX()
    -- Calculate the boundaries of the visible area
    local visibleStart = scrollX
    local visibleEnd = visibleStart + self:GetWide()
    -- Initialise variables to store target coordinates
    local targetX = nil

    -- Check if it is necessary to scroll
    if (childX < visibleStart) then
        targetX = childX  -- If the element is to the left of the visible area
    elseif (childX + childWidth > visibleEnd) then
        targetX = childX + childWidth - self:GetWide()  -- If the element is to the right of the visible area
    end

    -- print('Target X:', targetX)

    -- If targetX is defined, scroll
    if targetX and type(targetX) == 'number' then
        local maxX = self:GetWide() - self.canvas:GetWide()
        targetX = math.Clamp(targetX, maxX, 0)
        -- print('Scrolling to:', targetX)
        -- Scrolling with animation
        self:AnimateScrollTo(targetX)
    else
        -- print('No scrolling needed or targetX is not a valid number')
    end
end


function HORIZONTALSCROLL:AnimateScrollTo(targetX)
    local currentX = self:GetScrollX()
    local step = 10 -- Scroll step, can be adjusted for faster or slower speeds

    -- Animation function
    local function scrollStep()
        currentX = currentX + step * (targetX > currentX and 1 or -1) -- Increase or decrease the current position
        if (math.abs(currentX - targetX) < step) then currentX = targetX end -- Reached target

        self:SetScrollX(currentX) -- Set a new scroll position

        if (currentX ~= targetX) then
            -- If you haven't reached the target yet, continue the animation
            DBase:TimerSimple(0.01, scrollStep) -- Start the next step after 10 ms
        else
            -- print('Reached target X:', targetX) -- Debugging information
        end
    end
    scrollStep() -- Start animation
end

function HORIZONTALSCROLL:IsChildVisible(child)
    if (not IsValid(child)) then return false end

    -- Get the position of the child element relative to its parent
    local childX = child:GetPos()
    local childWidth = child:GetWide()
    
    -- Get current scrolling
    local scrollX = self:GetScrollX()
    
    -- Calculate the boundaries of the visible area
    local visibleStart = scrollX
    local visibleEnd = visibleStart + self:GetWide()

    -- Check if the element is visible
    return (childX >= visibleStart and childX + childWidth <= visibleEnd)
end


-- Returns true if the width of the content is greater than the width of the visible area
function HORIZONTALSCROLL:SetScrollCheck()
    local w = self:GetWide()
    return self.canvas:GetWide() < w
end

function HORIZONTALSCROLL:OnChildAdded(child)
    if (not self.canvas) then return end
    child:SetParent(self.canvas)
    self.canvas:SizeToChildren(true)
    self:CheckShouldEnable()
    -- Scroll to a new item
    self:ScrollToChild(child)
end

function HORIZONTALSCROLL:CheckShouldEnable()
    if (not IsValid(self.scrollBar.grip)) then return end

    local w = self:GetWide()
    if (self.canvas:GetWide() > w) then
        self.scrollBar.grip:SetWide(w / 3)
    else
        self.scrollBar.grip:SetWide(0)
    end
end

function HORIZONTALSCROLL:Clear()
    self.canvas:Clear()
end

function HORIZONTALSCROLL:Think()
    if (not input.IsMouseDown(MOUSE_LEFT)) then
        if (not self.isDragging) then return end
        self.isDragging = false
        return
    end

    local startX, startY = self:LocalToScreen(0, 0)
    local endX, endY = startX + self:GetWide(), startY + self:GetTall()
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    local withinBounds = (mouseX >= startX) and (mouseX <= endX) and (mouseY >= startY) and (mouseY <= endY)

    if (not withinBounds) then
        self.isDragging = false
        return
    end

    if (not self.isDragging) then
        self.isDragging = true
        self.dragMouseStartX = mouseX
        self.dragPosStartX = self:GetScrollX()
    end
    self:SetScrollX(self.dragPosStartX + mouseX - self.dragMouseStartX)
end

HORIZONTALSCROLL:Register('DanLib.UI.HorizontalScroll')
