local app = require 'app'
local store = require 'hawk/store'
local utils = require 'utils'

local Gamestate = require 'vendor/gamestate'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local state = Gamestate.new()
local Player = require 'player'
local window = require 'window'
local controls = require('inputcontroller').get()
local VerticalParticles = require "verticalparticles"
local Menu = require 'menu'

local menu = Menu.new()

function state:onSelectCallback()
  return function(option)
    local options = {
      ['FULLSCREEN'] = 'updateFullscreen',
      ['SHOW FPS'] = 'updateFpsSetting',
      ['SEND PLAY DATA'] = 'updateSendDataSetting',
      ['HARDCORE MODE'] = 'updateHardcore',
      ['SFX VOLUME'] = true,
      ['MUSIC VOLUME'] = true,
    }
    local menus = {
      ['COSTUME'] = 'change_costume',
      ['SAVE GAME'] = 'save_game',
      ['GAME'] = 'game_menu',
      ['RESET SETTINGS'] = 'reset_settings',
      ['RESET SETTINGS/SAVES'] = 'reset_menu',
      ['CANCEL RESET'] = 'game_menu',
      ['AUDIO'] = 'audio_menu',
      ['VIDEO'] = 'video_menu',
      ['BACK TO OPTIONS'] = 'options_menu',
      ['BACK TO MENU'] = 'main_menu',
    }
    if menus[option] then
      self[menus[option]](self)
    elseif options[option] then
      if self.option_map[option].bool ~= nil then
        self.option_map[option].bool = not self.option_map[option].bool
        self[options[option]](self)
      end
    else
      error("Error: Complete the options menu onSelect function! Missing key: " .. option)
    end
  end
end

menu:onSelect(state:onSelectCallback())

local db = store('options-2')

local OPTIONS = {
  { name = 'FULLSCREEN',              bool   = false          },
  { name = 'MUSIC VOLUME',            range  = { 0, 10, 10 }  },
  { name = 'SFX VOLUME',              range  = { 0, 10, 10 }  },
  { name = 'SHOW FPS',                bool   = false          },
  { name = 'SEND PLAY DATA',          bool   = false          },
  { name = 'HARDCORE MODE',           bool   = false          },
}

local MENU = {
  {name = 'COSTUME'},
  {name = 'GAME', page = {
    {name = 'SAVE GAME'},
    {name = 'HARDCORE MODE'},
    {name = 'SEND PLAY DATA'},
    {name = 'RESET SETTINGS/SAVES', page = {
      {name = 'CANCEL RESET'},
      {name = 'RESET SETTINGS'},
    }},
    {name = 'BACK TO OPTIONS'},
  }},
  {name = 'AUDIO', page = {
    {name = 'MUSIC VOLUME'},
    {name = 'SFX VOLUME'},
    {name = 'BACK TO OPTIONS'},

  }},
  {name = 'VIDEO', page = {
    {name = 'FULLSCREEN'},
    {name = 'SHOW FPS'},
    {name = 'BACK TO OPTIONS'},
  }},
  {name = 'BACK TO MENU'},
}

function state:init()

    self.background = love.graphics.newImage("images/menu/pause.png")
    self.arrow = love.graphics.newImage("images/menu/medium_arrow.png")
    self.bigarrow = love.graphics.newImage("images/menu/arrow.png")
    self.checkbox_checked = love.graphics.newImage("images/menu/checkbox_checked.png")
    self.checkbox_unchecked = love.graphics.newImage("images/menu/checkbox_unchecked.png")
    self.range = love.graphics.newImage("images/menu/range.png")
    self.range_arrow = love.graphics.newImage("images/menu/small_arrow_up.png")


    self.option_map = {}
    self.options = utils.deepcopy(OPTIONS)
    self.pages = utils.deepcopy(MENU)
    self:options_menu()

    -- Load default options first
    for i, user in pairs(db:get('options', {})) do
      for j, default in pairs(self.options) do
        if user.name == default.name then
            self.options[j] = user
        end
      end
    end

    for i,o in pairs(self.options) do
        if o.name then
            self.option_map[o.name] = self.options[i]
        end
    end

    self:updateFullscreen()
    self:updateSettings()
    self:updateFpsSetting()
    self:updateSendDataSetting()
    self:updateHardcore()
end

function state.switchMenu(menu)
  local newMenu = {}
  for i,page in pairs(menu) do
    for k,v in pairs(page) do
      if k == 'name' then
        table.insert(newMenu, v)
      end
    end
  end
  return newMenu
end

function state:options_menu()
  menu.options = self.switchMenu(self.pages)
  self.page = 'optionspage'
  menu.selection = 0
end

function state:game_menu()
  menu.options = self.switchMenu(self.pages[2].page)
  self.page = 'gamepage'
  menu.selection = 0
end

function state:audio_menu()
  menu.options = self.switchMenu(self.pages[3].page)
  self.page = 'audiopage'
  menu.selection = 0
end

function state:video_menu()
  menu.options = self.switchMenu(self.pages[4].page)
  self.page = 'videopage'
  menu.selection = 0
end

function state:reset_menu()
  menu.options = self.switchMenu(self.pages[2].page[4].page)
  self.page = 'resetpage'
  menu.selection = 0
end

function state:main_menu()
  self:options_menu()
  if self.target then
    Gamestate.switch('pause')
  else
    Gamestate.switch(self.previous)
  end
