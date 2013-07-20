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


local Npc = {}
Npc.__index = Npc
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Npc.isInteractive = true

function Npc.new(node, collider)
    local npc = {}
    setmetatable(npc, Npc)

    local character = require('npcs/' .. node.properties.person)

    local npcImage = character.sprite
    local g = anim8.newGrid(32, 48, npcImage:getWidth(), npcImage:getHeight())

    npc.image = npcImage
    npc.animations = {
        walking = {
            right = anim8.newAnimation('loop', g('1-3,1'), .18),
            left = anim8.newAnimation('loop', g('1-3,2'), .18),
        },
        standing = {
            right = anim8.newAnimation('loop', g('1,1', '10,1'), 2, {[2]=.1}),
            left = anim8.newAnimation('loop', g('1,2', '10,2'), 2, {[2]=.1}),
        },
        talking = {
            right = anim8.newAnimation('loop', g('1,1', '11,1'), .8, {[2]=.3}),
            left = anim8.newAnimation('loop', g('1,2', '11,2'), .8, {[2]=.3}),
        },
    }

    npc.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    npc.bb.node = npc
    npc.collider = collider
    npc.collider:setPassive(npc.bb)
    npc.walk = character.walk
    npc.state = character.walk and 'walking' or 'standing'
    npc.direction = 'right'

    npc.stare = ( not character.walk and character.stare )

    npc.width = node.width
    npc.height = node.height
    npc.position = { x = node.x + 12, y = node.y }
    npc.maxx = node.x + 48
    npc.minx = node.x - 48
    npc.menu = Menu.new(character.items, character.responses,
                        character.menuImage, character.tickImage)
    return npc
end

function Npc:draw()
    local animation = self.animations[self.state][self.direction]
    animation:draw(self.image, math.floor(self.position.x) + 8, self.position.y)
    self.menu:draw(self.position.x, self.position.y - 50)
end

function Npc:update(dt, player)
    local animation = self.animations[self.state][self.direction]
    animation:update(dt)

    if self.position.x > self.maxx then
        self.direction = 'left'
    elseif self.position.x < self.minx then
        self.direction = 'right'
    end

    local direction = self.direction == 'right' and 1 or -1

    if self.state == 'walking' then
        self.position.x = self.position.x + 18 * dt * direction
    elseif self.menu.dialog == nil or self.menu.dialog.state == 'closed' then
        self.state = 'standing'
        if self.stare then
            if player.position.x < self.position.x then
                self.direction = 'left'
            else
                self.direction = 'right'
            end
        end
    else
        self.state = 'talking'
    end

    if self.menu.state == 'closed' then
        self.state = self.walk and 'walking' or 'standing'
    end

    self:moveBoundingBox(self)
    
    self.menu:update(dt)
end

function Npc:moveBoundingBox()
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + (self.height / 2) + 2)
end

function Npc:keypressed( button, player )
  if button == 'INTERACT' and self.menu.state == 'closed' and not player.jumping and not player.isClimbing then
    player.freeze = true
    player.character.state = 'idle'
    self.state = 'standing'

    local x1,_,x2,_ = self.bb:bbox()
    local width = x2-x1
    if player.position.x < self.position.x then
      self.direction = 'left'
      player.character.direction = 'right'
      self.position.x = player.position.x+width/2
    else
      self.direction = 'right'
      player.character.direction = 'left'
      self.position.x = player.position.x-width/2
    end
    self.position.x = self.position.x > self.maxx and self.maxx or self.position.x
    self.position.x = self.position.x < self.minx and self.minx or self.position.x

    self.menu:open()
    return self.menu:keypressed('ATTACK', player )
  end

  return self.menu:keypressed(button, player )
  
end

return Npc
