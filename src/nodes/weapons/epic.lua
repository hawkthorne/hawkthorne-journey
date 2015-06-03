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
  hitAudioClip = 'epic_hit',
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

  wield = function( weapon )
    weapon.player.wielding = true
    --changes the animation is weapon is charged
    weapon.player.character:animation():gotoFrame(1)
    weapon.player.character:animation():resume()

    if weapon.animation then
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
    end
    --changes the wield action between ranged and melee if the weapon is charged or not
    if weapon.charged then
      if weapon.player:isWalkState(weapon.player.character.state) then
        weapon.player.character.state = weapon.actionwalk
      elseif weapon.player:isJumpState(weapon.player.character.state) then
        weapon.player.character.state = weapon.actionjump
      else
        weapon.player.character.state = weapon.action
      end
      weapon.player.character:animation():gotoFrame(1)
      weapon.player.character:animation():resume()
    else
      weapon.collider:setSolid(weapon.bb)
      weapon.player.character.state = weapon.action
    end
    

    if weapon.attackAudioClip then
      sound.playSfx( weapon.attackAudioClip )
    end
  end,

  throwProjectile = function( weapon )
    Timer.add(.5, function()
      local node = {
        type = 'projectile',
        name = 'waterSpout',
        x = weapon.position.x+weapon.hand_x,
        y = weapon.position.y+(weapon.bbox_height),
        width = 24,
        height = 16,
        properties = {}
      }
      local water = Projectile.new( node, weapon.collider )
      local level = weapon.containerLevel
      level:addNode(water)
      water:throw(weapon)
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
    end)
    Timer.add(1.25, function()
      weapon.shake = false
      current.trackPlayer = true
      current.player.freeze = false
    end)
  end,

  update = function( dt, weapon, player, level )
    local current = gamestate.currentState()
    if weapon.shake and current.trackPlayer == false then
      local shake = (math.random() * 4) - 2
      camera:setPosition(weapon.camera.tx + shake, weapon.camera.ty + shake)
    end
  end,
}
