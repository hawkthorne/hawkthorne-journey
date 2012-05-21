---------------------------------------------------------------------------------------------------
-- -= Base64 =-
---------------------------------------------------------------------------------------------------

-- Make some functions easier to write
local floor = math.floor
local sub = string.sub
local gsub = string.gsub
local rem = table.remove

-- Our base64 value table
local base64 = { ['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['I']=8,
				['J']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,
				['R']=17,['S']=18,['T']=19,['U']=20,['V']=21,['W']=22,['X']=23,['Y']=24,
				['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['g']=32,
				['h']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,
				['p']=41,['q']=42,['r']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,
				['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,
				['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['+']=62,['/']=63,['=']=nil}

-- Decimal values for binary digits
local bin ={}
local mult = 1
for i = 1,40 do
	bin[i] = mult
	mult = mult*2
end

-- A buffer we will use to process the bits
local buffer = 0
local pos = 0
local function clearBuffer()
	buffer = 0
	pos = 1
end

-- Shift all of the bits up in the buffer and put the base64 number on the bottom
local function pushBase64(n)
	if base64[n] == nil then return end
	buffer = buffer * bin[7] + base64[n]
	pos = pos + 6
end

-- Get an int out of the buffer. This is tricky. The byte order is in little endian so we're going
-- to have to isolate and cut the bytes out and then move them around.
local function getInt()
	-- If our buffer isn't filled all the way then fill it with zeros
	while pos < 33 do 
		buffer = buffer * bin[2] 
		pos = pos + 1
	end
	-- Move the buffer position to just below the integer.
	pos = pos - 32
	
	-- Swap the first and forth byte and then the second and third.
	local tmp = floor((buffer%bin[33+pos-1])/bin[25+pos-1]) +
				floor((buffer%bin[25+pos-1])/bin[17+pos-1])*bin[9] +
				floor((buffer%bin[17+pos-1])/bin[9+pos-1])*bin[17] + 
				floor((buffer%bin[9+pos-1])/bin[pos])*bin[25]
	
	-- We've got our integer so let's cut that portion out of the buffer
	buffer = buffer % bin[pos]
	-- Return the int
	return  tmp
end

-- Get a byte out of the buffer
local function getByte()
	-- If our buffer isn't filled all the way then fill it with zeros
	while pos < 9 do
		buffer = buffer * bin[2] 
		pos = pos + 1
	end
	-- Move the buffer position to just below the byte.
	pos = pos - 8
	-- Cut out the byte
	local tmp = floor((buffer%bin[9+pos-1])/bin[pos])
	-- Delete the byte from the buffer
	buffer = buffer % bin[pos]
	-- Return the byte
	return tmp
end

-- Glues together an integer from four bytes. Little endian
local function glueInt(b1, b2, b3, b4)
	return b1%bin[9] + b2%bin[9]*bin[9] + b3%bin[9]*bin[17] + b4%bin[9]*bin[25]
end

-- A Lua set that will filter out characters that aren't in the base64 table
local set = "[^%a%d%+%/%=]"

-- Decodes a base64 string into the given type
local function decode(mode, raw)

	-- Make sure the mode is supported
	assert(mode=="string" or mode=="int" or mode=="byte", "Base64 decode - Invalid mode: " .. mode)

	-- Clear the buffer
	clearBuffer()
	
	-- Filters undefined characters out of the string
	raw = gsub(raw, set, "")
	
	local size = 0			-- Size of the returned type in bits
	local val = {} 			-- A table containing the data to be returned
	local raw_pos = 1		-- The position of the progress through the raw base64 string
	local raw_size = #raw	-- The size of the base64 string
	local char = ""			-- The current base64 character to be processed
	
	-- If we're expected to return an int then the bit size is 32, otherwise it's 8
	if mode == "int" then size = 32 else size = 8 end
	
	-- While we still have input
	while raw_pos <= raw_size do
		-- Fill the buffer until we have enough bits
		while pos <= size and raw_pos <= raw_size do
			char = sub(raw,raw_pos,raw_pos)
			pushBase64( char )
			raw_pos = raw_pos + 1
		end
		-- If a nil character is encountered the end the loop
		if char == "=" then break end
		-- Get data from the buffer depending on the type
		if mode == "string" then val[#val+1] = string.char( getByte() ) end
		if mode == "byte" then val[#val+1] = getByte() end
		if mode == "int" then val[#val+1] = getInt() end
	end
	
	if mode == "string" then return table.concat(val) end
	return val
end

-- Returns the functions
return {decode = decode, glueInt = glueInt, base64 = base64}


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