local correctVersion = require 'correctversion'
if correctVersion then

  require 'utils'
  local Gamestate = require 'vendor/gamestate'
  local Level = require 'level'
  local camera = require 'camera'
  local fonts = require 'fonts'
  local sound = require 'vendor/TEsound'
  local window = require 'window'
  local controls = require 'controls'
  local hud = require 'hud'
  local cli = require 'vendor/cliargs'
  local character = require 'character'

  -- XXX Hack for level loading
  Gamestate.Level = Level

  -- will hold the currently playing sources

  function love.load(arg)
    table.remove(arg, 1)
    local state = 'splash'

    -- SCIENCE!
    love.thread.newThread('ping', 'ping.lua'):start()

    -- set settings
    local options = require 'options'
    options:init()

    cli:add_option("-l, --level=NAME", "The level to display")
    cli:add_option("-c, --character=NAME", "The character to use in the game")
    cli:add_option("-o, --costume=NAME", "The costume to use in the game")
    cli:add_option("-m, --mute=CHANNEL", "Disable sound: all, music, sfx")
    cli:add_option("--console", "Displays print info")

    local args = cli:parse(arg)

    if not args then
        error( "Error parsing command line arguments!")
    end

    if args["level"] ~= "" then
      state = args["level"]
    end

    if args["character"] ~= "" then
      character:setCharacter( args["c"] )
    end

    if args["costume"] ~= "" then
      character:setCostume( args["o"] )
    end
    
    if args["mute"] == 'all' then
      sound.volume('music',0)
      sound.volume('sfx',0)
    elseif args["mute"] == 'music' then
      sound.volume('music',0)
    elseif args["mute"] == 'sfx' then
      sound.volume('sfx',0)
    end

    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    camera:setScale(window.scale, window.scale)
    love.graphics.setMode(window.screen_width, window.screen_height)

    Gamestate.switch(state)
  end

  function love.update(dt)
    if paused then return end
    dt = math.min(0.033333333, dt)
    Gamestate.update(dt)
    sound.cleanup()
  end

  function love.keyreleased(key)
    local button = controls.getButton(key)
    if button then Gamestate.keyreleased(button) end
  end

  function love.keypressed(key)
    local button = controls.getButton(key)
    if button then Gamestate.keypressed(button) end
  end

  function love.draw()
    camera:set()
    Gamestate.draw()
    camera:unset()

    if paused then
      love.graphics.setColor(75, 75, 75, 125)
      love.graphics.rectangle('fill', 0, 0, love.graphics:getWidth(),
      love.graphics:getHeight())
      love.graphics.setColor(255, 255, 255, 255)
    end

  end

  -- Override the default screenshot functionality so we can disable the fps before taking it
  local newScreenshot = love.graphics.newScreenshot
  function love.graphics.newScreenshot()
    window.dressing_visible = false
    love.draw()
    local ss = newScreenshot()
    window.dressing_visible = true
    return ss
  end

end
