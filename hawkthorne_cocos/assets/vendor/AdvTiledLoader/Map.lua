---------------------------------------------------------------------------------------------------
-- -= Map =-
---------------------------------------------------------------------------------------------------

-- Import the other classes
TILED_LOADER_PATH = TILED_LOADER_PATH or ({...})[1]:gsub("[%.\\/][Mm]ap$", "") .. '.'
local Tile = require( TILED_LOADER_PATH .. "Tile")
local TileSet = require( TILED_LOADER_PATH .. "TileSet")
local TileLayer = require( TILED_LOADER_PATH .. "TileLayer")
local Object = require( TILED_LOADER_PATH .. "Object")
local ObjectLayer = require( TILED_LOADER_PATH .. "ObjectLayer")


-- Localize some functions so they are faster
local pairs = pairs
local ipairs = ipairs 
local assert = assert
local love = love
local table = table
local ceil = math.ceil
local floor = math.floor

-- Make our map class
local Map = {}
Map.__index = Map

-- Returns a new map
function Map:new(name, width, height, tileWidth, tileHeight, orientation, properties)

	-- Our map
	local map = {}
	
	-- Public:
	map.name = name or "Unnamed Nap"				-- Name of the map
	map.width = width or 0							-- Width of the map in tiles
	map.height = height or 0						-- Height of the map in tiles
	map.tileWidth = tileWidth or 0					-- Width in pixels of each tile
	map.tileHeight = tileHeight or 0				-- Height in pixels of each tile
	map.orientation = orientation or "orthogonal"	-- Type of map. "orthogonal" or "isometric"
	map.properties = properties or {}				-- Properties of the map set by Tiled
	map.useSpriteBatch = false						-- If true then tile layers are rendered with sprite batches.
	
	map.offsetX = 0					-- X offset the map
	map.offsetY = 0					-- Y offset of the map
	
	map.tileLayers = {}				-- Tile layers indexed by name
	map.objectLayers = {}			-- Object layers indexed by name
	map.tilesets = {}				-- Tilesets indexed by name
	map.tiles = {}					-- Tiles indexed by id
	
	map.tl = map.tileLayers			-- A shortcut to tileLayers
	map.ol = map.objectLayers		-- A shortcut to objectLayers
	
	map.drawList = {}				-- Draws the items in order from 1 to n.				
	map.drawRange = {}				-- Limits the drawing of tiles and objects. [1]:x [2]:y [3]:width [4]:height
	map.drawObjects = true			-- If true then object layers will be drawn
	
	-- Private:
	map._widestTile = 0				-- The widest tile on the map.
	map._highestTile = 0			-- The tallest tile on the map.
	map._tileRange = {}				-- The range of drawn tiles. [1]:x [2]:y [3]:width [4]:height
	map._previousTileRange = {}		-- The previous _tileRange. If this changed then we redraw sprite batches.
	map._specialRedraw = true		-- If true then the map needs to redraw sprite batches.
	map._forceSpecialRedraw = false	-- If true then the next special redraw is forced
	map._previousUseSpriteBatch = false   -- The previous _useSpiteBatch. If this changed then we redraw sprite batches.
	map._tileClipboard	=	nil		-- The value that stored for TileLayer:tileCopy() and TileLayer:tilePaste()
	
	-- Return the new map
	return setmetatable(map, Map)
end

-- Creates a new tileset and adds it to the map. The map will then auto-update its tiles.
function Map:newTileSet(img, name, tilew, tileh, width, height, firstgid, space, marg, tprop)
	assert(name, "Map:newTileSet - The name parameter is invalid")
	self.tilesets[name] = TileSet:new(img, name, tilew, tileh, width, height, firstgid, space, marg, tprop)
	self:updateTiles()
	return self.tilesets[name]
end

