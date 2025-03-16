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
 *	 @source 		Link: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/markup.lua
 */



local markupIndex = {}
markupIndex.__index = markupIndex


local string = string
local len = string.len
local match = string.match
local gmatch = string.gmatch
local gsub = string.gsub
local find = string.find
local lower = string.lower

local table = table
local Table = DanLib.Table
local tremove = table.remove

local surface = surface
local sub = string.sub
local textFont = surface.SetFont
local textColor = surface.SetTextColor
local drawText = surface.DrawText
local textPos = surface.SetTextPos
local textSize = surface.GetTextSize

local tostring = tostring
local ipairs = ipairs
local setmetatable = setmetatable
local tonumber = tonumber

local math = math
local max = math.max
local ceil = math.ceil

local utf8 = utf8
local codes = utf8.codes
local char = utf8.char
local offset = utf8.offset
local force = utf8.force


--- Temporary information used when building text frames.
local colour_stack = { Color(255, 255, 255) }
local font_stack = { 'danlib_font_18' }
local blocks = {}

local colourmap = {
	-- it's all black and white
	['black'] =	Color(0, 0, 0),
	['white'] =	Color(255, 255, 255),

	-- it's greys
	['dkgrey'] = Color(64, 64, 64),
	['grey'] = Color(128, 128, 128),
	['ltgrey'] = Color(192, 192, 192),

	-- account for speeling mistakes
	['dkgray'] = Color(64, 64, 64),
	['gray'] = Color(128, 128, 128),
	['ltgray'] = Color(192, 192, 192),

	-- normal colours
	['red'] = Color(255, 0, 0),
	['green'] =	Color(0, 255, 0),
	['blue'] = Color(0, 0, 255),
	['yellow'] = Color(255, 255, 0),
	['purple'] = Color(255, 0, 255),
	['cyan'] = Color(0, 255, 255),
	['turq'] = Color(0, 255, 255),

	-- dark variations
	['dkred'] =	Color(128, 0, 0),
	['dkgreen'] = Color(0, 128, 0),
	['dkblue'] = Color(0, 0, 128),
	['dkyellow'] = Color(128, 128, 0),
	['dkpurple'] = Color(128, 0, 128),
	['dkcyan'] = Color(0, 128, 128),
	['dkturq'] = Color(0, 128, 128),

	-- light variations
	['ltred'] = Color(255, 128, 128),
	['ltgreen'] = Color(128, 255, 128),
	['ltblue'] = Color(128, 128, 255),
	['ltyellow'] = Color(255, 255, 128),
	['ltpurple'] = Color(255, 128, 255),
	['ltcyan'] = Color(128, 255, 255),
	['ltturq'] = Color(128, 255, 255),
}


--- Match the colour name to the rgb value.
-- @param color (string): color name
-- @return The corresponding colour
local function colourMatch(c)
	return colourmap[lower(c)]
end


--- This function is used to extract tag information.
-- @param p1 (string): - tag name
-- @param p2 (string): - tag value
local function ExtractParams(p1, p2)
	if (sub(p1, 1, 1) == '/') then
		local tag = sub(p1, 2, -1)
		if (tag == 'color:') then
			tremove(colour_stack)
		elseif (tag == 'font:') then
			tremove(font_stack)
		end
	else
		if (p1 == 'color:') then
			local rgba = colourMatch(p2)
			if (rgba == nil) then
				rgba = Color(255, 255, 255, 255)
				local x, n = { 'r', 'g', 'b', 'a' }, 1
				for k, v in gmatch(p2, '(%d+),?') do
					rgba[x[n]] = tonumber(k)
					n = n + 1
				end
			end
			Table:Add(colour_stack, rgba)
		elseif (p1 == 'font:') then
			Table:Add(font_stack, tostring(p2))
		end
	end
end


-- Escape entities for markup-safe conversion
local escapeEntities = { 
    ['&'] = '&amp;', 
    ['<'] = '&lt;', 
    ['>'] = '&gt;' 
} 

-- Converts a string to its markup-safe equivalent
-- @param str (string): string to be escaped
-- @return (string): escaped string
function Escape(str)
    return (gsub(tostring(str), '[&<>]', function(c)
        return escapeEntities[c] or c
    end))
