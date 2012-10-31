local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'

local BurnGrid = {}

BurnGrid.__index = BurnGrid

local burnBoxes = {}
local sprite_cache = {}


function BurnGrid:load_fire()
    local name = 'images/fire2.png'
    if sprite_cache[name] then
        return sprite_cache[name]
    end

    local image = love.graphics.newImage(name)
    image:setFilter('nearest', 'nearest')
    sprite_cache[name] = image
    return image
end


function BurnGrid.new(node, collider)
    local burnGrid = {}
    local p = node.properties
    setmetatable(burnGrid, BurnGrid)

    burnGrid.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    burnGrid.bb.node = burnGrid
    burnGrid.collider = collider
    burnGrid.collider:setActive(burnGrid.bb)
    
    burnGrid.setAflame = false
    
    burnGrid.x = node.x
    burnGrid.y = node.y
    burnGrid.width = node.width
    --critical for 2d floorspaces
    burnGrid.height = node.height
    
    burnGrid.flameCount = 5
    
    return burnGrid
end

function BurnGrid:draw()
    self.burnt = true
    for k,v in pairs(burnBoxes) do
        if not v.burnt then self.burnt = false end
        local animation = v:animation()
        animation:draw(self.sheet, math.floor(self.x), self.y)
    end
end


function BurnGrid:update(dt)
    if self.burnt then return end
    for k,v in pairs(burnBoxes) do
        if not v.burnt then self.burnt = false end
        
        --temporary, i update too often
        if v.burnt then
            local h = anim8.newGrid(25,26,225,26)
            v.animation = anim8.newAnimation('once', h('9,1'), 1)
        end
        
        v.animation:update(dt)
    end
end

--we start the fire.. but only once per BurnGrid
function BurnGrid:burn(x,y)
    if self.setAflame == true then
        return
    else
        self.setAflame = true
    end

    local curX = x
    local curY = y
    local flameSpreadDuration = 4
    local keepFlaming = true

    Timer.add(2, 
        function() 
            curX,curY = self:spawnFlame(curX,curY)
        end
    )
end

function BurnGrid:spawnFlame(curX,curY)
    --clip location
    if curX<=self.x then curX = self.x-5 end
    if curX>=self.x + self.width then curX = self.width + self.x +5 end
    if curY<=self.y then curY = self.y -5 end
    if curY>=self.y + self.height then curY = self.height + self.y + 5 end

    local burnBox = {}
    burnBox.sheet = self:load_fire()
    local h = anim8.newGrid(25,26,225,26)
    burnBox.animation = anim8.newAnimation('loop', h('1-8,1'), 0.09)
    burnBox.x = curX
    burnBox.y = curY
    table.insert(burnBoxes,burnBox)

    Timer.add(4+math.random()*4, 
        function() 
            burnBox.burnt = true
        end
    )

    local stepSize = 60
    curX = curX + (stepSize* math.random() - stepSize/2)
    curY = curY + (stepSize* math.random() - stepSize/2)
    if self.flameCount <=0 then
        return curX,curY
    else
        self.flameCount = self.flameCount - 1
        Timer.add(2, 
            function() 
                curX,curY = self:spawnFlame(curX,curY)
                return curX,curY
            end
        )
    end

end

function BurnGrid:draw()
    for k,v in pairs(burnBoxes) do
        if not v.burnt then self.burnt = false end
        local animation = v.animation
        animation:draw(v.sheet, math.floor(v.x), v.y)
    end
end


return BurnGrid
