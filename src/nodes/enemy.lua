------------------------------
-- Generic enemy node
-- Written by G3nius
-- Refactor by jhoff
--
-- Add a node to the .tmx of 'type' == 'enemy'
--    with an 'enemytype' property set to the type of enemy ( I.E. 'hippy' / 'frog' / etc )
-- You must create a src/nodes/enemies file to define unique
--    animation frames, movement function and additional properties.
------------------------------

local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local token = require 'nodes/token'
local game = require 'game'
local ach = (require 'achievements').new()

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(node, collider, enemytype)
    local enemy = {}
    setmetatable(enemy, Enemy)
    
    local type = node.properties.enemytype or enemytype
    
    enemy.type = type
    
    enemy.props = require( 'nodes/enemies/' .. type )
    
    enemy.sprite = love.graphics.newImage( 'images/enemies/' .. type .. '.png' )
    enemy.sprite:setFilter('nearest', 'nearest')
    
    enemy.grid = anim8.newGrid( enemy.props.width, enemy.props.height, enemy.sprite:getWidth(), enemy.sprite:getHeight() )
    
    enemy.node_properties = node.properties
    enemy.node = node
    enemy.collider = collider
    
    enemy.dead = false
    
    assert( enemy.props.damage, "You must provide a 'damage' value for " .. type )

    assert( enemy.props.hp, "You must provide a 'hp' ( hit point ) value for " .. type )
    enemy.hp = enemy.props.hp
    
    enemy.position_offset = enemy.props.position_offset or {x=0,y=0}
    
    enemy.position = {
        x = node.x + ( enemy.position_offset.x or 0),
        y = node.y + ( enemy.position_offset.y or 0)
    }
    enemy.height = enemy.props.height
    enemy.width = enemy.props.width
    enemy.velocity = enemy.props.velocity or {x=0,y=0}
    
    enemy.jumpkill = enemy.props.jumpkill
    if enemy.jumpkill == nil then enemy.jumpkill = true end
    
    enemy.dyingdelay = enemy.props.dyingdelay and enemy.props.dyingdelay or 0.75
    enemy.revivedelay = enemy.props.revivedelay and enemy.props.revivedelay or .5
    
    enemy.state = 'default'
    enemy.direction = 'left'
    
    enemy.animations = {}
    
    for state, data in pairs( enemy.props.animations ) do
        enemy.animations[state] = {}
        for dir, a in pairs( data ) do
            enemy.animations[ state ][ dir ] = anim8.newAnimation( a[1], enemy.grid( unpack(a[2]) ), a[3])
        end
    end
    
    enemy.bb = collider:addRectangle( node.x, node.y, enemy.props.bb_width or enemy.props.width, enemy.props.bb_height or enemy.props.height )
    enemy.bb.node = enemy

    enemy.bb_offset = enemy.props.bb_offset or {x=0,y=0}
    
    enemy.tokens = {} --the tokens the enemy drops when killed
    
    return enemy
end

function Enemy:enter()
    if self.props.enter then
        self.props.enter(self)
    end
end

function Enemy:animation()
    return self.animations[self.state][self.direction]
end

function Enemy:hurt( damage )
    if self.props.die_sound then sound.playSfx( self.props.die_sound ) end
    if not damage then damage = 1 end
    self.state = 'dying'
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.collider:remove(self.bb)
        Timer.add( self.dyingdelay, function() self.dead = true end )
        if self.reviveTimer then Timer.cancel( self.reviveTimer ) end
        ach:achieve( self.type .. ' killed by player' )
        self:dropTokens()
        if self.props.die then self.props.die( self ) end
    else
        self.reviveTimer = Timer.add( self.revivedelay, function() self.state = 'default' end )
        if self.props.hurt then self.props.hurt( self ) end
    end
end

