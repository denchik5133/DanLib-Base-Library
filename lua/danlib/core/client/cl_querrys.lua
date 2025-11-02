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
local CustomUtils = DanLib.CustomUtils

local vgui = vgui
local string = string
local upper = string.upper
local lerp = Lerp

local defaultFont = 'danlib_font_20'
local cancelColor = Color(236, 57, 62)
local confirmColor = Color(106, 178, 242)

if IsValid(DANLIB_POPUPS) then DANLIB_POPUPS:Remove() end


--- Displays a message pop-up with optional confirmation and cancellation buttons.
-- @param title (string): The title of the pop-up.
-- @param text (string): The description or message to display.
-- @param confirmText (string): The text for the confirmation button (default: "Confirm").
-- @param confirmFunc (function): The function to call when the confirmation button is clicked.
-- @param cancelText (string): The text for the cancel button (default: "Cancel").
-- @param cancelFunc (function): The function to call when the cancel button is clicked.
-- @param st (boolean): If true, the cancel button will not be displayed (default: false).
--
-- Example Usage:
--    DanLib.Func:QueriesPopup('Message Title (Optional)', 'Hey Some Text Here!!!', 'Okey', function()
--        DanLib.Func:QueriesPopup('Your headline', 'And a description of anything')
--    end, 'Cancel', function() 
--        DanLib.Func:QueriesPopup('Cancel', 'You pressed Cancel!') 
--    end)
function base:QueriesPopup(title, text, confirmText, confirmFunc, cancelText, cancelFunc, st)
    -- Set default values using Lua's or operator
    confirmText = confirmText or base:L('confirm')
    cancelText = cancelText or base:L('cancel')
    title = title or 'No text'
    text = text or 'No text'
    st = st or false

    -- Create the pop-up container
    local Container = CustomUtils.Create(nil, 'DanLib.UI.PopupBasis')
    DANLIB_POPUPS = Container
    Container:BackgroundCloseButtonShow(false)
    Container:CloseButtonShow(false)
    Container:SetHeader(upper(title))
    
    -- Wrap the text for display
    Container.Text = utils:TextWrap(text, defaultFont, 400, true)
    Container.buttonW = base:Scale(170)

    -- Calculate text size and set pop-up dimensions
    local text_h = utils:TextSize(Container.Text, defaultFont).h
    Container:SetPopupWide(450)
    Container:SetExtraHeight(80 + text_h)

    -- Create text area
    local textArea = CustomUtils.Create(Container)
    textArea:PinMargin(TOP, 10, 10)
    textArea:SetTall(20 + text_h)
    textArea:ApplyEvent(nil, function(_, w, h)
        utils:DrawParseText(text, defaultFont, w / 2, 0, base:Theme('text'), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 400, TEXT_ALIGN_CENTER)
    end)

    -- Create button container
    Container.ButtonContainer = CustomUtils.Create(Container)
    Container.ButtonContainer:PinMargin(BOTTOM, 10, 0, 10, 10)
    Container.ButtonContainer:SetTall(30)

    -- Create cancel button if not suppressed
    if (not st) then
        Container.ButtonContainer.ButtonCancel = base.CreateUIButton(Container.ButtonContainer, {
            background = { nil },
            dock_indent = { RIGHT, 6 },
            wide = Container.buttonW,
            hover = { ColorAlpha(cancelColor, 50), nil, 6 },
            text = { cancelText, defaultFont, nil, nil, cancelColor },
            click = function()
                Container:Close()
                if cancelFunc then cancelFunc() end
            end
        })
    end

    -- Create confirm button
    Container.ButtonContainer.ButtonConfirm = base.CreateUIButton(Container.ButtonContainer, {
        background = { nil },
        dock_indent = { RIGHT, 6 },
        wide = Container.buttonW,
        hover = { ColorAlpha(confirmColor, 50), nil, 6 },
        text = { confirmText, defaultFont, nil, nil, confirmColor },
        click = function()
            Container:Close()
            if confirmFunc then confirmFunc() end
        end
    })
