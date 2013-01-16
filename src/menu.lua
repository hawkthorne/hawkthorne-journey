local sound = require 'vendor/TEsound'

local menu = {}
menu.__index = menu

function menu.new(options)
  local m = {}
  setmetatable(m, menu)
  m.options = options or {}
  m.handlers = {}
  m.selection = 0
  return m
end

function menu:onSelect(func)
  self.handlers['select'] = func
end

function menu:selected()
  return self.selection
end

function menu:keypressed(button)
  if button == 'ATTACK' or button == "JUMP" then
    local option = self.options[self.selection + 1]
    if self.handlers['select'] then
      sound.playSfx( 'confirm' )
      self.handlers['select'](option)
    end
  elseif button == "UP" then
      sound.playSfx( 'click' )
    self.selection = (self.selection - 1) % #self.options
  elseif button == "DOWN" then
      sound.playSfx( 'click' )
    self.selection = (self.selection + 1) % #self.options
  end
end

return menu
