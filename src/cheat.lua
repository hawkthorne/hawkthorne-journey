local Cheat = {}

local cheatList ={}

--if turnOn is true the cheat is enabled
-- if turnOn is false the cheat is disabled
local function setCheat(cheatName, turnOn)
    local Player = require 'player'
    if cheatName=="jump_high" then
        cheatList[cheatName] = turnOn
        Player.jumpFactor = cheatList[cheatName] and 1.44 or 1
    elseif cheatName=="super_speed" then
        cheatList[cheatName] = turnOn
        Player.speedFactor = cheatList[cheatName] and 2 or 1
    elseif cheatName=="god" then
        cheatList[cheatName] = turnOn
    elseif cheatName=="slide_attack" then
        cheatList[cheatName] = turnOn
        local player = Player.factory()
        player.canSlideAttack = cheatList[cheatName] and true or false
    elseif cheatName=="give_money" then
        local player = Player.factory()
        player.money = player.money + 100
    elseif cheatName=="max_health" then
        local player = Player.factory()
        player.health = player.max_health
    elseif cheatName=="give_gcc_key" then
        local player = Player.factory()
        local ItemClass = require('items/item')
        local itemNode = {type = 'key',name = 'greendale'}
        local item = ItemClass.new(itemNode)
        player.inventory:addItem(item)
    elseif cheatName== "give_taco_meat" then
        local player = Player.factory()
        local ItemClass = require('items/item')
        local itemNode = require('items/consumables/tacomeat')
        local item = ItemClass.new(itemNode)
        player.inventory:addItem(item)
    elseif cheatName=="give_weapons" then
        local player = Player.factory()
        local ItemClass = require('items/item')
        local mweapons = {'battleaxe','boneclub','club','longsword','mace','mallet','sword','torch'}
        for k,weapon in ipairs(mweapons) do
            local itemNode = require ('items/weapons/' .. weapon)
            local item = ItemClass.new(itemNode)
            player.inventory:addItem(item)
        end
        local pweapons = {'icicle','throwingaxe','throwingknife'}
        for k,weapon in ipairs(pweapons) do
            local itemNode = require ('items/weapons/' .. weapon)
            itemNode['quantity'] = 99
            local item = ItemClass.new(itemNode)
            player.inventory:addItem(item)
        end
    elseif cheatName=="give_materials" then
        for i=1,3 do
            local player = Player.factory()
            local ItemClass = require('items/item')
            local materials = {'blade','bone','boulder','crystal','ember','fire','leaf','rock','stick','stone'}
            for k,material in ipairs(materials) do
                local itemNode = require ('items/materials/' .. material)
                itemNode['quantity'] = 1 --itemNode['MAX_ITEMS'] - 1
                local item = ItemClass.new(itemNode)
                player.inventory:addItem(item)
            end
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
