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
  local horizontal = dx < 0 and 'left' or 'right'
  local vertical = dy <= 0 and 'up' or 'down'

  local x_collision = nil
  local y_collision = nil

  local collision_layer = module.find_collision_layer(map)

  for _, i in ipairs(module.scan_rows(map, x, y, width, height, horizontal)) do
    if collision_layer.tiles[i] then
      x_collision = i
      break
    end
  end

  for _, i in ipairs(module.scan_cols(map, x, y, width, height, vertical)) do
    if collision_layer.tiles[i] then
      y_collision = i
      break
    end
  end

  if y_collision ~= nil and vertical == "down" then
    local tile_y  = math.floor(y_collision / map.width) * map.tileheight

    if tile_y <= (y + dy + height) then

      -- FIXME: Leaky abstraction
      player.jumping = false
      player:restore_solid_ground()

      return x + dx, tile_y - height
    end
  end

  if y_collision ~= nil and vertical == "up" then
    local platform = module.platform_type(collision_layer.tiles[y_collision].id)

    local tile_y = 0

    if platform == "block" then
      local tile_y  = math.floor(y_collision / map.width + 1) * map.tileheight
    elseif platform == "oneway" then
      local tile_y  = math.floor(y_collision / map.width) * map.tileheight
    end

    -- FIXME: the platform type stuff is super hacky
    if tile_y >= (y + dy) and platform == "block" then

      -- FIXME: Leaky
      player.velocity.y = 0

      return x + dx, tile_y
    end
  end


  return x + dx, y + dy
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
    edge_x = x + width
    stop, change = map.width, 1
  end

  local current_col = math.floor(edge_x / map.tilewidth) + 1
  local top_row = math.floor(y / map.tileheight)
  local bottom_row = math.floor((y + height) / map.tileheight)

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
    edge_y = y + height
    stop, change = map.height - 1, 1
  end

  local current_row = math.floor(edge_y / map.tileheight)
  local left_column = math.floor(x / map.tilewidth) + 1
  local right_column = math.floor((x + width) / map.tilewidth) + 1

  for i=current_row,stop,change do 
    for j=left_column,right_column,1 do 
      table.insert(cols, i * map.width + j)
    end
  end

  return cols
end


return module
