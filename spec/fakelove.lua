local imposter = require("spec/imposter")

local function open(path, m)
  local mode = m or "r"
  local handle, _ = io.open("save/" .. path, mode)
  
  if handle ~= nil then
    return handle
  end

  local handle, _ = io.open("src/" .. path, mode)
  return handle
end

return function()
  local love = imposter.new()

  love.graphics.getWidth.returns = 100
  love.graphics.getHeight.returns = 100

  local image = imposter.new()
  image.getHeight.returns = 100
  image.getWidth.returns = 100

  love.graphics.newImage.returns = image

  love.filesystem.exists = function(path)
    local handle, _ = open(path)

    if handle == nil then
      return false
    end

    handle:close()
    return true
  end

  love.filesystem.write = function(path, contents)
    local handle, _ = open(path, 'w')

    if handle == nil then
      error("Can't open file at path: " .. path)
    end

    handle:write(contents)
    handle:close()
  end

  love.filesystem.read = function(path)
    local handle, _ = open(path)

    if handle == nil then
      error("Can't open file at path: " .. path)
    end

    local contents = handle:read("*a")

    handle:close()
    return contents, #contents
  end

  return love
end
