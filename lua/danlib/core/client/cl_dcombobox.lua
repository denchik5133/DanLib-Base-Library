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


/***
 *   cl_dcombobox.lua
 *   This file is responsible for creating a customisable combobox in a DanLib project.
 *
 *   It includes the following functions:
 *   - Initialisation of the combo box with default settings.
 *   - Adding options with text, data and icons.
 *   - Selects an option and retrieves the selected option.
 *   - Opening and closing a drop-down menu.
 *   - Handling changes in the values of constants (ConVar).
 *   - Adjusting the background colour and selection.
 *   - Drawing a stateful combobox (normal, induced, open).
 *
 *   The file provides a convenient interface for creating comboboxes in a project.
 */



local base = DanLib.Func
local Table = DanLib.Table
local utils = DanLib.Utils
local CustomUtils = DanLib.CustomUtils
local PANEL = {}

Derma_Hook(PANEL, 'Paint', 'Paint', 'ComboBox')

Derma_Install_Convar_Functions(PANEL)

AccessorFunc(PANEL, 'm_bDoSort', 'SortItems', FORCE_BOOL)

function PANEL:Init()
    -- Setup internals
    self:SetTall(22)
    self:Clear()

    self:SetText('')
    self:SetContentAlignment(4)
    self:SetTextInset(8, 0)
    self:SetIsMenu(true)
    self:SetSortItems(true)
    self.iconAngle = 0
end

function PANEL:Clear()
    self:SetText('')
    self.Choices = {}
    self.Data = {}
    self.ChoiceIcons = {}
    self.Spacers = {}
    self.selected = nil
    self:CloseMenu()
end

function PANEL:GetOptionText(index)
    return self.Choices[index]
end

function PANEL:GetOptionData(index)
    return self.Data[index]
end

function PANEL:GetOptionTextByData(data)
    for id, dat in pairs(self.Data) do
        if (dat == data) then
            return self:GetOptionText(id)
        end
    end

    -- Try interpreting it as a number
    for id, dat in pairs(self.Data) do
        if (dat == tonumber(data)) then
            return self:GetOptionText(id)
        end
    end

    -- In case we fail
    return data
end

function PANEL:PerformLayout(w, h)
    -- Make sure the text color is updated
    DButton.PerformLayout(self, w, h)
end

function PANEL:ChooseOption(value, index)
    self:CloseMenu()
    self.text = value
    self.selected = index
    self:OnSelect(index, value, self.Data[index])
end

function PANEL:ChooseOptionID(index)
    local value = self:GetOptionText(index)
    self:ChooseOption(value, index)
end

function PANEL:GetSelectedID()
    return self.selected
end

function PANEL:GetSelected()
    if (not self.selected) then return end
    return self:GetOptionText(self.selected), self:GetOptionData(self.selected)
end

function PANEL:OnSelect(index, value, data)
    -- For override
end

function PANEL:OnMenuOpened(menu)
    -- For override
end

