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
 


local THEME = DanLib.Func.CreateTheme('dark_orange')
THEME:SetName('Dark Orange Theme')
THEME:SetAuthor('denchik')
THEME:SetDescription('Dark Orange Theme')
THEME:SetVersion('1.0.0')
THEME:SetStrings({
    --// Basic
    ['background'] = Color(35, 34, 34),
    ['secondary'] = Color(34, 33, 33),
    ['secondary_dark'] = Color(50, 50, 50),

    --// It is mainly used for DanLib.UI.PopupBasis
    ['line_up'] = Color(45, 45, 45),

    --// Color materials/icons
    ['mat'] = Color(255, 255, 255),

    --// Color decor
    ['decor'] = Color(255, 75, 0),
    ['decor2'] = Color(233, 71, 1),

    --// Color text
    ['title'] = Color(255, 255, 255, 255),
    ['text'] = Color(220, 221, 225),

    --// Color buttons
    ['button'] = Color(169, 64, 20),
    ['button_hovered'] = Color(119, 62, 31),

    --// Color notifications
    ['primary_notifi'] = Color(29, 28, 28),

    --// Color scroll
    ['scroll'] = Color(23, 33, 43),
    ['scroll_dark'] = Color(46, 52, 60),

    --// Color DMenu
    ['dmenu'] = Color(32, 32, 32),
    ['dmenu_hover'] = Color(126, 51, 20),

    --// Settings page
    ['button_page_a'] = Color(21, 19, 19),
    ['button_page_b'] = Color(29, 28, 26),
    ['button_page_line'] = Color(126, 51, 20),

    --// TextEntry/NumberWang/ComboBox
    ['decor_elements'] = Color(119, 62, 31),

    --// Used for panel like in Page Profile or Popup NPC.
    ['panel_background'] = Color(37, 36, 36),
    ['panel_line_up'] = Color(31, 30, 30),
})
THEME:Register()