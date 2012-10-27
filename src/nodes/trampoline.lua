local game = require 'game'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

local Trampoline = {}
Trampoline.__index = Trampoline

function Trampoline.new(node, collider)
    local tramp = {}
    setmetatable(tramp, Trampoline)
    tramp.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    tramp.node = node
    tramp.bb.node = tramp
    tramp.bval = node.properties.bval and -(tonumber(node.properties.bval)) or -1000
    tramp.dbadd = node.properties.dbadd and -(tonumber(node.properties.dbadd)) or -150
    tramp.lastBounce = tramp.bval
    tramp.blurHeight = 200
    tramp.player = nil
    tramp.originalGrav = game.gravity --original gravity value
    tramp.width = 312
    tramp.height = 144
    tramp.x = node.x
    tramp.y = node.y

    collider:setPassive(tramp.bb)

    return tramp
end

function Trampoline:collide(player, dt, mtv_x, mtv_y)
    if player.character then self.player = player end
    if player.position.y + player.height > self.node.y + self.node.height then
        sound.playSfx('jump')
        player.fall_damage = 0

        if self.double_bounce then
            player.velocity.y = self.lastBounce + self.dbadd
        else
            player.velocity.y = self.bval
        end
        self.lastBounce = player.velocity.y
    end
end

function Trampoline:update(dt)
    if not self.player then return end
    local player = self.player

    if player.position.y < 0 then
        --transition
        game.gravity = self.originalGrav
        Gamestate.switch('greendale-exterior')
    elseif player.position.y < self.blurHeight then
        player.blur = true
        player.velocity.y = -100
        game.gravity = self.originalGrav/10
    else
        game.gravity = self.originalGrav
        player.blur = false
    end
end

function Trampoline:keypressed( button )
    if button == 'B' then
        self.double_bounce = true
    end
end

function Trampoline:collide_end()
    self.bounced = false
    self.double_bounce = false
end

return Trampoline
