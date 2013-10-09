local Enemy = require 'nodes/enemy'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
    name = 'takeout',
    position_offset = { x = 0, y = 0 },
    height = 48,
    width = 48,
    damage = 0,
    hp = 9,
    animations = {
        dying = {
            right = {'once', {'2,1'}, 0.25},
            left = {'once', {'2,1'}, 0.25}
        },
        default = {
            right = {'loop', {'1,1'}, 0.25},
            left = {'loop', {'1,1'}, 0.25}
        },
        hurt = {
            right = {'once', {'2,1'}, 0.25},
            left = {'once', {'2,1'}, 0.25}
        }
    },
    enter = function( enemy )
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
        enemy.kungpaochickenMax = 3
        enemy.kungpaochickenCount = 0
        enemy.lastSpawn = 0
    end,
    update = function( dt, enemy, player, level )
        if enemy.dead then return end
        
        enemy.lastSpawn = enemy.lastSpawn + dt
        
        local direction = player.position.x > enemy.position.x and -1 or 1
        enemy.direction = direction == 1 and 'right' or 'left'
        
        if math.abs(enemy.position.x - player.position.x) < 200 and enemy.kungpaochickenCount < enemy.kungpaochickenMax and enemy.lastSpawn > 3 then
            enemy.lastSpawn = 0
            local node = {
                x = enemy.position.x,
                y = enemy.position.y,
                type = 'enemy',
                properties = {
                    enemytype = 'kungpaochicken'
                }
            }
            local kungpaochicken = Enemy.new(node, enemy.collider, enemy.type)
            kungpaochicken.velocity.x = math.random(20,60)*direction
            kungpaochicken.velocity.y = -math.random(300,400)
            kungpaochicken.state = 'enter'
            enemy.containerLevel:addNode(kungpaochicken)
            enemy.kungpaochickenCount = enemy.kungpaochickenCount + 1
        end

    end
}