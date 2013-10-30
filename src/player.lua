local json  = require 'hawk/json'
local queue = require 'queue'
local Timer = require 'vendor/timer'
local window = require 'window'
local sound = require 'vendor/TEsound'
local game = require 'game'
local character = require 'character'
local PlayerAttack = require 'playerAttack'
local Statemachine = require 'hawk/statemachine'
local Gamestate = require 'vendor/gamestate'
local InputController = require 'inputcontroller'
local app = require 'app'

local Inventory = require('inventory')

local Player = {}
Player.__index = Player
Player.isPlayer = true

Player.startingMoney = 0

Player.jumpFactor = 1
Player.speedFactor = 1

-- single 'character' object that handles all character switching, costumes and animation

local player = nil
---
-- Create a new Player
-- @param collider
-- @return Player
function Player.new(collider)
    local plyr = {}

    setmetatable(plyr, Player)
    
    plyr.haskeyboard = true
    
    plyr.invulnerable = false
    plyr.godmode = false
    plyr.actions = {}
    plyr.position = {x=0, y=0}
    plyr.frame = nil
    
    plyr.controlState = Statemachine.create({
        initial = 'normal',
        events = {
            {name = 'inventory', from = 'normal', to = 'ignoreMovement'},
            {name = 'standard', from = 'ignoreMovement', to = 'normal'},
    }})
    plyr.controls = InputController.get()

    plyr.width = 48
    plyr.height = 48
    plyr.bbox_width = 18
    plyr.bbox_height = 44
    plyr.character = character.current()

    --for damage text
    plyr.healthText = {x=0, y=0}
    plyr.healthVel = {x=0, y=0}
    plyr.max_health = 10
    plyr.health = plyr.max_health
    
    plyr.jumpDamage = 3
    plyr.punchDamage = 1

    plyr.inventory = Inventory.new( plyr )
    
    plyr.money = plyr.startingMoney
    plyr.slideDamage = 8
    plyr.canSlideAttack = false
    
    plyr.on_ice = false

    plyr.visitedLevels = {}

    plyr:refreshPlayer(collider)
    return plyr
end

function Player:refillHealth()
  self.health = self.max_health
end

function Player:refreshPlayer(collider)
    --changes that are made if you're dead
    if self.dead then
        self.health = self.max_health
        --self.money = 0
        --self.inventory = Inventory.new( self )
    end
    
    if self.character.changed then
        self.character.changed = false
        self.money = 0
        self:refillHealth()
        self.inventory = Inventory.new( self )
        local gamesave = app.gamesaves:active()
        if gamesave then
            self:loadSaveData( gamesave )
        end
    end

    self.invulnerable = false
    self.events = queue.new()
    self.rebounding = false
    self.damageTaken = 0
    

    self.jumping = false
    self.liquid_drag = false
    self.flash = false
    self.actions = {}

    self.velocity = {x=0, y=0}
    self.fall_damage = 0
    self.since_solid_ground = 0
    self.since_down = 0
    self.platform_dropping = false
    self.dead = false

    self:setSpriteStates(self.current_state_set or 'default')

    self.freeze = false
    self.mask = nil
    self.stopped = false

    if self.currently_held and self.currently_held.isWeapon then
        if not self.currently_held.isRangedWeapon then self.collider:remove(self.currently_held.bb) end
        self.currently_held.containerLevel:removeNode(self.currently_held)
        self.currently_held.containerLevel = Gamestate.currentState()
        self.currently_held.containerLevel:addNode(self.currently_held)
        self.currently_held:initializeBoundingBox(collider)
    else
        self:setSpriteStates('default')
        self.currently_held = nil
    end
    self.holdable = nil -- Object that would be picked up if player used grab key

    if self.top_bb then
        self.collider:remove(self.top_bb)
        self.top_bb = nil
    end
    if self.bottom_bb then
        self.collider:remove(self.bottom_bb)
        self.bottom_bb = nil
    end
    if self.attack_box and self.attack_box.bb then
        self.collider:remove(self.attack_box.bb)
    end

    self.attack_box = PlayerAttack.new(collider,self)
    self.collider = collider
    self.top_bb = collider:addRectangle(0,0,self.bbox_width,self.bbox_height/3)
    self.bottom_bb = collider:addRectangle(0,self.bbox_height/2,self.bbox_width,self.bbox_height/2)
    self:moveBoundingBox()
    self.top_bb.player = self -- wat
    self.bottom_bb.player = self -- wat
    self.character:reset()

    self.wielding = false
    self.prevAttackPressed = false
    
    self.currentLevel = Gamestate.currentState()
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

