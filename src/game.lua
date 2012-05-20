local anim8 = require 'vendor/anim8'

local game = {}

local directionKeys = {}
directionKeys.left = false --true if the left key is currently pressed
directionKeys.right = false --true if the right key is currently pressed

Player = {}
Player.__index = Player

function Player.create(sheet_path)
    local sheet = love.graphics.newImage(sheet_path)
    local plyr = {}
    local g = anim8.newGrid(92, 92, sheet:getWidth(), sheet:getHeight())

    setmetatable(plyr, Player)
    plyr.jumpfunc = function(x) return 0 end
    plyr.sheet = sheet
    plyr.pos = {x=300, y=450}
    plyr.vel = {x=0, y=0}
    plyr.state = 'idle'
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

function Player:direction()
    if self.vel.x < 0 then
        return 'left'
    else 
        return 'right'
    end
end


function Player:animation()
    return self.animations[self.state][self:direction()]
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
        self.jumpfunc = game.jumpFunction(200, .75)
        self.state = state
    elseif state ~= 'idle' then
        self.state = state
    end
end

function Player:draw()
    self:animation():draw(self.sheet, self.pos.x, self.pos.y)
end

function Player:reset(direction)
    self.animations['walk'][direction]:gotoFrame(1)
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


function Player:update(dt)
    self.x = self.x + dt
    self.pos.x = self.pos.x + self.vel.x
    if self.state == 'jump' then
        self.pos.y = 450 + math.min(self.jumpfunc(self.x), 0)

        if self.pos.y == 450 then
            if self.vel.x == 0 then
                self.state = 'idle'
            else
                self.state = 'walk'
            end
        end

    end
    self:animation():update(dt)
end

function game.load()
    love.audio.stop()
    bg = love.graphics.newImage("images/studyroom_scaled.png")

    player = Player.create("images/abed_sheet.png")

    music = love.audio.newSource("audio/level.ogg")
    music:setLooping(true)
    love.audio.play(music)

end

function game.update(dt)
    player:update(dt)
end

function game.keyreleased(key)
    if (key == "left" or key == "right") then
	directionKeys[key] = false
	
	if directionKeys.left == true then
	  player.vel.x = -3
	  player:transition('walk')
	elseif directionKeys.right == true then
	  player.vel.x = 3
	  player:transition('walk')
	else
	  player:transition('idle', key)
	  player:reset(key)
	end
    end
end

function game.keypressed(key)
    if key == "left" then
	directionKeys[key] = true
        player.vel.x = -3
        player:transition('walk')
    elseif key == "right" then
	directionKeys[key] = true
        player.vel.x = 3
        player:transition('walk')
    elseif key == " " then
        player.vel.y = -1
        player:transition('jump')
    end
end


function game.draw()
    love.graphics.draw(bg)
    player:draw()
end


return game
