-----------------------------------------------------------------------
-- inventory.lua
-- Manages the players currently held objects
-- Created by HazardousPeach
-----------------------------------------------------------------------

Inventory = {}

local items = {}
local visible = true
local image = love.graphics.newImage('images/openingmenu.png')
image:setFilter('nearest', 'nearest')

---
-- Draws the inventory to the screen
-- @param position the coordinates to draw at
-- @return nil
function Inventory.draw(position)
    if not visible then
        return
    end
    love.graphics.draw(image, position.x, position.y)
end

return Inventory