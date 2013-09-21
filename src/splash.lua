local app = require 'app'

local anim8 = require 'vendor/anim8'
local Gamestate = require 'vendor/gamestate'
local window    = require 'window'
local fonts     = require 'fonts'
local splash    = Gamestate.new()
local camera    = require 'camera'
local sound     = require 'vendor/TEsound'
local controls  = require 'controls'
local timer     = require 'vendor/timer'
local menu      = require 'menu'


function splash:init()

    self.splash = love.graphics.newImage("images/openingmenu.png")
    self.arrow = love.graphics.newImage("images/menu/small_arrow.png")
	self.menu = menu.new({ 'start', 'controls', 'options', 'credits', 'exit' })
    self.menu:onSelect(function(option)
        if option == 'exit' then
            love.event.push("quit")
        elseif option == 'controls' then
            Gamestate.switch('instructions')
        else
            Gamestate.switch(option)
        end
    end)	
end

function splash:enter()
    fonts.set( 'big' )
    camera:setPosition(0, 0)
end

function splash:leave()
    fonts.reset()
end

function splash:keypressed( button )
--disable until all loading stuff has been done?
        self.menu:keypressed(button)
end

-- **THINGS MISSING**
-- want text to be typed out, similar to Dialog
-- print random numbers rather than fixed one
-- menu doesn't show up until everything else is on-screen
-- option to speed it all up

function splash:draw()

	fonts.set('courier')
	love.graphics.setColor( 48, 254, 31, 225 )
	
    love.graphics.print("terminal://", 50, 50, 0, 0.5, 0.5)
	love.graphics.print("operations://loadprogram:(true)", 50, 60, 0, 0.5, 0.5)
	love.graphics.print("program:-journey-to-the-center-of-hawkthorne", 50, 70, 0, 0.5, 0.5)
	love.graphics.print("loading simulation ...", 50, 80, 0, 0.5, 0.5)
	
	for i = 0, 5 do
	    for j = 0, 24 do
		    love.graphics.print(1234567890, 60 + 70*i, 100 + 7*j, 0, 0.4, 0.4)
		end
	end
	
    local x = window.width / 2 - self.splash:getWidth()/2
    local y = window.height / 2 + 50
    love.graphics.draw(self.splash, x, y)

    for n,option in ipairs(self.menu.options) do
        love.graphics.print(app.i18n(option), x + 23, y + 12 * n - 2, 0, 0.5, 0.5)
    end
	
	love.graphics.setColor( 225, 225, 225, 225 )

    love.graphics.draw(self.arrow, x + 12, y + 23 + 12 * (self.menu:selected() - 1))

end

return splash
