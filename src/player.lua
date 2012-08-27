local Queue = require 'queue'
local Timer = require 'vendor/timer'
local Helper = require 'helper'
local window = require 'window'
local cheat = require 'cheat'

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

local healthbar = love.graphics.newImage('images/health.png')
healthbar:setFilter('nearest', 'nearest')

local healthbarq = {}

for i=6,0,-1 do
    table.insert(healthbarq, love.graphics.newQuad(28 * i, 0, 28, 27,
                             healthbar:getWidth(), healthbar:getHeight()))
end

local health = love.graphics.newImage('images/damage.png')

local Player = {}
Player.__index = Player

---
-- Create a new Player
-- @param collider
-- @return Player
function Player.new(collider)
    local plyr = {}

    setmetatable(plyr, Player)
    plyr.jumpQueue = Queue.new()
    plyr.halfjumpQueue = Queue.new()
    plyr.rebounding = false
    plyr.invulnerable = false
    plyr.jumping = false
    plyr.quicksand = false
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
    plyr.warpin = false
    plyr.dead = false
    plyr.crouch_state = 'crouch'
    plyr.gaze_state = 'gaze'
    plyr.walk_state = 'walk'
    plyr.hand_offset = 10
    plyr.freeze = false

    plyr.holding = nil
    plyr.holdable = nil

    plyr.collider = collider
    plyr.bb = collider:addRectangle(0,0,18,44)
    plyr:moveBoundingBox()
    plyr.bb.player = plyr -- wat

    --for damage text
    plyr.healthText = {x=0, y=0}
    plyr.healthVel = {x=0, y=0}
    plyr.health = 6
    plyr.damageTaken = 0


    return plyr
end

---
-- Loads a character sheet
-- @param character
-- @return nil
function Player:loadCharacter(character)
    self.animations = character.animations
    self.sheet = character.sheet
    self.hand_offset = character.hand_offset
    self.character = character
end

---
-- Gets the current animation based on the player's state and direction
-- @return Animation
function Player:animation()
    return self.animations[self.state][self.direction]
end

---
-- Respawn the player in the Study Hall
-- @return nil
function Player:respawn()
    self.warpin = true
    self.animations.warp:gotoFrame(1)
    love.audio.play("audio/respawn.ogg")
    Timer.add(0.30, function() self.warpin = false end)
end

---
-- Gets the current acceleration speed
-- @return Number the acceleration to apply
function Player:accel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.accel
    end
end

---
-- Gets the current deceleration speed
-- @return Number the deceleration to apply
function Player:deccel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.deccel
    end
end

---
-- After the sprites position is updated this function will move the bounding
-- box so that collisions keep working.
-- @see Helper.moveBoundingBox()
-- @return nil
function Player:moveBoundingBox()
    Helper.moveBoundingBox(self)
end

---
-- This is the main update loop for the player, handling position updates.
-- @param dt The time delta
-- @return nil
function Player:update(dt)
    if self.freeze then
        return
    end

    local crouching = love.keyboard.isDown('down') or love.keyboard.isDown('s')
    local gazing = love.keyboard.isDown('up') or love.keyboard.isDown('w')
    local movingLeft = love.keyboard.isDown('left') or love.keyboard.isDown('a')
    local movingRight = love.keyboard.isDown('right') or love.keyboard.isDown('d')

    if not self.invulnerable then
        self:stopBlink()
    end

    if self.health <= 0 then
        return
    end

    if self.warpin then
        self.animations.warp:update(dt)
        return
    end

    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if movingLeft and not movingRight and not self.rebounding then

        if crouching then
            self.velocity.x = self.velocity.x + (self:accel() * dt)
            if self.velocity.x > 0 then
                self.velocity.x = 0
            end
        elseif self.velocity.x > 0 then
            self.velocity.x = self.velocity.x - (self:deccel() * dt)
        elseif self.velocity.x > -game.max_x then
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.velocity.x < -game.max_x then
                self.velocity.x = -game.max_x
            end
        end

    elseif movingRight and not movingLeft and not self.rebounding then

        if crouching then
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.velocity.x < 0 then
                self.velocity.x = 0
            end
        elseif self.velocity.x < 0 then
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

    if jumped and not self.jumping and self.velocity.y == 0
        and not self.rebounding and not self.quicksand then
        self.jumping = true
        if cheat.jump_high then
            self.velocity.y = -970
        else
            self.velocity.y = -670
        end
        love.audio.play("audio/jump.ogg")
    elseif jumped and not self.jumping and self.velocity.y > -1
        and not self.rebounding and self.quicksand then
     -- Jumping through quicksand:
        self.jumping = true
        self.velocity.y = -270
        love.audio.play("audio/jump.ogg")
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

        self.state = self.walk_state
        self:animation():update(dt)

    elseif self.state ~= 'jump' and self.velocity.x ~= 0 then

        if crouching then
          self.state = self.crouch_state
        else
          self.state = self.walk_state
        end

        self:animation():update(dt)

    elseif self.state ~= 'jump' and self.velocity.x == 0 then

        if crouching and gazing then
            self.state = 'idle'
        elseif crouching then
            self.state = self.crouch_state
        elseif gazing then 
            self.state = self.gaze_state
        elseif self.holding then
            self.state = 'hold'
        else
            self.state = 'idle'
        end

        self:animation():update(dt)

    else
        self:animation():update(dt)
    end

    self.healthText.y = self.healthText.y + self.healthVel.y * dt
