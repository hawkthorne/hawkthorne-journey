local anim8 = require 'vendor/anim8'
local Dialog = require 'dialog'
local window = require "window"
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'

local Menu = {}
Menu.__index = Menu

function Menu.new(items, responses, commands, background, tick, npc)
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
            if self.commands[item.text] then
                self.commands[item.text](self.host, player)
            end
            if self.commands[item.text] and not self.responses[item.text] then
                self:close(player)
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

    love.graphics.setColor( 0, 0, 0, 255 )
    Font = love.graphics.getFont()

    y = y + 36

    for i, value in ipairs(self.items) do
        i = i - self.offset
        if i > 0 then
            love.graphics.printf(value.text, x - self.itemWidth, y - (i - 1) * 12,
                                 self.itemWidth, 'right')

            if self.choice == i then
                love.graphics.setColor( 255, 255, 255, 255 )

                love.graphics.draw(self.tick, x - (Font:getWidth(value.text)+10), y - (i - 1) * 12 + 2)
                love.graphics.setColor( 0, 0, 0, 255 )
                love.graphics.rectangle( 'line', x - (Font:getWidth(value.text)+1) -1, y - (i - 1) * 12 -1, Font:getWidth(value.text) +2 , Font:getHeight(value.text) +2 )
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
    --creates a new object
    local npc = {}
    --sets it to use the functions and variables defined in NPC
    -- if it doesn;t have one by that name
    setmetatable(npc, NPC)
    --stores all the parameters from the tmx file
    npc.node = node

    --stores parameters from a lua file

    npc.props = require('npcs/' .. node.name)

    npc.name = node.name

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
  
    -- deals with npc walking
    npc.walking = npc.props.walking or false
    npc.minx = node.x - (npc.props.max_walk or 48)
    npc.maxx = node.x + (npc.props.max_walk or 48)
    npc.walk_speed = npc.props.walk_speed or 18
    npc.wasWalking = false

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
    newMenuItems = {
     { ['text']='exit' },
     { ['text']='inventory' },
     { ['text']='command', ['option']=(npc.props.command_items or {})},
     { ['text']='talk', ['option']=npc.props.talk_items}
    }

    npc.love = 0
    npc.respect = 0
    npc.trust = 0

    newCommands = npc.props.talk_commands or {}
    command_commands = npc.props.command_commands or {}

     for k,v in pairs(command_commands) do newCommands[k] = v end

    npc.menu =    Menu.new(newMenuItems,
                        npc.props.talk_responses, 
                        newCommands,
                        npc.props.menuImage or love.graphics.newImage('images/npc/'..node.name..'_menu.png'), 
                        npc.props.tickImage or love.graphics.newImage('images/menu/selector.png'),
                        npc)

    return npc
end

function NPC:enter( previous )
    if self.props.enter then self.props.enter(self, previous) end
end

---
-- Draws the NPC to the screen
-- @return nil
function NPC:draw()
    local anim = self:animation()
    anim:draw(self.image, self.position.x + (self.direction=="left" and self.width or 0), self.position.y, 0, (self.direction=="left") and -1 or 1, 1)
    self.menu:draw(self.position.x, self.position.y - 50)
end

function NPC:keypressed( button, player )
    if button == 'INTERACT' and self.menu.state == 'closed' and not player.jumping and not player.isClimbing then
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
        self.menu:open(player)
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
    if self.menu.state ~= "closed" then self.menu:update(dt)end
    self:animation():update(dt)
    self:handleSounds(dt)

    if self.menu.state == "closing" then
        self.direction = self.orig_direction
    end

    if self.walking and self.menu.state == "closed" then self.state = 'walking' end
    if self.state == 'walking' and not self.walking then self.state = 'default' end
    if self.state == 'walking' then self:walk(dt) end

    if self.stare then
        if player.position.x < self.position.x then
            self.direction = "left"
        else
            self.direction = "right"
        end
    end

    local x1,y1,x2,y2 = self.bb:bbox()
    self.bb:moveTo( self.position.x + (x2-x1)/2 + self.bb_offset.x,
                 self.position.y + (y2-y1)/2 + self.bb_offset.y )
end

function NPC:walk(dt)
    if self.minx == self.maxx then
    elseif self.position.x > self.maxx then
        self.direction = 'left'
    elseif self.position.x < self.minx then
      self.direction = 'right'
    end
    local direction = self.direction == 'right' and 1 or -1
    self.position.x = self.position.x + self.walk_speed * dt * direction
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

return NPC