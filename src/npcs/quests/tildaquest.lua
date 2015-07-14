

local quests = {

  slay_acorn = {
    questName = 'To Slay An Acorn - Ask Around the Village about the Acorn King',
    questParent = 'Tilda',
    giveQuestSucceed = {
      "Please adventurer, I fear there is a sinister plot going on in these woods, one that may result in the very destruction of the Village."
    },
    successPrompt = "Will you not help me?",
    promptExtra = {
      "Oh thank you, thank you so much! My name is Tilda, I used to live in the village.",
      "When I was forced into marrying a man I did not love, I fled deep into these woods and now I fend for myself in the wilderness.",
      "Just last week while I was fetching water from a stream, I heard a great rumble as I saw the Acorn King himself walking through the woods.",
      "He was angrily muttering to himself about a plan to destroy the town and all of its people, and I fled in fear before I could hear the rest.",
      "Though I was banished, my family I still dearly love including my sister Hilda live in the Village, and I cannot bear to see it destroyed!",
      "I must prevent that. Though I do not know how, if you ask around at the {{olive}}Village{{white}} there must be someone who knows how to defeat the Acorn King.",
      "I would do it myself but if I were to return, they would likely think I turned into one of those tree-hugging hippies and burn me at the stake.",
      "Please, you must hurry!",
    },
    completeQuestFail = "Have you talked to the villagers yet? Try the elderly residents, they must know a few things.",
  },
  explore_mines = {
    questName = 'To Slay An Acorn - Explore the Mines for a Map to the Acorn King',
    questParent = 'Tilda',
    giveQuestSucceed = {
      "Huh?"
    },
    successPrompt = "You say the Acorn King plans on destroying this town?",
    promptExtra = {
      "You are as crazy as those filthy, long-haired hippies living high up in the mountains.",
      "Get out of here young man, my life is hard enough without you crazy hipies stirring trouble up!",
      "Alright, fine, I suppose there's no harm in indulging you in your crazy hippie-talk. So you want to know how to defeat the Acorn?",
      "In the {{orange}}abandoned mine{{white}} up in the mountains, is a local cult who are said to worship Cornelius and his creatures.",
      "It's supposed to contain numerous secrets such as the map to the Acorn King's hideout and ways to defeat him.",
      "Now I don't know if the rumors are true or not, but it's definitely worth checking out.",
      "Alright, now get out of my sight, I've got better things to be doing than talking to you.",
    },
    completeQuestFail = {
      "The map to the Acorn King's hideout is in the mines with the cultists?",
      "To my east is the entrance to the mines. I hear it is a dangerous place, bring a weapon and be ready for trouble!",
      },
  },
  find_hermit = {
    questName = 'To Slay an Acorn - Find the Old Hermit at Stonerspeak',
    questParent = 'Tilda',
    giveQuestSucceed = {
      "What did you find in the mines?"
    },
    successPrompt = "The map is gone?!?",
    promptExtra = {
      "That is troubling news, how will the Acorn King be defeated now?",
      "Wait...I have one more idea.",
      "At the very top of the mountain is {{green_light}}Stonerspeak{{white}}, the floating rocks in the clouds where the hippies live.",
      "At the very edge of that {{green_light}}Stonerspeak{{white}} there is an old hermit who lives in recluse. He is very old and wise.",
      "If there is anybody that has any information on how to defeat the Acorn King, it is the hermit.",
      "However, the path to {{green_light}}Stonerspeak{{white}} is extremely perilous. I was afraid to ask of you to do this but it is the only way.",
      "Please, you must hurry!",
    },
    completeQuestFail = "The hermit lives at the top of Stonerspeak. You must find him and ask for his aid!",
  },
  collect_berries = {
    questName = 'To Slay An Acorn - Collect the Special Berry for the Hermit',
    questParent = 'Tilda',
    completeQuestFail = {
      "The hermit lives at the top of Stonerspeak. You must find him and ask for his aid!",
      },
  },
}

return quests
