Basic install instructions
  - Extract the archive
  - Copy the "!Questie" folder into your "<WOW FOLDER>/Interface/Addons/" directory
    * NOTE * It should be beside several folders that start with "Blizzard_"
  - Log into the game and verify Questie is loaded by going into the addon menu (Bottom left of the screen)
    * NOTE * It is recommended that you increase the addon memory limit (top right of the window)
    The default value for vanilla is very low and may cause problems if you use questie with other addons

FAQ:
  - How do I move the QuestieTracker and QuestArrow?
	* Hold down CTRL + Shift + Hold Left Mouse Button + Drag
  - I get an error: "attempt to index global 'QuestieConfig' (a nil value)"
	* This can be caused by upgrading from an older version of Questie or using it for the first
	time before a SavedVariables can be properly created. Please use '/questie clearconfig' while in
	game to clear/reset your config file.
  - I play on a non-English server and Questie isn't working. How come?
	* Currently, Questie only supports English servers/clients. Language support is currently being worked on but is not yet available.
  - I can't seem to get my quests to appear in the tracker automatically.
	* For those not running EQL3 or some other QuestLog mod. If you prefer the default wow QuestLog and
	Tracker that's fine but it's very limited. For example, if a quest doesn't have any objectives to
	"track" then it won't appear in the quest tracker and no Quest Arrow will be available for it.
	Additionally, quests will not automatically be tracked by the default WoW quest tracker. The way that
	it works is that if you have the option enabled in the games Interface Options --> "Automatic Quest
	Tracking" then yes, it will auto track a quest with an objective once you OBTAIN the first quest item.
	Then it will appear automatically in the list unless you manually Shift+Click the quest in the
	QuestLog but again, only if there is a "trackable" objective. Unlike EQL3 or other
	QuestLog/QuestTracker mods where pretty much anything is trackable, these quests will appear in the
	Questie QuestTracker. If the quest appears then map coordinates are cached and this allows the
	QuestieArrow to hook into the position and give you an arrow.
  - Why isn't the QuestieArrow appearing?
	* You have to click on an objective on the Minimap, Worldmap or the quest in the QuestieTracker. If
	a quest has never been tracked it won't appear until after it has appeared at least once in the
	QuestieTracker. If you disable the QuestieTracker, the QuestieArrow will not work.

Questie Slash Commands - use "/questie" to show the help menu in game.
  - arrow: Toggles the QuestArrow on and off.
  - corpsearrow: Toggles the CorpseArrow on and off.
  - clearconfig: Resets all Questie settings and removes stale quest database entries (will not delete
    completed quests).
  - cleartracker: Resets the position of the QuestTracker and places it in the center of your screen.
  - color: Two different color schemes. The original(default) and the other mimics Monkey Quests colors.
  - header: This places an additional line (depending on which direction you have your QuestTracker listing
    quests) either above or below and informs you how many quests you have in your log.
  - listdirection: The default setting lists quests in the QuestTracker from the Top --> Down. Running this
    command will change the direction from Bottom --> Top.
  - mapnotes: Toggles all World Map and Mini Map icons on and off. This is the same function as the Questie
    Toggle button on the World Map (which will eventually be removed).
  - maxlevel: Toggles the maxlevel filter on or off - please use setmaxlevel to adjust settings.
  - minlevel: Toggles the minlevel filter on or off - please use setminlevel to adjust settings.
  - NUKE: Resets ALL Questie data and settings which includes the quest database.
  - professions: Toggles profeession related quests.
  - resizemap: This command are for those that do NOT run a Worldmap mod such as Metamap or Cartographer.
    This toggles the Worldmap in either fullscreen or windowed mode.
  - setmaxlevel: Hides quests until <X> levels above players level (default=3).
  - setminlevel: Hides quests <X> levels below players level (default=5).
  - settings: Displayes your current toggles and settings in your default chat window.
  - showquests: Toggles on and off the ability to always show quests on the Worldmap / Minimap - tracked or
    not tracked.
  - tooltips: Toggles on and off the Quest Objective tool tips.
  - tracker: Toggles on and off the QuestTracker.
  - qtscale: Resizes the Questie QuestTracker using one of 3 pre-programed sizes. Small(default), Medium and Large
  - background: Turns on the QuestTracker background
  - backgroundalpha: Sets the QuestTracker background alpha level. Takes a number input from 1 to 9.