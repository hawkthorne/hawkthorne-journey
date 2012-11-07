local Queue = require 'queue'
local Timer = require 'vendor/timer'
local Helper = require 'helper'
local window = require 'window'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local game = require 'game'
local PlayerAttack = require 'playerAttack'
local controls = require 'controls'
local GS = require 'vendor/gamestate'
local KeyboardContext = require 'keyboard_context'

local healthbar = love.graphics.newImage('images/health.png')
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

local player = nil
---
-- Create a new Player
-- @param collider
-- @return Player
function Player.new(collider)
    local plyr = {}

    setmetatable(plyr, Player)
    plyr.kc = KeyboardContext.new("player", true)
    plyr.jumpQueue = Queue.new()
    plyr.halfjumpQueue = Queue.new()
    plyr.rebounding = false
    plyr.invulnerable = false
    plyr.jumping = false
    plyr.liquid_drag = false
    plyr.flash = false
    plyr.width = 48
    plyr.height = 48
    plyr.bbox_width = 18
    plyr.bbox_height = 44
    plyr.sheet = nil 
    plyr.actions = {}
    plyr.position = {x=0, y=0}
    plyr.velocity = {x=0, y=0}
    plyr.fall_damage = 0
    plyr.state = 'idle'       -- default animation is idle
    plyr.direction = 'right'  -- default animation faces right
    plyr.animations = {}
    plyr.frame = nil
    plyr.warpin = false
    plyr.dead = false
    plyr.crouch_state = 'crouch'
    plyr.gaze_state = 'gaze'
    plyr.walk_state = 'walk'
    plyr.jump_state = 'jump'
    plyr.idle_state   = 'idle'
    plyr.isFloorspace = false;
    plyr.freeze = false
    plyr.mask = nil
    plyr.stopped = false

    plyr.grabbing       = false -- Whether 'grab' key is being pressed
    plyr.currently_held = nil -- Object currently being held by the player
    plyr.holdable       = nil -- Object that would be picked up if player used grab key

    plyr.collider = collider
    plyr.bb = collider:addRectangle(0,0,plyr.bbox_width,plyr.bbox_height)
    plyr:moveBoundingBox()
    plyr.bb.player = plyr -- wat

    plyr.attack_box = PlayerAttack.new(plyr.collider,plyr)

    --for damage text
    plyr.healthText = {x=0, y=0}
    plyr.healthVel = {x=0, y=0}
    plyr.max_health = 6
    plyr.health = plyr.max_health
    plyr.damageTaken = 0

    plyr.inventory = Inventory.new()
    plyr.prevAttackPressed = false
    
    plyr.money = 0
    plyr.lives = 3

    --tests if the player currently has a 
    --wieldable weapon out and the player is swinging it
    plyr.wielding = false

    return plyr
end

function Player:refreshPlayer(collider)

    self.kc:set()
    self.jumpQueue = Queue.new()
    self.halfjumpQueue = Queue.new()
    self.rebounding = false
    --self.invulnerable = false
    self.jumping = false
    self.liquid_drag = false
    self.flash = false
    self.width = 48
    self.height = 48
    self.bbox_width = 18
    self.bbox_height = 44
    --self.sheet = nil 
    self.actions = {}

    --if self.position == nil then
    --    self.position = {x=0, y=0}
    --end

    self.velocity = {x=0, y=0}
    self.fall_damage = 0
    self.since_solid_ground = 0
    self.state = 'idle'       -- default animation is idle
    self.direction = 'right'  -- default animation faces right
    --self.animations = {}
    self.warpin = false
    self.dead = false
    self.crouch_state = 'crouch'
    self.gaze_state = 'gaze'
    self.walk_state = 'walk'
    self.hand_offset = 10
    self.freeze = false
    self.mask = nil
    self.stopped = false

    self.grabbing       = false -- Whether 'grab' key is being pressed
    self.currently_held = nil -- Object currently being held by the player
    self.holdable       = nil -- Object that would be picked up if player used grab key

    self.collider = collider
    self.bb = collider:addRectangle(0,0,self.bbox_width,self.bbox_height)
    self:moveBoundingBox()
    self.bb.player = self -- wat

    self.attack_box = PlayerAttack.new(collider,self)
    collider:setPassive(self.attack_box.bb)

    table.insert(GS.currentState().nodes, self.currently_held)


    --for damage text
    --self.healthText = {x=0, y=0}
    --self.healthVel = {x=0, y=0}
    --self.health = 6
    --self.damageTaken = 0

    --self.inventory = Inventory.new()
    self.prevAttackPressed = false

    --self.money = 0

