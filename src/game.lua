local anim8 = require 'vendor/anim8'
local atl = require 'vendor/AdvTiledLoader'
local HC = require 'vendor/hardoncollider'
local camera = require 'camera'
local game = {}

-- taken from sonic physics http://info.sonicretro.org/SPG:Running
game.friction = 0.046875
game.accel = 0.046875
game.deccel = 0.5
game.gravity = 0.21875
game.airaccel = 0.09375
game.airdrag = 0.96875
game.max_x = 6
game.max_y= 6
game.step = 300
game.over = false

atl.Loader.path = 'maps/'
atl.Loader.useSpriteBatch = true

Enemy = {}
Enemy.__index = Enemy

function Enemy.create(sheet_path)
    local sheet = love.graphics.newImage(sheet_path)
    local enem = {}
    local g = anim8.newGrid(46, 46, sheet:getWidth(), sheet:getHeight())

    setmetatable(enem, Enemy)
    enem.width = 48
    enem.height = 48
    enem.sheet = sheet
    enem.position = {x=love.graphics.getWidth() - 23, y=300}
    enem.state = 'attack'         -- default animation is idle
    enem.direction = 'left'    -- default animation faces right direction is right
    enem.animations = {
        crawl = {
            right = anim8.newAnimation('loop', g('3-4,2'), 0.25),
            left = anim8.newAnimation('loop', g('3-4,1'), 0.25)
        },
        attack = {
            right = anim8.newAnimation('loop', g('1-2,2'), 0.25),
            left = anim8.newAnimation('loop', g('1-2,1'), 0.25)
        }
    }
    return enem
end


function Enemy:animation()
    return self.animations[self.state][self.direction]
end

function Enemy:update(dt)
    if self.position.x > player.position.x then
        self.direction = 'left'
    else
        self.direction = 'right'
    end

    if math.abs(self.position.x - player.position.x) < player.width * 2 then
        self.state = 'attack'
    else
        self.state = 'crawl'
    end

    if self.state == 'crawl' then
        if self.direction == 'left' then
            self.position.x = self.position.x - .5 
        else
            self.position.x = self.position.x + .5 
        end
    end

    self:animation():update(dt)
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + self.height / 2)
end

function Enemy:draw()
    self:animation():draw(self.sheet, self.position.x, self.position.y) 
end

Player = {}
Player.__index = Player

function Player.create(sheet_path)
    local sheet = love.graphics.newImage(sheet_path)
    local plyr = {}
    local g = anim8.newGrid(46, 46, sheet:getWidth(), sheet:getHeight())

    setmetatable(plyr, Player)
    plyr.jumping = false
    plyr.width = 48
    plyr.height = 48
    plyr.sheet = sheet
    plyr.actions = {}
    plyr.position = {x=love.graphics.getWidth() / 2 - 23, y=300}
    plyr.velocity = {x=0, y=0}
    plyr.state = 'idle'         -- default animation is idle
    plyr.direction = 'right'    -- default animation faces right direction is right
    plyr.animations = {
        jump = {
            right = anim8.newAnimation('once', g('7,2'), 1),
            left = anim8.newAnimation('once', g('7,1'), 1)
        },
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2', '3,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1', '3,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        }
    }
    return plyr
end


function Player:animation()
    return self.animations[self.state][self.direction]
end

function game.round(value)
    if value <= 0 then
        return math.floor(value)
    else
        return math.ceil(value)
    end
end

function math.sign(x)
    if x == math.abs(x) then
        return 1
    else
        return -1
    end
end

function Player:accel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.accel
    end
end

function Player:deccel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.deccel
    end
end


