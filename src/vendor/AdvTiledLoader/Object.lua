---------------------------------------------------------------------------------------------------
-- -= Object =-
---------------------------------------------------------------------------------------------------

-- Setup
local Object = {}
Object.__index = Object

-- Returns a new Object
function Object:new(layer, name, type, x, y, width, height, gid, prop)

	-- Public:
	local obj = {}
	obj.layer = layer			-- The layer that the object belongs to
	obj.name = name or ""		-- Name of the object
	obj.type = type or ""		-- Type of the object
	obj.x = x or 0				-- X location on the map
	obj.y = y  or 0				-- Y location on the map
	obj.width = width or 0		-- Object width in tiles
	obj.height = height or 0	-- Object height in tiles
	obj.gid = gid				-- The object's associated tile. If false an outline will be drawn.
	obj.properties = prop or {} -- Properties set by tiled.
	
	-- drawInfo stores values needed to actually draw the object. You can either set these yourself
	-- or use updateDrawInfo to do it automatically.
	obj.drawInfo = {
	
		-- x and y are the drawing location of the object. This is different than the object's x and
		-- y value which is the object's placement on the map.
		x = 0,		-- The x draw location
		y = 0,		-- The y draw location
		
		-- These limit the drawing of the object. If the object falls out of the bounds of
		-- the map's drawRange then the object will not be drawn. 
		left = 0,   -- The leftmost point on the object
		right = 0,	-- The rightmost point on the object
		top = 0,	-- The highest point on the object
		bottom = 0,	-- The lowest point on the object
		
		-- The order to draw the object in relation to other objects. Usually equal to bottom.
		order = 0,
		
		-- In addition to this, other drawing information can be stored in the numerical 
		-- indicies which is context sensitive to the map's orientation, if the object has a gid, or
		-- of the object is a polygon or polyline object.
	} 
	
	-- Update the draw info
	Object.updateDrawInfo(obj)
	
	-- Return our object
	return setmetatable(obj, Object)
end

-- Updates the draw information. Call this every time the object moves or changes size.
function Object:updateDrawInfo()
	local di = self.drawInfo
	local map = self.layer.map
		
	if self.polygon or self.polyline then
		-- Reset the draw info
		self.drawInfo = {}
		di = self.drawInfo
		-- Set the box to the first vertex
		local vertexes = self.polygon or self.polyline
		-- Create the draw information for each vertex
		for k,v in ipairs(vertexes) do
			if k%2 == 1 then
				if map.orientation == "isometric" then 
					di[k], di[k+1] = map:fromIso(self.x+vertexes[k], self.y+vertexes[k+1])
				else
					di[k], di[k+1] = self.x+vertexes[k], self.y+vertexes[k+1]
				end
			end
		end
		-- Set the start draw location
		di.x, di.y = di[1], di[2]
		-- Prime the bounds
		di.left, di.right, di.top, di.bottom = di.x, di.x, di.y, di.y
		-- Go through each vertex and find the highest and lowest values for the bounds.
		for k,v in ipairs(di) do
			-- if it's odd then it's an x value
			if k%2 == 1 then
				if v < di.left then di.left = v end
				if v > di.right then di.right = v end
			-- if it's even it's a y value
			else
				if v < di.top then di.top = v end
				if v > di.bottom then di.bottom = v end
			end
		end
		di.order = di.bottom
	
	-- Isometric map
	elseif map.orientation == "isometric" then
		-- Is a tile object
		if self.gid then
			local t = map.tiles[self.gid]
			local tw, th = t.width, t.height
			di.x, di.y  = map:fromIso(self.x, self.y)
			di.order = di.y
			di.x, di.y = di.x - map.tileWidth/2, di.y - th
			di.left, di.right, di.top, di.bottom = di.x, di.x+tw, di.y , di.y +th
		-- Is not a tile object
		else
			di[1], di[2] = map:fromIso(self.x, self.y)
			di[3], di[4] = map:fromIso(self.x + self.width, self.y)
			di[5], di[6] = map:fromIso(self.x + self.width, self.y + self.height)
			di[7], di[8] = map:fromIso(self.x, self.y + self.height)
			di.left, di.right, di.top, di.bottom = di[7], di[3], di[2], di[6]
			di.order = 1
		end
		
	-- Orthogonal map
	else
		-- Is a tile object
		if self.gid then
			local t = map.tiles[self.gid]
			local tw, th = t.width, t.height
			di.x, di.y = self.x, self.y
			di.order = di.y
			di.y = di.y - th
			di.left, di.top, di.right, di.bottom = di.x, di.y, di.x+tw, di.y+th
		-- Is not a tile object
		else
			di.x, di.y = self.x, self.y
			di[1], di[2] = self.x, self.y
			di[3], di[4] = self.width > 20 and self.width or 20, self.height > 20 and self.height or 20
			di.left, di.top, di.right, di.bottom = di.x, di.y , di.x+di[3], di.y +di[4]
			di.order = 1
		end
	end
end

-- Moves the object to the relative location
function Object:move(x,y)
	self.x = self.x + x
	self.y = self.y + y
	self:updateDrawInfo()
end

-- Moves the object to the absolute location
function Object:moveTo(x,y)
	self.x = x
	self.y = y
	self:updateDrawInfo()
end

-- Resizes the object
function Object:resize(w,h)
	self.width = w or self.width
	self.height = h or self.height
	self.updateDrawInfo()
end

-- Draw the object. The passed color is the color of the object layer the object belongs to.
function Object:draw(x, y, r, g, b, a)
	
	local di = self.drawInfo
	love.graphics.setLineWidth(2)

	-- The object is a polyline.
	if self.polyline then
		love.graphics.push()
		love.graphics.translate(0,1)
		love.graphics.setColor(0, 0, 0, a)
		love.graphics.line( unpack(di) )
		love.graphics.pop()
		love.graphics.setColor(r, g, b, a)
		love.graphics.line( unpack(di) )
		
	-- The object is a polygon.
	elseif self.polygon then
		love.graphics.push()
		love.graphics.translate(0,1)
		love.graphics.setColor(0, 0, 0, a)
		love.graphics.polygon( "line", unpack(di) )
		love.graphics.pop()
		love.graphics.setColor(r,g,b,a)
		love.graphics.polygon( "line", unpack(di) )	
		
	-- The object is a tile object. Draw the tile.
	elseif self.gid then
		local tile = self.layer.map.tiles[self.gid]
		tile:draw(self.x, self.y - tile.height)
		
	-- Map is isometric. Draw a parallelogram.
	elseif self.layer.map.orientation == "isometric" then
		love.graphics.setColor(r, g, b, a/5)
		love.graphics.polygon("fill", unpack(di))
		
		love.graphics.push()
		love.graphics.translate(0,1)
		love.graphics.setColor(0, 0, 0, a)
		love.graphics.polygon("line", unpack(di))
		love.graphics.pop()
			
		love.graphics.setColor(r,g,b,a)
		love.graphics.polygon("line", unpack(di))

	-- Map is orthogonal. Draw a rectangle.
	else
		love.graphics.setColor(r, g, b, a/5)
		love.graphics.rectangle("fill", unpack(di))
			
		love.graphics.setColor(0, 0, 0, a)
		love.graphics.push()
		love.graphics.translate(1,1)
		love.graphics.rectangle("line", unpack(di))
		love.graphics.print(self.name, di.x, di.y-20)
		love.graphics.pop()
			
		love.graphics.setColor(r,g,b,a)
		love.graphics.rectangle("line", unpack(di))
		love.graphics.print(self.name, di.x, di.y-20)
	end
end

-- Returns the Object class
return Object


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