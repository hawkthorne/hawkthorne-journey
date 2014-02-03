-- inculdes

local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
 
local function playSong(npc, level, time, song)
    npc.state = "playing"
    npc.busy = true
    sound.playMusic( song )
    Timer.add(time, function()
        npc.state = "default"
        npc.busy = false
        if level.music then
          sound.playMusic( level.music )
        end
    end)
end

return {
    width = 48,
    height = 48,  
    animations = {
        default = {
            'loop',{'1,1','1,1','1,1','1,1','1,1','1,1','1,1','1,1','2,1'},.5,
        },
        playing = {
            'loop',{'1-6,2'},.1,
        },
    },

    direction = "right",
    donotfacewhentalking = true,
    menuColor = {r=255, g=255, b=255, a=255},
    noinventory = "Sorry, my merch guy didn't come along today.",
    nocommands = "If you want to hear a song, just ask. But when I'm playing, I'm...Unstoppable!",

    talk_items = {
        { ['text']='i am done with you'},
        { ['text']='Can you play me...', ['option']={
            { ['text']='Where I Belong' },
            { ['text']='What Christmas Is For' },
            { ['text']='Viva Tacotown!' },
            { ['text']='Village Forest' },
            { ['text']='Valley of Laziness' },
            { ['text']='Starting The Game' },
            { ['text']='Somewhere Out There' },
            { ['text']='Seabluff' },
            { ['text']='Pocketful of Hawthornes' },
            { ['text']='Overworld' },
            { ['text']='New Abedtown' },
            { ['text']='M.A.S.H. Theme' },
            { ['text']='Mamma Mia' },
            { ['text']='Love So Alike' },
            { ['text']='Lets Play Poker' },
            { ['text']='Lazy Sandpits' },
            { ['text']='Kiss From A Rose' },
            { ['text']='Hall O Hippies' },
            { ['text']='Greendale Rave' },
            { ['text']='Greendale Hallways' },
            { ['text']='Greendale Exterior' },            
            { ['text']='Forest' },
            { ['text']='Farewell Abed' },
            { ['text']='Enter Cornelius' },
            { ['text']='Daybreak' },
            { ['text']='Comfy At A Cauldron' },
            { ['text']='Castle Interior' },
            { ['text']='Castle Exterior' },
            { ['text']='Blacksmiths House' },
            { ['text']='Black Caverns' },
            { ['text']='Alas Poor Britta-Bot' },
            { ['text']='A Girl Milking A Cow' },
            { ['text']='Abeds Christmas Medley' },
            { ['text']='Abeds Castle' },
}},
        { ['text']='I missed the dance...'},
        { ['text']='Sophie B. Hawkins?!'},
    },
    talk_responses = {
    ["Sophie B. Hawkins?!"]={
        "The one and only!",
	"Hawthorne Wipes are a proud sponsor of Lilith Fair!",
    },
    ["I missed the dance..."]={
        "Aw, don't fret, hun!",
	"The night's still young, and my roadies will take forever to pack up.",
	"I can always play you a song or two in the meantime.",
    },
    },
    talk_commands = {
    ["Daybreak"]=function(npc, player)
        playSong(npc, player.currentLevel, 38, "daybreak")
    end,
    ["Abeds Castle"]=function(npc, player)
        playSong(npc, player.currentLevel, 19.7, "abeds-castle")
    end,
    ["Abeds Christmas Medley"]=function(npc, player)
        playSong(npc, player.currentLevel, 322, "winter")
    end,
    ["A Girl Milking A Cow"]=function(npc, player)
        playSong(npc, player.currentLevel, 64, "town")
    end,
    ["Black Caverns"]=function(npc, player)
        playSong(npc, player.currentLevel, 47.4, "blackcaves")
    end,
    ["Blacksmiths House"]=function(npc, player)
        playSong(npc, player.currentLevel, 42, "blacksmith")
    end,
    ["Castle Exterior"]=function(npc, player)
        playSong(npc, player.currentLevel, 12.6, "castle-entrance")
    end,
    ["Comfy At A Cauldron"]=function(npc, player)
        playSong(npc, player.currentLevel, 45.2, "potionlab")
    end,
    ["Castle Interior"]=function(npc, player)
        playSong(npc, player.currentLevel, 50.3, "castle")
    end,
    ["Enter Cornelius"]=function(npc, player)
        playSong(npc, player.currentLevel, 47.5, "cornelius-appears")
    end,
    ["Forest"]=function(npc, player)
        playSong(npc, player.currentLevel, 22.2, "forest")
    end,
    ["Farewell Abed"]=function(npc, player)
        playSong(npc, player.currentLevel, 23.1, "village-forest")
    end,
    ["Village Forest"]=function(npc, player)
        playSong(npc, player.currentLevel, 33.2, "forest-2")
    end,
    ["What Christmas Is For"]=function(npc, player)
        playSong(npc, player.currentLevel, 58.7, "winter2")
    end,
    ["Mamma Mia"]=function(npc, player)
        playSong(npc, player.currentLevel, 204, "mamma-mia")
    end,
    ["M.A.S.H. Theme"]=function(npc, player)
        playSong(npc, player.currentLevel, 88, "mash-theme")
    end,
    ["New Abedtown"]=function(npc, player)
        playSong(npc, player.currentLevel, 59.1, "abeds-town")
    end,
    ["Lets Play Poker"]=function(npc, player)
        playSong(npc, player.currentLevel, 36.5, "tavern")
    end,
    ["Overworld"]=function(npc, player)
        playSong(npc, player.currentLevel, 20, "overworld")
    end,
    ["Love So Alike"]=function(npc, player)
        playSong(npc, player.currentLevel, 90, "lovesoalike")
    end,
    ["Greendale Exterior"]=function(npc, player)
        playSong(npc, player.currentLevel, 40.7, "greendale")
    end,
    ["Greendale Hallways"]=function(npc, player)
        playSong(npc, player.currentLevel, 28.8, "greendale-alt")
    end,
    ["Greendale Rave"]=function(npc, player)
        playSong(npc, player.currentLevel, 114, "rave")
    end,
    ["Lazy Sandpits"]=function(npc, player)
        playSong(npc, player.currentLevel, 136, "sandpits")
    end,
    ["Kiss From A Rose"]=function(npc, player)
        playSong(npc, player.currentLevel, 86, "credits")
    end,
    ["Seabluff"]=function(npc, player)
        playSong(npc, player.currentLevel, 30.65, "seabluff")
    end,
    ["Hall O Hippies"]=function(npc, player)
        playSong(npc, player.currentLevel, 92.3, "level")
    end,
    ["Starting The Game"]=function(npc, player)
        playSong(npc, player.currentLevel, 26.8, "opening")
    end,
    ["Alas Poor Britta-Bot"]=function(npc, player)
        playSong(npc, player.currentLevel, 20, "britta-bot")
    end,
    ["Viva Tacotown!"]=function(npc, player)
        playSong(npc, player.currentLevel, 32.6, "tacotown")
    end,
    ["Valley of Laziness"]=function(npc, player)
        playSong(npc, player.currentLevel, 155, "valley")
    end,
    ["Where I Belong"]=function(npc, player)
        playSong(npc, player.currentLevel, 90, "ending")
    end,
    ["Pocketful of Hawthornes"]=function(npc, player)
        playSong(npc, player.currentLevel, 70, "pocketful")
    end,
    ["Somewhere Out There"]=function(npc, player)
    playSong(npc, player.currentLevel, 133, "somewhereoutthere")
    end,
    },
}