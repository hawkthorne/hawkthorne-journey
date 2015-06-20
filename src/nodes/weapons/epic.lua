-----------------------------------------------
-- mace.lua
-- Represents a mace that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new mace object
-- @return the mace object created
local Timer = require 'vendor/timer'
local window = require 'window'
local camera = require 'camera'
local utils = require 'utils'
local Projectile = require 'nodes/projectile'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'

return {
  hand_x = 15,
  hand_y = 30,
  frameAmt = 9,
  width = 44,
  height = 46,
  dropWidth = 24,
  dropHeight = 44,
  damage = 12,
  projectile = "waterSpout",
  throwDelay = 0.24,
  special_damage = {water = 6, epic = 100},
  bbox_width = 18,
  bbox_height = 18,
  bbox_offset_x = {4,19,25,19},
  bbox_offset_y = {4,9,22,9},
  magical = true,
  animations = {
    default = {'once', {'1,1'}, 1},
    defaultCharged = {'loop', {'2-7,1'}, 0.1},
    wield = {'once', {'1,1','8,1','9,1','8,1'},0.2},
    wieldCharged = {'once', {'1,1','8,1','9,1','8,1'},0.2}
  },
  action = "wieldaction3",
  actionwalk = "wieldaction3",
  actionjump = "wieldaction3",

  update = function( weapon, dt, player, map)
    if not weapon.player and
       weapon.position.x == 1728 and
       weapon.position.y == 141 and
       math.abs(player.position.x - weapon.position.x) < 60 then
      weapon.charged = true
      weapon.animation = weapon.defaultChargedAnimation
    end
  end,

  trigger = function( weapon )
    weapon.charged = true
    weapon.animation = weapon.defaultChargedAnimation
  end,

  wield = function( weapon )
    if weapon.charged then
      weapon.animation = weapon.wieldChargedAnimation
      weapon.charged = false
      weapon:weaponShake(weapon)
      weapon:throwProjectile(weapon)
    else
      weapon.animation = weapon.wieldAnimation
    end
    weapon.animation:gotoFrame(1)
    weapon.animation:resume()
    Timer.add(.5, function() sound.playSfx( 'epic_hit' ) end)
  end,

  throwProjectile = function( weapon )
    Timer.add(.3, function()
      local node = {
        type = 'projectile',
        name = 'waterSpout',
        x = weapon.position.x+weapon.hand_x,
        y = weapon.player.position.y - weapon.player.height + 17,
        width = 24,
        height = 16,
        properties = {}
      }
      local water = Projectile.new( node, weapon.collider )
      local level = weapon.containerLevel
      if level then
        level:addNode(water)
        water:throw(weapon)
      end
    end)
  end,

  weaponShake = function (weapon)
    local current = gamestate.currentState()
    Timer.add(.3, function()
      weapon.shake = true
      weapon.camera.tx = camera.x
      weapon.camera.ty = camera.y
      current.trackPlayer = false
      current.player.freeze = true
      Timer.add(1, function()
        if not current.player then return end
        weapon.shake = false
        current.trackPlayer = true
        current.player.freeze = false
      end)
    end)
  end,
}