function Player.kill()
    player = nil
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
-- @return nil
function Player:moveBoundingBox()
    self.top_bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + (self.height / 3) + 2)
    self.bottom_bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + (3*self.height / 4) + 2)
    self.attack_box:update()
end


-- Set the current weapon. If weapon is nil then weapon is 
-- set to default attack
-- @return nil
function Player:selectWeapon(weapon)
    local selectNew = true
    if self.currently_held and self.currently_held.deselect then
        if weapon and weapon.name == self.currently_held.name then
            -- if we're selecting the same weapon, un-wield it, but don't re-select it
            selectNew = false
        end
        self.currently_held:deselect()
    end

    if weapon and selectNew then
        weapon:select(self)
    end
end


-- Switches weapons. if there's nothing to switch to
-- this switches to default attack
-- @return true if this function captured the keypress
function Player:switchWeapon()
    self:selectWeapon(self.inventory:tryNextWeapon())
end

function Player:keypressed( button, map )
    
    local controls = self.controls

    if button == 'SELECT' then
        if controls:isDown( 'DOWN' )then
            --dequips
            if self.currently_held and self.currently_held.isWeapon then
                self.currently_held:deselect()
                self.inventory.selectedWeaponIndex = self.inventory.selectedWeaponIndex - 1
            end
            self.doBasicAttack = true
            return true
        elseif controls:isDown( 'UP' ) then
            local held = self.currently_held and self.currently_held.isWeapon or not self.currently_held
            --cycle to next weapon
            if held then
                self.doBasicAttack = false
                self:switchWeapon()
                return true
            end
        else
            self.inventory:open()
            return true
        end
    elseif button == 'ATTACK' then
        if self.currently_held and not self.currently_held.wield then
            if controls:isDown( 'DOWN' ) then
                self:drop()
            elseif controls:isDown( 'UP' ) then
                self:throw_vertical()
            else
                self:throw()
            end
        elseif self.current_state_set ~= 'crawling' then
            self:attack()
        end
        return true
    elseif button == 'JUMP' then
        -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
        self.events:push('jump')
    elseif button == 'RIGHT' or button == 'LEFT' then
        if self.current_state_set ~= 'crawling' and controls:isDown( 'DOWN' )
           and not self.currentLevel.floorspace then
            --dequips
            if self.currently_held and self.currently_held.isWeapon then
                self.currently_held:deselect()
            end
            self:setSpriteStates( 'crawling' )
        end
    elseif button == 'DOWN' then
        if self.since_down > 0 and self.since_down < 0.15 then
            self.platform_dropping = true
            Timer.add( 0.25, function() self.platform_dropping = false end )
        end
    end
end

function Player:keyreleased( button, map )
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if button == 'JUMP' then
        self.events:push('halfjump')
    elseif button == 'DOWN' then
        if self.current_state_set == 'crawling' or self.character.state == 'crouch' then
            self:checkBlockedCrawl()
        end
    end
end

function Player:checkBlockedCrawl ()
    local top_bb_x = self.position.x + self.width / 2 
    local top_bb_y = self.position.y + (self.height / 3) + 2
    local _,_,bot_bb_x,bot_bb_y = self.bottom_bb:bbox()
    for block in pairs(self.bottom_bb:neighbors()) do
        if block:collidesWith(self.bottom_bb) and block.node.isSolid then
            for _, shape in ipairs(self.collider:shapesAt(top_bb_x,top_bb_y)) do
                if shape:collidesWith(self.top_bb) and shape.node.isSolid then
                    Timer.add(0.4, function() self:checkBlockedCrawl() end)
                    self:setSpriteStates('crawling')
                    return
                end
            end
        end
    end
    self:setSpriteStates(self.previous_state_set)
