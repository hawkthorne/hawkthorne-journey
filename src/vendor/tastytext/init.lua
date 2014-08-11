--[[
TastyText 2.0 
Copyright (c) 2014 Minh Ngo

This software is provided 'as-is', without any express or implied 
warranty. In no event will the authors be held liable for any damages 
arising from the use of this software. 

Permission is granted to anyone to use this software for any purpose, 
including commercial applications, and to alter it and redistribute it 
freely, subject to the following restrictions: 

1. The origin of this software must not be misrepresented; you must not 
claim that you wrote the original software. If you use this software 
in a product, an acknowledgment in the product documentation would be 
appreciated but is not required. 

2. Altered source versions must be plainly marked as such, and must not 
be misrepresented as being the original software. 

3. This notice may not be removed or altered from any source 
distribution. 
]]

--[[
Chunk objects have the following fields:

chunk = {
	Table/Image/String
	------------------
	x
	y
	width
	length
	line
	
	Table
	-----
	draw
	properties
	parent
	
	String
	------
	string
	
	Font
	----
	font
	
	Color
	-----
	color
	 
	Image
	----- 
	image
}
]]

local _NAME = (...)
require(_NAME .. '.utf8')

-------------------
-- GLOBALS
local START = '{{'
local END   = '}}'
local ESCAPE= '\\'
-------------------

local escape_tag = string.format('%s([%s%s])',ESCAPE,START,END)

------------------------------------------------------------------------
--TEXT CLASS
------------------------------------------------------------------------

local TastyText  = {}
TastyText.__index= TastyText

function TastyText.new(str,x,y,limit,default_font,tags,line_height)
	default_font = default_font or love.graphics.getFont()
	local t = setmetatable({
		x           = x,
		y           = y,
		limit       = limit,
		default_font= default_font,
		line_height = line_height or default_font:getHeight(),
		tags        = tags,
		chunk_array = nil,
		lines       = 0,
		length      = 0,
		first       = 0,
		last        = 0,
		align       = 'left',
		subalign    = 'left',
		line_lengths= nil,
		line_widths = nil,
	},TastyText)
	assert(t.line_height >= default_font:getHeight(), 'Line height must'..
' be greater than or equal to height of default font!')
	
	t.chunk_array = t:_parseString(str)
	t.lines,t.length,t.line_lengths,t.line_widths = t:_getMetaData()
	t.last = t.length
	
	return t
end

function TastyText:setSub(first,last)
	first,last = first or 1,last or self.length
	if first < 0 then
		first = self.length+1+first
	end
	if last < 0 then
		last = self.length+1+last
	end
	self.first,self.last = first,last
end

function TastyText:getCanvas()
	local canvas = love.graphics.newCanvas(self.limit,self.lines*self.line_height)
	canvas:renderTo(function()
		local old_blend = love.graphics.getBlendMode()
		love.graphics.setBlendMode 'premultiplied'
		self:draw()
		love.graphics.setBlendMode(old_blend)
	end)
	return canvas
end

function TastyText:draw()
	love.graphics.push()
	local old_font = love.graphics.getFont()
	love.graphics.setFont(self.default_font)
	local old_r,old_g,old_b,old_a = love.graphics.getColor()
	local position   = 0
	local line_widths= self.line_widths
	local line       = 1
	local x          = 0
	
	if self.subalign ~= 'left' and 
		(self.first > 1 or self.last < self.length) then
		line_widths = self:_getSubLineWidths()
	end
	
	for k = 1,#self.chunk_array do
		local chunk = self.chunk_array[k]
		if chunk.font then
			love.graphics.setFont(chunk.font)
		elseif chunk.color then
			love.graphics.setColor(chunk.color)
		elseif position+chunk.length >= self.first and 
		position <= self.last then
			
			if chunk.line ~= line then
				line = chunk.line
				x    = 0
			end
			
			local ox = self:_getOffset(chunk.line,line_widths[chunk.line])
			local width = chunk.width
			
			if chunk.image then
				love.graphics.draw(chunk.image,x+ox,chunk.y)
			elseif chunk.draw then
				chunk.draw(chunk,x+ox,(line-1)*self.line_height)
			elseif chunk.string then
			
				local str,new_width = self:_getSubString(chunk,
					position,position+chunk.length,
					love.graphics.getFont())		
				love.graphics.print(str,self.x + x + ox,self.y + chunk.y)
				width = new_width
				
			end
			x = x + width
		end
		position = position+(chunk.length or 0)
	end
	
	love.graphics.pop()
	love.graphics.setFont(old_font)
	love.graphics.setColor(old_r,old_g,old_b,old_a)
end

------------------------------------------------------------------------
--HELPER METHODS
------------------------------------------------------------------------

function TastyText:_getOffset(line,new_line_width)
	local line_width = self.line_widths[line]
	local ox = 0
	if self.align == 'center' then
		ox = (self.limit - line_width)*0.5
	elseif self.align == 'right' then
		ox = (self.limit - line_width)
	end
	if self.subalign == 'center' then
		ox = ox + (line_width-new_line_width)*0.5
	elseif self.subalign == 'right' then
		ox = ox + (line_width-new_line_width)
	end
	return ox
