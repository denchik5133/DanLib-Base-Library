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
 


local THEME = DanLib.Func.CreateTheme('default')
THEME:SetName('Default')
THEME:SetAuthor('denchik')
THEME:SetDescription('Default library dark-blue-themed look.')
THEME:SetVersion('1.5.3')
THEME:SetStrings({
    -- Basic
    ['background'] = Color(14, 22, 33), -- #0E1621
    ['secondary'] = Color(36, 47, 61), -- #242F3D
    ['secondary_dark'] = Color(24, 36, 51), -- #182533
    ['frame'] = Color(37, 56, 79),

    -- It is mainly used for DanLib.UI.PopupBasis
    ['line_up'] = Color(36, 47, 61), -- #242F3D

    -- Color materials/icons
    ['mat'] = Color(255, 255, 255),

    -- Color decor
    ['decor'] = Color(255, 165, 0), -- #FFA500
    ['decor2'] = Color(0, 151, 230), -- #0097E6

    -- Color text
    ['title'] = Color(255, 255, 255, 255),
    ['text'] = Color(220, 221, 225),

    -- Color buttons
    ['button'] = Color(42, 47, 60),
    ['button_hovered'] = Color(56, 63, 80), -- #383F50

    -- Color notifications
    ['primary_notifi'] = Color(23, 33, 43), -- #17212B

    -- Color scroll
    ['scroll'] = Color(23, 33, 43), -- #17212B
    ['scroll_dark'] = Color(36, 47, 61),

    -- Color DMenu
    ['dmenu'] = Color(23, 33, 43), -- #17212B
    ['dmenu_hover'] = Color(35, 46, 60),

    -- Settings page
    ['button_page_a'] = Color(28, 35, 52),
    ['button_page_b'] = Color(35, 41, 54),
    ['button_page_line'] = Color(29, 36, 52),

    -- TextEntry/NumberWang/ComboBox
    ['decor_elements'] = Color(42, 47, 60), -- #2A2F3C

    -- Used for panel like in Page Profile or Popup NPC.
    ['panel_background'] = Color(35, 44, 56),
    ['panel_line_up'] = Color(41, 53, 69),
})
THEME:Register()