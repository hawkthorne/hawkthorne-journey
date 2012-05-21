---------------------------------------------------------------------------------------------------
-- -= Grid =-
---------------------------------------------------------------------------------------------------

local Grid = {}
Grid.__index = Grid 

-- Creates and returns a new grid
function Grid:new()
	local grid = {}
	grid.cells = {}
	grid.cells.mt = {__mode = ""}
	return setmetatable(grid, Grid)
end

-- Weakens the grid's cells so the garbage collecter can delete their contents if they have no
-- other references.
function Grid:weaken()
	self.cells.mt.__mode = "v"
	for key,row in pairs(self.cells) do
		setmetatable(row,self.cells.mt)
	end
end

-- Unweakens the grid
function Grid:unweaken()
	self.cells.mt.__mode = ""
	for key,row in pairs(self.cells) do
		setmetatable(row,self.cells.mt)
	end
end

-- Gets the value of a single cell
function Grid:get(x,y)
	return self.cells[x] and self.cells[x][y] or nil
end

-- Sets the value of a single cell
function Grid:set(x,y,value)
	if not self.cells[x] then 
		self.cells[x] = setmetatable({}, self.cells.mt)
	end
	self.cells[x][y] = value
end

-- Sets all of the cells in an area to the same value
function Grid:setArea(startX, startY, endX, endY, value)
	for x = startX,endX do
		for y = startY,endY do
			self:set(x,y,value)
		end
	end
end

-- Iterate over all values
function Grid:iterate()
	local x, row = next(self.cells)
	local y, val
	return function()
		repeat
			y,val = next(row,y)
			if y == nil then x,row = next(self.cells, x) end
		until (val and x and y and type(x)=="number") or (not val and not x and not y)
		return x,y,val
	end
end

-- Iterate over a rectangle shape
function Grid:rectangle(startX, startY, endX, endY, includeNil)
	local x, y = startX, startY
	return function()
		while y <= endY do
			while x <=endX do
				x = x+1
				if self(x-1,y) ~= nil or includeNil then 
					return x-1, y, self(x-1,y)
				end
			end
			x = startX
			y = y+1
		end
		return nil
	end
end

-- Iterate over a line. Set noDiag to true to keep from traversing diagonally.
function Grid:line(startX, startY, endX, endY, noDiag, includeNil)	
    local dx = math.abs(endX - startX)
    local dy = math.abs(endY - startY)
    local x = startX
    local y = startY
    local incrX = endX > startX and 1 or -1 
    local incrY = endY > startY and 1 or -1 
    local err = dx - dy
	local err2 = err*2
	local i = 1+dx+dy
	local rx,ry,rv 
	local checkX = false
	return function()
		while i>0 do 
			rx,ry,rv = x,y,self(x,y)
			err2 = err*2
			while true do
				checkX = not checkX		
				if checkX == true or not noDiag then 
					if err2 > -dy then
						err = err - dy
						x = x + incrX
						i = i-1
						if noDiag then break end
					end
				end
				if checkX == false or not noDiag then
					if err2 < dx then
						err = err + dx
						y = y + incrY
						i = i-1
						if noDiag then break end
					end
				end
				if not noDiag then break end
			end
			if rx == endX and ry == endY then i = 0 end
			if rv ~= nil or includeNil then return rx,ry,rv end
		end
		return nil
	end
end

-- Iterates over a circle of cells
function Grid:circle(cx, cy, r, includeNil)
	local x,y
	x = x or cx-r
	return function()
		repeat
			y = y == nil and cy or y <= cy and y-1 or y+1
			while ((cx-x)*(cx-x)+(cy-y)*(cy-y)) >= r*r do
				if x > cx+r then return nil end
				x = x + (y < cy and 0 or 1)
				y = cy + (y < cy and 1 or 0)
			end
		until self(x,y) ~= nil or includeNil
		return x,y,self(x,y)
	end
end

-- Cleans the grid of empty rows. 
function Grid:clean()
	for key,row in pairs(self.cells) do
		if not next(row) then self.cells[key] = nil end
	end
end

-- This makes calling the grid as a function act like Grid.get.
Grid.__call = Grid.get

-- Returns the grid class
return Grid

--------------------------------------------------------------------------------------
-- Copyright (c) 2011 Casey Baxter

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- Except as contained in this notice, the name(s) of the above copyright holders
-- shall not be used in advertising or otherwise to promote the sale, use or
-- other dealings in this Software without prior written authorization.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.