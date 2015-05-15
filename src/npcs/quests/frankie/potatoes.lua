--collecting potatoes quest for Frankie

local quests = {
  potatoes = {
    infinite = true,
    questName = 'Save Greendale - Collect potatoes',
    questParent = 'frankie',
    collect = {name = 'potato', type = 'material'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "Someone's been leaving {{olive}}potatoes{{white}} on our rooftops as a weird prank of some sorts.",
    },
    successPrompt = "For every {{olive}}potato{{white}} you bring me, I'll give you 50 coins. How does that sound?",
    completeQuestFail = "Found those {{olive}}potatoes{{white}} yet? They're still on the roofs I hear.",
    completeQuestSucceed = "Thank you for getting rid of those potatoes!",
    reward = {affection = 30, money = 50},
  },
}

return quests
