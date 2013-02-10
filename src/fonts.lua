local fonts = { 'arial', 'courier', 'big' }

local glyphs = " abcdefghijklmnopqrstuvwxyz" ..
               "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
               "123456789.,!?-+/\\:;%&`'*#=\"$()<>{}" ..
               "\225\236\243\250\241\191\161\233\252" .. --  á   í   ó   ú   ñ   ¿   ¡   é   ü
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
