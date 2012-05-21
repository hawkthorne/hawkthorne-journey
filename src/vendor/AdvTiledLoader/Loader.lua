---------------------------------------------------------------------------------------------------
-- -= Loader =-
---------------------------------------------------------------------------------------------------

-- Define path so lua knows where to look for files.
TILED_LOADER_PATH = TILED_LOADER_PATH or ({...})[1]:gsub("[%.\\/][Ll]oader$", "") .. '.'

-- A cache to store tileset images so we don't load them multiple times. Filepaths are keys.
local cache = setmetatable({}, {__mode = "v"})
-- This stores cached images' original dimensions. Images are weak keys.
local cache_imagesize = setmetatable({}, {__mode="k"})

-- Decompresses gzip and zlib
local decompress = require(TILED_LOADER_PATH .. "external/deflatelua")
-- Parser than turns an XML file into a table
local xml_to_table = require(TILED_LOADER_PATH .. "external/xml")
-- Base64 parser, Turns base64 strings into other data formats
local base64 = require(TILED_LOADER_PATH .. "Base64")

-- Get the map classes
local Map = require(TILED_LOADER_PATH .. "Map")
local TileSet = require(TILED_LOADER_PATH .. "TileSet")
local TileLayer = require(TILED_LOADER_PATH .. "TileLayer")
local Tile = require(TILED_LOADER_PATH .. "Tile")
local Object = require(TILED_LOADER_PATH .. "Object")
local ObjectLayer = require(TILED_LOADER_PATH .. "ObjectLayer")


local Loader = {
	path = "", 				-- The path to tmx files.
	fixPO2 = false, 	    -- If true, pads the images to the power of 2.
	filterMin = "nearest",	-- The default min filter for image:setFilter()
	filterMag = "nearest",  -- The default mag filter for image:setFilter()
	useSpriteBatch = false,	-- The default setting for map.useSpriteBatch
	drawObjects = true,		-- The default setting for map.drawObjects
}

local filename -- The name of the tmx file
local fullpath -- The full path to the tmx file minus the name

-- Loads a Map from a tmx file and returns it.
function Loader.load(tofile)
	
	-- Get the raw path
	fullpath = Loader.path .. tofile
	
	-- Process directory up
	while string.find(fullpath, "[/\\][^/^\\]+[/\\]%.%.[/\\]") do
		fullpath = string.gsub(fullpath, "[/\\][^/^\\]+[/\\]%.%.[/\\]", "/", 1)
	end
	
	-- Get the file name
	filename = string.match(fullpath, "[^/^\\]+$")
	-- Get the path to the file
	fullpath = string.gsub(fullpath, "[^/^\\]+$", "")
	
	-- Read the file and parse it into a table
	local t = love.filesystem.read(fullpath .. filename)
	t = xml_to_table(t)
	
	-- Get the map and process it
	for _, v in pairs(t) do
		if v.label == "map" then
			return Loader._processMap(fullpath .. filename, v)
		end
	end
	
	-- If we made this this far then there wasn't a map tag
	error("Loader.load - No map found in file " .. fullpath .. filename)
end

----------------------------------------------------------------------------------------------------
-- Private
----------------------------------------------------------------------------------------------------

-- Returns a new image from the filename. If Loader.fixPO2 is set to true then 
-- the images will automatically be padded to the power of 2.
function Loader._newImage(info)
	local source, padded, image
	
	-- If the image information is image data then assign it as the source
	if info:type() == "ImageData" then  
		source = info
	-- Otherwise turn it into image data first
	else
		source = love.image.newImageData(info)
	end

    local w, h = source:getWidth(), source:getHeight()
	
	-- If we dont need to pad for PO2 then return now
	if not Loader.fixPO2 then return love.graphics.newImage(source), w, h end
	
    -- Find closest power-of-two.
    local wp = math.pow(2, math.ceil(math.log(w)/math.log(2)))
    local hp = math.pow(2, math.ceil(math.log(h)/math.log(2)))
   
    -- Only pad if needed:
    if wp ~= w or hp ~= h then
        padded = love.image._newImageData(wp, hp)
        padded:paste(source, 0, 0)
	else
		padded = source
    end
   
	-- Return the fixed image
    return love.graphics._newImage(padded), w, h 
