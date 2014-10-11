local Board = require "board"
local Gamestate = require "vendor/gamestate"
local window = require "window"
local fonts = require "fonts"
local dialog = require "dialog"
local Prompt = {}

Prompt.__index = Prompt

local corner = love.graphics.newImage('images/menu/small_corner.png')
local arrow = love.graphics.newImage("images/menu/small_arrow.png")
arrow:setFilter('nearest', 'nearest')
---
-- Create a new Prompt
-- @param message to display
-- @param callback when user answer's prompt
-- @return Prompt
function Prompt.new(message, callback, options, drawable)
  local prompt = {}
  setmetatable(prompt, Prompt)
  prompt.message = message
  prompt.callback = callback
  prompt.options = options or {'Yes','No'}
  prompt.selected = #prompt.options

  local font = fonts.set('arial')

  prompt.width = 0
  prompt.height = 22

  for i,o in pairs( prompt.options ) do
    prompt.width = prompt.width + font:getWidth(o) + 20
  end

  prompt.dialog = dialog.new(message, nil, drawable)

  fonts.revert()
  Prompt.currentPrompt = prompt
  return prompt
end

function Prompt:update(dt)
  if self.dialog.state == 'closed' and self.callback and not self.called then
    self.called = true
    Prompt.currentPrompt = nil
    self.callback(self.options[self.selected])
  end
end

function Prompt:draw()
  if self.dialog.state == 'closed' then
    return
  end

  local font = fonts:set('arial')

  if self.dialog.board.state == 'opened' then --leaky abstraction
    local _, y1, x2, _ = self.dialog:bbox()

    local x = x2 - self.width + self.height / 2
    local y = y1 - self.height / 2

    love.graphics.setColor(112, 28, 114, 255)
    love.graphics.rectangle('fill', x, y, self.width, self.height)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle('line', x, y, self.width, self.height)
    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw(corner, x - 2, y - 2)
    love.graphics.draw(corner, x - 2, y + self.height - 2)
    love.graphics.draw(corner, x - 2 + self.width, y - 2)
    love.graphics.draw(corner, x - 2 + self.width, y + self.height - 2)

    x = x + self.height / 2
    y = y + self.height / 4

    for i,o in pairs( self.options ) do
      love.graphics.setColor( 255, 255, 255, 255 )

      if i == self.selected then
        love.graphics.setColor( 254, 204, 2, 255 )
        love.graphics.draw(arrow, x - arrow:getWidth() - 3, y + 1) 
      end

      love.graphics.print(o, x, y)
      x = x + font:getWidth(o) + 20  --padding
    end
  end
  love.graphics.setColor(255, 255, 255, 255)

  fonts.revert()
end

function Prompt:keypressed( button )
  if self.dialog.state ~= 'opened' then
    return
  end

  if button == 'RIGHT' then
    if self.selected < #self.options then
      self.selected = self.selected + 1
    end
    return true
  elseif button == 'LEFT' then
    if self.selected > 1 then
      self.selected = self.selected - 1
    end
    return true
  end
  return self.dialog:keypressed(button)

end

return Prompt
