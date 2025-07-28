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
local ui = DanLib.UI
local DCustomUtils = DanLib.CustomUtils.Create
local DUtils = DanLib.Utils
local Table = DanLib.Table

local vector = Vector
local lerp = Lerp
local lerpVector = LerpVector

local math = math
local max = math.max

local string = string
local upper = string.upper

local draw = draw
local DrawText = draw.DrawText

if IsValid(ON_SCREEN_POPUP_NOTIFI) then ON_SCREEN_POPUP_NOTIFI:Remove() end


-- Function for creating notifications on the screen
-- @param title (string): Notification title
-- @param text (string): Notification text
-- @param mIcon (string): Notification icon (type)
-- @param nTime (number): Notification display time (in seconds)
-- @param sColor (Color): The colour of the notification (if not specified, the default colour for the icon type is used)
-- @return frame (DFrame): The notification frame created
function DBase:ScreenNotification(title, text, mIcon, nTime, sColor)
    -- Deleting a previous notification if it exists
    if IsValid(ON_SCREEN_POPUP_NOTIFI) then ON_SCREEN_POPUP_NOTIFI:OldRemove() end

    -- Creating a new notification frame
    local frame = DCustomUtils(nil, 'DFrame')
    ON_SCREEN_POPUP_NOTIFI = frame

    -- Initialising frame parameters
    frame:SetSize(0, 0)
    frame:SetTitle('')
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetDrawOnTop(true)

    -- Setting the title, text and icon
    frame.title = title or DBase:L('#no.data')
    local wrap = 370
    frame.text = DUtils:TextWrap(text, 'danlib_font_20', wrap)
    frame.icon = (DanLib.TYPE[mIcon] or DanLib.TYPE['ERROR'])
    frame.color = (DanLib.TYPE_COLOR[mIcon] or DanLib.TYPE_COLOR['ERROR'])
    frame.time = nTime or 5
    frame.text_h = DUtils:TextSize(frame.text, 'danlib_font_20').h

    local sizeF = 420
    local alpha = 0

    -- Enhanced Paint function with adaptive icons
    function frame.Paint(sl, w, h)
        -- Draw notification background with shadow
        DanLib.DrawShadow:Begin()
            local x, y = sl:LocalToScreen(0, 0)
            DUtils:DrawRoundedBox(x, y, w, h, DBase:Theme('primary_notifi'))
        DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)
        
        -- Draw colored borders
        DUtils:DrawRoundedMask(6, 0, 0, w, h, function()
            DUtils:DrawRoundedBox(0, 0, 4, h, sl.color)
            DUtils:DrawRoundedBox(w - 4, 0, 4, h, sl.color)
        end)
        
        -- Calculate adaptive icon size and position
        local iconSize = DUtils:CalculateAdaptiveIconSize(w, h, 32, 124)
        
        -- Center icon in the right area of notification
        local iconX = w - iconSize - 15
        local iconY = h * 0.5 - iconSize * 0.5
        
        -- Draw adaptive icon
        DUtils:DrawIcon(iconX, iconY, iconSize, iconSize, sl.icon, ColorAlpha(sl.color, alpha - 230))
        
        -- Draw text content
        DrawText(string.upper(sl.title), 'danlib_font_22', 30, 6, ColorAlpha(sl.color, alpha))
        DUtils:DrawParseText(text, 'danlib_font_20', 30, 32, DBase:Theme('text', alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, wrap, TEXT_ALIGN_LEFT)
        
        -- Debug info (only in debug mode)
        if DanLib.DEBUG_MODE then
            draw.SimpleText(string.format('Icon: %dx%d', iconSize, iconSize), 'danlib_font_16', 5, h - 15, Color(255, 255, 255, 100))
        end
    end

    -- Function for creating animation of notification appearance
    function frame.Create(sl)
        sl.drawtext = false
        sl.ProgressSize = 0

        -- Appearance animation
        local anim = sl:NewAnimation(0.4, 0, -1, function()
            frame.drawtext = true
            sl:Remove()
        end)
        anim.Size = vector(sizeF, 44 + sl.text_h, 0)
        anim.Pos = vector(ScrW() / 2 - sl:GetWide() / 2, 40, 0)

        -- Updating size and position during animation
        anim.Think = function(anim, panel, fraction)
            if (not anim.StartSize) then anim.StartSize = vector(panel:GetSize()) end
            if (not anim.StartPos) then anim.StartPos = vector(ScrW() / 2 - sl:GetWide() / 2, 120, 0) end
 
            local size = lerpVector(fraction, anim.StartSize, anim.Size)
            local pos = lerpVector(fraction, anim.StartPos, anim.Pos)
            
            panel:SetSize(sizeF, size.y)  
            panel:SetPos(ScrW() / 2 - sl:GetWide() / 2, 80)
            alpha = lerp(fraction * 0.6, alpha, 255)
        end

        -- Progress animation
        local anim2 = sl:NewAnimation(sl.time, 0, -1, function() end)
        anim2.Size = sizeF
        anim2.Think = function(anim, panel, fraction)
            if not anim.StartSize then anim.StartSize = 0 end
            panel.ProgressSize = lerp(fraction, anim.StartSize, anim.Size)
        end
    end

    -- Overriding the frame deletion method for the disappearance animation
    frame.OldRemove = frame.Remove
    function frame.Remove(sl)
        local anim = sl:NewAnimation(0.4, sl.time, -1, function()
            frame.drawtext = false
            frame:OldRemove()
        end)
        sl.ProgressSize = 0
        anim.Size = vector(sl:GetWide(), 5, 0)
        anim.Pos = vector(ScrW() / 2 - sl:GetWide() / 2, 120, 0)
        anim.Think = function(anim, panel, fraction)
            if (not anim.StartSize) then anim.StartSize = vector(panel:GetSize()) end
            if (not anim.StartPos) then anim.StartPos = vector(panel:GetPos()) end
 
            local size = lerpVector(fraction, anim.StartSize, anim.Size)
            local pos = lerpVector(fraction, anim.StartPos, anim.Pos)
            
            panel:SetSize(size.x, size.y) 
            panel:SetPos(pos.x, 80) -- pos.y
            alpha = lerp(fraction, alpha, 0)
        end
    end

    frame:Create()
    return frame
end


-- Debug mode toggle
concommand.Add('danlib_debug_adaptive', function(pPlayer, cmd, args)
    if (not IsValid(pPlayer)) then
        return
    end
    
    DanLib.DEBUG_MODE = not DanLib.DEBUG_MODE
    print('DanLib Adaptive Scaling Debug Mode: ' .. (DanLib.DEBUG_MODE and 'ON' or 'OFF'))
end)

concommand.Add('popup_debugtest1', function(pPlayer)
    if (pPlayer:SteamID64() ~= '76561198405398290' and pPlayer:SteamID64() ~= '76561199493672657') then
        return false, print 'This command is intended for the developer only. It is only used for testing purposes.'
    end

    DBase:ScreenNotification('CONFIG FILED', "The ability to save data about how a user wants to use an application is an important part of programming. Fortunately, it's a common task for programmers, so much of the work has probably already been done. Find a good library for encoding and decoding into an open format, and you can provide a persistent and consistent user experience.", 'ADMIN')
end)



--- Creates a popup notification in the UI
-- Displays a notification box with a title, message and icon DBased on the notification type.
-- Only one notification can be visible at a time - showing a new one will remove any existing notification.
--
-- @param parent (Panel): The parent panel where the notification will be displayed
-- @param tTitle (string): The title text displayed at the top of the notification
-- @param tText (string): The main message text of the notification
-- @param tType (string): The type of notification which determines its color and icon. Allowed values: 'ADMIN', 'ERROR', 'NOTIFICATION', 'WARNING', 'CONFIRM'
-- @param nTime (number): The time in seconds that the notification will remain visible before automatically closing
--
-- @usage
-- DBase:CreateUIPopupNotifi(mainPanel, 'Success', 'Operation completed successfully!', 'NOTIFICATION', 3)
-- DBase:CreateUIPopupNotifi(frame, 'Warning', 'Your session will expire soon.', 'WARNING', 10)
function DBase:CreateUIPopupNotifi(parent, tTitle, tText, tType, nTime)
    if IsValid(ON_SCREEN_POPUP_NOTIFI) then ON_SCREEN_POPUP_NOTIFI:Remove() end

    tTitle = tTitle or 'nil'
    tText = tText or 'nil'

    local Margin = 6
    local Size = 32

    local debug_pnl = DCustomUtils(parent)
    ON_SCREEN_POPUP_NOTIFI = debug_pnl
    debug_pnl:SetSize(0, 0)
    debug_pnl:SetDrawOnTop(true)

    debug_pnl.time = nTime or 5
    debug_pnl.Mat = (DanLib.TYPE[tType] or DanLib.TYPE['ERROR'])
    debug_pnl.color = (DanLib.TYPE_COLOR[tType] or DanLib.TYPE_COLOR['ERROR'])
    debug_pnl.title = DUtils:TextWrap(tText, 'danlib_font_18', 400)
    local titleX, titleY = DUtils:GetTextSize(debug_pnl.title, 'danlib_font_18')

    debug_pnl:SetWide(380)
    debug_pnl:SetTall(40 + titleY)
    debug_pnl:SetPos(25, parent:GetTall())

    debug_pnl.finalX, debug_pnl.finalY = 25, parent:GetTall() - 25 - debug_pnl:GetTall()
    debug_pnl:MoveTo(debug_pnl.finalX, debug_pnl.finalY, 0.3)

    debug_pnl:ApplyEvent(nil, function(sl, w, h)
        local Color = (sl.color or DBase:Theme('decor'))
        DUtils:DrawRect(0, 0, w, h, DBase:Theme('primary_notifi'))
        DUtils:DrawRoundedMask(6, 0, 0, w, h, function()
            DUtils:DrawRoundedBox(0, 0, 4, h, Color)
            DUtils:DrawRoundedBox(w - 4, 0, 4, h, Color)
        end)
        DUtils:DrawIcon(34 - Size * 0.5, h * 0.5 - Size * 0.5, Size, Size, sl.Mat, Color)

        DrawText(upper(tTitle), 'danlib_font_20', 65, 8, Color)
        DrawText(sl.title, 'danlib_font_18', 65, 30, DBase:Theme('text'))
    end)

    debug_pnl:ApplyEvent('Close', function(sl)
        debug_pnl:MoveTo(debug_pnl.finalX, parent:GetTall(), 0.3, nil, nil, function()
            debug_pnl:Remove()
        end)
    end)

    timer.Create('CreatePopupNotifi', 5, 0, function()
        if (not IsValid(debug_pnl) or not ispanel(debug_pnl)) then
            debug_pnl = nil
            return
        end

        debug_pnl.Close()
    end)

    debug_pnl:ApplyShadow(10, true)
end



local Count = 0
local NotificationPanels = {} -- Table for storing all active notification panels

local function InQuad(fraction, beginning, change)
    return change * (fraction ^ 2) + beginning
end

-- Function to recalculate positions of all active notifications
local function RecalculatePositions()
    -- Sort notifications by index in the table to keep the correct order
    local y_start = 10 -- Small indentation from the top of the screen
    local spacing = 46 -- Vertical spacing between notifications
    
    for i, panel in ipairs(NotificationPanels) do
        local targetY = y_start + (i - 1) * spacing
        local currentX, currentY = panel:GetPos()
        
        -- Create moving animation
        local moveAnim = Derma_Anim('Linear', panel, function(pnl, anim, delta, data)
            pnl:SetPos(currentX, Lerp(delta, currentY, targetY))
        end)
        
        moveAnim:Start(0.3)
        
        -- Update Think function to start animation
        local oldThink = panel.Think
        panel.Think = function(self)
            if moveAnim:Active() then 
                moveAnim:Run() 
            elseif oldThink then
                oldThink(self)
            end
        end
    end
end


--- Side Pop-up Notification
-- Displays a notification message at the side of the screen.
-- The notification will appear with an animation, stay for the specified time, and then fade out.
-- When a notification is removed, all remaining notifications will reposition themselves.
--
-- @param text (string): The text message to display in the notification
-- @param tType (string): The type of notification which determines its color and icon. Allowed values: 'ADMIN', 'ERROR', 'NOTIFICATION', 'WARNING', 'CONFIRM'
-- @param sTime (number): The time in seconds that the notification will remain visible before fading out
--
-- @usage
-- NotificationSystem.SidePopupNotification('This is an important message!', 'WARNING', 5)
-- DBase:SidePopupNotification('Operation completed successfully.', 'NOTIFICATION', 3)
function DBase:SidePopupNotification(text, tType, sTime)
    local w_size
    local x_start = 15
    local y_start = 10 + (#NotificationPanels * 46) -- Start with a small indentation from the top

    text = text or ''
    w_size = DUtils:GetTextSize(text, 'danlib_font_18')

    local debug_pnl = DCustomUtils(parent)
    local height = ui:ClampScaleH(debug_pnl, 40, 40)

    debug_pnl:SetSize(55 + w_size, height)
    debug_pnl:SetPos(x_start, y_start)
    debug_pnl:SetDrawOnTop(true)

    debug_pnl.Size = 22

    debug_pnl.Icon = (DanLib.TYPE[tType] or DanLib.TYPE['ERROR'])
    debug_pnl.Color = (DanLib.TYPE_COLOR[tType] or DanLib.TYPE_COLOR['ERROR'])

    debug_pnl:ApplyEvent(nil, function(sl, w, h)
        DanLib.DrawShadow:Begin()
        local x, y = sl:LocalToScreen(0, 0)
        DUtils:DrawRect(x, y, w, h, DBase:Theme('primary_notifi'))
        DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)

        DUtils:DrawRect(4, 6, 2, h - 12, sl.Color)
        DUtils:DrawRect(w - 6, 6, 2, h - 12, sl.Color)
        DUtils:DrawIcon(12, (h / 2) - (sl.Size / 2), sl.Size, sl.Size, sl.Icon, sl.Color)

        draw.SimpleText(text, 'danlib_font_18', 40, h * 0.5, DBase:Theme('title'), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end)

    -- Add a panel to the table of active notifications
    Table:Add(NotificationPanels, debug_pnl)
    
    local anim = Derma_Anim('Linear', debug_pnl, function(pnl, anim, delta, data)
        -- Do not change vertical position during animation, only transparency
        pnl:SetAlpha(delta * 255)
    end)

    debug_pnl.Think = function(self)
        if anim:Active() then anim:Run() end
    end

    -- Animate for two seconds
    anim:Start(0.5)
    if anim:Active() then anim:Run() end

    DBase:TimerSimple(sTime or 0.5, function()
        local anim2 = Derma_Anim('Linear', debug_pnl, function(pnl, anim, delta, data)
            pnl:SetAlpha(255 - delta * 255)
        end)

        anim2:Start(0.5)
        if anim2:Active() then anim2:Run() end

        debug_pnl.Think = function(self)
            if anim2:Active() then anim2:Run() end
        end
        
        DBase:TimerSimple(0.5, function()
            -- Finding and removing a panel from the table
            for i, panel in ipairs(NotificationPanels) do
                if panel == debug_pnl then
                    table.remove(NotificationPanels, i)
                    debug_pnl:Remove()
                    
                    -- Recalculate the positions of the remaining notifications
                    RecalculatePositions()
                    break
                end
            end
        end)
    end)
end
