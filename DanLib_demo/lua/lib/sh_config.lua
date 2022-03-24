
DanLib.Config.Different = {
    Chat = {
        NONE_COLOR = Color(255, 255, 255),

        PREFIX = '[DanLib]',
        PREFIX_COLOR = Color(255, 195, 56),

        SUCCESS_MSG = 'Successfully!',
        SUCCESS_COLOR = Color(83, 199, 0),

        WARNING_MSG = 'Attention!',
        WARNING_COLOR = Color(255, 129, 56),

        ERROR_MSG = 'Mistake!',
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
        MainFont = 'Rubik' -- Main font
    },
    Commands = {
        Prefixes = {
            '!',
            '/'
        }
    },
}


DanLib.Config.Links = {
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
DanLib.Config.Access = {
    ['superadmin'] = true,
    ['senioradmin'] = true,
}

-- Primary colors
DanLib.Config.Theme = {
    Background = Color(57, 64, 78),         -- For the background.
    Primary = Color(35, 35, 35),            -- The main color of windows and elements.
    Button = Color(51, 51, 51),             -- The color of the buttons.

    Accent = Color(255, 140, 0),            -- Color for decorative elements. (stripes, dividers, etc.)
    AccentQ = Color(38, 38, 38),            -- Color for decorative elements. (stripes, dividers, etc.)

    Text = Color(220, 221, 225),            -- Text color.
    HoveredText = Color(245, 246, 250),     -- The color of the text, but on hover. (buttons and other active elements)
    HightlightText = Color(255, 140, 0),    -- The color of the text, but for highlighting.

    DarkScroll = Color(255, 140, 0, 5),     -- Darker scroll color
    Scroll = Color(255, 140, 0),            -- Scroll Color

    DarkGray = Color(47, 54, 64),           -- Dark grey
    Gray = Color(113, 128, 147),            -- Gray
    Red = Color(194, 54, 22),               -- Red color.
    LightRed = Color(232, 65, 24),          -- Red, but lighter. 

    DarkBlue = Color(64, 115, 158),         -- Dark blue
    Blue = Color(0, 151, 230),              -- Blue
    DarkGreen = Color(68, 189, 50),         -- Green, but darker.
    Green = Color(76, 209, 55),             -- Green. 
    Yellow = Color(251, 197, 49),           -- Yellow

    AlphaWhite = Color(220, 221, 225, 50)   -- This color is needed for the blurr, it is better not to touch.
}

DanLib.Config.Style.ID = 'danlib_material'                          -- This is for caching materials,
                                                                    -- ATTENTION: The ID must be unique!

DanLib.Config.Materials = {
    CloseButton = 'https://i.imgur.com/uSqgmuD.png',                -- Close button
    SettingsButton = 'https://i.imgur.com/5em8djK.png',             -- Settings

    LogoNormal = 'https://i.imgur.com/xdPIrGC.png',                 -- Normal logo
    SkullIcon = 'https://i.imgur.com/K73SvR5.png',                  -- Skull icon for the death screen

    Add = 'https://i.imgur.com/q8OyHg8.png',                        -- Adding icon
    Event = 'https://i.imgur.com/lnwgjaw.png',

    -- Information menu
    Money = 'https://i.imgur.com/EhYWtGi.png',                      -- Icon for money
    Arrow = 'https://i.imgur.com/0R38Q7r.png',                      -- Arrow
    Save = 'https://i.imgur.com/Bapzkzg.png',

    -- Base Configuration Menu
    Testing = 'https://i.imgur.com/LTbqglU.png',                     -- Testing Icon
    MenuToggle = 'https://i.imgur.com/xGVY8DN.png',                  -- Settings Icon
    Settings = 'https://i.imgur.com/A39XiNJ.png',                    -- Settings Icon
    Modules = 'https://i.imgur.com/RYw22ER.png',

    Addition = 'https://i.imgur.com/X6zXK0x.png',
    BaseSettings = 'https://i.imgur.com/ySVKFgc.png',
    NewAdditions = 'https://i.imgur.com/5hZu4qC.png',

    BaseConfig = 'https://i.imgur.com/JGf9DzB.png',
    Configuration = 'https://i.imgur.com/sza5tdG.png',               -- Configuration icon
    ChatCommand = 'https://i.imgur.com/UN7k3Sd.png',                 -- Chat Command icon
    Language = 'https://i.imgur.com/XBpM8vX.png',                    -- Language Icon
    Interface = 'https://i.imgur.com/irRjpPD.png',                   -- Interface Icon

    AboutAuthor = 'https://i.imgur.com/dddlY1t.png',
}

MESSAGE_TYPE_NONE = 0
MESSAGE_TYPE_SUCCESS = 1
MESSAGE_TYPE_WARNING = 2
MESSAGE_TYPE_ERROR = 3
