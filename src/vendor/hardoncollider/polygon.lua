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

local _PACKAGE = (...):match("^(.+)%.[^%.]+")
if not (common and common.class and common.instance) then
	class_commons = true
	require(_PACKAGE .. '.class')
end
local vector = require(_PACKAGE .. '.vector-light')

----------------------------
-- Private helper functions
--
-- create vertex list of coordinate pairs
local function toVertexList(vertices, x,y, ...)
	if not (x and y) then return vertices end -- no more arguments

	vertices[#vertices + 1] = {x = x, y = y}   -- set vertex
	return toVertexList(vertices, ...)         -- recurse
end

-- returns true if three vertices lie on a line
local function areCollinear(p, q, r, eps)
	return math.abs(vector.det(q.x-p.x, q.y-p.y,  r.x-p.x,r.y-p.y)) <= (eps or 1e-32)
end
-- remove vertices that lie on a line
local function removeCollinear(vertices)
	local ret = {}
	local i,k = #vertices - 1, #vertices
	for l=1,#vertices do
		if not areCollinear(vertices[i], vertices[k], vertices[l]) then
			ret[#ret+1] = vertices[k]
		end
		i,k = k,l
	end
	return ret
end

-- get index of rightmost vertex (for testing orientation)
local function getIndexOfleftmost(vertices)
	local idx = 1
	for i = 2,#vertices do
		if vertices[i].x < vertices[idx].x then
			idx = i
		end
	end
	return idx
end

-- returns true if three points make a counter clockwise turn
local function ccw(p, q, r)
	return vector.det(q.x-p.x, q.y-p.y,  r.x-p.x, r.y-p.y) >= 0
end

-- test wether a and b lie on the same side of the line c->d
local function onSameSide(a,b, c,d)
	local px, py = d.x-c.x, d.y-c.y
	local l = vector.det(px,py,  a.x-c.x, a.y-c.y)
	local m = vector.det(px,py,  b.x-c.x, b.y-c.y)
	return l*m >= 0
end

local function pointInTriangle(p, a,b,c)
	return onSameSide(p,a, b,c) and onSameSide(p,b, a,c) and onSameSide(p,c, a,b)
end

-- returns starting/ending indices of shared edge, i.e. if p and q share the
-- edge with indices p1,p2 of p and q1,q2 of q, the return value is p1,q2
local function getSharedEdge(p,q)
	local pindex = setmetatable({}, {__index = function(t,k)
		local s = {}
		t[k] = s
		return s
	end})

	-- record indices of vertices in p by their coordinates
	for i = 1,#p do
		pindex[p[i].x][p[i].y] = i
	end

	-- iterate over all edges in q. if both endpoints of that
	-- edge are in p as well, return the indices of the starting
	-- vertex
	local i,k = #q,1
	for k = 1,#q do
		local v,w = q[i], q[k]
		if pindex[v.x][v.y] and pindex[w.x][w.y] then
			return pindex[w.x][w.y], k
		end
		i = k
	end
end

-----------------
-- Polygon class
--
local Polygon = {}
function Polygon:init(...)
	local vertices = removeCollinear( toVertexList({}, ...) )
	assert(#vertices >= 3, "Need at least 3 non collinear points to build polygon (got "..#vertices..")")

	-- assert polygon is oriented counter clockwise
	local r = getIndexOfleftmost(vertices)
	local q = r > 1 and r - 1 or #vertices
	local s = r < #vertices and r + 1 or 1
	if not ccw(vertices[q], vertices[r], vertices[s]) then -- reverse order if polygon is not ccw
		local tmp = {}
		for i=#vertices,1,-1 do
			tmp[#tmp + 1] = vertices[i]
		end
		vertices = tmp
	end
	self.vertices = vertices
	-- make vertices immutable
	setmetatable(self.vertices, {__newindex = function() error("Thou shall not change a polygon's vertices!") end})

	-- compute polygon area and centroid
	local p,q = vertices[#vertices], vertices[1]
	local det = vector.det(p.x,p.y, q.x,q.y) -- also used below
	self.area = det
	for i = 2,#vertices do
		p,q = q,vertices[i]
		self.area = self.area + vector.det(p.x,p.y, q.x,q.y)
	end
	self.area = self.area / 2

	p,q = vertices[#vertices], vertices[1]
	self.centroid = {x = (p.x+q.x)*det, y = (p.y+q.y)*det}
	for i = 2,#vertices do
		p,q = q,vertices[i]
		det = vector.det(p.x,p.y, q.x,q.y)
		self.centroid.x = self.centroid.x + (p.x+q.x) * det
		self.centroid.y = self.centroid.y + (p.y+q.y) * det
	end
	self.centroid.x = self.centroid.x / (6 * self.area)
	self.centroid.y = self.centroid.y / (6 * self.area)

	-- get outcircle
	self._radius = 0
	for i = 1,#vertices do
		self._radius = math.max(self._radius,
			vector.dist(vertices[i].x,vertices[i].y, self.centroid.x,self.centroid.y))
	end
end
local newPolygon


-- return vertices as x1,y1,x2,y2, ..., xn,yn
function Polygon:unpack()
	local v = {}
	for i = 1,#self.vertices do
		v[2*i-1] = self.vertices[i].x
		v[2*i]   = self.vertices[i].y
	end
	return unpack(v)
end

-- deep copy of the polygon
function Polygon:clone()
	return Polygon( self:unpack() )
end

-- get bounding box
function Polygon:getBBox()
	local ulx,uly = self.vertices[1].x, self.vertices[1].y
	local lrx,lry = ulx,uly
	for i=2,#self.vertices do
		local p = self.vertices[i]
		if ulx > p.x then ulx = p.x end
		if uly > p.y then uly = p.y end

		if lrx < p.x then lrx = p.x end
		if lry < p.y then lry = p.y end
	end

	return ulx,uly, lrx,lry
end

-- a polygon is convex if all edges are oriented ccw
function Polygon:isConvex()
	local function isConvex()
		local v = self.vertices
		if #v == 3 then return true end

		if not ccw(v[#v], v[1], v[2]) then
			return false
		end
		for i = 2,#v-1 do
			if not ccw(v[i-1], v[i], v[i+1]) then
				return false
			end
		end
		if not ccw(v[#v-1], v[#v], v[1]) then
			return false
		end
		return true
	end

	-- replace function so that this will only be computed once
	local status = isConvex()
	self.isConvex = function() return status end
	return status
end

function Polygon:move(dx, dy)
	if not dy then
		dx, dy = dx:unpack()
	end
	for i,v in ipairs(self.vertices) do
		v.x = v.x + dx
		v.y = v.y + dy
	end
	self.centroid.x = self.centroid.x + dx
	self.centroid.y = self.centroid.y + dy
end

function Polygon:rotate(angle, cx, cy)
	if not (cx and cy) then
		cx,cy = self.centroid.x, self.centroid.y
	end
	for i,v in ipairs(self.vertices) do
		-- v = (v - center):rotate(angle) + center
		v.x,v.y = vector.add(cx,cy, vector.rotate(angle, v.x-cx, v.y-cy))
	end
	local v = self.centroid
	v.x,v.y = vector.add(cx,cy, vector.rotate(angle, v.x-cx, v.y-cy))
end

function Polygon:scale(s, cx,cy)
	if not (cx and cy) then
		cx,cy = self.centroid.x, self.centroid.y
	end
	for i,v in ipairs(self.vertices) do
		-- v = (v - center) * s + center
		v.x,v.y = vector.add(cx,cy, vector.mul(s, v.x-cx, v.y-cy))
	end
	self._radius = self._radius * s
end

-- triangulation by the method of kong
function Polygon:triangulate()
	if #self.vertices == 3 then return {self:clone()} end
	local triangles = {} -- list of triangles to be returned
	local concave = {}   -- list of concave edges
	local adj = {}       -- vertex adjacencies
	local vertices = self.vertices

	-- retrieve adjacencies as the rest will be easier to implement
	for i,p in ipairs(vertices) do
		local l = (i == 1) and vertices[#vertices] or vertices[i-1]
		local r = (i == #vertices) and vertices[1] or vertices[i+1]
		adj[p] = {p = p, l = l, r = r} -- point, left and right neighbor
		-- test if vertex is a concave edge
		if not ccw(l,p,r) then concave[p] = p end
	end

	-- and ear is an edge of the polygon that contains no other
	-- vertex of the polygon
	local function isEar(p1,p2,p3)
		if not ccw(p1,p2,p3) then return false end
		for q,_ in pairs(concave) do
			if q ~= p1 and q ~= p2 and q ~= p3 and pointInTriangle(q, p1,p2,p3) then
				return false
			end
		end
		return true
	end

	-- main loop
	local nPoints, skipped = #vertices, 0
	local p = adj[ vertices[2] ]
	while nPoints > 3 do
		if not concave[p.p] and isEar(p.l, p.p, p.r) then
			-- polygon may be a 'collinear triangle', i.e.
			-- all three points are on a line. In that case
			-- the polygon constructor throws an error.
			if not areCollinear(p.l, p.p, p.r) then
				triangles[#triangles+1] = newPolygon(p.l.x,p.l.y, p.p.x,p.p.y, p.r.x,p.r.y)
				skipped = 0
			end

			if concave[p.l] and ccw(adj[p.l].l, p.l, p.r) then
				concave[p.l] = nil
			end
			if concave[p.r] and ccw(p.l, p.r, adj[p.r].r) then
				concave[p.r] = nil
			end
			-- remove point from list
			adj[p.p] = nil
			adj[p.l].r = p.r
			adj[p.r].l = p.l
			nPoints = nPoints - 1
			skipped = 0
			p = adj[p.l]
		else
			p = adj[p.r]
			skipped = skipped + 1
			assert(skipped <= nPoints, "Cannot triangulate polygon (is the polygon intersecting itself?)")
		end
	end

	if not areCollinear(p.l, p.p, p.r) then
		triangles[#triangles+1] = newPolygon(p.l.x,p.l.y, p.p.x,p.p.y, p.r.x,p.r.y)
	end

	return triangles
end

-- return merged polygon if possible or nil otherwise
function Polygon:mergedWith(other)
	local p,q = getSharedEdge(self.vertices, other.vertices)
	assert(p and q, "Polygons do not share an edge")

	local ret = {}
	for i = 1,p-1 do
		ret[#ret+1] = self.vertices[i].x
		ret[#ret+1] = self.vertices[i].y
	end

	for i = 0,#other.vertices-2 do
		i = ((i-1 + q) % #other.vertices) + 1
		ret[#ret+1] = other.vertices[i].x
		ret[#ret+1] = other.vertices[i].y
	end

	for i = p+1,#self.vertices do
		ret[#ret+1] = self.vertices[i].x
		ret[#ret+1] = self.vertices[i].y
	end

	return newPolygon(unpack(ret))
end

-- split polygon into convex polygons.
-- note that this won't be the optimal split in most cases, as
-- finding the optimal split is a really hard problem.
-- the method is to first triangulate and then greedily merge
-- the triangles.
function Polygon:splitConvex()
	-- edge case: polygon is a triangle or already convex
	if #self.vertices <= 3 or self:isConvex() then return {self:clone()} end

	local convex = self:triangulate()
	local i = 1
	repeat
		local p = convex[i]
		local k = i + 1
		while k <= #convex do
			local success, merged = pcall(function() return p:mergedWith(convex[k]) end)
			if success and merged:isConvex() then
				convex[i] = merged
				p = convex[i]
				table.remove(convex, k)
			else
				k = k + 1
			end
		end
		i = i + 1
	until i >= #convex
	
	return convex
end

function Polygon:contains(x,y)
	-- test if an edge cuts the ray
	local function cut_ray(p,q)
		return ((p.y > y and q.y < y) or (p.y < y and q.y > y)) -- possible cut
			and (x - p.x < (y - p.y) * (q.x - p.x) / (q.y - p.y)) -- x < cut.x
	end

	-- test if the ray crosses boundary from interior to exterior.
	-- this is needed due to edge cases, when the ray passes through
	-- polygon corners
	local function cross_boundary(p,q)
		return (p.y == y and p.x > x and q.y < y)
			or (q.y == y and q.x > x and p.y < y)
	end

	local v = self.vertices
	local in_polygon = false
	local p,q = v[#v],v[#v]
	for i = 1, #v do
		p,q = q,v[i]
		if cut_ray(p,q) or cross_boundary(p,q) then
			in_polygon = not in_polygon
		end
	end
	return in_polygon
end

function Polygon:intersectsRay(x,y, dx,dy)
	--local p = vector(x,y)
	--local v = vector(dx,dy)
	local nx,ny = vector.perpendicular(dx,dy)
	local wx,xy,det

	local tmin = math.huge
	local q1,q2 = nil, self.vertices[#self.vertices]
	for i = 1, #self.vertices do
		q1,q2 = q2,self.vertices[i]
		wx,wy = q2.x - q1.x, q2.y - q1.y
		det = vector.det(dx,dy, wx,wy)

		if det ~= 0 then
			-- there is an intersection point. check if it lies on both
			-- the ray and the segment.
			local rx,ry = q2.x - x, q2.y - y
			local l = vector.det(rx,ry, wx,wy) / det
			local m = vector.det(dx,dy, rx,ry) / det
			if l >= 0 and m >= 0 and m <= 1 then
				-- we cannot jump out early here (i.e. when l > tmin) because
				-- the polygon might be concave
				tmin = math.min(tmin, l)
			end
		else
			-- lines parralel or incident. get distance of line to
			-- anchor point. if they are incident, check if an endpoint
			-- lies on the ray
			local dist = vector.dot(q1.x-x,q1.y-y, nx,ny)
			if dist == 0 then
				local l = vector.dot(dx,dy, q1.x-x,q1.y-y)
				local m = vector.dot(dx,dy, q2.x-x,q2.y-y)
				if l >= 0 and l >= m then
					tmin = math.min(tmin, l)
				elseif m >= 0 then
					tmin = math.min(tmin, m)
				end
			end
		end
	end
	return tmin ~= math.huge, tmin
end

Polygon = common.class('Polygon', Polygon)
newPolygon = function(...) return common.instance(Polygon, ...) end
return Polygon