end

---
-- This is the main update loop for the player, handling position updates.
-- @param dt The time delta
-- @return nil
function Player:update( dt )

    self.inventory:update( dt )
    self.attack_box:update()
    
    if self.freeze then
        return
    end

    local controls = self.controls
    local crouching = controls:isDown( 'DOWN' ) and not self.controlState:is('ignoreMovement')
    local gazing = controls:isDown( 'UP' ) and not self.controlState:is('ignoreMovement')
    local movingLeft = controls:isDown( 'LEFT' ) and not self.controlState:is('ignoreMovement')
    local movingRight = controls:isDown( 'RIGHT' ) and not self.controlState:is('ignoreMovement')


    if not self.invulnerable then
        self:stopBlink()
    end

    if self.health <= 0 then
        self.velocity.y = self.velocity.y + game.gravity * dt
        if self.velocity.y > game.max_y then self.velocity.y = game.max_y end
        self.position.y = self.position.y + self.velocity.y * dt
        if self.currently_held and self.currently_held.deselect then
            self.currently_held:deselect()
        end
        self:moveBoundingBox()
        return
    end

    if self.character.warpin then
        self.character:warpUpdate(dt)
        return
    end

    if ( crouching and gazing ) or ( movingLeft and movingRight ) then
        self.stopped = true
    else
        self.stopped = false
    end
    
    if self.character.state == 'crouch' or self.character.state == 'slide'
       or self.character.state == 'dig' or self.current_state_set == 'crawling' then
        self.collider:setGhost(self.top_bb)
    else
        self.collider:setSolid(self.top_bb)
    end
    
    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if movingLeft and not movingRight and not self.rebounding then

        if crouching and self.crouch_state == 'crouch' and not self.jumping then -- crouch slide
            self.velocity.x = self.velocity.x + (self:accel() * dt)
            if self.velocity.x > 0 then
                self.velocity.x = 0
            end
        elseif self.current_state_set == 'crawling' then -- crawling
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.velocity.x < -game.max_x*self.speedFactor / 2 then
                self.velocity.x = -game.max_x*self.speedFactor / 2
            end
        elseif self.velocity.x > 0 and not self.on_ice then
            self.velocity.x = self.velocity.x - (self:deccel() * dt)
        elseif self.velocity.x > -game.max_x*self.speedFactor then
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.on_ice then
                self.velocity.x = self.velocity.x + (self:accel() * dt / 10)
            end
            if self.velocity.x < -game.max_x*self.speedFactor then
                self.velocity.x = -game.max_x*self.speedFactor
            end
        end

    elseif movingRight and not movingLeft and not self.rebounding then

        if crouching and self.crouch_state == 'crouch' and not self.jumping then
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.velocity.x < 0 then
                self.velocity.x = 0
            end
        elseif self.current_state_set == 'crawling' then -- crawling
            self.velocity.x = self.velocity.x + (self:accel() * dt)
            if self.velocity.x > game.max_x*self.speedFactor / 2 then
                self.velocity.x = game.max_x*self.speedFactor / 2
            end
        elseif self.velocity.x < 0 and not self.on_ice then
            self.velocity.x = self.velocity.x + (self:deccel() * dt)
        elseif self.velocity.x < game.max_x*self.speedFactor then
            self.velocity.x = self.velocity.x + (self:accel() * dt)
            if self.on_ice then
                self.velocity.x = self.velocity.x - (self:accel() * dt / 10)
            end
            if self.velocity.x > game.max_x*self.speedFactor then
                self.velocity.x = game.max_x*self.speedFactor
            end
        end

    else
        if self.velocity.x < 0 then
            self.velocity.x = math.min(self.velocity.x + game.friction * dt, 0)
        else
            self.velocity.x = math.max(self.velocity.x - game.friction * dt, 0)
        end
    end

    local jumped = self.events:poll('jump')
    local halfjumped = self.events:poll('halfjump')
    
    if jumped and not self.jumping and self:solid_ground()
        and not self.rebounding and not self.liquid_drag then
        self.jumping = true
        self.velocity.y = -670 *self.jumpFactor
        sound.playSfx( "jump" )
        if player.isClimbing then
            player.isClimbing:release(player)
        end
    elseif jumped and not self.jumping and self:solid_ground()
        and not self.rebounding and self.liquid_drag then
     -- Jumping through heavy liquid:
        self.jumping = true
        self.velocity.y = -270
        sound.playSfx( "jump" )
        if player.isClimbing then
            player.isClimbing:release(player)
        end
    end

    if halfjumped and self.velocity.y < -450 and not self.rebounding and self.jumping then
        self.velocity.y = -450
    end
    
    if not self.footprint or self.jumping then
        self.velocity.y = self.velocity.y + ((game.gravity * dt) / 2)
    end
    self.since_solid_ground = self.since_solid_ground + dt

    if self.velocity.y > game.max_y then
        self.velocity.y = game.max_y
        self.fall_damage = self.fall_damage + game.fall_dps * dt
    end
    -- end sonic physics
    
    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt

    if not self.footprint or self.jumping then
        self.velocity.y = self.velocity.y + ((game.gravity * dt) / 2)
    end

    -- These calculations shouldn't need to be offset, investigate
    -- Min and max for the level
    if self.position.x < -self.width / 4 then
        self.position.x = -self.width / 4
    elseif self.position.x > self.boundary.width - self.width * 3 / 4 then
        self.position.x = self.boundary.width - self.width * 3 / 4
    end

    --falling off the bottom of the map
    if self.position.y > self.boundary.height then
        self.health = 0
        self.character.state = 'dead'
        return
    end

    -- Platform dropping code
    if controls:isDown( 'DOWN' ) then
        self.since_down = 0
    else
        self.since_down = self.since_down + dt
    end

    action = nil
    
    self:moveBoundingBox()

    if self.velocity.x < 0 then
        self.character.direction = 'left'
    elseif self.velocity.x > 0 then
        self.character.direction = 'right'
    end

    if self.wielding or self.attacked then

        self.character:update(dt)

    elseif self.jumping then
        self.character.state = self.jump_state
        self.character:update(dt)

    elseif self.isJumpState(self.character.state) and not self.jumping then
        self.character.state = self.walk_state
        self.character:update(dt)

    elseif not self.isJumpState(self.character.state) and self.velocity.x ~= 0 then
        if crouching and self.crouch_state == 'crouch' then
            self.character.state = self.canSlideAttack and 'slide' or self.crouch_state
        else
            self.character.state = self.walk_state
        end

        self.character:update(dt)

    elseif not self.isJumpState(self.character.state) and self.velocity.x == 0 then

        if crouching and gazing then
            self.character.state = self.idle_state
        elseif crouching then
            self.character.state = self.crouch_state
        elseif gazing then 
            self.character.state = self.gaze_state
        else
            self.character.state = self.idle_state
        end

        self.character:update(dt)

    else
        self.character:update(dt)
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
function Player:hurt(damage)
    if self.invulnerable or self.godmode then
        return
    end

    damage = math.floor(damage)
    if damage == 0 then
        return
    end

    sound.playSfx( "damage" )
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
    else
        self.attacked = true
        self.character.state = 'hurt'
    end
    
    Timer.add(0.4, function()
        self.attacked = false
    end)

    Timer.add(1.5, function() 
        self.invulnerable = false
        self.flash = false
        self.rebounding = false
    end)

    self:startBlink()
