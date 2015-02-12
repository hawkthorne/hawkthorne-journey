-- hildaquest.lua

local quests = {
  oldman = {
    questName = 'collect flowers',
    questParent = 'hilda',
    --prompt: 'flowers'
    giveQuestSucceed = {
    "Oh thank you, thank you so much! My name is Tilda, I used to live in the village.",
    "When I was forced into marrying a man I did not love, I fled deep into these woods and now I fend for myself in the winderness.",
    "Just last week while I was fetching water from a stream, I heard a great rumble as I saw the Acorn King himself walking through the woods.",
    "He was angrily muttering to himself about a plan to destroy the town and all of its people, and I fled in fear before I could hear the rest.",
    "Though I was banished, my family who I still dearly love including my sister Hilda live in the Village, and I cannot bear to see it destroyed!",
    "Someone must do something! At the Village, there is an old man who is wise in his years. He must surely know a way to slay the King of Acorns.",
    "I would do it myself but if I were to return, they would likely think I turned into one of those tree-hugging hippies and burn me at the stake",
    "Please, you must hurry!",
      },
    successPrompt = "Accept quest {{red_light}}'Acorn Slayer'{{white}}?",
    completeQuestFail = "Please, you must hurry!",
    completeQuestSucceed = "My goodness, these flowers are beautiful!  Thank you so very much!",
    reward = {affection = 300},
  },
}

return quests
