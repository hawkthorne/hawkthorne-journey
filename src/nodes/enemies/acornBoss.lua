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
    damage = 2,
    jumpkill = false,
    player_rebound = 100,
    bb_width = 70,
    bb_height = 75,
    hp = 50,
    tokens = 15,
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
        hurt = {
            right = {'loop', {'7,1'}, 0.25},
            left = {'loop', {'7,2'}, 0.25}
        },
        ragehurt = {
            right = {'loop', {'2,3'}, 1},
            left = {'loop', {'5,3'}, 1}
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
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
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

    update = function( dt, enemy, player )

    local direction = player.position.x > enemy.position.x + 40 and -1 or 1

    --    local rage_velocity = 3

        if enemy.position.x < player.position.x then
                enemy.direction = 'right'
        elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
                enemy.direction = 'left'
        end

        enemy.last_jump = enemy.last_jump + dt
        if math.abs(enemy.position.x - player.position.x) < 120 then
            if enemy.last_jump > 1 then
                enemy.last_jump = 0
                if enemy.state == 'rage' then
                 enemy.state = 'ragejump'
                 enemy.velocity.y = -500
                Timer.add(.5, function()
                 enemy.state = 'rage'
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

        if enemy.hp < 30 then
            
            enemy.dead = true
        end
  
        if enemy.direction == 'left' then
            enemy.velocity.x = 70
        else
            enemy.velocity.x = -70
        end

    end    
}
