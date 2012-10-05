local correctVersion = require 'correctversion'
if correctVersion then
    
local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local camera = require 'camera'
local fonts = require 'fonts'
local paused = false
local showfps = true
local sound = require 'vendor/TEsound'
local window = require 'window'

-- will hold the currently playing sources

function love.load(arg)
    local state = 'home'
    local player = nil
    
    -- process command line options
    for x = 2, #arg, 1 do
        if string.sub( arg[x], 1, 2 ) == '--' then
            local split,_ = string.find( arg[x], '=' )
            if split then
                local key = string.sub( arg[x], 3, split - 1 )
                local value = string.sub( arg[x], split + 1 )
                if key == 'level' then
                    state = value
                elseif key == 'character' then
                    local character = require ( 'characters/' .. value )
		    local costume = love.graphics.newImage('images/characters/' .. value .. '/base.png')
                    player = character.new(costume)
                elseif key == 'mute' then
                    if value == 'all' then
                        sound.volume('music',0)
                        sound.volume('sfx',0)
                    elseif value == 'music' then
                        sound.volume('music',0)
                    elseif value == 'sfx' then
                        sound.volume('sfx',0)
                    end
                end
            end
        end
    end

    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    camera:setScale(window.scale, window.scale)
    love.graphics.setMode(window.screen_width, window.screen_height)

    -- set settings
    local options = require 'options'
    options:init()

    local loader = require 'loader'
    loader:target(state,player)

    Gamestate.switch(loader)
end

function love.update(dt)
    if paused then return end
    dt = math.min(0.033333333, dt)
    Gamestate.update(dt)
    sound.cleanup()
end

function love.keyreleased(key)
    Gamestate.keyreleased(key)
end

function love.focus(f)
    paused = not f
    if not f then 
        sound.pause('music')
        sound.pause('sfx')
    else
        sound.resume('music')
        sound.resume('sfx')
    end
end

function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.draw()
    camera:set()
    Gamestate.draw()
    camera:unset()

    if paused then
        love.graphics.setColor(75, 75, 75, 125)
        love.graphics.rectangle('fill', 0, 0, love.graphics:getWidth(),
                                love.graphics:getHeight())
        love.graphics.setColor(255, 255, 255, 255)
    end

    if showfps then
        fonts.set( 'big' )
        love.graphics.print(love.timer.getFPS() .. ' FPS', 10, 10 )
        fonts.revert()
    end
end

-- Override the default screenshot functionality so we can disable the fps before taking it
local newScreenshot = love.graphics.newScreenshot
function love.graphics.newScreenshot()
    local hadfps = showfps
    showfps = false
    love.draw()
    local ss = newScreenshot()
    showfps = hadfps
    return ss
end

end
