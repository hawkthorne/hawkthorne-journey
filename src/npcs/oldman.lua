local Timer = require 'vendor/timer'
local Dialog = require 'dialog'

return {
  width = 32,
  height = 32,  
  greeting = 'Bah! Go away.',
  animations = {
    default = {
      'loop',{'1,1','2,1'},.5,
    },
  },
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Any useful info for me?' },
    { ['text']='This town is in ruins!' },
    { ['text']='Hello!' },
  },
  talk_commands = {
    ['Hello!']=function(npc, player)
      npc.walking = false
      npc.stare = false
        
      if player.quest~='To Slay An Acorn - Collect Mushroom for the Old Man' and not 'To Slay An Acorn - Talk to Old Man in Village' then
        Dialog.new("Piss off.", function()
          --npc.walking = true
          npc.menu:close(player)
        end)
      elseif player.quest=='To Slay An Acorn - Collect Mushroom for the Old Man' and not player.inventory:hasMaterial('greenmushroom') then
        Dialog.new("Huh, didn't get that mushroom yet? Well, chop-chop young man, the world ain't free.", function()
          --npc.walking = true
          npc.menu:close(player)
        end) 
      elseif player.quest=='To Slay An Acorn - Collect Mushroom for the Old Man' and player.inventory:hasMaterial('greenmushroom') then
        script2 = {
          "Good, good, this mushroom will do nicely, great work...",
          "Now piss off would ya?",
          "Oh I suppose a promise is a promise...alright fine, I'll tell you of a local legend around these parts.",
          "Long ago, when the acorns in the were peaceful and not so angry all the time, the Villagers opened up a mine in the mountains.",
          "Business was booming, and the Village was thriving. However, the tyrant Hawthorne unfortunately soon got wind of the news.",
          "Fearful of the Village's newfound riches, he quickly put a stop to it by enchanting the local acorns to become aggressive, and angry.",
          "Legends say that an alchemist created a special weapon that can slay the Acorn King and hid it in the mines, before fleeing from Hawthorne's agents.",
          "That Hawthorne, cursed be his name, enchanted the Acorn King to be invincible in his raging state, and the weapon is the only way to slay him.",
          "I don't know if that story is true or not, but that is your best bet if you want to kill the Acorn King.",
          "Now when the acorns showed up, the mines were closed down and locked, and you'll need a key to get inside. Fortunately, I have the key.",
          "Unfortunately, it's not that simple, the world ain't easy. You're going to need a second set of keys to get inside the room where the weapon is hidden.",
          "The key to the weapons room is hidden deep in the mines, you'll have to venture inside to find it. Don't die eh? The mines are full of dangers from years of disuse.",
          "Now that's the easy part. The weapons room itself is guarded by a fearsome, indestrustible creature. Don't try fighting it, I'd advise you to sneak behind it.",
          "You hear? That beast right there will mess you up, don't play a hero; just get your ass in and out quickly and pray you're not seen by the monster.",
          "Here's the key to the mines. Now get out of here.",
        }
        Dialogue = Dialog.create(script2)
        Dialogue:open(function()
          Dialog.finished = true
          player.freeze = false 
        end)
        player.inventory:removeManyItems(1,{name='greenmushroom',type='material'})
        player.inventory:addItem({name='mines',type='key'}, true)
        player.quest = 'To Slay An Acorn - Enter the Mines and Obtain First Set of Keys'
        npc.menu:close(player)
      else
        script = {
          "Huh? You say you want to slay the Acorn King? Hah, you'd be a fool the challenge him! I suggest you piss off stranger.",
          "You are serious? You say he plans on destroying this town? You are as crazy as those filthy, long-haired hippies living high up in the mountains.",
          "Get out of here young man, go poke your nose into businesses elsewhere!",
          "...unless...",
          "The world isn't free, you know what I'm saying? Suppose I did know a way to slay the Acorn King, what's in it for me?",
          "There is a secret pathway that leads above the treetops in the forests right outside the town, at the base of the mountains.",
          "There is a green, special type of mushroom that only grows at the very top of the trees that's worth quite a lot...",
          "Now, if you bring me that special mushroom, I'll consider helping out with your foolish quest.",
        }
        Dialogue = Dialog.create(script)
        Dialogue:open(function()
          Dialog.finished = true
          player.quest = 'To Slay An Acorn - Collect Mushroom for the Old Man'
          player.freeze = false 
        end)

        npc.menu:close(player)

        player.freeze = true
        npc.fixed = result == 'Yes'
        npc.prompt = nil
        Timer.add(2, function()
          npc.fixed = false
        end)
      end
    end,
  },
  talk_responses = {
    ["This town is in ruins!"]={
      "Piss off.",
    },
    ["Any useful info for me?"]={
      "Piss off, would ya?",
    },
  },
}