TILED_LOADER_PATH = TILED_LOADER_PATH or ({...})[1]:gsub("[%.\\/]init$", "") .. '.'

-- Return the classes in a table
return {
		Map = require(TILED_LOADER_PATH  .. "Map"),
		TileLayer = require(TILED_LOADER_PATH  .. "TileLayer"),
		Tile = require(TILED_LOADER_PATH  .. "Tile"),
		TileSet = require(TILED_LOADER_PATH  .. "TileSet"),
		Object = require(TILED_LOADER_PATH  .. "Object"),
		ObjectLayer = require(TILED_LOADER_PATH  .. "ObjectLayer"),
		Loader = require(TILED_LOADER_PATH  .. "Loader")
}


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