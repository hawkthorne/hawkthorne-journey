--[[
Copyright (c) 2012 Matthias Richter

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

local _PACKAGE = (...):match("^(.+)%.[^%.]+")
local vector  = require(_PACKAGE .. '.vector-light')

local function support(shape_a, shape_b, dx, dy)
	local x,y = shape_a:support(dx,dy)
	return vector.sub(x,y, shape_b:support(-dx, -dy))
end

-- returns closest edge to the origin
local function closest_edge(simplex)
	local e = {dist = math.huge}

	local i = #simplex-1
	for k = 1,#simplex-1,2 do
		local ax,ay = simplex[i], simplex[i+1]
		local bx,by = simplex[k], simplex[k+1]
		i = k

		local ex,ey = vector.perpendicular(bx-ax, by-ay)
		local nx,ny = vector.normalize(ex,ey)
		local d = vector.dot(ax,ay, nx,ny)

		if d < e.dist then
			e.dist = d
			e.nx, e.ny = nx, ny
			e.i = k
		end
	end

	return e
end

local function EPA(shape_a, shape_b, simplex)
	-- make sure simplex is oriented counter clockwise
	local cx,cy, bx,by, ax,ay = unpack(simplex)
	if vector.dot(ax-bx,ay-by, cx-bx,cy-by) < 0 then
		simplex[1],simplex[2] = ax,ay
		simplex[5],simplex[6] = cx,cy
	end

	-- the expanding polytype algorithm
	while true do
		local e = closest_edge(simplex)
		local px,py = support(shape_a, shape_b, e.nx, e.ny)
		local d = vector.dot(px,py, e.nx, e.ny)

		if d - e.dist < 1e-6 then
			return -d*e.nx, -d*e.ny
		end

		-- simplex = {..., simplex[e.i-1], px, py, simplex[e.i]
		table.insert(simplex, e.i, py)
		table.insert(simplex, e.i, px)
	end
end

--   :      :     origin must be in plane between A and B
-- B o------o A   since A is the furthest point on the MD
--   :      :     in direction of the origin.
local function do_line(simplex)
	local bx,by, ax,ay = unpack(simplex)
	local abx,aby = bx-ax, by-ay

	local dx,dy = vector.perpendicular(abx,aby)
	if vector.dot(dx,dy, -ax,-ay) < 0 then
		dx,dy = -dx,-dy
	end
	return simplex, dx,dy
end

-- B .'
--  o-._  1
--  |   `-. .'     The origin can only be in regions 1, 3 or 4:
--  |  4   o A 2   A lies on the edge of the MD and we came
--  |  _.-' '.     from left of BC.
--  o-'  3
-- C '.
local function do_triangle(simplex)
	local cx,cy, bx,by, ax,ay = unpack(simplex)
	local aox,aoy = -ax,-ay
	local abx,aby = bx-ax, by-ay
	local acx,acy = cx-ax, cy-ay

	-- test region 1
	local dx,dy = vector.perpendicular(abx,aby)
	if vector.dot(dx,dy, acx,acy) > 0 then
		dx,dy = -dx,-dy
	end
	if vector.dot(dx,dy, aox,aoy) > 0 then
		-- simplex = {bx,by, ax,ay}
		simplex[1], simplex[2] = bx,by
		simplex[3], simplex[4] = ax,ay
		simplex[5], simplex[6] = nil, nil
		return simplex, dx,dy
	end

	-- test region 3
	dx,dy = vector.perpendicular(acx,acy)
	if vector.dot(dx,dy, abx,aby) > 0 then
		dx,dy = -dx,-dy
	end
	if vector.dot(dx,dy, aox, aoy) > 0 then
		-- simplex = {cx,cy, ax,ay}
		simplex[3], simplex[4] = ax,ay
		simplex[5], simplex[6] = nil, nil
		return simplex, dx,dy
	end

	-- must be in region 4
	return simplex
end


local function GJK(shape_a, shape_b)
	local ax,ay = support(shape_a, shape_b, 1,0)
	local simplex = {ax,ay}
	local n = 2
	local dx,dy = -ax,-ay

	-- first iteration: line case
	ax,ay = support(shape_a, shape_b, dx,dy)
	if vector.dot(ax,ay, dx,dy) <= 0 then
		return false
	end
	simplex[n+1], simplex[n+2] = ax,ay
	simplex, dx, dy = do_line(simplex, dx, dy)
	n = 4

	-- all other iterations must be the triangle case
	while true do
		ax,ay = support(shape_a, shape_b, dx,dy)

		if vector.dot(ax,ay, dx,dy) <= 0 then
			return false
		end

		simplex[n+1], simplex[n+2] = ax,ay
		simplex, dx, dy = do_triangle(simplex, dx,dy)
		n = #simplex

		if n == 6 then
			return true, EPA(shape_a, shape_b, simplex)
		end
	end
end

return GJK
