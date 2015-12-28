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
    white = {255, 255, 255},
    teal = {74, 205, 180},
    blue_light = {100, 143, 154},
    olive = {190, 198, 149},
    green_light = {90, 145, 111},
    green_dark = {0, 83, 67},
    grey = {139, 139, 139},
    peach = {238, 212, 191},
    yellow = {235, 207, 82},
    orange = {204, 132, 50},
    red_light = {166, 94, 96},
    red = {157, 26,18},
    red_dark = {95, 31, 41},
    purple = {96, 21, 99}
  }
}

for _,x in pairs( fonts ) do
  local img = love.graphics.newImage( "images/fonts/" .. x .. ".png" )
  img:setFilter( 'nearest', 'nearest' )
  Fonts[x] = love.graphics.newImageFont( img, glyphs, 1 )
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
