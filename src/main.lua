local correctVersion = require 'correctversion'

if correctVersion then

  require 'utils'
  local debugger = require 'debugger'
  local Gamestate = require 'vendor/gamestate'
  local Level = require 'level'
  local camera = require 'camera'
  local fonts = require 'fonts'
  local sound = require 'vendor/TEsound'
  local window = require 'window'
  local controls = require 'controls'
  local hud = require 'hud'
  local cli = require 'vendor/cliargs'
  local mixpanel = require 'vendor/mixpanel'
  local character = require 'character'
  local cheat = require 'cheat'
  local player = require 'player'

  -- XXX Hack for level loading
  Gamestate.Level = Level

  -- Get the current version of the game
  local function getVersion()
    return split(love.graphics.getCaption(), "v")[2]
  end

  function love.load(arg)
    table.remove(arg, 1)
    local state, door = 'splash', nil

    -- SCIENCE!
    mixpanel.init("ac1c2db50f1332444fd0cafffd7a5543")
    mixpanel.track('game.opened')

    -- set settings
    local options = require 'options'
    options:init()

    cli:add_option("-l, --level=NAME", "The level to display")
    cli:add_option("-r, --door=NAME", "The door to jump to ( requires level )")
    cli:add_option("-c, --character=NAME", "The character to use in the game")
    cli:add_option("-o, --costume=NAME", "The costume to use in the game")
    cli:add_option("-m, --money=COINS", "Give your character coins ( requires level flag )")
    cli:add_option("-v, --vol-mute=CHANNEL", "Disable sound: all, music, sfx")
    cli:add_option("-g, --god", "Enable God Mode Cheat")
    cli:add_option("-j, --jump", "Enable High Jump Cheat")
    cli:add_option("-d, --debug", "Enable Memory Debugger")
    cli:add_option("-b, --bbox", "Draw all bounding boxes ( enables memory debugger )")
    cli:add_option("--console", "Displays print info")

    local args = cli:parse(arg)

    if not args then
        love.event.push("quit")
        return
    end

    if args["level"] ~= "" then
      state = args["level"]
    end

    if args["door"] ~= "" then
      door = args["door"]
    end

    if args["character"] ~= "" then
      character:setCharacter( args["c"] )
    end

    if args["costume"] ~= "" then
      character:setCostume( args["o"] )
    end
    
    if args["vol-mute"] == 'all' then
      sound.disabled = true
    elseif args["vol-mute"] == 'music' then
      sound.volume('music',0)
    elseif args["vol-mute"] == 'sfx' then
      sound.volume('sfx',0)
    end

    if args["money"] ~= "" then
      player.startingMoney = tonumber(args["money"])
    end

    
    if args["d"] then
      debugger.set( true, false )
    end

    if args["b"] then
      debugger.set( true, true )
    end
    
    if args["g"] then
      cheat.god = true
    end
    
    if args["j"] then
      cheat.jump_high = true
    end
    
    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    camera:setScale(window.scale, window.scale)
    love.graphics.setMode(window.screen_width, window.screen_height)

    Gamestate.switch(state,door)
  end

  function love.update(dt)
    if paused then return end
    if debugger.on then debugger:update(dt) end
    dt = math.min(0.033333333, dt)
    Gamestate.update(dt)
    sound.cleanup()
  end

  function love.keyreleased(key)
    local button = controls.getButton(key)
    if button then Gamestate.keyreleased(button) end
  end

  function love.keypressed(key)
    if key == 'f5' then debugger:toggle() end
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

    if debugger.on then debugger:draw() end
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
