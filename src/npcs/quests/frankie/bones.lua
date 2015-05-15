--bones

local quests = {
  bones = {
    infinite = false,
    questName = 'Save Greendale - Remove bones from parking lot',
    questParent = 'frankie',
    removeall = {name = 'bone', level = 'parking-lot'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "The janitorial staff reported that the school parking lot is currently littered with bones of unknown origins.",
      "I do not care nor do I want to find out where those bones came from, but we need to clean them up.",
    },
    successPrompt = "Can you remove the bones from the parking lot?",
    completeQuestFail = "The parking lot is still littered with those creepy bones!",
    completeQuestSucceed = "Thank you for helping clean up the parking lot! Even for Greendale, that was creepy.",
    reward = {affection = 120},
  },
}

return quests
