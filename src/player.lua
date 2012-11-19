local Queue = require 'queue'
local Timer = require 'vendor/timer'
local Helper = require 'helper'
local window = require 'window'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local game = require 'game'
local controls = require 'controls'
local character = require 'character'
local KeyboardContext = require 'keyboard_context'
local Footprint = require 'nodes/footprint'
local GS = require 'vendor/gamestate'
local SM = require 'statemachine'

local healthbar = love.graphics.newImage('images/healthbar.png')
healthbar:setFilter('nearest', 'nearest')

local Inventory = require('inventory')

local healthbarq = {}

for i=6,0,-1 do
    table.insert(healthbarq, love.graphics.newQuad(28 * i, 0, 28, 27,
                             healthbar:getWidth(), healthbar:getHeight()))
end

local health = love.graphics.newImage('images/damage.png')

local Player = {}
Player.__index = Player
Player.isPlayer = true

-- single 'character' object that handles all character switching, costumes and animation
Player.character = character

local player = nil
---
-- Create a new Player
-- @param collider
-- @return Player
function Player.new(collider)
    local plyr = {}

    setmetatable(plyr, Player)
    
    plyr.kc = KeyboardContext.new("player", true)
    plyr.invulnerable = false
    plyr.actions = {}
    plyr.position = {x=0, y=0}
    plyr.frame = nil
    
    plyr.width = 48
    plyr.height = 48
    plyr.bbox_width = 18
    plyr.bbox_height = 44

    --for damage text
    plyr.healthText = {x=0, y=0}
    plyr.healthVel = {x=0, y=0}
    plyr.max_health = 6
    plyr.health = plyr.max_health

    plyr.inventory = Inventory.new()
    
    plyr.money = 0
    plyr.lives = 3
    
    plyr.acceleration = game.accel
    plyr.deceleration = game.deccel
    plyr.max_velocity = 400

    plyr:refreshPlayer(collider)
    return plyr
end

function Player:refreshPlayer(collider)
    --changes that are made if you're dead
    if self.dead then
        self.health = self.max_health
        self.money = 0
        self.inventory = Inventory.new()
        self.lives = self.lives - 1
    end
    
    if self.character.changed then
        self.character.changed = false
        self.health = self.max_health
        self.money = 0
        self.inventory = Inventory.new()
        self.lives = 3
    end

    self.invulnerable = cheat.god
    self.kc:set()
    self.jumpQueue = Queue.new()
    self.halfjumpQueue = Queue.new()
    self.rebounding = false
    self.damageTaken = 0

    self.jumping = false
    self.liquid_drag = false
    self.flash = false
    self.actions = {}

    self.velocity = {x=0, y=0}
    self.fall_damage = 0
    self.since_solid_ground = 0
    self.dead = false
    self.crouch_state = 'crouch'
    self.gaze_state = 'gaze'
    self.walk_state = 'walk'
    self.freeze = false
    self.mask = nil
    self.stopped = false

    self.grabbing       = false -- Whether 'grab' key is being pressed
    self.currently_held = nil -- Object currently being held by the player
    self.holdable       = nil -- Object that would be picked up if player used grab key

    if self.bb then
        self.collider:setGhost(self.bb)
    end
    if self.footprint and self.footprint.bb and self.collider then
        self.collider:setGhost(self.footprint.bb)
    end

    self.footprint = Footprint.new(collider,self)
    self.collider = collider
    self.bb = collider:addRectangle(0,0,self.bbox_width,self.bbox_height)
    self:moveBoundingBox()
    self.bb.player = self -- wat

    self.prevAttackPressed = false

    --self.money = 0
    self.spriteState = SM.new(self)
end

---
-- Create or look up a new Player
-- @param collider
-- @return Player
function Player.factory(collider)
    if player == nil then
        player = Player.new(collider)
    end
    return player
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
    self.footprint:update(self)

end

