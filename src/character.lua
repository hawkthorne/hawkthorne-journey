local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

local characters = {}

for i,p in pairs( love.filesystem.enumerate( 'characters' ) ) do
    -- bring in the data from the character file
    local character = require( 'characters/' .. p:gsub('.lua', '') )

    -- build the character
    character.beam = love.graphics.newImage( 'images/characters/' .. character.name .. '/beam.png')
    character.beam:setFilter('nearest', 'nearest')
    
    character.count = 1

    character.sheets = {}
    character.sheets.base = love.graphics.newImage( 'images/characters/' .. character.name .. '/base.png')
    character.sheets.base:setFilter('nearest', 'nearest')

    character.mask = love.graphics.newQuad(0, character.offset, 48, 35, character.sheets.base:getWidth(), character.sheets.base:getHeight())

    character.positions = require( 'positions/' .. character.name )

    character._grid = anim8.newGrid( 48, 48, character.sheets.base:getWidth(), character.sheets.base:getHeight() )
    character._warp = anim8.newGrid( 36, 300, character.beam:getWidth(), character.beam:getHeight() )

    for state, _ in pairs( character.animations ) do
        local data = character.animations[ state ]
        if state == 'warp' then
            character.animations[ state ] = anim8.newAnimation(data[1], character._warp(unpack(data[2])), data[3])
        else
            if type( data[1] ) == 'string' then
                -- positionless
                character.animations[ state ] = anim8.newAnimation(data[1], character._grid(unpack(data[2])), data[3])
            else
                -- positioned
                for i, _ in pairs( data ) do
                    character.animations[ state ][i] = anim8.newAnimation(data[i][1], character._grid(unpack(data[i][2])), data[i][3])
                end
            end
        end
    end

    characters[ character.name ] = character
end

local Character = {}
Character.__index = Character
Character.characters = characters

Character.name = 'abed'
Character.costume = 'base'

Character.warpin = false

function Character:reset()
    self.state = 'idle'
    self.direction = 'right'
end

function Character:setCharacter( name )
    if character == self.name then return end

    if self.characters[name] then
        self.name = name
        self.costume = 'base'
        return
    end

    error( "Invalid character ( " .. name .. " ) requested!" )
end

function Character:setCostume( costume )
    if costume == self.costume then return end
    
    for _,c in pairs( self:current().costumes ) do
        if c.sheet == costume then
            self.costume = costume
            if not self:sheet() then
                self:current().sheets[self.costume] = love.graphics.newImage( 'images/characters/' .. self.name .. '/' .. self.costume .. '.png')
                self:current().sheets[self.costume]:setFilter('nearest', 'nearest')
            end
            return
        end
    end
    
    error( "Undefined costume ( " .. costume .. " ) requested for character ( " .. self.name .. " )" )
end

function Character:current()
    return self.characters[self.name]
end

function Character:sheet()
    return self:current().sheets[self.costume]
end

function Character:updateAnimation(dt)
    self:animation():update(dt)
end

function Character:animation()
    return self.characters[self.name].animations[self.state][self.direction]
end

function Character:warpUpdate(dt)
    self:current().animations.warp:update(dt)
end

function Character:respawn()
    self.warpin = true
    self:current().animations.warp:gotoFrame(1)
    self:current().animations.warp:resume()
    sound.playSfx( "respawn" )
    Timer.add(0.30, function() self.warpin = false end)
end

function Character:draw()
end

Character:reset()

return Character