---------------------------------------------------------------------------------------------------
-- -= ObjectLayer =-
---------------------------------------------------------------------------------------------------

-- Setup
TILED_LOADER_PATH = TILED_LOADER_PATH or ({...})[1]:gsub("[%.\\/][Oo]bject[Ll]ayer$", "") .. '.'
local love = love
local unpack = unpack
local pairs = pairs
local ipairs = ipairs
local Object = require( TILED_LOADER_PATH .. "Object")
local ObjectLayer = {}
ObjectLayer.__index = ObjectLayer


-- Creates and returns a new ObjectLayer
function ObjectLayer:new(map, name, color, opacity, prop)
	
	-- Create a new table for our object layer and do some error checking.
	local ol = {}
	assert(map, "ObjectLayer:new - Requires a parameter for map")
	
	ol.map = map							-- The map this layer belongs to
	ol.name = name or "Unnamed ObjectLayer"	-- The name of this layer
	ol.color = color or {128,128,128,255}	-- The color theme
	ol.opacity = opacity or 1				-- The opacity
	ol.objects = {}							-- The layer's objects indexed by type
	ol.properties = prop or {}				-- Properties set by Tiled.
	
	-- Return the new object layer
	return setmetatable(ol, ObjectLayer)
end

-- Creates a new object, automatically inserts it into the layer, and then returns it
function ObjectLayer:newObject(name, type, x, y, width, height, gid, prop)
	local obj = Object:new(self, name, type, x, y, width, height, gid, prop)
	self.objects[#self.objects+1] = obj
	return obj
end

-- Sorting function for objects. We'll use this below in ObjectLayer:draw()
local function drawSort(o1, o2) 
	return o1.drawInfo.order < o2.drawInfo.order 
end

-- Draws the object layer. The way the objects are drawn depends on the map orientation and
-- if the object has an associated tile. It tries to draw the objects as closely to the way
-- Tiled does it as possible.
function ObjectLayer:draw()

	-- Exit if objects are not suppose to be drawn
	if not self.map.drawObjects then return end

	local di									-- The draw info
	local rng = self.map.drawRange				-- The drawing range. [1-4] = x,y,width,height
	local drawList = {}							-- A list of the objects to be drawn
	local r,g,b,a = love.graphics.getColor()	-- Save the color so we can set it back at the end
	local line	= love.graphics.getLineWidth()	-- Save the line width too
	self.color[4] = 255 * self.opacity			-- Set the opacity
	
	-- Put only objects that are on the screen in the draw list. If the screen range isn't defined
	-- add all objects
	for k,obj in ipairs(self.objects) do
		di = obj.drawInfo
		if rng[1] and rng[2] and rng[3] and rng[4] then
			if 	di.right > rng[1]-20 and 
				di.bottom > rng[2]-20 and 
				di.left < rng[1]+rng[3]+20 and 
				di.top < rng[2]+rng[4]+20 then 
					drawList[#drawList+1] = obj
			end
		else
			drawList[#drawList+1] = obj
		end
	end
	
	-- Sort the draw list by the object's draw order
	table.sort(drawList, drawSort)

	-- Draw all the objects in the draw list.
	for k,obj in ipairs(drawList) do
		love.graphics.setColor(r,b,g,a)
		obj:draw(di.x, di.y, unpack(self.color or neutralColor))
	end
	
	-- Reset the color and line width
	love.graphics.setColor(r,b,g,a)
	love.graphics.setLineWidth(line)
end

-- Return the ObjectLayer class
return ObjectLayer


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