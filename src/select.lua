local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local fonts = require 'fonts'
local background = require 'selectbackground'
local sound = require 'vendor/TEsound'
local character = require 'character'
local controls = require('inputcontroller').get()

local state = Gamestate.new()

-- The current selected page

function state:init()
  self.side = 0 -- 0 for left, 1 for right
  self.level = 0 -- 0 through 3 for characters
  self.current_page = 1

  background.init()
  self.chartext = ""
  self.costtext = ""
  self.randomtext = ""
end

function state:enter(previous)
  self.current_page = 1

  self.character_selections = {}
  self.characters = {}
  self.costumes = {}

  self.character_selections[1] = {} -- main characters
  self.character_selections[1][0] = {} -- left
  self.character_selections[1][1] = {} -- right
  self.character_selections[1][1][0] = 'troy'
  self.character_selections[1][1][1] = 'shirley'
  self.character_selections[1][1][2] = 'pierce'
  self.character_selections[1][0][0] = 'jeff'
  self.character_selections[1][0][1] = 'britta'
  self.character_selections[1][0][2] = 'abed'
  self.character_selections[1][0][3] = 'annie'

  self.character_selections[2] = {} -- page 2
  self.character_selections[2][0] = {} -- left
  self.character_selections[2][1] = {} -- right
  self.character_selections[2][1][0] = 'chang'
  self.character_selections[2][1][1] = 'fatneil'
  self.character_selections[2][1][2] = 'vicedean'
  self.character_selections[2][0][0] = 'dean'
  self.character_selections[2][0][1] = 'guzman'
  self.character_selections[2][0][2] = 'buddy'
  self.character_selections[2][0][3] = 'leonard'

  self.character_selections[3] = {} -- page 3
  self.character_selections[3][0] = {} -- left
  self.character_selections[3][1] = {} -- right
  self.character_selections[3][1][0] = 'duncan'
  self.character_selections[3][1][1] = 'rich'
  self.character_selections[3][1][2] = 'vicki'
  self.character_selections[3][0][0] = 'vaughn'
  self.character_selections[3][0][1] = 'garrett'
  self.character_selections[3][0][2] = 'gilbert'

  self.selections = self.character_selections[self.current_page]

  fonts.set('big')
  self.previous = previous
  background.enter()
  background.setSelected(self.side, self.level)

  self.chartext = "PRESS " .. controls:getKey('JUMP') .. " TO CHOOSE CHARACTER" 
  self.costtext = "PRESS " .. controls:getKey('ATTACK') .. " or " ..controls:getKey('INTERACT') .. " TO CHANGE COSTUME"
  self.randomtext = "PRESS " .. controls:getKey('SELECT') .. " TO GET A RANDOM COSTUME"
end

function state:character()
  local name = self.selections[self.side][self.level]

  if not name then
    return nil
  end

  return self:loadCharacter(name)
end

function state:loadCharacter(name)
  if not self.characters[name] then
    self.characters[name] = character.load(name)
    self.characters[name].count = 1
    self.characters[name].costume = 'base'
  end

  return self.characters[name]
end

function state:keypressed( button )
  if button == "START" then
    Gamestate.switch("welcome")
    return true
  end

  -- If any input is received while sliding, speed up
  if background.slideIn or background.slideOut then
    background.speed = 10
    return
  end

  local level = self.level
  local options = 4

  if button == 'LEFT' or button == 'RIGHT' then
    self.side = (self.side - 1) % 2
    sound.playSfx('click')
  elseif button == 'UP' then
    level = (self.level - 1) % options
    sound.playSfx('click')
  elseif button == 'DOWN' then
    level = (self.level + 1) % options
    sound.playSfx('click')
  elseif button == 'ATTACK' then
    if self.level == 3 and self.side == 1 then
      return
    else
      local c = self:character()
      if c then
        c.count = (c.count + 1)
        if c.count == (#c.costumes + 1) then
          c.count = 1
        end
        c.costume = c.costumes[c.count].sheet
        sound.playSfx('click')
      end
    end
    return
  elseif button == 'INTERACT' then
    if self.level == 3 and self.side == 1 then
      return
    else
      local c = self:character()
      if c then
        c.count = (c.count - 1)
        if c.count == 0 then
          c.count = #c.costumes
        end
        c.costume = c.costumes[c.count].sheet
        sound.playSfx('click')
      end
    end
    return
  elseif button == 'SELECT' then
    local c = self:character()
    if c then
      c.count = math.random(#c.costumes)
      c.costume = c.costumes[c.count].sheet
      sound.playSfx('click')
    end
  end

  self.level = level

  if ( button == 'JUMP' ) and self.level == 3 and self.side == 1 then
    self.current_page = self.current_page % #self.character_selections + 1
    self.selections = self.character_selections[self.current_page]
    sound.playSfx('confirm')
  elseif button == 'JUMP' then
    if self:character() then
      -- Tell the background to transition out before changing scenes
      background.slideOut = true
    end
    sound.playSfx('confirm')
  end

  background.setSelected(self.side, self.level)
end

function state:leave()
  fonts.reset()
  background.leave()

  self.character_selections = nil
  self.characters = nil
  self.costumes = nil
  self.selections = nil
  self.previous = nil
end

function state:update(dt)
  -- The background returns 'true' when the slide-out transition is complete
  if background.update(dt) then
    -- set the selected character and costume
    local currentPick = self:character()

    character.pick(currentPick.name, currentPick.costume)

    -- Probably don't need this anymore
    local current = character.current()
    current.changed = true

    love.graphics.setColor(255, 255, 255, 255)

    local level = Gamestate.get('overworld')
    level:reset()

    Gamestate.switch('flyin')
  end
end

function state:drawCharacter(name, x, y, offset)
  local char = self:loadCharacter(name)
  local key = name .. char.costume

  if not self.costumes[key] then
    self.costumes[key] = character.getCostumeImage(name, char.costume)
  end

  local image = self.costumes[key]

  if not char.mask then
    char.mask = love.graphics.newQuad(0, char.offset, 48, 35,
                                      image:getWidth(), image:getHeight())
  end

  if offset then
    love.graphics.draw(image, char.mask, x, y, 0, -1, 1)
  else
    love.graphics.draw(image, char.mask, x, y)
  end
end


function state:draw()
  background.draw()

  -- Only draw the details on the screen when the background is up
  if not background.slideIn then
    local name = ""

    if self:character() then
      name = self:character().costumes[self:character().count].name
    end

    love.graphics.printf(self.chartext, 0, window.height - 75, window.width, 'center')
    love.graphics.printf(self.costtext, 0, window.height - 55, window.width, 'center')
    love.graphics.printf(self.randomtext, 0, window.height - 35, window.width, 'center')

    love.graphics.printf(name, 0,
    23, window.width, 'center')

    local x, y = background.getPosition(1, 3)
    love.graphics.setColor(255, 255, 255, 200)
    love.graphics.print("INSUFFICIENT", x, y + 5, 0, 0.5, 0.5, 12, -6)
    love.graphics.print(  "FRIENDS"   , x, y + 5, 0, 0.5, 0.5, -12, -32)
    love.graphics.print(self.current_page .. ' / ' .. #self.character_selections, x + 60, y + 15, 0, 0.5, 0.5 )
    love.graphics.setColor(255, 255, 255, 255)
  end

  for i=0,1,1 do
    for j=0,3,1 do
      local character_name = self.selections[i][j]
      local x, y = background.getPosition(i, j)
      if character_name then
        self:drawCharacter(character_name, x, y, i == 0)
      end
    end
  end
end

Gamestate.home = state

return state