function Player:keypressed( button, map )

    if not self.kc:active() then return end
    
    if self.spriteState[button] then
        SM.advanceState(self,button)
    elseif button =='A' and self.spriteState['pickUp'] then
        SM.advanceState(self,'pickUp')
    elseif button =='A' and self.spriteState['drop'] then
        print("dropping up")
        SM.advanceState(self,'drop')
    else
        print("ruined picking up")
    end
    
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if button == 'B' and map.jumping then
        self.jumpQueue:push('jump')
    end
end

function Player:keyreleased( button, map )
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if button == 'B' and map.jumping then
        self.halfjumpQueue:push('jump')
    end
end

---
-- This is the main update loop for the player, handling position updates.
-- @param dt The time delta
-- @return nil
function Player:update( dt )
    if GS.currentState().map.objectgroups.floorspace then
        self:floorspaceUpdate(dt)
        return
    end

    if self.inventory.visible then
        self.inventory:update( dt )
        return
    end
    
    if self.freeze then
        return
    end

    local crouching = controls.isDown( 'DOWN' )
    local gazing = controls.isDown( 'UP' )
    local movingLeft = controls.isDown( 'LEFT' )
    local movingRight = controls.isDown( 'RIGHT' )
    local grabbing = controls.isDown( 'A' )
    local jumping = controls.isDown( 'B' )

    if not self.invulnerable then
        self:stopBlink()
    end

    if self.health <= 0 then
        self.velocity.y = self.velocity.y + game.gravity * dt
        if self.velocity.y > game.max_y then self.velocity.y = game.max_y end
        self.position.y = self.position.y + self.velocity.y * dt
        self:moveBoundingBox()
        return
    end

    if self.character.warpin then
        self.character:warpUpdate(dt)
        return
    end
    
    if (grabbing and not self.grabbing) then
        if self.currently_held then
            if crouching then
                self:drop()
            elseif gazing then
                self:throw_vertical()
            else
                self:throw()
            end
        else
            self:pickup()
        end
    end
    self.grabbing = grabbing

    if ( crouching and gazing ) or ( movingLeft and movingRight ) then
        self.stopped = true
    else
        self.stopped = false
    end

    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if movingLeft and not movingRight and not self.rebounding then

        if crouching and self.crouch_state == 'crouch' then
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

        if crouching and self.crouch_state == 'crouch' then
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

    if jumped and not self.jumping and self:solid_ground()
        and not self.rebounding and not self.liquid_drag then
        self.jumping = true
        if cheat.jump_high then
            self.velocity.y = -970
        else
            self.velocity.y = -670
        end
        sound.playSfx( "jump" )
    elseif jumped and not self.jumping and self:solid_ground()
        and not self.rebounding and self.liquid_drag then
     -- Jumping through heavy liquid:
        self.jumping = true
        self.velocity.y = -270
        sound.playSfx( "jump" )
    end

    if halfjumped and self.velocity.y < -450 and not self.rebounding and self.jumping then
        self.velocity.y = -450
    end

    self.velocity.y = self.velocity.y + game.gravity * dt
    self.since_solid_ground = self.since_solid_ground + dt

    if self.velocity.y > game.max_y then
        self.velocity.y = game.max_y
        self.fall_damage = self.fall_damage + game.fall_dps * dt
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

    -- falling off the bottom of the map
    if self.position.y > self.boundary.height then
        self.health = 0
        self.character.state = 'dead'
        return
    end

    action = nil
    
    self:moveBoundingBox()

    if self.velocity.x < 0 then
        self.character.direction = 'left'
    elseif self.velocity.x > 0 then
        self.character.direction = 'right'
    end

    if self.velocity.y < 0 then

        self.character.state = 'jump'
        self.character:animation():update(dt)

    elseif self.character.state == 'jump' and not self.jumping then

        self.character.state = self.walk_state
        self.character:animation():update(dt)

    elseif self.character.state ~= 'jump' and self.velocity.x ~= 0 then

        if crouching and self.crouch_state == 'crouch' then
            self.character.state = self.crouch_state
        else
            self.character.state = self.walk_state
        end

        self.character:animation():update(dt)

    elseif self.character.state ~= 'jump' and self.velocity.x == 0 then

        if crouching and gazing then
            self.character.state = 'idle'
        elseif crouching then
            self.character.state = self.crouch_state
        elseif gazing then 
            self.character.state = self.gaze_state
        elseif self.currently_held then
            self.character.state = 'hold'
        else
            self.character.state = 'idle'
        end

        self.character:animation():update(dt)

    else
        self.character:animation():update(dt)
    end

    self.healthText.y = self.healthText.y + self.healthVel.y * dt
    
    sound.adjustProximityVolumes()
