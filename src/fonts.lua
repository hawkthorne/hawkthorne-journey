local fonts = { 'arial', 'courier', 'big', 'small' }

local glyphs = " abcdefghijklmnopqrstuvwxyz" ..
               "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
               "123456789.,!?-+/\\:;%&`'*#=\"$()<>{}" ..
               "|||||||||" .. -- Eventuall add these back áíóúñ¿¡éü
               "^" --cursor

local Fonts = {
  _default = 'arial',
  _last = nil,
  tasty = require 'vendor/tastytext',
  colors = {
    white = {1, 1, 1},
    teal = {74/255, 205/255, 180/255},
    blue_light = {100/255, 143/255, 154/255},
    olive = {190/255, 198/255, 149/255},
    green_light = {90/255, 145/255, 111/255},
    green_dark = {0, 83/255, 67/255},
    grey = {139/255, 139/255, 139/255},
    peach = {238/255, 212/255, 191/255},
    yellow = {235/255, 207/255, 82/255},
    orange = {204/255, 132/255, 50/255},
    red_light = {166/255, 94/255, 96/255},
    red = {157/255, 26/255, 18/255},
    red_dark = {95/255, 31/255, 41/255},
    purple = {96/255, 21/255, 99/255}
  }
}

for _,x in pairs( fonts ) do
  local font = love.graphics.newImageFont("images/fonts/" .. x .. ".png", glyphs, 1)
  font:setFilter( 'nearest', 'nearest' )
  Fonts[x] =  font
end

function Fonts.set( x )
  Fonts._last = love.graphics.getFont()
  if Fonts[x] then
    love.graphics.setFont( Fonts[x] )
  else
    love.graphics.setFont( Fonts[Fonts._default] )
  end
  return love.graphics.getFont()
end

function Fonts.reset()
  Fonts._last = Fonts[Fonts._default]
  love.graphics.setFont( Fonts[Fonts._default] )
end

function Fonts.revert()
  love.graphics.setFont( Fonts._last )
end

Fonts.reset()

return Fonts
