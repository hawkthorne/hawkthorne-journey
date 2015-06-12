local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Fireball = require 'nodes/fire_cornelius_big'
local utils = require 'utils'
local Dialog = require 'dialog'
local anim8 = require 'vendor/anim8'
local game = require 'game'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local cheat = require 'cheat'
local Sprite = require 'nodes/sprite'
local Insults = require 'nodes/insults'
local Firework = require 'nodes/firework'

local Player = require 'player'
Player = Player.factory()
local playersinsult = Insults[Player.character.name]

return {
  name = 'cornelius',
  isBoss = true,
  attackDelay = 1,
  height = 220,
  width = 200,
  damage = 30,
  --attack_bb = true,
  jumpkill = false,
  knockback = 0,
  player_rebound = 400,
  antigravity = true,
  bb_width = 220,
  bb_height = 200,
  bb_offset = { x = 0, y = 8},
  attack_width = 40,
  velocity = {x = 0, y = 10},
  hp = 200,
  rage = false,
  freeze = false,
  tokens = 100,
  dyingdelay = 2,
  fadeIn = true,
  cameraScale = 0,
  cameraOriginalScale = {scaleX = camera.scaleX,
                         scaleY = camera.scaleY},
  enterScript ={
    "{{grey}}Welcome{{white}}, you are the first to make it to the {{orange}}Throne of Hawkthorne{{white}}.",
    "Let me take a look at you...",
    "According to your {{olive}}complexion{{white}}, I think you might be...{{purple}} " .. Player.character.name:gsub("^%l", string.upper) .. "{{white}}.",
  }, 
  deathScript ={
    "{{grey}}*heavy breathing*{{white}} I suppose you're wondering,{{purple}} player{{white}}.",
    "Why program myself dying and letting you destroy me?",
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
      right = {'loop', {'1-3,4','2,2'}, 0.1},
      left = {'loop', {'1-3,4','2,2'}, 0.1}
    },
    dying = {
      right = {'loop', {'1-3,5','2,5'}, 0.15},
      left = {'loop', {'1-3,5','2,5'}, 0.15}
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
    enemy.typicalY = enemy.position.y
    enemy.maxy = enemy.position.y - 25
    enemy.miny = enemy.position.y + 25
    enemy.last_teleport = 0
    enemy.last_attack = 0
    enemy.last_fireball = 0 
    enemy.last_dive = 0
    enemy.diving = false
    enemy.falling = false
    enemy.swoop_speed = 150
    enemy.fly_speed = 75
    enemy.swoop_distance = 150
    enemy.swoop_ratio = 0.25

    if enemy.props.hatched then return end

    sound.playMusic("cornelius-transforms")
    -- cheat:fairfight()

    enemy.props.shake( enemy, camera )

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
    if enemy.props.enterScript then
      for i= 0, #playersinsult do
        table.insert(enemy.props.enterScript, playersinsult[i])
      end
      table.insert(enemy.props.enterScript, "I bequeath my fortune to no inferiors!")
      enemy.state = 'talking'
      Dialog.new(enemy.props.enterScript, function()
        enemy.props.hatched = true
        enemy.state = 'attack'
        enemy.props.rage = true
        enemy.velocity.x = 125
        enemy.velocity.y = 5
        sound.playMusic("cornelius-attacks")
        end, nil, 'small')
    end
  end,

  --draws a rotated sparke, used when cornelius appears
  sparkleRotated = function(enemy, offsetX, offestY)
    local node = {
      type = 'sprite',
      name = 'sparkle_rotated',
      x = enemy.position.x+offsetX,
      y = enemy.position.y+offestY,
      width = 45,
      height = 45,
      properties = {
        sheet = 'images/sprites/castle/cornelius_sparkles_big_rotated.png', 
        speed = .2, 
        animation = '1-4,1',
        width = 45,
        height = 45,
        mode = 'once',
        foreground = true
      }
    }
    local sparkleR = Sprite.new( node, enemy.collider )
    local level = enemy.containerLevel
    level:addNode(sparkleR)
  end,

  --draws a straight sparke, used when cornelius appears
  sparkle = function(enemy, offsetX, offestY)
    local node = {
      type = 'sprite',
      name = 'sparkle',
      x = enemy.position.x+offsetX,
      y = enemy.position.y+offestY,
      width = 45,
      height = 45,
      properties = {
        sheet = 'images/sprites/castle/cornelius_sparkles_big.png', 
        speed = .2, 
        animation = '1-4,1',
        width = 45,
        height = 45,
        mode = 'once',
        foreground = true
      }
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
      print('fireball')
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
    print('teleport')
    enemy.state = 'teleport'
    enemy.last_teleport = 0 
    enemy.last_attack = 0
    sound.playSfx("teleport")
    Timer.add(.5, function()  
      if enemy.position.x >= player.position.x then
        enemy.position.x = player.position.x - enemy.width
        enemy.state = 'attack'
      elseif enemy.position.x < player.position.x then
        enemy.position.x = player.position.x 
        enemy.state = 'attack'
      end
      enemy.props.fireball( enemy, player )
    end)  
  end,

  -- adjusts values needed to initialize diving based on where the player is
  targetDive = function ( enemy, player, direction )
    enemy.fly_dir = direction
    enemy.launch_y = enemy.position.y
    local p_x = player.position.x - player.character.bbox.x
    local p_y = player.position.y - player.character.bbox.y
    local e_x = enemy.position.x + (enemy.width/2)
    enemy.swoop_distance = math.abs(p_y - (enemy.position.y+enemy.height))
    enemy.swoop_ratio = math.abs(p_x - e_x) / enemy.swoop_distance
    -- experimentally determined max and min swoop_ratio values
    enemy.swoop_ratio = math.min(1.4, math.max(0.7, enemy.swoop_ratio))
  end,

  --cornelius dives at the player
  startDive = function ( enemy )
    print('dive')
    enemy.diving = true
    enemy.velocity.x = 0
    enemy.last_attack = 0
    enemy.last_dive = 0
    enemy.velocity.y = enemy.swoop_speed
  -- swoop ratio used to center bat on target
    enemy.velocity.x = -( enemy.swoop_speed * enemy.swoop_ratio ) * enemy.fly_dir
    Timer.add(.6, function()  
      enemy.velocity.y = -enemy.fly_speed
      enemy.velocity.x = -(enemy.swoop_speed / 1.5) * enemy.fly_dir
    end)

  end,

  die = function( enemy )
    if enemy.dead then return end
    for _,node in pairs(enemy.containerLevel.nodes) do
      if node.name == "lava" and node.oscillating then
        node.dormant = true
      end
    end
    enemy.falling = true
    enemy.props.freeze = true
    sound.playMusic("cornelius-forfeiting")

    Dialog.new(enemy.props.deathScript, function()
      enemy:die()
      sound.playSfx("cornelius-ending")
      sound.stopMusic()
      Timer.add(8, function()
        sound.playMusic("castle")
      end)
      local NodeClass = require('nodes/key')
      local node = {
        type = 'key',
        name = 'greendale',
        x = 2472,
        y = 616,
        width = 24,
        height = 24,
        properties = {
          info = "Congratulations. You have found the {{green_dark}}Greendale{{white}} key. If you want more to explore, you now have access to the {{green_dark}}Greendale{{white}} campus!",
                 'To get there, exit the study room then use the door to the left. Remember to bring the key!',
        },
      }
      local spawnedNode = NodeClass.new(node, enemy.collider)
      local level = gamestate.currentState()
      level:addNode(spawnedNode)
      --add firework
      --local firework = Firework.new(2300, 700)
      --level:addNode(firework)
    end, nil, 'small')
  end,

  draw = function( enemy )
    --I opted for cornelius not to have a HUD
    --maybe there should be another, more subtle, indication of his health?
  end,

  hurt = function ( enemy )
    print(enemy.hp)
  end,

  --this updates Cornelius's position when he dies so that he drops off the screen
  dyingupdate = function ( dt, enemy )
    enemy.velocity.y = enemy.velocity.y + game.gravity * dt * 0.4
    enemy.position.y = enemy.position.y + enemy.velocity.y * dt
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    if enemy.state == "talking" then
      if enemy.props.cameraScale < 4 then
        enemy.props.cameraScale = enemy.props.cameraScale + dt
        local newOffset = enemy.containerLevel.offset - enemy.props.cameraScale
        if newOffset > 400 then
          enemy.containerLevel.offset = newOffset
        end
        camera:setScale(enemy.props.cameraOriginalScale.scaleX + (enemy.props.cameraScale / 2 / 10),
                        enemy.props.cameraOriginalScale.scaleY + (enemy.props.cameraScale / 2 / 10))
      end
    end

    --move cornelius up if near the bridge
    --still not sure how to handle this and this is not the niceset solution
    if enemy.position.x < 1320 then
      enemy.typicalY = 531
    end
    if not enemy.diving and not player.jumping then 
      enemy.position.y = player.position.y - (enemy.height+55)
    end

    local direction = player.position.x > enemy.position.x + 70 and -1 or 1

    --this stuff is for shaking the camera
    local current = gamestate.currentState()
    local shake = 0
    if enemy.shake and current.trackPlayer == false then
      shake = (math.random() * 4) - 2
      camera:setPosition(enemy.camera.tx + shake, enemy.camera.ty + shake)
    end

    --this is where cornelius's attacks are controlled
    if enemy.state == 'attack' and not enemy.props.hatched then
      enemy.props.hatched = true
      enemy.props.fireball( enemy, player )
    elseif enemy.props.hatched and not enemy.props.freeze then
      enemy.props.rage = true
      enemy.last_teleport = enemy.last_teleport + dt
      enemy.last_attack = enemy.last_attack + dt
      enemy.last_fireball = enemy.last_fireball + dt 
      enemy.last_dive = enemy.last_dive + dt 
      enemy.props.targetDive( enemy, player, -direction )

      if enemy.diving and enemy.position.y <= enemy.typicalY then 
        enemy.velocity.y = 0
        enemy.diving = false
      end

      --cornelius chases player

      if not enemy.diving then
        if enemy.position.x >= player.position.x + 60 then
          enemy.velocity.x = 125
        elseif enemy.position.x <= player.position.x - 250 then
          enemy.velocity.x = -125
        elseif enemy.position.x <= player.position.x - 250 and enemy.position.x <= player.position.x then
          enemy.velocity.x = -125
        end
      --[[this bit would be for cornelius bobbing up and down
            
                    if enemy.position.y <= enemy.maxy then
                      enemy.velocity.y = 10
                      print('down')
                    elseif enemy.position.y >= miny then
                      enemy.velocity.y = -10
                      print('up')
        end]]
      end
      --each attack should have a different chance of occuring
      --fireball is probally the most common attack followed by the dive and then the teleport.
      --They values change based on cornelius's hp
      local pause = 3
      local fireballPause = 4
      local divePause = 6
      local teleportPause = 10
      if enemy.hp >= 100 and enemy.hp < 150 then
        local fireballPause = 3
        local divePause = 4
        local teleportPause = 8
      elseif enemy.hp >= 50 and enemy.hp < 100 then
        local pause = 2
        local fireballPause = 3
        local divePause = 3
        local teleportPause = 6
      elseif enemy.hp >= 1 and enemy.hp < 50 then
        local pause = 0
        local fireballPause = 1
        local divePause = 2
        local teleportPause = 3
      end

      if enemy.last_attack > pause then
        if enemy.last_fireball > fireballPause then
          enemy.props.fireball( enemy, player )
        elseif enemy.last_dive > divePause then
          enemy.props.startDive ( enemy )
        elseif enemy.last_teleport > teleportPause then
          enemy.props.teleport( enemy, player, dt )
        end
      end
    end
  end
}