local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local TunnelParticles = require "tunnelparticles"
local flyin = Gamestate.new()
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Character = require 'character'

function flyin:init( )
    TunnelParticles:init()
end

function flyin:enter( prev )
    self.flying = {}
    self.characterorder = {}
    for i,c in pairs(Character.characters) do
        if c.name ~= Character.name then
            table.insert(self.characterorder, c.name)
        end
    end
    self.characterorder = table.shuffle( self.characterorder, 5 )
    table.insert( self.characterorder, Character.name )
    local time = 0
    for _,name in pairs( self.characterorder ) do
        Timer.add(time, function()
            table.insert( self.flying, {
                n = name,
                c = name == Character.name and Character.costume or Character:findRelatedCostume(name),
                x = window.width / 2,
                y = window.height / 2,
                t = math.random( ( math.pi * 2 ) * 10000 ) / 10000,
                r = n == Character.name and 0 or ( math.random( 4 ) - 1 ) * ( math.pi / 2 ),
                s = 0.1,
                show = true
            })
        end)
        time = time + 0.4
    end
end

function flyin:draw()
    TunnelParticles.draw()
    
    love.graphics.circle( 'fill', window.width / 2, window.height / 2, 30 )
    
    --draw in reverse order, so the older ones get drawn on top of the newer ones
    for i = #flyin.flying, 1, -1 do
        local v = flyin.flying[i]
        if v.show then
            love.graphics.setColor( 255, 255, 255, 255 )
            Character.characters[v.n].animations.flyin:draw( Character:getSheet(v.n,v.c), v.x, v.y, v.r - ( v.r % ( math.pi / 2 ) ), math.min(v.s,5), math.min(v.s,5), 22, 32 )
            -- black mask while coming out of 'tunnel'
            if v.s <= 1 then
                love.graphics.setColor( 0, 0, 0, 255 * ( 1 - v.s ) )
                Character.characters[v.n].animations.flyin:draw( Character:getSheet(v.n,v.c), v.x, v.y, v.r - ( v.r % ( math.pi / 2 ) ), math.min(v.s,5), math.min(v.s,5), 22, 32 )
            end
        end
    end
end

function flyin:startGame(dt)
  local gamesave = app.gamesaves:active()
  local point = gamesave:get('savepoint', {level='studyroom', name='bookshelf'})
  Gamestate.switch(point.level, point.name)
end

function flyin:keypressed(button)
    Timer.clear()
    self:startGame()
end

function flyin:update(dt)
    TunnelParticles.update(dt)
    for k,v in pairs(flyin.flying) do
        if v.n ~= Character.name then
            v.x = v.x + ( math.cos( v.t ) * dt * v.s * 90 )
            v.y = v.y + ( math.sin( v.t ) * dt * v.s * 90 )
        end
        v.s = v.s + dt * 4
        v.r = v.r + dt * 5
        if v.s >= 6 then
            v.show = false
        end
    end
    if not flyin.flying[ #flyin.flying ].show then
        Timer.clear()
        self:startGame()
    end
end

return flyin
