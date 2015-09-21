local module = {}

function module.find_collision_layer(map)
  for _, layer in ipairs(map.tilelayers) do
    if layer.name == "collision" then
      return layer
    end
  end
  return {tiles = {}}
end

function module.platform_type(tile_id)
  if tile_id >= 78 and tile_id <= 103 then
    return 'ice-block'
  end
  if tile_id >= 52 and tile_id <= 77 then
    return 'no-drop'
  end
  if tile_id >= 26 and tile_id <= 51 then
    return 'oneway'
  end
  -- Tile id 104 is a special block representing the breakable block
  if (tile_id >= 0 and tile_id <= 25) or
     (tile_id >= 104 and tile_id <= 129) then
    return 'block'
  end

  error('Unknown collision type')
end

function module.is_sloped(tile_id)
  return (tile_id > 0 and tile_id < 21) or (tile_id > 26 and tile_id < 47)
         or (tile_id > 52 and tile_id < 73) or (tile_id > 78 and tile_id < 99)
         or (tile_id > 104 and tile_id < 125)
end

function module.is_special(tile_id)
  return (tile_id > 20 and tile_id < 26) or (tile_id > 46 and tile_id < 52)
         or (tile_id > 72 and tile_id < 78) or (tile_id > 98 and tile_id < 104)
         or (tile_id > 126 and tile_id < 130)
end

local _slopes = {
  nil,
  {23, 0},
  {0, 23},
  {23, 12},
  {11, 0},
  {0, 11},
  {12, 23},
  {23, 16},
  {15, 8},
  {7, 0},
  {0, 7},
  {8, 15},
  {16, 23},
  {23, 18},
  {17, 12},
  {11, 7},
  {6, 0},
  {0, 6},
  {7, 11},
  {12, 17},
  {18, 23}
}

-- format, {x, y, x + width, y + height}
local _special = {
  {0, 12, 24, 24},
  {0, 12, 12, 24},
  {12, 12, 24, 24},
  {0, 0, 12, 24},
  {12, 0, 24, 24}
}

function module.slope_edges(tile_id)
  local tile_id = tile_id % 26
  return _slopes[tile_id + 1][1], _slopes[tile_id + 1][2]
end

function module.special_interp_y(tile_id, tile_x, x, width, direction)
  local tile_id = tile_id % 26
  local tile = _special[tile_id - 20]
  -- Outside the tiles area
  if x + width - tile_x <= tile[1] or x - tile_x >= tile[3] then return nil end
  
  if direction == 'down' then
    return tile[2]
  elseif direction == 'up' then
    return tile[4]
  end
end

function module.special_interp_x(tile_id, tile_y, y, direction)
  local tile_id = tile_id % 26
  local tile = _special[tile_id - 20]
  -- Outside the tiles area
  if y - tile_y <= tile[2] or y - tile_y > tile[4] + 1 then return nil end
  
  if direction == 'right' then
    return tile[1]
  elseif direction == 'left' then
    return tile[3]
  end
end

-- if the character (that is, his bottom-center pixel) is on a 
-- {0, *} slope, ignore left tile, and, if on a {*, 0} slope,
-- ignore the right tile.
--
-- Also, remember that tile ids are indexed startin at 1
-- We assume that the tile at tile_index is sloped
function module.is_adjacent(current_index, current_id, tile_index, tile_id, direction)
  if tile_id ~= 0 and tile_id ~= 104 and not module.is_special(tile_id) then
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

-- Adds a tile to a specific location
function module.add_tile(map, x, y, width, height, tile_type)
    local collision_layer = module.find_collision_layer(map)
    -- y needs to be offset so that it returns tile rather standing tile
    local index = module.current_tile(map, x, y - height, width, height)
    
    -- Tiles only seem to contain an id
    local tile = {id = tile_type}
    collision_layer.tiles[index] = tile
end

-- Removes a tile from a specific location
function module.remove_tile(map, x, y, width, height)
    local collision_layer = module.find_collision_layer(map)
    -- y needs to be offset so that it returns tile rather standing tile
    local index = module.current_tile(map, x, y - height, width, height)
    
    collision_layer.tiles[index] = nil
