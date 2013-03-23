local Gamestate = require 'vendor/gamestate'
local Tween = require 'vendor/tween'
local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local Prompt = require 'prompt'

local Door = {}
Door.__index = Door

function Door.new(node, collider)
    local door = {}
    setmetatable(door, Door)
    
    door.level = node.properties.level
    
    --if you can go to a level, setup collision detection
    --otherwise, it's just a location reference
    if door.level then
        door.player_touched = false
        door.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
        door.bb.node = door
        collider:setPassive(door.bb)
    end
    
    door.instant  = node.properties.instant
    door.warpin = node.properties.warpin
    door.button = node.properties.button and node.properties.button or 'UP'
    --either a specific sound or false to disable
    door.sound = node.properties.sound and node.properties.sound or true
    if door.sound == 'false' then door.sound = false end
    door.info = node.properties.info
    door.to = node.properties.to
    door.height = node.height
    door.width = node.width
    door.node = node
    door.key = node.properties.key
    
    door.hideable = node.properties.hideable == 'true'
    
    -- generic support for hidden doors
    if door.hideable then
        door.hidden = true
        door.sprite = love.graphics.newImage('images/' .. node.properties.sprite .. '.png')
        door.sprite_width = tonumber( node.properties.sprite_width )
        door.sprite_height = tonumber( node.properties.sprite_height )
        door.grid = anim8.newGrid( door.sprite_width, door.sprite_height, door.sprite:getWidth(), door.sprite:getHeight())
        door.animode = node.properties.animode and node.properties.animode or 'once'
        door.anispeed = node.properties.anispeed and tonumber( node.properties.anispeed ) or 1
        door.aniframes = node.properties.aniframes and node.properties.aniframes or '1,1'
        door.animation = anim8.newAnimation(door.animode, door.grid(door.aniframes), door.anispeed)
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
    local _, _, _, py2 = player.bottom_bb:bbox()
    
    if player.currently_held and not player.currently_held.isWeapon then
        player:drop()
    end

    self.player_touched = false
    if math.abs(wy2 - py2) > 10 or player.jumping then
        return
    end

    if not self.key or player.inventory:hasKey(self.key) then
        if self.sound ~= false and not self.instant then
            sound.playSfx( ( type(self.sound) ~= 'boolean' ) and self.sound or 'unlocked' )
        end
        local current = Gamestate.currentState()
        if current.name ~= self.level then
            current:exit(self.level, self.to)
        else
            local destDoor = current.doors[self.to]
            player.position.x = destDoor.x+destDoor.node.width/2-player.width/2
            player.position.y = destDoor.y+destDoor.node.height-player.height
        end
    else
        sound.playSfx('locked')
        player.freeze = true
        local message
        if self.info then
            message = {self.info}
        else
            message = {'You need a "'..self.key..'" key to open this door.'}
        end
        local callback = function(result)
            self.prompt = nil
            player.freeze = false
        end
        local options = {'Exit'}
        self.prompt = Prompt.new(message, callback, options)
    end
end

function Door:collide(node)
    if self.hideable and self.hidden then return end
    if not node.isPlayer then return end
    
    if self.loaded >= os.time() - 1 then
        self.instant_block = true
    end
    
    if self.instant and not self.instant_block then
        self:switch(node)
    end
end

function Door:collide_end(node,dt)
    self.instant_block = nil
end

function Door:enter(previous)
    self.loaded = os.time()
end

function Door:leave()
    self.loaded = nil
end

function Door:keypressed( button, player)
    if player.freeze or player.dead then return end
    if self.hideable and self.hidden then return end
    if button == self.button then
        self:switch(player)
    end
end

-- everything below this is required for hidden doors
function Door:show()
    if self.hideable and self.hidden then
        self.hidden = false
        sound.playSfx( 'reveal' )
        Tween.start( self.movetime, self.position, self.position_shown )
    end
end

function Door:hide()
    if self.hideable and not self.hidden then
        self.hidden = true
        sound.playSfx( 'unreveal' )
        Tween.start( self.movetime, self.position, self.position_hidden )
    end
end

function Door:update(dt)
    if self.animation then
        self.animation:update(dt)
    end
end

function Door:draw()

    if not self.hideable then return end
    
    self.animation:draw(self.sprite, self.position.x, self.position.y)
end

return Door


