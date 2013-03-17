local Gamestate = require 'vendor/gamestate'
local queue = require 'queue'
local anim8 = require 'vendor/anim8'
local tmx = require 'vendor/tmx'
local HC = require 'vendor/hardoncollider'
local Timer = require 'vendor/timer'
local Tween = require 'vendor/tween'
local camera = require 'camera'
local window = require 'window'
local sound = require 'vendor/TEsound'
local controls = require 'controls'
local transition = require 'transition'
local HUD = require 'hud'
local music = {}

local node_cache = {}
local tile_cache = {}

local Player = require 'player'
local Floorspace = require 'nodes/floorspace'
local Floorspaces = require 'floorspaces'
local Platform = require 'nodes/platform'
local Block = require 'nodes/block'

local function limit( x, min, max )
    return math.min(math.max(x,min),max)
end

local function load_tileset(name)
    if tile_cache[name] then
        return tile_cache[name]
    end
    
    local tileset = tmx.load(require("maps/" .. name))
    tile_cache[name] = tileset
    return tileset
end

local function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    if shape_a.player and shape_b.player then return end
    local player, node, node_a, node_b

    if shape_a.player then
        player = shape_a.player
        node = shape_b.node
        node.player_touched = true
        if node.collide then
            node:collide(player, dt, mtv_x, mtv_y, shape_a)
        end
    elseif shape_b.player then
        player = shape_b.player
        node = shape_a.node
        node.player_touched = true
        if node.collide then
            node:collide(player, dt, mtv_x, mtv_y, shape_b)
        end
    else
        node_a = shape_a.node
        node_b = shape_b.node
    end

    if node_a then
        if node_a.collide then
            node_a:collide(node_b, dt, mtv_x, mtv_y)
        end
        if node_b.collide then
            node_b:collide(node_a, dt, mtv_x, mtv_y)
        end
    end

end

-- this is called when two shapes stop colliding
local function collision_stop(dt, shape_a, shape_b)
    if shape_a.player and shape_b.player then return end
    local player, node

    if shape_a.player then
        player = shape_a.player
        node = shape_b.node
    elseif shape_b.player then
        player = shape_b.player
        node = shape_a.node
    else
        node_a = shape_a.node
        node_b = shape_b.node
    end

    if node then
        node.player_touched = false

        if node.collide_end then
            node:collide_end(player, dt)
        end
    else
        if node_a.collide_end then
            node_a:collide_end(node_b, dt)
        end
        if node_b.collide_end then
            node_b:collide_end(node_a, dt)
        end
    end
end

local function setBackgroundColor(map)
    local prop = map.properties
    if not prop.red then
        love.graphics.setBackgroundColor(0, 0, 0)
        return
    end
    love.graphics.setBackgroundColor(tonumber(prop.red),
                                     tonumber(prop.green),
                                     tonumber(prop.blue))
end

local function getCameraOffset(map)
    local prop = map.properties
    if not prop.offset then
        return 0
    end
    return tonumber(prop.offset) * map.tilewidth
end

local function getTitle(map)
    local prop = map.properties
    return prop.title or "UNKNOWN"
end

local function getSoundtrack(map)
    local prop = map.properties
    return prop.soundtrack or "level"
end

local Level = {}
Level.__index = Level
Level.isLevel = true


function Level.load_node(name)
    if node_cache[name] then
        return node_cache[name]
    end

    local node = require('nodes/' .. name)
    node_cache[name] = node
    return node
end

