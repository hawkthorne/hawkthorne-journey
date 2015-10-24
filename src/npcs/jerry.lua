local Dialog = require 'dialog'
local prompt = require 'prompt'
local Quest = require 'quest'
local quests = require 'npcs/quests/frankiequest'

return {
  width = 32,
  height = 48,
  greeting = 'Hey-oh! I am the janitor around {{olive}}Greendale{{white}}, you can call me {{red_light}}Jerry{{white}}.',
  animations = {
    default = {
      'loop',{'1,1','11,1'},.5,
    },
    walking = {
      'loop',{'1,1','2,1','3,1'},.2,
    },
  },

  walking = true,
  max_walk = 380,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Hello!' },
    { ['text']='Listen to me.' },
    { ['text']='Why is the pool closed?', freeze = true },
  },
  talk_responses = {
    ["Hello!"]={
      "Damn man! Ain't you ever heard of knocking?!",
    },
    ["Listen to me."]={
      "Toilets and sinks...REAL THINGS!",
      "Things that people always use and always need to get fixed! You could be a plumber!,",
    },
  },
  talk_commands = {
    ["Why is the pool closed?"]=function(npc, player)
      if player.quest == 'Save Greendale - Find out what the delay with pool repairs is' then
        if  player.inventory:hasMaterial('wires') and player.inventory:hasWeapon('wrench') then
            player.freeze = false
            player.inventory:removeManyItems(1, {name='wires',type='material'})
            player.inventory:removeManyItems(1, {name='wrench',type='weapon'})
            Quest.removeQuestItem(player)
            Quest:activate(npc, player, quests.poolreturn)
            npc.menu:close(player)
          
        else
          Dialog.new(quests.poolreturn.completeQuestFail, function()
            player.freeze = false
            npc.menu:close(player)
          end)
        end
      else
        Dialog.new("There's an electric current running through the pool at the moment. Or I don't know, I'm a plumber not an electrician, pool's just not safe, okay?", function()
          player.freeze = false
          npc.menu:close(player)
        end)
      end
    end,
  },
}