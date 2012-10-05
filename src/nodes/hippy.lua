local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local gs = require 'vendor/gamestate'

local Hippie = {}
Hippie.__index = Hippie

local sprite = love.graphics.newImage('images/hippy.png')
sprite:setFilter('nearest', 'nearest')

local g = anim8.newGrid(48, 48, sprite:getWidth(), sprite:getHeight())

local splatters = love.graphics.newImage('images/splatters.png')
local splatterSize = {width=300,height=250}
local splattersAvail = splatters:getWidth() / splatterSize.width

function Hippie.new(node, collider)
    local hippie = {}

    setmetatable(hippie, Hippie)
    hippie.collider = collider
    hippie.dead = false
    hippie.width = 48
    hippie.height = 48
    hippie.damage = 1

    hippie.position = {x=node.x, y=node.y}
    hippie.velocity = {x=0, y=0}
    hippie.state = 'crawl'      -- default animation is idle
    hippie.direction = 'left'   -- default animation faces right direction is right
    hippie.animations = {
        dying = {
            right = anim8.newAnimation('once', g('5,2'), 1),
            left = anim8.newAnimation('once', g('5,1'), 1)
        },
        crawl = {
            right = anim8.newAnimation('loop', g('3-4,2'), 0.25),
            left = anim8.newAnimation('loop', g('3-4,1'), 0.25)
        },
        attack = {
            right = anim8.newAnimation('loop', g('1-2,2'), 0.25),
            left = anim8.newAnimation('loop', g('1-2,1'), 0.25)
        }
    }

    hippie.bb = collider:addRectangle(node.x, node.y,30,25)
    hippie.bb.node = hippie
    collider:setPassive(hippie.bb)

    hippie.splatterIdx = math.random( splattersAvail )
    hippie.splatterFlipX = math.random( 2 ) == 1
    hippie.splatterFlipY = math.random( 2 ) == 1

    return hippie
end

function Hippie:enter()
    -- get coords of the first ceiling and the first floor node
    -- note: this will probably have to be refactored if we use hippies anywhere besides the hallway
    self.ceiling = gs.currentState().map.objectgroups.ceiling.objects[1]
    self.floor = gs.currentState().map.objectgroups.floor.objects[1]
    self.map_width = gs.currentState().map.width * gs.currentState().map.tilewidth

    self.stencils = {
        ceiling = function()
                love.graphics.rectangle('fill',
                                        self.ceiling.x,
                                        self.ceiling.y,
                                        self.map_width,
                                        self.ceiling.height )
            end,
        wall = function()
                love.graphics.rectangle('fill',
                                        self.ceiling.x,
                                        self.ceiling.y + self.ceiling.height,
                                        self.map_width,
                                        self.floor.y - ( self.ceiling.y + self.ceiling.height ) )
            end,
        floor = function()
                love.graphics.rectangle('fill',
                                        self.floor.x,
                                        self.floor.y,
                                        self.map_width,
                                        self.floor.height )
            end
    }
end

function Hippie:animation()
    return self.animations[self.state][self.direction]
end

function Hippie:hit()
    self.state = 'attack'
    Timer.add(1, function() 
        if self.state ~= 'dying' then self.state = 'crawl' end
    end)
end

function Hippie:die()
    sound.playSfx( "hippie_kill" )
    self.state = 'dying'
    self.collider:setGhost(self.bb)
    Timer.add(.75, function() self.dead = true end)
end

function Hippie:collide(player, dt, mtv_x, mtv_y)
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


function Hippie:update(dt, player)
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' or self.state == 'attack' then
        return
    end


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

    self.bb:moveTo(self.position.x + self.width / 2,
    self.position.y + self.height / 2 + 10)
end

function Hippie:draw()
    if self.dead or self.state == 'dying' then
        self:draw_splatter()
        return
    end

    self:animation():draw(sprite, math.floor(self.position.x),
    math.floor(self.position.y))
end

function Hippie:draw_splatter()

    love.graphics.setColor(255,255,255)

    love.graphics.setStencil( self.stencils.wall )
    love.graphics.drawq( splatters,
                         love.graphics.newQuad( splatterSize.width * ( self.splatterIdx - 1), 0, splatterSize.width, splatterSize.height, splatters:getWidth(), splatters:getHeight() ),
                         ( self.position.x + self.width / 2 ) - splatterSize.width / 2 + ( self.splatterFlipX and splatterSize.width or 0 ),
                         ( self.position.y + self.height / 2 ) - splatterSize.height / 2 + ( self.splatterFlipY and splatterSize.height or 0 ),
                         0,
                         self.splatterFlipX and -1 or 1,
                         self.splatterFlipY and -1 or 1 )

    love.graphics.setColor(200,200,200)  -- Giving darker shade to splash on ceiling and floor

    love.graphics.setStencil( self.stencils.floor )
    love.graphics.drawq( splatters,
                         love.graphics.newQuad( splatterSize.width * ( self.splatterIdx - 1), 0, splatterSize.width, splatterSize.height, splatters:getWidth(), splatters:getHeight() ),
                         ( self.position.x + self.width / 2 ) - splatterSize.width / 2 + ( self.splatterFlipX and splatterSize.width or 0 ),
                         ( self.position.y + self.height / 2 ) - splatterSize.height / 2 + ( self.splatterFlipY and splatterSize.height or 0 ),
                         0,
                         self.splatterFlipX and -1 or 1,
                         self.splatterFlipY and -1 or 1,
                         -splatterSize.width / 2 + ( self.splatterFlipY and 51 or 0 ), 0,
                         -1, 0 )

    love.graphics.setStencil( self.stencils.ceiling )
    love.graphics.drawq( splatters,
                         love.graphics.newQuad( splatterSize.width * ( self.splatterIdx - 1), 0, splatterSize.width, splatterSize.height, splatters:getWidth(), splatters:getHeight() ),
                         ( self.position.x + self.width / 2 ) - splatterSize.width / 2 + ( self.splatterFlipX and splatterSize.width or 0 ),
                         ( self.position.y + self.height / 2 ) - splatterSize.height / 2 + ( self.splatterFlipY and splatterSize.height or 0 ),
                         0,
                         self.splatterFlipX and -1 or 1,
                         self.splatterFlipY and -1 or 1,
                         splatterSize.width / 2 - ( self.splatterFlipY and 51 or 0 ), 0,
                         1, 0 )

    love.graphics.setColor(255,255,255)
    love.graphics.setStencil()

end

return Hippie
