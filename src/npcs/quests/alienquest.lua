

local quests = {

  alienobject = {
    infinite = true,
    questName = 'Aliens! - Bring back alien technology from hostile aliens',
    questParent = 'frankie',
    collect = {name = 'alien_object2', type = 'key'},
    --prompt: 'You look very busy'
    giveQuestSucceed = {
      "You're probably wondering why I've called you, eh? Well, I'll explain...",
      "There's a huge, hidden group of {{blue_light}}aliens{{white}} hiding in the Valley of Laziness, who are secretly preparing for an invasion.",
      "I was one of them, until I fell in love with Mexican food and decided to prevent those other aliens from destroying this fine cuisine.",
      "Ever since, I've been fighting against those other aliens. The goat farm was my hideout for a while until I was discovered",
      "Before I escaped, I left behind a message in hopes that it would reach anyone other than those lazy citizens of Tacotown.",
    },
    successPrompt = "Adventurer, will you join me in my fight against the invading aliens?",
    promptExtra = {
      "Good, good. Your first task is to hijack an item from a group of alien soldiers up near the {{blue_light}}coast{{white}} to Village Forest.",
      "I found out that one of the alien soldiers is carrying an alien technology that I need for my plan to bring them down.",
      "I'll explain what I need the item for later. Be prepared for a fight! Good luck then.",
    },
    completeQuestFail = "The aliens are still camped up by the coast. I need the alien equipment that they're carrying!",
    completeQuestSucceed = "Thank you for getting rid of those potatoes!",
    reward = {affection = 50, money = 50},
  },

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
    reward = {affection = 100},
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
