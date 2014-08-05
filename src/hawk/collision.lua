local module = {}

function module.find_collision_layer(map)
  for _, layer in ipairs(map.tilelayers) do
    if layer.name == "collision" then
      return layer
    end
  end
  return nil
end

function module.platform_type(tile_id)
  if tile_id >= 21 and tile_id <= 42 then
    return 'oneway'
  end

  if tile_id >= 0 and tile_id <= 20 then
    return 'block'
  end

  error('Unknown collision type')
end

function module.is_sloped(tile_id)
  return (tile_id > 0 and tile_id < 21) or (tile_id > 21 and tile_id < 43)
end

local _slopes = {
  nil,
  {23, 0},
  {0, 23},
  {23, 12},
  {11, 0},
  {0, 11},
  {12, 23},
}

function module.slope_edges(tile_id)
  local tile_id = tile_id % 21
  return _slopes[tile_id + 1][1], _slopes[tile_id + 1][2]
end

-- if the character (that is, his bottom-center pixel) is on a 
-- {0, *} slope, ignore left tile, and, if on a {*, 0} slope,
-- ignore the right tile.
--
-- Also, remember that tile ids are indexed startin at 1
-- We assume that the tile at tile_index is sloped
function module.is_adjacent(current_index, current_id, tile_index, tile_id, direction)
  if tile_id ~= 0 then
    return false
  end

  -- Check if the tile is adjacent
  -- FIXME: Corner case where these ids overlap rows
  if direction == "right" and tile_index - current_index ~= 1 then
    return false
  end

  -- Check if the tile is adjacent
  -- FIXME: Corner case where these ids overlap rows
  if direction == "left" and current_index - tile_index ~= 1 then
    return false
  end

  if not module.is_sloped(current_id) then
    return false
  end

  return true
end

-- Returns the current tile index, using the bottom center pixel
function module.current_tile(map, x, y, width, height)
  local x1 = math.floor(x + width / 2)
  local y1 = y + height

  local current_col = math.floor(x1 / map.tilewidth) + 1
  local current_row = math.floor(y1 / map.tileheight)

  local result = current_row * map.width + current_col

  return result
end

function module.move_x(map, player, x, y, width, height, dx, dy)
  local collision_layer = module.find_collision_layer(map)
  local direction = player.character.direction
  local new_x = x + dx

  local current_index = module.current_tile(map, x, y, width, height)
  local current_tile = collision_layer.tiles[current_index]

  for _, i in ipairs(module.scan_rows(map, x, y, width, height, direction)) do
    local tile = collision_layer.tiles[i]

    if tile then
      local platform_type = module.platform_type(tile.id)
      local sloped = module.is_sloped(tile.id)

      local adjacent_slope = false

      if current_tile then
        adjacent_slope = module.is_adjacent(current_index, current_tile.id, i, 
                                            tile.id, direction)
      end

      local ignore = sloped or adjacent_slope
      
      if direction == "left" then
        local tile_x = math.floor(i % map.width) * map.tileheight

        if platform_type == "block" and not ignore then

          if new_x <= tile_x and tile_x <= x then
            return tile_x
          end

        end
      end

      if direction == "right" then
        local tile_x = math.floor((i % map.width) - 1) * map.tilewidth

        if platform_type == "block" and not ignore then

          if x <= tile_x and tile_x <= (new_x + width) then
            return tile_x - width
          end

        end
      end
    end
  end

  return new_x
end

--local center_x = player_x + bbox_width / 2

function module.interpolate(tile_x, center_x, left_edge, right_edge, tilesize)
  local t = (center_x - tile_x) / tilesize;
  local y = math.floor(((1-t) * left_edge + t * right_edge))
  return math.min(math.max(y, 0), tilesize)
end


function module.move_y(map, player, x, y, width, height, dx, dy)
  local direction = dy <= 0 and 'up' or 'down'
  local new_y = y + dy
  local collision_layer = module.find_collision_layer(map)

  for _, i in ipairs(module.scan_cols(map, x, y, width, height, direction)) do
    local tile = collision_layer.tiles[i]

    if tile then
      local platform_type = module.platform_type(tile.id)
      local sloped = module.is_sloped(tile.id)

      if direction == "down" then
        local tile_x = math.floor((i % map.width) - 1) * map.tilewidth
        local tile_y = math.floor(i / map.width) * map.tileheight
        local slope_y = math.floor(i / map.width) * map.tileheight

        if sloped then
          local center_x = x + (width / 2)
          local ledge, redge = module.slope_edges(tile.id)
          local slope_change = module.interpolate(tile_x, center_x, ledge, redge,
                                             map.tilewidth)
          slope_y = tile_y + slope_change
        end

        if platform_type == "block" then

          -- If the block is sloped, interpolate the y value to be correct
          if slope_y <= (y + dy + height) then
            -- FIXME: Leaky abstraction
            player.jumping = false
            player.velocity.y = 0
            player:restore_solid_ground()
            return slope_y - height
          end
        end

        if platform_type == "oneway" then
          local above_tile = (y + height) <= slope_y 

          -- If player is in a sloped tile, keep them there
          local foot = y + height
          local in_tile = sloped and foot > tile_y and foot <= tile_y + map.tileheight

          if (above_tile or in_tile) and slope_y <= (y + dy + height) then
            player.jumping = false
            player.velocity.y = 0
            player:restore_solid_ground()
            return slope_y - height
          end
        end
      end

      if direction == "up" then
        if platform_type == "block" then
          local tile_y = math.floor(i / map.width + 1) * map.tileheight

          if y > tile_y and tile_y >= (y + dy) then
            player.velocity.y = 0
            return tile_y
          end
        end

        if platform_type == "oneway" then
          -- Oneway platforms never collide when going up
        end
      end 
    end
  end

  return new_y
end


-- Returns the new position for x and y
function module.move(map, player, x, y, width, height, dx, dy)
  local new_x = module.move_x(map, player, x, y, width, height, dx, dy)
  local new_y = module.move_y(map, player, new_x, y, width, height, dx, dy)
  return new_x, new_y
end

function module.scan_rows(map, x, y, width, height, direction)
  if direction ~= "left" and direction ~= "right" then
    error("Direction must be left or right")
  end

  local rows = {}

  -- Default value for left
  local edge_x = x
  local stop, change = 1, -1

  if direction == "right" then
    stop, change = map.width, 1
  end

  local current_col = math.floor(edge_x / map.tilewidth) + 1
  local top_row = math.floor(y / map.tileheight)
  local bottom_row = math.floor((y + height - 1) / map.tileheight)

  for i=current_col,stop,change do 
    for j=top_row,bottom_row,1 do 
      table.insert(rows, i + (j * map.width))
    end
  end

  return rows
end 

function module.scan_cols(map, x, y, width, height, direction)
  if direction ~= "up" and direction ~= "down" then
    error("Direction must be up or down")
  end

  local cols = {}

  -- Default value for left
  local edge_y = y
  local stop, change = 0, -1

  if direction == "down" then
    stop, change = map.height - 1, 1
  end

  local current_row = math.floor(edge_y / map.tileheight)
  local left_column = math.floor(x / map.tilewidth) + 1
  local right_column = math.floor((x + width - 1) / map.tilewidth) + 1

  for i=current_row,stop,change do 
    for j=left_column,right_column,1 do
      table.insert(cols, i * map.width + j)
    end
  end

  return cols
end


return module
