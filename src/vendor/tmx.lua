local tmx = {}

local Map = {}
Map.__index = Map

function Map:draw(x, y)
  love.graphics.draw(self.layer, x, self.offset + y)
end

function tmx.tileRotation(tile)
  return {
    r = tile.flipDiagonal and math.pi * 1.5 or 0,
    sy = (tile.flipVertical and -1 or 1) * (tile.flipDiagonal and -1 or 1),
    sx = tile.flipHorizontal and -1 or 1,
  }
end


function tmx.load(level)
  local map = {}
  setmetatable(map, Map)
  local tileCount = 0

  for _, layer in ipairs(level.tilelayers) do
    if layer.tiles then
      for _, tile in ipairs(layer.tiles) do
        if tile.id ~= 0 then
          tileCount = tileCount + 1
        end
      end
    end
  end

  local imagePath = "maps/" .. level.tilesets[1].image.source

  map.tileset = love.graphics.newImage(imagePath)
  map.layer = love.graphics.newSpriteBatch(map.tileset, tileCount)
  map.offset = (tonumber(level.properties.offset) or 0) * level.tileheight

  local atlaswidth = map.tileset:getWidth()
  local atlasheight = map.tileset:getHeight()
  local tiles = {}
  local tilewidth = level.tilewidth
  local tileheight = level.tileheight

  local tileRow = atlaswidth / tilewidth
  local tileHeight = atlasheight / tileheight

  print("tilset dimensions " .. atlaswidth .. " x " .. atlasheight ")

  for y=0,tileHeight do
    for x=1,tileRow do
      local index = y * tileRow + x
      local offsetY = y * tileheight
      local offsetX = (x - 1) * tilewidth

      print("index " .. index)
      print("x,y " .. offsetX .. "," .. offsetY)

      tiles[index] = love.graphics.newQuad(offsetX, offsetY,
					   tilewidth, tileheight,
					   atlaswidth, atlasheight)
    end
  end


  for _, layer in ipairs(level.tilelayers) do
    if layer.tiles then
      for y=1,level.height do
        for x=1,level.width do
          local index = x + (y-1) * level.width
          local tile = layer.tiles[index]
          if tile and tile.id ~= 0 then
            local info = tmx.tileRotation(tile)

      	    map.layer:addq(tiles[tile.id],
			   x * tilewidth + (tilewidth / 2),
			   y * tileheight - (tileheight / 2),
			   info.r, info.sx, info.sy, 
			   (tilewidth / 2), (tileheight / 2))
          end
        end
      end
    end
  end

  return map
end

return tmx