end

---
-- Call to take falling damage, and reset self.fall_damage to 0
-- @return nil
function Player:impactDamage()
    if self.fall_damage > 0 then
        self:hurt(self.fall_damage)
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
        local y = self.position.y - self.character.beam:getHeight() + self.height + 4
        self.character.animations.warp:draw(self.character.beam, self.position.x + 6, y)
        return
    end

    if self.flash then
        love.graphics.setColor( 255, 0, 0, 255 )
    end
    
    if self.footprint and self.jumping then
        self.footprint:draw()
    end
    
    if self.currently_held then
        self.currently_held:draw()
    end


    local animation = self.character:animation()
    animation:draw(self.character:sheet(), math.floor(self.position.x),
                                      math.floor(self.position.y))

    -- Set information about animation state for holdables
    self.frame = animation.frames[animation.position]
    local x,y,w,h = self.frame:getViewport()
    self.frame = {x/w+1, y/w+1}
    if self.character.positions then
        self.offset_hand_right = self.character.positions.hand_right[self.frame[2]][self.frame[1]]
        self.offset_hand_left  = self.character.positions.hand_left[self.frame[2]][self.frame[1]]
    else
        self.offset_hand_right = {0,0}
        self.offset_hand_left  = {0,0}
    end

    if self.currently_held and (self.character.state~= self.gaze_state or self.gaze_state=='idle' or self.gaze_state=='gaze') then
        self.currently_held:draw()
    end

    local health = self.damageTaken * -1

    if self.rebounding and self.damageTaken > 0 then
        love.graphics.setColor( 255, 0, 0, 255 )
        love.graphics.print(health, self.healthText.x, self.healthText.y, 0, 0.7, 0.7)
    end

    love.graphics.setColor( 255, 255, 255, 255 )
    
    love.graphics.setStencil()
    
