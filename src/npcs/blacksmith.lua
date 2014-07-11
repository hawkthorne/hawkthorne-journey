-- includes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'

return {
    width = 63,
    height = 66,
    special_items = {'throwingtorch'},
    run_offsets = {{x=130, y=0}, {x=130, y=36}, {x=0, y=36}},
    run_speed = 100,
    animations = {
        default = {
            'loop',{'1-4,1'},0.20,
        },
        talking = {
            'loop',{'2,3','2,4'},0.20,
        },
        hurt = {
            'loop',{'1-4,5'}, 0.20,
        },
        dying = {
            'once',{'1-3,6','2,6', '1,6'}, 0.15,
        },
        yelling = {
            'loop',{'4, 3', '3, 4'}, 0.20,
        }
    },
    sounds = {
        hammer = {
            state = 'default',
            position = 2,
            file = 'sword_hit',
        }
    },
    donotfacewhentalking = true,
    enter = function(npc, previous)
        if npc.db:get('blacksmith-dead', false) then
            npc.dead = true
            npc.state = 'dying'
            -- Prevent the animation from playing
            npc:animation():pause()
            return
        end
        
        -- Lock the door before the player can leave
        doors = npc.containerLevel:getOutgoingDoors()
        for _,door in pairs(doors) do
            if door.node.name == 'main' then
                npc.props.door = door
            end
        end
        
        if previous and previous.name ~= 'town' then
            return
        end

        Timer.add(1,function()
            -- Blacksmith will be yelling at the player if he is angry
            if not npc.angry and npc.state ~= 'hurt' then
                npc.state = 'talking'
                sound.playSfx("ibuyandsell")
                Timer.add(2.8,function()
                    if not npc.angry and npc.state ~= 'hurt' then
                      npc.state = 'default'
                    end
                end)
            end
        end)

    end,
    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Anything happening here?' },
        { ['text']='Any useful info for me?' },
        { ['text']='Hello!' },
    },
    talk_responses = {
    ["inventory"]={
        "These are my wares.",
    },
    ["Hello!"]={
        "Hello, I am the blacksmith.",
        "You may have met my lovely daughter, Hilda.",
    },
    ["Anything happening here?"]={
        "We used to have a cult leader that claimed to specialize in alchemy stay in the house next door.",
        "What was odd was that he left with nothing and there was no alchemy equipment in the house at all.",
        "We think that he was just lying in an attempt to obtain followers.",
    },
    ["Any useful info for me?"]={
        "You will need some weapons and potions if you are going to survive.",
    },
    },
    inventory = function(npc, player)
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.stack("shopping", player, screenshot, npc.name)
    end,
    
    collide = function(npc, node, dt, mtv_x, mtv_y)
        if npc.state == 'hurt' and node.hurt then
            -- 5 is minimum player damage
            node:hurt(5)
        end
    end,
    
    hurt = function(npc, special_damage, knockback)
        -- Blacksmith reacts when getting hit while dead
        if npc.dead then
            npc:animation():restart()
        end
        
        -- Only accept torches or similar for burning the blacksmith
        if not special_damage or special_damage['fire'] == nil then return end
        
        -- Blacksmith will be yelling if the player stole his torch
        if npc.state == 'yelling' then
            -- Blacksmith is now on fire
            npc.state = 'hurt'
            -- Allow the player to leave the room
            npc.props.door:unlock()
            -- The flames will kill the blacksmith if the player doesn't
            -- Add a bit of randomness so the blacksmith doesn't always fall in the same place
            Timer.add(5 + math.random(), function() npc.props.die(npc) end)
            -- If the player leaves and re-enters, the blacksmith will be dead
            npc.db:set('blacksmith-dead', true)
        elseif npc.state == 'hurt' then
            npc.props.die(npc)
        end
    end,
    
    update = function(dt, npc, player)
        -- Blacksmith running around
        if npc.state == 'hurt' then 
            npc:run(dt, player)
        end
    end,
    
    item_found = function(npc, player)
        if npc.state ~= 'hurt' and npc.state ~= 'yelling' then
            npc.state = 'yelling'
            npc.angry = true
            npc.props.door:lock('Drop the item!')
        end
    end,
    
    die = function(npc)
        npc.dead = true
        npc.state = 'dying'
    end,
}