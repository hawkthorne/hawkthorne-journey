local module = {}

function module.find_collision_layer(map)
  for _, layer in ipairs(map.tilelayers) do
    if layer.name == "collision" then
      return layer
    end
  end
  return nil
end

-- Returns the new position for x and y
function module.move(map, x, y, width, height, dx, dy)
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

  if y_collision ~= nil then
    local tile_row = math.floor(y_collision / map.width)
    return x + dx, (tile_row * map.tileheight) - height
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
