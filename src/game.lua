local anim8 = require 'vendor/anim8'
local atl = require 'vendor/AdvTiledLoader'
local camera = require 'camera'
local game = {}

atl.Loader.path = 'maps/'
atl.Loader.useSpriteBatch = true

Player = {}
Player.__index = Player

function Player.create(sheet_path)
    local sheet = love.graphics.newImage(sheet_path)
    local plyr = {}
    local g = anim8.newGrid(46, 46, sheet:getWidth(), sheet:getHeight())

    setmetatable(plyr, Player)
    plyr.jumpfunc = function(x) return 0 end
    plyr.sheet = sheet
    plyr.start = {x=love.graphics.getWidth() / 2 - 23, y=300}
    plyr.pos = {x=0, y=0}
    plyr.vel = {x=0, y=0}
    plyr.state = 'idle'         -- default animation is idle
    plyr.direction = 'right'    -- default animation faces right
    plyr.speed = 200            -- multiplied by dt
    plyr.x = 0
    plyr.animations = {
        jump = {
            right = anim8.newAnimation('once', g('7,2'), 1),
            left = anim8.newAnimation('once', g('7,1'), 1)
        },
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2', '3,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1', '3,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        }
    }
    return plyr
end




function Player:animation()
    return self.animations[self.state][self.direction]
end

function Player:transition(state, key)
    if state == 'idle' and key == 'left' and self.vel.x < 0 then
        self.vel.x = 0
    elseif state == 'idle' and key == 'right' and self.vel.x > 0 then
        self.vel.x = 0
    end
    
    if self.state == 'jump' then
        return
    elseif state == 'idle' and self.vel.x == 0 then
        self.state = state
    elseif state == 'jump' then
        self.x = 0
        self.jumpfunc = game.jumpFunction(100, .75)
        self.state = state
    elseif state ~= 'idle' then
        self.state = state
    end
end

function Player:update(dt, dx, dy)
    self.pos.x = self.pos.x + dx

    if dx < 0 then
        self.direction = 'left'
    elseif dx > 0 then
        self.direction = 'right'
    end

    if self.state == 'idle' and dx ~= 0 then
        self.state = 'walk'
        self:animation():gotoFrame(1)
    elseif self.state == 'walk' and dx == 0 then
        self.state = 'idle'
        self:animation():update(dt)
    else
        self:animation():update(dt)
    end
end

function Player:draw()
    self:animation():draw(self.sheet, self.start.x + self.pos.x,
                                      self.start.y + self.pos.y)
end

function game.jumpFunction(height, duration)
    -- (0,0) (duration / 2, height) (0, duration)
    x1 = 0
    y1 = 0
    x2 = duration / 2 
    y2 = -height
    x3 = duration
    y3 = 0
    denom = (x1 - x2) * (x1 - x3) *(x2 - x3)
    A = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / denom
    B = (x3^2 * (y1 - y2) + x2^2 * (y3 - y1) + x1^2 * (y2 - y3)) / denom
    C = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / denom
    return function(x) 
        return A * math.pow(x, 2) + B * x + C
    end
end




function game.load()
    love.audio.stop()
    bg = love.graphics.newImage("images/studyroom_scaled.png")

    player = Player.create("images/abed_sheet.png")

    map = atl.Loader.load("hallway.tmx")

    music = love.audio.newSource("audio/level.ogg")
    music:setLooping(true)
    love.audio.play(music)

end

function game.update(dt)
    dx = 0

    if love.keyboard.isDown('right') then
        dx = dx + dt * player.speed
    elseif love.keyboard.isDown('left') then
        dx = dx + dt * -player.speed
    end
     
    player:update(dt, dx, 0)
    camera:setPosition(player.pos.x, 0)

end

function game.keyreleased(key)
    -- print('release ' .. key)
end

function game.keypressed(key)
end


function game.draw()
    camera:set()

    map:autoDrawRange(math.floor(camera.x * -1), math.floor(camera.y), 1, 0)
    map:draw()
    player:draw()

    camera:unset()
end


return game
