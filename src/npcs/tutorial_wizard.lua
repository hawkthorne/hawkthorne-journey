-- inculdes

return {
  width = 32,
  height = 48, 
  greeting = 'Hello and welcome to {{teal}}The Test Level{{white}}!',
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
    { ['text']='i am done with you' },
    { ['text']='Where are the tutorials?' }, 
    { ['text']='Professor Duncan?' },
    { ['text']='Who are you?' },

  },
  talk_responses = {
    ["Who are you?"]={
      "I am a Tutorial Wizard!",
      "And definitely not a Christmas Wizard.",
    },
    ["Where are the tutorials?"]={
      "I'm a tutorial wizard not a tutorial conjurer.",
    },
    ["Professor Duncan?"]={
      "I do not have the slightest idea",
      "What you're talking about.",
    },
  },
}
