-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Emotion = require 'nodes/emotion'

return {
    width = 48,
    height = 48,  
    special_items = {'throwingtorch'},
    run_offsets = {{x=0, y=0}, {x=190, y=0}},
    run_speed = 100,
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
        exclaim = {
            'loop',{'1-4, 3'}, 0.20,
        },
        yelling = {
            'loop',{'1-4, 3'}, 0.20,
        },
        hidden = {
            'loop',{'5, 1'}, 0.20,
        },
    },

    noinventory = "Talk to my husband to about supplies.",
    enter = function(npc, previous)
        if npc.db:get('blacksmith-dead', false) and Gamestate.currentState().name == "blacksmith-upstairs" then
            npc.state = 'hidden'
            -- Prevent the animation from playing
            npc:animation():pause()
            return
        end

        local dead = npc.db:get('blacksmith_wife-dead', false)
        if Gamestate.currentState().name == "blacksmith" then
            if npc.db:get('blacksmith-dead', false) then
                if dead ~= false then
                    npc.dead = true
                    if type(dead) ~= "boolean" then
                        npc.position.x = dead.x
                        npc.position.y = dead.y
                        npc.direction = dead.direction
                    end
                    npc.state = 'dying'
                    -- Prevent the animation from playing
                    npc:animation():pause()

                    return
                else
                    npc.state = 'yelling'
                end
            else
                npc.state = 'hidden'
            end
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
            Timer.add(2 + math.random(), function() npc.props.die(npc) end)
        elseif npc.state == 'hurt' then
            npc.props.die(npc)
        end
    end,

    update = function(dt, npc, player)
        if npc.db:get('blacksmith-dead', false) then
            npc.busy = true
            if Gamestate.currentState().name == "blacksmith-upstairs" then
                npc.state = 'hidden'
            end

            if npc.state == 'yelling' or npc.state == 'hurt' then
                npc:run(dt, player)
            end
        end
    end,

    panic = function(npc, player)
        Timer.add(0.5, function()
            npc.emotion = Emotion.new(npc, "exclaim")
        end)
        npc.run_offsets = {{x=10, y=60}, {x=-10, y=125}, {x=-60, y=125}, {x=130, y=125}}
        Timer.add(1.0, function()
            npc.emotion = Emotion.new(npc)
            npc.state = 'yelling'
        end)
    end,

    die = function(npc, player)
        npc.dead = true
        npc.state = 'dying'
        npc.db:set('blacksmith_wife-dead', {x = npc.position.x, y = npc.position.y, direction = npc.direction})
    end,
}