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

local function __NULL__() end

function state:init()

  VerticalParticles.init()
  background.init()

  self.side = 0 -- 0 for left, 1 for right
  self.level = 0 -- 0 through 3 for characters
  self.page = 'characterPage'
  self.rowLength = 10

  self.chartext = ""
  self.menutext = ""
  self.costtext = ""
  self.backtext = ""
  
end

function state:enter(previous, target)

  self.selectionBox = love.graphics.newImage('images/menu/selection.png')
  self.page = 'characterPage'
  self.characters = {}
  self.costumes = {}

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
  
  self.insufficient = {}
  
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
  local name = self.character_selections[self.side][self.level]

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

    self.insufficientOverworld = {}
    self.insufficientG = {}
    self.insufficientCumulative = {}
    for i = 1, #self.insufficient_list do
      local name = self.insufficient_list[i]
      local c = self:loadCharacter(name)
      self.insufficient[i] = #c.costumes
      self.insufficientCumulative[i] = self.insufficient[i] + (self.insufficientCumulative[i-1] or 0 )
      self.insufficientOverworld[i] = love.graphics.newImage('images/characters/'..self.insufficient_list[i]..'/overworld.png')
      self.insufficientG[i] = anim8.newGrid(36, 36, self.insufficientOverworld[i]:getWidth(), self.insufficientOverworld[i]:getHeight())
    end

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
      for i = 1, #self.insufficient_list do
        local name = self.insufficient_list[i]
        local c = self.characters[name]
      end
      self:loadInsufficient()
      self.insufficientName = self.insufficient_list[1]
      self.insufficientCostume = 1
      self.number = self.insufficientCumulative[#self.insufficient_list]
      self.columnLength = math.ceil(self.number / self.rowLength)
      self.lastRowLength = nonzeroMod(self.number, self.rowLength)
      self.page = 'insufficientPage'
    elseif button == 'JUMP' then
      local name = self.character_selections[self.side][self.level]
      self.owsprite = love.graphics.newImage('images/characters/'..name..'/overworld.png')
      self.g = anim8.newGrid(36, 36, self.owsprite:getWidth(), self.owsprite:getHeight())
      local c = self.characters[name]
      self.number = #c.costumes
      self.columnLength = math.ceil(self.number / self.rowLength)
      self.lastRowLength = nonzeroMod(self.number, self.rowLength)
      self.page = 'costumePage'
    end
  end

  background.setSelected(self.side, self.level)
end

function state:costumeKeypressed(button)

  if button == "LEFT" then
    if self.row == self.columnLength then
      self.column = nonzeroMod(self.column - 1 , self.lastRowLength)
    else
      self.column = nonzeroMod(self.column - 1 , self.rowLength)
    end
    sound.playSfx('click')

  elseif button == "RIGHT" then
    if self.row == self.columnLength then
      self.column = nonzeroMod(self.column + 1 , self.lastRowLength)
    else
      self.column = nonzeroMod(self.column + 1 , self.rowLength)
    end
    sound.playSfx('click')

  elseif button == "DOWN" then
    if (self.row == self.columnLength - 1 and self.column > self.lastRowLength)  then
      self.row = 1
    else
      self.row = nonzeroMod(self.row + 1, self.columnLength)
    end
    sound.playSfx('click')

  elseif button == "UP" then
    if (self.row == 1 and self.column > self.lastRowLength) then
      self.row = self.columnLength - 1
	else
      self.row = nonzeroMod(self.row - 1, self.columnLength)
    end
    sound.playSfx('click')
  end

  self.count = (self.row - 1)*self.rowLength + self.column

  if self.page == 'costumePage' then
    if button == "JUMP" then
      sound.playSfx('confirm')
      if self:character() then
        self:changeCostume()
      end
    elseif button == "ATTACK" then
      sound.playSfx('click')
      self.row = 1
      self.column = 1
      self.count = 1
      self.page = 'characterPage'
    end 
  elseif self.page == 'insufficientPage' then  
    if button == "JUMP" then
      sound.playSfx('confirm')
      -- should check if self:character()
      self:changeCostume()
    elseif button == "ATTACK" then
      sound.playSfx('click')
      self.row = 1
      self.column = 1
      self.count = 1
      self.page = 'characterPage'
    end

  local costumeName = 1
  local costumeNumber = 1
  for i = 1, self.count - 1 do
    if costumeNumber < self.insufficient[costumeName] then
      costumeNumber = costumeNumber + 1
    else
      costumeName = costumeName + 1
      costumeNumber = 1
    end
  end
  self.insufficientName = self.insufficient_list[costumeName]
  self.insufficientCostume = costumeNumber
  end
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
    name = self.insufficientName
    c = self.characters[self.insufficientName]
    sheet = c.costumes[self.insufficientCostume].sheet
  end
  
  character.pick(name, sheet)
  player.character = character.current()
  
  Gamestate.switch(self.target)
end

function state:leave()
  fonts.reset()
  background.leave()
  VerticalParticles.leave()

  self.character_selections = nil
  self.characters = nil
  self.costumes = nil
  self.previous = nil
  target = self.target
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
    char.mask = love.graphics.newQuad(0, char.offset, 48, 35, image:getWidth(), image:getHeight())
  end

  if offset then
    love.graphics.drawq(image, char.mask, x, y, 0, -1, 1)
  else
    love.graphics.drawq(image, char.mask, x, y)
  end
end


function state:draw()

  if self.page == 'characterPage' then
    background.draw()
  
  -- Only draw the details on the screen when the background is up
    if not background.slideIn then
    
      love.graphics.setColor(255, 255, 255, 255)
      local name = ""

      if self:character() then
        name = self:character().costumes[1].name
      end

      love.graphics.printf(self.chartext, 0, window.height - 65, window.width, 'center')
      love.graphics.printf(self.menutext, 0, window.height - 45, window.width, 'center')

      love.graphics.printf(name, 0, 23, window.width, 'center')

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

    local x = (window.width - self.rowLength*spacingX)/2 - 40
    local y = (window.height - 125 - self.columnLength*spacingY)/2

	local i = 1
	local j = 1
    
    love.graphics.draw(self.selectionBox, x - 2 + spacingX*self.column, y  + spacingY*self.row)
    
    if self.page == 'costumePage' then

      local name = self.character_selections[self.side][self.level]
      local c = self.characters[name]
    
	  for k = 1, #c.costumes do
        self.overworld = anim8.newAnimation('once', self.g(c.costumes[k].ow, 1), 1)
        self.overworld:draw(self.owsprite, x + spacingX*i, y + spacingY*j)
	    if i < self.rowLength then
	      i = i + 1
        else
          i = 1
		  j = j + 1
	    end
      end
      love.graphics.printf(c.costumes[self.count].name, 0, 23, window.width, 'center')
      
    elseif self.page == 'insufficientPage' then
 
      local name = self.insufficient_list[1]
      local c = self.characters[name]
 
      for n = 1, #self.insufficient_list do
        name = self.insufficient_list[n]
        c = self.characters[name]
        for k = 1, #c.costumes do
          self.overworld = anim8.newAnimation('once', self.insufficientG[n](c.costumes[k].ow, 1), 1)
          self.overworld:draw(self.insufficientOverworld[n], x + spacingX*i, y + spacingY*j)
	      if i < self.rowLength then
	        i = i + 1
          else
            i = 1
		    j = j + 1
	      end
        end
      end
      local d = self.characters[self.insufficientName]
      love.graphics.printf(d.costumes[self.insufficientCostume].name, 0, 23, window.width, 'center')
    end
  end
end

return state