function Level.new(name)
    local level = {}
    setmetatable(level, Level)

    level.over = false
    level.state = 'idle'  -- TODO: Use state machine
    level.name = name

    assert( love.filesystem.exists( "maps/" .. name .. ".lua" ),
            "maps/" .. name .. ".lua not found.\n\n" ..
            "Have you generated your maps lately?\n\n" ..
            "LINUX / OSX: run 'make maps'\n" ..
            "WINDOWS: use tmx2lua to generate\n\n" ..
            "Check the documentation for more info."
    )

    level.map = require("maps/" .. name)
    level.tileset = load_tileset(name)
    level.collider = HC(100, on_collision, collision_stop)
    level.offset = getCameraOffset(level.map)
    level.music = getSoundtrack(level.map)
    level.spawn = (level.map.properties and level.map.properties.respawn) or 'studyroom'
    level.title = getTitle(level.map)
    level.environment = {r=255, g=255, b=255, a=255}
 
    level:panInit()

    level.player = Player.factory(level.collider)
    level.boundary = {
        width =level.map.width  * level.map.tilewidth,
        height=level.map.height * level.map.tileheight
    }

    level.transition = transition.new('fade', 0.5)
    level.events = queue.new()
    level.trackPlayer = true
    level.nodes = {}
    level.doors = {}

    level.default_position = {x=0, y=0}
    for k,v in pairs(level.map.objectgroups.nodes.objects) do
        local NodeClass = Level.load_node(v.type)
        local node
        if NodeClass and v.type == 'scenetrigger' then
            v.objectlayer = 'nodes'
            local layer = level.map.objectgroups[v.properties.cutscene]
            node = NodeClass.new( v, level.collider, layer )
            level:addNode(node)
        elseif NodeClass then
            v.objectlayer = 'nodes'
            node = NodeClass.new( v, level.collider )
            level:addNode(node)
        end

        if v.type == 'door' then
            if v.name then
                if v.name == 'main' then
                    level.default_position = {x=v.x, y=v.y}
                end
                
                level.doors[v.name] = {x=v.x, y=v.y, node=node}
            end
        end
    end

    if level.map.objectgroups.floorspace then
        level.floorspace = true
        for k,v in pairs(level.map.objectgroups.floorspace.objects) do
            v.objectlayer = 'floorspace'
            local node = Floorspace.new(v, level)
            level:addNode(node)
        end
    end

    if level.map.objectgroups.platform then
        for k,v in pairs(level.map.objectgroups.platform.objects) do
            v.objectlayer = 'platform'
            local node = Platform.new(v, level.collider)
            level:addNode(node)
        end
    end

    if level.map.objectgroups.block then
        for k,v in pairs(level.map.objectgroups.block.objects) do
            v.objectlayer = 'block'
            Block.new(v, level.collider, false)
        end
    end

    if level.map.objectgroups.ice then
        for k,v in pairs(level.map.objectgroups.ice.objects) do
            v.objectlayer = 'ice'
            Block.new(v, level.collider, true)
        end
    end

    level.player = player
    return level
end

function Level:restartLevel()
    assert(self.name ~= "overworld","level's name cannot be overworld")
    assert(Gamestate.currentState() ~= Gamestate.get("overworld"),"level cannot be overworld")
    self.over = false

    self.player = Player.factory(self.collider)
    self.player:refreshPlayer(self.collider)
    self.player.boundary = {
        width = self.map.width * self.map.tilewidth,
        height = self.map.height * self.map.tileheight
    }
    
    self.player.position = {x = self.default_position.x,
                            y = self.default_position.y}
    Floorspaces:init()
end


function Level:enter( previous, door, position )
    self.respawn = false
    self.state = 'idle'

    self.transition:forward(function()
        self.state = 'active'
    end)

    --only restart if it's an ordinary level
    if previous.isLevel or previous==Gamestate.get('overworld') then
        self.previous = previous
        self:restartLevel()
    end
    if previous == Gamestate.get('overworld') then
        self.respawn = true
        self.player.character:respawn()
    end
    if not self.player then
        self:restartLevel()
    end

    camera.max.x = self.map.width * self.map.tilewidth - window.width

    setBackgroundColor(self.map)
 
    sound.playMusic( self.music )

    self.hud = HUD.new(self)

    if door then
        self.player.position = {
            x = self.doors[ door ].x + self.doors[ door ].node.width / 2 - self.player.width / 2,
            y = self.doors[ door ].y + self.doors[ door ].node.height - self.player.height
        }
        if self.doors[ door ].warpin then
            self.player:respawn()
        end
        if self.doors[ door ].node then
            self.doors[ door ].node:show()
            self.player.freeze = false
        end
    end
    
    if position then
        local p = split(position, ",")
        self.player.position = {
            x = p[1] * self.map.tilewidth,
            y = p[2] * self.map.tileheight
        }
    end

    self:moveCamera()
    self.player:moveBoundingBox()


    for i,node in pairs(self.nodes) do
        if node.enter then node:enter(previous) end
    end

    self.player:setSpriteStates(self.player.current_state_set or 'default')
end

function Level:init()
end

local function leaveLevel(level, levelName, doorName)
  local destination = Gamestate.get(levelName)
            
  if level == destination then
    level.player.position = { -- Copy, or player position corrupts entrance data
      x = level.doors[doorName].x + level.doors[doorName].node.width / 2 - level.player.width / 2,
      y = level.doors[doorName].y + level.doors[doorName].node.height - level.player.height
    }
    return
  end

  Gamestate.switch(levelName, doorName)
