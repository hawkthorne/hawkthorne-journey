-- juanitaquest.lua

local quests = {
  alcohol = {
    infinite = true,
    questName = 'Help Juanita pick up empty bottles',
    questParent = 'juanita',
    collect = {name = 'alcohol', type = 'consumable'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "Of course I am! Look at all this mess I have to clean up! It sucks being a cleaning person around these parts.",
      "You know, I am pretty darn sure that I'm the only one who does an honest day's work in this town.",
    },
    successPrompt = "Can you help me clean up by picking up some bottles?",
    completeQuestFail = "This place is filthy!",
    completeQuestSucceed = "Thanks for helping clean up! The town looks so much nicer!",
    reward = {affection = 100},
  },
}

return quests