end


function Player:floorspaceUpdate( dt )
    if self.inventory.visible then
        self.inventory:update( dt )
        return
    end
    
    if self.freeze then
        return
    end

    local KEY_DOWN = controls.isDown( 'DOWN' )
    local KEY_UP = controls.isDown( 'UP' )
    local KEY_LEFT = controls.isDown( 'LEFT' )
    local KEY_RIGHT = controls.isDown( 'RIGHT' )

    if not self.invulnerable then
        self:stopBlink()
    end

    if self.health <= 0 then
        self.velocity.y = self.velocity.y + game.gravity * dt
        if self.velocity.y > game.max_y then self.velocity.y = game.max_y end
        self.position.y = self.position.y + self.velocity.y * dt
        self:moveBoundingBox()
        return
    end

    if self.warpin then
        self.animations.warp:update(dt)
        return
    end
    
    -- taken from sonic physics http://info.sonicretro.org/SPG:Running

    if not self.update_jumping then
        self.footprint.y = self.position.y + self.height
    end
    
    --update walking by keypresses
    if self.update_walking and KEY_LEFT then
        self.velocity.x = self.velocity.x - self.acceleration * dt
    elseif self.update_walking and KEY_RIGHT then
        self.velocity.x = self.velocity.x + self.acceleration * dt
    elseif self.update_walking and self.velocity.x < 0 then
        self.velocity.x = math.min(self.velocity.x + self.deceleration * dt, 0)
    elseif self.update_walking and self.velocity.x > 0 then
        self.velocity.x = math.max(self.velocity.x - self.deceleration * dt, 0)
    end

    if self.update_walking and KEY_DOWN then
        self.velocity.y = self.velocity.y + self.acceleration * dt
    elseif self.update_walking and KEY_UP then
        self.velocity.y = self.velocity.y - self.acceleration * dt
    elseif self.update_walking and self.velocity.y < 0 then
        self.velocity.y = math.min(self.velocity.y + self.deceleration * dt, 0)
    elseif self.update_walking and self.velocity.y > 0 then
        self.velocity.y = math.max(self.velocity.y - self.deceleration * dt, 0)
    end
    
    --update walking state
    if self.update_walking and self.velocity.x < 0 then
        SM.advanceState(self,'goLeft')
    elseif self.update_walking and self.velocity.x > 0 then
        SM.advanceState(self,'goRight')
    elseif self.update_walking and self.velocity.y > 0 then
        SM.advanceState(self,'goDown')
    elseif self.update_walking and self.velocity.y < 0 then
        SM.advanceState(self,'goUp')
    elseif self.update_walking then
        SM.advanceState(self,'idle')
    end

    --handle jumping
    local jumped = self.jumpQueue:flush()
    local halfjumped = self.halfjumpQueue:flush()


    if jumped and not self.liquid_drag and self.spriteState['normalJump'] then
        SM.advanceState(self,'normalJump')
    elseif jumped and self.liquid_drag and self.spriteState['liquid_jump'] then
     --Jumping through heavy liquid:
        SM.advanceState(self,'liquid_jump')
        self.jumping = true
        self.velocity.y = -270
        sound.playSfx( "jump" )
    end

    if halfjumped and self.velocity.y < -450 and not self.rebounding and self.spriteState['half_jump'] then
        SM.advanceState(self,'half_jump')
        self.velocity.y = -450
    end
    
    if self.update_jumping and self.velocity.y>0 and self.position.y + self.height > self.footprint.y then
        SM.advanceState(self,'land')
    elseif self.update_jumping then
        self.velocity.y = self.velocity.y + game.gravity * dt
    end
    
    if self.update_jumping and controls.isDown('LEFT') then
        self.velocity.x = self.velocity.x - self.acceleration * dt
    elseif self.update_jumping and controls.isDown('RIGHT') then
        self.velocity.x = self.velocity.x + self.acceleration * dt
    elseif self.update_jumping and controls.isDown('DOWN')  then
        self.footprint.y = self.        tprint.y + 10*dt
    elseif self.update_jumping and controls.isDown('up') then
        self.footprint.y = self.footprint.y - 10*dt
    end
    
    -- end sonic physics
    
    -- These calculations shouldn't need to be offset, investigate
    -- Min and max for the level
    --clip positions
    -- i think the problem might be the size of the bounding box is
    -- larger than the original programmer thought(48x48)
    if self.position.x < -self.width / 4 then
        self.position.x = -self.width / 4
    elseif self.position.x > self.boundary.width - self.width * 3 / 4 then
        self.position.x = self.boundary.width - self.width * 3 / 4
    end
    
    --clip speeds
    if self.velocity.x < -self.max_velocity then
        self.velocity.x = -self.max_velocity
    elseif self.velocity.x > self.max_velocity then
        self.velocity.x = self.max_velocity
    elseif self.velocity.y > self.max_velocity then
        self.velocity.y = self.max_velocity
    elseif  self.velocity.y < -self.max_velocity then
        self.velocity.y = -self.max_velocity
    end
    
    --laws of projectiles only apply if jumping
    --(i.e. if the footprint isn't on the floorspace or if the footprint isn't
    -- where the feet are.)

    --finally update positions
    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt


    if self.velocity.x < 0 then
        self.character.direction = 'left'
    elseif self.velocity.x > 0 then
        self.character.direction = 'right'
    end
    
    self.character:animation():update(dt)
    self:moveBoundingBox()

    self.healthText.y = self.healthText.y + self.healthVel.y * dt
    
    sound.adjustProximityVolumes()

