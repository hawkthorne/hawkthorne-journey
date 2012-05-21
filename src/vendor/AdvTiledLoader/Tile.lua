---------------------------------------------------------------------------------------------------
-- -= Tile =-
---------------------------------------------------------------------------------------------------

-- Setup
local assert = assert
local Tile = {}
Tile.__index = Tile

-- Creates a new tile and returns it.
function Tile:new(id, tileset, quad, width, height, prop)
	assert( id and tileset and quad, "Tile:new - Needs at least 3 parameters for id, tileset and quad.")
	local tmp = {}
	tmp.id = id						-- The id of the tile
	tmp.tileset = tileset			-- The tileset this tile belongs to
	tmp.quad = quad 				-- The of the tileset that defines the tile
	tmp.width = width or 0			-- The width of the tile in pixels
	tmp.height = height or 0		-- The height of the tile in pixels
	tmp.properties = prop or {}		-- The properties of the tile set in Tiled
	return setmetatable(tmp, Tile)
end

-- Draws the tile at the given location 
function Tile:draw(x, y, rotation, scaleX, scaleY, offsetX, offsetY)
	love.graphics.drawq(self.tileset.image, self.quad, self.tileset.tileoffset.x + x, 
						self.tileset.tileoffset.y + y, rotation, scaleX, scaleY, offsetX, offsetY)
end

-- Return the Tile class
return Tile


--[[Copyright (c) 2011 Casey Baxter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.--]]