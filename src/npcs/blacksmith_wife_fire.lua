-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'

return {
    width = 48,
    height = 48,  
    special_items = {'throwingtorch'},
    run_offsets = {{x=5, y=50},{x=-5, y=120},{x=100, y=120},{x=-40, y=120}},
    animations = {
        default = {
            'loop',{'1,1','2,1'},.5,
        },
        hurt = {
            'loop',{'1-4, 2'}, 0.20,
        },
        dying = {
            'once',{'3-4,1'}, 0.15,
        },
        yelling = {
            'loop',{'1-4, 3'}, 0.20,
        }
    },

    noinventory = "Talk to my husband to about supplies.",
    enter = function(npc, previous)
        if npc.db:get('blacksmith_wife-dead', false) then
            npc.dead = true
            npc.state = 'dying'
            -- Prevent the animation from playing
            npc:animation():pause()
            return
        end
        
        if previous and previous.name ~= 'town' then
            return
        end

    end,

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='Anything happening here?' },
        { ['text']='Hello!' },
    },
    talk_responses = {
    ["Hello!"]={
        "Hello, I am the blacksmith's wife.",
        "You may have met my lovely daughter, Hilda.",
    },
    
    ["Anything happening here?"]={
        "I've been trying to convince my husband to build us a new home.  I keep telling him it's a terrible idea to have his workshop inside a wooden house!",
    },
    ["Any useful info for me?"]={
        "My husband is the best blacksmith around.  He can help you stock up on supplies before venturing into the woods.",
    },
    },
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
            -- The flames will kill the blacksmith if the player doesn't
            -- Add a bit of randomness so the blacksmith doesn't always fall in the same place
            Timer.add(5 + math.random(), function() npc.props.die(npc) end)
            -- If the player leaves and re-enters, the blacksmith will be dead
            npc.db:set('blacksmith_wife-dead', true)
        elseif npc.state == 'hurt' then
            npc.props.die(npc)
        end
    end,
    update = function(dt, npc, player)
        if npc.db:get('blacksmith-dead', false) then
        -- Blacksmith running around
        npc.props.fire(npc)
            npc:run(dt, player)
        end
    end,
    item_found = function(npc, player)
        if npc.state ~= 'hurt' then
            npc.state = 'yelling'
            npc.angry = true
        end
    end,
    die = function(npc)
        npc.dead = true
        npc.state = 'dying'
    end,
    fire = function(npc)
        npc.state = 'yelling' 
        -- Blacksmith will be yelling if the player stole his torch
        if npc.state == 'yelling' then
            -- Blacksmith is now on fire
            npc.state = 'hurt'
            -- The flames will kill the blacksmith if the player doesn't
            -- Add a bit of randomness so the blacksmith doesn't always fall in the same place
            Timer.add(5 + math.random(), function() npc.props.die(npc) end)
            -- If the player leaves and re-enters, the blacksmith will be dead
            npc.db:set('blacksmith_wife-dead', true)
        elseif npc.state == 'hurt' then
            npc.props.die(npc)
        end
    end,
}