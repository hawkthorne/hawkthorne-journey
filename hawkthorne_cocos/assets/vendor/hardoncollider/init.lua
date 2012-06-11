--[[
Copyright (c) 2011 Matthias Richter

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
THE SOFTWARE.
]]--

local _NAME = (...)
if not (common and common.class and common.instance) then
	class_commons = true
	require(_NAME .. '.class')
end
local Shapes      = require(_NAME .. '.shapes')
local Spatialhash = require(_NAME .. '.spatialhash')

local newPolygonShape = Shapes.newPolygonShape
local newCircleShape  = Shapes.newCircleShape
local newPointShape   = Shapes.newPointShape

local function __NULL__() end

local HC = {}
function HC:init(cell_size, callback_collide, callback_stop)
	self._active_shapes  = {}
	self._passive_shapes = {}
	self._ghost_shapes   = {}
	self._current_shape_id = 0
	self._shape_ids      = setmetatable({}, {__mode = "k"}) -- reverse lookup
	self.groups          = {}
	self._colliding_last_frame = {}

	self.on_collide = callback_collide or __NULL__
	self.on_stop    = callback_stop    or __NULL__
	self._hash      = common.instance(Spatialhash, cell_size)
end

function HC:clear()
	self._active_shapes  = {}
	self._passive_shapes = {}
	self._ghost_shapes   = {}
	self._current_shape_id = 0
	self._shape_ids      = setmetatable({}, {__mode = "k"}) -- reverse lookup
	self.groups          = {}
	self._colliding_last_frame = {}
	self._hash           = common.instance(Spatialhash, self._hash.cell_size)
	return self
end

function HC:setCallbacks(collide, stop)
	if type(collide) == "table" and not (getmetatable(collide) or {}).__call then
		stop = collide.stop
		collide = collide.collide
	end

	if collide then
		assert(type(collide) == "function" or (getmetatable(collide) or {}).__call,
			"collision callback must be a function or callable table")
		self.on_collide = collide
	end

	if stop then
		assert(type(stop) == "function" or (getmetatable(stop) or {}).__call,
			"stop callback must be a function or callable table")
		self.on_stop = stop
	end

	return self
end

local function new_shape(self, shape)
	local x1,y1,x2,y2 = shape:bbox()

	self._current_shape_id = self._current_shape_id + 1
	self._active_shapes[self._current_shape_id] = shape
	self._shape_ids[shape] = self._current_shape_id
	self._hash:insert(shape, {x=x1,y=y1}, {x=x2,y=y2})
	shape._groups = {}

	local hash = self._hash
	local move, rotate = shape.move, shape.rotate
	function shape:move(...)
		local x1,y1,x2,y2 = self:bbox()
		move(self, ...)
		local x3,y3,x4,y4 = self:bbox()
		hash:update(self, {x=x1,y=y1}, {x=x2,y=y2}, {x=x3,y=y3}, {x=x4,y=y4})
	end

	function shape:rotate(...)
		local x1,y1,x2,y2 = self:bbox()
		rotate(self, ...)
		local x3,y3,x4,y4 = self:bbox()
		hash:update(self, {x=x1,y=y1}, {x=x2,y=y2}, {x=x3,y=y3}, {x=x4,y=y4})
	end

	function shape:neighbors()
		local x1,y1, x2,y2 = self:bbox()
		return pairs(hash:getNeighbors(self, {x=x1,y=y1}, {x=x2,y=y2}))
	end

	function shape:_removeFromHash()
		local x1,y1, x2,y2 = self:bbox()
		hash:remove(shape, {x=x1,y=y1}, {x=x2,y=y2})
	end

	return shape
end

function HC:activeShapes()
	local next, t, k, v = next, self._active_shapes
	return function()
		k, v = next(t, k)
		return v
	end
end

function HC:addPolygon(...)
	return new_shape(self, newPolygonShape(...))
end

function HC:addRectangle(x,y,w,h)
	return self:addPolygon(x,y, x+w,y, x+w,y+h, x,y+h)
end

function HC:addCircle(cx, cy, radius)
	return new_shape(self, newCircleShape(cx,cy, radius))
end

function HC:addPoint(x,y)
	return new_shape(self, newPointShape(x,y))
end

