-- dmlib.bit
-- Bitwise operations implemented entirely in Lua.
-- Represents bit arrays as non-negative Lua numbers.[1]
-- Can represent 32-bit bit arrays, when Lua is compiled
-- with lua_Number being double-precision IEEE 754 floating point.
--
-- Based partly on Roberto Ierusalimschy's post
-- in http://lua-users.org/lists/lua-l/2002-09/msg00134.html .
--
-- References
--
--   [1] http://lua-users.org/wiki/FloatingPoint
--
-- (c) 2008 David Manura.  Licensed under the same terms as Lua (MIT).


local function memoize(f)
  local mt = {}
  local t = setmetatable({}, mt)
  function mt:__index(k)
    local v = f(k); t[k] = v
    return v
  end
  return t
end

local function make_bitop_uncached(t, m)
  local function bitop(a, b)
    local res,p = 0,1
    while a ~= 0 and b ~= 0 do
      local am, bm = a%m, b%m
      res = res + t[am][bm]*p
      a = (a - am) / m
      b = (b - bm) / m
      p = p*m
    end
    res = res + (a+b)*p
    return res
  end
  return bitop
end

local function make_bitop(t)
  local op1 = make_bitop_uncached(t,2^1)
  local op2 = memoize(function(a)
    return memoize(function(b)
      return op1(a, b)
    end)
  end)
  return make_bitop_uncached(op2, 2^(t.n or 1))
end

local bxor = make_bitop {[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0}, n=4}
local F8 = 2^32 - 1
local function bnot(a)   return F8 - a end
local function band(a,b) return ((a+b) - bxor(a,b))/2 end
local function bor(a,b)  return F8 - band(F8 - a, F8 - b) end

local M = {}
M.bxor = bxor
M.bnot = bnot
M.band = band
M.bor = bor

return M

--[[
LICENSE

Copyright (C) 2008, David Manura.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

(end license)
--]]
