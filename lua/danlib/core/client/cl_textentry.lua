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
 *   cl_textentry.lua
 *   This file is responsible for creating a customisable text field in a DanLib project.
 *
 *   It includes the following functions:
 *   - Initialisation of the text field with default settings.
 *   - Set the icon, if specified.
 *   - Handling text changes and events such as gaining and losing focus.
 *   - Limits the number of characters you can enter in a text field.
 *   - Adjusting the background colour and selection.
 *   - Drawing a stateful text box (normal, edit).
 *
 *   The file provides a convenient interface for creating text fields in a project.
 */



local DBase = DanLib.Func
local DUtils = DanLib.Utils
local DTheme = DanLib.Config.Theme
local DCustomUtils = DanLib.CustomUtils.Create

local _Clamp = math.Clamp
local _utf8len = utf8.len
local _utf8sub = utf8.sub
local _ColorAlpha = ColorAlpha
local _SimpleText = draw.SimpleText
 

--- Creates a text field in the specified panel.
-- @param parent: The parent panel where the text field will be created.
-- @param strIcon: An icon displayed to the left of the text box. Default is nil.
-- @param iSize: Icon Size. Defaults to 16 unless specified.
-- @return TextEntry: Returns the created text field for a chain of method calls.
function DBase.CreateTextEntry(parent, strIcon, iSize)
    local tTextEntry = DCustomUtils(parent)

    -- Creating an icon, if specified
    if strIcon then
        tTextEntry.icon = DCustomUtils(tTextEntry)
        tTextEntry.icon:SetMouseInputEnabled(false)
        tTextEntry.icon.size = iSize or 16

        -- Drawing an icon
        tTextEntry.icon:ApplyEvent(nil, function(sl, w, h)
            DUtils:DrawIconOrMaterial(w * 0.5 - sl.size * 0.5, h * 0.5 - sl.size * 0.5, sl.size, strIcon, DBase:Theme('mat', 150))
        end)

        -- Setting the dimensions for the icon
        tTextEntry:ApplyEvent('PerformLayout', function(self, w, h)
            self.icon:SetPos(5, 5)
            self.icon:SetSize(h - 10, h - 10)
        end)
    end

    -- Creating a text field
    tTextEntry.textEntry = DCustomUtils(tTextEntry, 'DTextEntry')
    tTextEntry.textEntry:PinMargin(nil, strIcon and 30 or 8, nil, 8)
    tTextEntry.textEntry:SetFont('danlib_font_18')
    tTextEntry.textEntry:SetText('')
    tTextEntry.textEntry:SetTextColor(Color(255, 255, 255, 20))
    tTextEntry.textEntry:SetCursorColor(Color(255, 255, 255))
    tTextEntry.textEntry.backTextColor = DBase:Theme('text', 100)

    -- Handler for clicking on the parent element
    -- TODO:
    --      OnMousePressed handler: Added OnMousePressed event handler to the parent element (parent),
    --      which checks if the text field is in edit mode.
    --      If it is, the ClearFocus() method is called, which removes the focus from the text field.
    -- parent.OnMousePressed = function()
    --     if IsValid(tTextEntry.textEntry) and tTextEntry.textEntry:IsEditing() then
    --         tTextEntry.textEntry:ClearFocus() -- Let's get the focus off
    --     end
    -- end

    -- Drawing a text box
    tTextEntry.textEntry:ApplyClearPaint()
    tTextEntry.textEntry:ApplyEvent(nil, function(sl, w, h)
        local textColor = sl:GetTextColor()
        if (textColor.a != 255 or textColor.a != 0) then
            sl:SetTextColor(DBase:Theme('text', 100 + (tTextEntry.alpha or 0)))
        end

        sl:DrawTextEntryText(textColor, sl:GetHighlightColor(), sl:GetCursorColor())
    
        if (not sl:IsEditing() and sl:GetText() == '') then
            _SimpleText(sl.backText or '', sl:GetFont(), 0, h / 2, sl.backTextColor, 0, TEXT_ALIGN_CENTER)
        end
    end)

    -- Setting event handlers
    local function setEventHandler(eventName, handler)
        tTextEntry.textEntry[eventName] = function(...)
            if tTextEntry[eventName] then
                tTextEntry[eventName](...)
            end

            if handler then
                handler(...)
            end
        end
    end

    setEventHandler('OnChange')
    setEventHandler('OnEnter')
    setEventHandler('OnGetFocus')
    setEventHandler('OnLoseFocus')


    -- Methods for managing a text field

    --- Requests focus for a text field.
    -- @return boolean: Returns true if the focus was successfully requested.
    function tTextEntry:RequestFocus()
        if IsValid(self.textEntry) then
            return self.textEntry:RequestFocus()
        end
        return false
    end

    --- Handles a change in the value of a text field.
    -- @return any: Returns the value, if necessary.
    function tTextEntry:OnValueChange() return self.textEntry:OnValueChange() end

    --- Sets the refresh mode when entering text.
    -- @param enabled: If true, the update will occur when text is entered.
    -- @return TextEntry: Returns an instance of the text field for a chain of method calls.
    function tTextEntry:SetUpdateOnType(enabled) self.textEntry:SetUpdateOnType(enabled) return self end

    --- Sets the multi-line text input mode.
    -- @param enabled: If true, the text field will be multi-line.
    function tTextEntry:SetMultiline(enabled) self.textEntry:SetMultiline(enabled) end

    --- Handles text changes in a text field.
    -- @return any: Returns the value, if necessary.
    function tTextEntry:OnTextChanged() return self.textEntry:OnTextChanged() end

    --- Checks if the text field is in edit mode.
    -- @return boolean: Returns true if the text field is editable.
    function tTextEntry:IsEditing() return self.textEntry:IsEditing() end

    --- Sets the value of the text field.
    -- @param val: The value to be set.
    function tTextEntry:SetValue(val) self.textEntry:SetValue(val) end

    --- Gets the current value of the text field.
    -- @return string: Returns the current value of the text field.
    function tTextEntry:GetValue() return self.textEntry:GetValue() end

    --- Sets the text displayed when the text box is empty.
    -- @param backText: The text to be displayed.
    -- @return TextEntry: Returns an instance of the text field for a chain of method calls.
    function tTextEntry:SetBackText(backText) self.textEntry.backText = backText return self end

    --- Sets the background colour of the text box.
    -- @param color: The colour to be set as the background.
    -- @return TextEntry: Returns an instance of the text field for a chain of method calls.
    function tTextEntry:SetBackColor(color) self.backColor = color return self end

    --- Sets the selection colour of the text box.
    -- @param color: The colour to be set for the selection.
    -- @return TextEntry: Returns an instance of the text field for a chain of method calls.
    function tTextEntry:SetHighlightColor(color) self.highlightColor = color return self end

    --- Sets the font for the text box.
    -- @param font: The font to be used.
    -- @return TextEntry: Returns an instance of the text field for a chain of method calls.
    function tTextEntry:SetFont(font) self.textEntry:SetFont(font) return self end

    --- Sets the enable state of the text field.
    -- @param enabled: If true, the text box will be enabled.
    -- @return TextEntry: Returns an instance of the text field for a chain of method calls.
    function tTextEntry:SetEnabled(enabled) self.textEntry:SetEnabled(enabled) return self end

    --- Sets the verification for the text field.
    -- @param verification: The importance of verification.
    -- @return TextEntry: Returns an instance of the text field for a chain of method calls.
    function tTextEntry:SetVerification(verification) self.verification = verification return self end

    -- Turning off shadows
    tTextEntry:ApplyEvent('DisableShadows', function(self, distance, noClip, iteration)
        self:ApplyShadow(distance or 10, noClip or false, iteration or 5)
        return self
    end)

    --- Character Limitation
    tTextEntry:ApplyEvent('SetMaxChar', function(self, max)
        self.max = max
        
        -- Redefining AllowInput to prevent unnecessary characters from being entered
        self.textEntry.AllowInput = function(sl, char)
            local text = sl:GetValue()
            local currentLen = _utf8len(text) or 0
            
            -- We allow input only if the limit is not exceeded
            -- or if the character is a control key (backspace, etc.)
            if (currentLen >= max and char ~= nil and char ~= '') then
                return true -- Blocking the input
            end
            
            return false -- Allowing input
        end
    end)

    -- Drawing a text box
    tTextEntry:ApplyEvent(nil, function(self, w, h)
        local is_editing = self.textEntry:IsEditing()
        self:ApplyAlpha(0.1, 155, false, false, is_editing, 155)
        self.hoverPercent = is_editing and _Clamp((self.hoverPercent or 0) + 5, 0, 100) or _Clamp((self.hoverPercent or 0) - 5, 0, 100)
        local hoverPercent = self.hoverPercent / 100

        DUtils:DrawRect(0, 0, w, h, DBase:Theme('decor_elements'))
        DUtils:OutlinedRect(0, 0, w, h, DBase:Theme('frame'))
        DUtils:OutlinedRect(0, 0, w, h, self.verification and _ColorAlpha(DTheme['Red'], hoverPercent * 100) or DBase:Theme('decor', hoverPercent * 100))

        -- Character count
        if self.max then
            local currentLen = _utf8len(self:GetValue()) or 0
            local remaining = self.max - currentLen
            local countColor = (remaining <= 0) and _ColorAlpha(DTheme['Red'], 150) or DBase:Theme('text', 150)
            _SimpleText(remaining, 'danlib_font_16', w - 4, 10, countColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end)

    return tTextEntry
end