end


-- Function for decoding escaped characters
local unescapeEntities = { 
    ['&amp;'] = '&', 
    ['&lt;'] = '<', 
    ['&gt;'] = '>' 
}

-- Function to decode escaped characters
-- @param str (string): string to decode
-- @return (string): decoded string
function Unescape(str)
    return (gsub(tostring(str), '&amp;|&lt;|&gt;', function(c)
        return unescapeEntities[c] or c
    end))
end


-- This function puts data into the "blocks" table depending on whether p is a tag or text.
-- @param p (string): - text or tag to process
local function CheckTextOrTag(p)
    if (p == '') then return end
    if (p == nil) then return end

    -- Processing new tags
    if (sub(p, 1, 1) == '{') then
        -- Check that the tag is correct
        local success, err = pcall(function()
            gsub(p, '{([%a:/]+)%s*([^}]*)}', ExtractParams)
        end)
        if (not success) then
            print('Error during tag processing:' .. err)
        end -- gsub(p, '{([%a:]+)%s*([^}]*)}', ExtractParams)
    else
        local text_block = {}
        text_block.text = p -- Decode text before adding Unescape(p)
        text_block.colour = colour_stack[#colour_stack]
        text_block.font = font_stack[#font_stack]
        Table:Add(blocks, text_block)
    end
end


-- CheckTextOrTag for 3 parameters. Called by string.gsub
-- @param p1 (string): text or tag
-- @param p2 (string): text or tag
-- @param p3 (string): text or tag
local function ProcessMatches(p1, p2, p3)
	if (p1) then CheckTextOrTag(p1) end
	if (p2) then CheckTextOrTag(p2) end
	if (p3) then CheckTextOrTag(p3) end
end


-- Returns the width of the markup block
-- @return block width
function markupIndex:GetWidth()
	return self.totalWidth
end


-- Returns the maximum width of the markup block
-- @return (number): maximum block width
function markupIndex:GetMaxWidth()
	return self.maxWidth or self.totalWidth
end


-- Returns the height of the markup block
-- @return (number): block height
function markupIndex:GetHeight()
	return self.totalHeight
end


-- Returns the dimensions of the markup block
-- @return (number, number): width and height of the block
function markupIndex:Size()
	return self.totalWidth, self.totalHeight
end


--- Draws the markup text on the screen
-- @param xOffset (number): X-axis offset
-- @param yOffset (number): y-axis offset
-- @param halign (number): horizontal alignment (TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT)
-- @param valign (number): vertical alignment (TEXT_ALIGN_TOP, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
-- @param alphaoverride (number): override text alpha value
-- @param textAlign (number): align text inside borders
function markupIndex:Draw(xOffset, yOffset, halign, valign, alphaoverride, textAlign)
	for i, blk in ipairs(self.blocks) do
		local y = yOffset + (blk.height - blk.thisY) + blk.offset.y
		local x = xOffset

		if (halign == TEXT_ALIGN_CENTER) then
			x = x - (self.totalWidth / 2)
		elseif (halign == TEXT_ALIGN_RIGHT) then
			x = x - self.totalWidth
		end

		x = x + blk.offset.x

		if (valign == TEXT_ALIGN_CENTER) then
			y = y - (self.totalHeight / 2)
		elseif (valign == TEXT_ALIGN_BOTTOM) then
			y = y - self.totalHeight
		end

		local alpha = blk.colour.a
		if (alphaoverride) then alpha = alphaoverride end

		textFont(blk.font)
		textColor(blk.colour.r, blk.colour.g, blk.colour.b, alpha)
		textPos(x, y)

		if (textAlign ~= TEXT_ALIGN_LEFT) then
			local lineWidth = self.lineWidths[blk.offset.y]
			if lineWidth then
				if (textAlign == TEXT_ALIGN_CENTER) then
					textPos(x + ((self.totalWidth - lineWidth) / 2), y)
				elseif (textAlign == TEXT_ALIGN_RIGHT) then
					textPos(x + (self.totalWidth - lineWidth), y)
				end
			end
		end

		drawText(blk.text)
	end
end


--- Parses the pseudo-html markup language and creates markup that can be used to display text on the screen.
-- @param text (string): text to parse
-- @param dFont (string): default font
-- @param dColor (Color): default color
-- @param maxwidth (number): maximum width of the text.
-- @return (Markup): markup object
function markupIndex:ParseMarkup(text, dFont, dColor, maxwidth)
	text = force(Escape(text))
	colour_stack = { dColor or Color(255, 255, 255, 255) }
	font_stack = { dFont or 'danlib_font_18' }
	blocks = {}

	if (not find(text, '{')) then text = text .. '{nop}' end
    gsub(text, '([^{}]*)([{][^}]*[}])([^{}]*)', ProcessMatches)

	local xOffset = 0
	local yOffset = 0
	local xSize = 0
	local xMax = 0
	local thisMaxY = 0
	local new_block_list = {}
	local ymaxes = {}
	local lineWidths = {}

	local lineHeight = 0
	for i, blk in ipairs(blocks) do
		textFont(blk.font)
		blk.text = gsub(blk.text, '(&.-;)', unescapeEntities)

		local thisY = 0
		local curString = ''
		for j, c in codes(blk.text) do
			local ch = char(c)
			if (ch == '\n') then
				if (thisY == 0) then
					thisY = lineHeight
					thisMaxY = lineHeight
				else
					lineHeight = thisY
				end

				if (len(curString) > 0) then
					local x1 = textSize(curString)
					local new_block = {
						text = curString,
						font = blk.font,
						colour = blk.colour,
						thisY = thisY,
						thisX = x1,
						offset = { x = xOffset, y = yOffset }
					}
					Table:Add(new_block_list, new_block)
					if (xOffset + x1 > xMax) then xMax = xOffset + x1 end
				end

				xOffset = 0
				xSize = 0
				yOffset = yOffset + thisMaxY
				thisY = 0
				curString = ''
				thisMaxY = 0
			elseif (ch == '\t') then
				if (len(curString) > 0) then
					local x1 = textSize(curString)
					local new_block = {
						text = curString,
						font = blk.font,
						colour = blk.colour,
						thisY = thisY,
						thisX = x1,
						offset = { x = xOffset, y = yOffset }
					}
					Table:Add(new_block_list, new_block)
					if (xOffset + x1 > xMax) then xMax = xOffset + x1 end
				end

				curString = ''
				local xOldSize = xSize
				xSize = 0
				local xOldOffset = xOffset
				xOffset = ceil((xOffset + xOldSize) / 50) * 50

				if (xOffset == xOldOffset) then
					xOffset = xOffset + 50
					if (maxwidth and xOffset > maxwidth) then
						-- Needs a new line
						if (thisY == 0) then
							thisY = lineHeight
							thisMaxY = lineHeight
						else
							lineHeight = thisY
						end

						xOffset = 0
						yOffset = yOffset + thisMaxY
						thisY = 0
						thisMaxY = 0
					end
				end
			else
				local x, y = textSize(ch)
				if (x == nil) then return end
				if (maxwidth and maxwidth > x) then
					if (xOffset + xSize + x >= maxwidth) then
						-- need to: find the previous space in the curString
						--      if we can't find one, take off the last character and Table:Add as a new block, incrementing the y etc
						local lastSpacePos = len(curString)
						for k = 1, len(curString) do
							local chspace = sub(curString, k, k)
							if (chspace == ' ') then
								lastSpacePos = k
							end
						end

						local previous_block = new_block_list[#new_block_list]
						local wrap = lastSpacePos == len(curString) && lastSpacePos > 0

						if (previous_block and previous_block.text:match(' $') and wrap and textSize(blk.text) < maxwidth) then
							-- If the block was preceded by a space, wrap the block onto the next line first, as we can probably fit it there
							local trimmed, trimCharNum = previous_block.text:gsub(' +$', '')
							if (trimCharNum > 0) then
								previous_block.text = trimmed
								previous_block.thisX = textSize(previous_block.text)
							end
						else
							if wrap then
								-- If the block takes up multiple lines (and has no spaces), split it up
								local sequenceStartPos = offset(curString, 0, lastSpacePos)
								ch = match(curString, utf8.charpattern, sequenceStartPos) .. ch
								j = offset(curString, 1, sequenceStartPos)
								curString = sub(curString, 1, sequenceStartPos - 1)
							else
								-- Otherwise, strip the trailing space and start a new line
								ch = sub(curString, lastSpacePos + 1) .. ch
								j = lastSpacePos + 1
								curString = sub(curString, 1, max(lastSpacePos - 1, 0))
							end

							local m = 1
							while (sub(ch, m, m) == ' ') do
								m = m + 1
							end
							ch = sub(ch, m)

							local x1, y1 = textSize(curString)
							if (y1 > thisMaxY) then
								thisMaxY = y1
								ymaxes[yOffset] = thisMaxY
								lineHeight = y1
							end

							local new_block = {
								text = curString,
								font = blk.font,
								colour = blk.colour,
								thisY = thisY,
								thisX = x1,
								offset = { x = xOffset, y = yOffset }
							}
							Table:Add(new_block_list, new_block)

							if (xOffset + x1 > xMax) then xMax = xOffset + x1 end
							curString = ''
						end

						xOffset = 0
						xSize = 0
						x, y = textSize(ch)
						yOffset = yOffset + thisMaxY
						thisY = 0
						thisMaxY = 0
					end
				end

				curString = curString .. ch
				thisY = y
				xSize = xSize + x

				if (y > thisMaxY) then
					thisMaxY = y
					ymaxes[yOffset] = thisMaxY
					lineHeight = y
				end
			end
		end

		if (len(curString) > 0) then
			local x1 = textSize(curString)
			local new_block = {
				text = curString,
				font = blk.font,
				colour = blk.colour,
				thisY = thisY,
				thisX = x1,
				offset = { x = xOffset, y = yOffset }
			}
			Table:Add(new_block_list, new_block)
			lineHeight = thisY

			if (xOffset + x1 > xMax) then xMax = xOffset + x1 end
			xOffset = xOffset + x1
		end
		xSize = 0
	end

	local totalHeight = 0
	for i, blk in ipairs(new_block_list) do
		blk.height = ymaxes[blk.offset.y]

		if (blk.offset.y + blk.height > totalHeight) then
			totalHeight = blk.offset.y + blk.height
		end

		lineWidths[blk.offset.y] = max(lineWidths[blk.offset.y] or 0, blk.offset.x + blk.thisX)
	end

	return setmetatable( {
		totalHeight = totalHeight,
		totalWidth = xMax,
		maxWidth = maxwidth,
		lineWidths = lineWidths,
		blocks = new_block_list
	}, markupIndex)
end


--- Draws markup text on the screen at the specified position with the given formatting options.
-- @param text (string): The markup text to be displayed, which may include formatting tags.
-- @param font (string): The font to be used for rendering the text.
-- @param x (number): The X coordinate for the text's starting position on the screen.
-- @param y (number): The Y coordinate for the text's starting position on the screen.
-- @param color (Color): The color of the text to be displayed.
-- @param xAlign (number): The horizontal alignment of the text (e.g., left, center, right).
-- @param yAlign (number): The vertical alignment of the text (e.g., top, center, bottom).
-- @param maxwidth (number): The maximum width allowed for the text before it wraps.
-- @param textAlign (number): The alignment of the text within its allocated space.
function DanLib.Utils:DrawParseText(text, font, x, y, color, xAlign, yAlign, maxwidth, textAlign)
	x = x or 0
	y = y or 0
	xAlign = xAlign or TEXT_ALIGN_CENTER
	yAlign = yAlign or TEXT_ALIGN_CENTER
	textAlign = textAlign or TEXT_ALIGN_CENTER

    local markupObject = markupIndex:ParseMarkup(text, font, color, maxwidth)
    if markupObject then
        markupObject:Draw(x, y, xAlign, yAlign, nil, textAlign)
    end
end


-- An example of using text markup in a HUD.
local function testTextHUD()
	-- Example of markup text
	-- local text = 'This is a long line of text that should wrap if it exceeds the maximum width.'
	local text = 'This is a long {font: danlib_font_16}{color: 0, 255, 0}line of text that should{/color:}{/font:} wrap if it exceeds the maximum width.'

	-- Call the function to display the text with the maximum width value
	DanLib.Utils:DrawParseText(text, nil, ScrW() - 10, 100, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 0)
end
-- hook.Add('HUDPaint', '', testTextHUD)