end


--- Displays a text input pop-up with optional confirmation and cancellation buttons.
-- This pop-up allows the user to enter text and provides options to confirm or cancel the input.
-- @param title (string): The title of the pop-up.
-- @param text (string): The description or message to display.
-- @param default (string): The default text for the text entry field (default: '').
-- @param confirmText (string): The text for the confirmation button (default: "Confirm").
-- @param confirmFunc (function): The function to call when the confirmation button is clicked.
-- @param cancelText (string): The text for the cancel button (default: "Cancel").
-- @param cancelFunc (function): The function to call when the cancel button is clicked.
--
-- Example Usage:
--    DanLib.Func:RequestTextPopup('Message Title', 'Please enter your input below:', 'Default Text',
--    function(input)
--        print('User  input:', input)
--    end, 'Cancel', function() 
--        print('User  cancelled the input.') 
--    end)
function base:RequestTextPopup(title, text, default, confirmText, confirmFunc, cancelText, cancelFunc, verification)
    -- Setting default values
    default = default or ''
    confirmText = confirmText or base:L('confirm')
    cancelText = cancelText or base:L('cancel')
    title = title or 'No text'
    text = text or 'No text'

    -- Creating a container for a popup
    local Container = CustomUtils.Create(nil, 'DanLib.UI.PopupBasis')
    DANLIB_POPUPS = Container
    Container:BackgroundCloseButtonShow(false)
    Container:CloseButtonShow(false)
    Container:SetHeader(upper(title))
    Container.Text = utils:TextWrap(text, defaultFont, 400, true)
    Container.buttonW = base:Scale(150)

    local text_h = utils:TextSize(Container.Text, defaultFont).h
    Container:SetPopupWide(450)
    Container:SetExtraHeight(120 + text_h)

    local textArea = CustomUtils.Create(Container)
    textArea:PinMargin(TOP, 10, 10, 5)
    textArea:SetTall(20 + text_h)
    textArea:ApplyEvent(nil, function(sl, w, h)
        utils:DrawParseText(text, defaultFont, w / 2, 0, base:Theme('text'), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 400, TEXT_ALIGN_CENTER)
    end)

    Container.TextEntry = base.CreateTextEntry(Container)
    Container.TextEntry:PinMargin(TOP, 10, nil, 15)
    Container.TextEntry:SetTall(36)
    Container.TextEntry:SetValue(default)
    Container.TextEntry:SetUpdateOnType(true)
    Container.TextEntry:RequestFocus()

    Container.ButtonContainer = CustomUtils.Create(Container)
    Container.ButtonContainer:PinMargin(BOTTOM, 10, nil, 10, 10)
    Container.ButtonContainer:SetTall(30)

    -- Create cancel button if not suppressed
    Container.ButtonContainer.ButtonCancel = base.CreateUIButton(Container.ButtonContainer, {
        background = { nil },
        dock_indent = { RIGHT, 6 },
        wide = Container.buttonW,
        hover = { ColorAlpha(cancelColor, 50), nil, 6 },
        text = { cancelText, defaultFont, nil, nil, cancelColor },
        click = function()
            Container:Close()
            if (cancelFunc) then cancelFunc() end
        end
    })

    -- Create confirm button
    Container.ButtonContainer.ButtonConfirm = base.CreateUIButton(Container.ButtonContainer, {
        background = { nil },
        dock_indent = { RIGHT, 6 },
        wide = Container.buttonW,
        hover = { ColorAlpha(confirmColor, 50), nil, 6 },
        text = { confirmText, defaultFont, nil, nil, confirmColor },
        click = function()
            local val = Container.TextEntry:GetValue()
            Container:Close()
            if (confirmFunc) then confirmFunc(val) end
        end
    })

    -- Validation on text input
    if verification then
        Container.TextEntry.textEntry:ApplyEvent('OnTextChanged', function(sl)
            local text = Container.TextEntry:GetValue()
            local isValid = verification and verification(text)
            print(isValid)
            Container.TextEntry:SetVerification(not isValid)
            Container.ButtonContainer.ButtonConfirm:SetDisabled(not isValid) -- Deactivate the button if the input is invalid
        end)

        -- Make sure that the confirmation button is active during initialisation
        Container.TextEntry:SetVerification(false)
        Container.ButtonContainer.ButtonConfirm:SetDisabled(false)
    end
