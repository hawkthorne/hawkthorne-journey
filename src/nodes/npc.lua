local anim8 = require 'vendor/anim8'
local collision  = require 'hawk/collision'
local app = require 'app'
local Dialog = require 'dialog'
local window = require "window"
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local Player = require 'player'
local Emotion = require 'nodes/emotion'

local Menu = {}
Menu.__index = Menu

function Menu.new(items, responses, commands, background, tick, npc, menuColor)
    local menu = {}
    setmetatable(menu, Menu)
    menu.responses = responses
    menu.commands = commands
    menu.rootItems = items
    menu.items = items
    menu.itemWidth = 150
    menu.choice = 1
    menu.offset = 0
    menu.background = background
    menu.tick = tick
    menu.host = npc
    menu.color = menuColor
    local h = anim8.newGrid(69, 43, background:getWidth(), background:getHeight())
    menu.animation = anim8.newAnimation('once', h('1-6,1'), .08)
    menu.state = 'closed'
    return menu
end

function Menu:keypressed( button, player )
    if self.state == 'closing' then return end
    if self.dialog and (self.state == 'closed' or self.state == 'hidden')
        and button == 'JUMP' then
        return self.dialog:keypressed( button, player )
    end

    if self.state == 'closed' or self.state == 'hidden' then
        return false
    end

    if button == 'UP' then
        sound.playSfx( 'click' )
        if self.choice == 4 then
            self.offset = math.min(self.offset + 1, #self.items - 4)
        end
        self.choice = math.min(4, self.choice + 1)
    elseif button == 'DOWN' then
        sound.playSfx( 'click' )
        if self.choice == 1 then
            self.offset = math.max(self.offset - 1, 0)
        end
        self.choice = math.max(1, self.choice - 1)
    elseif button == 'JUMP' then
        sound.playSfx( 'click' )
        local item  = self.items[self.choice + self.offset]
        if self.commands then
            if self.commands[item.text] and not self.responses[item.text] and not item.freeze then
                self:close(player)
            end
            if self.commands[item.text] then
                self.commands[item.text](self.host, player)
                if item.freeze then
                  self:hide()
                end
            end
        end
        if item == nil or item.text == 'exit' then
            self:close(player)
        elseif item.text == 'i am done with you' or item.text == 'back' then
            self.items = self.rootItems
            self:resetSelection()
        elseif item.text == 'inventory' then
            if self.host.props.inventory then
                self:instahide()
                self.host.props.inventory(self.host, player)
                self.dialog = Dialog.new(self.responses[item.text], function() self:show() end)
            else
                self:hide()
                self.dialog = Dialog.new(self.host.noinventory, function() self:show() end)
            end
        elseif item.text == 'command' then
            if self.host.props.command_items then

                self.items = item.option
            else
                self:hide()
                self.dialog = Dialog.new(self.host.nocommands, function() self:show() end)
            end
        elseif self.responses[item.text] then
            self:hide()
            if item.option then
                self.items = item.option
                self:resetSelection()
            end
            self.dialog = Dialog.new(self.responses[item.text], function() self:show() end)
        elseif type(item.option) == 'table' then
            self.items = item.option
        end
    elseif button == 'INTERACT' then
        self:close(player)
    elseif button == 'ATTACK' then
        if self.items == self.rootItems then
            self:close(player)
        else
            self.items = self.rootItems
            self:resetSelection()
        end
    elseif button == 'START' then
        self:close(player)
    end

    return true
end

function Menu:resetSelection()
    self.choice = 4
    self.offset = 0
end

function Menu:update(dt)
    if self.state == 'closed' or self.state == 'hidden' then
        if self.dialog then self.dialog:update(dt) end
        return
    end

    if self.state == 'hiding' and self.animation.position == 1 then
        self.state = 'hidden'
    end

    if self.state == 'closing' and self.animation.position == 1 then
        self.state = 'closed'
    end

    self.animation:update(dt)
end

function Menu:draw(x, y)
    fonts.set('arial')

    if self.state == 'closed' or self.state == 'hidden' then
        if self.dialog then self.dialog:draw() end
        return
    end

    self.animation:draw(self.background, x + 3, y + 4)

    if self.state == 'opening' and self.animation.position >= 5 then
        self.state = 'opened'
    end

    if self.state ~= 'opened' then
        return
    end

    love.graphics.setColor( self.color.r, self.color.g, self.color.b, self.color.a )
    Font = love.graphics.getFont()

    y = y + 36

    for i, value in ipairs(self.items) do
        i = i - self.offset
        if i > 0 then
            love.graphics.printf(value.text, x - self.itemWidth, y - (i - 1) * 12,
                                 self.itemWidth, 'right')

            if self.choice == i then
                -- pointer
                love.graphics.setColor( 255, 255, 255, 255 )
                love.graphics.draw(self.tick, x - (Font:getWidth(value.text)+10), y - (i - 1) * 12 + 2)
                love.graphics.setColor( self.color.r, self.color.g, self.color.b, self.color.a )
            end
        end
    end
    love.graphics.setColor( 255, 255, 255, 255 )
    fonts.revert()
end

function Menu:open()
    self.items = self.rootItems
    self.choice = 4
    self.offset = 0
    self:show()
end

function Menu:show()
    self.state = 'opening'
    self.animation.direction = 1
    self.animation:gotoFrame(1)
end

function Menu:hide()
    self.animation:resume()
    self.animation.direction = -1
    self.state = 'hiding'
end

function Menu:instahide()
    self.animation:resume()
    self.animation.direction = -1
    self.animation.position = 1
    self.state = 'hidden'
end

function Menu:close(player)
    player.freeze = false
    if self.host.finish then self.host.finish(self.host, player) end
    self.animation:resume()
    self.animation.direction = -1
    self.state = 'closing'
end

-----------------------------------------------
-- NPC.lua
-----------------------------------------------

local NPC = {}
NPC.__index = NPC
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
NPC.isInteractive = true

---
-- Creates a new NPC object
-- @param node the table used to create this
-- @param a collider of objects
-- @return the NPC object created
function NPC.new(node, collider)
    local p = node.properties
    --creates a new object
    local npc = {}
    --sets it to use the functions and variables defined in NPC
    -- if it doesn;t have one by that name
    setmetatable(npc, NPC)
    --stores all the parameters from the tmx file
    npc.node = node
    npc.foreground = p.foreground == 'true'
    --stores parameters from a lua file

    npc.props = require('npcs/' .. node.name)

    npc.name = node.name
    npc.type = node.type

    npc.busy = false

    --sets the position from the tmx file
    npc.position = {x = node.x, y = node.y}
    npc.width = npc.props.width
    npc.height = npc.props.height
    
    --initialize the node's bounding box
    npc.collider = collider
    npc.bb = collider:addRectangle(0,0,(npc.props.bb_width or npc.props.width),(npc.props.bb_height or npc.props.height))
    npc.bb.node = npc
    npc.collider:setPassive(npc.bb)
 
    --define some offsets for the bounding box that can be used each update cycle
    npc.bb_offset = {x = npc.props.bb_offset_x or 0,
                           y = npc.props.bb_offset_y or 0}
                           
    -- Ensures bb is in correct position
    npc:update_bb()
  
    -- deals with npc walking
    npc.walking = npc.props.walking or false
    npc.minx = node.x - (npc.props.max_walk or 48)
    npc.maxx = node.x + (npc.props.max_walk or 48)
    npc.walk_speed = npc.props.walk_speed or 18
    npc.wasWalking = false
    npc.velocity = {x=0, y=0}
    
    npc.run_speed = npc.props.run_speed or 100

    -- deals with staring
    npc.stare = npc.props.stare or false

    npc.donotfacewhentalking = npc.props.donotfacewhentalking or false

    --add more initialization code here if you want
    npc.controls = nil
    
    -- code to run before and after converstation, can be used for talking sprites
    npc.begin = npc.props.begin
    npc.finish = npc.props.finish

    npc.state = 'default'
    npc.direction = npc.props.direction or 'right'
    
    -- optional replies to no iventory or commands
    npc.noinventory = npc.props.noinventory or 'I do not have anything to sell you.'
    npc.nocommands = npc.props.nocommands or 'I do not take commands from the likes of you.'
    
    -- deals with the image of the npc
    local npcImage = love.graphics.newImage('images/npc/'..node.name..'.png')
    local g = anim8.newGrid(npc.props.width, npc.props.height, npcImage:getWidth(), npcImage:getHeight())
    npc.image = npcImage
    
    npc.animations = {}
    for state, data in pairs( npc.props.animations ) do
        npc.animations[ state ] = anim8.newAnimation( data[1], g( unpack(data[2]) ), data[3])
    end

    npc.lastSoundUpdate = math.huge

    -- makes the menu
    menuColor = npc.props.menuColor or {r=0, g=0, b=0, a=255}

    newMenuItems = {
     { ['text']='exit' },
     { ['text']='inventory' },
     { ['text']='command', ['option']=(npc.props.command_items or {})},
     { ['text']='talk', ['option']=npc.props.talk_items}
    }
    npc.affectionText = {x=0, y=0}
    npc.affectionVel = {x=0, y=0}
    npc.displayAffection = false
  
    
    npc.levels = require 'npclevels'		
    if npc.levels[npc.name] then
      npc.affection = npc.levels[npc.name][1] or 0
      npc.respect = npc.levels[npc.name][2] or 0
      npc.trust = npc.levels[npc.name][3] or 0
      npc.married = npc.levels[npc.name][4] or false
    end
	


    npc.db = app.gamesaves:active()

    npc.dead = false
    
    -- a special item is an item in the level that the player can steal or the npc reacts to the player having
    npc.special_items = npc.props.special_items or {}
    npc.greeting = npc.props.greeting or false

    -- store the original position, used in running
    npc.original_pos = {x=npc.position.x, y=npc.position.y}
    -- the offset points for an npc to run towards
    npc.run_offsets = npc.props.run_offsets or {}
    npc.run_offsets_index = 1
    
    -- Used when the npc has been insulted (i.e something was stolen)
    npc.angry = false

    newCommands = npc.props.talk_commands or {}
    command_commands = npc.props.command_commands or {}

     for k,v in pairs(command_commands) do newCommands[k] = v end

    npc.menu =    Menu.new(newMenuItems,
                        npc.props.talk_responses, 
                        newCommands,
                        npc.props.menuImage or love.graphics.newImage('images/npc/'..node.name..'_menu.png'), 
                        npc.props.tickImage or love.graphics.newImage('images/menu/selector.png'),
                        npc,
                        menuColor)

    npc.emotion = Emotion.new(npc)

    return npc
end

function NPC:enter( previous )
    if self.props.enter then self.props.enter(self, previous) end

    -- Check player inventory on NPC creation
    local player = Player.factory()
    self:checkInventory(player)
end

---
-- Draws the NPC to the screen
-- @return nil
function NPC:draw()
    if self.state == 'hidden' then return end
    local anim = self:animation()
    anim:draw(self.image, self.position.x + (self.direction=="left" and self.width or 0), self.position.y, 0, (self.direction=="left") and -1 or 1, 1)
    self.menu:draw(self.position.x, self.position.y - 50)
    self.emotion:draw(self)

    if self.displayAffection then
        love.graphics.setColor( 0, 0, 255, 255 )
        love.graphics.print("+ " .. self.affection, self.affectionText.x, self.affectionText.y, 0, 0.7, 0.7)
        love.graphics.setColor(255,255,255,255)
    end

end

function NPC:keypressed( button, player )
    if self.dead or self.angry then return end
    
    if button == 'INTERACT' and self.menu.state == 'closed' and not player.jumping and not player.isClimbing and not self.busy then
        player.freeze = true
        player.character.state = 'idle'
        self.state = 'default'
        self.orig_direction = self.direction
        if self.donotfacewhentalking then
        elseif player.position.x < self.position.x then
            self.direction = "left"
        else
            self.direction = "right"
        end
        if self.greeting and self.db:get( self.name .. '-greeting', true) then
            local walking_temp = self.walking
            self.walking = false
            Dialog.new(self.greeting, function()
                self.menu:open(player)
                self.walking = walking_temp
            end)
            self.db:set( self.name .. '-greeting', false)
        else
            self.menu:open(player)
        end
        if self.begin then self.begin(self, player) end
    else
        return self.menu:keypressed(button, player)
    end
end

---
-- Called when the NPC begins colliding with another node
-- @param node the node you're colliding with
-- @param dt deltatime
-- @param mtv_x amount the node must be moved in the x direction to stop colliding
-- @param mtv_y amount the node must be moved in the y direction to stop colliding
-- @return nil
function NPC:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer and self.stare and self.walking then
        self.wasWalking = true
        self.walking = false
    end
    
    if self.props.collide then self.props.collide(self, node, dt, mtv_x, mtv_y) end
end

function NPC:hurt(damage, special_damage, knockback)
    if self.props.hurt then
        self.props.hurt(self, special_damage, knockback)
    end
end


function NPC:animation()
    return self.animations[self.state]
end

---
-- Called when the NPC finishes colliding with another node
-- @return nil
function NPC:collide_end(node, dt)
    if node.isPlayer and self.stare and self.wasWalking then
        self.wasWalking = false
        self.walking = true
    end
end

---
-- Updates the NPC
-- dt is the amount of time in seconds since the last update
function NPC:update(dt, player)
    if self.state == 'hidden' then return end
    if self.menu.state ~= "closed" then self.menu:update(dt) end
    self:animation():update(dt)
    self:handleSounds(dt)

    if self.menu.state == "closing" then
        self.direction = self.orig_direction
    end
    
    -- The npc is dead and can no longer interact
    if self.dead then return end

    if self.walking and self.menu.state == "closed" then self.state = 'walking' end
    if self.state == 'walking' and not self.walking then self.state = 'default' end
    if self.state == 'walking' then self:walk(dt)
    else self.velocity = {x=0, y=0} end

    if self.stare then
        if player.position.x < self.position.x then
            self.direction = "left"
        else
            self.direction = "right"
        end
    end
    
    if self.props.update then
        self.props.update(dt, self, player)
    end
  	if self.displayAffection then
        self.affectionText.x = self.position.x + self.width / 2
        self.affectionText.y = self.affectionText.y + self.affectionVel.y * dt
        self.affectionVel.y = -35
    else
		self.affectionText.y = self.position.y
	end

    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt

    -- Moves the bb with the npc
    self:update_bb()
end

function NPC:affectionUpdate(amount) 
  self.displayAffection = true
  self.affection = amount
  Timer.add(.45, function()
    self.displayAffection = false
    end)
end

function NPC:update_bb()
    local x1,y1,x2,y2 = self.bb:bbox()
    self.bb:moveTo( self.position.x + (x2-x1)/2 + self.bb_offset.x,
                    self.position.y + (y2-y1)/2 + self.bb_offset.y )
end

function NPC:show_death()
    local dead = self.db:get( self.name .. '-dead', false)

    self.dead = true
    if type(dead) ~= "boolean" then
        self.position = dead.position
        self.bb_offset = dead.bb_offset
        self.direction = dead.direction
        self:update_bb()
    end
    self.state = 'dying'
    -- Prevent the animation from playing
    self:animation():pause()
end

function NPC:store_death()
    self.db:set( self.name .. '-dead', {
        position = self.position,
        bb_offset = self.bb_offset,
        direction = self.direction
    })
end

function NPC:walk(dt)
    if self.minx == self.maxx then
    elseif self.position.x > self.maxx then
        self.direction = 'left'
    elseif self.position.x < self.minx then
        self.direction = 'right'
    end
    local direction = self.direction == 'right' and 1 or -1
    self.velocity.x = self.walk_speed * direction
end

-- Follows the path defined in self.props.run_offsets
function NPC:run(dt, player)
    -- If npc is within 5px of target it's time to move to the next one
    if math.abs(self.position.x - self.run_offsets[self.run_offsets_index].x - self.original_pos.x) < self.run_speed * dt and
       math.abs(self.position.y - self.run_offsets[self.run_offsets_index].y - self.original_pos.y) < self.run_speed * dt / 2 then
        self.run_offsets_index = self.run_offsets_index + 1
    end
    -- If the end of the target points is reached loop between the last two points
    if self.run_offsets_index > #self.run_offsets then
        self.run_offsets_index = self.run_offsets_index - 2
    end
    local target_pos = self.run_offsets[self.run_offsets_index]
    
    -- Direction of x movement
    local direction_x = 0
    
    -- Determine which x direction to move in
    -- Checks position within one frame of movement
    if self.position.x < target_pos.x + self.original_pos.x - self.run_speed * dt then
        direction_x = 1
        -- Only switch direction if necessary
        if self.direction == 'left' then 
            self.direction = 'right'
        end
    elseif self.position.x > target_pos.x + self.original_pos.x + self.run_speed * dt then
        direction_x = -1
        -- Only switch direction if necessary
        if self.direction == 'right' then
            self.direction = 'left'
        end
    end
    
    -- Direction of y movement
    local direction_y = 0
    
    -- Determine which y direction to move in
    -- Checks position within one frame of movement
    if self.position.y > target_pos.y + self.original_pos.y + self.run_speed * dt / 2 then
        direction_y = -1
    elseif self.position.y < target_pos.y + self.original_pos.y - self.run_speed * dt / 2 then
        direction_y = 1
    end

    -- Determine how fast to move on each axis
    -- Useful for when NPCs travel diagonally
    local target_pos_prev = {x=0, y=0}
    if self.run_offsets_index > 1 then
        target_pos_prev = self.run_offsets[self.run_offsets_index - 1]
    end
    local speed_fraction_x = 1
    local speed_fraction_y = 1
    local target_delta_x = math.abs(target_pos.x - target_pos_prev.x)
    local target_delta_y = math.abs(target_pos.y - target_pos_prev.y)
    if target_delta_y > 0 and target_delta_x > 0 then
        if target_delta_y > target_delta_x then
            speed_fraction_x = target_delta_x / target_delta_y / 2
        else
            speed_fraction_y = target_delta_y / target_delta_x
        end
    end

    self.velocity.x = self.run_speed * direction_x
    self.velocity.y = self.run_speed * direction_y / 2
end

-- Checks for certain items in the players inventory
function NPC:checkInventory(player)
    if self.dead then return end

    if self.props.check_level_items then

        -- make a list of all default weapons and projectiles and count them
        local level_default = {}
        local default_nodes = utils.require("maps/" .. self.containerLevel.name)
        for k,v in pairs(default_nodes.objectgroups.nodes.objects) do
            if v.type == 'weapon' or v.type == 'projectile' then
                if not level_default[v.name] then
                    level_default[v.name] = 1
                else
                    level_default[v.name] = level_default[v.name] + 1
                end
            end
        end

        -- make a list of all weapons and projectiles in level currently
        local level_current = {}
        for k,v in pairs(self.containerLevel.nodes) do
            if v.isWeapon or v.isProjectile then
                if player.currently_held and player.currently_held == v then
                else
                    if not level_current[v.name] then
                        level_current[v.name] = 1
                    else
                        level_current[v.name] = level_current[v.name] + 1
                    end
                end
            end
        end

        -- check current items against default items for anything missing
        local missing = false
        for k,v in pairs(level_default) do
            if level_current[k] == nil or level_current[k] < level_default[k] then
                missing = true
            end
        end

        if self.props.item_found then
            self.props.item_found(self, missing)
        end
    end

    -- check for specific items that NPC will notice in player inventory
    for _, special_item in ipairs(self.special_items) do
        local Item = require('items/item')
        local itemNode = utils.require ('items/weapons/'..special_item)
        local item = Item.new(itemNode, 1)
        
        if player.inventory:search(item) then
            -- npc reaction to finding a special item
            if self.props.item_found then
                self.props.item_found(self, true)
            end
        end
    end
end

function NPC:handleSounds(dt)
    self.lastSoundUpdate = self.lastSoundUpdate + dt
    for _,v in pairs((self.props.sounds or {})) do
        if self.state==v.state and self:animation().position==v.position and self.lastSoundUpdate > 0.5 then
            sound.playSfx(v.file)
            self.lastSoundUpdate = 0
  end
    end
end

function NPC:leave()


end


return NPC