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

local floor = math.floor
local min, max = math.min, math.max

local _PACKAGE = (...):match("^(.+)%.[^%.]+")
if not (common and common.class and common.instance) then
	class_commons = true
	require(_PACKAGE .. '.class')
end

-- transparent cell accessor methods
-- cells = {[0] = {[0] = <>, [1] = <>, ... }, [1] = {...}, ...}
local cells_meta = {}
function cells_meta.__newindex(tbl, key, val)
	local cell = rawget(tbl, key.x)
	if not cell then
		rawset(tbl, key.x, {[key.y] = val})
	else
		rawset(cell, key.y, val)
	end
end

function cells_meta.__index(tbl, key)
	local cell = rawget(tbl, key.x)
	if not cell then
		local ret = setmetatable({}, {__mode = "kv"})
		cell = {[key.y] = ret}
		rawset(tbl, key.x, cell)
		return ret
	end

	local ret = rawget(cell, key.y)
	if not ret then
		ret = setmetatable({}, {__mode = "kv"})
		rawset(cell, key.y, ret)
	end
	return ret
end

local Spatialhash = {}
function Spatialhash:init(cell_size)
	self.cell_size = cell_size or 100
	self.cells = setmetatable({}, cells_meta)
end

function Spatialhash:cellCoords(v)
	return {x=floor(v.x / self.cell_size), y=floor(v.y / self.cell_size)}
end

function Spatialhash:cell(v)
	return self.cells[ self:cellCoords(v) ]
end

function Spatialhash:insert(obj, ul, lr)
	local ul = self:cellCoords(ul)
	local lr = self:cellCoords(lr)
	for i = ul.x,lr.x do
		for k = ul.y,lr.y do
			rawset(self.cells[{x=i,y=k}], obj, obj)
		end
	end
end

function Spatialhash:remove(obj, ul, lr)
	-- no bbox given. => must check all cells
	if not ul or not lr then
		for _,cell in pairs(self.cells) do
			rawset(cell, obj, nil)
		end
		return
	end

	local ul = self:cellCoords(ul)
	local lr = self:cellCoords(lr)
	-- else: remove only from bbox
	for i = ul.x,lr.x do
		for k = ul.y,lr.y do
			rawset(self.cells[{x=i,y=k}], obj, nil)
		end
	end
end

-- update an objects position
function Spatialhash:update(obj, ul_old, lr_old, ul_new, lr_new)
	local ul_old, lr_old = self:cellCoords(ul_old), self:cellCoords(lr_old)
	local ul_new, lr_new = self:cellCoords(ul_new), self:cellCoords(lr_new)

	if ul_old.x == ul_new.x and ul_old.y == ul_new.y and
	   lr_old.x == lr_new.x and lr_old.y == lr_new.y then
		return
	end

	for i = ul_old.x,lr_old.x do
		for k = ul_old.y,lr_old.y do
			rawset(self.cells[{x=i,y=k}], obj, nil)
		end
	end
	for i = ul_new.x,lr_new.x do
		for k = ul_new.y,lr_new.y do
			rawset(self.cells[{x=i,y=k}], obj, obj)
		end
	end
end

function Spatialhash:getNeighbors(obj, ul, lr)
	local ul = self:cellCoords(ul)
	local lr = self:cellCoords(lr)
	local set = {}
	for i = ul.x,lr.x do
		for k = ul.y,lr.y do
			local cell = self.cells[{x=i,y=k}] or {}
			for other,_ in pairs(cell) do
				rawset(set, other, other)
			end
		end
	end
	rawset(set, obj, nil)
	return set
end

function Spatialhash:draw(how, show_empty, print_key)
	if show_empty == nil then show_empty = true end
	for k1,v in pairs(self.cells) do
		for k2,cell in pairs(v) do
			local empty = true
			(function() for _ in pairs(cell) do empty = false; return end end)()
			if show_empty or not empty then
				local x = k1 * self.cell_size
				local y = k2 * self.cell_size
				love.graphics.rectangle(how or 'line', x,y, self.cell_size, self.cell_size)

				if print_key then
					love.graphics.print(("%d:%d"):format(k1,k2), x+3,y+3)
				end
			end
		end
	end
end

return common.class('Spatialhash', Spatialhash)
