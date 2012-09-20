local hilda = {}

hilda.sprite = love.graphics.newImage('images/hilda.png')
hilda.tickImage = love.graphics.newImage('images/heart.png')
hilda.menuImage = love.graphics.newImage('images/hilda_menu.png')
hilda.walk = true
hilda.items = {
    { ['text']='exit' },
    { ['text']='inventory' },
    { ['text']='command' },
    { ['text']='talk', ['option']={
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
                { ['text']='wine hat' },
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
            { ['text']='i am done with you' },
            { ['text']='throne of hawkthorne' },
            { ['text']='for your hand' },
        }},
        { ['text']='stand aside' },
    }},
}

hilda.responses = {
    ['madam, i am on a quest']={
        'I can help with that',
        'I have information on many topics...',
    },
    ['throne of hawkthorne']={
        'The throne is in Castle Hawkthorne,',
        'north of here. You unlock the castle with',
        'the white crystal of discipline,',
        'which you must free from the black caverns.',
    },
    ['frog extinction']={
        'You know what? My prank is going to cause a sea of',
        'laughter, and I am going to watch you drown in it!',
    },
    ['ostrich']={
        "I like ostriches, but also, I don't?",
        "I don't support ostriches. They're unfair to pigeons.",
        "I guess that's why you never see them",
        "on the same continent.",
    },
    ['other parrot']={
        'In the toughest jungle in the world,',
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
        "SNAAAAAAKKKEEEEEE!!!",
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
        'Breaking this vase forces you into a dream-like state,',
        'filled with your subconscious.',
    },
    ['magic flute']={
        'Playing one of these may cause you to be transported',
        'to far off worlds that will frustrate you even more',
    },
    ['star zone']={
        'In my opinion, there is only one star worth studying.',
        'It is a black hole called Sagittarius A,',
        'located in the center of our galaxy.',
        'It has the density of 40 suns. Just like my wiener.',
    },
    ['rashes']={
        "I'm not getting flustered,",
        "these things on my chest are just rashes.",
        "I'm allergic to beans.",
    },
    ['zits']={
        'Like pimples, but too small to pop.',
        'Caused by poor breeding',
    },
    ['pimples']={
        'Whenever Magnitude gets a pimple,',
        'he knows what to do',
    },
    ['dark queen']={
        'There are two things you need to know,',
        'about the dark queen.',
        '#1, she is dark.',
        '#2, she is a queen',
        'Do not abuse your knowledge.',
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
    }
    ['seal along the shore']={
        "Oh, I do like to be beside the seaside,",
        "I do like to be beside the sea.",
    }
    ['black lightning']={
        "Faster than white lightning.",
    },
    ['hornet']={
        "This honey gives me a buzzzz.",
    }
    ['shredder']={
        "Together we will punish these creatures,",
        "these turtles.",
    }
    ['avenger']={
        "There was an idea to bring together a group of remarkable people,",
        "so when we needed them,",
        "they could fight the battles that we never could.",
    }
   ['wine hat']={
        "Imaginary opera gloves.",
        "Wait, what is this? What are we doing?",
    }
    ['magic feather']=nil,
    ['raccoon clothes']={
        "A raccoon once bit my sister.",
        "No realli! She was carving her initials on the raccoon..."
        "with the sharpened end of an intergalactic toothbrush."
    },
    ['running jump']=nil,
    ['collect all blue coins']={
        "Bugger me, you could get someone killed for that.",
    }
    ['island of annoying voices']=nil,
    ['hot tub end boss']=nil,
    ['mustached mushroom']=nil,
    ['bell toss']=nil,
    ['charged fireball']=nil,
    ['time bombs']={
        "We have three realistic alternatives:",
        "#1, Sit here and get blown up,",
        "#2. Stand here and get blown up,",
        "#3, Jump up and down, shout at me for not being able to thing of anything,",
        "then get blown up.",
    },
    ['rock punch']=nil,
    ['blue fire']=nil,
    ['green fire']=nil,
    ['purple fire']={
        "The opposite colour fire doesn't put it out."   
    },
    ['boring regular old fire']={
        "Next contestant, Mrs. Sybil Fawlty from Torquay.",
        "Specialist subject - the bleeding obvious.",
    }
    ['flying war ships']={
        "Don't mention the war.",
    }
    ['clown face helicopter']=nil,
    ['teeter totter flying floor']=nil,
    ['unstable bath']=nil,
    ['impervious to lava']=nil,
    ['underwater exploration']={
        "I can swim, racist.",
    },
    ['hover puppy']={
        "Does it always have to be puppies though?",
    },
    ['giant ant dance club']={
        "If you knew how they treat those animals",
        "you would eat them faster,"
        "to put them out of their misery,"
        "and then you would throw up."
    },
    ['good karma quests']={
        "Wik.",
    },
    ['fun quests']=nil,
    ['unkillable bears']={
        "Their kryptonite is dragon farts ...",
        "mixed with dust bunnies."
        "You can't kill them but you can ...",
        "make them wonder what the hell is going on.",
    },
    ['antiphysics horse']=nil,
    ['bubble attack']=nil,
    ['leaf attack']=nil,
    ['time freeze attack']=nil,
    ['metal blade attack']=nil,
    ['egg treatment']=nil,
    ['blue poultry']=nil,
    ['the chicken lady']=nil,
    ['forest fungus']={
        "Ew, that looks infected.",
    },
    ['wild children']=nil,
    ['trippy potions']=nil,
    ['pharmacist']={
        "Continental cretin.",
    }
    ['sawing small trees']=nil,
    ['carpenter camps']=nil,
    ['broken swords']=nil,
    ['giant rock monster']=nil,
    ['frog prescriptions']=nil,
    ['vision medication']=nil,
    ['brick vouchers']=nil,
    ['extra large swords']=nil,
}


return hilda
