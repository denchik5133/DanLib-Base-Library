local Fonts = DanLib.Config.Different.Fonts

surface.CreateFont( 'font_sans_3d2d_large', { font = Fonts.MainFont, size = 128, weight = 500, extended = true })
surface.CreateFont( 'font_sans_3d2d_small', { font = Fonts.MainFont, size = 72, weight = 500, extended = true })
surface.CreateFont( 'font_sans_3d2d_title', { font = Fonts.MainFont, size = 55, weight = 500, extended = true })

local fontSizes = {
    56,
    35,
    32,
    30,
    26,
    24,
    22,
    21,
    18,
    16,
}

for i = 1, #fontSizes do
    local size = fontSizes[i]
    surface.CreateFont( 'font_sans_' .. size, {
        font = Fonts.MainFont,
        size = size,
        weight = 500,
        extended = true,
    } )
end



surface.CreateFont( 'font_dan_35', { font = 'Roboto', size = 35, weight = 500, extended = true }) -- Test

surface.CreateFont('font_dan_40', {
    font = 'Good Times Rg',
    extended = false,
    size = 40,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true
})