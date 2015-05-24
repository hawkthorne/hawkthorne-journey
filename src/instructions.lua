local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local controls = require('inputcontroller').get()
local VerticalParticles = require "verticalparticles"
local Menu = require 'menu'
local state = Gamestate.new()

local menu = Menu.new({
  'UP',
  'DOWN',
  'LEFT',
  'RIGHT',
  'SELECT',
  'START',
  'JUMP',
  'ATTACK',
  'INTERACT',
})

local descriptions = {
  UP = 'Move Up / Look',
  DOWN = 'Move Down / Duck',
  LEFT = 'Move Left',
  RIGHT = 'Move Right',
  SELECT = 'Inventory',
  START = 'Pause',
  JUMP = 'Jump / OK',
  ATTACK = 'Attack',
  INTERACT = 'Interact',
}

menu:onSelect(function()
  controls:enableRemap()
  state.statusText = "PRESS NEW KEY" end)

function state:init()
  VerticalParticles.init()

  self.arrow = love.graphics.newImage("images/menu/arrow.png")
  self.background = love.graphics.newImage("images/menu/pause.png")
  self.instructions = {}

  -- The X coordinates of the columns
  self.left_column = 160
  self.right_column = 300
  -- The Y coordinate of the top key
  self.top = 95
  -- Vertical spacing between keys
  self.spacing = 17

end

function state:enter(previous)
  fonts.set( 'big' )
  sound.playMusic( "daybreak" )

  camera:setPosition(0, 0)
  self.instructions = controls:getActionmap()
  self.previous = previous
  self.option = 0
  self.statusText = ''
end

function state:leave()
  fonts.reset()
end

function state:keypressed( button )
  if controls:isRemapping() then self:remapKey(button) end
  if controls.getAction then menu:keypressed(button) end
  if button == 'START' then Gamestate.switch(self.previous) end
end

function state:update(dt)
  VerticalParticles.update(dt)
end

function state:draw()
  VerticalParticles.draw()

  love.graphics.draw(self.background, 
    camera:getWidth() / 2 - self.background:getWidth() / 2,
    camera:getHeight() / 2 - self.background:getHeight() / 2)

  local n = 1

  love.graphics.setColor(255, 255, 255)
  local back = controls:getKey("START") .. ": BACK TO MENU"
  local howto = controls:getKey("ATTACK") .. " OR " .. controls:getKey("JUMP") .. ": REASSIGN CONTROL"

  love.graphics.print(back, 25, 25)
  love.graphics.print(howto, 25, 55)
  love.graphics.print(self.statusText, self.left_column, 280)
  love.graphics.setColor( 0, 0, 0, 255 )

  for i, button in ipairs(menu.options) do
    local y = self.top + self.spacing * (i - 1)
    local key = controls:getKey(button)

    -- Show default global keys if they aren't already assigned
    if button == "START" and key ~= "escape" then key = key .. " / ESCAPE" end
    if button == "JUMP" and key ~= "return" then key = key .. " / ENTER" end

    love.graphics.print(descriptions[button], self.left_column, y, 0, 0.5)
    love.graphics.print(key, self.right_column, y, 0, 0.5)
  end
  
  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.draw(self.arrow, 135, 87 + self.spacing * menu:selected())
end

function state:remapKey(key)
  local button = menu.options[menu:selected() + 1]
  if not controls:newAction(key, button) then
    self.statusText = "KEY IS ALREADY IN USE"
  else
    if key == ' ' then key = 'space' end
    -- Don't bother checking for the RETURN or ESCAPE key as they are globals
    if key ~= 'return' and key ~= 'escape' then
      assert(controls:getKey(button) == key)
    end
    if button == "START" and key ~= "escape" then key = key .. " or ESCAPE" end
    if button == "JUMP" and key ~= "return" then key = key .. " or ENTER" end
    self.statusText = button .. ": " .. key
  end
  controls:disableRemap()
  controls:save()
end

return state
