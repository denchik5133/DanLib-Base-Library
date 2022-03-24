hook.Run('DanLib::ThemeLoaded') -- IN NO CASE SHOULD YOU TOUCH

local CheckProducts = CheckProducts or {}

function DanLib.AddonKaydi(name, requirements)
    CheckProducts[name] = requirements
    return true
end


hook.Add("InitPostEntity", "DanLib::AddonKaydi", function()
    local REQ_MISS = {}

    for name, tab in pairs(CheckProducts) do
        local MISSING = false

        for k, v in ipairs(tab) do
            if v.Check and ( v.Check() == false ) then
                if !MISSING then
                    MISSING = v.Name
                else
                    MISSING = MISSING..", "..v.Name
                end
            end
        end

        if MISSING then
            MsgC(Color(255,0,0), "["..name.."] ", Color(255,255,255), "Невозможно зарегистрировать продукт, отсутствуют требования (требования): "..MISSING.."\n")

            table.insert(REQ_MISS, {
                Name = name, 
                Missing = MISSING,
            })
        else
            MsgC(Color(75,170,200), "["..name.."] ", Color(255,255,255), "Успешно зарегистрированный продукт.\n")
        end
    end

    if CLIENT then
        if LocalPlayer():IsAdmin() and #REQ_MISS >= 1 then
            local DermaPanel = vgui.Create( "DFrame" )
            DermaPanel:SetSize( ScrW() * 0.3, ScrH() * 0.4 )
            DermaPanel:Center()
            DermaPanel:SetTitle( "[DanLib] Недостающие требования" )
            DermaPanel:ShowCloseButton( true )
            DermaPanel:MakePopup()

            local DermaListView = vgui.Create("DListView")
            DermaListView:SetParent(DermaPanel)
            DermaListView:Dock(FILL)
            DermaListView:SetMultiSelect(false)
            DermaListView:AddColumn("Скрипт")
            DermaListView:AddColumn("Недостающий")
            
            for k, v in ipairs(REQ_MISS) do
                DermaListView:AddLine(v.Name, v.Missing) -- Add lines
            end
        end
    end
end)


--[[local curVer = "v2.28"

btn.OnMouseReleased = function()
    http.Fetch("https://raw.githubusercontent.com/USER/REPO/BRANCH/version.txt", function(actualVer)
        if actualVer ~= curVer then
            print("A new version of ADDON-NAME released! Please update at https://github.com/USER/REPO")
        end
    end)
end]]