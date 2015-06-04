-- hildaquest.lua

local quests = {
  boulders = {
    infinite = false,
    questName = 'Collect boulders for the Lotus Cult member',
    questParent = 'Lotus Cult member',
    collect = {name = 'boulder', type = 'material'},
    --prompt: 'flowers'
    giveQuestSucceed = {
        "I've been working on a new potion recently, but I'm missing a key ingredient.",
        "I need a {{teal}}boulder{{white}} to act as a reactant, but it looks like I'm all out!",
        "It would be great if you could bring some for me, I would of course reward you!",
      },
    successPrompt = "Do you want to collect boulders for {{red_light}}the Cult Member{{white}}?",
    completeQuestFail = "Have you collected any boulders yet? It can be created by combining two {{olive}}stones{{white}} together. Stones can be created by combining two {{teal}}rocks{{white}} together.",
    completeQuestSucceed = "Thank you so much! I can finish my potion now!",
    reward = { affection = 300},
  },
}

return quests
