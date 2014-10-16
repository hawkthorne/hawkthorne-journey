local anim8 = require 'vendor/anim8'
local background = require 'selectbackground'
local character = require 'character'
local controls = require('inputcontroller').get()
local fonts = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local Player = require 'player'
local sound = require 'vendor/TEsound'
local VerticalParticles = require "verticalparticles"
local window = require 'window'

local state = Gamestate.new()

local function nonzeroMod(a,b)
  local m = a%b
  if m==0 then
    return b
  else
    return m
  end
end

function state:init()
  self.name = 'costumeselect'

  VerticalParticles.init()
  background.init()

  self.side = 0 -- 0 for left, 1 for right
  self.level = 0 -- 0 through 3 for characters
  self.page = 'characterPage'
  
  -- shows a maximum of columnHeight*columnsVisible costumes on screen at any one time
  -- player can scroll right to see more (if necessary)
  -- start off at column 1
  self.columnHeight = 5
  self.columnsVisible = 7
  self.leftColumn = 1

  self.chartext = ""
  self.menutext = ""
  self.costtext = ""
  self.backtext = ""
end

function state:enter(previous, target)
  self.selectionBox = love.graphics.newImage('images/menu/selection.png')
  self.backgroundBox = love.graphics.newImage('images/menu/costumeselect.png')
  self.arrow = love.graphics.newImage('images/menu/arrow.png')
  self.page = 'characterPage'

  self.characters = {}
  self.costumes = {}
  self.insufficient = {}

  self.character_selections = {}
  self.character_selections[0] = {} -- left
  self.character_selections[1] = {} -- right
  self.character_selections[0][0] = 'jeff'
  self.character_selections[0][1] = 'britta'
  self.character_selections[0][2] = 'abed'
  self.character_selections[0][3] = 'annie'
  self.character_selections[1][0] = 'troy'
  self.character_selections[1][1] = 'shirley'
  self.character_selections[1][2] = 'pierce'
  
  self.insufficient_list = {}
  self.insufficient_list[1] = 'dean'
  self.insufficient_list[2] = 'chang'
  self.insufficient_list[3] = 'garrett'
  self.insufficient_list[4] = 'fatneil'
  self.insufficient_list[5] = 'leonard'
  self.insufficient_list[6] = 'duncan'
  self.insufficient_list[7] = 'vicki'
  self.insufficient_list[8] = 'vaughn'
  self.insufficient_list[9] = 'vicedean'
  self.insufficient_list[10] = 'gilbert'
  self.insufficient_list[11] = 'rich'
  self.insufficient_list[12] = 'buddy'
  self.insufficient_list[13] = 'guzman'

  fonts.set('big')
  self.previous = previous
  self.target = target
  background.enter()
  background.setSelected(self.side, self.level)

  self.chartext = "PRESS " .. controls:getKey('JUMP') .. " TO CHOOSE CHARACTER"
  self.menutext = "PRESS " .. controls:getKey('START') .. " TO RETURN TO MENU"
  self.costext = "PRESS " .. controls:getKey('JUMP') .. " TO CHOOSE COSTUME" 
  self.backtext = "PRESS " .. controls:getKey('ATTACK') .. " TO CHANGE CHARACTER"
end

function state:character()
  local name = nil
  if self.page == 'insufficientPage' then
    name = self.insuffName
  else
    name = self.character_selections[self.side][self.level]
  end

  if not name then
    return nil
  end

  return self:loadCharacter(name)
end

function state:loadCharacter(name)
  if not self.characters[name] then
    self.characters[name] = character.load(name)
  end

  return self.characters[name]
end

