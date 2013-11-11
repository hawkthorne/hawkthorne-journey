-- inculdes

return {
  width = 27,
  height = 42,   
  greeting = 'Huh? What did ya say?',
  animations = {
    default = {
      'loop',{'1,1'},.5,
    },
    walking = {
      'loop',{'1,2','2,2','3,2'},.2,
    },
  },

  walking = true,
  walk_speed = 10,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Pardon?' },
    { ['text']='Say again?' },
    { ['text']='Talk about the Acorn King' },
  },
  talk_responses = {
    ["What?"]={
      "Speak up! I can't hear a thing you're sayin'!",
    },
    ["Say again?"]={
      "Speak up! I can't hear a thing you're sayin'!",
    },
    ["Talk about the Acorn King"]={
      "Speak up! I can't hear a thing you're sayin'!",
    },
  },
}