end


--- Displays a color selection pop-up using a color mixer with confirmation and cancellation options.
-- This pop-up allows the user to select a color and provides options to confirm or cancel the selection.
-- @param title (string): The title of the pop-up (default: 'RGB Colors').
-- @param default (Color): The initial color for the color mixer (default: Color(255, 255, 255, 255)).
-- @param confirmText (string): The text for the confirmation button (default: 'Confirm').
-- @param confirmFunc (function): The function to call when the confirmation button is clicked, receiving the selected color.
-- @param cancelText (string): The text for the cancel button (default: 'Cancel').
-- @param cancelFunc (function): The function to call when the cancel button is clicked.
--
-- Example Usage:
--    local function OnColorConfirmed(selectedColor)
--        print('Selected color:', selectedColor)
--    end
--
--    local function OnColorCanceled()
--        print('Color selection canceled.')
--    end
--
--    DanLib.Func:RequestColorChangesPopup(
--        'Choose a Color',              -- Title
--        Color(100, 150, 200),          -- Default color
--        'Confirm',                     -- Confirmation button text
--        OnColorConfirmed,              -- Confirmation callback
--        'Cancel',                      -- Cancel button text
--        OnColorCanceled                -- Cancellation callback
--    )
function base:RequestColorChangesPopup(title, default, confirmText, confirmFunc, cancelText, cancelFunc)
    default = default or Color(255, 255, 255, 255)
    title = title or 'RGB Colors'
    confirmText = confirmText or base:L('confirm')
    cancelText = cancelText or base:L('cancel')

    local Container = CustomUtils.Create(nil, 'DanLib.UI.PopupBasis')
    DANLIB_POPUPS = Container
    Container:BackgroundCloseButtonShow(false)
    Container:CloseButtonShow(false)
    Container:SetHeader(upper(title))
    Container.buttonW = base:Scale(150)
    Container:SetPopupWide(300)
    Container:SetExtraHeight(350)

    Container.MixerEntry = CustomUtils.Create(Container, 'DanLib.UI.ColorMixer')
    Container.MixerEntry:Pin(nil, 10)
    Container.MixerEntry:SetAlphaBar(true)
    Container.MixerEntry:SetWangs(true)
    Container.MixerEntry:SetPalette(true)
    Container.MixerEntry:SetColor(default)

    Container.ButtonContainer = CustomUtils.Create(Container)
    Container.ButtonContainer:PinMargin(BOTTOM, 10, nil, 10, 10)
    Container.ButtonContainer:SetTall(30)

    -- Create cancel button if not suppressed
    Container.ButtonContainer.ButtonCancel = base.CreateUIButton(Container.ButtonContainer, {
        background = { nil },
        dock_indent = { RIGHT, 6 },
        wide = Container.buttonW,
        hover = { ColorAlpha(cancelColor, 50), nil, 6 },
        text = { cancelText, defaultFont, nil, nil, cancelColor },
        click = function()
            Container:Close()
            if cancelFunc then cancelFunc() end
        end
    })

    -- Create confirm button
    Container.ButtonContainer.ButtonConfirm = base.CreateUIButton(Container.ButtonContainer, {
        background = { nil },
        dock_indent = { RIGHT, 6 },
        wide = Container.buttonW,
        hover = { ColorAlpha(confirmColor, 50), nil, 6 },
        text = { confirmText, defaultFont, nil, nil, confirmColor },
        click = function()
            local val = Container.MixerEntry:GetColor()
            Container:Close()
            if (confirmFunc) then confirmFunc(val) end
        end
    })

    return Container, Container.MixerEntry
