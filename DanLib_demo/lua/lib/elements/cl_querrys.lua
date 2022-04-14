--[[--
Модуль запросов
LIB предоставляет своим пользователям возможноть взаемодействывать с игроком посредством запросов.
Этими запросами можно получить информацию от игрока, или дать её игроку.

    LIB.Donate('Дополнительный слот для персонажа', 200,
        function() /* Отправить запрос о покупке на сервер, там будет проверено ли хватает денег и если хватает, то будет выдан слот и списаны деньги */ end, -- При согласии
        function() /* Вывести в чат: "Если вам станет скучно играть за этого персонажа - вы знаете где найти меня ;)" */ end -- При отмене
    )
]]
-- @module LIB

local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub('.', function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return '\n' .. char
        end

        return char
    end)

    return text, totalWidth
end

function LIB.textWrap(text, font, maxWidth)
    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                totalWidth = 0
            end

            local wordlen = surface.GetTextSize(word)
            totalWidth = totalWidth + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= maxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
                totalWidth = splitPoint
                return splitWord
            elseif totalWidth < maxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                totalWidth = wordlen - spaceWidth
                return '\n' .. string.sub(word, 2)
            end

            totalWidth = wordlen
            return '\n' .. word
        end)

    return text
end

--- Структура кнопок
-- @realm client
-- @table ButtonsStructure
-- @field[type=table] 1 Таблица кнопки
-- @field[type=table,opt] 2 Таблица кнопки
-- @field[type=table,opt] 3 Таблица кнопки
-- @field[type=table,opt] 4 Таблица кнопки
-- @see ButtonStructure
-- @usage 
-- {
--     [1] = {
--         Text = "Кнопка 1",
--         Click = function()
--             print("Кнопка #1 нажата")
--         end
--     },
--     [2] = {
--         Text = "Кнопка 2",
--         Click = function()
--             print("Кнопка #2 нажата")
--         end
--     },
-- }

--- Структура кнопки
-- @realm client
-- @table ButtonStructure
-- @field[type=string] Text Текст на кнопке
-- @field[type=func,opt="panel:Remove()"] Click Функция, которая будет вызвана при нажатии на кнопку.
-- @usage {
--      Text = "Это кнопка",
--      Click = function(panel) panel:Remove() end
-- }