end
---
-- Create or look up a new Player
-- @param collider
-- @param playerNum the index of the player
-- @return Player
function Player.factory(collider)
    local plyr = player
    if plyr~=nil then
        plyr = player
        if plyr.state=='dead' then
            plyr = Player.new(collider)
            player = plyr
        end
        return plyr
    else
        plyr = Player.new(collider)
        player = plyr
        return plyr
    end
end


---
-- Loads a character sheet
-- @param character
-- @return nil
function Player:loadCharacter(character)
    self.animations = character.animations
    self.sheet      = character.sheet
    self.positions  = character.positions
    self.character  = character
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
    sound.playSfx( "respawn" )
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

function Player:keypressed( button, map )
    if not self.kc:active() then return end
    
    if button == 'SELECT' then
        self.inventory:open( self )
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

        if self.attack_box and self.attack_box.bb then
        if self.direction=='right' then
            self.attack_box.bb:moveTo(self.position.x + 24 + 20, self.position.y+28)
        else
            self.attack_box.bb:moveTo(self.position.x + 24 - 20, self.position.y+28)
        end

   end

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
    local KEY_SHIFT = controls.isDown( 'A' )
    local jumping = controls.isDown( 'B' )

    if not self.invulnerable then
        self:stopBlink()
    end

    if self.health <= 0 then
        --retract weapon on death
        if self.currently_held and self.currently_held.unuse then
            self.currently_held:unuse()
        end

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
    
    if (KEY_SHIFT and not self.grabbing) then
        if self.currently_held and self.currently_held.wield then
            if KEY_UP then
                self:switch_weapon()
            elseif KEY_DOWN then
                self:drop()
            else
                self:attack()
            end
        elseif self.currently_held then
            if KEY_UP then
                self:throw_vertical()
            elseif KEY_DOWN then
                self:drop()
            else
                self:throw()
            end
        elseif self.holdable then
            self:pickup()
        else
            self:attack()
        end
    end
    self.grabbing = KEY_SHIFT

    if ( KEY_DOWN and KEY_UP ) or ( KEY_LEFT and KEY_RIGHT ) then
        self.stopped = true
    else
        self.stopped = false
    end

    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if KEY_LEFT and not KEY_RIGHT and not self.rebounding then

        if KEY_DOWN and self.crouch_state == 'crouch' then
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

    elseif KEY_RIGHT and not KEY_LEFT and not self.rebounding then

        if KEY_DOWN and self.crouch_state == 'crouch' then
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

    action = nil
    
    self:moveBoundingBox()

    if self.velocity.x < 0 then
        self.direction = 'left'
    elseif self.velocity.x > 0 then
        self.direction = 'right'
    end

    if self.wielding then
        self.state = self.currently_held.action --'wieldaction' by default, this is the attack motion for the current weapon
        self:animation():update(dt)

    elseif self.velocity.y < 0 then

        self.state = self.jump_state
        self:animation():update(dt)

    elseif self.isJumpState(self.state) and not self.jumping then

        self.state = self.walk_state
        self:animation():update(dt)

    elseif not self.isJumpState(self.state) and self.velocity.x ~= 0 then

        if KEY_DOWN and self.crouch_state == 'crouch' then
            self.state = self.crouch_state
        else
            self.state = self.walk_state
        end

        self:animation():update(dt)

    elseif not self.isJumpState(self.state) and self.velocity.x == 0 then

        if KEY_DOWN and KEY_UP then
            self.state = self.idle_state
        elseif KEY_DOWN then
            self.state = self.crouch_state
        elseif KEY_UP then
            self.state = self.gaze_state
        else
            self.state = self.idle_state --'idle'
        end

        self:animation():update(dt)

    else
        self:animation():update(dt)
    end

    self.healthText.y = self.healthText.y + self.healthVel.y * dt
    
    sound.adjustProximityVolumes()
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
        self.state = 'dead'
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
    
    if self.warpin then
        local y = self.position.y - self.character.beam:getHeight() + self.height + 4
        self.animations.warp:draw(self.character.beam, self.position.x + 6, y)
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

    local animation = self:animation()
    animation:draw(self.sheet, math.floor(self.position.x),
                                      math.floor(self.position.y))

    -- Set information about animation state for holdables
    self.frame = animation.frames[animation.position]
    local x,y,w,h = self.frame:getViewport()
    self.frame = {x/w+1, y/w+1}
    if self.positions then
        self.offset_hand_right = self.positions.hand_right[self.frame[2]][self.frame[1]]
        self.offset_hand_left = self.positions.hand_left[self.frame[2]][self.frame[1]]
    else
        self.offset_hand_right = {0,0}
        self.offset_hand_left = {0,0}
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
-- call this function if an action requires a set of state changes
-- @param presetName
-- @return nil
function Player:setSpriteStates(presetName)
    --walk_state  : pressing left or right
    --crouch_state: pressing down
    --gaze_state  : pressing up
    --jump_state  : pressing jump button
    --idle_state  : standing around

    --player.spriteStates = presetName
    if presetName ~= self.previousSpriteStates and presetName ~= 'attacking' then
        self.previousSpriteStates = presetName
    end

    if presetName == 'wielding' then
        self.walk_state   = 'wieldwalk'
        if self.isFloorspace then
            self.crouch_state = 'crouchwalk'
            self.gaze_state   = 'gazewalk'
        end
        self.jump_state   = 'wieldjump'
        self.idle_state   = 'wieldidle'
    elseif presetName == 'holding' then
        self.walk_state   = 'holdwalk'
        self.crouch_state = 'holdwalk'
        self.gaze_state   = 'holdwalk'
        self.jump_state   = 'holdjump'
        self.idle_state   = 'hold'
    elseif presetName == 'attacking' then --state for sustained attack
        self.walk_state   = 'attackwalk'
        if self.isFloorspace then
            self.crouch_state = 'crouchwalk'
            self.gaze_state   = 'gazewalk'
        end
        self.jump_state   = 'attackjump'
        self.idle_state   = 'attack'
    else
        -- Default
        self.walk_state   = 'walk'
        if self.isFloorspace then
            self.crouch_state = 'crouchwalk'
            self.gaze_state   = 'gazewalk'
        end
        self.jump_state   = 'jump'
        self.idle_state   = 'idle'
    end
