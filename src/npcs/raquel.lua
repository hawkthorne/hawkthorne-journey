-- inculdes
local Dialog = require 'dialog'

return {
  width = 24,
  height = 67,
  animations = {
    default = {
      'once',{'2,1'},.5,
    },
    neutral = {
      'once',{'2,1'},.2,
    },
    happy = {
      'once',{'1,1'},.5,
    },
    sad = {
      'once',{'3,1'},.15,
    }
  },
  stare = false,

  talk_items = {
  { ['text']='i am done with you' },
  { ['text']='Current emotion level' },
  { ['text']="I'm thinking about...", ['option']={
    { ['text']='puppy parade'},
    { ['text']='Kickpuncher'},
    { ['text']='Inspector Spacetime'},
    { ['text']='the study group'},
    { ['text']='Dictator Chang'},
    { ['text']='buttered noodles'},
    { ['text']="Vaughn's tiny nipples"},
    { ['text']="paintball"},
    { ['text']="City College"},
    { ['text']="Cougar Town"},
    { ['text']="pillow and blanket forts"},
    { ['text']="dancing"},
    { ['text']="psychology experiments"},
    { ['text']="Alan Connor"},
    { ['text']="LeVar Burton"},
    { ['text']="Annie's Boobs"},
    { ['text']="Glee Club"},
    { ['text']="gas leaks"},
    { ['text']="Professor Cornwallis"},
    { ['text']="Yogurtsburgh"},
    { ['text']="Ass Crack Bandit"},
    { ['text']="#sixseasonsandamovie"},
    { ['text']="Magnitude"},
    { ['text']="Natalie is Freezing"},
    { ['text']="norwegian Troll doll"},
    { ['text']="Adderall"},
    { ['text']="Chimpan-Zzz's"},
    { ['text']="Daybreak"},
    
  }},
  { ['text']='How does this work?' },
  },
  talk_commands = {
    ['Current emotion level'] = function (npc, player)
      local affection = player.affection.raquel or 0
      Dialog.new("My current emotion level is " .. affection .. ".", function()
        npc.menu:close(player)
      end)
    end,
    ['puppy parade'] = function (npc, player)
      npc:affectionUpdate(50)
      player:affectionUpdate('raquel',50)
    end,
    ['Kickpuncher'] = function (npc, player)
      npc:affectionUpdate(50)
      player:affectionUpdate('raquel',50)
    end,
    ['Inspector Spacetime'] = function (npc, player)
      npc:affectionUpdate(100)
      player:affectionUpdate('raquel',100)
    end,
    ['the study group'] = function (npc, player)
      npc:affectionUpdate(200)
      player:affectionUpdate('raquel',200)
    end,
    ['Dictator Chang'] = function (npc, player)
      npc:affectionUpdate(-100)
      player:affectionUpdate('raquel',-100)
    end,
    ['buttered noodles'] = function (npc, player)
      npc:affectionUpdate(50)
      player:affectionUpdate('raquel',50)
    end,
    ["Vaughn's tiny nipples"] = function (npc, player)
      npc:affectionUpdate(100)
      player:affectionUpdate('raquel',100)
    end,
    ['paintball'] = function (npc, player)
      npc:affectionUpdate(200)
    end,
    ['City College'] = function (npc, player)
      npc:affectionUpdate(-200)
      player:affectionUpdate('raquel',-200)
    end,
    ['Cougar Town'] = function (npc, player)
      npc:affectionUpdate(50)
      player:affectionUpdate('raquel',50)
    end,
    ['pillow and blanket forts'] = function (npc, player)
      npc:affectionUpdate(100)
      player:affectionUpdate('raquel',100)
    end,
    ['dancing'] = function (npc, player)
      npc:affectionUpdate(50)
      player:affectionUpdate('raquel',50)
    end,
    ['psychology experiments'] = function (npc, player)
      npc:affectionUpdate(-50)
      player:affectionUpdate('raquel',-50)
    end,
    ['Alan Connor'] = function (npc, player)
      npc:affectionUpdate(-50)
      player:affectionUpdate('raquel',-50)
    end,
    ['LeVar Burton'] = function (npc, player)
      npc:affectionUpdate(100)
      player:affectionUpdate('raquel',100)
    end,
    ["Annie's Boobs"] = function (npc, player)
      npc:affectionUpdate(50)
      player:affectionUpdate('raquel',50)
    end,
    ['Glee Club'] = function (npc, player)
      npc:affectionUpdate(-100)
      player:affectionUpdate('raquel',-100)
    end,
    ['gas leaks'] = function (npc, player)
      npc:affectionUpdate(-200)
      player:affectionUpdate('raquel',-200)
    end,
    ['Professor Cornwallis'] = function (npc, player)
      npc:affectionUpdate(-50)
      player:affectionUpdate('raquel',-50)
    end,
    ['Yogurtsburgh'] = function (npc, player)
      npc:affectionUpdate(50)
      player:affectionUpdate('raquel',50)
    end,
    ['Ass Crack Bandit'] = function (npc, player)
      npc:affectionUpdate(-300)
      player:affectionUpdate('raquel',-300)
    end,
    ['#sixseasonsandamovie'] = function (npc, player)
      npc:affectionUpdate(200)
      player:affectionUpdate('raquel',200)
    end,
    ['Magnitude'] = function (npc, player)
      npc:affectionUpdate(100)
      player:affectionUpdate('raquel',100)
    end,
    ['Natalie is Freezing'] = function (npc, player)
      npc:affectionUpdate(50)
      player:affectionUpdate('raquel',50)
    end,
    ['norwegian Troll doll'] = function (npc, player)
      npc:affectionUpdate(-100)
      player:affectionUpdate('raquel',-100)
    end,
    ['Adderall'] = function (npc, player)
      npc:affectionUpdate(-100)
      player:affectionUpdate('raquel',-100)
    end,
    ["Chimpan-Zzz's"] = function (npc, player)
      npc:affectionUpdate(-50)
      player:affectionUpdate('raquel',-50)
    end,
    ['Daybreak'] = function (npc, player)
      npc:affectionUpdate(100)
      player:affectionUpdate('raquel',100)
    end,
    
  },

  talk_responses = {
    ['How does this work?']={
      "Think about something that will generate a burst of emotion.",
    },
  
  },

  update = function(dt, npc, player)
    local affection = player.affection.raquel or 0

    if affection >= 1000 then
      npc.state = "happy"
      npc.db:set('raquel', true)
      npc.married = true

      --if npc.married == false then
        --Dialog.new("It worked!", function()
          --npc.db:set('raquel', true)
          
          --npc.menu:close(player)
        --end)
      --end
    elseif affection < 0 then
      npc.state = "sad"
    else
      npc.state = "default"
    end
  end,
}