function Player:update(dt)
    local step = dt * game.step
    
    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if love.keyboard.isDown('left') then

        if self.velocity.x > 0 then
            self.velocity.x = self.velocity.x - (self:deccel() * step)
        elseif self.velocity.x > -game.max_x then
            self.velocity.x = self.velocity.x - (self:accel() * step)
            if self.velocity.x < -game.max_x then
                self.velocity.x = -game.max_x
            end
        end

    elseif love.keyboard.isDown('right') then

        if self.velocity.x < 0 then
            self.velocity.x = self.velocity.x + (self:deccel() * step)
        elseif self.velocity.x < game.max_x then
            self.velocity.x = self.velocity.x + (self:accel() * step)
            if self.velocity.x > game.max_x then
                self.velocity.x = game.max_x
            end
        end

    else

        if self.velocity.y < 0 and self.velocity.y > -4 then
            if math.abs(self.velocity.x) >= 0.125 then
                self.velocity.x = self.velocity.x * game.airdrag
            end
        else
            local min = math.min(math.abs(self.velocity.x), game.friction * step)
            self.velocity.x = self.velocity.x - min * math.sign(self.velocity.x)
        end

    end

    self.velocity.y = self.velocity.y + game.gravity -- step
    if self.velocity.y > game.max_y then
        self.velocity.y = game.max_y
    end
    -- end sonic physics
    
    self.position.x = game.round(self.position.x + self.velocity.x)
    self.position.y = math.min(game.round(self.position.y + self.velocity.y), 300)

    if self.position.y == 300 then
        self.jumping = false
    end

    -- These calculations shouldn't need to be offset, investigate
    if self.position.x < -player.width / 4 then
        self.position.x = -player.width / 4
    elseif self.position.x > map.width * map.tileWidth - player.width * 3 / 4 then
        self.position.x = map.width * map.tileWidth - player.width * 3 / 4
    end

    action = nil
    
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + self.height / 2)


    if self.velocity.x < 0 then
        self.direction = 'left'
    elseif self.velocity.x > 0 then
        self.direction = 'right'
    end

    if self.velocity.y < 0 then

        self.state = 'jump'

    elseif self.state == 'jump' and not self.jumping then

        self.state = 'walk'

    elseif self.state == 'idle' and self.velocity.x ~= 0 then

        self.state = 'walk'
        self:animation():gotoFrame(1)

    elseif self.state == 'walk' and self.velocity.x == 0 then

        self.state = 'idle'
        self:animation():update(dt)
    else

        self:animation():update(dt)

    end
end

function Player:draw()
    self:animation():draw(self.sheet, self.position.x, self.position.y) 
end

function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    if shape_a.parent == enemy then
        shape_a.parent.state = 'crawl'
        Collider:remove(shape_a)
    end

    if shape_b.parent == enemy then
        shape_b.parent.state = 'crawl'
        Collider:remove(shape_b)
    end

    if shape_a.parent == player then
        player.jumping = false
        player.position.x = player.position.x + math.floor(mtv_x)
        player.position.y = player.position.y + math.floor(mtv_y)
    end

    if shape_b.parent == player then
        player.jumping = false
        player.position.x = player.position.x + math.floor(mtv_x)
        player.position.y = player.position.y + math.floor(mtv_y)
    end
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
end


function game.load()
    love.audio.stop()
    bg = love.graphics.newImage("images/studyroom_scaled.png")
    endscreen = love.graphics.newImage("images/enddemo.png")

    player = Player.create("images/abed_sheet.png")
    enemy = Enemy.create("images/hippy.png")

    map = atl.Loader.load("hallway.tmx")

    music = love.audio.newSource("audio/level.ogg")
    music:setLooping(true)
    love.audio.play(music)

    Collider = HC(100, on_collision, collision_stop)

    for _, o in pairs(map.objectLayers.solid.objects) do
        rect = Collider:addRectangle(o.x, o.y, o.width * map.tileWidth, 
                                     o.height * map.tileHeight)
    end

    camera.max.x = map.width * map.tileWidth - love.graphics:getWidth()

    -- playe bounding box
    player.bb = Collider:addRectangle(0,0,18,42)
    player.bb.parent = player

    enemy.bb = Collider:addRectangle(0,0,38,38)
    enemy.bb.parent = enemy

end

function game.update(dt)
    player:update(dt)
    enemy:update(dt)
    Collider:update(dt)
    local x = math.max(player.position.x - love.graphics:getWidth() / 2, 0)
    camera:setPosition(x, 0)

    if (map.width * map.tileWidth - player.position.x) < player.width then
        game.over = true
    end
end


function game.draw()
    if game.over then 
        love.graphics.draw(endscreen)
        return
    end

    camera:set()

    map:autoDrawRange(math.floor(camera.x * -1), math.floor(camera.y), 1, 0)
    map:draw()
    player:draw()

    enemy:draw()

    camera:unset()
end


function game.keyreleased(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' then
        if player.velocity.y < 0 and player.velocity.y < -4 then
            player.velocity.y = -4
        end
    end
end

function game.keypressed(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' then
        if player.state ~= 'jump' then
            player.jumping = true
            player.velocity.y = -6.5
        end
    end
end


return game
