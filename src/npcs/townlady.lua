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
  foreground = true,

  enter = function(npc, previous)
    local show = npc.db:get('acornKingVisible', false)
    local acornDead = npc.db:get("bosstriggers.acorn", true)
    local bldgburned = npc.db:get('house_building_burned', false )
    if show == true or bldgburned == true then
      npc.state = 'hidden'
      npc.collider:setGhost(npc.bb)
    end
  end,

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
    ["Pardon?"]={
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