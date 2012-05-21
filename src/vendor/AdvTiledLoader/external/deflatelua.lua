-- dmlib.deflate
-- deflate (and gunzip) implemented in Lua.
--
-- Note: only supports decompression.
-- Compression not implemented.
--
-- References
-- [1] DEFLATE Compressed Data Format Specification version 1.3
--     http://tools.ietf.org/html/rfc1951
-- [2] GZIP file format specification version 4.3
--     http://tools.ietf.org/html/rfc1952
-- [3] http://en.wikipedia.org/wiki/DEFLATE
-- [4] pyflate, by Paul Sladen
--     http://www.paul.sladen.org/projects/pyflate/
-- [5] Compress::Zlib::Perl - partial pure Perl implementation of
--     Compress::Zlib
--     http://search.cpan.org/~nwclark/Compress-Zlib-Perl/Perl.pm
--
-- (c) 2008 David Manura.  Licensed under the same terms as Lua (MIT).

local assert = assert
local error = error
local ipairs = ipairs
local pairs = pairs
local print = print
local require = require
local tostring = tostring
local type = type
local setmetatable = setmetatable
local io = io
local math = math
local table_sort = table.sort
local math_max = math.max
local string_char = string.char
local io_open = io.open
local _G = _G

local crc32 = require( TILED_LOADER_PATH .. "external.crc32lua" ) . crc32_byte

local DEBUG = false

--[[NATIVE_BITOPS
local band = bit.band
local lshift = bit.lshift
local rshift = bit.rshift
--]]

local M = {}


local function warn(s)
  io.stderr:write(s, '\n')
end


local function debug(...)
  print('DEBUG', ...)
end


local function runtime_error(s, level)
  level = level or 1
  error({s}, level+1)
end


local function make_outstate(outbs)
  local outstate = {}
  outstate.outbs = outbs
  outstate.window = {}
  outstate.window_pos = 1
  return outstate
end


local function output(outstate, byte)
  -- debug('OUTPUT:', s)
  local window_pos = outstate.window_pos
  outstate.outbs(byte)
  outstate.window[window_pos] = byte
  outstate.window_pos = window_pos % 32768 + 1  -- 32K
end


local function noeof(val)
  return assert(val, 'unexpected end of file')
end


local function hasbit(bits, bit)
  return bits % (bit + bit) >= bit
end


local function memoize(f)
  local mt = {}
  local t = setmetatable({}, mt)
  function mt:__index(k)
    local v = f(k)
    t[k] = v
    return v
  end
  return t
end


-- small optimization (lookup table for powers of 2)
local pow2 = memoize(function(n) return 2^n end)

--local tbits = memoize(
--  function(bits)
--    return memoize( function(bit) return getbit(bits, bit) end )
--  end )


-- weak metatable marking objects as bitstream type
local is_bitstream = setmetatable({}, {__mode='k'})


-- DEBUG
-- prints LSB first
local function bits_tostring(bits, nbits)
  local s = ''
  local tmp = bits
  local function f()
    local b = tmp % 2 == 1 and 1 or 0
    s = s .. b
    tmp = (tmp - b) / 2
  end
  if nbits then
    for i=1,nbits do f() end
  else
    while tmp ~= 0 do f() end
  end

  return s
end


local function bytestream_from_file(fh)
  local o = {}
  function o:read()
    local sb = fh:read(1)
    if sb then return sb:byte() end
  end
  return o
end


local function bytestream_from_string(s)
  local i = 1
  local o = {}
  function o:read()
    local by
    if i <= #s then
      by = s:byte(i)
      i = i + 1
    end
    return by
  end
  return o
end


local function bytestream_from_function(f)
  local i = 0
  local buffer = ''
  local o = {}
  function o:read()
    i = i + 1
    if i > #buffer then
      buffer = f()
      if not buffer then return end
      i = 1
    end
    return buffer:byte(i,i)
  end
  return o
end