end

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
    --persistence : whether or not this state should assigned to self.previous_state_set
    local sprite_states = self:getSpriteStates()
    assert( sprite_states[presetName], "Error! invalid spriteState set: " .. presetName .. "." )
    
    if self.current_state_set and sprite_states[self.current_state_set].persistence then
        self.previous_state_set = self.current_state_set or 'default'
    end
    self.current_state_set = presetName

    self.walk_state   = sprite_states[presetName].walk_state
    self.crouch_state = sprite_states[presetName].crouch_state
    self.gaze_state   = sprite_states[presetName].gaze_state
    self.jump_state   = sprite_states[presetName].jump_state
    self.idle_state   = sprite_states[presetName].idle_state
    
end

function Player:getSpriteStates()
    return {
        wielding = {
            walk_state   = 'wieldwalk',
            crouch_state = (self.footprint and 'crouchwalk') or 'crouch',
            gaze_state   = (self.footprint and 'gazewalk') or 'idle',
            jump_state   = 'wieldjump',
            idle_state   = 'wieldidle',
            persistence  = true
        },
        holding = {
            walk_state   = 'holdwalk',
            crouch_state = (self.footprint and 'crouchholdwalk') or 'crouch',
            gaze_state   = (self.footprint and 'gazeholdwalk') or 'idle',
            jump_state   = 'holdjump',
            idle_state   = 'hold',
            persistence  = true
        },
        attacking = {
            walk_state   = 'attackwalk',
            crouch_state = 'dig',
            gaze_state   = 'attack',
            jump_state   = 'kick',
            idle_state   = 'attack',
            persistence  = false
        },
        climbing = {
            walk_state   = 'gazeholdwalk',
            crouch_state = 'gazeholdwalk',
            gaze_state   = 'gazeholdwalk',
            jump_state   = 'gazeholdwalk',
            idle_state   = 'gazehold',
            persistence  = false
        },
        crawling = {
            walk_state   = 'crawlwalk',
            crouch_state = (self.footprint and 'crawlcrouchwalk') or 'crawlidle',
            gaze_state   = (self.footprint and 'crawlgazewalk') or 'crawlidle',
            jump_state   = 'jump',
            idle_state   = 'crawlidle',
            persistence  = false
        },
        default = {
            walk_state   = 'walk',
            crouch_state = (self.footprint and 'crouchwalk') or 'crouch',
            gaze_state   = (self.footprint and 'gazewalk') or 'idle',
            jump_state   = 'jump',
            idle_state   = 'idle',
            persistence  = true
        },
    }
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

----- Platformer interface
function Player:ceiling_pushback(node, new_y)
    self.position.y = new_y
    self.velocity.y = 0
    self:moveBoundingBox()
    self.rebounding = false
