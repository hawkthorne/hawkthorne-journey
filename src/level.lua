local app = require 'app'

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
local transition = require 'transition'
local HUD = require 'hud'
local utils = require 'utils'
local tracker = require 'tracker'
local music = {}

local Player = require 'player'
local Floorspace = require 'nodes/floorspace'
local Floorspaces = require 'floorspaces'
local Sprite = require 'nodes/sprite'

local save = require 'save'

local function limit( x, min, max )
    return math.min(math.max(x,min),max)
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

function Level.new(name)
    local level = {}
    setmetatable(level, Level)

    level.paused = false
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

    level.node_cache = {}
    level.map = utils.require("maps/" .. name)
    level.map.moving_platforms = {} -- Need to give map access to moving platforms
    level.tileset = tmx.load(level.map)
    level.collider = HC(100, on_collision, collision_stop)
    level.offset = getCameraOffset(level.map)
    level.music = getSoundtrack(level.map)
    level.spawn = (level.map.properties and level.map.properties.respawn) or 'studyroom'
    level.overworldName = (level.map.properties and level.map.properties.overworldName) or 'greendale'
    level.title = getTitle(level.map)
    level.environment = {r=255, g=255, b=255, a=255}
    level.trackPlayer = true
    level.autosave = level.map.properties.autosave or true
 
    level:panInit()

    level.player = Player.factory(level.collider)
    level.boundary = {
        width =level.map.width  * level.map.tilewidth,
        height=level.map.height * level.map.tileheight
    }

    level.transition = transition.new('fade', 0.5)
    level.events = queue.new()
    level.nodes = {}
    level.doors = {}

    if app.config.tracker then
      level.tracker = tracker.new(level.name, level.player)
    end

    level.default_position = {x=0, y=0}

    level:updateLevelState()
    for k,v in pairs(level.map.objectgroups.nodes.objects) do
        local nodePath = 'nodes/' .. v.type

        local ok, NodeClass = level:loadNode(nodePath)

        if ok then 
          local node

          if NodeClass and v.type == 'scenetrigger' then
              v.objectlayer = 'nodes'
              local layer = level.map.objectgroups[v.properties.cutscene]
              node = NodeClass( v, level.collider, layer, level )
              node.drawHeight = v.height
              level:addNode(node)
          elseif NodeClass then
              v.objectlayer = 'nodes'
              node = NodeClass.new(v, level.collider, level)
              node.drawHeight = v.height
              level:addNode(node)
          end

          if v.type == 'door' or v.type == 'savepoint' then
              if v.name then
                  if v.name == 'main' then
                      level.default_position = {x=v.x, y=v.y}
                  end
                  
                  level.doors[v.name] = {x=v.x, y=v.y, node=node}
              end
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

    level.player = player
    return level
end

-- Return the node from the filesystem
function Level:loadNode(path)
  if self.node_cache[path] then
    return true, self.node_cache[path]
  end

  local ok, class = pcall(utils.require, path)

  if not ok then 
    print("WARNING: Can't load " .. path)
  end

  self.node_cache[path] = class

  return true, class
end

function Level:restartLevel(keepPosition)
    assert(self.name ~= "overworld","level's name cannot be overworld")
    assert(Gamestate.currentState().name ~= "overworld","level cannot be overworld")
    self.over = false

    self.player = Player.factory(self.collider)
    self.player:refreshPlayer(self.collider)
    self.player.boundary = {
        width = self.map.width * self.map.tilewidth,
        height = self.map.height * self.map.tileheight
    }
    
    if not keepPosition then
      self.player.position = {x = self.default_position.x, y = self.default_position.y}
    end

    Floorspaces:init()
end

---
-- Save the removed node into the level state
function Level:saveRemovedNode(node)
    local gamesave = app.gamesaves:active()
    local default_nodes = utils.require("maps/" .. self.name)

    -- Check to see if node is default (present in tmx) and not set to persistent
    local isDefaultNode = false
    local isPersistent = false
    for k,v in pairs(default_nodes.objectgroups.nodes.objects) do
        if v.type == node.type and v.name == node.name and v.x == node.position.x and v.y == node.position.y then
            isDefaultNode = true
            if v.properties.persistent == 'true' then
                isPersistent = true
            end
        end
    end

    if isDefaultNode and not isPersistent then
        -- Add it to the removed level table so it doesn't load anymore
        table.insert(self.removed_nodes, {
                            name = node.name,
                            type = node.type,
                            x = node.position.x,
                            y = node.position.y
                        })
    elseif not isPersistent then
        -- Remove it from the added level table
        for k,v in pairs(self.added_nodes) do
            if v.type == node.type and v.name == node.name and v.x == node.position.x and v.y == node.position.y then
                table.remove(self.added_nodes, k)
            end
        end
    end
end

---
-- Save the added node into the level state
function Level:saveAddedNode(node)
    local gamesave = app.gamesaves:active()

    -- Add it to the added level table
    table.insert(self.added_nodes, {
                        name = node.name,
                        type = node.type,
                        directory = node.directory,
                        x = node.position.x,
                        y = node.position.y,
                        width = node.width,
                        height = node.height,
                        properties = {}
                    })
