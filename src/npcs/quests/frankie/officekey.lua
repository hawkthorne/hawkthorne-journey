

local quests = {
  officekey = {
    infinite = false,
    questName = 'Save Greendale - Look for the lost office key',
    questParent = 'frankie',
    collect = {name = 'office_key', type = 'key'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "Last night, the Dean apparently lost the spare office key while stalking a certain Mr. Winger.",
      "Sometimes, I wonder which buffoon put the Dean in charge.",
    },
    successPrompt = "Can you go look for the lost key? It should still be on campus somewhere.",
    completeQuestFail = "Have you found the key yet? It should hopefully still be on campus somewhere.",
    completeQuestSucceed = "Thank you for retrieving the key!",
    reward = {affection = 140},
  },
}

return quests
