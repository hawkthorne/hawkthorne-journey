local tween = require 'vendor/tween'
local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local timer = require 'vendor/timer'

local camera = require 'camera'
local fonts = require 'fonts'
local window = require 'window'
local controls = require('inputcontroller').get()
local character = require 'character'

local testing = false
local paused = false

function love.load(arg)
  -- Check if this is the correct version of LOVE
  local version = love.getVersion()

  if version < 11 then
    error("Love 11 or later is required")
  end

  local state, door, position = 'baseball', nil, nil

  -- set settings
  local options = require 'options'
  options:init()

  -- Choose character and costume
  local char = "pierce"
  local costume = "base"
  character.pick(char, costume)

  love.graphics.setDefaultFilter('nearest', 'nearest')

  Gamestate.switch(state,door,position)
end

function love.update(dt)
  if paused or testing then return end
  dt = math.min(0.033333333, dt)

  Gamestate.update(dt)
  tween.update(dt > 0 and dt or 0.001)
  timer.update(dt)
  sound.cleanup()
end

function buttonreleased(key)
  if testing then return end
  local action = controls:getAction(key)
  if action then Gamestate.keyreleased(action) end

  if not action then return end

  Gamestate.keyreleased(action)
end

function buttonpressed(key)
  if testing then return end
  if controls:isRemapping() then Gamestate.keypressed(key) return end
  local action = controls:getAction(key)
  local state = Gamestate.currentState().name or ""

  if not action and state ~= "welcome" then return end
  Gamestate.keypressed(action)
end

function love.keyreleased(key, scancode)
  buttonreleased(key)
end

function love.keypressed(key, scancode, isrepeat)
  controls:switch()
  buttonpressed(key)
end

function love.gamepadreleased(joystick, key)
  buttonreleased(key)
end

function love.gamepadpressed(joystick, key)
  controls:switch(joystick)
  buttonpressed(key)
end

function love.joystickremoved(joystick)
  controls:switch()
end

function love.joystickreleased(joystick, key)
  if joystick:isGamepad() then return end
  buttonreleased(tostring(key))
end

function love.joystickpressed(joystick, key)
  if joystick:isGamepad() then return end
  controls:switch(joystick)
  buttonpressed(tostring(key))
end

function love.joystickaxis(joystick, axis, value)
  if joystick:isGamepad() then return end
  axisDir1, axisDir2, _ = joystick:getAxes()
  controls:switch(joystick)
  if axisDir1 < 0 then buttonpressed('dpleft') end
  if axisDir1 > 0 then buttonpressed('dpright') end
  if axisDir2 < 0 then buttonpressed('dpup') end
  if axisDir2 > 0 then buttonpressed('dpdown') end
end

function love.draw()
  if testing then return end

  camera:set()
  Gamestate.draw()
  fonts.set('arial')
  fonts.revert()
  camera:unset()

  if paused then
    love.graphics.setColor(75/255, 75/255, 75/255, 125/255)
    love.graphics.rectangle('fill', 0, 0, love.graphics:getWidth(),
    love.graphics:getHeight())
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- If the user has turned the FPS display on AND a screenshot is not being taken
  if window.showfps and window.dressing_visible then
    love.graphics.setColor( 1, 1, 1, 1 )
    fonts.set('big')
    love.graphics.print( love.timer.getFPS() .. ' FPS', love.graphics.getWidth() - 100, 5, 0, 1, 1 )
    fonts.revert()
  end
end

-- Override the default screenshot functionality so we can disable the fps before taking it
local captureScreenshot = love.graphics.captureScreenshot
function love.graphics.captureScreenshot( callback )
  window.dressing_visible = false
  love.draw()
  captureScreenshot( callback )
  window.dressing_visible = true
end
