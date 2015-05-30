
local quests = {
 --retrieve alien object
  alien = {
    infinite = false,
    questName = 'Aliens! - Investigate Goat Farm',
    questParent = 'telescopejuan',
    collect = {name = 'alien_object', type = 'key'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "You will not believe what's been going on lately!",
      "Animals have recently been disappearing in the area and I've been seeing these weird alien lights at night!",
      "Just last night, I saw a bright object fall out of the sky into the goat farm nearby. Aliens, aliens!",
    },
    successPrompt = "Can you go investigate the goat farm and retrieve whatever alien object is there?",
    promptExtra = {
      "Excellent! But first, you're gonna need a key to get inside the farm.",
      "Talk to Juan with the sombrero, he owns the goat farm. Maybe you can persuade him to let you in.",
    },
    completeQuestFail = "The entrance to the goat farm is right beside Juan with the sombrero. Ask him for the key to get inside!",
    completeQuestSucceed = "That alien thing is really weird. Thanks for getting it for me though!",
    completed = "Man, that alien this is weird!",
    reward = {money = 50},
  },
}

return quests
