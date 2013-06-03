local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local sound = require 'vendor/TEsound'

return {
    name = 'turkeyBoss',
    attack_sound = 'gobble_boss',
    attackDelay = 1,
    height = 115,
    width = 215,
    damage = 4,
    attack_bb = true,
    jumpkill = false,
    player_rebound = 1200,
    last_jump = 0,
    bb_width = 40,
    bb_height = 105,
    bb_offset = { x = -40, y = 10},
    attack_width = 40,
    attack_offset = { x = -40, y = 10},
    velocity = {x = 0, y = 1},
    hp = 200,
    tokens = 15,
    hand_x = -40,
    hand_y = 70,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        jump = {
            right = {'loop', {'3-4,2'}, 0.25},
            left = {'loop', {'3-4,3'}, 0.25}
        },
        attack = {
            right = {'once', {'2,4'}, 0.2},
            left = {'once', {'3,4'}, 0.2}
        },
        charge = {
            right = {'once', {'1,4'}, 0.8},
            left = {'once', {'4,4'}, 0.8}
        },
        default = {
            right = {'loop', {'1-2,2'}, 0.25},
            left = {'loop', {'1-2,3'}, 0.25}
        },
        hurt = {
            right = {'loop', {'1-2,2'}, 0.25},
            left = {'loop', {'1-2,3'}, 0.25}
        },
        dying = {
            right = {'once', {'1-4,2'}, 0.25},
            left = {'once', {'1-4,3'}, 0.25}
        },
        enter = {
            right = {'once', {'1,5'}, 0.25},
            left = {'once', {'1,5'}, 0.25}
        },
        hatch = {
            right = {'once', {'2-3,5','1-3,1'}, 0.25},
            left = {'once', {'2-3,5','1-3,1'}, 0.25}
        },
    },
    enter = function( enemy )
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
        enemy.state = 'enter'
        enemy.hatched = false
    end,
    die = function( enemy )
        local NodeClass = require('nodes/key')
        local node = {
                    type = 'key',
                    name = 'white_crystal',
                    x = enemy.position.x + enemy.width/2 - 12,
                    y = 670,
                    width = 24,
                    height = 24,
                    properties = {},
                    }
        local spawnedNode = NodeClass.new(node, enemy.collider)
        local level = gamestate.currentState()
        level:addNode(spawnedNode)
    end,
    draw = function( enemy )
        back = love.graphics.newImage('images/turkey_health_bar/bar.png')
        cap = love.graphics.newImage('images/turkey_health_bar/cap.png')
        
        
        position = {x=enemy.position.x - 180 + enemy.width/4, y=695}
        bar_position = {x=position.x + 63, y=position.y + 36}
        
        love.graphics.draw(back, position.x, position.y, 0 , 0.5)
        
        enemy.health_ratio = enemy.health_ratio or 282 / enemy.hp
        
        fill = enemy.hp * enemy.health_ratio
        
        love.graphics.setColor(
        math.min( map( fill, 284, 143, 0, 255 ), 255 ), -- green to yellow
        math.min( map( fill, 142, 0, 255, 0), 255), -- yellow to red
        0,
        200
        )
        love.graphics.draw(cap, bar_position.x, bar_position.y + 13, math.pi)
        love.graphics.draw(cap, bar_position.x + fill, bar_position.y)
        love.graphics.rectangle("fill", bar_position.x, bar_position.y, fill, 13)
        love.graphics.setColor( 255, 255, 255, 255 )
    end,
    attackBasketball = function( enemy )
        local node = {
            type = 'projectile',
            name = 'basketball',
            x = enemy.position.x,
            y = enemy.position.y,
            width = 18,
            height = 16,
            properties = {}
        }
        local basketball = Projectile.new( node, enemy.collider )
        basketball.enemyCanPickUp = true
        local level = enemy.containerLevel
        level:addNode(basketball)

        enemy:registerHoldable(basketball)
        enemy:pickup()
        
        enemy.currently_held:launch(enemy)

        basketballenemyCanPickUp = false
    end,
    wing_attack = function( enemy, player, delay )
        local state = enemy.state
        if state == 'attack' or state == 'charge' then state = 'default' end
        enemy.state = 'charge'
        Timer.add(0.8, function() enemy.collider:setSolid(enemy.attack_bb) enemy.state = 'attack' end)
        Timer.add(delay, function() enemy.collider:setGhost(enemy.attack_bb) enemy.state = state end)
        
    end,
    spawn_minion = function( enemy, direction )
        local node = {
                    x = enemy.position.x,
                    y = enemy.position.y,
                    type = 'enemy',
                    properties = {
                        enemytype = 'turkey'
                    }
                }
        local spawnedTurkey = Enemy.new(node, enemy.collider, enemy.type)
        spawnedTurkey.turkeyMax = math.random() > 0.8 and 0 or 1
        spawnedTurkey.velocity.x = math.random(10,100)*direction
        spawnedTurkey.velocity.y = -math.random(200,400)
        spawnedTurkey.last_jump = 1
        enemy.containerLevel:addNode(spawnedTurkey)
    end,
    jump = function ( enemy )
        enemy.state = 'jump'
        enemy.last_jump = 0
        enemy.velocity.y = -math.random(300,800)
        
    end,
    update = function( dt, enemy, player, level )
        if enemy.dead or enemy.state == 'attack' then
            return
        end
        
        local direction = player.position.x > enemy.position.x + 40 and -1 or 1
        
        if enemy.velocity.y > 1 and not enemy.hatched then
            enemy.state = 'enter'
        elseif math.abs(enemy.velocity.y) < 1 and not enemy.hatched then
            enemy.state = 'hatch'
            Timer.add(2, function() enemy.hatched = true end)
        elseif enemy.hatched then
            
        enemy.last_jump = enemy.last_jump + dt
        enemy.last_attack = enemy.last_attack + dt
        
        local pause = 1.5
        
        if enemy.hp < 20 then
            pause = 0.7
            
        elseif enemy.hp < 50 then
            pause = 1
        end
        
        if enemy.last_jump > 2 and enemy.state ~= 'attack' and enemy.state ~= 'charge' then
            enemy.props.jump( enemy )
            Timer.add(0.75, function() enemy.direction = direction == -1 and 'right' or 'left' end)
            
        elseif enemy.last_attack > pause and enemy.state ~= 'jump' then
            if math.random() > 0.9 and enemy.hp < 80 then
                enemy.props.spawn_minion(enemy, direction)
            elseif math.random() > 0.6 then
                enemy.props.wing_attack(enemy, player, enemy.props.attackDelay)
            else
                enemy.props.attackBasketball(enemy)
            end
            enemy.last_attack = -0
        end
        if enemy.velocity.y == 0 and enemy.hatched and enemy.state ~= 'attack' and enemy.state ~= 'charge' then
            enemy.state = 'default'
        end
         
        end

    end    
}