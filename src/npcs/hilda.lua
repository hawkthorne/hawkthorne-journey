-- inculdes
local sound = require 'vendor/TEsound'
local Timer = require('vendor/timer')
local tween = require 'vendor/tween'
local character = require 'character'
local Gamestate = require 'vendor/gamestate'
local utils = require 'utils'
require 'utils'
local anim8 = require 'vendor/anim8'
local Dialog = require 'dialog'
local prompt = require 'prompt'

return {
    width = 32,
    height = 72, 
    run_offsets = {{x=680, y=0}, {x=680, y=0}, {x=600, y=0}}, 
    animations = {
        default = {
            'loop',{'1,1','11,1'},.5,
        },
        walking = {
            'loop',{'1,1','2,1','3,1'},.2,
        },
        birth = {
            'once',{'9-11,1'},.5,
        },
        dancing = {
            'loop',{'9-11,1', '9-11,1','9-11,2', '9-11,2', '7-8,1', '8,2', '7-8,1', '8,2'},.15,
        },
        undress = {
            'once',{'1,1','1,3','2,3','3,3','4,3','3,3','2,3','1,3'},.25,
        },
        fight = {
            'once',{'1,1','12,1'},.35,
        },
        crying = {
            'loop',{'4,1','5,1','6,1'},.35,
        },
        yelling = {
            'loop',{'5,3','6,3','7,3'}, 0.5,
        }
    },

    walking = true,
    --this will be for when the blacksmith's house burns down
    --[[enter = function(npc, previous)
        if npc.db:get('hilda-crying', false) then
            npc.state = 'crying'
            npc.position = {x = 1128, y = 192}
            return
        end
        
        if previous and previous.name ~= 'town' then
            return
        end
    end,]]
    talk_items = {
    { ['text']='i am done with you' },
    { ['text']='i will wear your skin' },
    { ['text']='madam, i am on a quest', ['option']={
        { ['text']='more...', ['option']={
            { ['text']='i am done with you' },
            { ['text']='frog extinction' },
            { ['text']='ostrich' },
            { ['text']='other parrot' },
            { ['text']='anglerfish' },
            { ['text']='seal' },
            { ['text']='spider' },
            { ['text']='snake' },
            { ['text']='parrot' },
            { ['text']='swordfish' },
            { ['text']='rhino' },
            { ['text']='magic carpet' },
            { ['text']='rocket ship' },
            { ['text']='albatross' },
            { ['text']='ladder bug' },
            { ['text']='hidden pipe' },
            { ['text']='subcon vase' },
            { ['text']='magic flute' },
            { ['text']='star zone' },
            { ['text']='rashes' },
            { ['text']='zits' },
            { ['text']='pimples' },
            { ['text']='dark queen' },
            { ['text']='mechanical' },
            { ['text']='stoneship' },
            { ['text']='channel wood' },
            { ['text']='space ship' },
            { ['text']='old man trainer' },
            { ['text']='fly on a bird' },
            { ['text']='cinnamon island' },
            { ['text']='seal along the shore' },
            { ['text']='black lightning' },
            { ['text']='hornet' },
            { ['text']='shredder' },
            { ['text']='avenger' },
            { ['text']='wing hat' },
            { ['text']='magic feather' },
            { ['text']='raccoon clothes' },
            { ['text']='running jump' },
            { ['text']='collect all blue coins' },
            { ['text']='island of annoying voices' },
            { ['text']='hot tub end boss' },
            { ['text']='mustached mushroom' },
            { ['text']='bell toss' },
            { ['text']='charged fireball' },
            { ['text']='time bombs' },
            { ['text']='rock punch' },
            { ['text']='blue fire' },
            { ['text']='green fire' },
            { ['text']='purple fire' },
            { ['text']='boring regular old fire' },
            { ['text']='flying war ships' },
            { ['text']='clown face helicopter' },
            { ['text']='teeter totter flying floor' },
            { ['text']='unstable bath' },
            { ['text']='impervious to lava' },
            { ['text']='underwater exploration' },
            { ['text']='hover puppy' },
            { ['text']='giant ant dance club' },
            { ['text']='good karma quests' },
            { ['text']='fun quests' },
            { ['text']='unkillable bears' },
            { ['text']='antiphysics horse' },
            { ['text']='bubble attack' },
            { ['text']='leaf attack' },
            { ['text']='time freeze attack' },
            { ['text']='metal blade attack' },
            { ['text']='egg treatment' },
            { ['text']='blue poultry' },
            { ['text']='the chicken lady' },
            { ['text']='forest fungus' },
            { ['text']='wild children' },
            { ['text']='trippy potions' },
            { ['text']='pharmacist' },
            { ['text']='sawing small trees' },
            { ['text']='carpenter camps' },
            { ['text']='broken swords' },
            { ['text']='giant rock monster' },
            { ['text']='frog prescriptions' },
            { ['text']='vision medication' },
            { ['text']='brick vouchers' },
            { ['text']='extra large swords' },
        }},
        { ['text']='flowers', freeze = true },
        { ['text']='throne of hawkthorne'},
        { ['text']='for your hand', freeze = true},
    }},
    { ['text']='stand aside' },
    },
    talk_commands = {
        ['flowers']=function(npc, player)
        		npc.walking = false
        		npc.stare = false
        	
        	if player.quest~=nil and player.quest~='collect flowers' then
            Dialog.new("You already have quest '" .. player.quest .. "' for " .. player.questParent .. "!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.quest=='collect flowers' and not player.inventory:hasMaterial('flowers') then
            Dialog.new("Have you found any flowers?  Try looking beyond the town.", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.quest=='collect flowers' and player.inventory:hasMaterial('flowers') then
            Dialog.new("My goodness, these flowers are beautiful!  Thank you so very much!", function()
            npc:affectionUpdate(300)
            player:affectionUpdate('hilda',300)
        			npc.walking = true
        			player.inventory:removeManyItems(1,{name='flowers',type='material'})
        			player.quest = nil
              npc.menu:close(player)
        		end)
  	      else
            Dialog.new("I love flowers!  I used to collect flowers from the forest beyond the blacksmith but ever since Hawkthorne started ruling the forests haven't been safe.", function()
              Dialog.new("I would be so happy if someone could pick me some!", function()
                npc.prompt = prompt.new("Do you want to collect flowers for Hilda?", function(result)
                  if result == 'Yes' then
                    player.quest = 'collect flowers'
                    player.questParent = 'hilda'
                  end
                  npc.menu:close(player)
                  npc.fixed = result == 'Yes'
                  npc.walking = true
                  npc.prompt = nil
                  Timer.add(2, function() 
                    npc.fixed = false
                  end)
                end)
              end)
            end)
          end

    end,

    ['for your hand']=function(npc, player)
        local affection = player.affection.hilda or 0
        npc.walking = false
        npc.stare = false
        if affection < 1000 and player.married == false then
          Dialog.new("I cannot marry someone whom I do not truly love and trust.  My current affection for you is " .. affection .. ".", function()
              npc.walking = true
              npc.menu:close(player)
          end)
        

        elseif player.married and not player.married == 'hilda' then
          sound.playSfx( "dbl_beep" )
          Dialog.new("How dare you! You're already married!", function ()
            npc.walking = true
            Dialog.currentDialog = nil
            npc.menu:close(player)
          end)

        elseif player.married == 'hilda' then
         	Dialog.new("I live in the village.  I love " .. player.character.name .. "." , function()
                npc.walking = true
                Dialog.currentDialog = nil
                npc.menu:close(player)
            end)
  		          	
        elseif affection >= 1000 and not player.married then
            npc.walking = false
        	npc.stare = false
        	sound.playSfx( "dbl_beep" )
            	Dialog.new("Yes yes a thousand times yes! We will have so many adorable babies together.", function()
                  player.married = 'hilda'
                  npc.walking = true
                  npc.menu:close(player)
            	end)


        end 
      --self.fade = {0, 0, 0, 0}
      --tween(1, self.fade, {0, 0, 200, 130}, 'outQuad')
    end,
    },
    talk_responses = {
    ['madam, i am on a quest']={
        "I can help with that",
        "I have information on many topics...",
    },
	['i will wear your skin']={
        "My skin is not my own.",
    },
	['stand aside']={
        "I'm sorry to see you go.",
    },
    ['throne of hawkthorne']={
        "The throne is in Castle Hawkthorne, north of here.",
    "You unlock the castle with the white crystal of discipline, which you must free from the black caverns.",
    },
    ['frog extinction']={
        "You know what? My prank is going to cause a sea of laughter,",
        "and I am going to watch you drown in it!",
    },
    ['ostrich']={
        "I like ostriches, but also, I don't?",
        "I don't support ostriches. They're unfair to pigeons.",
        "I guess that's why you never see them",
        "on the same continent.",
    },
    ['other parrot']={
        "In the toughest jungle in the world,",
        "there are the big time parrots,",
        "and then there are the Other Parrots.",
    },
    ['anglerfish']={
        "A violent fish, prone to aggression.",
        "You wouldn't like him when he's anglery",
    },
    ['seal']={
        "You can unlock this by getting kissed,",
        "by a rose on the grey",
    },
    ['spider']={
        "We're gonna make Spiderman black now?",
        "Why don't we just have Michael Cera play Shaft?",
    },
    ['snake']={
        "Snake? Snake?!",
        "SNAAAAKKKEEE!!",
    },
    ['parrot']={
        "This parrot is no more!",
        "He has ceased to be!",
    },
    ['swordfish']={
        "An underrated movie starring Wolverine,",
        "it's still not as good as Blade.",
    },
    ['rhino']={
        "Oh, this was just a nickname that I got in college.",
        "Don't worry about it.",
    },
    ['magic carpet']={
        "Almost always piloted by friendly...",
        "yet sexually ambiguous Glee club instructors.",
    },
    ['rocket ship']={
        "Just as KFC's secret process seals in the flavor,",
        "I'm sealing in the cabin's air",
        "so you don't explode on your journey.",
    },
    ['albatross']={
        "Albatrosses are one of the biggest birds in the world.",
        "Many species of albatross are close to extinction,",
        "therefore we must try harder.",
    },
    ['ladder bug']={
        "Welcome to... ladders",
        "**applause**",
    },
    ['hidden pipe']={
        "It's hidden.",
    },
    ['subcon vase']={
        "Breaking this vase sends you into a dream-like state filled with your subconscious.",
    },
    ['magic flute']={
        "Playing one of these may cause you to be transported",
        "to far off worlds that will frustrate you even more",
    },
    ['star zone']={
        "In my opinion, there is only one star worth studying.",
        "It is a black hole called Sagittarius A,",
        "located in the center of our galaxy.",
        "It has the density of 40 suns. Just like my wiener.",
    },
    ['rashes']={
        "I'm not getting flustered,",
        "these things on my chest are just rashes.",
        "I'm allergic to beans.",
    },
    ['zits']={
        "Like pimples, but too small to pop. Caused by poor breeding",
    },
    ['pimples']={
        "Whenever Magnitude gets a pimple, he knows what to do.",
    },
    ['dark queen']={
        "There are two things you need to know about the dark queen.",
        "#1, she is dark.",
        "#2, she is a queen.",
        "Do not abuse your knowledge.",
    },
    ['mechanical']={
        "I want to watch Tom Selleck fight mechanical spiders.",
    },
    ['stoneship']={
        "It'll sink like a lead balloon.",
    },
    ['channel wood']={
        "That's what she said.",
    },
    ['space ship']={
        "In the future",
        "two cardboard boxes",
        "are about to become",
        "SPACE SHIPS",
    },
    ['old man trainer']={
        "I'm younger than the three of you put together.",
    },
    ['fly on a bird']={
        "Am I a bird?",
        "No, I'm a bat.",
        "I'm Batman.",
    },
    ['cinnamon island']={
        "It's atmosphere is 7% cinnamon.",
    },
    ['seal along the shore']={
        "Oh, I do like to be beside the seaside,",
        "I do like to be beside the sea.",
    },
    ['black lightning']={
        "Faster than white lightning.",
    },
    ['hornet']={
        "This honey gives me a buzzzz.",
    },
    ['shredder']={
        "Together we will punish these creatures, ...",
        "these turtles.",
    },
    ['avenger']={
        "There was an idea to bring together a group of remarkable people,",
        "so when we needed them,",
        "they could fight the battles that we never could.",
    },
   ['wing hat']={
        "Imaginary opera gloves.",
        "Wait, what is this? What are we doing?",
    },
    ['magic feather']={
        "Sticking feathers up your butt does not make you a chicken.",
    },
    ['raccoon clothes']={
        "A raccoon once bit my sister.",
        "No realli! She was carving her initials on the raccoon...",
        "with the sharpened end of an intergalactic toothbrush.",
        "Go watch Monty Python if you think realli is wrong.",

    },
    ['running jump']={
        "You can only jump so far until you break your leg.",
    },
    ['collect all blue coins']={
        "Bugger me, you could get someone killed for that.",
    },
    ['island of annoying voices']={
        "Annoy, tiny blonde one.",
        "Annoy like the wind.",
    },
    ['hot tub end boss']={
        "Wetter than you'd think.",
    },
    ['mustached mushroom']={
        "Start living like you have a mustache - ",
        "Ask yourself what would Burt Reynolds do?",
    },
    ['bell toss']={
        "Oranges and lemons ...",
    },
    ['charged fireball']={
        "On the bright side,",
        "We haven't had any earthquakes lately.",
    },
    ['time bombs']={
        "We have three realistic alternatives",
        "#1, Sit here and get blown up,",
        "#2. Stand here and get blown up,",
        "#3, Jump up and down, shout at me for not being able to think of anything, then get blown up.",
    },
    ['rock punch']={
        "You must seek out Kickpuncher;",
        "His punches have the power of kicks.",
    },
    ['blue fire']={
        "Use copper chloride.",
    },
    ['green fire']={
        "Never laugh at live dragons, Bilbo you fool!",
    },
    ['purple fire']={
        "The opposite colour fire doesn't put it out."   
    },
    ['boring regular old fire']={
        "Next contestant, Mrs. Sybil Fawlty from Torquay.",
        "Specialist subject - the bleeding obvious.",
    },
    ['flying war ships']={
        "Don't mention the war.",
    },
    ['clown face helicopter']={
        "Flying a helicopter is no different than riding a bike,",
        "it's just a lot harder to put baseball cards in the spokes.",
    },
    ['teeter totter flying floor']={
        "Even with an IQ of 6000, it's still brown-trousers time.",
    },
    ['unstable bath']={
        "With bubbles - it's a milestone.",
    },
    ['impervious to lava']={
        "Run, run the house is on mfire!",
        "You can't mfire me - I mquit.",
    },
    ['underwater exploration']={
        "I can swim, racist.",
    },
    ['hover puppy']={
        "Does it always have to be puppies though?",
    },
    ['giant ant dance club']={
        "If you knew how they treat those animals",
        "you would eat them faster,",
        "to put them out of their misery,",
        "and then you would throw up.",
    },
    ['good karma quests']={
        "Wik.",
        "That's a Holy Grail reference.",
    },
    ['fun quests']={
        "Between our quests we sequin vests",
        "and impersonate Clark Gable.",
    },
    ['unkillable bears']={
        "Their kryptonite is dragon farts ...",
        "mixed with dust bunnies.",
        "You can't kill them but you can ...",
        "make them wonder what the hell is going on.",
    },
    ['antiphysics horse']={
        "I've got a pantomime-horse disguise you could use.",
        "Do either of you have any experience being a horse's ass?",
    },
    ['bubble attack']={
        "Bubbles! Bubbles! My bubbles!",
    },
    ['leaf attack']={
        "I know kung-fu.",
    },
    ['time freeze attack']={
        "Did you see TimeCop?",
        "He, like, totally changed time.",
    },
    ['metal blade attack']={
        "Stab them with the pointy end.",
    },
    ['egg treatment']={
        "I do not like green eggs and ham.",
    },
    ['blue poultry']={
        "Treat yo' self!",
    },
    ['the chicken lady']={
        "She brings me all the bacon and eggs she has.",
    },
    ['forest fungus']={
        "Ew, that looks infected.",
    },
    ['wild children']={
        "It is more fun to talk with someone who doesn't",
        "use long, difficult words",
        "but rather short, easy words like,",
        "'What about lunch?'",
    },
    ['trippy potions']={
        "How far beyond zebra are you planning to go?",
    },
    ['pharmacist']={
        "Continental cretin.",
    },
    ['sawing small trees']={
        "But there's no wood.",
    },
    ['carpenter camps']={
        "Why do birds suddenly appear?",
    },
    ['broken swords']={
        "Has anyone ever tried sticking a sword in Voldemort?",
    },
    ['giant rock monster']={
        "R.O.U.S",
        "Rocks of unusal size.",
    },
    ['frog prescriptions']={
        "I'm a frog.",
        "Someone got that was a Power Rangers reference?",
        "Right?",
    },
    ['vision medication']={
        "You'll miss the best things if you keep your eyes shut.",
    },
    ['brick vouchers']={
        "I'm broke.",
        "I tried to buy fertilizer the other day for the soccer field.",
        "Request denied.",
        "I literally can't buy %$&#!.",
    },
    ['extra large swords']={
        "You have successfully rubbed your balls on his sword.",
    },
    },
    tickImage = love.graphics.newImage('images/npc/hilda_heart.png'),
    command_items = { 
    --{ ['text']='back' },
    { ['text']='more', ['option']={
        { ['text']='custom', ['option']={
            { ['text']='more', ['option']={
                { ['text']='more', ['option']={
                    { ['text']='more'},
                    { ['text']='make baby', freeze = true},
                    { ['text']='spacetime rpg'},
                    { ['text']='handshake'},
                    },},
                { ['text']='hug'},
                { ['text']='kickpunch', freeze = true},
                { ['text']='undress', freeze = true},
                },},
            { ['text']='repair'},
            { ['text']='defend'},
            { ['text']='fight', freeze = true},
            },},
        { ['text']='dance', freeze = true },        
        { ['text']='rest'},
        { ['text']='heal'}, 
        },},
    { ['text']='go home' },
    { ['text']='stay' }, 
    { ['text']='follow' }, 
    },
    command_commands = {
    ['follow']=function(npc, player)
        npc.walking = true
        npc.stare = true
        npc.minx = npc.maxx
    end,

    ['stay']=function(npc, player)
        npc.walking = false
        npc.stare = false
    end,
    ['go home']=function(npc, player)
        npc.walking = true
        npc.stare = false
        npc.minx = npc.maxx - (npc.props.max_walk or 48)*2
    end,
    ['heal']=function(npc, player)
        player.health = player.max_health
        sound.playSfx( "healing_quiet" )
        npc:affectionUpdate(100)
        player:affectionUpdate('hilda',100)
    end,
    ['rest']=function(npc, player)
        sound.playSfx( "dbl_beep" )
		npc.walking = true
		npc.stare = false
    end,
    ['dance']=function(npc, player)
        npc.walking = false
        npc.stare = false
        npc.state = "dancing"
        npc.busy = true
        Timer.add(5, function()
            npc.state = "walking"
            npc.busy = false
            npc.walking = true
            npc:affectionUpdate(10)
            player:affectionUpdate('hilda',10)
            npc.menu:close(player)
        end)
    end,
    ['fight']=function(npc, player)
        npc.walking = false
        npc.state = 'fight'
        npc.busy = true
        player:hurt(5)
        Timer.add(.5, function()
            npc.state = "walking"
            npc.busy = false
            npc.walking = true
            npc:affectionUpdate(-50)
            player:affectionUpdate('hilda',-50)
            npc.menu:close(player)
        end)
    end,
    ['defend']=function(npc, player)
        sound.playSfx( "dbl_beep" )
    end,
    ['repair']=function(npc, player)
        sound.playSfx( "dbl_beep" )
    end,
    ['undress']=function(npc, player)
        npc.walking = false
        npc.state = "undress"
        npc.busy = true
        Timer.add(2, function()
            npc.state = "walking"
            npc.busy = false
            npc.walking = true
            npc:affectionUpdate(10)
            player:affectionUpdate('hilda',10)
            npc.menu:close(player)
        end)
    end,
    ['kickpunch']=function(npc, player)
        npc.walking = false
        npc.stare = false
        npc.prompt = prompt.new("Do you want to learn to kickpunch?", function(result)
        	if result == 'Yes' then
            	player.canSlideAttack = true
            	Dialog.new("To kickpunch run forward then press DOWN then ATTACK.", function()
                	Dialog.currentDialog = nil
                	npc.menu:close(player)
                	end)
            	npc.walking = true
        	end
        	if result == 'No/Unlearn' then
          		player.canSlideAttack = false
          		npc.walking = true
          
        	end
        npc.fixed = result == 'Yes'
        Timer.add(2, function() npc.fixed = false end)
        npc.prompt = nil
        npc.walking = true
        npc.menu:close(player)
      end)
    end,
    ['hug']=function(npc, player)
        sound.playSfx( "dbl_beep" )
    end,
    ['handshake']=function(npc, player)
        sound.playSfx( "dbl_beep" )

    end,

    ['spacetime rpg']=function(npc, player)
        sound.playSfx( "dbl_beep" )

    end,
    ['make baby']=function(npc, player)
        npc.walking = false
        npc.stare = false
        if player.married == 'hilda' then
        	npc.state = "birth"
        	npc.busy = true
        	Timer.add(.5, function()
            	npc.walking = true
            	npc.state = "walking"
            	npc.busy = false
            	local NodeClass = require('nodes/npc')
            	local node = {
                	type = 'npc',
                	name = 'babyabed',
                	x = npc.position.x + npc.width/2 - 12,
                	y = 240,
                	width = 32,
                	height = 25,
                	properties = {}
                	}
            	local spawnedNode = NodeClass.new(node, npc.collider)
            	local level = Gamestate.currentState()
            	level:addNode(spawnedNode)
              npc.menu:close(player)
        	end)
        elseif player.married and not player.married == 'hilda' then
            sound.playSfx( "dbl_beep" )
            Dialog.new("How dare you!  You're already married!", function()
                npc.walking = true
                Dialog.currentDialog = nil
                npc.menu:close(player)
            end) 

        else
            sound.playSfx( "dbl_beep" )
            Dialog.new("I would never have a child with someone I wasn't married to!", function()
                npc.walking = true
                Dialog.currentDialog = nil
                npc.menu:close(player)
            end)

        end 
    end,
    },
    --[[update = function(dt, npc, player)
        if npc.db:get('blacksmith-dead', false) then
        -- Hilda running around
            Timer.add(10, function() 
                    --npc.state = 'crying' 
            		npc.busy = false
            		npc.walking = false
            		npc.db:set('hilda-crying', true)
                  end)
            npc:run(dt, player)
            npc.state = 'yelling'
            npc.busy = true  
        end
    end,]]

}