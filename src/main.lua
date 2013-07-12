require 'utils'

local app = nil

function love.errhand(msg)
  print(msg)
  if app then app:errhand(msg) end
end

function love.releaseerrhand(msg)
  if app then app:releaseerrhand(msg) end
end


local core = require 'hawk/core'
local test = require 'hawk/test'

local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'
local timer = require 'vendor/timer'
local cli = require 'vendor/cliargs'
local mixpanel = require 'vendor/mixpanel'

local debugger = require 'debugger'
local camera = require 'camera'
local fonts = require 'fonts'
local window = require 'window'
local controls = require 'controls'
local hud = require 'hud'
local character = require 'character'
local cheat = require 'cheat'
local player = require 'player'
local Dialog = require 'dialog'
local Prompt = require 'prompt'


function love.load(arg)
  -- Check if this is the correct version of LOVE
  if not (type(love._version) == "string" and love._version == "0.8.0") then
    error("Love 0.8.0 is required")
  end

  table.remove(arg, 1)
  local state, door, position = 'splash', nil, nil

  -- set settings
  local options = require 'scenes/options'
  options()

  cli:add_option("-t, --test", "Run the game in test mode")
  cli:add_option("-l, --level=NAME", "The level to display")
  cli:add_option("-r, --door=NAME", "The door to jump to ( requires level )")
  cli:add_option("-p, --position=X,Y", "The positions to jump to ( requires level )")
  cli:add_option("-c, --character=NAME", "The character to use in the game")
  cli:add_option("-o, --costume=NAME", "The costume to use in the game")
  cli:add_option("-m, --money=COINS", "Give your character coins ( requires level flag )")
  cli:add_option("-v, --vol-mute=CHANNEL", "Disable sound: all, music, sfx")
  cli:add_option("-h, --cheat=ALL/CHEAT1,CHEAT2", "Enable certain cheats ( some require level to function, else will crash with collider is nil )")
  cli:add_option("-d, --debug", "Enable Memory Debugger")
  cli:add_option("-b, --bbox", "Draw all bounding boxes ( enables memory debugger )")
  cli:add_option("-n, --locale=LOCALE", "Local, defaults to en-US")
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

  if args["position"] ~= "" then
    position = args["position"]
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

  if args["locale"] ~= "" then
    app.i18n:setLocale(args.locale)
  end

  local argcheats = false
  local cheats = { }
  if args["cheat"] ~= "" then
    argcheats = true

    if string.find(args["cheat"],",") then
      local from  = 1
      local delim_from, delim_to = string.find( args["cheat"], ",", from  )
      while delim_from do
        table.insert( cheats, string.sub( args["cheat"], from , delim_from-1 ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( args["cheat"], ",", from  )
      end
      table.insert( cheats, string.sub( args["cheat"], from  ) )
    else
      if args["cheat"] == "all" then
        cheats = {'jump_high','super_speed','god','slide_attack','give_money','max_health','give_gcc_key','give_weapons','give_materials'}
      else
        cheats = {args["cheat"]}
      end
    end
  end


  love.graphics.setDefaultImageFilter('nearest', 'nearest')
  camera:setScale(window.scale, window.scale)
  love.graphics.setMode(window.screen_width, window.screen_height)

  if argcheats then
    for k,arg in ipairs(cheats) do
      cheat:on(arg)
    end
  end

  if args["t"] then
    app = test.Runner('config.json')
  else
    app = core.Application('config.json')
  end

  mixpanel.init(app.config.iteration)
  mixpanel.track('game.opened')

  app:redirect('/title')
end

function love.update(dt)
  if debugger.on then debugger:update(dt) end
  dt = math.min(0.033333333, dt)

  if Prompt.currentPrompt then
    Prompt.currentPrompt:update(dt)
  end
  if Dialog.currentDialog then
    Dialog.currentDialog:update(dt)
  end

  if app then app:update(dt) end

  tween.update(dt > 0 and dt or 0.001)
  timer.update(dt)
  sound.cleanup()
end

function love.keyreleased(key)
  local button = controls.getButton(key)

  if not button then 
    return 
  end

  if Prompt.currentPrompt or Dialog.currentDialog then
    --bypass
  else
    if app then app:buttonreleased(button) end
  end
end

function love.keypressed(key)
  if controls.enableRemap and app then 
    app:keypressed(key)
    return
  end

  if key == 'f5' then debugger:toggle() end
  if key == "f6" and debugger.on then debug.debug() end
  local button = controls.getButton(key)

  if not button then return end
  if Prompt.currentPrompt then
    Prompt.currentPrompt:keypressed(button)
  elseif Dialog.currentDialog then
    Dialog.currentDialog:keypressed(button)
  else
    if app then app:buttonpressed(button) end
  end
end

function love.draw()
  camera:set()

  if app then app:draw() end

  fonts.set('arial')
  if Dialog.currentDialog then
    Dialog.currentDialog:draw()
  end
  if Prompt.currentPrompt then
    Prompt.currentPrompt:draw()
  end
  fonts.revert()
  camera:unset()

  if debugger.on then debugger:draw() end
  -- If the user has turned the FPS display on AND a screenshot is not being taken
  if window.showfps and window.dressing_visible then
    love.graphics.setColor( 255, 255, 255, 255 )
    fonts.set('big')
    love.graphics.print( love.timer.getFPS() .. ' FPS', love.graphics.getWidth() - 100, 5, 0, 1, 1 )
    fonts.revert()
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
