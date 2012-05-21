---------------------------------------------------------------------------------------------------
-- -= TileSet =-
---------------------------------------------------------------------------------------------------

-- Setup
TILED_LOADER_PATH = TILED_LOADER_PATH or ({...})[1]:gsub("[%.\\/][Tt]ile[Ss]et", "") .. '.'
local ceil = math.ceil
local Tile = require( TILED_LOADER_PATH .. "Tile")
local TileSet = {}
TileSet.__index = TileSet

-- Creates a new tileset.
function TileSet:new(img, name, tilew, tileh, width, height, firstgid, space, marg, tprop, prop)
	assert( img and name and tilew and tileh and width and height and firstgid,
		   "TileSet:new - Needs at least 7 parameters for image, name, " ..
		   "tileWidth, tileHeight, width, height, and firstgid")
	local ts = {}
	
	-- Public:
	ts.image = img 				-- The image of the tileset
	ts.name = name 				-- Name of the tilseset
	ts.tileWidth = tilew 		-- The width of each tile in pixels
	ts.tileHeight = tileh 		-- The height of each tile in pixels
	ts.width = width			-- The width of the tileset image in pixels
	ts.height = height 			-- The height of the tileset image in pixels
	ts.firstgid = firstgid		-- The id of the first tile
	ts.spacing = space or 0		-- The spacing in pixels between each tile
	ts.margin = marg or 0		-- The margin in pixels surrounding the entire tile set.
	ts.tileProperties = tprop or {}	-- Properties of contained tiles indexed by the tile's gid
	ts.properties = prop or {}	-- The properties of the tileset
	
	return setmetatable(ts, TileSet)
end

-- Returns the width in tiles
function TileSet:tilesWide()
	return ceil( (self.width - self.margin*2 - self.spacing) / 
					  (self.tileWidth + self.spacing) )
end

-- Returns the height in tiles
function TileSet:tilesHigh()
	return ceil( (self.height - self.margin*2 - self.spacing) / 
					  (self.tileHeight + self.spacing) )
end

-- Produces tiles from the settings and returns them in a table indexed by their id.
-- These are cut out left-to-right, top-to-bottom.
function TileSet:getTiles()
	local x,y = self.margin, self.margin
	local tiles = {}
	local quad = false
	local id = self.firstgid
	local imageWidth, imageHeight = self.image:getWidth(), self.image:getHeight()

	for i = 1, self:tilesHigh() do
		for j = 1, self:tilesWide() do
			quad = love.graphics.newQuad(x, y, self.tileWidth, self.tileHeight, imageWidth, imageHeight)
			tiles[id] = Tile:new(self.firstgid + i + j - 2, self, quad, 
							   self.tileWidth, self.tileHeight, self.tileProperties[id])
			x = x + self.tileWidth + self.spacing
			id = id + 1
		end
		x = self.margin
		y = y + self.tileHeight + self.spacing
	end
	
	return tiles
end

-- Return the TileSet class
return TileSet


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