end

-- Checks to see if the table is a valid XML table
function Loader._checkXML(t)
	assert(type(t) == "table", "Loader._checkXML - Passed value is not a table")
	assert(t ~= Loader, "Loader._checkXML - Passed table is the Loader class. " ..
						"You probably used a : instead of a .")
	assert(t.label, "Loader._checkXML - Table does not contain a label value")
	assert(t.xarg, "Loader._checkXML - Table does not contain an xarg table")
end


-- This is used to eliminate naming conflicts. It checks to see if the string is inside the table and
-- continues to rename it until there isn't a conflict.
function Loader._checkName(t, str)
	while t[str] do
		if string.find(str, "%(%d+%)$") == nil then str = str .. "(1)" end
		str = string.gsub(str, "%(%d+%)$", function(a) return "(" .. 
								tonumber( string.sub(a, string.find(a, "%d+")) ) + 1 .. ")" end)
	end
	return str
end

-- Processes a properties table and returns it
function Loader._processProperties(t)

	-- Do some checking
	Loader._checkXML(t)
	assert(t.label == "properties", "Loader._processProperties - Passed value is not a properties table")
	
	-- Create a properties table and populate it. Will attempt to convert the property to a number.
	local prop = {}
	for _,v in pairs(t) do
		Loader._checkXML(t)
		if v.label == "property" then
			prop[v.xarg.name] = tonumber(v.xarg.value) or v.xarg.value
		end
	end
	
	-- Return the properties
	return prop
end

