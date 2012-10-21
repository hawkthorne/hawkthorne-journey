local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local splat = require 'nodes/splat'
local properties

local Enemy = {}
Enemy.__index = Enemy

local sprite = "not loaded"
local g

function Enemy.new(node, collider)
	local enemy = {}
	local name = node.properties.name
	setmetatable(enemy, Enemy)
	
	properties = require ('nodes/' .. name)
	sprite = love.graphics.newImage('images/' .. name .. '.png.')
	sprite:setFilter('nearest', 'nearest')
	g = anim8.newGrid(48, 48, sprite:getWidth(), sprite:getHeight())
	enemy.node = node
	enemy.collider = collider
	enemy.dead = false
	enemy.width = 48
    enemy.height = 48
    enemy.damage = 1
    enemy.floor = node.properties.floor
    enemy.dropspeed = 600
    
    
	enemy.position = {x=node.x, y=node.y}
	enemy.velocity = {x=0, y=0}
	enemy.state = 'movement'
	enemy.direction = 'left'
	enemy.animations = properties.setAnimations(g)
	enemy.bb = collider:addRectangle(node.x, node.y, 30, 38)
	enemy.bb.node = enemy
	collider:setPassive(enemy.bb)
	
	enemy.loot = {} --the loot the enemy drops when killed
	
	return enemy
end

function Enemy:animation()
    return self.animations[self.state][self.direction]
end

function Enemy:hit()
    self.state = 'attack'
    Timer.add(1, function() 
        if self.state ~= 'dying' then self.state = 'movement' end
    end)
end

function Enemy:die()
    sound.playSfx( properties.sound )
    self.state = 'dying'
    self.collider:setGhost(self.bb)
    Timer.add(.75, function() self.dead = true end)
    self.splat = splat:add(self.position.x, self.position.y, self.width, self.height)
    self.loot = properties.makeLoot(self.position.x + self.width / 2, self.position.y + self.height, self.collider)
end

function Enemy:collide(player, dt, mtv_x, mtv_y)
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
    
    self:hit()

    player:die(self.damage)
    player.bb:move(mtv_x, mtv_y)
    player.velocity.y = -450
    player.velocity.x = 300 * a
end

function Enemy:update(dt, player)
    for _,c in pairs(self.loot) do
        c:update(dt)
    end
    
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' or self.state == 'attack' then
        return
    end

	if properties.movement == 'follow' then
	    if self.position.x > player.position.x then
	        self.direction = 'left'
	    else
	        self.direction = 'right'
	    end
	
	    if math.abs(self.position.x - player.position.x) < 2 then
	        -- stay put
	    elseif self.direction == 'left' then
	        self.position.x = self.position.x - (10 * dt)
	    else
	        self.position.x = self.position.x + (10 * dt)
	    end
		if self.floor then
		if self.position.y < self.floor then
        	self.position.y = self.position.y + dt * self.dropspeed
    	else
       		self.position.y = self.floor
    	end end
    	
	    self.bb:moveTo(self.position.x + self.width / 2,
	    self.position.y + self.height / 2 + 10)
	end
end

function Enemy:draw()
    if not self.dead then
        self:animation():draw( sprite, math.floor( self.position.x ), math.floor( self.position.y ) )
    end

    for _,c in pairs(self.loot) do
        c:draw()
    end
end

return Enemy