local left
local function bitstream_from_bytestream(bys)
  local buf_byte = 0
  local buf_nbit = 0
  local o = {}

  function o:nbits_left_in_byte()
    return buf_nbit
  end

  function o:read(nbits)
    nbits = nbits or 1
    while buf_nbit < nbits do
      local byte = bys:read()
      if not byte then return end  -- note: more calls also return nil
      buf_byte = buf_byte + pow2[buf_nbit] * byte
      buf_nbit = buf_nbit + 8
    end
    local m = pow2[nbits]
    local bits = buf_byte % m
    buf_byte = (buf_byte - bits) / m
    buf_nbit = buf_nbit - nbits
    return bits
  end
  --[[NATIVE_BITOPS
  function o:read(nbits)
    nbits = nbits or 1
    while buf_nbit < nbits do
      local byte = bys:read()
      if not byte then return end  -- note: more calls also return nil
      buf_byte = buf_byte + lshift(byte, buf_nbit)
      buf_nbit = buf_nbit + 8
    end
    local bits
    if nbits == 0 then
      bits = 0
    elseif nbits == 32 then
      bits = buf_byte
      buf_byte = 0
    else
      bits = band(buf_byte, rshift(0xffffffff, 32 - nbits))
      buf_byte = rshift(buf_byte, nbits)
    end
    buf_nbit = buf_nbit - nbits
    return bits
  end
  --]]
  
  is_bitstream[o] = true

  return o
end


local function get_bitstream(o)
  local bs
  if is_bitstream[o] then
    return o
  elseif io.type(o) == 'file' then
    bs = bitstream_from_bytestream(bytestream_from_file(o))
  elseif type(o) == 'string' then
    bs = bitstream_from_bytestream(bytestream_from_string(o))
  elseif type(o) == 'function' then
    bs = bitstream_from_bytestream(bytestream_from_function(o))
  else
    runtime_error 'unrecognized type'
  end
  return bs
end


local function get_obytestream(o)
  local bs
  if io.type(o) == 'file' then
    bs = function(sbyte) o:write(string_char(sbyte)) end
  elseif type(o) == 'function' then
    bs = o
  else
    runtime_error('unrecognized type: ' .. tostring(o))
  end
  return bs
end


