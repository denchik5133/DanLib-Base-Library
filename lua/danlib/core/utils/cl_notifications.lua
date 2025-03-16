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
 


local base = DanLib.Func
local ui = DanLib.UI
local customUtils = DanLib.CustomUtils
local utils = DanLib.Utils
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
function base:ScreenNotification(title, text, mIcon, nTime, sColor)
    -- Deleting a previous notification if it exists
    if IsValid(ON_SCREEN_POPUP_NOTIFI) then ON_SCREEN_POPUP_NOTIFI:OldRemove() end

    -- Creating a new notification frame
    local frame = customUtils.Create(nil, 'DFrame')
    ON_SCREEN_POPUP_NOTIFI = frame

    -- Initialising frame parameters
    frame:SetSize(0, 0)
    frame:SetTitle('')
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetDrawOnTop(true)

    -- Setting the title, text and icon
    frame.title = title or base:L('#no.data')
    frame.text = utils:TextWrap(text, 'danlib_font_20', 340)
    frame.icon = (DanLib.TYPE[mIcon] or DanLib.TYPE['ERROR'])
    frame.color = (DanLib.TYPE_COLOR[mIcon] or DanLib.TYPE_COLOR['ERROR'])
    frame.time = nTime or 5
    frame.text_h = utils:TextSize(frame.text, 'danlib_font_20').h

    local sizeF = 420
    local alpha = 0

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

    -- Function for frame rendering
    function frame.Paint(sl, w, h)
        DanLib.DrawShadow:Begin()
            local x, y = sl:LocalToScreen(0, 0)
            utils:DrawRoundedBox(x, y, w, h, base:Theme('primary_notifi'))
        DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)

        utils:DrawRoundedMask(6, 0, 0, w, h, function()
            utils:DrawRoundedBox(0, 0, 4, h, sl.color)
            utils:DrawRoundedBox(w - 4, 0, 4, h, sl.color)
        end)

        local size = 32
        utils:DrawIcon(20, h * 0.5 - size * 0.5, size, size, sl.icon, ColorAlpha(sl.color, alpha))
        DrawText(upper(sl.title), 'danlib_font_22', 65, 6, ColorAlpha(sl.color, alpha))
        utils:DrawParseText(text, 'danlib_font_20', 65, 32, base:Theme('text', alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 340, TEXT_ALIGN_LEFT)
    end

    frame:Create()
    return frame
end


concommand.Add('popup_debugtest1', function(pPlayer)
    if (pPlayer:SteamID64() ~= '76561198405398290' and pPlayer:SteamID64() ~= '76561199493672657') then
        return false, print 'This command is intended for the developer only. It is only used for testing purposes.'
    end

    base:ScreenNotification('CONFIG FILED', "The ability to save data about how a user wants to use an application is an important part of programming. Fortunately, it's a common task for programmers, so much of the work has probably already been done. Find a good library for encoding and decoding into an open format, and you can provide a persistent and consistent user experience.", 'ADMIN')
end)








function base:CreatePopupNotifi(parent, tTitle, tText, tType)
    if IsValid(ON_SCREEN_POPUP_NOTIFI) then ON_SCREEN_POPUP_NOTIFI:Remove() end

    tTitle = tTitle or 'nil'
    tText = tText or 'nil'

    local Margin = 6
    local Size = 32

    local debug_pnl = customUtils.Create(parent)
    ON_SCREEN_POPUP_NOTIFI = debug_pnl
    debug_pnl:SetSize(0, 0)
    debug_pnl:SetDrawOnTop(true)

    debug_pnl.time = nTime or 5
    debug_pnl.Mat = (DanLib.TYPE[tType] or DanLib.TYPE['ERROR'])
    debug_pnl.color = (DanLib.TYPE_COLOR[tType] or DanLib.TYPE_COLOR['ERROR'])
    debug_pnl.title = utils:TextWrap(tText, 'danlib_font_18', 400)
    local titleX, titleY = utils:GetTextSize(debug_pnl.title, 'danlib_font_18')

    debug_pnl:SetWide(380)
    debug_pnl:SetTall(40 + titleY)
    debug_pnl:SetPos(25, parent:GetTall())

    debug_pnl.finalX, debug_pnl.finalY = 25, parent:GetTall() - 25 - debug_pnl:GetTall()
    debug_pnl:MoveTo(debug_pnl.finalX, debug_pnl.finalY, 0.3)

    debug_pnl:ApplyEvent(nil, function(sl, w, h)
        local Color = (sl.color or base:Theme('decor'))
        utils:DrawRect(0, 0, w, h, base:Theme('primary_notifi'))

        local borderR = 2
        utils:DrawRect(4, borderR + 4, borderR, h - borderR - 10, Color)
        utils:DrawRect(w - borderR - 4, borderR + 4, borderR, h - borderR - 10, Color)
        utils:DrawIcon(34 - Size * 0.5, h * 0.5 - Size * 0.5, Size, Size, sl.Mat, Color)

        DrawText(upper(tTitle), 'danlib_font_20', 65, 8, Color)
        DrawText(sl.title, 'danlib_font_18', 65, 30, base:Theme('text'))
    end)

    debug_pnl:ApplyEvent('Close', function(sl)
        sl:MoveTo(sl.finalX, parent:GetTall(), 0.3, nil, nil, function()
            sl:Remove()
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
local function InQuad(fraction, beginning, change)
    return change * (fraction ^ 2) + beginning
end

-- Side Pop-up Notification
--
-- text => Any text you like.
-- 2. tType => Place one of the types. All types: "Admin", "ERROR", "Notification", "Warning", "Confirm".
--    Also with one of the selected type, the color of the icon will change. 
-- 3. sTime => The time is put in seconds. 5 seconds, 10 seconds, 15 seconds, 20 seconds et cetera.
--
-- Example:
--    base:SidePopupNotification('CARROTS. Usually in the household, the word "carrot" refers to the widespread root vegetable of this particular plant, which is usually categorized as a vegetable.', 'Warning', 5)
function base:SidePopupNotification(text, tType, sTime)
    local w_size
    local x_start = 15
    local y_start = ScreenScale(34) + Count * 46

    text = text or ''
    w_size = utils:GetTextSize(text, 'danlib_font_18')

    local debug_pnl = customUtils.Create(parent)
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
        utils:DrawRect(x, y, w, h, base:Theme('primary_notifi'))
        DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)

        utils:DrawRect(4, 6, 2, h - 12, sl.Color)
        utils:DrawRect(w - 6, 6, 2, h - 12, sl.Color)
        utils:DrawIcon(12, (h / 2) - (sl.Size / 2), sl.Size, sl.Size, sl.Icon, sl.Color)

        draw.SimpleText(text, 'danlib_font_18', 40, h * 0.5, base:Theme('title'), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end)

    local anim = Derma_Anim('Linear', debug_pnl, function(pnl, anim, delta, data)
        pnl:SetPos(x_start, InQuad(delta, y_start, -ScreenScale(30)))
        pnl:SetAlpha(delta * 255)
    end)

    debug_pnl.Think = function(self)
        if anim:Active() then anim:Run() end
    end

    -- Animate for two seconds
    anim:Start(0.5)
    if anim:Active() then anim:Run() end

    base:TimerSimple(sTime or 0.5, function()
        local anim2 = Derma_Anim('Linear', debug_pnl, function(pnl, anim, delta, data)
            pnl:SetAlpha(255 - delta * 255)
        end)

        anim2:Start(0.5)
        if anim2:Active() then anim2:Run() end

        debug_pnl.Think = function(self)
            if anim2:Active() then anim2:Run() end
        end
        
        base:TimerSimple(0.5, function ()
            debug_pnl:Remove()
            Count = max(0, Count - 1)
        end)
    end)

    Count = Count + 1
end




local notif_tbl = {}
local InvertNotifications = false -- Put notifications on the bottom right, rather than on the top right

local function AddLegalNotice(text, icon, time)
    text = text or 'No text!'

    local size_x, size_y = utils:GetTextSize(text, 'danlib_font_24')
    local height = base:GetSize(20)

    local debug_pnl = customUtils.Create()
    debug_pnl:SetSize(size_x + base:GetSize(50), size_y + base:GetSize(15))

    for _, v in pairs(notif_tbl) do
        if IsValid(v) then
            height = v:GetTall() + base:GetSize(20) + height
        end
    end

    debug_pnl:SetPos(ScrW() - debug_pnl:GetWide() - base:GetSize(20), (InvertNotifications and (ScrH() - height - debug_pnl:GetTall()) or height))
    debug_pnl:SetDrawOnTop(true)

    debug_pnl.Size = 22
    debug_pnl.Margin = 2
    debug_pnl.Icon = (DanLib.TYPE[icon] or DanLib.TYPE['ERROR'])
    debug_pnl.Color = (DanLib.TYPE_COLOR[icon] or DanLib.TYPE_COLOR['ERROR'])

    debug_pnl:ApplyEvent(nil, function(sl, w, h)
        local Color = (sl.color or base:Theme('decor'))
        utils:DrawRect(0, 0, w, h, base:Theme('primary_notifi'))
        utils:DrawRect(4, 4, sl.Margin, h - 8, Color)
        utils:DrawRect(w - sl.Margin - 4, 4, sl.Margin, h - 8, Color)
        utils:DrawIcon(22 - sl.Size * 0.5, h * 0.5 - sl.Size * 0.5, sl.Size, sl.Size, sl.Icon, Color)

        draw.DrawText(text, 'danlib_font_22', 34, h / 2, base:Theme('title'), TEXT_ALIGN_LEFT)
    end)

    function debug_pnl:OnRemove()
        local height = base:GetSize(50)

        for k, v in pairs(notif_tbl) do
            if (v == self or !IsValid(v)) then
                notif_tbl[k] = nil
                k = k - 1
            else
                v:MoveTo(select(1, v:GetPos()), (InvertNotifications and (ScrH() - height - v:GetTall()) or height), 0.2, 0, 0.3)
                height = v:GetTall() + base:GetSize(20) + height
            end
        end
    end

    base:TimerSimple(time or 5, function()
        if IsValid(debug_pnl) then
            debug_pnl:Remove()
        end
    end)

    Table:Add(notif_tbl, debug_pnl)
end
-- AddLegalNotice()