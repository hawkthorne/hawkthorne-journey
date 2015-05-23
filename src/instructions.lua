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
  VerticalParticles.init()
  
  camera:setPosition(0, 0)
  self.instructions = controls:getActionmap()
  self.previous = previous
  self.option = 0
  self.statusText = ''
  local width, height, flags = love.window.getMode()
  self.width = width*window.scale
  self.height = height*window.scale
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
    (self.width - self.background:getWidth()) / 2,
    (self.height - self.background:getHeight()) / 2)

  local n = 1
  local x = (self.width - window.width)/2
  local y = (self.height - window.height)/2
  
  love.graphics.setColor(255, 255, 255)
  local back = controls:getKey("START") .. ": BACK TO MENU"
  local howto = controls:getKey("ATTACK") .. " OR " .. controls:getKey("JUMP") .. ": REASSIGN CONTROL"

  love.graphics.print(back, 25, 25)
  love.graphics.print(howto, 25, 55)
  love.graphics.print(self.statusText, x + self.left_column, y + 280)
  love.graphics.setColor( 0, 0, 0, 255 )

  for i, button in ipairs(menu.options) do
    local z = y + self.top + self.spacing * (i - 1)
    local key = controls:getKey(button)
    love.graphics.print(descriptions[button], x + self.left_column, z, 0, 0.5)
    love.graphics.print(key, x + self.right_column, z, 0, 0.5)
  end
  
  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.draw(self.arrow, x + 135, y + 87 + self.spacing * menu:selected())
end

function state:remapKey(key)
  local button = menu.options[menu:selected() + 1]
  if not controls:newAction(key, button) then
    self.statusText = "KEY IS ALREADY IN USE"
  else
    if key == ' ' then key = 'space' end
    assert(controls:getKey(button) == key)
    self.statusText = button .. ": " .. key
  end
  controls:disableRemap()
  controls:save()
end

return state
