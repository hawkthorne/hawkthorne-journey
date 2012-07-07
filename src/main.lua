-- will hold the currently playing sources
local sources = {}

-- check for sources that finished playing and remove them
-- add to love.update
function love.audio.update()
    local remove = {}
    for _,s in pairs(sources) do
        if s:isStopped() then
            remove[#remove + 1] = s
        end
    end

    for i,s in ipairs(remove) do
        sources[s] = nil
    end
end

-- overwrite love.audio.play to create and register source if needed
local play = love.audio.play
function love.audio.play(what, how, loop)
    local src = what
    if type(what) ~= "userdata" or not what:typeOf("Source") then
        src = love.audio.newSource(what, how)
        src:setLooping(loop or false)
    end

    play(src)
    sources[src] = src
    return src
end

-- stops a source
local stop = love.audio.stop
function love.audio.stop(src)
    if not src then return end
    stop(src)
    sources[src] = nil
end

local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local camera = require 'camera'
local paused = false
local atl = require 'vendor/AdvTiledLoader'

atl.Loader.path = 'maps/'
atl.Loader.useSpriteBatch = true

-- will hold the currently playing sources

function love.load()
    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    local width = love.graphics:getWidth()
    local height = love.graphics:getHeight()
    camera:setScale(456 / width , 264 / height)
    love.graphics.setMode(width, height, true)

    local font = love.graphics.newImage("imagefont.png")
    font:setFilter('nearest', 'nearest')

    love.graphics.setFont(love.graphics.newImageFont(font,
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/:;%&`'*#=\""), 35)

    Gamestate.switch(require('loader'))
end

function love.update(dt)
    love.audio.update()
    if paused then return end
    dt = math.min(0.033333333, dt)
    Gamestate.update(dt)
end

function love.keyreleased(key)
    Gamestate.keyreleased(key)
end

function love.focus(f)
    paused = not f
	if not f then 
        love.audio.pause()
    else
        love.audio.resume()
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

    love.graphics.print(love.timer.getFPS() .. ' FPS', 10, 10)
end

