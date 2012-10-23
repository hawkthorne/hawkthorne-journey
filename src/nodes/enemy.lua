--a generic enemy node. to use it in a map, insert an enemy node with the property "name" for the enemy name. a file with the enemy name is neseccary for animation, movement pattern and additional properties.
local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
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
	enemy.node_properties = node.properties
	enemy.node = node
	enemy.collider = collider
	enemy.dead = false
	enemy.width = 48
    enemy.height = 48
    if properties.damage then enemy.damage = properties.damage
    else enemy.damage = 1 end
    if properties.speed then enemy.speed = properties.speed
    else enemy.speed = 1 end
    if node.properties.floor then enemy.floor = node.properties.floor
    else enemy.floor = node.y end
    if properties.hp then enemy.hp = properties.hp
    else enemy.hp = 1 end
    enemy.dropspeed = 600
    
    
	enemy.position = {x=node.x, y=node.y}
	enemy.velocity = {x=0, y=0}
	enemy.state = 'default'
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
    if self.animations['attack'] then self.state = 'attack' --some enemies won't have an attack animation
    Timer.add(1, function() 
        if self.state ~= 'dying' then self.state = 'default' end
    end) end
end

function Enemy:die(damage)
    if properties.die_sound then sound.playSfx( properties.die_sound ) end
    if not damage then damage = 1 end
    self.state = 'dying'
    self.hp = self.hp - damage
    if self.hp < 1 then
    	self.collider:setGhost(self.bb)
    	Timer.add(.75, function() self.dead = true end)
    	if reviveTimer then Timer.cancel(reviveTimer) end
    	if properties.makeLoot then self.loot = properties.makeLoot(self.position.x, self.position.y, self.width, self.height, self.collider) end
    else
    	reviveTimer = Timer.add(.75, function() self.state = 'default' end)
    end
end

function Enemy:collide(player, dt, mtv_x, mtv_y)
    if player.rebounding then
        return
    end

    local a = player.position.x < self.position.x and -1 or 1
    local x1,y1,x2,y2 = self.bb:bbox()
    if player.position.y + player.height <= self.position.y + self.height and player.velocity.y > 0 then 
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
    
    if player.invulnerable or self.state == 'dying' then
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

	if properties.movement == 'follow' then
	    if self.position.x > player.position.x then
	        self.direction = 'left'
	    else
	        self.direction = 'right'
	    end
	
	    if math.abs(self.position.x - player.position.x) < 2 or self.state == 'dying' or self.state == 'attack' then
	        -- stay put
	    elseif self.direction == 'left' then
	        self.position.x = self.position.x - (self.speed * dt)
	    else
	        self.position.x = self.position.x + (self.speed * dt)
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
	if properties.movement == 'frog_jump' then
		if self.position.x > player.position.x then
     		self.direction = 'left'
   		else
        	self.direction = 'right'
    	end
    	
    	if self.state == 'default' then --default frog_jump state is lurking
    		if not self.lurkTimer then
    			if self.node_properties.count then x = self.node_properties.count / 10
    			else x = 0 end
    			self.lurkTimer = Timer.add(3-x, function()
    				self.lurkTimer = nil
    				if self.state ~= 'die' then self.state = 'emerge' end
    				end)
    		end

    	elseif self.state == 'emerge' then
			if not self.emergeTimer then
    			self.emergeTimer = Timer.add(0.2, function()
    				self.emergeTimer = nil
    				if self.state ~= 'die' then self.state = 'leap' end
    				end)
    		end

    	elseif self.state == 'leap' then
			if self.position.y > self.floor - self.speed then
				self.position.y = self.position.y - (self.speed * dt)
			else
				if self.state ~= 'die' then self.state = 'fall' end
			end

    	elseif self.state == 'fall' then
			if self.position.y < self.floor then
				self.position.y = self.position.y + (self.speed * dt)
			else
				if self.state ~= 'die' then self.state = 'dive' end
			end

    	elseif self.state == 'dive' then
			if not self.diveTimer then
    			self.diveTimer = Timer.add(0.2, function()
    				self.diveTimer = nil
    				if self.state ~= 'die' then self.state = 'default' end
    				end)
    		end
    	end
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