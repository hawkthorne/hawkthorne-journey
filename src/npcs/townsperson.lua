-- inculdes

return {
  width = 32,
  height = 48,  
  animations = {
    default = {
      'loop',{'1,1','11,1'},.5,
    },
    walking = {
      'loop',{'1,1','2,1','3,1'},.2,
    },
  },

  walking = true,
  walk_speed = 36,
 
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='What are you carrying?'},
    { ['text']='This town is in ruins!' },
    { ['text']='Talk about the Acorn King', ['option'] ={
        { ['text']='Who is he?'},
        { ['text']='Where did he come from?'},
        { ['text']='How do we defeat him?' },
        { ['text']='Great, even more acorns!' },
        --{ ['text']='Lets overthrow him?' },
        --{ ['text']='Get this town together!'},
    }},
  },

  talk_responses = {
    ["Who is he?"]={
      "Who knows? Some say he's a monster, some say he's an evil spirit.",
      "All I know is that him and his acorn underlings aren't welcome in this town.",
      "It's because of the acorn infestation that we had to close the mines, it got too dangerous!",
    },
    ["This town is in ruins!"]={
      "Ever since that tyrant {{grey}}Hawkthorne{{white}} started ruling,",
      "our town started falling apart into pieces. If only he were overthrown!",
    },
    ["What are you carrying?"]={
      "It's a piece of wood. The town {{green_light}}blacksmith{{white}} needs it to make his weapons.",
      "You can find him at the last house on the street.",
    },
    ["Where did he come from?"]={
      "Let's see, no one really knows where the Acorn King suddenly came from...",
      "I think it appeared around the time Cornelius first took over--oh god, maybe Cornelius has something to do with that Acorn!",
    },
    ["How do we defeat him?"]={
      "Hey man, I'm just a guy carrying around some lumber. What makes you think I know anything?",
    },
    ["Fantastic, even more acorns!"]={
      "I know right? Annoying little buggers, they'll get you if you don't keep your eyes peeled!",
    },
  },
}