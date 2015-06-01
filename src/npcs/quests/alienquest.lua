

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
    successPrompt = "Earthling, would you like to have the honor of serving under me in my fight against the invading aliens?",
    promptExtra = {
      "Good, good. Your first task is to hijack an item from a group of alien soldiers up near the {{blue_light}}coast{{white}} to Village Forest.",
      "I found out that one of the alien soldiers is carrying an alien technology that I need for my plan to bring them down.",
      "It's usually the {{blue_light}}Elite Alien{{white}} carrying important equipment, so target those guys first.",
      "I'll explain what I need the item for later. Be prepared for a fight, and try not to die alright? Good luck then.",
    },
    completeQuestFail = "The aliens are still camped up by the coast. I need the alien equipment that they're carrying!",
    completeQuestSucceed = {
    "Wow, impressive! You fought off all those aliens? You are tougher than you look.",
    "Alright, I got another task for you. Talk to me when you're ready.",
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
    successPrompt = "Alright, you ready for the next task?",
    promptExtra = {
      "Okay, listen up underlin--oh alright fine, I guess you're my partner.",
      "So there's an even bigger group of aliens camped up by the {{orange}}Hills{{white}} area, who are in possession of another important alien equipment.",
      "I'm not gonna lie, this alien camp is stacked to the brim. It's gonna be extremely dangerous, so be prepared!",
      "Ahh, don't look at me like that. I have complete faith that you'll make it out alive with most of your limbs. Cheer up eh?",
      "It's the same drill as before. It's usually the {{blue_light}}Elite Alien{{white}} carrying important equipment, so target those guys first.",
      "Oh, you wanna know what I want to do with this alien technology? Well, that I'll tell you if you come back alive. Now go!",
    },
    completeQuestFail = "The aliens are still camped up in the {{orange_light}}Hills{{white}} area. Chop chop!",
    completeQuestSucceed = {
    "Holy burrito",
    "Alright, I got another task for you. Talk to me when you're ready.",
    },
    reward = {affection = 1},
  },

  peanutcostume = {
    infinite = false,
    questName = 'Save Greendale - Find peanut bar costume receipt',
    questParent = 'frankie',
    collect = {name = 'receipt', type = 'key'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "So I have discovered that the Dean used school expenses to purchase an exorbitantly priced peanut bar costume.",
      "I'm hoping to find the receipt for the costume so I can get a refund before it's too late.",
      "The receipt should be lying around somewhere in the Dean's closet, I need someone to go find it.",
    },
    successPrompt = "Can you go retrieve the receipt for Dean's stupid costume?",
    completeQuestFail = "Have you found the receipt yet? It should be somewhere inside the Dean's closet.",
    completeQuestSucceed = "Thank you for retrieving the receipt! Hopefully it's not too late to get our money back...",
    reward = {affection = 200},
  },

  officekey = {
    infinite = false,
    questName = 'Save Greendale - Look for the lost office key',
    questParent = 'frankie',
    collect = {name = 'office_key', type = 'key'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "Last night, the Dean lost the spare office key in the Administration building while stalking a certain Mr. Winger.",
      "Sometimes, I wonder which buffoon put the Dean in charge.",
    },
    successPrompt = "Can you go look for the lost key? It should still be on campus somewhere.",
    completeQuestFail = "Have you found the key yet? It should hopefully still be on campus somewhere.",
    completeQuestSucceed = "Thank you for retrieving the key!",
    reward = {affection = 140},
  },
  pool = {
    infinite = false,
    questName = 'Save Greendale - Find out what the delay with pool repairs is',
    questParent = 'frankie',
    giveQuestSucceed = {
      "The Borchert Hall pool has been closed for weeks for repairs, but there seems to be no progress being made!",
    },
    successPrompt = "Could you go find out what the delay is?",
    completeQuestFail = "Please go find out what is taking so long with the pool repairs!",
  },
  poolreturn = {
    infinite = false,
    questName = 'Save Greendale - Return back to Frankie',
    questParent = 'frankie',
    completeQuestSucceed = "Thank you for getting the repair guys back to work again! Hopefully the pool should be back up and running.",
    completeQuestFail = {
      "Well, the pool is actually somehow electrified at the moment. We'd fix it, but we're running low on some supplies.",
      "We need a {{orange}}wrench{{white}} and some {{orange}}wires{{white}} to make the repairs, but we got nothing in this damn school.",
      "I remember I lost a wrench working in the Health Center vents some time ago, and there may be some spare wires in the Classroom buildings basement.",
      "Of course, we don't get paid enough to actually go looking for those materials, so here we are, sitting around for the electricity to run out.",
    },  
    reward = {affection = 200, money = 50},
  },
  dianemail = {
    infinite = false,
    questName = 'Save Greendale - Mail Diane',
    questParent = 'frankie',
    collect = {name = 'office_key', type = 'key'},
    giveQuestSucceed = {
      "I have an important document that I need to send to a certain Diane.",
      "I would send an e-mail, but there is some trouble with campus wi-fi and the IT lady is nowhere to be seen.",
    },
    successPrompt = "Could you deposit this document into the mailbox? And no montages!",
    completeQuestFail = "Have you deposited it into the mailbox yet? The mailbox is at the west end of the campus. And no wasting time with montages!",
  },
  dianereturn = {
    infinite = false,
    questName = 'Save Greendale - Return to Frankie',
    questParent = 'frankie',
    completeQuestSucceed = "Thank you for depositing the mail!",
    reward = {affection = 50},
  },
}

return quests
