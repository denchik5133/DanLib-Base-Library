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
local utils = DanLib.Utils
local network = DanLib.Network

-- Example of use
local NOTIFY = base.CreateHUD('owner_notify')

local ui = DanLib.UI
local notify_panel
local showNotification = false
local squareSize = 64

if ui:valid(DANLIB_MAINHUD) then DANLIB_MAINHUD:Remove() end
if ui:valid(notify_panel) then notify_panel:Remove() end


network:Receive('DanLib.NotifyNoOwner', function()
    local notificationType = network:ReadString()
    if (notificationType == 'no_owner') then
        showNotification = true
    else
        showNotification = false
    end
end)


function NOTIFY:Create(parent)
    local width, height = 400, 110
    local t = 0.2
    local test = true

    -- Calculate coordinates for the centre of the screen
    local pos_x = 10 -- Centre horizontally
    local pos_y = parent:GetTall() - height - 15 -- Set vertically with 15 pixels indentation

    if showNotification then
        if ui:valid(notify_panel) then return end
        if ui:valid(notify_panel) then notify_panel:Remove() end

        notify_panel = DanLib.CustomUtils.Create(parent)
        notify_panel:SetPos(pos_x, parent:GetTall()) -- Starting position (off screen)
        notify_panel:SetSize(width, height)
        notify_panel:ApplyAttenuation(t)
        notify_panel:MoveTo(pos_x, pos_y, t, 0, -10) -- Move to the desired position
        notify_panel:SetDrawOnTop(true)

        local type_icon = DanLib.TYPE['WARNING']
        local type_color = DanLib.TYPE_COLOR['WARNING']

        notify_panel:ApplyEvent(nil, function(sl, w, h)
            utils:DrawRoundedMask(6, 0, 0, w, h, function()
                utils:DrawRoundedBox(0, 0, w, h, base:Theme('primary_notifi'))
                utils:DrawTextureGradient(0, 0, w, h, 0, 0, 4, 1, ColorAlpha(DanLib.Config.Theme['Red'], 20), 'vgui/alpha-back')
                utils:DrawSquareWithIcon(10, (h - squareSize) / 2, ColorAlpha(DanLib.Config.Theme['Red'], 20), squareSize, DanLib.Config.Materials['Lock'], 6)

                local textWrap = utils:TextWrap(base:L('#rank.no.owner'), 'danlib_font_18', 310)
                draw.DrawText(textWrap, 'danlib_font_18', squareSize + 20, 10, base:Theme('title'), TEXT_ALIGN_LEFT)
            end)
        end)

        local button = base.CreateUIButton(notify_panel, {
            dock = { FILL, 2 },
            background = { nil },
            hover = { nil },
            click = function()
                base:QueriesPopup(base:L('#owner.setup'), base:L('#owner.setup.description'), nil, function()
                    if showNotification then
                        network:Start('DanLib.SetupOwner')
                        network:SendToServer()

                        notify_panel:MoveTo(pos_x, parent:GetTall(), t, nil, nil, function() notify_panel = nil base:TimerSimple(1, DanLib.PopupWelcome) end)
                    else
                        notify_panel:MoveTo(pos_x, parent:GetTall(), t, nil, nil, function() notify_panel = nil end)
                    end
                end)
            end
        })
    else 
        if (not ui:valid(notify_panel) or not ispanel(notify_panel)) then
            notify_panel = nil
            return
        end

        notify_panel:MoveTo(pos_x, parent:GetTall(), t, nil, nil, function()
            notify_panel = nil
        end)
    end

    return notify_panel
end
