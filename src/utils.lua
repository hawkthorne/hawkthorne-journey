-- Global Utility Functions

------------------------------------------------------------
--   MATH UTILITIES
------------------------------------------------------------

-- given a value, it maps from the in range to the out range
-- useful for mapping variables to color or alpha values
function map( x, in_min, in_max, out_min, out_max)
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
end

-- Averages an arbitrary number of angles (in radians).
function math.averageAngles(...)
    local x,y = 0,0
    for i=1,select('#',...) do local a= select(i,...) x, y = x+math.cos(a), y+math.sin(a) end
    return math.atan2(y, x)
end

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(x2-x1, y2-y1) end

-- Returns the closest multiple of 'size' (defaulting to 10).
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end

-- Clamps a number to within a certain range.
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end

-- Linear interpolation between two numbers.
function lerp(a,b,t) return a+(b-a)*t end

-- Cosine interpolation between two numbers.
function cerp(a,b,t) local f=(1-math.cos(t*math.pi))*.5 return a*(1-f)+b*f end

-- Normalize two numbers.
function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end

-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end

-- Randomly returns either -1 or 1.
function math.rsign() return math.random(2) == 2 and 1 or -1 end

-- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end

-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
    local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
    local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
    local det,x,y = a1*b2 - a2*b1
    if det==0 then return false, "The lines are parallel." end
    x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
    if seg1 or seg2 then
        local min,max = math.min, math.max
        if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
           seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
            return false, "The lines don't intersect."
        end
    end
    return x,y
end

------------------------------------------------------------
--   STRING UTILITIES
------------------------------------------------------------

-- splits a string on a pattern, returns a table
function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

-- joins a table of strings using a delimeter
function join(_tbl,_delim)
    _delim = _delim or ''
    local _str = ''
    for n,v in pairs(_tbl) do
        _str = _str .. v
        if n ~= #_tbl then
            _str = _str .. _delim
        end
    end
    return _str
end

------------------------------------------------------------
--   TABLE UTILITIES
------------------------------------------------------------
local inspector = require('vendor/inspect')

-- pretty print objects
function inspect(obj,n)
    print(inspector(obj,n))
end

-- deepcopies an object
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- reverse sorts a table
function table.reverse_sort(t)
    table.sort(t, function(a,b) return a > b end)
end

-- returns true if the table contains a specific value
function table.contains(t, value)
    for k,v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

-- returns the index of a value in a table or nil if it doesn't exist
function table.indexof(t, value)
    for k,v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function table.shuffle( t, n )
    -- http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm
    if n == nil then n = 1 end
    for i = 1, #t, 1 do
        j = math.random( #t )
        _temp = t[i]
        t[i] = t[j]
        t[j] = _temp
    end
    n = n - 1
    if n > 0 then
        return table.shuffle( t, n )
    end
    return t
end

function table.propcount( t )
    local count = 0
    for _,_ in pairs(t) do
        count = count + 1
    end
    return count
end

------------------------------------------------------------
--   DRAWING UTILITIES
------------------------------------------------------------

-- drawing function to make a rounded rectangle
function roundedrectangle( x, y, w, h, r )
    -- love.graphics.arc( mode, x, y, radius, angle1, angle2 )
    local q = math.pi / 2
    if w < 2 * r then r = w / 2 end
    if h < 2 * r then r = h / 2 end
    drawArc( x+r, y+r, r, q, q*2 )
    love.graphics.line( x+r, y, x+w-r, y )
    drawArc( x+w-r, y+r, r, 0, q )
    love.graphics.line( x+w, y+r, x+w, y+h-r )
    drawArc( x+w-r, y+h-r, r, q*3, q*4 )
    love.graphics.line( x+r, y+h, x+w-r, y+h )
    drawArc( x+r, y+h-r, r, q*2, q*3 )
    love.graphics.line( x, y+r, x, y+h-r )
end

-- drawing function to make an arc
function drawArc( x, y, r, angle1, angle2 )
  local i = angle1
  local j = 0
  local step = ( math.pi * 2 ) / 15
    
  while i < angle2 do
    j = angle2 - i < step and angle2 or i + step
    love.graphics.line(x + (math.cos(i) * r), y - (math.sin(i) * r), x + (math.cos(j) * r), y - (math.sin(j) * r))
    i = j
  end
end
