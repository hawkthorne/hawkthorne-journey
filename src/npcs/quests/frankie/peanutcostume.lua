--well I'm a peanut bar, and I'm here to say

local quests = {
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
}

return quests