function PANEL:AddSpacer()
    self.Spacers[#self.Choices] = true
end

function PANEL:AddChoice(value, data, select, icon)
    local index = table.insert(self.Choices, value)
    if data then self.Data[index] = data end
    if icon then self.ChoiceIcons[index] = icon end
    if select then self:ChooseOption(value, index) end
    return index
end

function PANEL:RemoveChoice(index)
    if (not isnumber(index)) then return end

    local text = table.remove(self.Choices, index)
    local data = table.remove(self.Data, index)
    return text, data
end

function PANEL:IsMenuOpen()
    return IsValid(self.Menu) && self.Menu:IsVisible()
end

function PANEL:OpenMenu(pControlOpener)
    if (pControlOpener && pControlOpener == self.TextEntry) then
        return
    end

    -- Don't do anything if there aren't any options..
    if (#self.Choices == 0) then
        return
    end

    -- If the menu still exists and hasn't been deleted
    -- then just close it and don't open a new one.
    self:CloseMenu()

    -- If we have a modal parent at some level, we gotta parent to
    -- that or our menu items are not gonna be selectable
    local parent = self
    while (IsValid(parent) && not parent:IsModal()) do
        parent = parent:GetParent()
    end

    if (not IsValid(parent)) then
        parent = self
    end

    self.Menu = base:UIContextMenu(parent)
    self.iconAngle = 180

    if self:GetSortItems() then
        local sorted = {}
        for k, v in pairs(self.Choices) do
            local val = tostring(v)
            if (string.len(val) > 1 && not tonumber(val) && val:StartsWith('#')) then
                val = language.GetPhrase(val:sub(2))
            end
            table.insert(sorted, { id = k, data = v, label = val })
        end

        for k, v in SortedPairsByMemberValue(sorted, 'label') do
            local option = self.Menu:Option(v.data, nil, self.ChoiceIcons[v.id] and self.ChoiceIcons[v.id] or nil, function()
                self:ChooseOption(v.data, v.id)
            end)

            if self.Spacers[v.id] then
                --[[ self.Menu:Spacer() ]]
            end
        end
    else
        for k, v in pairs(self.Choices) do
            local option = self.Menu:Option(v, nil, self.ChoiceIcons[k] and self.ChoiceIcons[k] or nil, function()
                self:ChooseOption(v, k)
            end)

            if self.Spacers[k] then
                --[[ self.Menu:Spacer() ]]
            end
        end
    end

    local x, y = self:LocalToScreen(0, self:GetTall())
    self.Menu:SetMinimumWidth(self:GetWide())
    self.Menu:Open(x, y + 2, false, self)
    self:OnMenuOpened(self.Menu)
end

function PANEL:CloseMenu()
    if IsValid(self.Menu) then self.Menu:Remove() end
    self.Menu = nil
    self.iconAngle = 0
end

-- This really should use a convar change hook
function PANEL:CheckConVarChanges()
    if (not self.m_strConVar) then return end

    local strValue = GetConVarString(self.m_strConVar)
    if (self.m_strConVarValue == strValue) then return end

    self.m_strConVarValue = strValue
    self:SetValue(self:GetOptionTextByData(self.m_strConVarValue))
end

--- Sets the direction of the text in the combo box.
-- @param d: Text Direction.
function PANEL:SetDirection(d)
    self.Direction = d
end

--- Sets the font for the text in the combo box.
-- @param font: The font to be used.
function PANEL:SetFont(font)
    self.setFont = font
end

function PANEL:Think()
    self:CheckConVarChanges()
end

function PANEL:SetValue(strValue)
    self.text = strValue
end

function PANEL:DoClick()
    if self:IsMenuOpen() then return self:CloseMenu() end
    self:OpenMenu()
end

-- Turning off shadows
function PANEL:DisableShadows(distance, noClip, iteration)
    self:ApplyShadow(distance or 10, noClip or false, iteration or 5)
    return self
end

--- Draws a combo box.
function PANEL:Paint(w, h)
    self:ApplyAlpha(0.1, 155, false, false, self:IsMenuOpen(), 155)

    self.hover = self:IsMenuOpen() and math.min((self.hover or 0) + 5, 100) or math.max((self.hover or 0) - 5, 0)
    local hover = self.hover / 100

    utils:DrawRoundedBox(0, 0, w, h, base:Theme('decor_elements'))
    utils:OutlinedRect(0, 0, w, h, base:Theme('frame'))
    utils:OutlinedRect(0, 0, w, h, base:Theme('decor', hover * 100))

    local x = 10
    if self.setIcon then
        local iconSize = base:Scale(30)
        utils:DrawIconOrMaterial(h * 0.5 - iconSize * 0.5, h * 0.5 - iconSize * 0.5, iconSize, self.setIcon, base:Theme('mat', 75 + self.alpha))
        x = x + 20
    end

    if self.Direction then
        local sz = 16
        self.deg = Lerp(FrameTime() * 15, self.deg or 0, self.iconAngle)
        utils:DrawIconRotated(w - sz - 5, h / 2, sz, sz, self.deg, DanLib.Config.Materials['Arrow'], base:Theme('decor', 100 + self.alpha))
    end

    local text = self.text or base:L('#no.data')
    local font = self.setFont or 'danlib_font_18'
    draw.SimpleText(text, font, self.Direction and x or w * 0.5, h * 0.5, base:Theme('text', 100 + self.alpha), self.Direction and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

derma.DefineControl('DanLib.UI.ComboBox', '', PANEL, 'DButton')


function base.CreateUIComboBox(parent)
    parent = parent or nil

    local ComboBox = DanLib.CustomUtils.Create(parent, 'DanLib.UI.ComboBox')
    return ComboBox
end

