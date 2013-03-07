local tween = require 'vendor/tween'

local Projectile = require "nodes/projectile"
local Sprite = require "nodes/sprite"
local camera = require "camera"

local Script =  {}
Script.__index = Script
Script.isScript = true
function Script.new(scene,player,level)
    assert(scene)
    assert(player)
    assert(player.isPlayer)
    assert(level)
    --assert(level.isLevel,level.name or '<nil>'.." may be a gamestate, but not a bona fide level")
    script = {{line = "Pierce: Oh crap. It's Buddy!",
    precondition = function()
        scene.nodes.britta.opacity = 0
        scene.nodes.britta.invulnerable = true
        scene:teleportCharacter(750,nil,scene.nodes.britta)
    end,
    action = function()
        player.character.direction = 'left'
        scene.nodes.pierce.desireDirection = 'left'
        scene:moveCharacter(900,nil,scene.nodes.abed)
        scene:moveCharacter(850,nil,scene.nodes.pierce)
        scene:moveCharacter(920,nil,scene.nodes.shirley)
        scene:moveCharacter(900,nil,scene.nodes.troy)
        scene:moveCharacter(800,nil,scene.nodes.annie)
        scene:moveCharacter(620,nil,scene.nodes.jeff)
        scene:moveCharacter(600,nil,scene.nodes.buddy)
    end},

    {line = "Pierce: Well, well, well. Looks like someone's one step behind",
    precondition = function()
        scene:teleportCharacter(900,nil,scene.nodes.abed)
        scene:teleportCharacter(850,nil,scene.nodes.pierce)
        scene:teleportCharacter(920,nil,scene.nodes.shirley)
        scene:teleportCharacter(900,nil,scene.nodes.troy)
        scene:teleportCharacter(800,nil,scene.nodes.annie)
        scene:teleportCharacter(620,nil,scene.nodes.jeff)
        scene:teleportCharacter(600,nil,scene.nodes.buddy)
    end,
    action = function ()
        scene:moveCharacter(840,nil,scene.nodes.pierce)
        scene:moveCharacter(900,nil,scene.nodes.shirley)
        scene.nodes.pierce.desireDirection = 'left'
    end},

    {line = "Buddy: While you were shopping I gained enough levels to do this... ",
    precondition = function()
        scene:teleportCharacter(840,nil,scene.nodes.pierce)
        scene:teleportCharacter(900,nil,scene.nodes.shirley)
    end,
    action = function ()
        --scene:moveCharacter(840,nil,scene.nodes.pierce)
        scene:jumpCharacter(scene.nodes.buddy)
        scene:moveCharacter(1000,nil,scene.nodes.pierce)
        -- make buddy do his level attavk
        scene:actionCharacter("attack",scene.nodes.buddy)
        -- generate a lightning bolt
        local node = require('nodes/projectiles/lightning')
        node.x = scene.nodes.buddy.position.x
        node.y = scene.nodes.buddy.position.y
        local lightning = Projectile.new(node, level.collider)
        lightning:throw(scene.nodes.buddy)
        table.insert(level.nodes, lightning)
    end},

    {line = "Troy: he's throwing lightning",
    precondition = function()
        scene:teleportCharacter(1000,nil,scene.nodes.pierce)
    end,
    action = function ()
        --make pierce duck
        scene:keypressedCharacter('DOWN',scene.nodes.pierce)
        --make britta visible
        tween(2, scene.nodes.britta, {opacity=255}, 'outQuad',
            function()
                scene.nodes.britta.invulnerable = false
            end
        )

    end},

    {line = "Troy: ...and I'm naked.",
   action = function ()
        scene:moveCharacter(670,nil,scene.nodes.buddy)
        scene.nodes.shirley.opacity = 255
        tween(2, scene.nodes.shirley, {opacity=0}, 'outQuad')
        --TODO: add potion sprite
    end},

    {line = "Jeff: Britta, drink that super strength potion "..
        (player.character.name=='britta' and 'you' or 
        player.character.name=='jeff' and 'I' or 
        player.character.name)
        .." made.",
    precondition = function()
        scene:teleportCharacter(670,nil,scene.nodes.buddy)
    end,
    action = function()
        scene:trackCharacter("britta")
        --scene:trackCharacter("jeff9)
        scene:moveCharacter(660,nil,scene.nodes.buddy)
        scene:moveCharacter(400,nil,scene.nodes.britta)
    end},

    {line = "Britta: Right, right, right",
    precondition = function()
        scene:teleportCharacter(660,nil,scene.nodes.buddy)
        scene:teleportCharacter(400,nil,scene.nodes.britta)
        scene.nodes.buddy.character.direction = 'left'
    end,
    action = function()
        --generate a potion sprite(not technically functional)
        local node = { x = scene.nodes.britta.position.x, y = scene.nodes.britta.position.y,
                        properties = {
                            sheet = 'images/potion.png',
                            height = 24, width = 24,
                          }
                        }
        local sprite = Sprite.new(node, collider)
        table.insert(level.nodes, sprite)

        --generate a rainbowbeam
        local lightNode = require('nodes/projectiles/rainbowbeam')
        lightNode.x = scene.nodes.buddy.position.x
        lightNode.y = scene.nodes.buddy.position.y
        local lightning = Projectile.new(lightNode, level.collider)
        lightning:throw(scene.nodes.buddy)
        table.insert(level.nodes, lightning)
    end},

    {line = "Jeff: I thought I could count on Britta to not screw up drinking",
    action = function()
        --scene:trackCharacter("jeff")
        scene.nodes.britta.opacity = 255
        tween(2, scene.nodes.britta, {opacity=0}, 'outQuad')
        scene:moveCharacter(400,nil,scene.nodes.buddy)
        scene:moveCharacter(550,nil,scene.nodes.troy)
    end},

    {line = "Buddy: This'll be fun.",
    precondition = function()
        --if(math.abs(400-scene.nodes.buddy.position.x)>40) then
            scene:teleportCharacter(400,nil,scene.nodes.buddy)
        --end
    end,
    action = function()
        --shitty removal since no one wants  to use the other way
        table.remove(level.nodes,#level.nodes-1)
        scene.nodes.buddy.character.state = 'holdjump'
    end},

    {line = "Buddy: What the hell?",
    action = function()
        scene:trackCharacter("jeff")
        scene.nodes.buddy.invulnerable = false
        scene:actionCharacter("die",scene.nodes.buddy)
    end},

    {line = "Jeff: Here's hoping we can count on her to screw up making potions",
    action = function()
        --scene:trackCharacter("jeff")
        scene:jumpCharacter(scene.nodes.troy)
    end},

    {line = "END",
    action = function()
    end}
    }
    return script
end

return Script