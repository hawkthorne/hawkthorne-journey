local overworld = require('overworld')
local Player = require('player')
local ItemClass = require('items/item')

local Cheat = {}

local cheatList ={}

--if turnOn is true the cheat is enabled
-- if turnOn is false the cheat is disabled
local function setCheat(cheatName, turnOn)
    local player = Player.factory() -- Expects existing player object
    local toggles = { -- FORMAT: {player attribute, true value, false value}
        jump_high = {'jumpFactor', 1.44, 1},
        super_speed = {'speedFactor', 2, 1},
        god = {'invulnerable', true, false},
        slide_attack = {'canSlideAttack', true, false},
    }
    local treasures = { -- FORMAT: {page1 = {item1, item2,...}, page2 = {item1, item2,...}}
        give_gcc_key = {keys = {'greendale'}},
        give_taco_meat = {consumables = {'tacomeat'}},
        give_weapons = {weapons = {
            'battleaxe','boneclub','club','longsword',
            'mace','mallet','sword','torch','bow','icicle',
            'throwingaxe','throwingknife','arrow'}},
        give_scrolls = {misc = {'lightning'}},
        give_materials = {materials = {
            'blade','bone','boulder','crystal',
            'ember','fire','leaf','rock','stick','stone'}},
        give_potions = {consumables = {
            'black_potion','blue_potion','green_potion','orange_potion',
            'purple_potion','red_potion','white_potion','yellow_potion'}},
    }
    local activations = {
        give_money = function() player.money = player.money + 500 end,
        max_health = function() player.health = player.max_health end,
        unlock_levels = function()
            player.visitedLevels = {}
            for _,mapInfo in pairs(overworld.zones) do
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
    elseif treasures[cheatName] then
        local cheatItems = treasures[cheatName]
        for page,items in pairs(cheatItems) do
            if page == 'keys' then
                for _,key in ipairs(items) do
                    local itemNode = {type = 'key', name = key}
                    local newItem = ItemClass.new(itemNode)
                    player.inventory:addItem(newItem)
                end
            else
                for _,item in ipairs(items) do
                    local itemNode = require('items/' .. page .. '/' .. item)
                    local count = 1
                    if itemNode.subtype and itemNode.subtype == 'projectile' or itemNode.subtype == 'ammo' then
                        count = 99
                    end
                    local newItem = ItemClass.new(itemNode, count)
                    player.inventory:addItem(newItem)
                end
            end
        end
    elseif activations[cheatName] then
        activations[cheatName]()
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
