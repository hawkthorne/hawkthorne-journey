require 'utils'

local tween = require 'vendor/tween'
local Gamestate = require 'vendor/gamestate'
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

math.randomseed(os.time())

function love.load(arg)
  local correctVersion = not ( type(love._version) == "string" and love._version >= "0.8.0" )
  assert(correctVersion, "This game requires LOVE v0.8.0")

  table.remove(arg, 1)

  -- set settings
  local options = require 'options'
  options:init()

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

  -- Gross, clean up this parsing
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

  if argcheats then
    for k,arg in ipairs(cheats) do
      cheat:on(arg)
    end
  end
  -- End grossness

  love.graphics.setDefaultImageFilter('nearest', 'nearest')

  app = application('config.json') 

  -- SCIENCE!
  mixpanel.init("2b45c2198796f3e6e7fb8c47837e4963")
  mixpanel.track('game.opened')
end

function love.update(dt)
  app:update(dt)
end

function love.keyreleased(key)
  app:keyrelease(key)
  local button = controls.getButton(key)
  if button then Gamestate.keyreleased(button) end

  if not button then return end

  if Prompt.currentPrompt or Dialog.currentDialog then
    --bypass
  else
    Gamestate.keyreleased(button)
  end
end

function love.keypressed(key)
  app:keypress(key)
end

function love.draw()
  app:draw()
end
