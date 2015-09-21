local gamestate = require "vendor/gamestate"
local Board = require "board"
local camera = require "camera"
local fonts = require 'fonts'
local Dialog = {}

Dialog.__index = Dialog

Dialog.currentDialog = nil

function Dialog.new(message, callback, drawable, size)
  local d = Dialog.create(message, size)
  d:reposition()
  d:open(callback)
  d.drawable = drawable
  Dialog.currentDialog = d
  return d
end

function Dialog.create(message, size)
  local say = {}
  setmetatable(say, Dialog)
  if size == 'small' then
    say.board = Board.new(156, 80)
  else
    say.board = Board.new(312, 60)
  end
  say.line = 1
  say.cursor = 0
  say.y = camera.y + camera:getHeight() - 60
  say.x = camera.x + camera:getWidth() / 2
  

  if type(message) == 'string' then
    say.messages = {message}
  else
    say.messages = message
  end

  say.blink = 0
  say.state = 'closed'
  say.result = false
  return say
end

function Dialog:open(callback)
  self.callback = callback
  Dialog.currentDialog = self
  self.board:open()
  self.state = 'opened'
end

function Dialog:close()
  self.board:close()
  self.state = 'closing'
end

function Dialog:reposition()
  local state = gamestate.currentState()

  if state.player and state.player.character.state ~= 'acquire' then
    state.player.character.state = state.player.idle_state
  end

  if (state.player and state.player.position.y + state.player.height + 35 > self.y)
     or state.floorspace then
    self.y = camera.y + 100
  end
end

function Dialog:bbox()
    return self.x - 156, self.y - 30, self.x + 156, self.y + 30
end

function Dialog:update(dt)
  local rate = 15
  self.blink = self.blink + dt < .50 and self.blink + dt or 0
  self.board:update(dt)
  self.cursor = math.min(self.cursor + (dt * rate), string.len(self.messages[self.line]))
  
  if self.board.state == 'closed' and self.state ~= 'closed' then
    self.state = 'closed'
    Dialog.currentDialog = nil
    if self.callback then self.callback(self.result) end
  end
end

function Dialog:message()
  x, y = self.board:draw(self.x, self.y)

  local message = self.messages[self.line]
  local result = ""

  local font = love.graphics.getFont()
  local lineHeight = love.graphics.getFont():getHeight("line height") * 1.3
  local tasty_temp = fonts.tasty.new(message, 0, 0, self.board.width - 20, love.graphics.getFont(), fonts.colors, lineHeight)
  local lines = tasty_temp.lines
  local ox = math.floor(x - self.board.width / 2 + 10)
  local oy = math.floor(y - (lineHeight * lines / 2) + 4)

  if math.floor(self.cursor) >= message:len() then
    result = message .. (self.blink > .25 and "^" or "")
    tastytext = fonts.tasty.new(result, ox, oy, self.board.width - 20, love.graphics.getFont(), fonts.colors, lineHeight)
  else
    result = string.sub(message, 1, math.floor(self.cursor))
    tastytext = fonts.tasty.new(message, ox, oy, self.board.width - 20, love.graphics.getFont(), fonts.colors, lineHeight)
    tastytext:setSub(1, math.floor(self.cursor))
  end

  return result
end

function Dialog:draw()
  if self.board.state == 'closed' then return end

  x, y = self.board:draw(self.x, self.y)

  if self.board.state == 'opened' then
    self:message()
    tastytext:draw()
  end
  
  if self.drawable then
    self.drawable:draw()
  end

  love.graphics.setColor( 255, 255, 255, 255 )

  return x, y
end

function Dialog:keypressed( button )
  if self.board.state == 'closed' then
    return false
  end

  if button == 'JUMP' then
    if self.cursor < string.len(self.messages[self.line]) then
      self.cursor = string.len(self.messages[self.line])
    elseif self.line ~= #self.messages then
      self.cursor = 0
      self.line = self.line + 1
    else
      self:close()
    end
  end

  return true
end

return Dialog