end

---
-- Called whenever the player takes damage, if the damage inflicted causes the
-- player's health to fall to or below 0 then it will transition to the dead
-- state.
-- This function handles displaying the health display, playing the appropriate
-- sound clip, and handles invulnearbility properly.
-- @param damage The amount of damage to deal to the player
--
function Player:die(damage)
    if self.invulnerable or cheat.god then
        return
    end

    love.audio.play("audio/damage_" .. math.max(self.health, 0) ..".ogg")
    self.rebounding = true
    self.invulnerable = true

    if damage ~= nil then
        self.healthText.x = self.position.x + self.width / 2
        self.healthText.y = self.position.y
        self.healthVel.y = -35
        self.damageTaken = damage
        self.health = math.max(self.health - damage, 0)
    end

    if self.health == 0 then -- change when damages can be more than 1
        self.state = 'dead'
    end

    Timer.add(1.5, function() 
        self.invulnerable = false
        self.flash = false
    end)

    self:startBlink()
end

---
-- Stops the player from blinking, clearing the damage queue, and correcting the
-- flash animation
-- @return nil
function Player:stopBlink()
    if self.blink then
        Timer.cancel(self.blink)
        self.blink = nil
    end
    self.damageTaken = 0
    self.flash = false
end

---
-- Starts the player blinking every .12 seconds if they are not already blinking
-- @return nil
function Player:startBlink()
    if not self.blink then
        self.blink = Timer.addPeriodic(.12, function()
            self.flash = not self.flash
        end)
    end
end

---
-- Draws the player to the screen
-- @return nil
function Player:draw()
    if self.warpin then
        local y = self.position.y - self.character.beam:getHeight() + self.height + 4
        self.animations.warp:draw(self.character.beam, self.position.x + 6, y)
        return
    end

    if self.blink then
        love.graphics.drawq(healthbar, healthbarq[self.health + 1],
                            math.floor(self.position.x) - 18,
                            math.floor(self.position.y) - 18)
    end

    if self.flash then
        love.graphics.setColor(255, 0, 0)
    end

    self:animation():draw(self.sheet, math.floor(self.position.x),
                                      math.floor(self.position.y))

    if self.holdable and self.holding then
        self.holdable:draw()
    end

    if self.rebounding and self.damageTaken > 0 then
        love.graphics.draw(health, self.healthText.x, self.healthText.y)
    end

    love.graphics.setColor(255, 255, 255)
end

---
-- Registers an object as something that the user can currently hold on to
-- @param holdable
-- @return nil
function Player:registerHoldable(holdable)
	if self.holdable == nil and self.holding == nil then
		self.holdable = holdable
	end
end

---
-- Cancels the holdability of a node
-- @param holdable
-- @return nil
function Player:cancelHoldable(holdable)
	if self.holdable == holdable then
		self.holdable = nil
	end
end

return Player
