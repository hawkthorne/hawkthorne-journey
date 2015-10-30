return {
  width = 48,
  height = 48,
  greeting = 'Oh man, {{red_dark}}shmitty alert!{{white}}',    
  nocommands = "We don't take commands from shmitty.  Uh-duh!",
  animations = {
    default = {
      'loop',{'1,1','4,1','1,1','1,1','1,1','1,1','1,1','2,1','1,1','1,1','1,1','1,1','3,1','1,1','1,1','1,1'},.2,
    },

  },
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Alright, look kids...' },
    { ['text']='You kids are horrible.' },
    { ['text']='Uh-duh!', ['option']={
      { ['text']='Uh-duh!' },
      { ['text']='Uh-duh!' },
      { ['text']='Uh-duh!' },
      { ['text']='Uh-duh!' },
    }},
  },
  talk_responses = {
    ["Alright, look kids..."]={
      "Shmitty!!",
      "Get out of here you loser.",
    },
    ["Uh-duh!"]={
      "Uh-duhhhh!",
    },
    ["You kids are horrible."]={
      "Says the loser attending a community college. Shmitty!",
    },
  },
}