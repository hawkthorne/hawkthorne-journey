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

    attack.width = 5
    attack.height = 5
    attack.radius = 10
    attack.collider = collider
    --attack.bb = collider:addRectangle(plyr.position.x,plyr.position.y+28,attack.width,attack.height)
    attack.bb = collider:addCircle(plyr.position.x+attack.width/2,(plyr.position.y+28)+attack.height/2,attack.width,attack.radius)
    attack.bb.node = attack
    attack.damage = 4
    attack.player = plyr

    return attack
end

function PlayerAttack:collide_end(node, dt)
end

function PlayerAttack:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
        --implement hug button action

    if not node then return end

    if node.die then
        node:die(self.damage)
        self.dead = true
        self.collider:setPassive(self.bb)
        self.player:setSpriteStates("default")
    end
    if node.isSolid then
        self.dead = true
    end
end

return PlayerAttack