end

function Player:isJumpState(myState)
    --assert(type(myState) == "string")
    if myState==nil then return nil end

    if string.find(myState,'jump') == nil then
        return false
    else
        return true
    end
end

function Player:isWalkState(myState)
    if myState==nil then return false end

    if string.find(myState,'walk') == nil then
        return false
    else
        return true
    end
end

function Player:isIdleState(myState)
    --assert(type(myState) == "string")
    if myState==nil then return nil end

    if string.find(myState,'idle') == nil then
        return false
    else
        return true
    end
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

    --use a holdable weapon
    if self.currently_held and self.currently_held.wield and not self.prevAttackPressed then
        self.currently_held:wield()
        --the specific weapon will handle wield states
        self.prevAttackPressed = true
        Timer.add(1.0, function()
            self.prevAttackPressed = false
        end)

        --use a throwable weapon or take out a holdable one
    elseif currentWeapon and not self.prevAttackPressed then
        currentWeapon:use(self)
        if self.currently_held and self.currently_held.wield then
            self:setSpriteStates('wielding')
        end
    --use a default attack
    elseif not self.prevAttackPressed then
        self.collider:setActive(self.attack_box.bb)
        self.prevAttackPressed = true
        Timer.add(1.0, function()
            self.prevAttackPressed = false
            self.collider:setPassive(self.attack_box.bb) 
            self:setSpriteStates('default')
        end)
        self:setSpriteStates('attacking')
    end
end

-- Picks up an object.
-- Note: weapons are picked up directly from their item
-- @return nil
function Player:pickup()
    if self.holdable and self.currently_held == nil then
        self.currently_held = self.holdable
        self:setSpriteStates('holding')

        if self.currently_held.pickup then
            self.currently_held:pickup(self)
        end
    end
end

-- Throws an object.
-- @return nil
function Player:throw()
    if self.currently_held and self.currently_held.wield then
        local inventoryWeapon = self.currently_held
        self.currently_held = nil
        inventoryWeapon:unuse()
    elseif self.currently_held then
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
    if self.currently_held and self.currently_held.wield then
        local inventoryWeapon = self.currently_held
        self.currently_held = nil
        inventoryWeapon:unuse()
    elseif self.currently_held then
        self:setSpriteStates('default')
        local object_thrown = self.currently_held
        self.currently_held = nil
        if object_thrown.throw_vertical then
            object_thrown:throw_vertical(self)
        end
    end
end

---
-- Switches weapons. if there's nothing to switch to
-- this switches to default attack
-- @return nil
function Player:switch_weapon()
    local newWeapon = self.inventory:currentWeapon()
    local oldWeapon = self.currently_held
    self.currently_held = nil
    oldWeapon:unuse()
    
    if newWeapon then
        newWeapon:use(self)
        self:setSpriteStates('wielding')
    end
end

---
-- Drops an object.
-- @return nil
function Player:drop()
    if self.currently_held and self.currently_held.wield then
        local inventoryWeapon = self.currently_held
        self.currently_held = nil
        inventoryWeapon:drop()
    elseif self.currently_held then
        self:setSpriteStates('default')
        local object_dropped = self.currently_held
        self.currently_held = nil
        if object_dropped.drop then
            object_dropped:drop(self)
        end
    end
end

return Player
