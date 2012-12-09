local Gamestate = require 'vendor/gamestate'
local Tween = require 'vendor/tween'
local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Dialog = require 'dialog'
local Floorspaces = require 'floorspaces'
local Sprite = require 'nodes/sprite'

local Door = {}
Door.__index = Door

function Door.new(node, collider, home_level)
    local door = {}
    setmetatable(door, Door)

    door.level = node.properties.level

    --if you can go to a level, setup collision detection
    --otherwise, it's just a location reference
    door.collider = collider
    if door.level then
        door.player_touched = false
        door.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
        door.bb.node = door
        collider:setPassive(door.bb)
    end
    
    door.instant  = node.properties.instant
    door.isElevator = node.properties.isElevator
    local FLOOR_LIMIT = 10
    if door.isElevator then
        door.floors = {}
        for i = 1,FLOOR_LIMIT do
            if node.properties['floor'..i] then
                door.floors[i] = node.properties['floor'..i]
            end
        end
        local depth = 25
        local bgNode = {x = node.x,y=node.y,
                        objectlayer = 'nodes',
                        properties = {sheet='images/elevator_background.png',
                                      width = node.width,height=node.height-depth,}
                        }
        table.insert(home_level.nodes,Sprite.new(bgNode,collider))
    end
    door.warpin = node.properties.warpin
    door.button = node.properties.button and node.properties.button or 'UP'
    door.to = node.properties.to
    door.height = node.height
    door.width = node.width
    door.node = node
    
    door.hideable = node.properties.hideable == 'true'
    
    -- generic support for hidden doors
    if door.hideable then
        door.hidden = true
        door.closing_time = node.properties.closing_time or 2
        door.sprite = love.graphics.newImage('images/' .. node.properties.sprite .. '.png')
        door.sprite_width = tonumber( node.properties.sprite_width )
        door.sprite_height = tonumber( node.properties.sprite_height )
        door.grid = anim8.newGrid( door.sprite_width, door.sprite_height, door.sprite:getWidth(), door.sprite:getHeight())
        door.animode = node.properties.animode and node.properties.animode or 'once'
        door.anispeed = node.properties.anispeed and tonumber( node.properties.anispeed ) or 1
        door.aniframes = node.properties.aniframes and node.properties.aniframes or '1,1'
        door.animation = anim8.newAnimation(door.animode, door.grid(door.aniframes), door.anispeed)
        door.openAnimation = anim8.newAnimation(door.animode, door.grid(node.properties.openframes), door.anispeed)
        door.closeAnimation = anim8.newAnimation(door.animode, door.grid(node.properties.closeframes), door.anispeed)
        door.position_hidden = {
            x = node.x + ( node.properties.offset_hidden_x and tonumber( node.properties.offset_hidden_x ) or 0 ),
            y = node.y + ( node.properties.offset_hidden_y and tonumber( node.properties.offset_hidden_y ) or 0 )
        }
        door.position_shown = {
            x = node.x + ( node.properties.offset_shown_x and tonumber( node.properties.offset_shown_x ) or 0 ),
            y = node.y + ( node.properties.offset_shown_y and tonumber( node.properties.offset_shown_y ) or 0 )
        }
        door.position = deepcopy(door.position_hidden)
        door.movetime = node.properties.movetime and tonumber(node.properties.movetime) or 1
    end
    
    return door
end

function Door:switch(player)
    local _, _, _, wy2  = self.bb:bbox()
    local _, _, _, py2 = player.bb:bbox()
    
    if player.currently_held and player.currently_held.unuse then
        player.currently_held:unuse('sound_off')
    elseif player.currently_held then
        player:drop()
    end

    self.player_touched = false
    if math.abs(wy2 - py2) > 10 or player.jumping then
        return
    end

    local level = Gamestate.get(self.level)
    local current = Gamestate.currentState()

    if current == level then
        player.position = { -- Copy, or player position corrupts entrance data
            x = level.doors[ self.to ].x + level.doors[ self.to ].node.width / 2 - player.width / 2,
            y = level.doors[ self.to ].y + level.doors[ self.to ].node.height - player.height
        }
        return
    --place character squarely in elevator before transport
    elseif self.isElevator then
        local elevX,elevY,_,_ = self.bb:bbox()
        local padding = 0
         player.position = { -- Copy, or player position corrupts entrance data
            x = elevX + self.node.width / 2 - player.width / 2,
            y = elevY + self.node.height - player.height - padding
        }
        player:moveBoundingBox()
   end

    -- current.collider:setPassive(player.bb)
    if self.isElevator then
        player.freeze = true
        self:hide()
        Timer.add(self.closing_time,function() 
            assert(self.level~='TBD',"Error: level must be selected by elevator switch")
            Gamestate.switch(self.level,self.to,player)
        end)
    elseif self.level == 'overworld' then
        Gamestate.switch(self.level, self.to)
    else
        Gamestate.switch(self.level, self.to)
    end

end

function Door:collide(node)
    if self.hideable and self.hidden then return end
    if not node.isPlayer then return end
    
    if self.instant then
        self:switch(node)
    end
end

function Door:keypressed( button, player)
    if self.dialog then
        self.dialog:keypressed( button )
    end
    if player.freeze or player.dead then return end
    if self.hideable and self.hidden then return end
    if button == self.button and self.isElevator and self.level=='TBD' then
        player.freeze = true
        self.dialog = Dialog.new(190, 80,"Select a floor, first", function()
            player.freeze = false
            self.dialog = nil
        end)
        self.dialog.x=self.position.x
        self.dialog.y=self.position.y
        self.dialog.width = 190
        self.dialog.height = 80
    elseif button == self.button then
        self:switch(player)
    end
end

-- everything below this is required for hidden doors
function Door:show()
    if self.hideable and self.hidden then
        self.hidden = false
        if self.isElevator then
            sound.playSfx( 'ding' )
            self.animation = self.openAnimation
            self.animation:gotoFrame(1)
            self.animation:resume()
        else
            sound.playSfx( 'reveal' )
            Tween.start( self.movetime, self.position, self.position_shown )
        end
    end
end

function Door:hide()
    if self.hideable and not self.hidden then
        self.hidden = true
        if self.isElevator then
            sound.playSfx( 'ding' )
            self.animation = self.closeAnimation
            self.animation:gotoFrame(1)
            self.animation:resume()
        else
            sound.playSfx( 'unreveal' )
            Tween.start( self.movetime, self.position, self.position_hidden )
        end
    end
end

function Door:update(dt,player)
    if not self.animation then return end
    
    if self.dialog then
        self.dialog:update(dt)
    end
    
    for k,v in pairs(Floorspaces.objects) do
        if v.node.name and v.node.name == self.node.name then
            if (self.animation == self.closeAnimation and self.closeAnimation.status == 'finished') then
                v.collider:setSolid(v.bb)
            else
                v.collider:setGhost(v.bb)
            end
            break
        end
    end
    self.animation:update(dt)
end

function Door:draw()
    if not self.hideable then return end

    self.animation:draw(self.sprite, self.position.x, self.position.y)
    if self.dialog then
        self.dialog:draw(self.position.x, self.position.y)
    end
end

return Door