end

--each time you try to pickUp
function Player.doDrop(self)
    self:drop()
end
--each time you try to pickUp
function Player.doPickUp(self)
    self:pickup()
end

--each time you change direction
function Player.walking(self)
    if self.update_jumping then
        self.position.y = self.footprint.y - self.height
        self.velocity.y=0
    end
    self.update_jumping = false
    self.update_walking = true
end

--each time you jump
function Player.normalJumping(self)
    self.jumping = true
    if cheat.jump_high then
        self.velocity.y = -970
    else
        self.velocity.y = -670
    end
    sound.playSfx( "jump" )
    self.update_jumping = true
    self.update_walking = false
end

--each time you land or stop moving
function Player.idling(self)
    self.footprint.y = self.position.y + self.height
    self.update_jumping = false
    self.update_walking = true
    self.velocity.y=0
end
---
-- Function to call when colliding with the ground
-- @return nil
function Player:landOnGround()
    self.footprint.y = self.position.y + self.height
    self.jumping = false
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

    damage = math.floor(damage)
    if damage == 0 then
        return
    end

    sound.playSfx( "damage_" .. math.max(self.health, 0) )
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
        self.dead = true
        self.character.state = 'dead'
    end
    
    Timer.add(1.5, function() 
        self.invulnerable = false
        self.flash = false
    end)

    self:startBlink()
end