end

function Player:floor_pushback(node, new_y)
    self:ceiling_pushback(node, new_y)
    self.jumping = false
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
    if self.holdable == nil and holdable.holder == nil then
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
    if self.prevAttackPressed or self.dead or self.isClimbing then return end 

    local currentWeapon = self.inventory:currentWeapon()
    local function punch()
            -- punch/kick
        self.attack_box:activate(self.punchDamage)
        self.prevAttackPressed = true
        self:setSpriteStates('attacking')
        Timer.add(0.1, function()
            self.attack_box:deactivate()
            self:setSpriteStates(self.previous_state_set)
        end)
        Timer.add(0.2, function()
            self.prevAttackPressed = false
        end)
    end
    
    
    if self.character.state=='slide' then
        self.attack_box:activate(self.slideDamage)
        Timer.add(0.2, function()
            self.attack_box:deactivate()
        end)
    elseif self.currently_held and self.currently_held.wield then
        --wield your weapon
        self.prevAttackPressed = true
        self.currently_held:wield()
        Timer.add(0.37, function()
            self.prevAttackPressed = false
        end)
    elseif self.currently_held then
        --do nothing if we have a nonwieldable
    elseif self.doBasicAttack then
        punch()
    elseif currentWeapon and (currentWeapon.props.subtype=='melee' or currentWeapon.props.subtype == 'ranged') then
        --take out your weapon
        currentWeapon:select(self)
    elseif currentWeapon then
        --shoot a projectile
        currentWeapon:use(self)
    else
        punch()
    end
end

-- Picks up an object.
-- @return true if you picked something up
function Player:pickup()
    self:setSpriteStates('holding')
    self.currently_held = self.holdable
    if self.currently_held.pickup then
        self.currently_held:pickup(self)
        return true
    end
    return false
end

-- Attempts to pick up a holdable object
-- @return true if you were able to pick something up
function Player:tryPickup()
    if self.holdable and not self.holdable.holder  then
        if self.currently_held and self.currently_held.deselect then
            self.currently_held:deselect()
            return self:pickup()
        elseif self.currently_held then
            --if you can't unuse it, ignore the keypress
            return false
        else
            return self:pickup()
        end
    end
    return false
end

-- Throws an object.
-- @return nil
function Player:throw()
    if self.currently_held and self.currently_held.isWeapon then
        --weapon does nothing
    elseif self.currently_held then
        self:setSpriteStates('default')
        local object_thrown = self.currently_held
        self.currently_held = nil
        if object_thrown.throw then
            object_thrown:throw(self)
        end
    end
    return true
end

---
-- Throws an object vertically.
-- @return nil
function Player:throw_vertical()
    if self.currently_held and self.currently_held.isWeapon then
        --throw_vertical action
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
-- Drops an object.
-- @return nil
function Player:drop()
    if self.currently_held and self.currently_held.isWeapon then
        self.currently_held:drop()
    elseif self.currently_held then
        self:setSpriteStates('default')
        local object_dropped = self.currently_held
        self.currently_held = nil
        if object_dropped.drop then
            object_dropped:drop(self)
        end
    end
end

-- Saves necessary player data to the gamesave object
-- @param gamesave the gamesave object to save to
function Player:saveData( gamesave )
    -- Save the inventory
    self.inventory:save( gamesave )
    -- Save our money
    gamesave:set( 'coins', self.money )
    -- Save visited levels
    gamesave:set( 'visitedLevels', json.encode( self.visitedLevels ) )
end

-- Loads necessary player data from the gamesave object
-- @param gamesave the gamesave object to load data from
function Player:loadSaveData( gamesave )
    -- First, load the inventory
    self.inventory:loadSaveData( gamesave )
    -- Then load the money
    local coins = gamesave:get( 'coins' )
    if coins ~= nil then
        self.money = coins
    end
    -- Then load the visited levels
    local visited = gamesave:get( 'visitedLevels' )
    if visited ~= nil then
        self.visitedLevels = json.decode( visited )
    end
end

return Player
