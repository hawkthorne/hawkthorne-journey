local camera = require 'camera'

local tmx = {}

local Map = {}
Map.__index = Map

function Map:draw( x, y, view )
  for _,layer in ipairs(self.layers) do
    local fg = ( view == 'foreground' )
    if fg == layer.foreground then
      local _x = math.floor( camera.x * ( 1 - layer.parallax ) )
      local _y = math.floor( ( camera.y - ( layer.tileheight * layer.offset ) ) * ( 1 - layer.parallax ) )
      love.graphics.draw(layer.batch, _x, _y)
    end
  end
end

function tmx.tileRotation(tile)
  return {
    r = tile.flipDiagonal and math.pi * 1.5 or 0,
    sy = (tile.flipVertical and -1 or 1) * (tile.flipDiagonal and -1 or 1),
    sx = tile.flipHorizontal and -1 or 1
  }
end

function tmx.getParallaxLayer( map, tilelayer, level )
  local parallax = tonumber(tilelayer.properties.parallax) or 1
  local foreground = tilelayer.properties.foreground == 'true'
  for _, layer in ipairs( map.layers ) do
    if layer.parallax == parallax and layer.foreground == foreground then
      return layer
    end
  end
  local layer = {
      tileCount = 0,
      parallax = parallax,
      width = level.width * level.tilewidth,
      height = level.height * level.tileheight,
      offset = tonumber(level.properties.offset) or 0,
      tileheight = level.tileheight,
      tilewidth = level.tilewidth,
      foreground = foreground
  }
  table.insert( map.layers, layer )
  return layer
end

function tmx.load(level)
  local map = {}
  setmetatable(map, Map)
  local imagePath = string.sub( level.tilesets[1].image.source, 3 )

  map.tileset = love.graphics.newImage(imagePath)
  map.offset = (tonumber(level.properties.offset) or 0) * level.tileheight
  map.layers = {}
  
  for _, tilelayer in ipairs(level.tilelayers) do
    if tilelayer.name ~= "collision" and tilelayer.tiles then
      layer = tmx.getParallaxLayer( map, tilelayer, level )
      for _, tile in ipairs(tilelayer.tiles) do
        if tile then
          layer.tileCount = layer.tileCount + 1
        end
      end
    end
  end

  for _, layer in ipairs(map.layers) do
    layer.batch = love.graphics.newSpriteBatch(map.tileset, layer.tileCount)
  end
  
  local atlaswidth = map.tileset:getWidth()
  local atlasheight = map.tileset:getHeight()
  local tiles = {}
  local tilewidth = level.tilewidth
  local tileheight = level.tileheight

  local tileRow = atlaswidth / tilewidth
  local tileHeight = atlasheight / tileheight

  for y=0,(tileHeight - 1) do
    for x=0,(tileRow - 1) do
      local index = y * tileRow + x
      local offsetY = y * tileheight
      local offsetX = x * tilewidth

      tiles[index] = love.graphics.newQuad(offsetX, offsetY,
                                           tilewidth, tileheight,
                                           atlaswidth, atlasheight)
    end
  end


  for _, tilelayer in ipairs(level.tilelayers) do
    if tilelayer.tiles then
      for i, tile in ipairs(tilelayer.tiles) do
        local x = (i - 1) % level.width
        local y = math.floor((i - 1)/ level.width)

        if tile then
          local info = tmx.tileRotation(tile)
          
          local sx = tile.flipHorizontal and -1 or 1
          local sy = tile.flipVertical and -1 or 1

          if tile.flipDiagonal then
            sx, sy = -sy, sx
          end

          layer = tmx.getParallaxLayer( map, tilelayer )

          layer.batch:add(tiles[tile.id], 
                         x * tilewidth + (tilewidth / 2),
                         y * tileheight + (tileheight / 2),
                         tile.flipDiagonal and math.pi * 1.5 or 0, --rotation
                         sx, sy, tilewidth / 2, tileheight / 2)
        end
      end
    end
  end

  table.sort(map.layers, function(a,b) return a.parallax < b.parallax end)
  
  return map
end

return tmx
