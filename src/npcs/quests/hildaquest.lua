-- hildaquest.lua

local quests = {
  flowers = {
    infinite = true,
    questName = 'Collect Flowers for Hilda',
    questParent = 'hilda',
    collect = {name = 'flowers', type = 'material'},
    --prompt: 'flowers'
    giveQuestSucceed = {
        "I love {{teal}}flowers{{white}}!",
        "I used to collect {{teal}}flowers{{white}} from the {{olive}}forest{{white}} beyond the {{green_light}}blacksmith{{white}} but ever since {{grey}}Hawkthorne{{white}} started ruling the {{olive}}forests{{white}} haven't been safe.",
        "I would be so happy if someone could pick me some!",
      },
    successPrompt = "Do you want to collect flowers for {{red_light}}Hilda{{white}}?",
    completeQuestFail = "Have you found any flowers? Try looking beyond the town.",
    completeQuestSucceed = "My goodness, these flowers are beautiful! Thank you so very much!",
    reward = {affection = 300},
  },
}

return quests