end

function state:change_costume()
  if not self.target then sound.playSfx('dbl_beep') return end
  Gamestate.switch('costumeselect', self.target)
end

function state:save_game()
  if not self.target then sound.playSfx('dbl_beep') return end
  local gamesave = app.gamesaves:active()
  local player = Player.factory()
  gamesave:set('savepoint', {level=self.target.name})
  player:saveData(gamesave)
  gamesave:flush()
end

function state:updateHardcore()
  app.config.hardcore = self.option_map['HARDCORE MODE'].bool
end

function state:update(dt)
    VerticalParticles.update(dt)
end

function state:enter(previous, target)
    fonts.set( 'big' )
    sound.playMusic( "daybreak" )
    VerticalParticles.init()

    camera:setPosition(0, 0)
    self.previous = previous
    self.target = target
end

function state:leave()
  self:updateSettings()
  db:set('options', self.options)
  db:flush()
  fonts.reset()
end

function state:updateFullscreen()
    if self.option_map['FULLSCREEN'].bool then
        utils.setMode(0, 0, true)
        local width = love.graphics:getWidth()
        local height = love.graphics:getHeight()
        camera:setScale( window.width / width , window.height / height )
        love.mouse.setVisible(false)
    else
        camera:setScale(window.scale,window.scale)
        utils.setMode(window.screen_width, window.screen_height, false)
        love.mouse.setVisible(true)
    end
end

function state:updateFpsSetting()
    window.showfps = self.option_map['SHOW FPS'].bool
end

function state:updateSendDataSetting()
  local setting = self.option_map['SEND PLAY DATA']
  app.config.tracker = setting and setting.bool or false
end

function state:updateSettings()
    sound.volume('music', self.option_map['MUSIC VOLUME'].range[3] / 10)
    sound.volume('sfx', self.option_map['SFX VOLUME'].range[3] / 10)
end

function state.reset_settings(self)
    -- Reset saves
    for slotNumber=1, 2, 3 do
        app.gamesaves:delete( slotNumber )
    end

    -- Reset all settings
    self.option_map = {}
    self.options = utils.deepcopy(OPTIONS)

    for i,o in pairs(self.options) do
        if o.name then
            self.option_map[o.name] = self.options[i]
        end
    end

    self:updateFullscreen()
    self:updateSettings()
    self:updateFpsSetting()
    self:updateSendDataSetting()
    self:updateHardcore()

    db:set('options', self.options)
    db:flush()

    sound.playSfx('beep')
    love.timer.sleep(0.5)
    self:main_menu()
end

function state:keypressed( button )
    -- Flag to track if the options need to be updated
    -- Used to minimize the number of db:flush() calls to reduce UI stuttering
    local updateOptions = false

    menu:keypressed(button)

    if button == 'START' then
        self:main_menu()
        return
    end

    if self.page == 'audiopage' then
      local opt = self.options[menu.selection + 2]
      if button == 'LEFT' then
          if opt.range ~= nil then
              if opt.range[3] > opt.range[1] then
                  sound.playSfx( 'confirm' )
                  opt.range[3] = opt.range[3] - 1
                  updateOptions = true
              end
          end
      elseif button == 'RIGHT' then
          if opt.range ~= nil then
              if opt.range[3] < opt.range[2] then
                  sound.playSfx( 'confirm' )
                  opt.range[3] = opt.range[3] + 1
                  updateOptions = true
              end
          end
      end
    end

    -- Only flush the options db when necessary
    if updateOptions == true then
        self:updateSettings()
        db:set('options', self.options)
        db:flush()
    end
end

function state:draw()
    VerticalParticles.draw()

    love.graphics.setColor(255, 255, 255)
    local back = controls:getKey("START") .. ": BACK TO MENU"
    love.graphics.print(back, 25, 25)


    local y = 96

    love.graphics.draw(self.background, 
      camera:getWidth() / 2 - self.background:getWidth() / 2,
      camera:getHeight() / 2 - self.background:getHeight() / 2)

    love.graphics.setColor( 0, 0, 0, 255 )

    local xoffset = self.page == 'optionspage' and 20 or 0
    
    for n, opt in pairs(menu.options) do
        if tonumber( n ) ~= nil  then
            love.graphics.print( opt, 150 + xoffset, y)
            if self.option_map[opt] then
              local option = self.option_map[opt]
              if option.bool ~= nil then
                  if option.bool then
                      love.graphics.draw( self.checkbox_checked, 366, y )
                  else
                      love.graphics.draw( self.checkbox_unchecked, 366, y )
                  end
              elseif option.range ~= nil then
                  love.graphics.draw( self.range, 336, y + 2 )
                  love.graphics.draw( self.range_arrow, 338 + ( ( ( self.range:getWidth() - 1 ) / ( option.range[2] - option.range[1] ) ) * ( option.range[3] - 1 ) ), y + 9 )
              end
            end
            y = y + 26
        end
    end

    if self.page ~= 'optionspage' then
      love.graphics.draw( self.arrow, 138, 124 + ( 26 * ( menu.selection - 1 ) ) )
    else
      love.graphics.setColor(255,255,255,255)
      love.graphics.draw( self.bigarrow, 138, 116 + ( 26 * ( menu.selection - 1) ) )
    end
    love.graphics.setColor( 255, 255, 255, 255 )
end

return state