local function HuffmanTable(init, is_full)
  local t = {}
  if is_full then
    for val,nbits in pairs(init) do
      if nbits ~= 0 then
        t[#t+1] = {val=val, nbits=nbits}
        --debug('*',val,nbits)
      end
    end
  else
    for i=1,#init-2,2 do
      local firstval, nbits, nextval = init[i], init[i+1], init[i+2]
      --debug(val, nextval, nbits)
      if nbits ~= 0 then
        for val=firstval,nextval-1 do
          t[#t+1] = {val=val, nbits=nbits}
        end
      end
    end
  end
  table_sort(t, function(a,b)
    return a.nbits == b.nbits and a.val < b.val or a.nbits < b.nbits
  end)

  -- assign codes
  local code = 1  -- leading 1 marker
  local nbits = 0
  for i,s in ipairs(t) do
    if s.nbits ~= nbits then
      code = code * pow2[s.nbits - nbits]
      nbits = s.nbits
    end
    s.code = code
    --debug('huffman code:', i, s.nbits, s.val, code, bits_tostring(code))
    code = code + 1
  end

  local minbits = math.huge
  local look = {}
  for i,s in ipairs(t) do
    minbits = math.min(minbits, s.nbits)
    look[s.code] = s.val
  end

  --for _,o in ipairs(t) do
  --  debug(':', o.nbits, o.val)
  --end

  -- function t:lookup(bits) return look[bits] end

  local function msb(bits, nbits)
    local res = 0
    for i=1,nbits do
      local b = bits % 2
      bits = (bits - b) / 2
      res = res * 2 + b
    end
    return res
  end
  --[[NATIVE_BITOPS
  local function msb(bits, nbits)
    local res = 0
    for i=1,nbits do
      res = lshift(res, 1) + band(bits, 1)
      bits = rshift(bits, 1)
    end
    return res
  end
  --]]
  
  local tfirstcode = memoize(
    function(bits) return pow2[minbits] + msb(bits, minbits) end)

  function t:read(bs)
    local code = 1 -- leading 1 marker
    local nbits = 0
    while 1 do
      if nbits == 0 then  -- small optimization (optional)
        code = tfirstcode[noeof(bs:read(minbits))]
        nbits = nbits + minbits
      else
        local b = noeof(bs:read())
        nbits = nbits + 1
        code = code * 2 + b   -- MSB first
        --[[NATIVE_BITOPS
        code = lshift(code, 1) + b   -- MSB first
        --]]
      end
      --debug('code?', code, bits_tostring(code))
      local val = look[code]
      if val then
        --debug('FOUND', val)
        return val
      end
    end
  end

  return t
end


local function parse_gzip_header(bs)
  -- local FLG_FTEXT = 2^0
  local FLG_FHCRC = 2^1
  local FLG_FEXTRA = 2^2
  local FLG_FNAME = 2^3
  local FLG_FCOMMENT = 2^4

  local id1 = bs:read(8)
  local id2 = bs:read(8)
  if id1 ~= 31 or id2 ~= 139 then
    runtime_error 'not in gzip format'
  end
  local cm = bs:read(8)  -- compression method
  local flg = bs:read(8) -- FLaGs
  local mtime = bs:read(32) -- Modification TIME
  local xfl = bs:read(8) -- eXtra FLags
  local os = bs:read(8) -- Operating System

  if DEBUG then
    debug("CM=", cm)
    debug("FLG=", flg)
    debug("MTIME=", mtime)
    -- debug("MTIME_str=",os.date("%Y-%m-%d %H:%M:%S",mtime)) -- non-portable
    debug("XFL=", xfl)
    debug("OS=", os)
  end

  if not os then runtime_error 'invalid header' end

  if hasbit(flg, FLG_FEXTRA) then
    local xlen = bs:read(16)
    local extra = 0
    for i=1,xlen do
      extra = bs:read(8)
    end
    if not extra then runtime_error 'invalid header' end
  end

  local function parse_zstring(bs)
    repeat
      local by = bs:read(8)
      if not by then runtime_error 'invalid header' end
    until by == 0
  end

  if hasbit(flg, FLG_FNAME) then
    parse_zstring(bs)
  end

  if hasbit(flg, FLG_FCOMMENT) then
    parse_zstring(bs)
  end

  if hasbit(flg, FLG_FHCRC) then
    local crc16 = bs:read(16)
    if not crc16 then runtime_error 'invalid header' end
    -- IMPROVE: check CRC.  where is an example .gz file that
    -- has this set?
    if DEBUG then
      debug("CRC16=", crc16)
    end
  end
end

local function parse_zlib_header(bs)
  local cm = bs:read(4) -- Compression Method
  local cinfo = bs:read(4) -- Compression info
  local fcheck = bs:read(5) -- FLaGs: FCHECK (check bits for CMF and FLG)
  local fdict = bs:read(1) -- FLaGs: FDICT (present dictionary)
  local flevel = bs:read(2) -- FLaGs: FLEVEL (compression level)
  local cmf = cinfo * 16  + cm -- CMF (Compresion Method and flags)
  local flg = fcheck + fdict * 32 + flevel * 64 -- FLaGs
  
  if cm ~= 8 then -- not "deflate"
    runtime_error("unrecognized zlib compression method: " + cm)
  end
  local window_size
  if cinfo > 7 then
    runtime_error("invalid zlib window size: cinfo=" + cinfo)
  end
  local window_size = 2^(cinfo + 8)
  
  if (cmf*256 + flg) %  31 ~= 0 then
    runtime_error("invalid zlib header (bad fcheck sum)")
  end
  
  if fdict == 1 then
    runtime_error("FIX:TODO - FDICT not currently implemented")
    local dictid = bs:read(32)
  end
  
  return window_size
end

local function parse_huffmantables(bs)
    local hlit = bs:read(5)  -- # of literal/length codes - 257
    local hdist = bs:read(5) -- # of distance codes - 1
    local hclen = noeof(bs:read(4)) -- # of code length codes - 4

    local ncodelen_codes = hclen + 4
    local codelen_init = {}
    local codelen_vals = {
      16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15}
    for i=1,ncodelen_codes do
      local nbits = bs:read(3)
      local val = codelen_vals[i]
      codelen_init[val] = nbits
    end
    local codelentable = HuffmanTable(codelen_init, true)

    local function decode(ncodes)
      local init = {}
      local nbits
      local val = 0
      while val < ncodes do
        local codelen = codelentable:read(bs)
        --FIX:check nil?
        local nrepeat
        if codelen <= 15 then
          nrepeat = 1
          nbits = codelen
          --debug('w', nbits)
        elseif codelen == 16 then
          nrepeat = 3 + noeof(bs:read(2))
          -- nbits unchanged
        elseif codelen == 17 then
          nrepeat = 3 + noeof(bs:read(3))
          nbits = 0
        elseif codelen == 18 then
          nrepeat = 11 + noeof(bs:read(7))
          nbits = 0
        else
          error 'ASSERT'
        end
        for i=1,nrepeat do
          init[val] = nbits
          val = val + 1
        end
      end
      local huffmantable = HuffmanTable(init, true)
      return huffmantable
    end

    local nlit_codes = hlit + 257
    local ndist_codes = hdist + 1

    local littable = decode(nlit_codes)
    local disttable = decode(ndist_codes)

    return littable, disttable
end


local tdecode_len_base
local tdecode_len_nextrabits
local tdecode_dist_base
local tdecode_dist_nextrabits
local function parse_compressed_item(bs, outstate, littable, disttable)
  local val = littable:read(bs)
  --debug(val, val < 256 and string_char(val))
  if val < 256 then -- literal
    output(outstate, val)
  elseif val == 256 then -- end of block
    return true
  else
    if not tdecode_len_base then
      local t = {[257]=3}
      local skip = 1
      for i=258,285,4 do
        for j=i,i+3 do t[j] = t[j-1] + skip end
        if i ~= 258 then skip = skip * 2 end
      end
      t[285] = 258
      tdecode_len_base = t
      --for i=257,285 do debug('T1',i,t[i]) end
    end
    if not tdecode_len_nextrabits then
      local t = {}
      for i=257,285 do
        local j = math_max(i - 261, 0)
        t[i] = (j - (j % 4)) / 4
        --[[NATIVE_BITOPS
        t[i] = rshift(j, 2)
        --]]
      end
      t[285] = 0
      tdecode_len_nextrabits = t
      --for i=257,285 do debug('T2',i,t[i]) end
    end
    local len_base = tdecode_len_base[val]
    local nextrabits = tdecode_len_nextrabits[val]
    local extrabits = bs:read(nextrabits)
    local len = len_base + extrabits

    if not tdecode_dist_base then
      local t = {[0]=1}
      local skip = 1
      for i=1,29,2 do
        for j=i,i+1 do t[j] = t[j-1] + skip end
        if i ~= 1 then skip = skip * 2 end
      end
      tdecode_dist_base = t
      --for i=0,29 do debug('T3',i,t[i]) end
    end
    if not tdecode_dist_nextrabits then
      local t = {}
      for i=0,29 do
        local j = math_max(i - 2, 0)
        t[i] = (j - (j % 2)) / 2
        --[[NATIVE_BITOPS
        t[i] = rshift(j, 1)
        --]]
      end
      tdecode_dist_nextrabits = t
      --for i=0,29 do debug('T4',i,t[i]) end
    end
    local dist_val = disttable:read(bs)
    local dist_base = tdecode_dist_base[dist_val]
    local dist_nextrabits = tdecode_dist_nextrabits[dist_val]
    local dist_extrabits = bs:read(dist_nextrabits)
    local dist = dist_base + dist_extrabits

    --debug('BACK', len, dist)
    for i=1,len do
      local pos = (outstate.window_pos - 1 - dist) % 32768 + 1  -- 32K
      output(outstate, assert(outstate.window[pos], 'invalid distance'))
    end
  end
  return false
end


local function parse_block(bs, outstate)
  local bfinal = bs:read(1)
  local btype = bs:read(2)

  local BTYPE_NO_COMPRESSION = 0
  local BTYPE_FIXED_HUFFMAN = 1
  local BTYPE_DYNAMIC_HUFFMAN = 2
  local BTYPE_RESERVED = 3

  if DEBUG then
    debug('bfinal=', bfinal)
    debug('btype=', btype)
  end

  if btype == BTYPE_NO_COMPRESSION then
    bs:read(bs:nbits_left_in_byte())
    local len = bs:read(16)
    local nlen = noeof(bs:read(16))

    for i=1,len do
      local by = noeof(bs:read(8))
      output(outstate, by)
    end
  elseif btype == BTYPE_FIXED_HUFFMAN or btype == BTYPE_DYNAMIC_HUFFMAN then
    local littable, disttable
    if btype == BTYPE_DYNAMIC_HUFFMAN then
      littable, disttable = parse_huffmantables(bs)
    else
      littable  = HuffmanTable {0,8, 144,9, 256,7, 280,8, 288,nil}
      disttable = HuffmanTable {0,5, 32,nil}
    end

    repeat
      local is_done = parse_compressed_item(
        bs, outstate, littable, disttable)
    until is_done
  else
    runtime_error 'unrecognized compression type'
  end

  return bfinal ~= 0
end


local function deflate(t)
  local bs = get_bitstream(t.input)
  local outbs = get_obytestream(t.output)
  local outstate = make_outstate(outbs)

  repeat
    local is_final = parse_block(bs, outstate)
  until is_final
end
M.deflate = deflate

-- http://tools.ietf.org/html/rfc1952
local function gunzip(t)
  local bs = get_bitstream(t.input)
  local outbs = get_obytestream(t.output)
  local disable_crc = t.disable_crc
  if disable_crc == nil then disable_crc = false end

  parse_gzip_header(bs)

  local data_crc32 = 0

  deflate{input=bs, output=
    disable_crc and outbs or
      function(byte)
        data_crc32 = crc32(byte, data_crc32)
        outbs(byte)
      end
  }

  bs:read(bs:nbits_left_in_byte())

  local expected_crc32 = bs:read(32)
  local isize = bs:read(32) -- ignored
  if DEBUG then
    debug('crc32=', expected_crc32)
    debug('isize=', isize)
  end
  if not disable_crc and data_crc32 then
    if data_crc32 ~= expected_crc32 then
      runtime_error('invalid compressed data--crc error')
    end    
  end
  if bs:read() then
    warn 'trailing garbage ignored'
  end
end
M.gunzip = gunzip

-- adler32 checksum
-- see ADLER32 in http://tools.ietf.org/html/rfc1950 .
local function adler32(byte, crc)
  local s1 = crc % 65536
  local s2 = (crc - s1) / 65536
  s1 = (s1 + byte) % 65521
  s2 = (s2 + s1) % 65521
  return s2*65536 + s1
end -- 65521 is the largest prime smaller than 2^16

-- http://tools.ietf.org/html/rfc1950
local function inflate_zlib(t)
  local bs = get_bitstream(t.input)
  local outbs = get_obytestream(t.output)
  local disable_crc = t.disable_crc
  if disable_crc == nil then disable_crc = false end
  
  local window_size = parse_zlib_header(bs)
  
  local data_adler32 = 1
  
  deflate{input=bs, output=
    disable_crc and outbs or
      function(byte)
        data_adler32 = adler32(byte, data_adler32)
        outbs(byte)
      end
  }

  bs:read(bs:nbits_left_in_byte())
  
  local b3 = bs:read(8)
  local b2 = bs:read(8)
  local b1 = bs:read(8)
  local b0 = bs:read(8)
  local expected_adler32 = ((b3*256 + b2)*256 + b1)*256 + b0
  if DEBUG then
    debug('alder32=', expected_adler32)
  end
  if not disable_crc then
    if data_adler32 ~= expected_adler32 then
      runtime_error('invalid compressed data--crc error')
    end    
  end
  if bs:read() then
    warn 'trailing garbage ignored'
  end
end
M.inflate_zlib = inflate_zlib

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