end

---
-- Update item nodes that have been picked up or dropped in the level
function Level:updateLevelState()
    local gamesave = app.gamesaves:active()
    self.added_nodes = gamesave:get(self.name .. '_added', {})
    self.removed_nodes = gamesave:get(self.name .. '_removed', {})

    -- Remove all nodes that have been removed in this save
    for k,v in pairs(self.removed_nodes) do
        for kk,vv in pairs(self.map.objectgroups.nodes.objects) do
            if v.type == vv.type and v.name == vv.name and v.x == vv.x and v.y == vv.y then
                table.remove(self.map.objectgroups.nodes.objects, kk)
            end
        end
    end

    -- Add all nodes that have been added in this save
    for k,v in pairs(self.added_nodes) do
        table.insert(self.map.objectgroups.nodes.objects, v)
    end
end

function Level:enter(previous, door, position)
    self.paused = false
    self.respawn = false
    self.state = 'idle'
    self.leaving = false

    self.transition:forward(function()
        self.state = 'active'
    end)

    --only restart if it's an ordinary level
    if previous.isLevel or previous.name=='overworld'
                        or previous.name=='splash'
                        or previous.name=='start' then
        self.previous = previous
        self:restartLevel()
    end
    if previous.name == 'overworld'
                   or previous.name=='splash'
                   or previous.name=='start' then
        self.respawn = true
        self.player.character:respawn()
    end
    if not self.player then
        self:restartLevel()
    end
    
    if previous.name=='costumeselect' then
      self:restartLevel(true)
    end

    camera.max.x = self.map.width * self.map.tilewidth - window.width

    setBackgroundColor(self.map)
 
    sound.playMusic( self.music )

    self.hud = HUD.new(self)

    if door and self.doors[door] then
        self.player.position = {
            x = self.doors[ door ].x + self.doors[ door ].node.width / 2 - self.player.character.bbox.width / 2,
            y = self.doors[ door ].y + self.doors[ door ].node.height - self.player.character.bbox.height
        }
        if self.doors[ door ].warpin then
            self.player:respawn()
        end
        if self.doors[ door ].node then
            -- passing previous will allow the door to check the level against its own
            self.doors[ door ].node:show(previous)
            self.player.freeze = false
        end
    end
    
    if position then
        local p = utils.split(position, ",")
        self.player.position = {
            x = p[1] * self.map.tilewidth,
            y = p[2] * self.map.tileheight
        }
    end

    self:moveCamera()
    self.player:moveBoundingBox()

    found = false
    for _,level in ipairs(self.player.visitedLevels) do
        if level == self.name then
            found = true
        end
    end
    if not found then self.player.visitedLevels[#self.player.visitedLevels+1] = self.name end

    for i,node in pairs(self.nodes) do
        if node.enter then node:enter(previous) end
    end

    self.player:setSpriteStates(self.player.current_state_set or 'default')

    if previous.isLevel and self.autosave == true then
        -- Save the item changes from previous level
        local gamesave = app.gamesaves:active()
        gamesave:set(previous.name .. '_added', previous.added_nodes)
        gamesave:set(previous.name .. '_removed', previous.removed_nodes)

        save:saveGame(self, door)
    end
end

function Level:init()
end

local function leaveLevel(level, levelName, doorName)
  if level.name == levelName then
    level.player.position = { -- Copy, or player position corrupts entrance data
      x = level.doors[doorName].x + level.doors[doorName].node.width / 2 - level.player.character.bbox.width / 2,
      y = level.doors[doorName].y + level.doors[doorName].node.height - level.player.character.bbox.height
    }
    return
  end

  Gamestate.switch(levelName, doorName)
end

function Level:update(dt)
    if self.tracker then
      self.tracker:update(dt)
    end

    if self.state == 'idle' then
        self.transition:update(dt)
    end

    if self.state == 'active' or self.respawn == true then
        self.player:update(dt, self.map)
    end

    if self.hud then
        self.hud:update(dt)
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
        local gamesave = app.gamesaves:active()
        if app.config.hardcore then
            self.player.inventory:dropAllItems()
        end
        self.player:saveData( gamesave )
        self.over = true
        self.respawn = Timer.add(3, function()
            self.player:resetEffects()
            self.player.character:reset()
            local point = gamesave:get('savepoint', {level='studyroom', name='bookshelf'})
            if app.config.hardcore then
              point = {level = 'studyroom', name = 'bookshelf'}
              self.player.money = 0
            end
            Gamestate.switch(point.level, point.name)
        end)
    end

    for i,node in pairs(self.nodes) do
        if self.state == 'active' and node.update then
            node:update(dt, self.player, self.map)
        end
    end
    
    --Prevent further processing as values have been niled.
    if self.leaving then return end

    self.collider:update(dt)

    self:updatePan(dt)
    self:moveCamera()

    local exited, levelName, doorName = self.events:poll('exit')
    if exited then
      leaveLevel(self, levelName, doorName)
    end
end

function Level:cameraPosition()
    local x = self.player.position.x + self.player.character.bbox.width / 2
    local y = self.player.position.y - self.map.tilewidth * 4.5
    return math.max(x - window.width / 2, 0),
      limit( limit(y, 0, self.offset) + self.pan, 0, self.offset )
end


function Level:moveCamera()
    if not self.trackPlayer then return end
    local x = self.player.position.x + self.player.character.bbox.width / 2
    local y = self.player.position.y - self.map.tilewidth * 4.5
    camera:setPosition( math.max(x - window.width / 2, 0),
                        limit( limit(y, 0, self.offset) + self.pan, 0, self.offset ) )
end

function Level:quit()
    if self.respawn ~= nil then
        Timer.cancel(self.respawn)
    end
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
            if node.draw and node.isBuilding then node:draw() end
        end

        for i,node in pairs(self.nodes) do
            if node.draw and node.isFire then node:draw() end
        end

        for i,node in pairs(self.nodes) do
            if node.draw and not node.foreground and not node.isTrigger and not node.isBuilding and not node.isFire then node:draw() end
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
            local node_base = node_position.y + (node.drawHeight or node.height) - node_depth
            -- adjust the base by the players position
            -- if on floor and not behind or in front
            if fp.offset == 0 and node_direction and node_base < fp_base and node_position.y + (node.drawHeight or node.height) > fp_base then
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
                -- weapon:draw() is managed in player.lua while the player is holding it
                if not (node.isWeapon and node.player) then
                    node:draw()
                end
            end
        end
    end
    if not player_drawn then
        self.player:draw()
    end
end

-- Called by Gamestate.switch when changing levels
function Level:leave()
  self.leaving = true
  for i,node in pairs(self.nodes) do
    if node.leave then node:leave() end
    if node.collide_end then
      node:collide_end(self.player)
    end
  end

  if self.tracker then
    self.tracker:flush()
  end

  self.previous = nil

  if not self.paused and self.name ~= 'new-abedtown' then
    self.tracker = nil
    self.player = nil
    self.map = nil
    self.tileset = nil
    self.collider = nil
    self.offset = nil
    self.music = nil
    self.spawn = nil 
    self.overworldName = nil
    self.title = nil
    self.environment = nil
    self.boundary = nil
    self.transition = nil
    self.events = nil
    self.nodes = {}
    self.doors = {}
  end
end

function Level:keyreleased( button )
    self.player:keyreleased( button, self )
end

function Level:keypressed( button )
    if self.state ~= 'active' then
        return true
    end

    if self.player.inventory.visible then
        self.player.inventory:keypressed( button )
        return true
    end

    -- First see if there are any holdables that can be picked up
    if button == 'INTERACT' and self.player:tryPickup() then
        -- The player was able to pick up an item
        return true
    end

    -- Uses a copy of the nodes to eliminate a concurrency error
    local tmpNodes = self:copyNodes()
    -- Next, look for any items that can be picked up
    for i,node in pairs(tmpNodes) do
        if not node.isInteractive and node.player_touched and node.keypressed then
            if node:keypressed( button, self.player) then
              return true
            end
        end
    end
    -- Then look for any interactive nodes that may be at the same location
    for i,node in pairs(tmpNodes) do
        if node.isInteractive and node.player_touched and node.keypressed then
            if node:keypressed( button, self.player) then
              return true
            end
        end
    end

    if self.player:keypressed( button, self ) then
      return true
    end

    if button == 'START' and not self.player.dead and self.player.health > 0 and not self.player.controlState:is('ignorePause') then
      Gamestate.stack('pause', self.player)
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
    local controls = self.player.controls

    if self.player.isClimbing or self.player.footprint then return end
    local up = controls:isDown( 'UP' ) and not self.player.controlState:is('ignoreMovement')
    local down = controls:isDown( 'DOWN' ) and not self.player.controlState:is('ignoreMovement')

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
    -- FIXME: This seems like a very bad idea
    if node.containerLevel and node.containerLevel.collider then
        node.containerLevel.collider:remove(node.bb)
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
            if v.collider then
                v.collider:remove(v.bb)
            end
        end
    end
end

function Level:hasNode(node)
    return utils.contains(self.nodes,node)
end

function Level:copyNodes()
    local tmpNodes = {}
    for i,node in pairs(self.nodes) do
        tmpNodes[i] = node
    end
    return tmpNodes
end

---
-- Gets outgoing doors (i.e. which point to non-nil levels)
-- @return array of outgoing doors
function Level:getOutgoingDoors()
  local doors = {}

  -- process all nodes; self.doors doesn't contain all doors, it contains only named doors (i.e. incoming)
  for _,door in pairs(self.nodes) do
    if door.isDoor and door.level ~= nil then
      table.insert(doors, door)
    end
  end

  return doors
end

---
-- Returns an user-friendly identifier
-- @return string describing this level in a user-friendly (and hopefully unique) way
function Level:getSourceId()
  return string.format("level %s", self.name)
end

return Level