end


--- Displays a combo box selection pop-up with optional confirmation and cancellation buttons.
-- This pop-up allows the user to select an option from a combo box and provides options to confirm or cancel the selection.
-- @param title (string): The title of the pop-up (default: 'No text').
-- @param text (string): The description or message to display (default: 'No text').
-- @param sOptions (table): A table of options to display in the combo box.
-- @param default (string): The default selected option in the combo box (default: '').
-- @param confirmText (string): The text for the confirmation button (default: 'Confirm').
-- @param confirmFunc (function): The function to call when the confirmation button is clicked, receiving the selected value and data.
-- @param cancelText (string): The text for the cancel button (default: 'Cancel').
-- @param cancelFunc (function): The function to call when the cancel button is clicked.
--
-- Example Usage:
--    local function OnOptionConfirmed(value, data)
--        print('Selected option:', value, 'with data:', data)
--    end
--
--    local function OnOptionCanceled()
--        print('Option selection canceled.')
--    end
--
--    DanLib.Func:ComboRequestPopup(
--        'Choose an Option',                   -- Title
--        'Please select an option below:',     -- Description text
--        {'Option 1', 'Option 2', 'Option 3'}, -- Options
--        'Option 1',                           -- Default option
--        'Confirm',                            -- Confirmation button text
--        OnOptionConfirmed,                    -- Confirmation callback
--        'Cancel',                             -- Cancel button text
--        OnOptionCanceled                      -- Cancellation callback
--    )
function base:ComboRequestPopup(title, text, sOptions, default, confirmText, confirmFunc, cancelText, cancelFunc)
    default = default or ''
    confirmText = confirmText or base:L('confirm')
    cancelText = cancelText or base:L('cancel')
    title = title or 'No text'
    text = text or 'No text'

    local Container = CustomUtils.Create(nil, 'DanLib.UI.PopupBasis')
    DANLIB_POPUPS = Container
    Container:SetHeader(upper(title))
    Container.Text = utils:TextWrap(text, defaultFont, 400, true)
    Container.buttonW = base:Scale(150)

    local text_h = utils:TextSize(Container.Text, defaultFont).h
    Container:SetPopupWide(450)
    Container:SetExtraHeight(120 + text_h)

    local textArea = CustomUtils.Create(Container)
    textArea:PinMargin(TOP, 10, 10, 5)
    textArea:SetTall(20 + text_h)
    textArea:ApplyEvent(nil, function(sl, w, h)
        utils:DrawParseText(text, defaultFont, w / 2, 0, base:Theme('text'), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 400, TEXT_ALIGN_CENTER)
    end)

    Container.comboSelect = base.CreateUIComboBox(Container)
    Container.comboSelect:PinMargin(TOP, 10, nil, 10)
    Container.comboSelect:SetTall(35)
    Container.comboSelect:SetFont(defaultFont)
    Container.comboSelect:SetValue(default)
    Container.comboSelect:SetDirection(10)

    for k, v in pairs(sOptions) do
        Container.comboSelect:AddChoice(v, k, default == k or default == v)
    end

    Container.ButtonContainer = CustomUtils.Create(Container)
    Container.ButtonContainer:PinMargin(BOTTOM, 10, nil, 10, 10)
    Container.ButtonContainer:SetTall(30)

    -- Create cancel button if not suppressed
    Container.ButtonContainer.ButtonCancel = base.CreateUIButton(Container.ButtonContainer, {
        background = { nil },
        dock_indent = { RIGHT, 6 },
        wide = Container.buttonW,
        hover = { ColorAlpha(cancelColor, 50), nil, 6 },
        text = { cancelText, defaultFont, nil, nil, cancelColor },
        click = function()
            Container:Close()
            if (cancelFunc) then cancelFunc() end
        end
    })

    -- Create confirm button
    Container.ButtonContainer.ButtonConfirm = base.CreateUIButton(Container.ButtonContainer, {
        background = { nil },
        dock_indent = { RIGHT, 6 },
        wide = Container.buttonW,
        hover = { ColorAlpha(confirmColor, 50), nil, 6 },
        text = { confirmText, defaultFont, nil, nil, confirmColor },
        click = function()
            local value, data = Container.comboSelect:GetSelected()
            if (value and data) then
                if confirmFunc then confirmFunc(value, data) end
                Container:Close()
            else
                base:ScreenNotification('ERROR', 'You need to select a value!', 'ERROR')
            end
        end
    })