function HC:share_group(shape, other)
	for name,group in pairs(shape._groups) do
		if group[other] then return true end
	end
	return false
end

-- get unique indentifier for an unordered pair of shapes, i.e.:
-- collision_id(s,t) = collision_id(t,s)
local function collision_id(self,s,t)
	local i,k = self._shape_ids[s], self._shape_ids[t]
	if i < k then i,k = k,i end
	return string.format("%d,%d", i,k)
end

-- check for collisions
function HC:update(dt)
	-- collect colliding shapes
	local tested, colliding = {}, {}
	for shape in self:activeShapes() do
		for other in shape:neighbors() do
			local id = collision_id(self, shape,other)
			if not tested[id] then
				if not (self._ghost_shapes[other] or self:share_group(shape, other)) then
					local collide, sx,sy = shape:collidesWith(other)
					if collide then
						colliding[id] = {shape, other, sx, sy}
					end
					tested[id] = true
				end
			end
		end
	end

	-- call colliding callbacks on colliding shapes
	for id,info in pairs(colliding) do
		self._colliding_last_frame[id] = nil
		self.on_collide( dt, unpack(info) )
	end

	-- call stop callback on shapes that do not collide anymore
	for _,info in pairs(self._colliding_last_frame) do
		self.on_stop( dt, unpack(info) )
	end

	self._colliding_last_frame = colliding
end

-- get list of shapes at point (x,y)
function HC:shapesAt(x, y)
	local shapes = {}
	for s in pairs(self._hash:cell{x=x,y=y}) do
		if s:contains(x,y) then
			shapes[#shapes+1] = s
		end
	end
	return shapes
end

-- remove shape from internal tables and the hash
function HC:remove(shape, ...)
	if not shape then return end
	local id = self._shape_ids[shape]
	if id then
		self._active_shapes[id] = nil
		self._passive_shapes[id] = nil
	end
	self._ghost_shapes[shape] = nil
	self._shape_ids[shape] = nil
	shape:_removeFromHash()

	return self:remove(...)
end

-- group support
function HC:addToGroup(group, shape, ...)
	if not shape then return end
	assert(self._shape_ids[shape], "Shape not registered!")

	if not self.groups[group] then self.groups[group] = {} end
	self.groups[group][shape] = true
	shape._groups[group] = self.groups[group]
	return self:addToGroup(group, ...)
end

function HC:removeFromGroup(group, shape, ...)
	if not shape or not self.groups[group] then return end
	assert(self._shape_ids[shape], "Shape not registered!")

	self.groups[group][shape] = nil
	shape._groups[group] = nil
	return self:removeFromGroup(group, ...)
end

function HC:setPassive(shape, ...)
	if not shape then return end
	assert(self._shape_ids[shape], "Shape not registered!")

	local id = self._shape_ids[shape]
	if not id or self._ghost_shapes[shape] then return end

	self._active_shapes[id] = nil
	self._passive_shapes[id] = shape

	return self:setPassive(...)
end

function HC:setActive(shape, ...)
	if not shape then return end
	assert(self._shape_ids[shape], "Shape not registered!")

	local id = self._shape_ids[shape]
	if not id or self._ghost_shapes[shape] then return end

	self._active_shapes[id] = shape
	self._passive_shapes[id] = nil

	return self:setActive(...)
end

function HC:setGhost(shape, ...)
	if not shape then return end
	local id = self._shape_ids[shape]
	assert(id, "Shape not registered!")

	self._active_shapes[id] = nil
	-- dont remove from passive shapes, see below
	self._ghost_shapes[shape] = shape
	return self:setGhost(...)
end

function HC:setSolid(shape, ...)
	if not shape then return end
	local id = self._shape_ids[shape]
	assert(id, "Shape not registered!")

	-- re-register shape. passive shapes were not unregistered above, so if a shape
	-- is not passive, it must be registered as active again.
	if not self._passive_shapes[id] then
		self._active_shapes[id] = shape
	end
	self._ghost_shapes[shape] = nil
	return self:setSolid(...)
end

-- the module
HC = common.class("HardonCollider", HC)
local function new(...)
	return common.instance(HC, ...)
end

return setmetatable({HardonCollider = HC, new = new},
	{__call = function(_,...) return new(...) end})
