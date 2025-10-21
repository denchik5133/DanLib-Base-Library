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
 


--- Welcome pop-up window for a user using the DanLib library.
-- @module PopupWelcome

local width = DanLib.Func:GetSize(500)
local height = DanLib.Func:GetSize(450)


-- Updating width and height when the screen size changes
local function ScreenSizeChanged()
    width = DanLib.Func:GetSize(500)
    height = DanLib.Func:GetSize(450)
end
DanLib.Hook:Add('DDI.PostScreenSizeChanged', 'DDI.ScreenSizeChanged', ScreenSizeChanged)


--- The main function to display the welcome pop-up window.
-- @function PopupWelcome
function DanLib.PopupWelcome()
    if (not DanLib.FileUtil.Exists('danlib/welcome_' .. GetHostName() .. '.txt')) then return end
    if IsValid(MainFrame) then MainFrame:Remove() end
    local pPlayer = LocalPlayer()
    local step = 1

    local tutorial = {
        [1] = {
            ['name'] = DanLib.Func:L('#tutorial.welcome', { player_name = pPlayer:Nick() }),
            ['description'] = '{color: 220, 221, 225}I appreciate your use of my library and my addons! To avoid disturbing players, this notification will only appear once and will only be visible to the{/color:} {color: 255, 165, 0}Owner{/color:}{color: 220, 221, 225}.{/color:}',
            ['back'] = 'Close',
            ['next'] = 'Start',
        },
        [2] = {
            ['name'] = DanLib.Func:L('#tutorial.welcome.page1'),
            ['description'] = '{color: 220, 221, 225}It is a library that extends the functionality of basic LUA functions. I plan to use it in my various developments, as I often use the same functions that I have to duplicate each time. To avoid this, I use a library that has everything I need to do a good job.{/color:}',
        },
        [3] = {
            ['name'] = DanLib.Func:L('#tutorial.welcome.page2'),
            ['description'] = '{color: 220, 221, 225}There are many different useful features available at this time. A game configuration that provides ease of use. Modular system. Various vgui elements (pop-up windows, pop-up notifications, etc.). An admin system that helps with module management and helps sort out the players who can use a particular module. And much more...{/color:}'
        },
        [4] = {
            ['name'] = DanLib.Func:L('#tutorial.welcome.page3'),
            ['description'] = '{color: 220, 221, 225}To open the MENU, type the default command !danlibmenu in chat, to use via console, type the default command danlibmenu. To use all the features of DanLib, you need to have the rank Owner! Since only this rank has all privileges.{/color:}',
            ['next'] = 'Start using',
        },
    }

    MainFrame = DanLib.CustomUtils.Create()
    Frame = MainFrame
    Frame:SetSize(ScrW(), ScrH())
    Frame:MakePopup() 
    Frame:Center()
    Frame:SetAlpha(0)
    Frame:AlphaTo(255, 0.2)
    Frame:ApplyBlur()
    Frame:ApplyBackground(Color(14, 22, 33, 180))
    Frame:ApplyText('Still in testing!!! ' .. DanLib.Func:L('#version', { version = DanLib.Version }), 'danlib_font_20', Frame:GetWide() - 20, Frame:GetTall() - 20, DanLib.Func:Theme('text'), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    -- Seasonal effect
    local currentMonth = os.date('!*t', os.time()).month
    if (currentMonth == 12 or currentMonth == 1 or currentMonth == 2) then
        DanLib.Func.CreateSnowPanel(Frame)
    else
        DanLib.Func.CreateLinePanel(Frame)
    end

    local base = DanLib.CustomUtils.Create(Frame)
    base:SetSize(width, height)
    base:Center()
    base:SetAlpha(0)
    base:AlphaTo(255, 0.2)
    base:ApplyEvent(nil, function(sl, w, h)
        local x, y = sl:LocalToScreen(0, 0)

        DanLib.DrawShadow:Begin()
        DanLib.Utils:DrawRoundedBox(x, y, w, h, DanLib.Func:Theme('background'))
        DanLib.DrawShadow:End(1, 1, 1, 255, 0, 0, false)
    end)

    local function createButton(parent, name, color, clickCallback)
        local Button = DanLib.Func.CreateUIButton(parent, {
            background = {ColorAlpha(color, 20), 6},
            dock_indent = {RIGHT, nil, 5, 5, 5},
            wide = 125,
            hover = {ColorAlpha(color, 60), nil, 6},
            text = {name, 'danlib_font_22', nil, nil},
            click = clickCallback
        })
        return Button
    end

    -- Function for displaying the current step of the tutorial
    local function welcome()
        local tuto = tutorial[step]
        local container = DanLib.CustomUtils.Create(base)
        container:Pin(FILL)

        container.lerp = 0
        container.alpha = 0

        local con = DanLib.CustomUtils.Create(container)
        con:Pin(FILL)
        con:SetAlpha(0)
        con:AlphaTo(255, 2)
        con:ApplyEvent(nil, function(sl, w, h)
            container.lerp = Lerp(FrameTime() * 2, container.lerp, 56)
            container.alpha = Lerp(FrameTime() * 0.5, container.alpha, 150)

            DanLib.Utils:DrawParseText(tutorial[step]['name'], 'danlib_font_36', 20, h * 0.05 + container.lerp, nil, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 500)
            DanLib.Utils:DrawParseText(tutorial[step]['description'], 'danlib_font_24', w - 20, h * 0.7 - container.lerp, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 400)
        end)

        local bottom = DanLib.CustomUtils.Create(container)
        bottom:Pin(BOTTOM)
        bottom:SetTall(40)

        local buttons = {
            {
                name = tuto['next'] or 'Next',
                color = Color(67, 156, 242),
                callback = function()
                    if tuto['Callback'] then tuto['Callback']() end
                    if (step == #tutorial) then
                        Frame:AlphaTo(0, 0.3, 0, function()
                            Frame:Remove()
                            step = 1
                        end)
                    else
                        step = step + 1
                        container:Clear()
                        welcome()
                    end
                end
            },
            {
                name = tuto['back'] or 'Back',
                color = Color(209, 53, 62),
                callback = function()
                    if (step == 1) then
                        Frame:AlphaTo(0, 0.3, 0, function() Frame:Remove() end)
                    else
                        step = step - 1
                        container:Clear()
                        welcome()
                    end
                end
            }
        }

        for _, btn in ipairs(buttons) do
            createButton(bottom, btn.name, btn.color, btn.callback)
        end
    end

    welcome()

    local File = 'danlib/welcome_' .. GetHostName() .. '.txt'
    local Content = 'This is an indicator that you have already seen the Thank you screen. Please don\'t delete this file.'
    DanLib.FileUtil.Write(File, Content)
end

-- DanLib.PopupWelcome()
