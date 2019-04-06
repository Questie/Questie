# FAQ:

# How do I move the QuestieTracker and QuestArrow?

Hold down CTRL + Shift + Hold Left Mouse Button + Drag

# I get an error: `attempt to index global 'QuestieConfig' (a nil value)`

This can be caused by upgrading from an older version of Questie or using it for the first time before a SavedVariables can be properly created. Please use `/questie clearconfig` while in game to clear/reset your config file. This has to be done for every character. To make sure the changes are correctly written to the drive restart the WoW client afterwards.

# I play on a non-English server and Questie isn't working. How come?

Currently, Questie only supports English servers/clients. Language support is currently **NOT** being worked on. If you are interested in working on it create an issue on GitHub or contact the developers on our Discord server.

# I can't seem to get my quests to appear in the tracker automatically.

For those not running EQL3 or some other QuestLog mod. If you prefer the default wow QuestLog and Tracker that's fine but it's very limited. For example, if a quest doesn't have any objectives to "track" then it won't appear in the quest tracker and no Quest Arrow will be available for it. Additionally, quests will not automatically be tracked by the default WoW quest tracker. The way that it works is that if you have the option enabled in the games Interface Options --> "Automatic Quest Tracking" then yes, it will auto track a quest with an objective once you OBTAIN the first quest item. Then it will appear automatically in the list unless you manually Shift+Click the quest in the QuestLog but again, only if there is a "trackable" objective. Unlike EQL3 or other QuestLog/QuestTracker mods where pretty much anything is trackable, these quests will appear in the Questie QuestTracker. If the quest appears then map coordinates are cached and this allows the QuestieArrow to hook into the position and give you an arrow.

# Why isn't the QuestieArrow appearing?
You have to click on an objective on the Minimap, Worldmap or the quest in the QuestieTracker. If a quest has never been tracked it won't appear until after it has appeared at least once in the QuestieTracker. If you disable the QuestieTracker, the QuestieArrow will not work.

# "My Dead Corpse"? Do you even English, bro?

The "My Dead Corpse" is kind of an inside joke from the original Closed Beta for Vanilla WoW days. Back then I was playing Alliance exclusively and the famous Horde guild [Goon Squad] was notorious for trolling Stranglethorn Vale. They would lock up the zone for hours corpse camping any Alliance player. Someone created a toon called MyDeadCorpse and left it dead and never resurrected. It was always there in the zone. A naked Gnome. For some reason, the Horde HATED Gnomes. :) [Ref.](https://github.com/AeroScripts/QuestieDev/issues/359#issuecomment-273827044)
