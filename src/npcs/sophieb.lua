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
            { ['text']='You Just Lost A Game' },
            { ['text']='Where I Belong' },
            { ['text']='What Christmas Is For' },
            { ['text']='Viva Tacotown!' },
            { ['text']='Village Forest' },
            { ['text']='Valley of Laziness' },
            { ['text']='To Understand Christmas' },
            { ['text']='The Way It Goes' },
            { ['text']='Take The Throne' },
            { ['text']='Study Room F' },
            { ['text']='Starting The Game' },
            { ['text']='Somewhere Out There' },
            { ['text']='Seabluff' },
            { ['text']='Running Through Rain' },
            { ['text']='Roxanne' },
            { ['text']='Pocketful of Hawthornes' },
            { ['text']='Overworld' },
            { ['text']='Ol Fashion Nightmare' },
            { ['text']='New Abedtown' },
            { ['text']='Modern Warfare' },
            { ['text']='Merry Happy!' },
            { ['text']='M.A.S.H. Theme' },
            { ['text']='Mamma Mia' },
            { ['text']='Love So Alike' },
            { ['text']='Lindbergh Lean' },
            { ['text']='Lets Play Poker' },
            { ['text']='Lazy Sandpits' },
            { ['text']='Kiss From A Remix' },
            { ['text']='Kiss From A Rose' },
            { ['text']='Is He Being Ominous?' },
            { ['text']='Hall O Hippies' },
            { ['text']='Greendale Rave' },
            { ['text']='Greendale Hallways' },
            { ['text']='Greendale Exterior' },
            { ['text']='Gravity' },
            { ['text']='Gilbert Strikes Back' },
            { ['text']='Getting Rid of Bowser' },
            { ['text']='Getting Rid of Britta' },
            { ['text']='Forfeiting' },
            { ['text']='Forest' },
            { ['text']='Finally Be Fine' },
            { ['text']='Farewell Abed' },
            { ['text']='Enter Cornelius' },
            { ['text']='Die Racism!' },
            { ['text']='Daylight' },
            { ['text']='Daybreak' },
            { ['text']='Dancing Queen' },
            { ['text']='Community Medley' },
            { ['text']='Comfy At A Cauldron' },
            { ['text']='Christmas Infiltration' },
            { ['text']='Castle Interior' },
            { ['text']='Castle Exterior' },
            { ['text']='Blacksmiths House' },
            { ['text']='Black Caverns' },
            { ['text']='A Winger Speech' },
            { ['text']='At Least Its Underground' },
            { ['text']='At Least Its Finally Boss' },
            { ['text']='At Least It Was Here' },
            { ['text']='A Simple Question' },
            { ['text']='Alas Poor Britta-Bot' },
            { ['text']='A Girl Milking A Cow' },
            { ['text']='Abeds Christmas Medley' },
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
    ["A Simple Question"]=function(npc, player)
        playSong(npc, player.currentLevel, 22.3, "contract")
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
    ["Die Racism!"]=function(npc, player)
        playSong(npc, player.currentLevel, 89.8, "corneliusbattle")
    end,
    ["Enter Cornelius"]=function(npc, player)
        playSong(npc, player.currentLevel, 47.5, "cornelius-appears")
    end,
    ["Forfeiting"]=function(npc, player)
        playSong(npc, player.currentLevel, 31, "forfeiting")
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
    ["Modern Warfare"]=function(npc, player)
        playSong(npc, player.currentLevel, 240.5, "modernwarfare")
    end,
    ["A Winger Speech"]=function(npc, player)
        playSong(npc, player.currentLevel, 73.2, "wingerspeech")
    end,
    ["What Christmas Is For"]=function(npc, player)
        playSong(npc, player.currentLevel, 58.7, "winter2")
    end,
    ["The Way It Goes"]=function(npc, player)
        playSong(npc, player.currentLevel, 228, "wayitgoes")
    end,
    ["New Abedtown"]=function(npc, player)
        playSong(npc, player.currentLevel, 59.1, "abeds-town")
    end,
    ["At Least It Was Here"]=function(npc, player)
        playSong(npc, player.currentLevel, 151.3, "leastitwashere")
    end,
    ["At Least Its Finally Boss"]=function(npc, player)
        playSong(npc, player.currentLevel, 274.5, "finallyboss")
    end,
    ["At Least Its Underground"]=function(npc, player)
        playSong(npc, player.currentLevel, 23.4, "atleastunderground")
    end,
    ["Merry Happy!"]=function(npc, player)
        playSong(npc, player.currentLevel, 109.7, "merryhappy")
    end,
    ["To Understand Christmas"]=function(npc, player)
        playSong(npc, player.currentLevel, 74.4, "understandxmas")
    end,
    ["Take The Throne"]=function(npc, player)
        playSong(npc, player.currentLevel, 8.35, "takethethrone")
    end,
    ["Running Through Rain"]=function(npc, player)
        playSong(npc, player.currentLevel, 96.1, "runningthroughrain")
    end,
    ["Roxanne"]=function(npc, player)
        playSong(npc, player.currentLevel, 197, "roxanne")
    end,
    ["Lindbergh Lean"]=function(npc, player)
        playSong(npc, player.currentLevel, 147.1, "lindberghlean")
    end,
    ["Lets Play Poker"]=function(npc, player)
        playSong(npc, player.currentLevel, 36.5, "tavern")
    end,
    ["Daylight"]=function(npc, player)
        playSong(npc, player.currentLevel, 74, "daylight")
    end,
    ["Ol Fashion Nightmare"]=function(npc, player)
        playSong(npc, player.currentLevel, 199, "nightmare")
    end,
    ["Overworld"]=function(npc, player)
        playSong(npc, player.currentLevel, 20, "overworld")
    end,
    ["Christmas Infiltration"]=function(npc, player)
        playSong(npc, player.currentLevel, 56, "xmasrap")
    end,
    ["Love So Alike"]=function(npc, player)
        playSong(npc, player.currentLevel, 90, "lovesoalike")
    end,
    ["Finally Be Fine"]=function(npc, player)
        playSong(npc, player.currentLevel, 53, "finallybefine")
    end,
    ["Getting Rid of Britta"]=function(npc, player)
        playSong(npc, player.currentLevel, 131.5, "ridbritta")
    end,
    ["Getting Rid of Bowser"]=function(npc, player)
        playSong(npc, player.currentLevel, 76, "bowser")
    end,
    ["Gravity"]=function(npc, player)
        playSong(npc, player.currentLevel, 117.3, "gravity")
    end,
    ["M.A.S.H. Theme"]=function(npc, player)
        playSong(npc, player.currentLevel, 88, "mash-theme")
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
    ["Gilbert Strikes Back"]=function(npc, player)
        playSong(npc, player.currentLevel, 18.7, "gilbertstrikesback")
    end,
    ["Lazy Sandpits"]=function(npc, player)
        playSong(npc, player.currentLevel, 136, "sandpits")
    end,
    ["Mamma Mia"]=function(npc, player)
        playSong(npc, player.currentLevel, 204, "mamma-mia")
    end,
    ["Kiss From A Rose"]=function(npc, player)
        playSong(npc, player.currentLevel, 86, "credits")
    end,
    ["Kiss From A Remix"]=function(npc, player)
        playSong(npc, player.currentLevel, 101, "kissfromjesus")
    end,
    ["Is He Being Ominous?"]=function(npc, player)
        playSong(npc, player.currentLevel, 60.7, "ominous")
    end,
    ["Pocketful of Hawthornes"]=function(npc, player)
        playSong(npc, player.currentLevel, 70, "pocketful")
    end,
    ["Dancing Queen"]=function(npc, player)
        playSong(npc, player.currentLevel, 237, "dancingqueenfull")
    end,
    ["Somewhere Out There"]=function(npc, player)
        playSong(npc, player.currentLevel, 132, "somewhereoutthere")
    end,
    ["Study Room F"]=function(npc, player)
        playSong(npc, player.currentLevel, 53.5, "studyroom")
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
    ["Community Medley"]=function(npc, player)
        playSong(npc, player.currentLevel, 246.1, "medley")
    end,
    ["You Just Lost A Game"]=function(npc, player)
        playSong(npc, player.currentLevel, 7, "you-just-lost")
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
    },
}