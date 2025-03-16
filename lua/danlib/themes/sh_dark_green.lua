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
 


local THEME = DanLib.Func.CreateTheme('dark_green')
THEME:SetName('Dark Green')
THEME:SetAuthor('denchik')
THEME:SetDescription('Dark green theme, with a cosy atmosphere and good text readability. Suitable for a modern interface, providing comfortable use.')
THEME:SetVersion('1.0.0')
THEME:SetStrings({
    --// Basic
    ['background'] = Color(18, 28, 18), -- Темный зеленый фон
    ['secondary'] = Color(34, 49, 34), -- Более светлый зеленый
    ['secondary_dark'] = Color(24, 36, 24), -- Темный зеленый
    ['frame'] = Color(50, 70, 50), -- Светлый зеленый

    --// It is mainly used for DanLib.UI.PopupBasis
    ['line_up'] = Color(40, 55, 40), -- Более светлый зеленый

    --// Color materials/icons
    ['mat'] = Color(255, 255, 255), -- Белый для иконок

    --// Color decor
    ['decor'] = Color(0, 150, 136), -- Теплый зеленый (например, бирюзовый)
    ['decor2'] = Color(0, 188, 212), -- Яркий бирюзовый

    --// Color text
    ['title'] = Color(255, 255, 255, 255), -- Белый для заголовков
    ['text'] = Color(220, 221, 225), -- Светло-серый текст

    --// Color buttons
    ['button'] = Color(34, 49, 34), -- Темно-зеленая кнопка
    ['button_hovered'] = Color(45, 63, 45), -- Более светлая кнопка при наведении

    --// Color notifications
    ['primary_notifi'] = Color(23, 33, 43), -- Темный фон уведомлений

    --// Color scroll
    ['scroll'] = Color(23, 33, 43), -- Темный цвет скролла
    ['scroll_dark'] = Color(40, 55, 40), -- Более светлый цвет скролла

    --// Color DMenu
    ['dmenu'] = Color(23, 33, 43), -- Темный фон DMenu
    ['dmenu_hover'] = Color(35, 46, 60), -- Светлый фон DMenu при наведении

    --// Settings page
    ['button_page_a'] = Color(28, 35, 52), -- Темный фон страницы настроек
    ['button_page_b'] = Color(35, 41, 54), -- Более светлый фон страницы настроек
    ['button_page_line'] = Color(29, 36, 52), -- Линия на странице настроек

    --// TextEntry/NumberWang/ComboBox
    ['decor_elements'] = Color(34, 49, 34), -- Темно-зеленые элементы

    --// Used for panel like in Page Profile or Popup NPC.
    ['panel_background'] = Color(35, 44, 56), -- Темный фон панели
    ['panel_line_up'] = Color(41, 53, 69), -- Линия на панели
})
THEME:Register()