end

function module.move_x(map, player, x, y, width, height, dx, dy)
  if dx == 0 then return x end
 
  -- Clamp player position inside of level
  if x + dx <= 0 then
    if player.wall_pushback then
      player:wall_pushback()
    end
    return 0
  elseif x + dx >= map.width * map.tilewidth - width then
    if player.wall_pushback then
      player:wall_pushback()
    end
    return map.width * map.tilewidth - width
  end
  
  local collision_layer = module.find_collision_layer(map)
  local direction = dx < 0 and "left" or "right"
  local new_x = x + dx

  local current_index = module.current_tile(map, x, y, width, height)
  local current_tile = collision_layer.tiles[current_index]

  for _, i in ipairs(module.scan_rows(map, x, y, width, height, direction)) do
    local tile = collision_layer.tiles[i]

    if tile then
      local platform_type = module.platform_type(tile.id)
      local sloped = module.is_sloped(tile.id)
      local special = module.is_special(tile.id)

      local adjacent_slope = false

      if current_tile then
        adjacent_slope = module.is_adjacent(current_index, current_tile.id, i, 
                                            tile.id, direction)
      end

      local ignore = sloped or adjacent_slope
      
      if direction == "left" then
        local tile_x = math.floor(i % map.width) * map.tileheight
        local tile_y = math.floor((i - 1) / map.width) * map.tileheight
        
        if (platform_type == "block" or platform_type == "ice-block") and not ignore then

          if special then
            local t_x = module.special_interp_x(tile.id, tile_y, y + height, direction)
            if t_x then
              -- tile_x is offset by 1 tilewidth to the right
              tile_x = tile_x - map.tilewidth + t_x
            else
              -- Use an unrealistic tile_x so it gets ignored
              tile_x = new_x - width
            end
          end
        
          if new_x <= tile_x and tile_x <= x then
            if player.wall_pushback then
              player:wall_pushback(tile)
            end
            return tile_x
          end
        end
      end

      if direction == "right" then
        local tile_x = math.floor((i - 1) % map.width) * map.tilewidth
        local tile_y = math.floor((i - 1) / map.width) * map.tileheight

        if (platform_type == "block" or platform_type == "ice-block") and not ignore then

          if special then
            local t_x = module.special_interp_x(tile.id, tile_y, y + height, direction)
            if t_x then
              tile_x = tile_x + t_x
            else
              -- Use an unrealistic tile_x so it gets ignored
              tile_x = x - width
            end
          end
        
          if x <= tile_x and tile_x <= (new_x + width) then
            if player.wall_pushback then
              player:wall_pushback(tile)
            end
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
  if dy == 0 then return y end

  local direction = dy <= 0 and 'up' or 'down'
  local new_y = y + dy
  local collision_layer = module.find_collision_layer(map)

  for _, i in ipairs(module.scan_cols(map, x, y, width, height, direction)) do

    local tile = collision_layer.tiles[i]

    if tile then
      local platform_type = module.platform_type(tile.id)
      local sloped = module.is_sloped(tile.id)
      local special = module.is_special(tile.id)
      local center_x = x + (width / 2)
      local tile_x = math.floor(((i - 1) % map.width)) * map.tilewidth

      if direction == "down" and
       -- Ensure that the center of the player is actually within tile (or very close)
      (not sloped or (center_x >= tile_x - 5 and center_x <= tile_x + map.tilewidth + 5) ) then
        
        -- need to offset to prevent issue when tile_x == map.width
        local tile_y = math.floor((i - 1) / map.width) * map.tileheight
        local slope_y = math.floor((i - 1) / map.width) * map.tileheight
        local tile_slope = 0

        if sloped then
          local ledge, redge = module.slope_edges(tile.id)
          local slope_change = module.interpolate(tile_x, center_x, ledge, redge,
                                                  map.tilewidth)
          tile_slope = (ledge - redge) / map.tilewidth
          slope_y = tile_y + slope_change

        elseif special then
          local tile_height = module.special_interp_y(tile.id, tile_x, x, width, direction)
          -- Height can be nil meaning the tile is not there
          if tile_height then
            slope_y = tile_y + tile_height
          else
            -- Use an unrealistic y-position so it gets ignored
            slope_y = new_y + height * 2
          end
        end
        
        player.on_ice = platform_type == "ice-block"

        if (platform_type == "block" or platform_type == "ice-block") then
          -- will never be dropping when standing on a block  
          player.platform_dropping = false
          -- If the block is sloped, interpolate the y value to be correct
          if slope_y <= (new_y + height - tile_slope * dx + 2) and (slope_y >= y + height or not special) then
            if player.floor_pushback then
              player:floor_pushback(tile)
            end
            return slope_y - height
          end
        end

        if platform_type == "oneway" or platform_type == "no-drop" then
          -- If player is in a sloped tile, keep them there
          local foot = y + height - tile_slope * dx - 2
          local above_tile = foot <= slope_y
          local in_tile = sloped and foot > tile_y and foot <= tile_y + map.tileheight

          if (above_tile or in_tile) and slope_y <= (new_y + height - tile_slope * dx + 2) and
             (slope_y >= y + height or not special)then
          
            -- Only oneways support dropping
            if platform_type == "oneway" then
              if player.platform_dropping == true then
                player.platform_dropping = y + height
              elseif player.platform_dropping then
                return new_y
              end
            else
              -- can't drop on a no-drop tile
              player.platform_dropping = false
            end
          
            if player.floor_pushback then
              player:floor_pushback(tile)
            end
            return slope_y - height
          end
        end
      end

      if direction == "up" then
        if (platform_type == "block" or platform_type == "ice-block") then
          local tile_y = math.floor(i / map.width + 1) * map.tileheight
          
          if special then
            local tile_height = module.special_interp_y(tile.id, tile_x, x, width, direction)
            -- Height can be nil meaning the tile is not there
            if tile_height then
              tile_y = tile_y - map.tilewidth + tile_height
            else
              -- Use an unrealistic y-position so it gets ignored
              tile_y = new_y + height * 2
            end
          end

          if y > tile_y and tile_y >= new_y then
            player.velocity.y = 0
            if player.ceiling_pushback then
              player:ceiling_pushback(tile)
            end
            return tile_y
          end
        end

        if platform_type == "oneway" or platform_type == "no-drop" then
          -- Oneway platforms never collide when going up
        end
      end 
    end
  end
  
  -- Scan through all moving platforms
  for _, platform in ipairs(map.moving_platforms) do
    if x + width >= platform.x and x <= platform.x + platform.width then
      -- Only apply platform dy when the platform is moving up
      local foot = y + height - 2 + math.min(0, platform.dy)
      local above_tile = foot <= platform.y
      
      if above_tile and platform.y <= (new_y + height + 2) and
         direction == 'down' then
        
        -- Dropping is not allowed on moving platforms
        player.platform_dropping = false
        
        if player.floor_pushback then
          player:floor_pushback()
        end
        
        platform:collide(player)
        return platform.y - height
      end
    end
    -- Player is no longer on the platform
    if player.currentplatform == platform then
      player.currentplatform = nil
    end
  end

  return new_y
end


-- Returns the new position for x and y
-- width/height should not be equal to or more than 2 tiles wide/tall
function module.move(map, player, x, y, width, height, dx, dy)
  local new_x = module.move_x(map, player, x, y, width, height, dx, dy)
  local new_y = module.move_y(map, player, new_x, y, width, height, dx, dy)
  return new_x, new_y
end

-- Returns whether or not the character can increase size
function module.stand(map, player, x, y, width, height, new_height)
    local change = height - new_height
    local new_y = module.move_y(map, player, x, y, width, height, 0, change)
    -- If it is possible to move to the new location, it means standing up is possible
    return new_y == y + change
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
