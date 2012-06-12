local Queue = require 'queue'
local Timer = require 'vendor/timer'

local game = {}
game.step = 10000
game.friction = 0.146875 * game.step
game.accel = 0.046875 * game.step
game.deccel = 0.5 * game.step
game.gravity = 0.21875 * game.step
game.airaccel = 0.09375 * game.step
game.airdrag = 0.96875 * game.step
game.max_x = 300
game.max_y= 600

local health = love.graphics.newImage('images/damage.png')

local Player = {}
Player.__index = Player

function Player.new(collider)
    local plyr = {}

    setmetatable(plyr, Player)
    plyr.jumpQueue = Queue.new()
    plyr.halfjumpQueue = Queue.new()
    plyr.rebounding = false
    plyr.invulnerable = false
    plyr.jumping = false
    plyr.flash = false
    plyr.width = 48
    plyr.height = 48
    plyr.sheet = nil 
    plyr.actions = {}
    plyr.position = {x=0, y=0}
    plyr.velocity = {x=0, y=0}
    plyr.state = 'idle'       -- default animation is idle
    plyr.direction = 'right'  -- default animation faces right
    plyr.animations = {}

    plyr.collider = collider
    plyr.bb = collider:addRectangle(0,0,18,44)
    plyr:moveBoundingBox()
    plyr.bb.player = plyr -- wat

    --for damage text
    plyr.healthText = {x=0, y=0}
    plyr.healthVel = {x=0, y=0}
    plyr.health = 100
    plyr.damageTaken = 0

    return plyr
end


function Player:loadCharacter(character)
    self.animations = character.animations
    self.sheet = character.sheet
    self.character = character
end

function Player:animation()
    return self.animations[self.state][self.direction]
end


function Player:accel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.accel
    end
end

function Player:deccel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.deccel
    end
end

function Player:moveBoundingBox()
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + (self.height / 2) + 2)
end

function Player:update(dt)
    if not self.invulnerable then
        self:stopBlink()
    end

    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if (love.keyboard.isDown('left') or love.keyboard.isDown('a')) and not self.rebounding then

        if self.velocity.x > 0 then
            self.velocity.x = self.velocity.x - (self:deccel() * dt)
        elseif self.velocity.x > -game.max_x then
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.velocity.x < -game.max_x then
                self.velocity.x = -game.max_x
            end
        end

    elseif (love.keyboard.isDown('right') or love.keyboard.isDown('d')) and not self.rebounding then

        if self.velocity.x < 0 then
            self.velocity.x = self.velocity.x + (self:deccel() * dt)
        elseif self.velocity.x < game.max_x then
            self.velocity.x = self.velocity.x + (self:accel() * dt)
            if self.velocity.x > game.max_x then
                self.velocity.x = game.max_x
            end
        end

    else
        if self.velocity.x < 0 then
            self.velocity.x = math.min(self.velocity.x + game.friction * dt, 0)
        else
            self.velocity.x = math.max(self.velocity.x - game.friction * dt, 0)
        end
    end

    local jumped = self.jumpQueue:flush()
    local halfjumped = self.halfjumpQueue:flush()

    if jumped and not self.jumping and self.velocity.y == 0 and not self.rebounding then
        self.jumping = true
        self.velocity.y = -670
        love.audio.play(love.audio.newSource("audio/jump.ogg", "static"))
    end

    if halfjumped and self.velocity.y < -450 and not self.rebounding and self.jumping then
        self.velocity.y = -450
    end

    self.velocity.y = self.velocity.y + game.gravity * dt

    if self.velocity.y > game.max_y then
        self.velocity.y = game.max_y
    end
    -- end sonic physics
    
    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt

    -- These calculations shouldn't need to be offset, investigate
    -- Min and max for the level
    if self.position.x < -self.width / 4 then
        self.position.x = -self.width / 4
    elseif self.position.x > self.boundary.width - self.width * 3 / 4 then
        self.position.x = self.boundary.width - self.width * 3 / 4
    end

    action = nil
    
    self:moveBoundingBox()

    if self.velocity.x < 0 then
        self.direction = 'left'
    elseif self.velocity.x > 0 then
        self.direction = 'right'
    end

    if self.velocity.y < 0 then

        self.state = 'jump'
        self:animation():update(dt)

    elseif self.state == 'jump' and not self.jumping then

        self.state = 'walk'
        self:animation():update(dt)

    elseif self.state == 'idle' and self.velocity.x ~= 0 then

        self.state = 'walk'
        self:animation():gotoFrame(1)

    elseif self.state == 'walk' and self.velocity.x == 0 then

        self.state = 'idle'
        self:animation():update(dt)

    else
        self:animation():update(dt)

    end

    self.healthText.y = self.healthText.y + self.healthVel.y * dt
end

function Player:die(damage)
    if self.invulnerable then
        return
    end

    love.audio.play(love.audio.newSource("audio/hit.wav", "static"))
    self.rebounding = true
    self.invulnerable = true

    if damage ~= nil then
        self.healthText.x = self.position.x + self.width / 2
        self.healthText.y = self.position.y
        self.healthVel.y = -35
        self.damageTaken = damage
    end

    Timer.add(1.5, function() 
        self.invulnerable = false
        self.flash = false
    end)

    self:startBlink()
end


function Player:stopBlink()
    if self.blink then
        Timer.cancel(self.blink)
        self.blink = nil
    end
    self.damageTaken = 0
    self.flash = false
end


function Player:startBlink()
    if not self.blink then
        self.blink = Timer.addPeriodic(.12, function()
            self.flash = not self.flash
        end)
    end
end


function Player:draw()
    if self.flash then
        love.graphics.setColor(255, 0, 0)
    end

    self:animation():draw(self.sheet, math.floor(self.position.x),
                                      math.floor(self.position.y))

    if self.rebounding and self.damageTaken > 0 then
        love.graphics.draw(health, self.healthText.x, self.healthText.y)
    end

    love.graphics.setColor(255, 255, 255)
end

return Player
