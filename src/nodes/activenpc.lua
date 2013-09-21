--MUST READ: 
-- to use this file do the following
-- 1)find and replace each capitalized instance of Activenpc
-- with a capitalized version of your node's name
-- 2) find and replace each lowercase instance of activenpc
-- with a lowercase version of your node's name(this should be the same as the filename)
-- 3) start coding

local anim8 = require 'vendor/anim8'
local Dialog = require 'dialog'
local window = require "window"
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'

local Menu = {}
Menu.__index = Menu

function Menu.new(items, responses, background, tick)
    local menu = {}
    setmetatable(menu, Menu)
    menu.responses = responses
    menu.rootItems = items
    menu.items = items
    menu.itemWidth = 150
    menu.choice = 1
    menu.offset = 0
    menu.background = background
    menu.tick = tick
    local utils = require 'utils'
    utils.inspect(background)
    local h = anim8.newGrid(69, 43, background:getWidth(), background:getHeight())
    menu.animation = anim8.newAnimation('once', h('1-6,1'), .08)
    menu.state = 'closed'
    return menu
end

function Menu:keypressed( button, player )
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
        if item == nil or item.text == 'exit' or item.text == 'i am done with you' then
            self:close()
            player.freeze = false
        elseif self.responses[item.text] then
            self:hide()
            if item.option then
                self.items = item.option
                self.choice = 4
            end
            self.dialog = Dialog.new(self.responses[item.text], function()
                self:show()
            end)
        elseif type(item.option) == 'table' then
            self.items = item.option
        end
    elseif button == 'INTERACT' then
        self:close()
        player.freeze = false
    end

    return true
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
                love.graphics.draw(self.tick, x - (Font:getWidth(value.text)+8), y - (i - 1) * 12 + 2)
                love.graphics.setColor( 0, 0, 0, 255 )
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


function Menu:close()
    self.animation:resume()
    self.animation.direction = -1
    self.state = 'closing'
end


-----------------------------------------------
-- Activenpc.lua
-----------------------------------------------

local Activenpc = {}
Activenpc.__index = Activenpc
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Activenpc.isInteractive = true

---
-- Creates a new Activenpc object
-- @param node the table used to create this
-- @param a collider of objects
-- @return the Activenpc object created
function Activenpc.new(node, collider)
    --creates a new object
    local activenpc = {}
    --sets it to use the functions and variables defined in Activenpc
    -- if it doesn;t have one by that name
    setmetatable(activenpc, Activenpc)
    --stores all the parameters from the tmx file
    activenpc.node = node

    --stores parameters from a lua file
    activenpc.props = require('nodes/activenpcs/' .. node.name)

    --sets the position from the tmx file
    activenpc.position = {x = node.x, y = node.y}
    activenpc.width = node.width
    activenpc.height = node.height
    
    --initialize the node's bounding box
    activenpc.collider = collider
    activenpc.bb = collider:addRectangle(0,0,activenpc.props.bb_width,activenpc.props.bb_height)
    activenpc.bb.node = activenpc
    activenpc.collider:setPassive(activenpc.bb)
 
    --define some offsets for the bounding box that can be used each update cycle
    activenpc.bb_offset = {x = activenpc.props.bb_offset_x or 0,
                           y = activenpc.props.bb_offset_y or 0}
 
    
    --add more initialization code here if you want
    activenpc.controls = nil
    
    activenpc.state = "default"
    activenpc.direction = "right"
    
    local npcImage = love.graphics.newImage('images/activenpcs/'..node.name..'.png')
    local g = anim8.newGrid(activenpc.props.width, activenpc.props.height, npcImage:getWidth(), npcImage:getHeight())
    activenpc.image = npcImage
    
    activenpc.animations = {}
    for state, data in pairs( activenpc.props.animations ) do
        activenpc.animations[ state ] = anim8.newAnimation( data[1], g( unpack(data[2]) ), data[3])
    end

    activenpc.lastSoundUpdate = math.huge

    activenpc.menu = Menu.new(activenpc.props.items, activenpc.props.responses,
                        activenpc.props.menuImage, activenpc.props.tickImage)

    return activenpc
end

function Activenpc:enter( previous )
    if self.props.enter then
        self.props.enter(self, previous)
    end
end

---
-- Draws the Activenpc to the screen
-- @return nil
function Activenpc:draw()
    local anim = self:animation()
    anim:draw(self.image, self.position.x, self.position.y, 0, (self.direction=="left") and -1 or 1)
    self.menu:draw(self.position.x, self.position.y - 50)
    --if self.prompt then
    --    self.prompt:draw(self.position.x + 20, self.position.y - 35)
    --end
end

function Activenpc:keypressed( button, player )
    if button == 'INTERACT' and self.menu.state == 'closed' and not player.jumping and not player.isClimbing then
        player.freeze = true
        player.character.state = 'idle'
        
        self.menu:open()
        return self.menu:keypressed('ATTACK', player )
    end

  return self.menu:keypressed(button, player )
  
end

---
-- Called when the Activenpc begins colliding with another node
-- @param node the node you're colliding with
-- @param dt ?
-- @param mtv_x amount the node must be moved in the x direction to stop colliding
-- @param mtv_y amount the node must be moved in the y direction to stop colliding
-- @return nil
function Activenpc:collide(node, dt, mtv_x, mtv_y)
end


function Activenpc:animation()
    return self.animations[self.state]
end

---
-- Called when the Activenpc finishes colliding with another node
-- @return nil
function Activenpc:collide_end(node, dt)
end

---
-- Updates the Activenpc
-- dt is the amount of time in seconds since the last update
function Activenpc:update(dt)
    if self.menu.state ~= "closed" then self.menu:update(dt) end
    self:animation():update(dt)
    self:handleSounds(dt)


    local x1,y1,x2,y2 = self.bb:bbox()
    self.bb:moveTo( self.position.x + (x2-x1)/2 + self.bb_offset.x,
                 self.position.y + (y2-y1)/2 + self.bb_offset.y )
end

function Activenpc:handleSounds(dt)
    self.lastSoundUpdate = self.lastSoundUpdate + dt
    for _,v in pairs(self.props.sounds) do
        if self.state==v.state and self:animation().position==v.position and self.lastSoundUpdate > 0.5 then
            sound.playSfx(v.file)
            self.lastSoundUpdate = 0
        end
    end
end

return Activenpc