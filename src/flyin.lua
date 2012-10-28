local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local TunnelParticles = require "tunnelparticles"
local flyin = Gamestate.new()
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'

function flyin:init( )
    TunnelParticles:init()
end

function flyin:enter( prev, character )
    self.character = character
    self.flying = {}
    self.players = love.filesystem.enumerate( 'characters' )
    for i,p in pairs(self.players) do
        if self.character.name == p:gsub('.lua', '') then
            table.remove( self.players, i )
            break
        end
    end
    table.insert( self.players, self.character.name .. '.lua' )
    local time = 0
    for i,c in pairs( self.players ) do
        local plyr = require( 'characters/' .. c:gsub('.lua', '') )
        local sheet = love.graphics.newImage('images/characters/' .. plyr.name .. '/base.png')
        self.players[i] = plyr.new( sheet )
        Timer.add(time, function()
            table.insert( self.flying, {
                i = i,
                x = window.width / 2,
                y = window.height / 2,
                t = math.random( ( math.pi * 2 ) * 10000 ) / 10000,
                r = i == #self.players and 0 or ( math.random( 4 ) - 1 ) * ( math.pi / 2 ),
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
            self.players[v.i].animations.flyin:draw( self.players[v.i].sheet, v.x, v.y, v.r - ( v.r % ( math.pi / 2 ) ), math.min(v.s,5), math.min(v.s,5), 22, 32 )
        end
    end
end

function flyin:keypressed(button)
    Timer.clear()
    Gamestate.switch( 'overworld', self.character )
end

function flyin:update(dt)
    Timer.update(dt)
    TunnelParticles.update(dt)
    for k,v in pairs(flyin.flying) do
        if self.players[v.i].name ~= self.character.name then
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
        Gamestate.switch( 'overworld', self.character )
    end
end

return flyin
