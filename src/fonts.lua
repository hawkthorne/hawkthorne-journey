local fonts = { 'arial', 'courier', 'big', 'small' }

local glyphs = " abcdefghijklmnopqrstuvwxyz" ..
               "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
               "123456789.,!?-+/\\:;%&`'*#=\"$()<>{}" ..
               "|||||||||" .. -- Eventuall add these back áíóúñ¿¡éü
               "^" --cursor

local Fonts = {
    _default = 'arial',
    _last = nil
}

for _,x in pairs( fonts ) do
    local img = love.graphics.newImage( "images/fonts/" .. x .. ".png" )
    img:setFilter( 'nearest', 'nearest' )
    Fonts[x] = love.graphics.newImageFont( img, glyphs )
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