-- Creates a new TileLayer and adds it to the map. The last parameter is the place in the draw order
-- If draw isn't specified, it will be created as the highest drawable.
function Map:newTileLayer(name, opacity, prop, draw)
	assert(name, "Map:newTileLayer - The name parameter is invalid")
	self.tl[name] = TileLayer:new(self, name, opacity, prop)
	table.insert(self.drawList, draw or #self.drawList + 1, self.tl[name])
	return self.tl[name]
end

-- Creates a new ObjectLayer and inserts it into the map
function Map:newObjectLayer(name, color, opacity, prop, draw)
	assert(name, "Map:newObjectLayer - The name parameter is invalid")
	self.ol[name] = ObjectLayer:new(self, name, color, opacity, prop)
	table.insert(self.drawList, draw or #self.drawList + 1, self.tl[name])
	return self.ol[name]
end

-- Cuts tiles out of tilesets and stores them in the tiles tables under their id
-- Call this after the tilesets are set up
function Map:updateTiles()
	self.tiles = {}
	self.widestTile = 0
	self.highestTile = 0
	for _, ts in pairs(self.tilesets) do
		if ts.tileWidth > self.widestTile then self.widestTile = ts.tileWidth end
		if ts.tileHeight > self.highestTile then self.highestTile = ts.tileHeight end
		for id, val in pairs(ts:getTiles()) do
			self.tiles[id] = val
		end
	end
end

-- Forces the map to redraw the sprite batches.
function Map:forceRedraw()
	self._specialRedraw = true
	self._forceSpecialRedraw = true
end

-- Draws each item in drawList. By default, drawList is simply an array of all the layers'
-- draw functions in the order they appear in Tiled. You can manipulate drawList however you like.
-- Items in drawList can either be functions or tables with a draw() function.
function Map:draw()
	
	-- Update the tile range
	self:_updateTileRange()
	
	-- This actually draws the map
	local vtype
	for i,v in ipairs(self.drawList) do
		vtype = type(v)
		if vtype == "table"  then 
			assert(v.draw, "Map:draw() - A table in drawList does not have a draw() function")
			v:draw()
		elseif vtype == "function" then 
			v()
		end
	end

end

-- Returns the draw position of the item contained in drawList.
function Map:drawPosition(item)
	local pos
	for k, v in ipairs(self.drawList) do
		if v == item then pos = k end
	end
	return pos
end

-- Turns an isometric location into a world location. The unit length for isometric tiles is always
-- the map's tileHeight. This is both for width and height.
function Map:fromIso(x, y)
	x, y = x or 0, y or 0
	local h, tw, th = self.height, self.tileWidth, self.tileHeight
	return ((x-y)/th + h - 1)*tw/2, (x+y)/2
end

-- Turns a world location into an isometric location
function Map:toIso(a, b)
	a, b = a or 0, b or 0
	local h, tw, th = self.height, self.tileWidth, self.tileHeight
	local x, y
	x = b - (h-1)*th/2 + (a*th)/tw 
	y = 2*b - x
	return x, y
end

-- Sets the draw range
function Map:setDrawRange(x,y,w,h)
	self.drawRange[1], self.drawRange[2], self.drawRange[3], self.drawRange[4] = x, y, w, h
end

-- Gets the draw range
function Map:getDrawRange()
	return self.drawRange[1], self.drawRange[2], self.drawRange[3], self.drawRange[4]
end

-- Automatically sets the draw range to fit the display
function Map:autoDrawRange(tx, ty, scale, pad)
	tx, ty, scale, pad = tx or 0, ty or 0, scale or 1, pad or 0
	if scale > 0.001 then
		self:setDrawRange(-tx-pad,-ty-pad,love.graphics.getWidth()/scale+pad*2,
						  love.graphics.getHeight()/scale+pad*2)
	end
end

-- A short-hand to retreive tiles from a layer's tileData.
function Map:__call(layerName, x, y)
	return self.tileLayers.tileData(x,y)
end

----------------------------------------------------------------------------------------------------
-- Private Functions
----------------------------------------------------------------------------------------------------

-- This is an internal function used to update the map's _tileRange, _previousTileRange, and 
-- _specialRedraw
function Map:_updateTileRange()
	
	-- Offset to make sure we can always draw the highest and widest tile
	local heightOffset = self.highestTile - self.tileHeight
	local widthOffset = self.widestTile - self.tileWidth
	
	-- Set the previous tile range
	for i=1,4 do self._previousTileRange[i] = self._tileRange[i] end
	
	-- Get the draw range. We will replace these values with the tile range.
	local x1, y1, x2, y2 = self.drawRange[1], self.drawRange[2], self.drawRange[3], self.drawRange[4]
	
	-- Calculate the _tileRange for orthogonal tiles
	if self.orientation == "orthogonal" then
	
		-- Limit the drawing range. We must make sure we can draw the tiles that are bigger
		-- than the self's tileWidth and tileHeight.
		if x1 and y1 and x2 and y2 then
			x2 = ceil((x1+x2)/self.tileWidth)
			y2 = ceil((y1+y2+heightOffset)/self.tileHeight)
			x1 = floor((x1-widthOffset)/self.tileWidth)
			y1 = floor(y1/self.tileHeight)
		
			-- Make sure that we stay within the boundry of the map
			x1 = x1 > 0 and x1 or 0
			y1 = y1 > 0 and y1 or 0
			x2 = x2 < self.width-1 and x2 or self.width-1
			y2 = y2 < self.height-1 and y2 or self.height-1
		
		else
			-- If the drawing range isn't defined then we draw all the tiles
			x1, y1, x2, y2 = 1, 1, self.width, self.height
		end
		
	-- Calculate the _tileRange for isometric tiles.
	else
		-- If the drawRange is set
		if x1 and y1 and x2 and y2 then
			x1, y1 = self:toIso(x1-self.widestTile,y1)
			x1, y1 = ceil(x1/self.tileHeight), ceil(y1/self.tileHeight)-1
			x2 = ceil((x2+self.widestTile)/self.tileWidth)
			y2 = ceil((y2+heightOffset)/self.tileHeight)
		-- else draw everything
		else
			x1 = 0
			y1 = 0
			x2 = self.width-1
			y2 = self.height-1
		end
	end
	
	-- Assign the new values to the tile range
	local tr, ptr = self._tileRange, self._previousTileRange
	tr[1], tr[2], tr[3], tr[4] = x1, y1, x2, y2
	
	-- If the tile range or useSpriteBatch is different than the last frame then we need to update sprite batches.
	self._specialRedraw = self.useSpriteBatch ~= self._previousUseSpriteBatch or
						  self._forceSpecialRedraw or
						  tr[1] ~= ptr[1] or 
						  tr[2] ~= ptr[2] or 
						  tr[3] ~= ptr[3] or 
						  tr[4] ~= ptr[4]
						  
	-- Set the previous useSpritebatch
	self._previousUseSpriteBatch = self.useSpriteBatch
						  
	-- Reset the forced special redraw
	self._forceSpecialRedraw = false
end

-- Returns the Map class
return Map


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