require "vendor/vector"

BSpline = {}
BSpline.__index = BSpline

local function vectors(points)
	local ret = {}
	for i = 1,math.floor(#points/2) do
		ret[i] = vector.new(points[2*i-1], points[2*i])
	end
	return ret
end

function BSpline.new(controlpoints, knots)
	local s = {
		knots = {},
		controlpoints = vectors(controlpoints)
	}
	if type(knots) == "table" then -- copy and check knots
		s.degree = #knots - #s.controlpoints + 1
		if s.degree < 1 then
			error(string.format("Degree (%d) to small. Provide more knots!", s.degree))
		end

		for i,k in ipairs(knots) do
			if i > 1 and s.knots[i-1] > k then
				error(string.format("Knot %d < Knot %d", i, i-1))
			end
			s.knots[i] = k
		end
	else -- provide aequidistant knots, assume <= cubic spline
		s.degree = math.min(#s.controlpoints - 1, 3)
		if s.degree < 1 then
			error(string.format("Degree (%d) to small. Provide more controlpoints!", s.degree))
		end
		s.knots = {}
		for i = 1,s.degree do s.knots[#s.knots+1] = 0 end
		for i = 1,#s.controlpoints-s.degree do s.knots[#s.knots+1] = i end
		for i = 1,s.degree-1 do s.knots[#s.knots+1] = s.knots[#s.knots] end
	end
	setmetatable(s, BSpline)
	return s
end

function BSpline:clone()
	return BSpline.new(self:controlPolygon(), self.knots)
end

function BSpline:translate(x, y)
	local t = vector.new(x,y)
	for i,p in ipairs(self.controlpoints) do
		self.controlpoints[i] = p + t
	end
end

function BSpline:controlPolygon(min, max)
	local min = min or 1
	local max = max or #self.controlpoints

	local ret = {}
	for i=min,max do
		ret[#ret+1] = self.controlpoints[i].x
		ret[#ret+1] = self.controlpoints[i].y
	end
	return ret
end

function BSpline:knotIndex(t)
	for i = 1,#self.knots-1 do
		if self.knots[i] <= t and t < self.knots[i+1] then
			return i
		end
	end

	i = self.degree
	if t < self.knots[i] then return i end

	return #self.knots - self.degree
end

function BSpline:knotMin()
	return self.knots[self.degree]
end

function BSpline:knotMax()
	return self.knots[#self.knots-self.degree+1]
end

function BSpline:eval(t)
	if t < self:knotMin() then t = self:knotMin() end
	if t > self:knotMax() then t = self:knotMax() end

	local points, last = {}
	local alpha
	local i = self:knotIndex(t) - self.degree + 1

	for k = 1,self.degree+1 do
		points[k] = self.controlpoints[i+k-1]
	end

	for k = 1,self.degree do
		last = points
		points = {}
		for j = i,i+self.degree-k do
			alpha = (t - self.knots[j+k-1]) / (self.knots[j+self.degree] - self.knots[j+k-1])
			points[j-i+1] = (1-alpha) * last[j-i+1] + alpha * last[j-i+2]
		end
	end
	return points[1]
end

function BSpline:insertKnot(t)
	-- run one iteration of the de boor algorithm. the new control points are
	-- on the outer edge of the scheme
	local points, last = {}, {}
	local alpha
	local i = self:knotIndex(t) - self.degree + 1

	for k = 1,self.degree+1 do
		last[k] = self.controlpoints[i+k-1]
	end

	for k = 1,i do
		points[#points+1] = self.controlpoints[k]
	end
	-- run one iteration of the de boor algorithm
	for j = i,i+self.degree-1 do
		alpha = (t - self.knots[j]) / (self.knots[j+self.degree] - self.knots[j])
		points[#points+1] = (1-alpha) * last[j-i+1] + alpha * last[j-i+2]
	end

	for k = i+self.degree+1,#self.controlpoints+1 do
		points[#points+1] = self.controlpoints[k-1]
	end
	self.controlpoints = points

	-- insert knot into knot-vector
	local knotcount = #self.knots
	self.knots[knotcount+1] = math.huge
	for i=1,knotcount+1 do
		if self.knots[i] > t then
			t, self.knots[i] = self.knots[i], t
		end
	end
	return self
end

function BSpline:insertKnots(k)
	for _,t in ipairs(k) do
		self:insertKnot(t)
	end
	return self
end

function BSpline:subdivide()
	local toinsert = {}
	for i = self.degree,#self.knots-self.degree do
		toinsert[#toinsert+1] = (self.knots[i] + self.knots[i+1])/2
	end
	self:insertKnots(toinsert)
end

function BSpline:polygon(k)
	local k = k or 4
	local temp = self:clone()
	while k > 0 do
		temp:subdivide()
		k = k - 1
	end
	return temp:controlPolygon()
end

function BSpline:draw(k)
	love.graphics.line(self:polygon(k))
end

function BSpline.interpolate(points)
	local function alpha(i, knots) return (knots[i+2] - knots[i])   / (knots[i+3] - knots[i])   end
	local function beta(i, knots)  return (knots[i+2] - knots[i+1]) / (knots[i+3] - knots[i+1]) end
	local function gamma(i, knots) return (knots[i+2] - knots[i+1]) / (knots[i+4] - knots[i+1]) end
	local points = vectors(points)

	-- interpolate knots
	local m, delta = #points - 1
	local knots = {0,0,0}
	for i=4,m+3 do -- TODO: other knot distance measures
		if i == m+3 then delta = points[m]:len()
		else             delta = (points[i-2] - points[i-3]):len()
		end
		knots[i] = knots[i-1] + math.sqrt(delta/600)
	end
	knots[m+4] = knots[m+3]
	knots[m+5] = knots[m+3]

	-- interpolate controlpoints by cleverly solving a linear system
	-- I almost got this working, but only on paper, hence:
	-- TODO!

	local s = {
		controlpoints = controlpoints,
		knots = knots,
		degree = 3
	}
	setmetatable(s, BSpline)
	return s
end

return BSpline
