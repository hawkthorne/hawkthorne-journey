local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

local HUD = {}
HUD.__index = HUD

local lens = love.graphics.newImage('images/hud/lens.png')
local lensback = love.graphics.newImage('images/hud/lensback.png')
local chevron = love.graphics.newImage('images/hud/chevron.png')
local energy = love.graphics.newImage('images/hud/energy.png')

lens:setFilter('nearest', 'nearest')
lensback:setFilter('nearest', 'nearest')
chevron:setFilter('nearest', 'nearest')
energy:setFilter('nearest', 'nearest')

function HUD.new(level)
    local hud = {}
    setmetatable(hud, HUD)
    
    local character = level.player.character:current()
        
    hud.sheet = level.player.character:sheet()
    hud.character_quad = love.graphics.newQuad( 0, character.offset or 5, 48, 48, hud.sheet:getWidth(), hud.sheet:getHeight() )
    
    hud.character_stencil = function( x, y )
        love.graphics.circle( 'fill', x + 31, y + 31, 21 )
    end
    
    hud.energy_stencil = function( x, y )
        love.graphics.rectangle( 'fill', x + 31, y + 46, 80, 9 )
    end

    return hud
end

function HUD:draw( player )
    if not window.dressing_visible then
        return
    end

    fonts.set( 'big' )

    self.x, self.y = camera.x + 10, camera.y
    love.graphics.setColor(
        math.min( map( player.health, player.max_health, player.max_health / 2 + 1, 0, 255 ), 255 ), -- green to yellow
        math.min( map( player.health, player.max_health / 2, 0, 255, 0), 255), -- yellow to red
        0,
        255
    )
    love.graphics.setStencil( self.energy_stencil, self.x, self.y )
    love.graphics.draw( energy, self.x - ( player.max_health - player.health ) * 3.2, self.y)

    love.graphics.setStencil( )
    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw( chevron, self.x, self.y)

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.setStencil( self.character_stencil, self.x, self.y )
    local currentWeapon = player.inventory:currentWeapon()
    if currentWeapon and not player.doBasicAttack then
        local position = {x = self.x + 22, y = self.y + 22}
        currentWeapon:draw(position, nil,false)
    else
        love.graphics.drawq( self.sheet, self.character_quad, self.x + 7, self.y + 17 )
    end

    love.graphics.setStencil( )
    love.graphics.draw( lensback, self.x, self.y)

    love.graphics.setColor( 255, 165, 0, 255 )
    love.graphics.setLine(3.5, "smooth")
    local levelexp = player:getExpToCurrentLevel()
    local nextlevelexp= player:getExpToNextLevel()
    local anglecomplete = 2 * math.pi - ((nextlevelexp-player.exp)/(nextlevelexp-levelexp) * 2 * math.pi)
    local radius = 20.5
    local x,y = (self.x + 30) + math.cos((math.pi/2)) * radius, (self.y + 31) -math.sin((math.pi/2)) * radius
    for i=1,360 do
        local angle = (math.pi/2) + ((i / 360) * -anglecomplete)
        local nx, ny = (self.x + 30) + math.cos(angle) * radius, (self.y + 31) -math.sin(angle) * radius
        love.graphics.line(x,y,nx,ny)
        x,y = nx,ny
    end

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.setStencil( )
    love.graphics.draw( lens, self.x, self.y)

    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.print( player.money, self.x + 75, self.y + 19, 0, 0.5, 0.5 )
    love.graphics.print( player.level, self.x + 75, self.y + 28, 0, 0.5, 0.5 )

    if window.showfps then
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.print( love.timer.getFPS() .. ' FPS', self.x + window.width - 50, self.y + 5, 0, 0.5, 0.5 )
    end

    love.graphics.setColor( 255, 255, 255, 255 )

    fonts.revert()
end

return HUD
