-- inculdes

local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
 
local function playSong(npc, level, time, song)
    npc.state = "playing"
    sound.playMusic( song )
    Timer.add(time, function()
        npc.state = "default"
        sound.playMusic( level.music )
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

    talk_items = {
        { ['text']='i am done with you'},
        { ['text']='Play me a song?'},
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
    ["Play me a song?"]={
        "Of course! Just give me the command.",
	"I keep my setlist there.",
    },
    },
    
    command_items = {
        { ['text']='Daybreak' },
        { ['text']='Daylight' },
        { ['text']='Where I Belong' },
        { ['text']='Alas Poor Britta-Bot' },
    },
    command_commands = {
    ["Daybreak"]=function(npc, player)
        playSong(npc, player.currentLevel, 10, "daybreak")
    end,
    ["Daylight"]=function(npc, player)
        playSong(npc, player.currentLevel, 74, "daylight")
    end,
    ["Alas Poor Britta-Bot"]=function(npc, player)
        playSong(npc, player.currentLevel, 20, "britta-bot")
    end,
    ["Where I Belong"]=function(npc, player)
        playSong(npc, player.currentLevel, 91, "whereibelong")
    end,
    },
}