end




-- Editor pop-up
function base:EditorPopup(title, sCode, confirmText, confirmFunc, cancelText, cancelFunc)
    title = title or 'No text'

    confirmText = confirmText or base:L('confirm')
    cancelText = cancelText or base:L('cancel')

    local Container = CustomUtils.Create(nil, 'DanLib.UI.PopupBasis')
    DANLIB_POPUPS = Container
    Container:SetHeader(upper(title))
    Container.buttonW = base:Scale(150)
    Container:SetPopupWide(650)
    Container:SetExtraHeight(300)

    local Margin = 6

    local editor = base.CreateHTML(Container)
    editor:PinMargin(TOP, Margin, Margin, Margin)
    editor:SetTall(240)
    editor.Code = sCode or ''
    editor:AddFunction('gmodinterface', 'OnCode', function(code)
        editor.Code = code
    end)

    -- http://metastruct.github.io/lua_editor/
    editor:OpenURL('http://metastruct.github.io/lua_editor/')

    function editor:GetCode()
        return self.Code
    end

    function editor:JavascriptSafe(str)
        return str
        :gsub(".", {
            ["\\"] = "\\\\",
            ["\0"] = "\\0",
            ["\b"] = "\\b",
            ["\t"] = "\\t",
            ["\n"] = "\\n",
            ["\v"] = "\\v",
            ["\f"] = "\\f",
            ["\r"] = "\\r",
            ["\""] = "\\\"",
            ["\'"] = "\\\'"
        })
        :gsub("\226\128\168", "\\\226\128\168")
        :gsub("\226\128\169", "\\\226\128\169")
    end

    function editor:SetCode(code)
        self.Code = code
        self:Call('SetContent(\"' .. self:JavascriptSafe(code) .. '\");')
    end

    Container.ButtonContainer = DanLibCustomUtils.Create(Container)
    Container.ButtonContainer:PinMargin(BOTTOM, 10, nil, 10, 10)
    Container.ButtonContainer:SetTall(30)

    -- Button cancel
    Container.ButtonContainer.ButtonCancel = base:CreateButton(Container.ButtonContainer, cancelText, defaultFont)
    Container.ButtonContainer.ButtonCancel:PinMargin(RIGHT, 10)
    Container.ButtonContainer.ButtonCancel:SetWide(Container.buttonW)
    function Container.ButtonContainer.ButtonCancel:DoClick()
        Container:Close()
        if (cancelFunc) then cancelFunc() end
    end

    -- Button confirm
    Container.ButtonContainer.ButtonConfirm = base:CreateButton(Container.ButtonContainer, confirmText, defaultFont)
    Container.ButtonContainer.ButtonConfirm:PinMargin(RIGHT, 10)
    Container.ButtonContainer.ButtonConfirm:SetWide(Container.buttonW)
    function Container.ButtonContainer.ButtonConfirm:DoClick()
        Container:Close()
        if (confirmFunc) then confirmFunc() end
    end
end

-- concommand.Add('EditorPopup', function()
--     base.EditorPopup(

--     )
-- end)
