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


do
    local BASE = DanLib.CreateUserModule('BASE')
    BASE:SetTitle('Base')
        :SetIcon('HuFRarz')
        :SetDescription('Basic client-side settings for the game')
        :SetColor(Color(255, 165, 0))
        :SetSortOrder(1)

    -- Add some example configuration options
    BASE:AddOption('ShowParticles', 'Particles', 'The particles interact with mouse movements to create visual effects.', DanLib.Type.Bool, true)

    -- Register the module
    BASE:Register()
end


--- Load all configurations
-- DanLib.LoadUserConfig()
