local app       = require 'app'
local Gamestate = require 'vendor/gamestate'
local camera    = require 'camera'
local character = require 'character'
local sound     = require 'vendor/TEsound'
local fonts     = require 'fonts'
local player    = require 'player'
local state     = Gamestate.new()
local window    = require 'window'
local controls  = require('inputcontroller').get()
local VerticalParticles = require "verticalparticles"

function state:init()
  self.name = 'start'
  VerticalParticles.init()

  self.background = love.graphics.newImage("images/menu/pause.png")
  self.arrow = love.graphics.newImage("images/menu/arrow.png")
  self.option_map = {}
  self.options = {
    --           display name       slot number
    { name = 'SLOT 1',        slot = 1 },
    { name = 'SLOT 2',        slot = 2 },
    { name = 'SLOT 3',        slot = 3 },
  }
  for i,o in pairs( self.options ) do
    if o.name then
      self.option_map[o.name] = self.options[i]
    end
  end
  self.selection = 0
  self.selectionDelete = 0
end

function state:update( dt )
  VerticalParticles.update( dt )
end

function state:enter( previous )
  fonts.set( 'big' )
  camera:setPosition( 0, 0 )
  self.previous = previous
  self.window = 'main'
end

function state:leave()
  fonts.reset()
end

function state:startGame(dt)
  local gamesave = app.gamesaves:active()
  local point = gamesave:get('savepoint', {level='studyroom', name='main'})
  Gamestate.switch(point.level, point.name)
end

-- Loads the given slot number
-- @param slotNumber the slot number to load
function state:load_slot( slotNumber )
  app.gamesaves:activate( slotNumber )
  local gamesave = app.gamesaves:active()
  local characterN = gamesave:get('characterName')
  local costumeN = gamesave:get('costumeName')
  local point = gamesave:get('savepoint')
  
  if characterN ~= nil and costumeN ~= nil then
    character.pick(characterN, costumeN)
  end

  if point ~= nil and point.level ~= nil then
    local current = character.current()
    current.changed = true
    Gamestate.switch(point.level, point.name)
  else
    Gamestate.switch( 'autosave_warning' )
  end
end

-- Gets the saved slot's level name, or the empty string
-- @param slotNumber the slot number to get the level name for
function state.get_slot_level(slotNumber)
  local gamesave = app.gamesaves:all()[ slotNumber ]
  if gamesave ~= nil then
    local savepoint = gamesave:get( 'savepoint' )
    if savepoint ~= nil and savepoint.level ~= nil then
      -- If the level name is too long, then produce a shortened name for display purposes
      if savepoint.level:len() > 16 then
        local shortName = savepoint.level:sub( 0, 11 )
        shortName = shortName .. '..' .. savepoint.level:sub( -3 )
        return shortName
      else
        return savepoint.level
      end
    end
  else
    print( "Warning: no gamesave information for slot: " .. slotNumber )
  end
  return "<empty>"
end

function state:keypressed( button )

  if button == 'START' then
    if self.previous.name then
      Gamestate.switch( self.previous )
    else
      Gamestate.switch( 'welcome' )
    end
    return
  end

  if self.window == 'main' then
    local option = self.options[ self.selection + 1 ]

    if  button == 'ATTACK' or button == 'JUMP' then
      sound.playSfx('click')
      if option.slot then
        -- Load the selected slot
        self:load_slot( option.slot )
      elseif option.action then
        self[option.action]()
      end
    elseif button == 'INTERACT' then
      app.gamesaves:activate( option.slot )
      local gamesave = app.gamesaves:active()
      local savepoint = gamesave:get( 'savepoint' )
      if savepoint ~= nil then
        sound.playSfx('confirm')
        self.window = 'deleteSlot'
      else
        sound.playSfx('unlocked')
      end
    elseif button == 'UP' then
      sound.playSfx('click')
      self.selection = (self.selection - 1) % #self.options
      while self.options[self.selection + 1].name == nil do
        self.selection = (self.selection - 1) % #self.options
      end
    elseif button == 'DOWN' then
      sound.playSfx('click')
      self.selection = (self.selection + 1) % #self.options
      while self.options[self.selection + 1].name == nil do
        self.selection = (self.selection + 1) % #self.options
      end
    end
  elseif self.window == 'deleteSlot' then
    if button == 'UP' or button == 'DOWN' then
      sound.playSfx('click')
      self.selectionDelete = (self.selectionDelete + 1)%2
    elseif button == 'JUMP' and self.selectionDelete == 0 then
      sound.playSfx('beep')
      app.gamesaves:delete( self.selection + 1 )
      Gamestate.switch( 'start' )
    elseif button == 'JUMP' then
        self.window = 'main'
    end  
  end   
end

function state:draw()
  VerticalParticles.draw()
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.background,
    camera:getWidth() / 2 - self.background:getWidth() / 2,
    camera:getHeight() / 2 - self.background:getHeight() / 2)
  
  if self.window == 'main' then
    love.graphics.setColor(255, 255, 255)
    local howto = controls:getKey("ATTACK") .. " OR " .. controls:getKey("JUMP") .. ": SELECT SLOT"
    local delete = controls:getKey("INTERACT") .. ": DELETE SLOT"
    love.graphics.print(howto, 25, 25)
    love.graphics.print(delete, 25, 55)
    local yFactor = 20

    local y = 90

    love.graphics.setColor( 0, 0, 0, 255 )

    for n, opt in pairs(self.options) do
      if tonumber( n ) ~= nil  then
        if opt.name and opt.slot then
          love.graphics.print( opt.name , 175, y, 0 )
          y = y + yFactor
          love.graphics.print( self.get_slot_level( opt.slot ), 190, y, 0 )
          y = y + yFactor
        elseif opt.name then
          y = y + yFactor
          love.graphics.print( opt.name, 175, y, 0 )
        end
      end
    end
    love.graphics.setColor( 255, 255, 255, 255 )
    -- Determine how far the arrow should move for the last menu item
    local arrowYFactor = 2
    if self.selection > 2 then
      arrowYFactor = 2.5
    end
    love.graphics.draw( self.arrow, 135, 127 + ( (yFactor * arrowYFactor) * ( self.selection - 1 ) ) )
  elseif self.window == 'deleteSlot' then
    love.graphics.setColor(255, 255, 255)
    local howto = controls:getKey("UP") .. " OR " .. controls:getKey("DOWN") .. ": CHANGE OPTION"
    local delete = controls:getKey("JUMP") .. ": SELECT OPTION"
    love.graphics.print(howto, 25, 25)
    love.graphics.print(delete, 25, 55)
    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.printf('Are you sure you want to delete this slot?', 155, 110, self.background:getWidth() - 30, 'left')
    love.graphics.print('Yes', 175, 175, 0)
    love.graphics.print('No', 175, 205, 0)
    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw( self.arrow, 140, 170 + 30 * self.selectionDelete ) 
  end
end

return state
