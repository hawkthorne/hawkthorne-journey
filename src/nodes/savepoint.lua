local app = require 'app'
local prompt = require 'prompt'

local Savepoint = {}

Savepoint.__index = Savepoint

local image = love.graphics.newImage('images/bust.png')
image:setFilter('nearest', 'nearest')

function Savepoint.new(node, collider, level)
  local savepoint = {}
  setmetatable(savepoint, Savepoint)

  assert(node.name, "All savepoints must have names")

  savepoint.x = node.x
  savepoint.y = node.y
  savepoint.width = node.width
  savepoint.height = node.height
  savepoint.name = node.name
  savepoint.level = level.name

  savepoint.player_touched = false
  savepoint.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  savepoint.bb.node = savepoint
  collider:setPassive(savepoint.bb)

  return savepoint
end

function Savepoint:update(dt, player)
  if self.prompt then self.prompt:update(dt) end
end

function Savepoint:keypressed( button, player)
  if self.prompt then
    return self.prompt:keypressed( button )
  end
  if button == 'UP' or button == 'INTERACT' then
    player.freeze = true
    local message = {'Would you like to save your game?'}
    local callback = function(result)
      if result == 'Save' then
        local gamesave = app.gamesaves:active()
        gamesave:set('savepoint', {level=self.level, name=self.name})
        gamesave:flush()
        player:refillHealth()
      end

      self.prompt = nil
      player.freeze = false
    end
    self.prompt = prompt.new(message, callback, {'Save', 'Cancel'})
  end
end

function Savepoint:show()
end

function Savepoint:draw()
  love.graphics.draw(image, self.x, self.y)
  if self.prompt then self.prompt:draw() end
end

return Savepoint