-- Process Map data from xml table
function Loader._processMap(name, t)
	
	-- Do some checking
	Loader._checkXML(t)
	assert(t.label == "map", "Loader._processMap - Passed table is not a map")
	assert(t.xarg.width, t.xarg.height, t.xarg.tilewidth, t.xarg.tileheight,
		   "Loader._processMap - Map data is corrupt")

	-- We'll use these for temporary storage
	local map, tileset, tilelayer, objectlayer
	
	-- Create the map from the settings
	local map = Map:new(name, tonumber(t.xarg.width),tonumber(t.xarg.height), 
						tonumber(t.xarg.tilewidth), tonumber(t.xarg.tileheight), 
						t.xarg.orientation)
							
	-- Apply the loader settings
	map.useSpriteBatch = Loader.useSpriteBatch
	map.drawObjects = Loader.drawObjects
	
	-- Now we fill it with the content
	for _, v in ipairs(t) do
		
		-- Process TileSet
		if v.label == "tileset" then 
			tileset = Loader._processTileSet(v, map)
			map.tilesets[tileset.name] = tileset
			map:updateTiles()
		end
			
		-- Process TileLayer
		if v.label == "layer" then
			tilelayer = Loader._processTileLayer(v, map)
			map.tl[tilelayer.name] = tilelayer
			map.drawList[#map.drawList + 1] = tilelayer
		end
		
		-- Process ObjectLayer
		if v.label == "objectgroup" then
			objectlayer = Loader._processObjectLayer(v, map)
			map.ol[objectlayer.name] = objectlayer
			map.drawList[#map.drawList + 1] = objectlayer
		end
		
		-- Process Map properties
		if v.label == "properties" then
			map.properties = Loader._processProperties(v)
		end
			
	end
	
	-- Return our map
	return map
end

-- Process TileSet from xml table
function Loader._processTileSet(t, map)

	-- Do some checking
	Loader._checkXML(t)
	assert(t.label == "tileset", "Loader._processTileSet - Passed table is not a tileset")
	
	-- If the tileset is an external one then replace it as the tileset. The firstgid is 
	-- stored in the tileset tag in the original file while the rest of the tileset information 
	-- is stored in the external file.
	if t.xarg.source then 
		local gid = t.xarg.firstgid
		t = love.filesystem.read(Loader.path .. t.xarg.source)
		for _,v in pairs(xml_to_table(t)) do if v.label == "tileset" then t = v end end
		t.xarg.firstgid = gid
	end
	assert(t.xarg.name and t.xarg.tilewidth and t.xarg.tileheight and t.xarg.firstgid,
		   "Loader._processTileSet - Tileset data is corrupt")
	
	-- Temporary storage
	local image, imageWidth, imageHeight, path, prop
	local tileProperties = {}
	local tileoffset = {x=0,y=0}
	
	-- Process elements
	for _, v in ipairs(t) do
		-- Process image
		if v.label == "image" then 
			path = fullpath .. v.xarg.source
			-- Process directory up
			while string.find(path, "[^/^\\]+[/\\]%.%.[/\\]") do
				path = string.gsub(path, "[^/^\\]+[/\\]%.%.[/\\]", "", 1)
			end
			-- If the image is in the cache then load it
			if cache[path] then
				image = cache[path]
				imageWidth = cache_imagesize[image].width
				imageHeight = cache_imagesize[image].height
			-- Else load it and store in the cache
			else
				image = love.image.newImageData(path) 
				-- transparent color
				if v.xarg.trans then
					local trans = { tonumber( "0x" .. v.xarg.trans:sub(1,2) ), 
									tonumber( "0x" .. v.xarg.trans:sub(3,4) ), 
									tonumber( "0x" .. v.xarg.trans:sub(5,6) )}
					image:mapPixel( function(x,y,r,g,b,a)
					return r,g,b, (trans[1] == r and trans[2] == g and trans[3] ==b and 0) or a  end
					)
				end
				-- Set the image information
				image, imageWidth, imageHeight = Loader._newImage(image)
				image:setFilter(Loader.filterMin, Loader.filterMag)
				-- Cache the created image
				cache[path] = image
				cache_imagesize[image] = {width = imageWidth, height = imageHeight}
			end
		end
		
		-- Process tile properties
		if v.label == "tile" then 
			for _, v2 in ipairs(v) do
				if v2.label == "properties" then
					-- Store the property. We must increase the id the starting gid
					tileProperties[v.xarg.id+t.xarg.firstgid] = Loader._processProperties(v2)
				end
			end
		end
		
		-- Process tile set properties
		if v.label == "properties" then
			local tileSetProperties = Loader._processProperties(v)
		end
		
		-- Get the tile offset if there is one.
		if v.label == "tileoffset" then
			tileoffset.x, tileoffset.y = tonumber(v.xarg.x or 0), tonumber(v.xarg.y or 0)
		end

	end
	
	-- Make sure that an image was loaded
	assert(image, "Loader._processTileSet - Tileset did not contain an image")

	-- Return the TileSet
	local tileset = TileSet:new(image, Loader._checkName(map.tilesets, t.xarg.name), 
					   tonumber(t.xarg.tilewidth), tonumber(t.xarg.tileheight),
					   tonumber(imageWidth), tonumber(imageHeight),
					   tonumber(t.xarg.firstgid), tonumber(t.xarg.spacing), 
					   tonumber(t.xarg.margin), tileProperties, tileSetProperties)
	tileset.tileoffset = tileoffset
	return tileset
end

-- Process TileLayer from xml table
function Loader._processTileLayer(t, map)

	-- Do some checking
	Loader._checkXML(t)
	assert(t.label == "layer", "Loader._processTileLayer - Passed table is not a tileset")
	
	-- Process elements
	local data, properties
	for _, v in ipairs(t) do
		Loader._checkXML(t)
		
		-- Process data
		if v.label == "data" then 
			data = Loader._processTileLayerData(v) 
		end
		
		-- Process TileLayer properties
		if v.label == "properties" then
			properties = Loader._processProperties(v)
		end
	end
	
	-- Return the new layer
	local tl = TileLayer:new(map, t.xarg.name, t.xarg.opacity, properties)
	tl:_populate(data)
	return tl
end

-- Process TileLayer data from xml table
function Loader._processTileLayerData(t)

	-- Do some checking
	Loader._checkXML(t)
	assert(t.label == "data", "Loader._processTileLayerData - Passed table is not TileLayer data")
	
	local data = {}
	
	-- If encoded by comma seperated value (csv) then cut each value out and put it into a table.
	if t.xarg.encoding == "csv" then
        	string.gsub(t[1], "[%-%d]+", function(a) data[#data+1] = tonumber(a) or 0 end)
	end
	
	-- Base64 encoding. See base64.lua for more details.
	if t.xarg.encoding == "base64" then
	
		-- If a compression method is used
		if t.xarg.compression == "gzip" or t.xarg.compression == "zlib"  then
			-- Select the appropriate function
			local decomp = t.xarg.compression == "gzip" and decompress.gunzip or decompress.inflate_zlib
			-- Decompress the string into bytes
			local bytes = {}
			decomp({input = base64.decode("string", t[1]), output = function (b) bytes[#bytes+1] = b end})
			-- Glue the bytes into ints
			for i=1,#bytes,4 do
				data[#data+1] = base64.glueInt(bytes[i],bytes[i+1],bytes[i+2],bytes[i+3])
			end
		-- If there is no compression then just convert to ints
		else
			data = base64.decode("int", t[1])
		end
	end
	
	-- If there is no encoding then the file is probably saved as XML
	if t.xarg.encoding == nil then
		for k,v in ipairs(t) do
			if v.label == "tile" then 
				data[#data+1] = tonumber(v.xarg.gid)
			end
		end
	end
	
	-- Return the data
	return data
end

-- Process ObjectLayer from xml table
function Loader._processObjectLayer(t, map)

	-- Do some checking
	Loader._checkXML(t)
	assert(t.label == "objectgroup", "Loader._processObjectLayer - Passed table is not ObjectLayer data")
	
	-- Tiled stores colors in hexidecimal format that looks like "#FFFFFF" 
	-- We need go convert them into base 10 RGB format
	if t.xarg.color == nil then t.xarg.color = "#000000" end
	local color = { tonumber( "0x" .. t.xarg.color:sub(2,3) ), 
					tonumber( "0x" .. t.xarg.color:sub(4,5) ), 
					tonumber( "0x" .. t.xarg.color:sub(6,7) )}
	
	-- Create a new layer
	local layer = ObjectLayer:new(map, Loader._checkName(map.ol, t.xarg.name), color, 
								  t.xarg.opacity)
					
	-- Process elements
	local objects = {}
	local prop, obj, poly
	for _, v in ipairs(t) do
	
		-- Process objects
		local obj
		if v.label == "object" then
			obj = Object:new(layer, v.xarg.name, v.xarg.type, tonumber(v.xarg.x), 
											 tonumber(v.xarg.y), tonumber(v.xarg.width), 
											 tonumber(v.xarg.height), tonumber(v.xarg.gid) )
			objects[#objects+1] = obj
			for _, v2 in ipairs(v) do
			
				-- Process object properties
				if v2.label == "properties" then 
					obj.properties = Loader._processProperties(v2)
				end
				
				-- Process polyline objects
				if v2.label == "polyline" then
					obj.polyline = {}
					string.gsub(v2.xarg.points, "[%-%d]+", function(a) obj.polyline[#obj.polyline+1] = tonumber(a) or 0 end)
				end
				
				-- Process polyline objects
				if v2.label == "polygon" then
					obj.polygon = {}
					string.gsub(v2.xarg.points, "[%-%d]+", function(a) obj.polygon[#obj.polygon+1] = tonumber(a) or 0 end)
				end
			
			end
			obj:updateDrawInfo()
		end
		
		-- Process properties
		if v.label == "properties" then
			prop = Loader._processProperties(v)
		end
		
	end
	
	-- Set the properties and object tables
	layer.properties = prop
	layer.objects = objects
	
	-- Return the layer
	return layer
end

-- Return the loader
return Loader


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

