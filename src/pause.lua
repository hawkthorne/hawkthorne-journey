local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()


local options = {
    'Resume',
    'Options',
    'Quit to Map',
    'Quit to Menu',
    'Quit to Desktop',
}
-- Should these attributes be contained within the state table?
local screen_width, screen_height
local menu_left, menu_right, menu_top, menu_bottom
local menu_width, menu_height
local x_anchor
-- This is used to detect the mouse over an option. It's the percentage
-- of menu space occupied by a single option. Poorly named.
local option_percent = 1 / #options

function state:init()
    self.arrow = love.graphics.newImage('images/menu/arrow.png')
    self.background = love.graphics.newImage('images/menu/pause.png')
    
    -- For some reason drawing coordinates are based off of the background 
    -- image size, rather than the screen size. In this case the background 
    -- size is half of the screen size.
    screen_width = self.background:getWidth()
    screen_height = self.background:getHeight()
    
    menu_left = screen_width * .25
    menu_right = screen_width * .75
    menu_top = screen_height * .25
    menu_bottom = screen_height * .75
    
    menu_width = menu_right - menu_left
    menu_height = menu_bottom - menu_top
    
    -- The longest string is center aligned within the menu, and each
    -- shorter string is aligned to the left of the longest.
    local longest_string
    local max_length = 0
    for index, option in pairs(options) do
        if (#option > max_length) then
            longest_string = index
            max_length = #option
        end
    end
    
    local longest_width = fonts.big:getWidth(options[longest_string])
    x_anchor = (screen_width - longest_width) / 2
end

local function changeState()
    if state.option == 0 then
        Gamestate.switch(state.previous)
    elseif state.option == 1 then
        Gamestate.switch('options')
    elseif state.option == 2 then
        Gamestate.switch('overworld')
    elseif state.option == 3 then
        state.previous:quit()
        Gamestate.switch(Gamestate.home)
    elseif state.option == 4 then
        love.event.push('quit')
    end
end

function state:enter(previous)
    self.music = sound.playMusic('daybreak')

    fonts.set('big')

    camera:setPosition(0, 0)
    self.option = 0
    
    if previous ~= Gamestate.get('options') then
        self.previous = previous
    end
    
    self.konami = { 'UP', 'UP', 'DOWN', 'DOWN', 'LEFT', 'RIGHT', 'LEFT', 'RIGHT', 'B', 'A' }
    self.konami_idx = 0
end

function state:leave()
    fonts.reset()
end

function state:keypressed(button)
    if button == 'UP' then
        self.option = (self.option - 1) % 5
    elseif button == 'DOWN' then
        self.option = (self.option + 1) % 5
    end

    if button == 'START' then
        Gamestate.switch(self.previous)
        return
    end
    
    if button == 'A' or button == 'SELECT' then
        changeState()
    end

    if self.konami[self.konami_idx + 1] == button then
        self.konami_idx = self.konami_idx + 1
    else
        self.konami_idx = 0
    end
    
    if self.konami_idx == #self.konami then
        Gamestate.switch('cheatscreen', self.previous)
    end
end

function state:mousepressed(x, y, button)
    if button == 'wu' then
        self.option = (self.option - 1) % 5
    elseif button == 'wd' then
        self.option = (self.option + 1) % 5
    end
    
    if button == 'l' then
        changeState()
    end
end

local mouse_x, mouse_y
function state:update()
    local x = love.mouse.getX() / 2
    local y = love.mouse.getY() / 2
    
    if not mouse_x or not mouse_y then
        mouse_x = x
        mouse_y = y
        return
    end
    
    -- Only register mouse controls if:
    --  The mouse is inside the menu.
    --  The mouse has been moved on this frame.
    -- This allows a user to completely ignore the mouse if they so desire.
    if mouse_x ~= x or mouse_y ~= y then
        if x > menu_left and x < menu_right and
           y > menu_top and y < menu_bottom then
            for index, option in pairs(options) do
                local breakpoint1 = (menu_height * option_percent) * (index - 1) + menu_top
                local breakpoint2 = (menu_height * option_percent) * index + menu_top
                if (y > breakpoint1 and y < breakpoint2) then
                    self.option = index - 1
                end
            end
        end
        
        mouse_x = x
        mouse_y = y
    end
end


function state:draw()
    love.graphics.draw(self.background)

    for index, option in pairs(options) do
        if index - 1 == self.option then
            love.graphics.setColor(255, 255, 255, 255)
        else
            love.graphics.setColor(0, 0, 0, 255)
        end
        
        -- I'd like to change the Y value to be resolution independent but
        -- this is acceptable for now.
        love.graphics.print(option, x_anchor, 101 + 30 * (index - 1))
    end

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.arrow, 156, 96 + 30 * self.option)
end


return state

