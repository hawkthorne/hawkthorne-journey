-- hildaquest.lua

local quests = {
  mushroom = {
    infinite = false,
    questName = 'Remove invasive mushrooms in the treetops',
    questParent = 'blacksmith_wife',
    removeall = {name = 'bluemushroom', level = 'village-treeline'},
    --prompt: 'flowers'
    giveQuestSucceed = {
        "Adventurer! If you had time, I was wondering if you could help me out with a small problem?",
        "Just on the other side of the mountains on the way to {{orange}}Valley of Laziness{{white}}, there's a hidden door leading to the treetops.",
        "Recently, an invasive species of {{blue_light}}blue mushrooms{{white}} have begun growing there, threatening local plants!",
      },
    successPrompt = "Could you go remove ALL of those {{blue_light}} mushrooms{{white}} on the treetops? I will pay you handsomely!",
    completeQuestFail = "The {{blue_light}}blue mushrooms{{white}} are in the treetops, on the way to {{orange}}Valley of Laziness{{white}}! Please remove them for me!",
    completeQuestSucceed = "Thank you for removing those mushrooms! You can probably sell those in shops in {{orange}}Valley of Laziness{{white}}.",
    reward = {money = 300},
  },
}

return quests