end

function Level:update(dt)

    if self.state == 'idle' then
        self.transition:update(dt)
    end
    

    if self.state == 'active' or self.respawn == true then
        self.player:update(dt)
    end

    -- falling off the bottom of the map
    if self.player.position.y - self.player.height > self.map.height * self.map.tileheight then
        self.player.health = 0
        self.player.dead = true
    end

    -- start death sequence
    if self.player.dead and not self.over then
        sound.stopMusic()
        sound.playSfx( 'death' )
        self.over = true
        self.respawn = Timer.add(3, function()
            self.player.character:reset()
            if self.player.lives <= 0 then
                Gamestate.switch("gameover")
            else
                local respawnLevel = Gamestate.get(self.spawn)
                --usually send the character to studyroom and reset the overworld
                -- otherwise just send the character to the respawn level and keep his
                -- overworld progress
                if respawnLevel == Gamestate.get('studyroom') then
                    Gamestate.get('overworld'):reset()
                end
                Gamestate.switch(respawnLevel)
            end
        end)
    end

    for i,node in pairs(self.nodes) do
        if node.update then node:update(dt, self.player) end
    end

    self.collider:update(dt)

    self:updatePan(dt)
    self:moveCamera()

    local exited, levelName, doorName = self.events:poll('exit')
    if exited then
      leaveLevel(self, levelName, doorName)
    end
end

function Level:cameraPosition()
    local x = self.player.position.x + self.player.width / 2
    local y = self.player.position.y - self.map.tilewidth * 4.5
    return math.max(x - window.width / 2, 0),
      limit( limit(y, 0, self.offset) + self.pan, 0, self.offset )
end


function Level:moveCamera()
    if not self.trackPlayer then return end
    local x = self.player.position.x + self.player.width / 2
    local y = self.player.position.y - self.map.tilewidth * 4.5
    camera:setPosition( math.max(x - window.width / 2, 0),
                        limit( limit(y, 0, self.offset) + self.pan, 0, self.offset ) )
end

function Level:quit()
    if self.respawn ~= nil then
        Timer.cancel(self.respawn)
    end
end

function Level:leave()
  self.state = 'idle'
end

function Level:exit(levelName, doorName)
  self.respawn = false
  if self.state ~= 'idle' then
    self.state = 'idle'
    self.transition:backward(function()
      self.events:push('exit', levelName, doorName)
    end)
  end
end

function Level:draw()
    self.tileset:draw(0, 0, 'background')

    if self.player.footprint then
        self:floorspaceNodeDraw()
    else
        for i,node in pairs(self.nodes) do
            if node.draw and not node.foreground and not node.isTrigger then node:draw() end
        end

        self.player:draw()

        for i,node in pairs(self.nodes) do
            if node.draw and (node.foreground or node.isLiquid) and not node.isTrigger then node:draw() end
        end
        for i,node in pairs(self.nodes) do
            if node.draw and node.foreground and node.isLiquid and not node.isTrigger then node:draw() end
        end
        
    end
    
    self.tileset:draw(0, 0, 'foreground')

    if self.scene then
        self.scene:draw(self.player)
    end

    self.player.inventory:draw(self.player.position)
    self.hud:draw( self.player )

    if self.state == 'idle' then
      self.transition:draw(camera.x, camera.y, camera:getWidth(), camera:getHeight())
    end
end

