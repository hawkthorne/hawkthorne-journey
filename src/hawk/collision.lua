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
  if tile_id >= 21 and tile_id <= 43 then
    return 'oneway'
  else
    return 'block'
  end
end


-- Returns the new position for x and y
function module.move(map, player, x, y, width, height, dx, dy)
  local horizontal = player.character.direction
  local vertical = dy <= 0 and 'up' or 'down'

  local x_collision = nil
  local y_collision = nil

  local new_x = x + dx
  local new_y = y + dy

  local collision_layer = module.find_collision_layer(map)

  for _, i in ipairs(module.scan_rows(map, x, y, width, height, horizontal)) do
    if collision_layer.tiles[i] then
      x_collision = i
      break
    end
  end

  if x_collision ~= nil and horizontal == "left" then
    local platform = module.platform_type(collision_layer.tiles[x_collision].id)
    local tile_x = math.floor(x_collision % map.width) * map.tileheight

    if platform == "block" then
      if new_x <= tile_x then
        -- FIXME: Leaky abstraction
        new_x = tile_x
      end
    end
  end
  

  if x_collision ~= nil and horizontal == "right" then
    local platform = module.platform_type(collision_layer.tiles[x_collision].id)
    local tile_x = math.floor((x_collision % map.width) - 1) * map.tilewidth

    if platform == "block" then
      -- FIXME: the platform type stuff is super hacky
      if tile_x <= (new_x + width) then
      -- FIXME: Leaky
        new_x = tile_x - width
      end
    end
  end

  for _, i in ipairs(module.scan_cols(map, new_x, y, width, height, vertical)) do
    if collision_layer.tiles[i] then
      y_collision = i
      break
    end
  end

  if y_collision ~= nil and vertical == "down" then
    local platform = module.platform_type(collision_layer.tiles[y_collision].id)

    if platform == "block" then
      local tile_y  = math.floor(y_collision / map.width) * map.tileheight

      if tile_y <= (y + dy + height) then
        -- FIXME: Leaky abstraction
        player.jumping = false
        player:restore_solid_ground()
        return new_x, tile_y - height
      end
    end

    if platform == "oneway" then
      local tile_y  = math.floor(y_collision / map.width) * map.tileheight
      local player_above_tile = (y + height) <= tile_y 

      if player_above_tile and tile_y <= (y + dy + height) then
        player.jumping = false
        player:restore_solid_ground()
        return new_x, tile_y - height
      end
    end
  end

  if y_collision ~= nil and vertical == "up" then
    local platform = module.platform_type(collision_layer.tiles[y_collision].id)

    if platform == "block" then
      local tile_y  = math.floor(y_collision / map.width + 1) * map.tileheight

      if tile_y >= (y + dy) then
        player.velocity.y = 0
        return new_x, tile_y
      end

    end
    
    if platform == "oneway" then
      -- Oneway platforms never collide when going up
    end
  end

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