--- Предустановлиене материалы
-- @realm client
-- @table LIB.Materials
-- @field[type=material] Information Материал иконки с буквой "I". [Посмотреть](https://i.imgur.com/Zmqwdjp.png)
-- @field[type=material] Question Материал иконки с знаком "?". [Посмотреть](https://i.imgur.com/wtFYIU2.png)
-- @field[type=material] Confirm Материал иконки с галочкой. [Посмотреть](https://i.imgur.com/QRipy9l.png)
-- @field[type=material] Warning Материал иконки с занком "!". [Посмотреть](https://i.imgur.com/QqxE5lq.png)
-- @field[type=material] Error Материал иконки с крестиком. [Посмотреть](https://i.imgur.com/Tqjmh9q.png)
-- @field[type=material] Donate Материал иконки с рублём. [Посмотреть](https://i.imgur.com/dfrGlGn.png)
-- @usage local material = LIB.Materials.Information -- материал иконки информации
-- 
-- -- Где-то позже
-- surface.SetMaterial(material)
-- surface.DrawTexturedRect(0, 0, 64, 64)

LIB.Materials = {
    Information = 'https://i.imgur.com/Zmqwdjp.png',
    Question = 'https://i.imgur.com/wtFYIU2.png',

    Confirm = 'https://i.imgur.com/QRipy9l.png',
    Warning = 'https://i.imgur.com/QqxE5lq.png',
    Error = 'https://i.imgur.com/Tqjmh9q.png',

    Donate = 'https://i.imgur.com/dfrGlGn.png',
    Key = 'https://i.imgur.com/pUiV5qJ.png',

    Locator = 'https://i.imgur.com/EOUj7NC.png',
    CloseButton = 'https://i.imgur.com/uSqgmuD.png',

    Reset = 'https://i.imgur.com/ei4v9WW.png'
}

local Materials = LIB.Materials

if IsValid(CMRPPopupFrame) then CMRPPopupFrame:Remove() end
if IsValid(CMRPOnScreenPopupFrame) then CMRPOnScreenPopupFrame:Remove() end

for k, v in pairs(Materials) do
    local path = 'LIB/popups/'..string.lower(k)..'.png'
	local dPath = 'data/'..path

	if(file.Exists(path, 'DATA')) then Materials[k] = Material(dPath, 'mips') end
	if(not file.IsDir(string.GetPathFromFilename(path), 'DATA')) then file.CreateDir(string.GetPathFromFilename(path)) end


	http.Fetch(v, function(body, size, headers, code)
		if(code != 200) then return errorCallback(code) end
		file.Write(path, body)
		Materials[k] = Material(dPath, 'mips')
        
	end)
end

QUERY_MAT_DONAT = Materials.Question
QUERY_MAT_TEST = Materials.CloseButton
QUERY_MAT_QUESTION = Materials.Question
QUERY_MAT_WARNING = Materials.Warning
QUERY_MAT_RESET = Materials.Reset
QUERY_MAT_SUCCESS = Materials.Confirm

local textWrap = LIB.textWrap

-- =========
-- = Интерактывные всплывающие окна.
-- =========

--
-- Вывод текста и кнопок
--

hook.Add('LIB::ConfigLoaded', 'LIB::Querrys', function()

local Colors = {
    Information = LIB.Config.Theme.Accent,
    Question = LIB.Config.Theme.Accent,

    Confirm = LIB.Config.Theme.Green,
    Warning = LIB.Config.Theme.Yellow,
    Error = LIB.Config.Theme.Red,
}

--- Вывод текста на экран, с указаными кнопками
-- @realm client
-- @tparam material|LIB.Materials mIcon Материал иконки
-- @tparam color tIconColor Цвет иконки
-- @tparam string sText Текст
-- @tparam ButtonsStructure tButtons Кнопки
-- @treturn nil
-- @see ButtonsStructure
-- @see ButtonStructure
-- @see LIB.Materials
-- @aliases `LIB:Querry(mIcon, tIconColor, sText, tButtons)`
function LIB.Default(mIcon, tIconColor, sText, tButtons)
    if IsValid(CMRPPopupFrame) then CMRPPopupFrame:Remove() end

    CMRPPopupFrame = vgui.Create('DFrame')

    local frame = CMRPPopupFrame
    frame:SetSize(0, 0)
    frame:Center()
    frame:MakePopup() 
    frame:SetTitle('')
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    
    frame.text = textWrap(sText, 'font_sans_16', 400)
    
    surface.SetFont('font_sans_16')
    frame.textSizeX, frame.textSizeY = surface.GetTextSize(frame.text)

    function frame:Create()
        self.Blur = TDLib('DPanel')
            :ClearPaint()
            :Blur()
            :FadeIn(.5)
        self.Blur:SetSize(ScrW(), ScrH())
        
        self.Blur.OldRemove = self.Blur.Remove
        function self.Blur:Remove()
            self:FadeOut(.7)
            timer.Simple(.7, function() self:OldRemove() end)
        end

        local anim = self:NewAnimation(.5, 0, -1, function()
            self:AddButtons()
        end)
        anim.Size = Vector(500, 150 + self.textSizeY, 0)
        anim.Pos = Vector(ScrW() * .5 - 250, ScrH() * .5 - 75 - self.textSizeY * .5, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then anim.StartPos = Vector( ScrW() * .5, ScrH() * .5, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( 500, size.y ) 
            panel:SetPos( ScrW() * .5 - 250, pos.y )
        end
    end
    frame.OldRemove = frame.Remove
    function frame:Remove()
        for k, v in pairs(self:GetChildren()) do
            if v.FadeOut then
                v:FadeOut(.2)
            end
        end
        if frame.Blur then
            frame.Blur:Remove()
        end
        local anim = self:NewAnimation(.5, .2, -1, function()
            frame:OldRemove()
        end)
        anim.Size = Vector(500, 0, 0)
        anim.Pos = Vector(ScrW() * .5 - 250, ScrH() * .5, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then local w, h = panel:GetPos() anim.StartPos = Vector( w, h, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( 500, size.y ) 
            panel:SetPos( ScrW() * .5 - 250, pos.y )
        end
    end

    function frame:AddButtons()
        
        local ButtonBase = TDLib('DPanel', frame)
            :ClearPaint()

        ButtonBase:SetWide(500)
        ButtonBase:SetPos(0, self:GetTall() - 40)

        local x = 0
        for k, v in pairs(tButtons) do
            local button = TDLib('DButton', ButtonBase)
                :ClearPaint()
                :Background(LIB.Config.Theme.Background)
                :FadeHover()
                :BarHover(LIB.Config.Theme.Accent)
                :CircleClick(LIB.Config.Theme.AlphaWhite)
                :Text(v.Text, 'font_sans_21')
                :FadeIn()
                :Stick(LEFT)
                :SetRemove(self)
                :On('DoClick', function()
                    if v.Click then v.Click(frame) end
                end)
            
            button:SetWide(84)
            button:DockMargin(2, 0, 2, 0)

            x = x + button:GetWide() + 4
        end

        ButtonBase:SetWide(x)
        ButtonBase:CenterHorizontal()
    end

    function frame:Paint(w, h)
        surface.SetDrawColor(LIB.Config.Theme.Background)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(LIB.Config.Theme.AccentQ)
        surface.DrawRect(0, 0, w, 5)
        surface.DrawRect(0, h - 5, w, 5)

        frame:DrawIcon(w, h)

        draw.DrawText(self.text, 'font_sans_16', 25, 96, color_white)
    end

    function frame:DrawIcon(w, h)
        surface.SetDrawColor(tIconColor)
        surface.SetMaterial(mIcon)

        surface.DrawTexturedRect(w * .5 - 32, 16, 64, 64)
    end

    frame:Create()
    frame:DoModal()
end

function LIB:Querry(mIcon, tIconColor, sText, tButtons)
    return LIB.Default(mIcon, tIconColor, sText, tButtons)
end

---Обертка для обычной Querry, для донат услуги
-- @realm client
---@tparam string sName Название донат товара
---@tparam string|number sPrice Цена донат товара
---@tparam func fBuy Функция вызваная при подтверждении покупки
---@tparam[opt="panel:Remove()"] func fCancel Функция вызваная при отмене покупки
---@treturn nil
-- @aliases `LIB:QuerryDonate(sName, sPrice, fBuy, fCancel)`
function LIB.Donate(sName, sPrice, fBuy, fCancel)
    LIB:Querry(Materials.Donate,
        LIB.Config.Theme.Yellow,
        'Вы хотите купить '..'300',
        {
            {
                Text = 'Да',
                Click = fBuy or function(frame)
                    
                end
            },
            {
                Text = 'Нет',
                Click = fCancel or function(frame)
                    
                end
            }
        }
    )
end

function LIB:QuerryDonate(sName, sPrice, fBuy, fCancel)
    LIB.Donate(sName, sPrice, fBuy, fCancel)
end
---Обертка для обычной Querry, для информации
-- @realm client
-- @tparam string sText Текст
-- @tparam[opt="panel:Remove()"] func fOK Функция вызваная при нажатии "принять"
-- @treturn nil
-- @aliases `LIB:QuerryInformation(sText, fOK)`
function LIB.Information(sText, fOK)
    LIB:Querry(Materials.Information,
        LIB.Config.Theme.Yellow,
        sText,
        {
            {
                Text = 'Принять',
                Click = fOK or function(frame) end
            }
        }
    )
end
function LIB:QuerryInformation(sText, fOK)
    LIB.Information(sText, fOK)
end

---Обертка для обычной Querry, для выбора
-- @realm client
-- @tparam string sText Текст
-- @tparam func fConfirm Функция вызваная при нажатии "Да"
-- @tparam[opt="panel:Remove()"] func fCancel Функция вызваная при нажатии "Нет"
-- @return nil
-- @aliases LIB:QuerryChoose(sText, fConfirm, fCancel)
function LIB.Choose(sText, fConfirm, fCancel)
    LIB:Querry(Materials.Question,
        LIB.Config.Theme.Yellow,
        sText,
        {
            {
                Text = 'Да',
                Click = fConfirm or function(frame)
                    
                end
            },
            {
                Text = 'Нет',
                Click = fCancel or function(frame)
                    
                end
            }
        }
    )
end
function LIB:QuerryChoose(sText, fConfirm, fCancel)
    LIB.Choose(sText, fConfirm, fCancel)
end

---Обертка для обычной Querry, для предупреждений
-- @realm client
-- @tparam string sText Текст + Продолжить?
-- @tparam func fConfirm Функция вызваная при нажатии "Да"
-- @tparam func[opt="panel:Remove()"] fCancel Функция вызваная при нажатии "Нет"
-- @treturn nil
-- @aliases LIB:QuerryWarning(sText, fConfirm, fCancel)
function LIB.Warning(sText, fConfirm, fCancel)
    LIB:Querry(Materials.Warning,
        LIB.Config.Theme.Yellow,
        sText .. '\nПродолжить?',
        { 
            {
                Text = 'Да',
                Click = fConfirm or function(frame)
                    
                end
            },
            {
                Text = 'Нет',
                Click = fCancel or function(frame)
                    
                end
            }
        }
    )
end

function LIB:QuerryWarning(sText, fConfirm, fCancel)
    LIB.Warning(sText, fConfirm, fCancel)
end

-- 
-- Вывод поля для ввода
--

---Вывод поля для ввода
-- @realm client
-- @tparam material|LIB.Materials mIcon Иконка
-- @tparam color tIconColor Цвет иконки
-- @tparam string sText Текст
-- @tparam string sDefaultText @Стандартный тест поля
-- @tparam string sOkText Текст на кнопке принятия
-- @tparam func fCallback Функция при вводе, `function(string Value) end`, первый аргумент - введеное значение.
-- @tparam string sCancelText Текст на кнопке отклонения
-- @tparam func fCancelCallback Функция при отмене
-- @treturn nil
-- @see LIB.Materials
-- @aliases `LIB.QuerryText(mIcon, tIconColor, sText, sDefaultText, sOkText, fCallback, sCancelText, fCancelCallback)`
function LIB.QuerryTexts(mIcon, tIconColor, sText, sDefaultText, sOkText, fCallback, sCancelText, fCancelCallback)
    if IsValid(CMRPPopupFrame) then CMRPPopupFrame:Remove() end

    CMRPPopupFrame = vgui.Create('DFrame')

    local tButtons = {
        {
            Text = sOkText or 'Подтвердить',
            Click = fCallback or function(frame) end
        },
        {
            Text = sCancelText or 'Отмена',
            Click = fCancelCallback or function(frame) end
        }
    }

    local frame = CMRPPopupFrame
    frame:SetSize(0, 0)
    frame:Center()
    frame:MakePopup() 
    frame:SetTitle('')
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    
    frame.text = textWrap(sText, 'font_sans_16', 400)
    
    surface.SetFont('font_sans_16')
    frame.textSizeX, frame.textSizeY = surface.GetTextSize(frame.text)

    function frame:Create()
        self.Blur = TDLib('DPanel')
            :ClearPaint()
            :Blur()
            :FadeIn(.5)
        self.Blur:SetSize(ScrW(), ScrH())
        
        self.Blur.OldRemove = self.Blur.Remove
        function self.Blur:Remove()
            self:FadeOut(.7)
            timer.Simple(.7, function() self:OldRemove() end)
        end

        local anim = self:NewAnimation(.5, 0, -1, function()
            self:AddButtons()
        end)
        anim.Size = Vector(500, 175 + self.textSizeY, 0)
        anim.Pos = Vector(ScrW() * .5 - 250, ScrH() * .5 - (175 * .5) - self.textSizeY * .5, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then anim.StartPos = Vector( ScrW() * .5, ScrH() * .5, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( 500, size.y ) 
            panel:SetPos( ScrW() * .5 - 250, pos.y )
        end
    end
    frame.OldRemove = frame.Remove
    function frame:Remove()
        for k, v in pairs(self:GetChildren()) do
            if v.FadeOut then
                v:FadeOut(.2)
            end
        end
        if frame.Blur then
            frame.Blur:Remove()
        end
        local anim = self:NewAnimation(.5, .2, -1, function()
            frame:OldRemove()
        end)
        anim.Size = Vector(500, 0, 0)
        anim.Pos = Vector(ScrW() * .5 - 275, ScrH() * .5, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then local w, h = panel:GetPos() anim.StartPos = Vector( w, h, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( 500, size.y ) 
            panel:SetPos( ScrW() * .5 - 250, pos.y )
        end
    end

    function frame:AddButtons()
        
        local Text = vgui.Create('DTextEntry', self)
        Text:SetWide(450)
        Text:SetPos(0, self:GetTall( ) - 40 - 25)
        Text:CenterHorizontal()
        Text:SetValue(sDefaultText or '')
        Text:RequestFocus()

        local ButtonBase = TDLib('DPanel', self)
            :ClearPaint()

        ButtonBase:SetWide(500)
        ButtonBase:SetPos(0, self:GetTall() - 40)

        local x = 0
        for k, v in pairs(tButtons) do
            local button = TDLib('DButton', ButtonBase)
                :ClearPaint()
                :Background(LIB.Config.Theme.Background)
                :FadeHover()
                :BarHover(LIB.Config.Theme.Accent)
                :CircleClick(LIB.Config.Theme.AlphaWhite)
                :Text(v.Text, 'font_sans_21')
                :FadeIn()
                :Stick(LEFT)
                :SetRemove(self)
                :On('DoClick', function()
                    if v.Click then v.Click(Text:GetValue(), self) end
                end)
            
            button:SetWide(120)
            button:DockMargin(2, 0, 2, 0)

            x = x + button:GetWide() + 4
        end

        ButtonBase:SetWide(x)
        ButtonBase:CenterHorizontal()

        ButtonBase:CenterHorizontal()
    end

    function frame:Paint(w, h)
        surface.SetDrawColor(LIB.Config.Theme.Background)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(LIB.Config.Theme.AccentQ)
        surface.DrawRect(0, 0, w, 5)
        surface.DrawRect(0, h - 5, w, 5)

        frame:DrawIcon(w, h)

        draw.DrawText(self.text, 'font_sans_16', 25, 96, color_white)
    end

    function frame:DrawIcon(w, h)
        surface.SetDrawColor(tIconColor)
        surface.SetMaterial(mIcon)

        surface.DrawTexturedRect(w * .5 - 32, 16, 64, 64)
    end

    frame:Create()
    frame:DoModal()
end
function LIB:QuerryText(mIcon, tIconColor, sText, sDefaultText, sOkText, fCallback, sCancelText, fCancelCallback)
    LIB.QuerryTexts(mIcon, tIconColor, sText, sDefaultText, sOkText, fCallback, sCancelText, fCancelCallback)
end

-- 
-- Выбор кнопки
--
function LIB:QuerryButton(mIcon, tIconColor, sText, nDefaultButton, sOkText, fCallback, sCancelText, fCancelCallback)
    if IsValid(CMRPPopupFrame) then CMRPPopupFrame:Remove() end

    CMRPPopupFrame = vgui.Create('DFrame')

    local tButtons = {
        {
            Text = sOkText or 'Подтвердить',
            Click = fCallback or function(frame) end
        },
        {
            Text = sCancelText or 'Отмена',
            Click = fCancelCallback or function(frame) end
        }
    }

    local frame = CMRPPopupFrame
    frame:SetSize(0, 0)
    frame:Center()
    frame:MakePopup() 
    frame:SetTitle('')
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    
    frame.text = textWrap(sText, 'font_sans_16', 400)
    
    surface.SetFont('font_sans_16')
    frame.textSizeX, frame.textSizeY = surface.GetTextSize(frame.text)

    function frame:Create()
        self.Blur = TDLib('DPanel')
            :ClearPaint()
            :Blur()
            :FadeIn(.5)
        self.Blur:SetSize(ScrW(), ScrH())
        
        self.Blur.OldRemove = self.Blur.Remove
        function self.Blur:Remove()
            self:FadeOut(.7)
            timer.Simple(.7, function() self:OldRemove() end)
        end

        local anim = self:NewAnimation(.5, 0, -1, function()
            self:AddButtons()
        end)
        anim.Size = Vector(500, 175 + self.textSizeY, 0)
        anim.Pos = Vector(ScrW() * .5 - 250, ScrH() * .5 - (175 * .5) - self.textSizeY * .5, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then anim.StartPos = Vector( ScrW() * .5, ScrH() * .5, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( 500, size.y ) 
            panel:SetPos( ScrW() * .5 - 250, pos.y )
        end
    end
    frame.OldRemove = frame.Remove
    function frame:Remove()
        for k, v in pairs(self:GetChildren()) do
            if v.FadeOut then
                v:FadeOut(.2)
            end
        end
        if frame.Blur then
            frame.Blur:Remove()
        end
        local anim = self:NewAnimation(.5, .2, -1, function()
            frame:OldRemove()
        end)
        anim.Size = Vector(500, 0, 0)
        anim.Pos = Vector(ScrW() * .5 - 275, ScrH() * .5, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then local w, h = panel:GetPos() anim.StartPos = Vector( w, h, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( 500, size.y ) 
            panel:SetPos( ScrW() * .5 - 250, pos.y )
        end
    end

    function frame:AddButtons()
        
        local Text = vgui.Create('DBinder', self)
        Text:SetWide(80)
        Text:SetPos(0, self:GetTall( ) - 40 - 35)
        Text:CenterHorizontal()
        Text:RequestFocus()
        Text:SetValue(nDefaultButton)

        local ButtonBase = TDLib('DPanel', self)
            :ClearPaint()

        ButtonBase:SetWide(500)
        ButtonBase:SetPos(0, self:GetTall() - 40)

        local x = 0
        for k, v in pairs(tButtons) do
            local button = TDLib('DButton', ButtonBase)
                :ClearPaint()
                :Background(LIB.Config.Theme.Background)
                :FadeHover()
                :BarHover(LIB.Config.Theme.Accent)
                :CircleClick(LIB.Config.Theme.AlphaWhite)
                :Text(v.Text, 'font_sans_21')
                :FadeIn()
                :Stick(LEFT)
                :SetRemove(self)
                :On('DoClick', function()
                    if v.Click then v.Click(Text:GetValue(), self) end
                end)
            
            button:SetWide(120)
            button:DockMargin(2, 0, 2, 0)

            x = x + button:GetWide() + 4
        end

        ButtonBase:SetWide(x)
        ButtonBase:CenterHorizontal()

        ButtonBase:CenterHorizontal()
    end

    function frame:Paint(w, h)
        surface.SetDrawColor(LIB.Config.Theme.Background)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(LIB.Config.Theme.AccentQ)
        surface.DrawRect(0, 0, w, 5)
        surface.DrawRect(0, h - 5, w, 5)

        frame:DrawIcon(w, h)

        draw.DrawText(self.text, 'font_sans_16', 25, 96, color_white)
    end

    function frame:DrawIcon(w, h)
        surface.SetDrawColor(tIconColor)
        surface.SetMaterial(mIcon)

        surface.DrawTexturedRect(w * .5 - 32, 16, 64, 64)
    end

    frame:Create()
    frame:DoModal()
end

-- =========
-- = Пассивные экранные уведомления
-- =========

function LIB:ScreenNotify(nTime, mIcon, cIconColor, sText, pSender)
    if IsValid(CMRPOnScreenPopupFrame) then CMRPOnScreenPopupFrame:OldRemove() end
    nTime = nTime or 5
    mIcon = mIcon or Materials.Information
    cIconColor = cIconColor or LIB.Config.Theme.AccentQ

    CMRPOnScreenPopupFrame = vgui.Create('DFrame')

    local frame = CMRPOnScreenPopupFrame 
    frame:SetSize(0, 0)
    frame:SetTitle('')
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    
    if IsValid(pSender) then
        sText = sText..'\n\nОтправитель: '..pSender:Name()
    end

    frame.text = textWrap(sText, 'font_sans_21', 400)

    surface.SetFont('font_sans_21')
    frame.textSizeX, frame.textSizeY = surface.GetTextSize(frame.text)

    function frame:Create()
        self.drawtext = false
        self.ProgressSize = 0

        local anim = self:NewAnimation(.4, 0, -1, function()
            self:Create2()
        end)
        anim.Size = Vector(500, 80 + self.textSizeY, 0)
        anim.Pos = Vector(ScrW() * .5 - 250, 80, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then anim.StartPos = Vector( ScrW() * .5, 120, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( size.x, 5 ) 
            panel:SetPos( pos.x, 80 )
        end
    end

    function frame:Create2()
        local anim = self:NewAnimation(.3, 0, -1, function()
            frame.drawtext = true
            self:Remove()
        end)
        anim.Size = Vector(500, 60 + self.textSizeY, 0)
        anim.Pos = Vector(ScrW() * .5 - 250, 40, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then local w, h = panel:GetPos() anim.StartPos = Vector( w, h, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( 500, size.y ) 
            panel:SetPos( ScrW() * .5 - 250, pos.y )

            panel.textalpha = Lerp(fraction * .6, panel.textalpha or 0, 255)
        end

        local anim2 = self:NewAnimation(nTime, 0, -1, function()
            
        end)

        anim2.Size = 500
        anim2.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then anim.StartSize = 0 end
 
            local size = Lerp(fraction, anim.StartSize, anim.Size)
            
            panel.ProgressSize = size
        end
    end

    frame.OldRemove = frame.Remove
    function frame:Remove()        
        local anim = self:NewAnimation(.4, nTime, -1, function()
            frame.drawtext = false
            frame:Remove2()
        end)
        self.ProgressSize = 0
        anim.Size = Vector(self:GetWide(), 5, 0)
        anim.Pos = Vector(ScrW() * .5 - 250, 120, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then local w, h = panel:GetPos() anim.StartPos = Vector( w, h, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( size.x, size.y ) 
            panel:SetPos( pos.x, pos.y )

            panel.textalpha = Lerp(fraction, panel.textalpha or 0, 0)
        end
    end
    function frame:Remove2()        
        local anim = self:NewAnimation(.3, .2, -1, function()
            frame:OldRemove()
        end)
        
        anim.Size = Vector(0, 5, 0)
        anim.Pos = Vector(ScrW() * .5, 120, 0)

        anim.Think = function(anim, panel, fraction)
            if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
            if ( !anim.StartPos ) then local w, h = panel:GetPos() anim.StartPos = Vector( w, h, 0 ) end
 
            local size = LerpVector( fraction, anim.StartSize, anim.Size )
            local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
            
            panel:SetSize( size.x, size.y ) 
            panel:SetPos( pos.x, pos.y )
        end
    end

    function frame:Paint(w, h)        
        surface.SetDrawColor(Color(40, 40, 40, 150))
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(LIB.Config.Theme.Green)
        surface.DrawRect(0, h - 7, self.ProgressSize, 3)

        surface.SetDrawColor(Color(70, 70, 70))
        surface.DrawRect(0, 0, w, 5)
        surface.DrawRect(0, h - 5, w, 5)

        frame:DrawIcon(w, h)

        draw.DrawText(self.text, 'font_sans_21', 84, h * .5 - self.textSizeY * .5, ColorAlpha(color_white, self.textalpha or 0))
    end

    function frame:DrawIcon(w, h)
        surface.SetDrawColor(ColorAlpha(cIconColor, self.textalpha or 0))
        surface.SetMaterial(mIcon)

        surface.DrawTexturedRect(10, h * .5 - 32, 64, 64)
    end

    frame:Create()
    return frame
end

function LIB:Location(nTime, sText, mBelongsTo)
    local frame = LIB:ScreenNotify(nTime, nil, nil, sText, pSender)

    function frame:DrawIcon(w, h)
        surface.SetDrawColor(ColorAlpha(LIB.Config.Theme.AccentQ, self.textalpha or 0))
        surface.SetMaterial(Materials.Locator)

        surface.DrawTexturedRect(10, h * .5 - 32, 64, 64)

        if mBelongsTo ~= nil then
            surface.SetDrawColor(ColorAlpha(LIB.Config.Theme.Text, self.textalpha or 0))
            surface.SetMaterial(Materials.Key)

            surface.DrawTexturedRect(64 - 16, h * .5 + 16 - 8, 32, 32)
        end
    end
end

netstream.Hook('LIB::ScreenNotify', function(sText, sType, nTime)
    sType = sType or 'Information'

    LIB:ScreenNotify(nTime, Materials[sType], Colors[sType], sText)
end)

end)