local Cheat = {}

local cheatList ={}

--if turnOn is true the cheat is enabled
-- if turnOn is false the cheat is disabled
local function setCheat(cheatName, turnOn)
    local Player = require 'player'
    local player = Player.factory() -- Expects existing player object
    local toggles = { -- FORMAT: {player attribute, true value, false value}
        jump_high = {'jumpFactor', 1.44, 1},
        super_speed = {'speedFactor', 2, 1},
        god = {},
        slide_attack = {'canSlideAttack', true, false},
        give_money = {'money', player.money + 500, player.money + 500},
        max_health = {'health', player.max_health, player.max_health}
    }
    local others = {
        unlock_levels = function()
            local zones = require('overworld').zones
            player.visitedLevels = {}
            for _,mapInfo in pairs(zones) do
                table.insert(player.visitedLevels, mapInfo.level)
            end
        end
    }
    if toggles[cheatName] then
        local cheat = toggles[cheatName]
        cheatList[cheatName] = turnOn
        if cheat[1] then
            player[cheat[1]] = cheatList[cheatName] and cheat[2] or cheat[3]
        end
    elseif others[cheatName] then
        others[cheatName]()
    elseif cheatName=="give_gcc_key" then
        local ItemClass = require('items/item')
        local itemNode = {type = 'key',name = 'greendale'}
        local item = ItemClass.new(itemNode)
        player.inventory:addItem(item)
    elseif cheatName== "give_taco_meat" then
        local ItemClass = require('items/item')
        local itemNode = require('items/consumables/tacomeat')
        local item = ItemClass.new(itemNode)
        player.inventory:addItem(item)
    elseif cheatName=="give_weapons" then
        local ItemClass = require('items/item')
        local sweapons = {'battleaxe','boneclub','club','longsword','mace','mallet','sword','torch','bow'}
        for k,weapon in ipairs(sweapons) do
            local itemNode = require ('items/weapons/' .. weapon)
            local item = ItemClass.new(itemNode)
            player.inventory:addItem(item)
        end
        local mweapons = {'icicle','throwingaxe','throwingknife','arrow'}
        for k,weapon in ipairs(mweapons) do
            local itemNode = require ('items/weapons/' .. weapon)
            itemNode.quantity = 99
            local item = ItemClass.new(itemNode)
            player.inventory:addItem(item)
        end
    elseif cheatName=="give_materials" then
        local ItemClass = require('items/item')
        local materials = {'blade','bone','boulder','crystal','ember','fire','leaf','rock','stick','stone'}
        for k,material in ipairs(materials) do
            local itemNode = require ('items/materials/' .. material)
            itemNode['quantity'] = itemNode['MAX_ITEMS']
            local item = ItemClass.new(itemNode)
            player.inventory:addItem(item)
        end
    elseif cheatName == "give_misc" then
        local ItemClass = require('items/item')
        local miscItems = love.filesystem.enumerate('items/misc/')
        for k, misc in ipairs(miscItems) do
            local itemNode = require ('items/misc/' .. misc:gsub('.lua', ''))
            if itemNode.subtype and (itemNode.subtype == 'projectile' or itemNode.subtype == 'ammo') then
                itemNode.quantity = 99
            end
            local item = ItemClass.new(itemNode)
            player.inventory:addItem(item)
        end
    end
end

function Cheat:is(cheatName)
    return cheatList[cheatName] and true or false
end

function Cheat:on(cheatName)
    setCheat(cheatName,true)
end

function Cheat:off(cheatName)
    setCheat(cheatName,false)
end

function Cheat:toggle(cheatName)
    setCheat(cheatName,not cheatList[cheatName])
end

return Cheat
