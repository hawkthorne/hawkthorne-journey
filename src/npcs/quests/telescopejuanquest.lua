
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
      "Just last night, I saw a bright object fall out of the sky into the goat farm nearby. {{teal}}Aliens, aliens!{{white}}",
    },
    successPrompt = "Can you go {{red_light}}investigate the goat farm and retrieve whatever alien object is there?{{white}}",
    promptExtra = {
      "Excellent! But first, you're gonna need a key to get inside the farm.",
      "Talk to Juan with the {{purple}}purple sombrero{{white}}, he owns the goat farm. Maybe you can persuade him to let you in.",
    },
    completeQuestFail = "The entrance to the goat farm is right beside Juan with the {{purple}}purple sombrero{{white}}. Ask him for the key to get inside!",
    completeQuestSucceed = {
      "Ooh, this alien thing looks amazing. This is definite proof that aliens are among us!",
      "Here's some money for your troubles, thanks again!",
    },
    completed = "Man, that alien thing was weird!",
    reward = {money = 70},
  },
}

return quests
