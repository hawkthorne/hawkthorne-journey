local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

return {
    name = 'acornBoss',
    attack_sound = 'acorn_growl',
    hurt_sound = 'acorn_crush',
    height = 75,
    width = 75,
    damage = 10,
    jumpkill = false,
    player_rebound = 100,
    bb_width = 70,
    bb_height = 75,
    hp = 100,
    knockbackDisabled = true,
    speed = 50,
    tokens = 40,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        jump = {
            right = {'loop', {'6,1'}, 1},
            left = {'loop', {'6,2'}, 1}
        },
        dying = {
            right = {'once', {'8,1'}, 0.25},
            left = {'once', {'8,2'}, 0.25}
        },
        default = {
            right = {'loop', {'2-5,1'}, 0.25},
            left = {'loop', {'2-5,2'}, 0.25}
        },
        --hurt = {
        --    right = {'loop', {'7,1'}, 0.25},
        --    left = {'loop', {'7,2'}, 0.25}
        --},
        ragehurt = {
            right = {'loop', {'2,3'}, 1},
            left = {'loop', {'5,3'}, 1}
        },
        rageready1 = {
            right = {'loop', {'1-3,6'}, 0.25},
            left = {'loop', {'1-3,7'}, 0.25}
        },
        ragereadyjump1 = {
            right = {'loop', {'4,6'}, 1},
            left = {'loop', {'6,7'}, 1}
        },
        rageready2 = {
            right = {'loop', {'5-7,6'}, 0.25},
            left = {'loop', {'5-7,7'}, 0.25}
        },
        ragereadyjump2 = {
            right = {'loop', {'8,6'}, 1},
            left = {'loop', {'8,7'}, 1}
        },
        rage = {
            right = {'loop', {'2-5,4'}, 0.25},
            left = {'loop', {'2-5,5'}, 0.25}
        },
        ragejump = {
            right = {'loop', {'6,4'}, 1},
            left = {'loop', {'6,5'}, 1}
        },
        rageattack = {
            right = {'loop', {'8,1'}, 1},
            left = {'loop', {'8,2'}, 1}
        },
    },
    enter = function( enemy )
        enemy.direction ='left'
    end,

    die = function( enemy )
    
        local node = {
                    x = enemy.position.x,
                    y = enemy.position.y,
                    type = 'enemy',
                    properties = {
                        enemytype = 'acorn'
                    }
             }
        local node = Enemy.new(node, enemy.collider, enemy.type)
        node.maxx = enemy.position.x + 24
        node.minx = enemy.position.x - 24
        enemy.containerLevel:addNode( node )
    end,


    draw = function( enemy )
        fonts.set( 'small' )
    love.graphics.setStencil( )

        local energy = love.graphics.newImage('images/enemies/bossHud/energy.png')
        local bossChevron = love.graphics.newImage('images/enemies/bossHud/bossChevron.png')
        local bossPic = love.graphics.newImage('images/enemies/bossHud/acornBoss.png')
        local bossPicRage = love.graphics.newImage('images/enemies/bossHud/acornBossRage.png')

        energy:setFilter('nearest', 'nearest')
        bossChevron:setFilter('nearest', 'nearest')
        bossPic:setFilter('nearest', 'nearest')

        x, y = camera.x + window.width - 130 , camera.y + 10


        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( bossChevron, x , y )
         --if enemy.hp < 30 then 
         -- love.graphics.draw(bossPicRage, x + 69, y + 10 )
      --   else
          love.graphics.draw(bossPic, x + 69, y + 10 )
       --  end     

        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.printf( "ACORN", x + 15, y + 15, 52, 'center' )
        love.graphics.printf( "KING", x + 15, y + 41, 52, 'center'  )

        energy_stencil = function( x, y )
            love.graphics.rectangle( 'fill', x + 11, y + 27, 59, 9 )
        end
        love.graphics.setStencil(energy_stencil, x, y)
        local max_hp = 50
        local rate = 58/max_hp
        love.graphics.setColor(
            math.min(utils.map(enemy.hp, max_hp, max_hp / 2 + 1, 0, 255 ), 255), -- green to yellow
            math.min(utils.map(enemy.hp, max_hp / 2, 0, 255, 0), 255), -- yellow to red
            0,
            255
        )
        love.graphics.draw(energy, x + ( max_hp - enemy.hp ) * rate, y)

        love.graphics.setStencil( )
        love.graphics.setColor( 255, 255, 255, 255 )
          fonts.revert()

    end,

    rage = function( enemy )
        enemy.state = 'rage'
        enemy.damage = 20
        enemy.burn = true
        enemy.props.speed = 170
        enemy.player_rebound = 450
        Timer.add(8, function() 
          if enemy.state ~= 'dying' then
            enemy.state = 'default'
            enemy.player_rebound = 300
            enemy.idletime = 0      
            enemy.burn = false
            enemy.damage = 10
            enemy.props.speed = 50  
          end
        end)
    end,

    update = function( dt, enemy, player )
    if enemy.dead then return end

    local direction

    if enemy.position.x < player.position.x then
      enemy.direction = 'right'
      direction = -1
    elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
      enemy.direction = 'left'
      direction = 1
    end

    enemy.idletime = enemy.idletime + dt

    if math.abs(enemy.position.x - player.position.x) < 200 then
    enemy.last_jump = enemy.last_jump + dt
        if enemy.last_jump > 3 then
            enemy.last_jump = 0
            if enemy.state == 'rage' then
            enemy.state = 'ragejump'
            enemy.velocity.y = -500
            Timer.add(.5, function()
                enemy.state = 'rage'
                end)
            elseif enemy.state == 'rageready1' then
            enemy.state = 'ragereadyjump1'
            enemy.velocity.y = -500
            Timer.add(.5, function()
                enemy.state = 'rageready1'
                end)
            elseif enemy.state == 'rageready2' then
            enemy.state = 'ragereadyjump2'
            enemy.velocity.y = -500
            Timer.add(.5, function()
                enemy.state = 'rageready2'
                end)
            else
                enemy.state = 'jump'   
                enemy.velocity.y = -430
            Timer.add(.5, function()
                enemy.state = 'default'
                end)
            end                             
        end
    end

        if enemy.idletime >= 15 then
        enemy.props.rage(enemy)
        elseif enemy.idletime >= 12 then
        enemy.state = 'rageready2'
        elseif enemy.idletime >= 7 then
        enemy.state = 'rageready1'
        else
        enemy.state = 'default'
        end

    if math.abs(enemy.position.x - player.position.x) < 2 then
        enemy.props.speed = 0
    elseif enemy.state ~= 'rage' then
        enemy.props.speed = 50
    end

    enemy.velocity.x = enemy.props.speed * direction

    end    
}