end

function TastyText:_getSubLineWidths()
	line_widths   = {}
	local position= 0
	local font    = self.default_font
	
	for k = 1,#self.chunk_array do
		local chunk = self.chunk_array[k]
		if chunk.font then
			font = chunk.font
		elseif chunk.length and position+chunk.length >= self.first and 
		position <= self.last then
		
			local width = chunk.width
			if chunk.string then
				local str,new_width = self:_getSubString(chunk,position,
				position+chunk.length,font)
				width = new_width
			end
			line_widths[chunk.line] = (line_widths[chunk.line] or 0) 
			+ width
			
		end
		position = position+(chunk.length or 0)
	end
	return line_widths
end

function TastyText:_getMetaData()
	local line_lengths = {}
	local line_widths  = {}
	local length       = 0
	for i = 1,#self.chunk_array do
		local chunk = self.chunk_array[i]
		if chunk.length then
			length = length + chunk.length
			line_lengths[chunk.line] = 
				(line_lengths[chunk.line] or 0) + chunk.length
			line_widths[chunk.line] = 
				(line_widths[chunk.line] or 0) + chunk.width
		end
	end
	return #line_lengths,length,line_lengths,line_widths
end

function TastyText:_parseString(str)
	assert(#str > 0, 'Cannot parse empty string!')
	local encoded_str= self:_encode(str)
	local tag_pattern= START..'.-'..END
	local i          = 0
	local split_array= self:_splitNewLine( 
		self:_split(encoded_str,tag_pattern) )
	local chunk_array= self:_newChunkArray(split_array)
	
	-- Strip trailing spaces
	local the_chunk,prev_font
	local line  = 1
	local font  = self.default_font
	for i,chunk in ipairs(chunk_array) do
		font = chunk.font or font
		if chunk.line and chunk.line > line then
			if the_chunk and the_chunk.string then
				the_chunk.string,the_chunk.width = self:_stripTrailingSpace(
					the_chunk.string,prev_font)
			end
			line     = chunk.line
			the_chunk= nil
		end
		
		if chunk.width and chunk.width > 0 then
			the_chunk,prev_font = chunk,font
		end
	end
	
	if the_chunk and the_chunk.string then
		the_chunk.string,the_chunk.width = self:_stripTrailingSpace(
			the_chunk.string,prev_font)
	end	
	
	return chunk_array
end

function TastyText:_stripTrailingSpace(str,font)
	local new_str = str:match '^(.-)%s*$'
	local width   = font:getWidth(new_str)
	return new_str,width
end

function TastyText:_encode(str)
	return str:gsub(escape_tag,function(x)
		return string.format('\\%03d',string.byte(x))
	end)
end

function TastyText:_decode(str)
	return str:gsub('\\(%d%d%d)',string.char)
end

function TastyText:_newTagChunk(sub_str,line_index,x,y,tag_capture,font,tags)

	local tag_name= sub_str:match(tag_capture)
	local tag     = self.tags[tag_name]
	local next_x  = x
	local chunk
	if type(tag) == 'table' then
		if tag.draw then
			local width = tag.width or 0
			local length= tag.length or 0
			if x + width > self.limit then
				line_index = line_index + 1
				x,y = 0,y+self.line_height
			end
			chunk = {
				width     = width,
				length    = length,
				draw      = tag.draw,
				properties= tag.properties,
				line      = line_index,
				parent    = self,
			}
			next_x = x + width
		else -- color
			chunk = {
				color = tag,
			}
		end
		
	elseif tag:type() == 'Font' then
	
		chunk = {
			font= tag,
		}
		local default_baseline = self.default_font:getBaseline()
		local new_baseline     = chunk.font:getBaseline()
		y   = ((line_index-1)*self.line_height)-(new_baseline-default_baseline)
		font= chunk.font
		
	elseif tag:type() == 'Image' then
		
		local width = tag:getWidth()
		if x + width > self.limit then
			line_index = line_index + 1
			x,y = 0,y+self.line_height
		end
		
		chunk = {
			image = tag,
			width = width,
			line  = line_index,
			length= 1,
			x     = x,
			y     = (line_index-1)*self.line_height + (self.line_height-tag:getHeight())/2
		}
		
		next_x = x + width
	end

	return chunk,line_index,next_x,y,font
end

function TastyText:_newTextChunk(str,x,y,width,line_index)
	return {
		x     = x,
		y     = y,
		line  = line_index,
		string=str,
		width = width,
		length= str:utf8len(),
	}	
end

function TastyText:_newChunkArray(split_array)
	local chunk_array= {}
	local open_tag   = '^'..START
	local tag_capture= START..'(.+)'..END
	local newline    = '\n'
	local font       = self.default_font
	local tags       = self.tags
	-- y coordinate is also baseline corrected for the current font
	-- Use (line_index-1) * line_height for default y positions
	local line_index = 1
	local x,y        = 0,0 
	
	for i = 1,#split_array do
		local sub_str = split_array[i]
		local chunk
		if sub_str:find(open_tag) then
		
			chunk,line_index,x,y,font = self:_newTagChunk(sub_str,line_index,x,y,
				tag_capture,font,tags)
			table.insert(chunk_array,chunk)
			
		elseif sub_str == newline then
			
			line_index = line_index + 1
			x,y = 0,y+self.line_height
			
		else -- normal text
		
			-- Hack to strip leading space
			if x == 0 then
				sub_str = sub_str:match '^%s*(.*)'
			end
			sub_str = self:_decode(sub_str)
		
			local width = font:getWidth(sub_str)
			local next_x= x + width
			
			if next_x > self.limit then
			
				local str_array   = self:_split(sub_str,'%s+')
				local concat_t    = {}
				local accum_width = 0
				local i           = 1
				local min_limit   = font:getWidth('AA')
				
				while str_array[i] do
					local wordOrSpace= str_array[i]
					local isSpace    = wordOrSpace:find '^%s+'
					local width      = font:getWidth(wordOrSpace)
				
					if not isSpace and width > self.limit 
					and self.limit > min_limit
					then
					
						local array  = self:_splitLongWord(wordOrSpace,width,x+accum_width,font)
						str_array[i] = array[1]
						for j = 2,#array do
							table.insert(str_array,i+j-1,array[j])
						end
						wordOrSpace = array[1]
						width       = font:getWidth(wordOrSpace)
					end
					
					-- Concat the previous chunk and move string to next line
					if x + accum_width + width > self.limit then
						
						local str = table.concat(concat_t)
						concat_t  = {}
						if str ~= '' then
							chunk = self:_newTextChunk(str,x,y,accum_width,line_index)
							table.insert(chunk_array,chunk)	
						end
						
						-- Don't move to the next line if a long word fills a 
						-- whole line already
						if x + accum_width ~= 0 then
							line_index = line_index + 1
							x,y        = 0,y+self.line_height
							accum_width= 0
						end
						
						-- Don't include leading space in next line
						if isSpace then
							width = 0
						else
							table.insert(concat_t,wordOrSpace)
						end
						
					else 
						table.insert(concat_t,wordOrSpace) 
					end
					
					i = i + 1
					accum_width = accum_width + width
				end
				
				local str = table.concat(concat_t)
				if str ~= '' then
					chunk = self:_newTextChunk(str,x,y,accum_width,line_index)
					table.insert(chunk_array,chunk)
				end
				x = x + accum_width
				
			elseif sub_str ~= '' then
				chunk = self:_newTextChunk(sub_str,x,y,width,line_index)
				table.insert(chunk_array,chunk)
				x = x + width
			end
			
		end
	end
	
	return chunk_array
end

function TastyText:_splitLongWord(str,width,x,font)
	local array = {}
	local i     = 1
	
	while width > self.limit do
		local dw       = self.limit - x
		local sub_len  = math.ceil( (dw/width * str:utf8len()) )
		local sub_str  = str:utf8sub(1,sub_len)
		local sub_width= font:getWidth(sub_str)
		
		while x + sub_width > self.limit do
			sub_str   = sub_str:utf8sub(1,-2)
			sub_width = font:getWidth(sub_str)
			sub_len   = sub_len - 1
		end
		
		array[i]= sub_str
		str     = str:utf8sub(sub_len+1)
		width   = width-sub_width
		x       = 0
		i       = i + 1
	end
	array[i] = str

	return array
end

function TastyText:_splitNewLine(split_array)
	local new_array  = {}
	local index      = 0
	local open_tag   = '^'..START
	for i = 1,#split_array do
		local sub_str = split_array[i]
		if not sub_str:find(open_tag) then
			local array_newline_split = self:_split(sub_str,'\n')
			for j = 1,#array_newline_split do
				index = index + 1
				new_array[index] = array_newline_split[j]
			end
		else 
			index = index + 1
			new_array[index] = sub_str
		end
	end
	return new_array
end

function TastyText:_split(str,delimiter_pattern)
	local array = {}
	local index = 1
	local bytes = #str
	while index <= bytes do
		local s,e = string.find(str,delimiter_pattern,index)
		local value,tag
		if s then
			value = str:sub(index,s-1)
			tag   = str:sub(s,e)
			index = e+1
		else
			value = str:sub(index,bytes)
			index = bytes+1
		end
		if value ~= '' then
			table.insert(array,value)
		end
		table.insert(array,tag)
	end
	return array
end

function TastyText:_getSubString(chunk,i,j,font)
	local width = chunk.width
	local str   = chunk.string
	if self.first > 1 then
		local start= math.max(1,self.first-i)
		str        = chunk.string:utf8sub(start)
		width      = font:getWidth(str)
	end
	if self.last < self.length then
		local last = math.min(self.last-j-1,-1)
		str        = str:utf8sub(1,last)
		width      = font:getWidth(str)
	end
	return str,width
end

return TastyText