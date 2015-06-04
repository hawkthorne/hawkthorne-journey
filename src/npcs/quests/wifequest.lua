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
        "Just on the other side of the mountains on the way to {{orange}}Valley of Laziness{{white}}, there's a hidden door leading to the treetops. you may have noticed {{teal}}flowers{{white}} growing beside the road. from the {{olive}}forest{{white}} beyond the {{green_light}}blacksmith{{white}} but ever since {{grey}}Hawkthorne{{white}} started ruling the {{olive}}forests{{white}} haven't been safe.",
        "Recently, an invasive species of {{blue_light}}blue mushrooms{{white}} have begun growing there, threatening local plants!",
      },
    successPrompt = "Could you go remove those mushrooms on the treetops? I will pay you handsomely!",
    completeQuestFail = "The {{blue_light}}blue mushrooms{{white}} are in the treetops, on the way to {{orange}}Valley of Laziness{{white}}! Please remove them for me!",
    completeQuestSucceed = "Thank you for removing those mushrooms! You can probably sell those in shops in {{orange}}Valley of Laziness{{white}}.",
    reward = {money = 300},
  },
}

return quests
