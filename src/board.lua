local gamestate = require "vendor/gamestate"
local sound = require 'vendor/TEsound'
local camera = require 'camera'

local Board = {}
Board.__index = Board
local corner = love.graphics.newImage('images/corner.png')
local rate = 900

---
-- Create a new Board
-- @param width in pixels
-- @param height in pixels
-- @return Board
function Board.new(width, height)
  local board = {}
  setmetatable(board, Board)
  board.state = 'closed'
  board.width = 6
  board.height = 6
  board.targetWidth = 6
  board.targetHeight = 6
  board.maxWidth = width
  board.maxHeight = height
  return board
end

function Board:open()
  local state = gamestate.currentState()
  if state.player then
    state.player.inventory:close()
    state.player.controlState:inventory()
  end
  sound.playSfx( 'menu_expand' )
  self.state = 'opening'
  self.targetWidth = self.maxWidth
  self.targetHeight = self.maxHeight
end

function Board:close()
  sound.playSfx( 'menu_close' )
  self.state = 'closing'
  self.targetWidth = 6
  self.targetHeight= 6
end

function Board:update(dt)
  -- Hide the board when it isn't opened and finished animating
  self.done = self.width == self.targetWidth and self.height == self.targetHeight

  if self.done and self.state == 'closing' then
    self.state = 'closed'
    local state = gamestate.currentState()
    if not state.scene then
      if state.player then state.player.controlState:standard() end
    end
  end

  if self.done and self.state == 'opening' then
    self.state = 'opened'
  end

  if self.state == 'opened' or self.state == 'opening' then
    if self.height == self.targetHeight then
      self.width = math.min(self.targetWidth, self.width + dt * rate)
    else
      self.height = math.min(self.targetHeight, self.height + dt * rate)
    end
  else
    if self.width == self.targetWidth then
      self.height = math.max(self.targetHeight, self.height - dt * rate)
    else
      self.width = math.max(self.targetWidth, self.width - dt * rate)
    end
  end
end

function Board:draw(x, y)
  if self.state == 'closed' then
    return
  end

  local width = math.floor(self.width)
  local height = math.floor(self.height)
  local halfWidth = math.floor(self.width / 2)
  local halfHeight = math.floor(self.height / 2)

  love.graphics.setColor( 0, 0, 0, 255 )
  love.graphics.rectangle('fill', x - halfWidth, y - halfHeight, width, height)
  love.graphics.setColor( 112, 28, 114, 255 )
  love.graphics.rectangle('line', x - halfWidth, y - halfHeight, width, height)
  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.draw(corner, x - halfWidth - 3, y - halfHeight - 3)
  love.graphics.draw(corner, x - halfWidth - 3, y + halfHeight - 3)
  love.graphics.draw(corner, x + halfWidth - 3, y + halfHeight - 3)
  love.graphics.draw(corner, x + halfWidth - 3, y - halfHeight - 3)

  return x, y --return the updated x and y positions
end

return Board
