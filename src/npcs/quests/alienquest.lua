

local quests = {

  alienobject = {
    infinite = true,
    questName = 'Aliens! - Bring back alien technology from hostile aliens',
    questParent = 'alien',
    collect = {name = 'alien_object2', type = 'key'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "Alright, so listen up human. I need your help.",
      "There's a huge, hidden group of {{blue_light}}aliens{{white}} hiding in the Valley of Laziness, who are secretly preparing for an invasion.",
      "I was one of them, until I fell in love with Mexican food and decided to prevent those other aliens from destroying this fine cuisine.",
      "I ran away and hid myself in this farm, and ever since, I've been fighting against those other aliens. However, I can't do this by myself.",
    },
    successPrompt = "Earthling, would you like to have the honor of serving under me in {{teal}}my fight against the invading aliens?{{white}}",
    promptExtra = {
      "Good, good. Your first task is to {{blue_light}}hijack an item from a group of alien soldiers{{white}} camped up nearby.",
      "The aliens are camped up to the east of {{orange}}Tacotown{{white}}, on the way to the giant fence.",
      "I found out that one of the alien soldiers is carrying an alien technology that I need for my plan to bring them down.",
      "It's usually the blue {{blue_light}}Elite Alien{{white}} carrying important equipment, so target those guys first.",
      "I'll explain what I need the item for later. Be prepared for a fight, and try not to die eh?. Good luck then.",
    },
    completeQuestFail = "The aliens are still camped up to the east of {{orange}}Tacotown{{white}}. I need the alien equipment that they're carrying!",
    completeQuestSucceed = {
    "Wow, impressive! You fought off all those aliens? You are tougher than you look.",
    "Okay, I have another task for you. Talk to me when you're ready.",
    },
    reward = {affection = 1},
  },

  aliencamp = {
    infinite = false,
    questName = 'Aliens! - Attack alien camp and bring back alien technology',
    questParent = 'alien',
    collect = {name = 'alien_object3', type = 'key'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "Ughhhh...the things I would do for a burrito right now--oh shoot, you're back already?",
    },
    successPrompt = "So, you ready for the next task?",
    promptExtra = {
      "So there's an even bigger group of aliens camped up by the {{orange}}Hills{{white}} area, who are in possession of another important alien equipment.",
      "I'm not gonna lie, this alien camp is stacked to the brim. It's gonna be extremely dangerous, so be prepared!",
      "It's the same drill as before. It's usually the {{blue_light}}Elite Alien{{white}} carrying important equipment, so target those guys first.",
      "Oh, you wanna know what I want to do with this alien technology? Well, that I'll tell you if you come back alive. Now go!",
    },
    completeQuestFail = "The aliens are still camped up in the {{orange}}Hills{{white}} area. Chop chop!",
    completeQuestSucceed = {
    "Ooh, I almost forgot to take with me the device you brought!",
    },
    reward = {affection = 1},
  },
  regroup = {
    infinite = false,
    skipPrompt = true,
    questName = 'Aliens! - Regroup with the alien at Chili Fields',
    questParent = 'alien',
    giveQuestSucceed = {
      "Damn it, you stupid human! The aliens followed you back here! {{red_light}}We're under attack!{{white}}",
      "Survival first, come meet me at the {{red_light}}Chili Fields{{white}}, we gotta regroup!",
    },
    successPrompt = "Regroup in the {{red_light}}Chili Fields{{white}}!",
    completeQuestFail = "What the hell are you still doing here? Go hold those aliens off!",
  },
  qfo = {
    infinite = false,
    questName = 'Aliens! - Destroy the QFO!',
    questParent = 'alien',
    giveQuestSucceed = {
      " ",
    },
    successPrompt = "Do you want to take on the {{orange}}QFO{{white}}?",
    completeQuestFail = "What the hell are you still doing here? Go hold those aliens off!",
    completeQuestSucceed = {
      "You...you've done it! You've defeated the {{orange}}QFO{{white}}! Now I can eat Mexican food in peace, forever!",
      "As a token of thanks, you can have my standard issue {{blue_light}}alien pistol{{white}}, you'll need it more than I do. Here's some gold as well.",
      "Whenever you run out of ammo for the pistol come back to me and I will sell some to you.",
      "It was nice working with you partner. We've defeated them!",
    },
    reward = {money = 150},
  },
}

return quests