-- draws the nodes based on their location in the y axis
-- this is an accurate representation of the location
-- written by NimbusBP1729, refactored by jhoff
function Level:floorspaceNodeDraw()
    local layers = {}
    local player = self.player
    local fp = player.footprint
    local fp_base = math.floor( fp.y + fp.height )
    local player_drawn = false
    local player_center = player.position.x + player.width / 2

    --iterate through the nodes and place them in layers by their lowest y value
    for _,node in pairs(self.nodes) do
        if node.draw then
            local node_position = node.position and node.position or ( ( node.x and node.y ) and {x=node.x,y=node.y} or ( node.node and {x=node.node.x,y=node.node.y} or false ) )
            assert( node_position, 'Error! Node has to have a position!' )
            assert( node.height and node.width, 'Error! Node must have a height and a width property!' )
            local node_center = node_position.x + ( node.width / 2 )
            local node_depth = ( node.node and node.node.properties and node.node.properties.depth ) and node.node.properties.depth or 0
            local node_direction = ( node.node and node.node.properties and node.node.properties.direction ) and node.node.properties.direction or false
            -- base is, by default, offset by the depth
            local node_base = node_position.y + node.height - node_depth
            -- adjust the base by the players position
            -- if on floor and not behind or in front
            if fp.offset == 0 and node_direction and node_base < fp_base and node_position.y + node.height > fp_base then
                node_base = fp_base - 3
                if ( node_direction == 'left' and player_center < node_center ) or
                   ( node_direction == 'right' and player_center > node_center ) then
                    node_base = fp_base + 3
                end
            end
            -- add the node to the layer
            node_base = math.floor( node_base )
            while #layers < node_base do table.insert( layers, false ) end
            if not layers[ node_base ] then layers[ node_base ] = {} end
            table.insert( layers[ node_base ], node )
         end
    end

    --draw the layers
    for y,nodes in pairs(layers) do
        if nodes then
            for _,node in pairs(nodes) do
                --draw player once his neighbors are found
                if not player_drawn and fp_base <= y then
                    self.player:draw()
                    player_drawn = true
                end
                node:draw()
            end
        end
    end
    if not player_drawn then
        self.player:draw()
    end
end

function Level:leave()
    for i,node in pairs(self.nodes) do
        if node.leave then node:leave() end
        if node.collide_end then
            node:collide_end(self.player)
        end
    end
end

function Level:keyreleased( button )
    self.player:keyreleased( button, self )
end

function Level:keypressed( button )
    if self.state ~= 'active' then
        return
    end

    --i don't know why it makes sense for us to be still to interact...
    if button == 'INTERACT' and not self.player:isIdleState(self.player.character.state) then
        return
    end

    --uses a copy of the nodes to eliminate a concurrency error
    local tmpNodes = self:copyNodes()
    for i,node in pairs(tmpNodes) do
        if node.player_touched and node.keypressed then
            if node:keypressed( button, self.player) then
              return true
            end
        end
    end
   
    if self.player:keypressed( button, self ) then
      return true
    end

    if button == 'START' and not self.player.dead and self.player.health > 0 and not self.player.controlState:is('ignorePause') then
        Gamestate.switch('pause')
        return true
    end
end

function Level:panInit()
    self.pan = 0
    self.pan_delay = 1
    self.pan_distance = 80
    self.pan_speed = 140
    self.pan_hold_up = 0
    self.pan_hold_down = 0
end

function Level:updatePan(dt)
    if self.player.isClimbing then return end
    local up = controls.isDown( 'UP' ) and not self.player.controlState:is('ignoreMovement')
    local down = controls.isDown( 'DOWN' ) and not self.player.controlState:is('ignoreMovement')

    if up and self.player.velocity.x == 0 then
        self.pan_hold_up = self.pan_hold_up + dt
    else
        self.pan_hold_up = 0
    end
    
    if down and self.player.velocity.x == 0 then
        self.pan_hold_down = self.pan_hold_down + dt
    else
        self.pan_hold_down = 0
    end

    if up and self.pan_hold_up >= self.pan_delay then
        self.player.gaze_state = 'gaze'
        self.pan = math.max( self.pan - dt * self.pan_speed, -self.pan_distance )
    elseif down and self.pan_hold_down >= self.pan_delay then
        --we currently have no sprite for looking down
        --self.player.crouch_state = 'gaze'
        self.pan = math.min( self.pan + dt * self.pan_speed, self.pan_distance )
    else
        self.player.gaze_state = self.player:getSpriteStates()[self.player.current_state_set].gaze_state
        if self.pan > 0 then
            self.pan = math.max( self.pan - dt * self.pan_speed, 0 )
        elseif self.pan < 0 then
            self.pan = math.min( self.pan + dt * self.pan_speed, 0 )
        end
    end
end

function Level:addNode(node)
    if node.containerLevel then
        node.containerLevel:removeNode(node)
    end
    node.containerLevel = self
    table.insert(self.nodes, node)
end

function Level:removeNode(node)
    node.containerLevel = nil
    for k,v in pairs(self.nodes) do
        if v == node then
            table.remove(self.nodes,k)
        end
    end
end

function Level:hasNode(node)
    return self.nodes[node] and true or false
end

function Level:copyNodes()
    local tmpNodes = {}
    for i,node in pairs(self.nodes) do
        tmpNodes[i] = node
    end
    return tmpNodes
end
return Level
