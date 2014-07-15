local Gamestate = require 'vendor/gamestate'
local Tween = require 'vendor/tween'
local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local Prompt = require 'prompt'
local utils = require 'utils'
local app = require 'app'

local Door = {}
Door.__index = Door
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Door.isInteractive = true
Door.isDoor = true

function Door.new(node, collider)
  local door = {}
  setmetatable(door, Door)
    
  door.level = node.properties.level
    
  --if you can go to a level, setup collision detection
  --otherwise, it's just a location reference
  if door.level then
    door.player_touched = false
    door.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    door.bb.node = door
    collider:setPassive(door.bb)
  end
    
  door.instant  = node.properties.instant
  door.warpin = node.properties.warpin
  door.button = node.properties.button and node.properties.button or 'UP'
  --either a specific sound or false to disable
  door.sound = node.properties.sound and node.properties.sound or true
  if door.sound == 'false' then door.sound = false end
  door.info = node.properties.info
  door.closedinfo = node.properties.closedinfo
  door.to = node.properties.to
  door.height = node.height
  door.width = node.width
  door.node = node
  door.key = node.properties.key
  door.trigger = node.properties.trigger or '' -- Used to show hideable doors based on gamesave triggers.
  
  door.inventory = node.properties.inventory    
  door.hideable = node.properties.hideable == 'true' and not app.gamesaves:active():get(door.trigger, false)
  door.open = app.gamesaves:active():get(door.trigger, false)
    
  -- generic support for hidden doors
  if door.hideable then
    -- necessary for opening/closing doors with a trigger
    door.hidden = true
    door.sprite = love.graphics.newImage('images/hiddendoor/' .. node.properties.sprite .. '.png')
    door.sprite_width = tonumber( node.properties.sprite_width )
    door.sprite_height = tonumber( node.properties.sprite_height )
    door.grid = anim8.newGrid( door.sprite_width, door.sprite_height, door.sprite:getWidth(), door.sprite:getHeight())
    door.animode = node.properties.animode and node.properties.animode or 'once'
    door.anispeed = node.properties.anispeed and tonumber( node.properties.anispeed ) or 1
    door.aniframes = node.properties.aniframes and node.properties.aniframes or '1,1'
    door.animation = anim8.newAnimation(door.animode, door.grid(door.aniframes), door.anispeed)
    door.anispeed2 = node.properties.anispeed2 and tonumber( node.properties.anispeed2 ) or 1
    door.aniframes2 = node.properties.aniframes2 and node.properties.aniframes2 or '1,1'
    door.animation2 = anim8.newAnimation(door.animode, door.grid(door.aniframes2), door.anispeed2)
    door.position_hidden = {
      x = node.x + ( node.properties.offset_hidden_x and tonumber( node.properties.offset_hidden_x ) or 0 ),
      y = node.y + ( node.properties.offset_hidden_y and tonumber( node.properties.offset_hidden_y ) or 0 )
    }
    door.position_shown = {
      x = node.x + ( node.properties.offset_shown_x and tonumber( node.properties.offset_shown_x ) or 0 ),
      y = node.y + ( node.properties.offset_shown_y and tonumber( node.properties.offset_shown_y ) or 0 )
    }
    door.position = utils.deepcopy(door.position_hidden)
    door.movetime = node.properties.movetime and tonumber(node.properties.movetime) or 1
  end

  return door
end

function Door:switch(player)
  local _, _, _, wy2  = self.bb:bbox()
  local _, _, _, py2 = player.bottom_bb:bbox()
    
  if player.currently_held and not player.currently_held.isWeapon then
    player:drop()
  end

  self.player_touched = false
  if math.abs(wy2 - py2) > 10 or player.jumping then
    return
  end

  if not self.key or (player.inventory:hasKey(self.key) and not self.inventory) or self.open then
    if self.sound ~= false and not self.instant then
      sound.playSfx( ( type(self.sound) ~= 'boolean' ) and self.sound or 'unlocked' )
    end
    local current = Gamestate.currentState()
    if current.name ~= self.level then
      current:exit(self.level, self.to)
    else
      local destDoor = current.doors[self.to]
      player.position.x = destDoor.x+destDoor.node.width/2-player.width/2
      player.position.y = destDoor.y+destDoor.node.height-player.height
    end
  else
    sound.playSfx('locked')
    player.freeze = true
    
    if player.inventory:hasKey(self.key) and self.closedinfo then
      message = {self.closedinfo}
    elseif self.info then
	  message = {self.info}
    else
	  message = {'You need a "'..self.key..'" key to open this door.'}
    end

    local callback = function(result)
      self.prompt = nil
      player.freeze = false
    end
    local options = {'Exit'}
    self.prompt = Prompt.new(message, callback, options)
  end
end

function Door:collide(node)
  if self.hideable and self.hidden then return end
  if not node.isPlayer then return end
    
  if self.instant then
    self:switch(node)
  end
end

function Door:keypressed( button, player)
  if player.freeze or player.dead then return end
  if self.hideable and self.hidden and not self.inventory then return end
  if button == self.button or button=="INTERACT" then
    self:switch(player)
    return true
  end
end

-- everything below this is required for hidden doors
function Door:show(previous)
  -- level check is to ensure that the player is using a switch and not re-entering a level
  if self.hideable and self.hidden and ( not previous or previous.name ~= self.level ) then
    self.hidden = false
    if self.inventory then
      self.open = true
    end
    sound.playSfx( 'reveal' )
    Tween.start( self.movetime, self.position, self.position_shown )
  end
end

function Door:hide(previous)
  -- level check is to allow door to close on re-entry or close command
  if self.hideable and ( (previous and previous.name == self.level) or not self.hidden ) then
    self.hidden = true
    self.position = utils.deepcopy(self.position_shown)
    sound.playSfx( 'unreveal' )
    Tween.start( self.movetime, self.position, self.position_hidden )
  end
end

function Door:update(dt)
  if self.animation then
    self.animation:update(dt)
  end
    
  if self.animation2 and self.open then
    self.animation2:update(dt)
  end
end

function Door:draw()

  if not self.hideable then return end

  if self.open then
    self.animation2:draw(self.sprite, self.position.x, self.position.y)   
  else
    self.animation:draw(self.sprite, self.position.x, self.position.y)
  end
end

---
-- Returns an user-friendly identifier
-- @return string describing where this door is located in a user-friendly (and hopefully unique) way
function Door:getSourceId()
  local levelName = (self.containerLevel ~= nil and self.containerLevel.name ~= nil and self.containerLevel.name ~= "") and self.containerLevel.name or "(UNKNOWN)"
  local doorName = (self.node ~= nil and self.node.name ~= nil) and self.node.name or ""
  local doorPos = (self.node ~= nil) and string.format("[%s,%s]", tostring(self.node.x), tostring(self.node.y)) or "(UNKNOWN)"

  if doorName == "" then
    return string.format("level %s, (unnamed) door at %s", levelName, doorPos)
  else
    return string.format("level %s, door '%s' at %s", levelName, doorName, doorPos)
  end
end

return Door
