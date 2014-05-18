local anim8 = require 'vendor/anim8'
local player = require 'player'
local utils = require 'utils'
local sound = require 'vendor/TEsound'
local window = require 'window'

local Vehicle = {}
Vehicle.__index = Vehicle
Vehicle.isVehicle = true

function Vehicle.new(node, collider)
  local vehicle = {}
  setmetatable(vehicle, Vehicle)

  local name= node.name

  vehicle.type = 'vehicle'
  vehicle.name = name
  vehicle.props = utils.require('nodes/vehicles/' .. name)

  vehicle.hasAttack = vehicle.props.hasAttack or false

  vehicle.width = vehicle.props.width or node.width
  vehicle.height = vehicle.props.height or node.height

  vehicle.image = love.graphics.newImage('images/vehicles/'..name..'.png')
  local g = anim8.newGrid(vehicle.width,vehicle.height,vehicle.image:getWidth(),vehicle.image:getHeight())

  local moveAnim= vehicle.props.move

  vehicle.idle = anim8.newAnimation('once',g(1,1),1)
  vehicle.move = anim8.newAnimation(moveAnim[1],g(unpack(moveAnim[2])),moveAnim[3])

  if vehicle.hasAttack then
    local attackAnim = vehicle.props.attack
    vehicle.attack = anim8.newAnimation(attackAnim[1],g(unpack(attackAnim[2])),attackAnim[3])
  end
	
	local Player = player.factory()
	vehicle.characterImage = love.graphics.newImage('images/characters/'..Player.character.name..'/'..Player.character.costume..'.png')
  vehicle.mask = love.graphics.newQuad(0, 48, 48, 48, 
	                   vehicle.characterImage:getWidth(), vehicle.characterImage:getHeight())

  vehicle.xOffset = vehicle.props.xOffset or 0
  vehicle.yOffset = vehicle.props.yOffset - Player.character.offset

  local yPosition = node.y - vehicle.height + 24

  vehicle.bb = collider:addRectangle(node.x, yPosition, vehicle.width, vehicle.height)
  vehicle.bb.node = vehicle
  vehicle.collider = collider
  vehicle.collider:setPassive(vehicle.bb)


  vehicle.position = { x = node.x, y = yPosition}
  vehicle.flip = false

  vehicle.driven = false
  vehicle.moving = false
  vehicle.attacking = false

  return vehicle

end

function Vehicle:draw()

  if self.driven then
    love.graphics.draw(self.characterImage, self.mask, 
      self.flip and (self.position.x + self.width - self.xOffset) or (self.position.x + self.xOffset), 
      self.position.y + self.yOffset, 0, self.flip and -1 or 1, 1)
end

  if self.moving then
    self.move:draw(self.image, self.position.x, self.position.y, 0, self.flip and -1 or 1, 1, self.flip and self.width or 0)
  elseif self.attacking then
    self.attack:draw(self.image, self.position.x, self.position.y, 0, self.flip and -1 or 1, 1, self.flip and self.width or 0)
  else
    self.idle:draw(self.image, self.position.x, self.position.y, 0, self.flip and -1 or 1, 1, self.flip and self.width or 0)
  end

end

function Vehicle:keypressed( button, player )

  if self.driven then
    if button == "LEFT" or button == "RIGHT" then
      self.moving = true
      self.flip = (button == "LEFT") and true or false
      return
    end
  end

  self.moving = false

-- stuff only turns off with a keypress

end

function Vehicle:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        node:registerHoldable(self)
    end
end

function Vehicle:collide_end(node, dt)
    if node.isPlayer then
        node:cancelHoldable(self)
    end
end

function Vehicle:pickup(player)
    self.driven = true
end

function Vehicle:drop(player)
    self.driven = false
    player:cancelHoldable(self)
end

function Vehicle:update(dt,player)

  if self.driven then

    if self.moving then
	    self.move:update(dt)
    end

    self.position = { x = player.position.x + (player.width - self.width)/2, y = player.position.y + player.height - self.height}
    self:moveBoundingBox()
    return
  end

end

function Vehicle:moveBoundingBox()
  if not self.bb then return end
  self.bb:moveTo(self.position.x + self.width / 2, self.position.y + (self.height / 2) + 2)
end

return Vehicle