function state:loadInsufficient()
  for i = 1, #self.insufficient_list do
    local name = self.insufficient_list[i]
    local c = self:loadCharacter(name)
    self.insufficient[i] = {}
    self.insufficient[i].count = #c.costumes
    local sum = 0
    if self.insufficient[i-1] then
      sum = self.insufficient[i-1].total
    end
    self.insufficient[i].total = self.insufficient[i].count + sum
    self.insufficient[i].ow = love.graphics.newImage('images/characters/'..self.insufficient_list[i]..'/overworld.png')
    self.insufficient[i].g = anim8.newGrid(36, 36, self.insufficient[i].ow:getDimensions())
  end
  self.insufficientTotal = self.insufficient[#self.insufficient_list].total
  -- count stores costumes per character, total stores costumes so far, Total stores total for all friends
  self.loaded = 1
end

function state:keypressed( button )
  if button == "START" then
    Gamestate.switch(self.previous, self.target)
    return
  end

  -- If any input is received while sliding, speed up
  if background.slideIn or background.slideOut then
    background.speed = 10
    return
  end

  if self.page == 'characterPage' then
    self:characterKeypressed(button)
  elseif self.page == 'costumePage' or self.page == 'insufficientPage' then
    self:costumeKeypressed(button)
  end
end

function state:characterKeypressed(button)
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
  end
  self.level = level

  if ( button == 'JUMP' ) then
    self.row = 1
    self.column = 1
    self.count = 1
    sound.playSfx('confirm')
    if self.level == 3 and self.side == 1 then
      self:switchInsufficientPage()
    else
      self:switchCostumePage()
    end
  end

  background.setSelected(self.side, self.level)
end

function state:costumeKeypressed(button)

  if button == "ATTACK" then
    self:switchCharacterPage()

  elseif button == "JUMP" then
    sound.playSfx('confirm')
    if self:character() then
      self:changeCostume()
    end

  else
    if button == "LEFT" then
      if self.column == 1 then
        sound.playSfx('unlocked')
      else
        self.column = self.column - 1
        sound.playSfx('click')
        self.leftColumn = math.min(self.leftColumn, self.column)
      end

    elseif button == "RIGHT" then
      if self.column == self.rowLength then
        sound.playSfx('unlocked')
      elseif (self.column == self.rowLength - 1 and self.row > self.lastColumnHeight) then
        sound.playSfx('unlocked')
        self.leftColumn = math.min(self.leftColumn + 1, math.max(1, self.column - self.columnsVisible + 2))
      else
        self.column = self.column + 1
        sound.playSfx('click')
        self.leftColumn = math.min(self.leftColumn + 1, math.max(1, self.column - self.columnsVisible + 1))
      end

    elseif button == "DOWN" then
      if self.row == self.columnHeight or (self.column == self.rowLength and self.row == self.lastColumnHeight) then
        sound.playSfx('unlocked')
      else
        self.row = self.row + 1
        sound.playSfx('click')
      end

    elseif button == "UP" then
      if self.row == 1 then
        sound.playSfx('unlocked')
      else
        self.row = self.row - 1
      end
    end
    self.count = (self.column - 1)*self.columnHeight + self.row
    if self.page == 'insufficientPage' then
      self:selectInsufficient()
    end
  end
end

function state:switchCharacterPage()
  self.page = 'characterPage'
end

function state:switchCostumePage()
  self.row = 1
  self.column = 1
  self.leftColumn = 1
  self.count = 1
  local name = self.character_selections[self.side][self.level]
  local c = self.characters[name]
  self.owsprite = love.graphics.newImage('images/characters/'..name..'/overworld.png')
  self.g = anim8.newGrid(36, 36, self.owsprite:getDimensions())
  self.rowLength = math.ceil(#c.costumes / self.columnHeight)
  self.lastColumnHeight = nonzeroMod(#c.costumes, self.columnHeight)
  self.page = 'costumePage'
end

function state:switchInsufficientPage()
  self.row = 1
  self.column = 1
  self.leftColumn = 1
  self.count = 1
  if not self.loaded then
    self:loadInsufficient()
  end
  self.insuffName = self.insufficient_list[1]
  self.insuffCos = 1
  self.rowLength = math.ceil(self.insufficientTotal / self.columnHeight)
  self.lastColumnHeight = nonzeroMod(self.insufficientTotal, self.columnHeight)
  self.page = 'insufficientPage'
end

function state:selectInsufficient()
  local costumeName = 1
  local costumeNumber = 1
  for i = 1, self.count - 1 do
    if costumeNumber < self.insufficient[costumeName].count then
      costumeNumber = costumeNumber + 1
    else
      costumeName = costumeName + 1
      costumeNumber = 1
    end
  end
  self.insuffName = self.insufficient_list[costumeName]
  self.insuffCos = costumeNumber
end

function state:changeCostume()

  local player = Player.factory() -- expects existing player object  
  local name = nil
  local c = nil
  local sheet = nil

  if self.page == 'costumePage' then
    name = self.character_selections[self.side][self.level]
    c = self:loadCharacter(name)
    sheet = c.costumes[self.count].sheet
  elseif self.page == 'insufficientPage' then
    name = self.insuffName
    c = self.characters[self.insuffName]
    sheet = c.costumes[self.insuffCos].sheet
  end
  
  character.pick(name, sheet)
  player.character = character.current()
  
  Gamestate.switch(self.target)
end

function state:leave()
  fonts.reset()
  background.leave()
  VerticalParticles.leave()
  
  target = self.target

  self.character_selections = nil
  self.insufficient_list = nil
  self.insufficient = nil
  self.characters = nil
  self.costumes = nil
  self.previous = nil
  
  self.loaded = nil
end

function state:update(dt)
  background.update(dt)
  VerticalParticles.update(dt)
end

function state:drawCharacter(name, x, y, offset)
  local char = self:loadCharacter(name)
  local key = name .. 'base'

  if not self.costumes[key] then
    self.costumes[key] = character.getCostumeImage(name, 'base')
  end

  local image = self.costumes[key]

  if not char.mask then
    char.mask = love.graphics.newQuad(0, char.offset, 48, 35, image:getDimensions())
  end

  if offset then
    love.graphics.draw(image, char.mask, x, y, 0, -1, 1)
  else
    love.graphics.draw(image, char.mask, x, y)
  end
end

function state:drawFlyin(name, costume, x, y)
  local char = self:loadCharacter(name)
  local key = name .. costume

  if not self.costumes[key] then
    self.costumes[key] = character.getCostumeImage(name, costume)
  end

  local image = self.costumes[key]

  if not char.maskFly then
    char.maskFly = love.graphics.newQuad(528, 192, 48, 48, image:getDimensions())
  end

  love.graphics.draw(image, char.maskFly, x, y - char.offset, 0, 2, 2)
end


function state:draw()

  if self.page == 'characterPage' then
    background.draw()

  -- Only draw the details on the screen when the background is up
    if not background.slideIn then
    
      love.graphics.setColor(255, 255, 255, 255)

      love.graphics.printf(self.chartext, 0, window.height - 65, window.width, 'center')
      love.graphics.printf(self.menutext, 0, window.height - 45, window.width, 'center')
 
      if self.side == 1 and self.level == 3 then
       love.graphics.printf('Insufficient Friends', 0, 23, window.width, 'center')
      else
        local name = ""
        if self:character() then
          name = self:character().costumes[1].name
        end
        love.graphics.printf(name, 0, 23, window.width, 'center')     
      end

      local x, y = background.getPosition(1, 3)
      love.graphics.setColor(255, 255, 255, 200)
      love.graphics.print("INSUFFICIENT", x, y + 5, 0, 0.5, 0.5, 12, -6)
      love.graphics.print(  "FRIENDS"   , x, y + 5, 0, 0.5, 0.5, -12, -32)
      love.graphics.setColor(255, 255, 255, 255)
    end

    for i=0,1,1 do
      for j=0,3,1 do
        local character_name = self.character_selections[i][j]
        local x, y = background.getPosition(i, j)
        if character_name then
          self:drawCharacter(character_name, x, y, i == 0)
        end
      end
    end
  else
    VerticalParticles.draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf(self.costext, 0, window.height - 75, window.width, 'center')
    love.graphics.printf(self.backtext, 0, window.height - 55, window.width, 'center')

    local spacingX = 40
    local spacingY = 40

    local x = (window.width - self.columnsVisible*spacingX)/2 + 30
    local y = (window.height - 125 - self.columnHeight*spacingY)/2

    local i = 1
    local j = 1

    local sideX = 20
    local sideY = (window.height - self.backgroundBox:getHeight())/3

    love.graphics.draw(self.selectionBox, x - 2 + spacingX*(self.column - self.leftColumn + 1), y  + spacingY*self.row)
    love.graphics.draw(self.backgroundBox, sideX, sideY)
    
    if self.leftColumn > 1 then
      love.graphics.draw(self.arrow, x + 35, sideY + 148, 0, -1, 1)
    end
    if self.leftColumn + self.columnsVisible < self.rowLength + 1 then
      love.graphics.draw(self.arrow, x + self.columnsVisible*spacingX + 45, sideY + 148)
    end

    if self.page == 'costumePage' then

      local name = self.character_selections[self.side][self.level]
      local c = self.characters[name]
    
      for k = 1, #c.costumes do
        if i >= self.leftColumn and i < self.leftColumn + self.columnsVisible then
          self.overworld = anim8.newAnimation('once', self.g(c.costumes[k].ow, 1), 1)
          self.overworld:draw(self.owsprite, x + spacingX*(i - self.leftColumn + 1), y + spacingY*j)
        end
        if j < self.columnHeight then
          j = j + 1
        else
          j = 1
          i = i + 1
        end
      end
      love.graphics.printf(c.costumes[self.count].name, 0, 23, window.width, 'center')
      self:drawFlyin(name,c.costumes[self.count].sheet, sideX + 22, sideY + 22)
      
    elseif self.page == 'insufficientPage' then
 
      local name = self.insufficient_list[1]
      local c = self.characters[name]

      for n = 1, #self.insufficient_list do
        name = self.insufficient_list[n]
        c = self.characters[name]
        for k = 1, #c.costumes do
          if i >= self.leftColumn and i < self.leftColumn + self.columnsVisible then
            self.overworld = anim8.newAnimation('once', self.insufficient[n].g(c.costumes[k].ow, 1), 1)
            self.overworld:draw(self.insufficient[n].ow, x + spacingX*(i - self.leftColumn + 1), y + spacingY*j)
          end
          if j < self.columnHeight then
            j = j + 1
          else
            j = 1
            i = i + 1
          end
        end
      end
      local d = self.characters[self.insuffName]
      love.graphics.printf(d.costumes[self.insuffCos].name, 0, 23, window.width, 'center')
      self:drawFlyin(self.insuffName, d.costumes[self.insuffCos].sheet, sideX + 22, sideY + 22)
    end
  end
end

return state
