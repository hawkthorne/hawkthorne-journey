local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local Sprite = require 'nodes/sprite'
local Timer = require 'vendor/timer'

local PlayerAttack = {}
PlayerAttack.__index = PlayerAttack
PlayerAttack.playerAttack = true

---
-- Create a new Player
-- @param collider
-- @return Player
function PlayerAttack.new(collider,plyr)

    local attack = {}

    setmetatable(attack, PlayerAttack)

    attack.width = 18
    attack.height = 18
    attack.radius = 10
    attack.collider = collider
    attack.bb = collider:addRectangle(0,0,attack.width,attack.height)
    attack.bb.node = attack
    attack.damage = 1
    attack.player = plyr
    attack:deactivate()

    return attack
end

function PlayerAttack:update()
    local player = self.player
    if player.character.direction=='right' then
        self.bb:moveTo(player.position.x + 24 + 20, player.position.y+28)
    else
        self.bb:moveTo(player.position.x + 24 - 20, player.position.y+28)
    end
end

function PlayerAttack:collide(node, dt, mtv_x, mtv_y)
    if not node then return end
    if self.dead then return end

    --implement hug button action
    if node.isPlayer then return end

    local tlx,tly,brx,bry = self.bb:bbox()
    local attackNode = { x = tlx, y = tly,
                        properties = {
                            sheet = 'images/attack.png',
                            height = 20, width = 20,
                          }
                        }
    if node.hurt then
        sound.playSfx('punch')
        local attackSprite = Sprite.new(attackNode, collider)
        attackSprite.containerLevel = Gamestate.currentState()
        attackSprite.containerLevel:addNode(attackSprite)
        Timer.add(0.1,function ()
            attackSprite.containerLevel:removeNode(attackSprite)
        end)
        node:hurt(self.damage)
        self:deactivate()
    end
end

function PlayerAttack:activate()
    self.dead = false
    self.collider:setSolid(self.bb)
end

function PlayerAttack:deactivate()
    self.dead = true
    self.collider:setGhost(self.bb)
end

return PlayerAttack
