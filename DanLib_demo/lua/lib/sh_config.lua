
LIB.Config.Different = {
    Chat = {
        NONE_COLOR = Color(255, 255, 255),

        PREFIX = '[Libs]',
        PREFIX_COLOR = Color(255, 195, 56),

        SUCCESS_MSG = 'Успешно!',
        SUCCESS_COLOR = Color(83, 199, 0),

        WARNING_MSG = 'Внимание!',
        WARNING_COLOR = Color(255, 129, 56),

        ERROR_MSG = 'Ошибка!',
        ERROR_COLOR = Color(255, 69, 0),

        MESSAGES_TYPE = {
            NONE = 0,
            SUCCESS = 1,
            WARNING = 2, 
            ERROR = 3,
            RP = 4
        }
    },
    Fonts = {
        MainFont = 'Rubik'
    }
}


LIB.Config.Links = {
    -- WebSite
    WebSite = 'https://google.com', -- Link to the website
    -- Social network
    VK = 'https://google.com', -- Link to VK
    Discord = 'https://google.com', -- Link to Discord
    Workshop = 'https://google.com', -- Link to Steam
    SteamProfile = 'https://steamcommunity.com/profiles/76561198405398290/', -- Link to Steam Profile
    GitHub = 'https://github.com/denchik5133', -- Link to GitHub
    YouTube = 'https://www.youtube.com/channel/UCoziZcyU3nUZElZoscwvZyQ', -- Link to YouTube
    Documentation = 'https://google.com' -- Link to documentation. [Example: Googl Document]
}

-- Who can open the DanLib Menu
LIB.Config.Access = {
    ['superadmin'] = true,
    ['senioradmin'] = true,
}

-- Primary colors
LIB.Config.Theme = {
    Background = Color(57, 64, 78),         -- Для заднего фона.
    Primary = Color(35, 35, 35),            -- Основной цвент окон и элементов.
    Button = Color(51, 51, 51),
    Accent = Color(255, 140, 0),            -- Цвет для элементов декора. (полосы, разделители и т.д.)
    AccentQ = Color(38, 38, 38),            -- Цвет для элементов декора. (полосы, разделители и т.д.)

    Text = Color(220, 221, 225),            -- Цвет текста
    HoveredText = Color(245, 246, 250),     -- Цвет текста, но при наведении. (кнопки и другие активные эелементы)
    HightlightText = Color(255, 140, 0),    -- Цвет текста, но для выделения.

    DarkScroll = Color(255, 140, 0, 5),     -- Болеё темный цвет скролла
    Scroll = Color(255, 140, 0),            -- Цвет скролла

    DarkGray = Color(47, 54, 64),           -- Тёмно-серый
    Gray = Color(113, 128, 147),            -- Серый
    Red = Color(194, 54, 22),               -- Красный цвет.
    LightRed = Color(232, 65, 24),          -- Красный, но светлее. 
    DarkBlue = Color(64, 115, 158),         -- Тёмно-синий
    Blue = Color(0, 151, 230),              -- Синий
    DarkGreen = Color(68, 189, 50),         -- Зелёный, но темнее.
    Green = Color(76, 209, 55),             -- Зелёный. 
    Yellow = Color(251, 197, 49),           -- Желтый

    AlphaWhite = Color(220, 221, 225, 50)   -- Этот цвет нужен для блюра, лучше не трогать.
}


LIB.Config.Materials = {

}

MESSAGE_TYPE_NONE = 0
MESSAGE_TYPE_SUCCESS = 1
MESSAGE_TYPE_WARNING = 2
MESSAGE_TYPE_ERROR = 3

hook.Run('LIB::ThemeLoaded') -- IN NO CASE SHOULD YOU TOUCH