function Enemy:dropTokens()
    if not self.props.tokens or self.props.tokens == 0 then return end
    
    for i=1, self.props.tokens do
        local r = math.random(100) / 100
        for _,d in pairs( self.props.tokenTypes ) do
            if r < d.p then
                table.insert(
                    self.tokens,
                    token.new(
                        d.item,
                        self.position.x + self.props.width / 2,
                        self.position.y + self.props.height,
                        self.collider,
                        d.v
                    )
                )
                break
            end
        end
    end
end

function Enemy:collide(player, dt, mtv_x, mtv_y)
	if not player.isPlayer then return end
    if player.rebounding or player.dead then
        return
    end
    
    if not player.current_enemy then
         player.current_enemy = self
     end
    
    if player.current_enemy ~= self then return end
    
    local _, _, _, playerBottom = player.bb:bbox()
    local _, enemyTop, _, y2 = self.bb:bbox()
    local headsize = (y2 - enemyTop) / 2

    if playerBottom >= enemyTop and (playerBottom - enemyTop) < headsize
        and player.velocity.y > self.velocity.y and self.jumpkill then
        -- successful attack
        self:hurt(1)
        if cheat.jump_high then
            player.velocity.y = -670
        else
            player.velocity.y = -450
        end
        return
    end

    if cheat.god then
        self:hurt(self.hp)
        return
    end
    
    if player.invulnerable or self.state == 'dying' then
        return
    end

    -- attack
    if self.props.attack_sound then sound.playSfx( self.props.attack_sound ) end
    
    if self.props.attack then
        self.props.attack(self)
    elseif self.animations['attack'] then
        self.state = 'attack'
        Timer.add( 1,
            function() 
                if self.state ~= 'dying' then self.state = 'default' end
            end
        )
    end

    player:die(self.props.damage)
    player.bb:move(mtv_x, mtv_y)
    player.velocity.y = -450
    player.velocity.x = 300 * ( player.position.x < self.position.x and -1 or 1 )

end

function Enemy:collide_end( node )
    if node and node.isPlayer and node.current_enemy == self then
        node.current_enemy = nil
    end
end

function Enemy:update( dt, player )
    for _,c in pairs(self.tokens) do
        c:update(dt)
    end
    
    if self.dead then
        return
    end

    self:animation():update(dt)
    if self.state == 'dying' then
        if self.props.dyingupdate then
            self.props.dyingupdate( dt, self )
        end
        return
    end
    
    if self.props.update then
        self.props.update( dt, self, player )
    end
    
    if not self.props.antigravity then
        -- Gravity
        self.velocity.y = self.velocity.y + game.gravity * dt
        if self.velocity.y > game.max_y then
            self.velocity.y = game.max_y
        end
    
        self.position.x = self.position.x - (self.velocity.x * dt)
        self.position.y = self.position.y + (self.velocity.y * dt)
    end
    
    self:moveBoundingBox()
end

function Enemy:draw()
    if not self.dead then
        self:animation():draw( self.sprite, math.floor( self.position.x ), math.floor( self.position.y ) )
    end
    
    if self.props.draw then
        self.props.draw(self)
    end
    
    for _,c in pairs(self.tokens) do
        c:draw()
    end
end

function Enemy:ceiling_pushback(node, new_y)
    if self.props.ceiling_pushback then
        self.props.ceiling_pushback(self,node,new_y)
    end
end

function Enemy:floor_pushback(node, new_y)
    if self.props.floor_pushback then
        self.props.floor_pushback(self,node,new_y)
    else
        self.position.y = new_y
        self.velocity.y = 0
        self:moveBoundingBox()
    end
end

function Enemy:wall_pushback(node, new_x)
    if self.props.wall_pushback then
        self.props.wall_pushback(self,node,new_x)
    else
        self.position.x = new_x
        self.velocity.x = 0
        self:moveBoundingBox()
    end
end

function Enemy:moveBoundingBox()
    self.bb:moveTo( self.position.x + ( self.props.width / 2 ) + self.bb_offset.x,
                    self.position.y + ( self.props.height / 2 ) + self.bb_offset.y )
end

return Enemy
