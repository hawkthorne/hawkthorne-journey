-- inculdes

return {
  width = 32,
  height = 48,   
  greeting = 'My name is {{red_light}}Sir Merek{{white}}, I became a knight to protect this {{olive}}village{{white}} from the dangers of the forest.',
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
    { ['text']='Any useful info for me?' },
    { ['text']='This town is in ruins!' },
    { ['text']='Talk about the Acorn King', ['option'] ={
        { ['text']='Who is he?'},
        { ['text']='Where did he come from?'},
        { ['text']='How do we defeat him?' },
        { ['text']='These damned acorns!' },
        --{ ['text']='Lets overthrow him?' },
        --{ ['text']='Get this town together!'},
    }},
  },
  talk_responses = {
    ["Who is he?"]={
      "This giant acorn monster with a crown on his head, fancies himself a king.",
      "He is known to terrorize any wayward travelers or villagers he comes across,",
    },
    ["Where did he come from?"]={
      "No idea really, he kind of popped out of nowhere a long time ago.",
      "Brought with him a bunch of those nasty little acorns, they've been infesting the forests ever since.",
    },
    ["How do we defeat him?"]={
      "There's nothing a good sword to the face can fix, you know what I'm saying?",
      "But really? I have no idea. Maybe some others in the village could tell you.",
    },
    ["This town is in ruins!"]={
      "It's that damned {{grey}}Hawkthorne{{white}}! He's a madman, that's what he is.",
      "Just sitting in that ivory tower of his, it's his fault we're in shambles like this.",
    },
    ["Any useful info for me?"]={
      "I hear {{grey}}Castle Hawkthorne{{white}} holds untold riches, if anyone could get to them.",
      "One of them, I hear, is a key that unlocks a fabled world called {{olive}}Greendale{{white}}.",
      "Now there's what I call an adventure.",
    },
    ["These damned acorns!"]={
      "Hear, hear, brother. This acorn problem is nuts.",
    },
  },
}