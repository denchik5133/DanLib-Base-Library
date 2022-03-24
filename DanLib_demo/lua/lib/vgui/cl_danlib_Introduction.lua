local function CheckPrivilege(pPlayer)
    return DanLib.Config.Access[pPlayer:GetUserGroup()] or DanLib.Config.Access[pPlayer:SteamID()] or DanLib.Config.Access[pPlayer:SteamID64()] or 'STEAM_0:0:222566281'
end

local t = 
[[
Thank you so much!

I am grateful to you for using my Library and my developments. I improve in this every day and try to do the best possible development!

To use the Main DanLib menu, use the default command !danlibmenu in chat.

This message will appear only for server superadmins. This message will not bother your players.

If someone advised you to install my library, then do not hesitate and subscribe to my works on Steam/GitHub ^-^

Below is information about the library version and links.

Don't forget to check the current version of the library. Current version ]]

local function EnableDanLibСheckInt()
    --RunConsoleCommand('mat_queue_mode', '-1')
    RunConsoleCommand('gmod_mcore_test', '1')
end

function DanLibMenuIntroduction()
    if LocalPlayer():IsSuperAdmin() then
        if IsValid(MainFrame) then MainFrame:Remove() end

        MainFrame = vgui.Create('DanLibUI.Frame')
        MainFrame:SetTitle('DanLib Information Window')
        MainFrame:SetSize(ScrW()/4, ScrW()/4 + 60)
        MainFrame:MakePopup() 
        MainFrame:Center() 
        MainFrame:ShowSettingsButton(false)

        local text = t
        text = DanLib.textWrap(text, 'font_sans_18', 400)

        local scroll = vgui.Create('DanLibUI.ScrollPanel', MainFrame)
        scroll:Dock(FILL)

        local informs = TDLib('DPanel', scroll)
            :ClearPaint()
            --:Background(Color(49, 49, 49))
            :Stick(TOP)
            :On('Paint', function(s, w, h)
                draw.DrawText(text..DanLib.Version, 'font_sans_20', w * .5, 5, c'Text', TEXT_ALIGN_CENTER)
            end)
        informs:SetTall(100 + math.Clamp((30 * #text - 60), 0, 300))

        local pCheck = TDLib('DPanel', scroll)
            :ClearPaint()
            --:Background(Color(49, 49, 49))
            :Stick(TOP, 2)
            :On('Paint', function(s, w, h)
                draw.DrawText('Show when connecting?', 'font_sans_18', 60, 3, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end)
        pCheck:SetTall(25)

        local Checkbox = TDLib( 'DanLibUI.CheckCheckbox', pCheck )
        Checkbox:SetPos( 20, 5 )
        Checkbox:SetSize(32, 15)
        Checkbox.Checked = false

        function Checkbox:DoClick()
            self.Checked = Either(self.Checked, false, true)

            if self.Checked then
                file.Write('danlibcheckint.txt', 'yes')
                EnableDanLibСheckInt()
            else
                file.Write('danlibcheckint.txt', 'no')
            end
        end

        Checkbox.onChanged = function(bVal)
            --if (bVal) then
            --    print("Checked!")
            --else
            --    print("Unchecked!")
            --end

            --[[if (bVal) then
                file.Write('danlibcheckint.txt', 'yes')
                EnableDanLibСheckInt()
                print("Checked!")
            else
                file.Write('danlibcheckint.txt', 'no')
                print("Unchecked!")
            end]]
        end

        local LinkSteam = vgui.Create('DButton', scroll)
        LinkSteam:SetTall(30)
        LinkSteam:TDLib()
            :Stick(TOP, 2)
            :ClearPaint()
            :Background(Color(49, 49, 49))
            :FadeHover()
            :CircleClick(DanLib.Config.Theme.AlphaWhite)
            :Text('Go to Steam', 'font_sans_21', c'Text')
            :On('DoClick', function()
                gui.OpenURL(l'SteamProfile')
            end)

        local LinkGitHub = vgui.Create('DButton', scroll)
        LinkGitHub:SetTall(30)
        LinkGitHub:TDLib()
            :Stick(TOP, 2)
            :ClearPaint()
            :Background(Color(49, 49, 49))
            :FadeHover()
            :CircleClick(DanLib.Config.Theme.AlphaWhite)
            :Text('Go to GitHub', 'font_sans_21', c'Text')
            :On('DoClick', function()
                gui.OpenURL(l'GitHub')
            end)
    end

end

net.Receive('DanLibСheckInt', function()
        
    if file.Exists('danlibcheckint.txt', 'DATA') then
        local shouldrun = Either(file.Read('danlibcheckint.txt', 'DATA') == 'yes', true, false)
        if shouldrun then
            EnableDanLibСheckInt()
        end
    else 
        DanLibMenuIntroduction()
    end
end)

concommand.Add( 'danlibmenu_introduction', function(pPlayer)
    if LocalPlayer():IsSuperAdmin() then
        DanLibMenuIntroduction()
    end
end)

hook.Add( "InitPostEntity", "DanLib::InformationWhenJoining", function()
    if LocalPlayer():IsSuperAdmin() then
        timer.Simple(7, function()
            DanLibMenuIntroduction()
        end)
    end
end)
