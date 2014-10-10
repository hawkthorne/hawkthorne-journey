-- inculdes

return {
    width = 32,
    height = 48,   
    greeting = 'My name is {{red_light}}Senor Juan{{white}}.  I guard this {{orange}}fence{{white}}.', 
    animations = {
        default = {
            'loop',{'1,1','11,1'},.5,
        },
        walking = {
            'loop',{'1,1','2,1','3,1'},.2,
        },

    },

    stare = true,

    talk_items = {
        
		{ ['text']='Where\'s your hat?' },
        { ['text']='Who are you?' },
        { ['text']='Is there another way out?' },
        { ['text']='Tell me about this fence', ['option']={
            { ['text']='Who put this here?' },
            { ['text']='Why is this here?' },
            { ['text']='Can I pass?' },
            { ['text']='Why are you guarding it?' },
        }},
    },
    talk_responses = {
    ["Who are you?"]={
        "I am Senor Juan, the lead border guard in charge of making sure no one gets out of this Valley.",
    },
	["Where's your hat?"]={
        "I lost the damned thing in the {{olive}}chilli fields{{white}}.",
		"I must have dropped it when I tripped on the cow skull outside the...",
		"Um... never mind. Just keep an eye for it if you happen to pass through the fields, will you?",
    },
    ["Is there another way out?"]={

        "Of course not, son, otherwise everybody would have escaped by now.",
        "This has always been the only way out.",
		"Yes sir!",

    },
    ["Who put this here?"]={
        "That old king {{grey}}Cornelius{{white}} put this thing up here not too long ago, and hired me and my crew to help build and guard it.",
    },
    ["Why is this here?"]={
        "When his majesty {{grey}}Cornelius{{white}} got tired of all the illegal immigrants pouring out, he commissioned the construction of this fence.",
        "That, and because of the amount of illegal substances secretly being smuggled out of here.",
    },
    ["Can I pass?"]={
        "Hah, you're welcome to try. There's no possible way you can jump over this thing.",
        "Don't even think about trying to break it either, it's reinforced with triple-thick steel.",
    },
    ["Why are you guarding it?"]={
        "I was hired, to help build and guard this thing.",
        "Some people call me a traitor to the Valley villagers, but hey, money's money.",
    },
    },
}