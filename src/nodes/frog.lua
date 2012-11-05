local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'

local Frog = {}
Frog.__index = Frog

local sprite = love.graphics.newImage('images/frog.png')
sprite:setFilter('nearest', 'nearest')

local g = anim8.newGrid(48, 48, sprite:getWidth(), sprite:getHeight())

function Frog.new(node, collider)
    local frog = {}

    setmetatable(frog, Frog)
    frog.collider = collider
    frog.dead = false
    frog.width = 48
    frog.height = 48
    frog.damage = 1

    frog.start_y = node.y + 3
    frog.velocity = {x=0, y=0}

    frog.state = 'lurk'
    frog.position = {x=node.x, y=node.y + 3}
    frog.count = tonumber(node.properties.count)

    frog.direction = 'left'   -- default animation faces right direction is right
    frog.animations = {
        dying = {
            right = anim8.newAnimation('once', g('5-8,2'), 0.2),
            left = anim8.newAnimation('once', g('5-8,1'), 0.2)
        },
        lurk = {
            right = anim8.newAnimation('loop', g('1,2'), 1),
            left = anim8.newAnimation('loop', g('1,1'), 1)
        },
	emerge = {
            right = anim8.newAnimation('loop', g('2,2'), 1),
            left = anim8.newAnimation('loop', g('2,1'), 1)
        },
	dive = {
            right = anim8.newAnimation('loop', g('2,2'), 1),
            left = anim8.newAnimation('loop', g('2,1'), 1)
        },
	fall = {
            right = anim8.newAnimation('loop', g('4,2'), 1),
            left = anim8.newAnimation('loop', g('4,1'), 1)
        },
        leap = {
            right = anim8.newAnimation('loop', g('3,2'), 1),
            left = anim8.newAnimation('loop', g('3,1'), 1)
        }
    }

    frog.bb = collider:addRectangle(node.x, node.y, 30, 38)
    frog.bb.node = frog
    collider:setPassive(frog.bb)

    return frog
end


function Frog:animation()
    return self.animations[self.state][self.direction]
end

function Frog:die()
    sound.playSfx( 'karramba_pop' ) -- Waiting for a froggy death sound
       self.state = 'dying'
    self.collider:setGhost(self.bb)
    Timer.add(1, function() self.dead = true end)
end

function Frog:collide(node, dt, mtv_x, mtv_y)
    if not node.isPlayer then return end
    local player = node
    
    if player.rebounding then
        return
       end

    local a = player.position.x < self.position.x and -1 or 1
    local x1,y1,x2,y2 = self.bb:bbox()
    
    if player.position.y + player.height <= y2 and player.velocity.y > 0 then
        -- successful attack
        self:die()
           if cheat.jump_high then
            player.velocity.y = -670
        else
            player.velocity.y = -450
        end
        return
    end

    if cheat.god then
        self:die()
        return
    end

    if player.invulnerable then
        return
    end

    player:die(self.damage)
    player.bb:move(mtv_x, mtv_y)
    if player.quicksand then
	player.velocity.y = -150
    else
	player.velocity.y = -450
    end
    player.velocity.x = 300 * a
end


function Frog:update(dt, player)
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' then
        return
    end


    if self.position.x > player.position.x then
        self.direction = 'left'
    else
        self.direction = 'right'
    end

    if self.state == 'lurk' then
	if self.count < 30 then
		self.count = self.count + (10 * dt)
	else
		self.count = 0
		self.state = 'emerge'
	end


    elseif self.state == 'emerge' then
	if self.count < 2 then
		self.count = self.count + (10 * dt)
	else
		self.count = 0
		self.state = 'leap'
	end

    elseif self.state == 'leap' then
	if self.position.y > self.start_y - 100 then
		self.position.y = self.position.y - (100 * dt)
	else
		self.state = 'fall'
	end


    elseif self.state == 'fall' then
	if self.position.y < self.start_y then
		self.position.y = self.position.y + (100 * dt)
	else
		self.state = 'dive'
	end


    elseif self.state == 'dive' then
	if self.count < 2 then
		self.count = self.count + (10 * dt)
	else
		self.count = 0
		self.state = 'lurk'
	end
    end

    self.bb:moveTo(self.position.x + self.width / 2,
    self.position.y + self.height / 2 + 10)
end

function Frog:draw()
    if self.dead then
        return
    end

    self:animation():draw(sprite, math.floor(self.position.x),
    math.floor(self.position.y))
end

return Frog
