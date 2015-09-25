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
  special_damage = {cornelius = 5000},
  damage = 30,
  jumpkill = false,
  knockback = 0,
  player_rebound = 400,
  antigravity = true,
  bb_width = 150,
  bb_height = 220,
  bb_offset = { x = 0, y = 8},
  attack_width = 40,
  velocity = {x = 0, y = 0},
  hp = 200,
  rage = false,
  tokens = 100,
  fadeIn = true,
  dying = false,
  invulnerableTime = 0,
  cameraScale = 0,
  cameraOriginalScale = {scaleX = camera.scaleX,
                         scaleY = camera.scaleY},
  cameraOffset = 552,
  camera = {
    tx = 0,
    ty = 0,
    sx = 1,
    sy = 1,
  },
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
    { item = 'coin', v = 1, p = 0 },
    { item = 'health', v = 1, p = 0 }
  },
  animations = {
    default = {
      right = {'loop', {'1-3,2','2,2'}, 0.1},
      left = {'loop', {'1-3,2','2,2'}, 0.1}
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
    before_death = {
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
    local dead = enemy.db:get('cornelius-dead', false)
    if dead then enemy:die(true) return end
    enemy.last_teleport = 0
    enemy.last_attack = 0
    enemy.last_fireball = 0 

    if enemy.props.hatched then return end

    sound.playMusic("cornelius-transforms")

    local cheats = cheat:fairfight()

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
      if cheats then
        table.insert(enemy.props.enterScript, "... I'll not allow any cheating!")
      end
      enemy.state = 'talking'
      Dialog.new(enemy.props.enterScript, function()
        enemy.state = 'attack'
        enemy.props.rage = true
        enemy.velocity.x = 125
        sound.playMusic("cornelius-attacks")
        end, nil, 'small')
    end
  end,

  leave = function(enemy)
    camera:setScale(enemy.props.cameraOriginalScale.scaleX,
                    enemy.props.cameraOriginalScale.scaleY)
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
    enemy.props.camera.tx = camera.x
    enemy.props.camera.ty = camera.y
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
    if enemy.props.dying or enemy.dead then return end
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
  end,

  --cornelius teleports to behind the player
  teleport = function ( enemy, player, dt )
    if enemy.props.dying or enemy.dead then return end
    enemy.state = 'teleport'
    enemy.last_teleport = 0 
    enemy.last_attack = 0
    sound.playSfx("teleport")
    Timer.add(1.5, function()
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

  die = function( enemy )
    if enemy.dead or enemy.db:get('cornelius-dead', false) then return end
    local level = enemy.containerLevel

    enemy.db:set('cornelius-dead', true)
    enemy.db:set('cornelius-beaten', true)

    sound.stopMusic()
    sound.playSfx("cornelius-ending")

    local NodeClass = require('nodes/firework')
    local node = {
      x = enemy.position.x,
      y = 480,
      properties = {},
    }
    local firework = NodeClass.new(node, enemy.collider)
    level:addNode(firework)
  end,

  deathspeeh = function( enemy )
    local level = enemy.containerLevel

    sound.playMusic("cornelius-forfeiting")

    for _,node in pairs(level.nodes) do
      if node.name == "lava" and node.oscillating then
        node.dormant = true
      end
      if node.isFire and node.die then
        node:die()
      end
    end

    Dialog.new(enemy.props.deathScript, function()
      local NodeClass = require('nodes/key')
      local node = {
        type = 'key',
        name = 'greendale',
        x = 1800,
        y = 615,
        width = 24,
        height = 24,
        properties = {
          info = "Congratulations. You have found the {{green_dark}}Greendale{{white}} key. If you want more to explore, you now have access to the {{green_dark}}Greendale{{white}} campus!",
                 'To get there, exit the study room then use the door to the left. Remember to bring the key!',
        },
      }
      local spawnedNode = NodeClass.new(node, enemy.collider)
      level:addNode(spawnedNode)
    end, nil, 'small')
  end,

  prevent_death = function( enemy )
    enemy.state = 'before_death'
    if not enemy.props.dying then
      enemy.props.dying = true
      return true
    end
    return false
  end,

  --this updates Cornelius's position when he dies so that he drops off the screen
  dying_update = function ( dt, enemy )
    enemy.velocity.y = enemy.velocity.y + game.gravity * dt * 2
    enemy.position.y = enemy.position.y + enemy.velocity.y * dt
  end,

  updateCameraZoom = function( dt, enemy )
    if not enemy.props.cameraZoom then return end
    enemy.props.cameraScale = enemy.props.cameraScale + dt * enemy.props.cameraZoom / 10
    camera:setScale(enemy.props.cameraOriginalScale.scaleX + enemy.props.cameraScale,
                    enemy.props.cameraOriginalScale.scaleY + enemy.props.cameraScale)
    enemy.props.updateCameraOffset( enemy )
    enemy.props.cameraZoom = nil
  end,

  updateCameraOffset = function( enemy )
    local newOffset = enemy.props.cameraOffset - (camera.scaleX - 0.5) * 500
    enemy.containerLevel.offset = newOffset
  end,

  floor_pushback = function( enemy )
    if enemy.props.dying and enemy.velocity.y == 0 then
      if not enemy.props.saidDeathSpeeh then
        enemy.props.saidDeathSpeeh = true
        Timer.add(2, function()
          enemy.props.deathspeeh( enemy )
        end)
      end
    end
  end,

  update = function( dt, enemy, player, level )
    if (enemy.props.dying or enemy.dead) and camera.scaleX > 0.5 then
      enemy.props.cameraZoom = -1
    end

    if enemy.invulnerable then
      enemy.props.invulnerableTime = enemy.props.invulnerableTime + dt
      if enemy.props.invulnerableTime > 5 then
        enemy.invulnerable = false
      end
    end

    if enemy.dead then return end

    if enemy.props.hatched and not enemy.props.dying and camera.scaleX < 0.65 then
      enemy.props.cameraZoom = 1
    end

    enemy.props.updateCameraZoom( dt, enemy )

    if enemy.props.dying then
      enemy.state = 'before_death'
      enemy.velocity.x = 0

      enemy.props.dying_update( dt, enemy )
      return
    end

    local direction = player.position.x > enemy.position.x + 70 and -1 or 1

    --this is where cornelius's attacks are controlled
    if enemy.state == 'attack' and not enemy.props.hatched then
      enemy.props.hatched = true
      enemy.props.fireball( enemy, player )
    elseif enemy.props.hatched then
      enemy.props.rage = true
      enemy.last_teleport = enemy.last_teleport + dt
      enemy.last_attack = enemy.last_attack + dt
      enemy.last_fireball = enemy.last_fireball + dt 

      --cornelius chases player
      if enemy.position.x >= player.position.x + 60 then
        enemy.velocity.x = 125
      elseif enemy.position.x <= player.position.x - 250 then
        enemy.velocity.x = -125
      elseif enemy.position.x <= player.position.x - 250 and enemy.position.x <= player.position.x then
        enemy.velocity.x = -125
      end

      --each attack should have a different chance of occuring
      --fireball is probally the most common attack followed by the dive and then the teleport.
      --They values change based on cornelius's hp
      local pause = 3
      local fireballPause = 4
      local teleportPause = 10

      if enemy.hp < 75 then
        pause = pause / 2
        fireballPause = fireballPause / 2
        teleportPause = teleportPause / 2
      end

      if enemy.last_attack > pause then
        if enemy.last_fireball > fireballPause then
          enemy.props.fireball( enemy, player )
        elseif enemy.last_teleport > teleportPause then
          enemy.props.teleport( enemy, player, dt )
        end
      end
    end
  end
}