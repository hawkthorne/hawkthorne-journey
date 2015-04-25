local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Fireball = require 'nodes/fire_cornelius_big'
local utils = require 'utils'
local Dialog = require 'dialog'
local anim8 = require 'vendor/anim8'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local cheat = require 'cheat'
local Sprite = require 'nodes/sprite'
local Insults = require 'nodes/insults'

return {
  name = 'cornelius',
  attackDelay = 1,
  height = 220,
  width = 200,
  damage = 30,
  special_damage = {cornelius = 5000},
  --attack_bb = true,
  jumpkill = false,
  knockback = 0,
  player_rebound = 400,
  antigravity = true,
  bb_width = 124,
  bb_height = 182,
  bb_offset = { x = 0, y = 8},
  attack_width = 40,
  velocity = {x = 0, y = 10},
  hp = 100,
  tokens = 100,
  dyingdelay = 2,
  fadeIn = true,
  enterScript ={
        "{{grey}}Welcome{{white}}, you are the first to make it to the {{orange}}Throne of Hawkthorne{{white}}.",
        "Let me take a look at you...",
        "According to your {{olive}}complexion{{white}}, I think you might be...{{purple}} .. enemy.containerLevel.player .. {{white}}.",
        "You don't deserve my fortune!",
      }, 
  deathScript ={
  		"{{grey}}*heavy breathing*{{white}} I suppose you're wondering,{{purple}} player{{white}}. ",
  		"Why record myself breathing weird and letting you destroy me?",
			"Because I am a man of {{red}}Honor!{{white}}",
			"So you've earned the pleasure of my death!",
  },
 
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
     default = {
      right = {'loop', {'1,1'}, 0.25},
      left = {'loop', {'1,1'}, 0.25}
    },
    talking = {
      right = {'loop', {'1-3,1','2,1'}, 0.15},
      left = {'loop', {'1-3,1','2,1'}, 0.15}
    },
    attack = {
      right = {'loop', {'1-3,2','2,2'}, 0.1},
      left = {'loop', {'1-3,2','2,2'}, 0.1}
    },
    hurt = {
      right = {'once', {'1-3,4','2,2'}, 0.1},
      left = {'once', {'1-3,4','2,2'}, 0.1}
    },
    dying = {
      right = {'loop', {'1-3,1','2,1'}, 0.15},
      left = {'loop', {'1-3,1','2,1'}, 0.15}
    },
    enter = {
      right = {'once', {'1,1'}, 0.2},
      left = {'once', {'1,1'}, 0.2}
    },
    teleport = {
      right = {'loop', {'1-3,3','2,3'}, 0.1},
      left = {'loop', {'1-3,3','2,3'}, 0.1}
    },
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.directionY = math.random(2) == 1 and 'up' or 'down'
    enemy.state = 'default'
    enemy.maxy = enemy.position.y + 10
    enemy.miny = enemy.position.y - 10
    enemy.hatched = false
    enemy.last_teleport = 0
    enemy.last_attack = 0
    enemy.last_fireball = 0 
    enemy.last_dive = 0
    enemy.swoop_speed = 150
    enemy.fly_speed = 75
    enemy.swoop_distance = 150
    enemy.swoop_ratio = 0.25
    sound.playMusic("cornelius-attacks")
    cheat:fairfight()
    --To Do 
      --add a cheat to dissable the overworld when fighting Cornelius

    --remove this after testing
    --enemy.rage = true
    --enemy.velocity.x = 100

    --shake
    enemy.props.shake( enemy, camera )
    --sparkles
    enemy.props.sparkleRotated( enemy, 45, 0 )
    enemy.props.sparkleRotated( enemy, 50, 60 )
    enemy.props.sparkleRotated( enemy, 110, 150 )
    Timer.add(.2, function() 
      enemy.props.sparkle( enemy, 0, 100 )
      enemy.props.sparkleRotated( enemy, 120, 100 )
      Timer.add(.2, function() 
        enemy.props.sparkleRotated( enemy, 70, 140 )
        enemy.props.sparkle( enemy, 0, 0 )
        Timer.add(.2, function() 
          enemy.props.sparkleRotated( enemy, 45, 0 )
          enemy.props.sparkleRotated( enemy, 50, 60 )
          enemy.props.sparkleRotated( enemy, 110, 150 )
          end)
        end)
    end)

    --enter dialog
		if enemy.enterScript then
      enemy.state = 'talking'
	    Dialog.new(enemy.enterScript, function() 
        enemy.state = 'attack'
        enemy.rage = true
	      end, nil, 'small')
	  end
     
  end,

  sparkleRotated = function(enemy, offsetX, offestY)
    local node = {
      type = 'sprite',
      name = 'sparkle_rotated',
      x = enemy.position.x+offsetX,
      y = enemy.position.y+offestY,
      width = 45,
      height = 45,
      properties = {sheet = 'images/sprites/castle/cornelius_sparkles_big_rotated.png', 
                    speed = .2, 
                    animation = '1-4,1',
                    width = 45,
                    height = 45,
                    mode = 'once',
                    foreground = true}
    }
    local sparkleR = Sprite.new( node, enemy.collider )
    local level = enemy.containerLevel
    level:addNode(sparkleR)
  end,

  sparkle = function(enemy, offsetX, offestY)
    local node = {
      type = 'sprite',
      name = 'sparkle',
     x = enemy.position.x+offsetX,
      y = enemy.position.y+offestY,
      width = 45,
      height = 45,
      properties = {sheet = 'images/sprites/castle/cornelius_sparkles_big.png', 
                    speed = .2, 
                    animation = '1-4,1',
                    width = 45,
                    height = 45,
                    mode = 'once',
                    foreground = true}
    }
    local sparkle = Sprite.new( node, enemy.collider )
    local level = enemy.containerLevel
    level:addNode(sparkle)

  end,

  --shakes the camera when cornelius enters
  shake = function ( enemy, camera )
    enemy.camera.tx = camera.x
    enemy.camera.ty = camera.y
    enemy.shake = true
    local current = gamestate.currentState()
    current.trackPlayer = false
    current.player.freeze = true
    Timer.add(.6, function()
      enemy.shake = false
      current.trackPlayer = true
      current.player.freeze = false
    end)

  end,

  --throws a fireball that will spawn fire to the right and left as well as eat away the floor.
  fireball = function( enemy, player )
    if not enemy.dead then
      enemy.last_fireball = 0 
      enemy.last_attack = 0
      local Fireball = require('nodes/fire_cornelius_big')
      local node = {
            type = 'fire_cornelius_big',
            name = 'fireball',
            x = player.position.x,
            y = enemy.position.y,
            width = 34,
            height = 110,
            properties = {}
          }
          local fireball = Fireball.new( node, enemy.collider )
          local level = enemy.containerLevel
          level:addNode(fireball)
    end
  end,

  --cornelius teleports to behind the player
  teleport = function ( enemy, player, dt )
    enemy.state = 'teleport'
    enemy.last_teleport = 0 
    enemy.last_attack = 0
    sound.playSfx("teleport")
    Timer.add(.5, function()  
      if enemy.position.x >= player.position.x then
        print('right')
        enemy.position.x = player.position.x - enemy.width
        enemy.state = 'attack'
      elseif enemy.position.x < player.position.x then
        print('left')
        enemy.position.x = player.position.x 
        enemy.state = 'attack'
      end
      enemy.props.fireball( enemy, player )
    end)  
  end,

  -- adjusts values needed to initialize swooping
  targetDive = function ( enemy, player, direction )
    enemy.fly_dir = direction
    enemy.launch_y = enemy.position.y
    local p_x = player.position.x - player.character.bbox.x
    local p_y = player.position.y - player.character.bbox.y
    enemy.swoop_distance = math.abs(p_y - enemy.position.y)
    enemy.swoop_ratio = math.abs(p_x - enemy.position.x) / enemy.swoop_distance
    -- experimentally determined max and min swoop_ratio values
    enemy.swoop_ratio = math.min(1.4, math.max(0.7, enemy.swoop_ratio))
  end,

  --cornelius dives at the player
  startDive = function ( enemy )
  enemy.last_attack = 0
  enemy.last_dive = 0
    enemy.velocity.y = enemy.swoop_speed
  -- swoop ratio used to center bat on target
    enemy.velocity.x = -( enemy.swoop_speed * enemy.swoop_ratio ) * enemy.fly_dir
    Timer.add(.5, function()  
      enemy.velocity.y = -enemy.fly_speed
      enemy.velocity.x = -(enemy.swoop_speed / 1.5) * enemy.fly_dir
      print('undive')
    
    end)

  end,

  -- Compares vulnerabilities to a weapons special damage and sums up total damage
  calculateDamage = function(self, damage, special_damage)
    if not special_damage then
      if self.state =='teleport' then
        print('double damage')
        damage = 2*damage
        return damage
      else
        print('regular damage')
        return damage
      end
    end
    for _, value in ipairs(self.vulnerabilities) do
      if special_damage[value] ~= nil then
        if self.state =='teleport' then
          damage = (damage + special_damage[value])*2
          print('double damage')
        else
          damage = damage + special_damage[value]
          print('regular damage')
        end
      end
    end

    return damage
  end,

  die = function( enemy )
    sound.playMusic("cornelius-forfeiting")
    Dialog.new(enemy.deathScript, function()
      enemy:die()
      sound.playSfx("cornelius-ending")
      sound.stopMusic()

      local NodeClass = require('nodes/key')
      local node = {
        type = 'key',
        name = 'greendale',
        x = enemy.position.x + enemy.width / 2 ,
        y = enemy.position.y + enemy.height+48,
        width = 24,
        height = 24,
        properties = {info = "Congratulations. You have found the {{green_dark}}Greendale{{white}} key. If you want more to explore, you now have access to the {{green_dark}}Greendale{{white}} campus!",
                              'To get there, exit the study room then use the door to the left. Remember to bring the key!',
        },
      }
      local spawnedNode = NodeClass.new(node, enemy.collider)
      local level = gamestate.currentState()
      level:addNode(spawnedNode)

      end, nil, 'small')

  end,

  draw = function( enemy )
    --I opted for cornelius not to have a HUD
    --maybe there should be another, more subtle, indication of his health?

    x, y = camera.x + window.width - 130 , camera.y + 10

  end,

   hurt = function( enemy )
    print(enemy.hp)
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end
    local direction = player.position.x > enemy.position.x + 70 and -1 or 1

    --this stuff is for shaking the camera
    local current = gamestate.currentState()
    local shake = 0
    if enemy.shake and current.trackPlayer == false then
      shake = (math.random() * 4) - 2
      camera:setPosition(enemy.camera.tx + shake, enemy.camera.ty + shake)
    end

    local offset = math.random(0,200)

    --this is where cornelius is controlled
    if enemy.state == 'talking' and not enemy.hatched then
      
    elseif enemy.state == 'attack' and not enemy.hatched then
      enemy.hatched = true
      enemy.props.fireball( enemy, player )
      print('hatch')
    elseif enemy.hatched then
    	enemy.rage = true
      enemy.last_teleport = enemy.last_teleport + dt
      enemy.last_attack = enemy.last_attack + dt
      enemy.last_fireball = enemy.last_fireball + dt 
      enemy.last_dive = enemy.last_dive + dt 
      enemy.props.targetDive( enemy, player, -direction )

      --cornelius chases player
      if enemy.position.x > player.position.x then
        enemy.velocity.x = 100
      elseif enemy.position.x < player.position.x then
        enemy.velocity.x = -100
      end
                  --[[
                  if enemy.position.y <= enemy.miny then 
                    enemy.velocity.y = -enemy.velocity.y 
                  elseif enemy.position.y >= enemy.maxy then
                    enemy.velocity.y = -enemy.velocity.y
                  end]]
      
      --each attack should have a different chance of occuring
      --fireball is probally the most common attack followed by the dive and then the teleport.
      if enemy.last_attack > 2 then
        if enemy.last_fireball > 4 then
          enemy.props.fireball( enemy, player )
        --end
        --if enemy.last
          enemy.props.teleport( enemy, player, dt )
        --enemy.props.startDive ( enemy )
        end
      end
      
    end

  
  end
}