---
-- Call to take falling damage, and reset self.fall_damage to 0
-- @return nil
function Player:impactDamage()
    if self.fall_damage > 0 then
        self:die(self.fall_damage)
    end
    self.fall_damage = 0
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

    if self.stencil then
        love.graphics.setStencil( self.stencil )
    else
        love.graphics.setStencil( )
    end
    
    if self.character.warpin then
        local y = self.position.y - self.character:current().beam:getHeight() + self.height + 4
        self.character:current().animations.warp:draw(self.character:current().beam, self.position.x + 6, y)
        return
    end

    self.inventory:draw(self.position)

    if self.blink then
        love.graphics.drawq(healthbar, healthbarq[self.health + 1],
                            math.floor(self.position.x) - 18,
                            math.floor(self.position.y) - 18)
    end

    if self.flash then
        love.graphics.setColor(255, 0, 0)
    end

    local animation = self.character:animation()
    animation:draw(self.character:sheet(), math.floor(self.position.x),
                                      math.floor(self.position.y))

     --self.footprint.bb:draw('line')
    
    -- Set information about animation state for holdables
    self.frame = animation.frames[animation.position]
    local x,y,w,h = self.frame:getViewport()
    self.frame = {x/w+1, y/w+1}
    if self.character:current().positions then
        self.offset_hand_right = self.character:current().positions.hand_right[self.frame[2]][self.frame[1]]
    else
        self.offset_hand_right = {0,0}
    end

    if self.currently_held then
        self.currently_held:draw()
    end

    if self.rebounding and self.damageTaken > 0 then
        love.graphics.draw(health, self.healthText.x, self.healthText.y)
    end

    love.graphics.setColor(255, 255, 255)
    
    love.graphics.setStencil()
    
end

---
-- Sets the sprite states of a player based on a preset combination
-- @param presetName
-- @return nil
function Player:setSpriteStates(presetName)
    if presetName == 'holding' then
        self.walk_state   = 'holdwalk'
        self.crouch_state = 'holdwalk'
        self.gaze_state   = 'holdwalk'
    else
        -- Default
        self.walk_state   = 'walk'
        self.crouch_state = 'crouchwalk'
        self.gaze_state   = 'gazewalk'
    end
end

----- Platformer interface
function Player:ceiling_pushback(node, new_y)
    self.position.y = new_y
    self.velocity.y = 0
    self:moveBoundingBox()
    self.jumping = false
    self.rebounding = false
end

function Player:floor_pushback(node, new_y)
    self:ceiling_pushback(node, new_y)
    self:impactDamage()
    self:restore_solid_ground()
end

function Player:wall_pushback(node, new_x)
    self.position.x = new_x
    self.velocity.x = 0
    self:moveBoundingBox()
end

---
-- Get whether the player has the ability to jump from here
-- @return bool
function Player:solid_ground()
    if self.since_solid_ground < game.fall_grace then
        return true
    else
        return false
    end
end

---
-- Function to call when colliding with the ground
-- @return nil
function Player:restore_solid_ground()
    self.since_solid_ground = 0
end

---
-- Registers an object as something that the user can currently hold on to
-- @param holdable
-- @return nil
function Player:registerHoldable(holdable)
    if self.holdable == nil and self.currently_held == nil then
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

---
-- The player attacks
-- @return nil
function Player:attack()
    local currentWeapon = self.inventory:currentWeapon()
    if currentWeapon then
        currentWeapon:use(self)
    else
        self:defaultAttack()
    end
end

-- Picks up an object.
-- @return nil
function Player:pickup()
    print("hahahahaha")
    if self.holdable and self.currently_held == nil then
        self:setSpriteStates('holding')
        self.currently_held = self.holdable
        if self.currently_held.pickup then
            self.currently_held:pickup(self)
        end
    end
end

---
-- Executes the players weaponless attack (punch, kick, or something like that)
function Player:defaultAttack()
end

-- Throws an object.
-- @return nil
function Player:throw()
    if self.currently_held then
        self:setSpriteStates('default')
        local object_thrown = self.currently_held
        self.currently_held = nil
        if object_thrown.throw then
            object_thrown:throw(self)
        end
    end
end

---
-- Throws an object vertically.
-- @return nil
function Player:throw_vertical()
    if self.currently_held then
        self:setSpriteStates('default')
        local object_thrown = self.currently_held
        self.currently_held = nil
        if object_thrown.throw_vertical then
            object_thrown:throw_vertical(self)
        end
    end
end

---
-- Drops an object.
-- @return nil
function Player:drop()
    if self.currently_held then
        self:setSpriteStates('default')
        local object_dropped = self.currently_held
        self.currently_held = nil
        if object_dropped.drop then
            object_dropped:drop(self)
        end
    end
end

return Player
