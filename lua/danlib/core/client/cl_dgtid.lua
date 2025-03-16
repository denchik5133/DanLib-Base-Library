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


/***
 *   DanLib.Func.CreateGridPanel
 *   This function creates a grid panel with customizable margins, columns, and maximum height.
 *
 *   @param parent The parent panel to which this grid panel will be attached.
 *   @return A new grid panel with methods for adding cells, calculating row heights, and auto-sizing.
 *   
 *   Attributes:
 *   - horizontalMargin: The horizontal margin between cells.
 *   - verticalMargin: The vertical margin between rows.
 *   - columns: The number of columns in the grid.
 *   - maxHeight: The maximum height of the grid panel.
 */



local base = DanLib.Func
local Table = DanLib.Table

 
function base.CreateGridPanel(parent)
    -- Create a scrollable panel as the base for the grid
    local PANEL = DanLib.CustomUtils.Create(parent, 'DanLib.UI.Scroll')

    -- Define accessors for grid panel attributes
    AccessorFunc(PANEL, 'horizontalMargin', 'HorizontalMargin', FORCE_NUMBER)
    AccessorFunc(PANEL, 'verticalMargin', 'VerticalMargin', FORCE_NUMBER)
    AccessorFunc(PANEL, 'columns', 'Columns', FORCE_NUMBER)
    AccessorFunc(PANEL, 'maxHeight', 'MaxHeight', FORCE_NUMBER)

    -- Set default margins
    PANEL:SetHorizontalMargin(4)
    PANEL:SetVerticalMargin(4)

    -- Initialize rows and cells
    PANEL.Rows = {}
    PANEL.Cells = {}

    -- Method to get the content height
    function PANEL:GetContentHeight()
        local totalHeight = 0
        for _, row in pairs(self.Rows) do
            totalHeight = totalHeight + row:GetTall() + base:Scale(self:GetVerticalMargin())
        end
        return totalHeight
    end

    --- Adds a cell to the grid panel.
    -- @param panel The panel to add as a cell.
    -- @param width The width of the cell (optional).
    -- @param height The height of the cell (optional).
    function PANEL:AddCell(panel, width, height)
        local slots = self:GetColumns()
        local index = math.floor(#self.Cells / slots) + 1
        local margin = self:GetHorizontalMargin()

        -- Create a new row if it doesn't exist
        self.Rows[index] = self.Rows[index] or self:CreateRow()

        -- Set the panel's parent and dock it
        panel:SetParent(self.Rows[index])
        panel:Dock(LEFT)
        panel:DockMargin(0, 0, (#self.Rows[index].Items + 1 < slots) and margin or 0, 0)
        -- panel:SetWide((self:GetWide() - margin * (slots - 1)) / slots)

        -- Set the width of the panel with the scroll bar taken into account
        -- local availableWidth = self:GetWide() - margin * (slots - 1)
        -- if (self:GetTall() < self:GetContentHeight()) then
        --     availableWidth = availableWidth - 16  -- Set the width of the scroll bar
        -- end

        -- if (not width) then
        --     local sub = height and 0 or 2
        --     panel:SetWide(availableWidth / slots)  -- Distribute the width of the panels

        --     -- Update width on layout
        --     panel.PerformLayout = function()
        --         panel:SetWide(availableWidth / slots)
        --     end
        -- end
        if (not width) then
            local sub = height and 0 or 1.4
            panel:SetWide((self:GetWide() - margin * (slots - 1)) / slots - sub)
            panel.PerformLayout = function ()
                panel:SetWide((self:GetWide() - margin * (slots - 1)) / slots - sub)
            end
        end

        -- Store the panel in the row and cells
        Table:Add(self.Rows[index].Items, panel)
        Table:Add(self.Cells, panel)

        -- Calculate the height of the row
        self:CalculateRowHeight(self.Rows[index], height)
    end

    --- Calculates the heights of all rows in the grid panel.
    function PANEL:CalculateRows()
        for _, row in pairs(self.Rows) do
            self:CalculateRowHeight(row)
        end
    end

    --- Automatically sizes the grid panel based on its contents.
    -- @return The total height of the grid panel after sizing.
    function PANEL:AutoSize()
        local totalHeight = 0
        for _, row in pairs(self.Rows) do
            local height = 0
            local bottomMargin = base:Scale(self:GetVerticalMargin())
            
            for _, cell in pairs(row.Items) do
                height = math.max(height, cell:GetTall())
            end
            totalHeight = totalHeight + height + bottomMargin
        end
        totalHeight = math.max(0, totalHeight - base:Scale(self:GetVerticalMargin()))

        -- Respect the maximum height if set
        if (self:GetMaxHeight() and self:GetMaxHeight() ~= 0) then
            totalHeight = math.min(totalHeight, base:Scale(self:GetMaxHeight()))
        end

        self:SetTall(totalHeight)

        -- Adjust parent height if necessary
        if (self:GetParent():GetName() == 'EditablePanel') then
            self:GetParent():SetTall(totalHeight + self:GetTopMargin())
        end
        return totalHeight
    end

    --- Creates a new row for the grid panel.
    -- @return The newly created row panel.
    function PANEL:CreateRow()
        local row = self:Add('EditablePanel')
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, base:Scale(self:GetVerticalMargin()))
        row.Paint = nil
        row.Items = {}
        return row
    end

    --- Calculates the height of a specified row.
    -- @param row The row for which to calculate the height.
    function PANEL:CalculateRowHeight(row)
        local height = 0
        for _, cell in pairs(row.Items) do
            height = math.max(height, cell:GetTall())
        end
        row:SetTall(height)
    end

    --- Skips a cell by adding an empty panel.
    function PANEL:Skip()
        local cell = DanLib.CustomUtils.Create()
        self:AddCell(cell)
    end

    --- Clears all cells and rows from the grid panel.
    function PANEL:Clear()
        for _, row in pairs(self.Rows) do
            for _, cell in pairs(row.Items) do
                cell:Remove()
            end
            row:Remove()
        end
        self.Cells, self.Rows = {}, {}
    end

    -- Ensure cleanup on removal
    PANEL.OnRemove = PANEL.Clear

    return PANEL
end






local function grid()
	local Frame = base.CreateUIFrame()
	Frame:SetSize(400, 400)
	Frame:Center()
	Frame:MakePopup()
	Frame:SetTitle('Grid panel')

	local Grid = base.CreateGridPanel(Frame)
    Grid:Dock(FILL)
    Grid:DockMargin(5, 5, 5, 5)
    Grid:SetColumns(3) -- Set how many columns will be used!
    Grid:SetHorizontalMargin(4)
    Grid:SetVerticalMargin(4)

    for i = 1, 24 do
      	local Panel = DanLib.CustomUtils.Create()
      	Panel:SetTall(50)
      	Panel.Paint = function(self, w, h)
        	DanLib.Utils:DrawRect(0, 0, w, h, base:Theme('secondary_dark'))
        	draw.SimpleText('Panel №'..i, 'danlib_font_18', w * 0.5, h * 0.5, base:Theme('text'), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      	end
      	Grid:AddCell(Panel, nil, true)
    end
end
-- concommand.Add('CreateGridPanel', grid)	