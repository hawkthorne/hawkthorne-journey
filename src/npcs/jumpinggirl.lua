-- inculdes

return {
  width = 24,
  height = 48, 
  max_walk = 24,  
  animations = {
    default = {
      'loop',{'1-12,2'},.05,
    },
    walking = {
      'loop',{'1-12,2'},.05,
    },
  },

  walking = true,
  walk_speed = 10,
  busy = true,
  
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
  },
  talk_responses = {
   
  },
}