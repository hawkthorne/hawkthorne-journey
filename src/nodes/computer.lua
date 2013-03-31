local anim8 = require 'vendor/anim8'
local game = require 'game'

local Computer = {}
Computer.__index = Computer

local computerImage = love.graphics.newImage('images/computer.png')
local g = anim8.newGrid(38, 38, computerImage:getWidth(), computerImage:getHeight())

function Computer.new(node, collider)
    local computer = {}

    setmetatable(computer, Computer)
    
    computer.node = node
    
    computer.position = {x = node.x, y = node.y}
    computer.width = node.width
    computer.height = node.height
    
    computer.collider = collider
    computer.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    computer.bb.node = computer
    computer.collider:setPassive(computer.bb)
    computer.velocity = { x=0, y=0 }
    
    computer.broke = false
    
    computer.unbroken = anim8.newAnimation('once', g('1,1'), 1)
    computer.broken = anim8.newAnimation('once', g('2,1'), 1)
    
    return computer
end

function Computer:draw()
    if not self.broke then
        self.unbroken:draw(computerImage, self.position.x, self.position.y)
    else
        self.broken:draw(computerImage, self.position.x, self.position.y)
    end
end

function Computer:collide(node, dt, mtv_x, mtv_y)
end

function Computer:collide_end(node, dt)
end

function Computer:update(dt)

    
    self:draw()
    self.velocity.y = self.velocity.y + game.gravity * dt / 2
    self.position.y = self.position.y + self.velocity.y * dt
    self:moveBoundingBox()
    
end

function Computer:moveBoundingBox()
    local x1,y1,x2,y2 = self.bb:bbox()
    self.bb:moveTo( self.position.x + (x2-x1)/2,
                 self.position.y + (y2-y1)/2)
end

function Computer:floor_pushback(node, new_y)
        self.position.y = new_y
        self.velocity.y = 0
        self:moveBoundingBox()
        self.broke = true
end

return Computer
