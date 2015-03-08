--[[
	MapNotes: Adds a note system to the WorldMap and other AddOns that use the Plugins facility provided

	See the README file for more information.
]]

-- English is the default localization for MapNotes
--if GetLocale() == "usEN" then

-- General
MAPNOTES_NAME = "MapNotes";
MAPNOTES_ADDON_DESCRIPTION = "Adds a note system to the WorldMap.";
MAPNOTES_DOWNLOAD_SITES = "See README for download sites";

-- Interface Configuration
MAPNOTES_WORLDMAP_HELP_1 = "Right-Click On Map To Zoom Out";
MAPNOTES_WORLDMAP_HELP_2 = "Left-Click On Map To Zoom In";
MAPNOTES_WORLDMAP_HELP_3 = "<Control>+Right-Click On Map To Open "..MAPNOTES_NAME.." Menu";
MAPNOTES_CLICK_ON_SECOND_NOTE = "|cFFFF0000"..MAPNOTES_NAME..":|r Choose Second Note To Draw/Clear A Line";

MAPNOTES_NEW_MENU = MAPNOTES_NAME;
MAPNOTES_NEW_NOTE = "Create Note";
MAPNOTES_MININOTE_OFF = "Turn MiniNote Off";
MAPNOTES_OPTIONS = "Options";
MAPNOTES_CANCEL = "Cancel";

MAPNOTES_POI_MENU = MAPNOTES_NAME;
MAPNOTES_EDIT_NOTE = "Edit Note";
MAPNOTES_MININOTE_ON = "Set As MiniNote";
MAPNOTES_SPECIAL_ACTIONS = "Special Actions";
MAPNOTES_SEND_NOTE = "Send Note";

MAPNOTES_SPECIALACTION_MENU = "Special Actions";
MAPNOTES_TOGGLELINE = "Toggle Line";
MAPNOTES_DELETE_NOTE = "Delete Note";

MAPNOTES_EDIT_MENU = "Edit Note";
MAPNOTES_SAVE_NOTE = "Save";
MAPNOTES_EDIT_TITLE = "Title (required):";
MAPNOTES_EDIT_INFO1 = "Info Line 1 (optional):";
MAPNOTES_EDIT_INFO2 = "Info Line 2 (optional):";
MAPNOTES_EDIT_CREATOR = "Creator (optional):";

MAPNOTES_SEND_MENU = "Send Note";
MAPNOTES_SLASHCOMMAND = "Change Mode";
MAPNOTES_SEND_TITLE = "Send Note:";
MAPNOTES_SEND_TIP = "These notes can be received by all "..MAPNOTES_NAME.." users.";
MAPNOTES_SEND_PLAYER = "Enter player name:";
MAPNOTES_SENDTOPLAYER = "Send to player";
MAPNOTES_SENDTOPARTY = "Send to party";
MAPNOTES_SHOWSEND = "Change Mode";
MAPNOTES_SEND_SLASHTITLE = "Get slash Command:";
MAPNOTES_SEND_SLASHTIP = "Highlight this and use CTRL+C to copy to clipboard (then you can post it in a forum for example)";
MAPNOTES_SEND_SLASHCOMMAND = "/Command:";

MAPNOTES_OPTIONS_MENU = "Options";
MAPNOTES_SAVE_OPTIONS = "Save";
MAPNOTES_OWNNOTES = "Show notes created by your character";
MAPNOTES_OTHERNOTES = "Show notes received from other characters";
MAPNOTES_HIGHLIGHT_LASTCREATED = "Highlight last created note in |cFFFF0000red|r";
MAPNOTES_HIGHLIGHT_MININOTE = "Highlight note selected for MiniNote in |cFF6666FFblue|r";
MAPNOTES_ACCEPTINCOMING = "Accept incoming notes from other players";
MAPNOTES_INCOMING_CAP = "Decline notes if they would leave less than 5 notes free";
MAPNOTES_AUTOPARTYASMININOTE = "Automatically set party notes as MiniNote.";

MAPNOTES_CREATEDBY = "Created by";
MAPNOTES_CHAT_COMMAND_ENABLE_INFO = "This command enables you to instert notes gotten by a webpage for example.";
MAPNOTES_CHAT_COMMAND_ONENOTE_INFO = "Overrides the options setting, so that the next note you receive is accepted.";
MAPNOTES_CHAT_COMMAND_MININOTE_INFO = "Displays the next received note directly as MiniNote (and insterts it into the map):";
MAPNOTES_CHAT_COMMAND_MININOTEONLY_INFO = "Displays the next note received as MiniNote only (not inserted into map).";
MAPNOTES_CHAT_COMMAND_MININOTEOFF_INFO = "Turns the MiniNote off.";
MAPNOTES_CHAT_COMMAND_MNTLOC_INFO = "Sets a tloc on the map.";
MAPNOTES_CHAT_COMMAND_QUICKNOTE = "Creates a note at the current position on the map.";
MAPNOTES_CHAT_COMMAND_QUICKTLOC = "Creates a note at the given tloc position on the map in the current zone.";

MAPNOTES_CHAT_COMMAND_IMPORT_METAMAP = "Imports MetaMapNotes. Intended for people migrating to MapNotes.\nMetaMap must be Installed and Enabled for the command to work. Then Un-Install MetaMap.\nWARNING : Intended for new users. May over-write existing notes."; --Telic_4
MAPNOTES_CHAT_COMMAND_IMPORT_ALPHAMAP = "Import AlphaMap's Instance Notes : Requires AlphaMap (Fan's Update) to be Installed and Enabled";		--Telic_4

MAPNOTES_MAPNOTEHELP = "This command can only be used to insert a note";
MAPNOTES_ONENOTE_OFF = "Allow one note: OFF";
MAPNOTES_ONENOTE_ON = "Allow one note: ON";
MAPNOTES_MININOTE_SHOW_0 = "Next as MiniNote: OFF";
MAPNOTES_MININOTE_SHOW_1 = "Next as MiniNote: ON";
MAPNOTES_MININOTE_SHOW_2 = "Next as MiniNote: ONLY";
MAPNOTES_DECLINE_SLASH = "Could not add, too many notes in |cFFFFD100%s|r.";
MAPNOTES_DECLINE_SLASH_NEAR = "Could not add, this note is too near to |cFFFFD100%q|r in |cFFFFD100%s|r.";
MAPNOTES_DECLINE_GET = "Could not receive note from |cFFFFD100%s|r: too many notes in |cFFFFD100%s|r, or reception disabled in the options.";
MAPNOTES_ACCEPT_SLASH = "Note added to the map of |cFFFFD100%s|r.";
MAPNOTES_ACCEPT_GET = "You received a note from |cFFFFD100%s|r in |cFFFFD100%s|r.";
MAPNOTES_PARTY_GET = "|cFFFFD100%s|r set a new party note in |cFFFFD100%s|r.";
MAPNOTES_DECLINE_NOTETONEAR = "|cFFFFD100%s|r tried to send you a note in |cFFFFD100%s|r, but it was too near to |cFFFFD100%q|r.";
MAPNOTES_QUICKNOTE_NOTETONEAR = "Can't create note. You are too near to |cFFFFD100%s|r.";
MAPNOTES_QUICKNOTE_NOPOSITION = "Can't create note: could not retrieve current position.";
MAPNOTES_QUICKNOTE_DEFAULTNAME = "Quicknote";
MAPNOTES_QUICKNOTE_OK = "Created note on the map of |cFFFFD100%s|r.";
MAPNOTES_QUICKNOTE_TOOMANY = "There are already too many notes on the map of |cFFFFD100%s|r.";
MAPNOTES_DELETED_BY_NAME = "Deleted all "..MAPNOTES_NAME.." with creator |cFFFFD100%s|r and name |cFFFFD100%s|r.";
MAPNOTES_DELETED_BY_CREATOR = "Deleted all "..MAPNOTES_NAME.." with creator |cFFFFD100%s|r.";
MAPNOTES_QUICKTLOC_NOTETONEAR = "Can't create note. The location is too near to the note |cFFFFD100%s|r.";
MAPNOTES_QUICKTLOC_NOZONE = "Can't create note: could not retrieve current zone.";
MAPNOTES_QUICKTLOC_NOARGUMENT = "Usage: '/quicktloc xx,yy [icon] [title]'.";
MAPNOTES_SETMININOTE = "Set note as new MiniNote";
MAPNOTES_THOTTBOTLOC = "Thottbot Location";
MAPNOTES_PARTYNOTE = "Party Note";

MAPNOTES_CONVERSION_COMPLETE = MAPNOTES_VERSION.." - Conversion complete. Please check your notes.";		-- ??

MAPNOTES_TRUNCATION_WARNING = "The Note Text being Sent had to be truncated";				-- ??

MAPNOTES_IMPORT_REPORT = " Notes Imported";								-- ??
MAPNOTES_NOTESFOUND = " Note(s) Found";									-- ??

-- Drop Down Menu
MAPNOTES_SHOWNOTES = "Show Notes";
MAPNOTES_DROPDOWNTITLE = MAPNOTES_NAME;
MAPNOTES_DROPDOWNMENUTEXT = "Quick Options";

MAPNOTES_WARSONGGULCH = "Warsong Gulch";
MAPNOTES_ALTERACVALLEY = "Alterac Valley";
MAPNOTES_ARATHIBASIN = "Arathi Basin";
MAPNOTES_STORMWIND = "Stormwind";

MAPNOTES_COSMIC = "Cosmic";


-- Coordinates
MAPNOTES_MAP_COORDS = "Map Coords";
MAPNOTES_MINIMAP_COORDS = "Minimap Coords";


-- MapNotes Target & Merging
MAPNOTES_MERGED = "MapNote Merged for : ";
MAPNOTES_MERGE_DUP = "MapNote already exists for : ";
MAPNOTES_MERGE_WARNING = "You must have something targetted to merge notes.";

BINDING_HEADER_MAPNOTES = "MapNotes";
BINDING_NAME_MN_TARGET_NEW = "QuickNote/TargetNote";
BINDING_NAME_MN_TARGET_MERGE = "Merge Target Note";

MN_LEVEL = "Level";

-- Magellan Style LandMarks
MAPNOTES_LANDMARKS = "Landmarks";				-- Landmarks, as in POI, or Magellan
MAPNOTES_LANDMARKS_CHECK = "Auto-MapNote "..MAPNOTES_LANDMARKS;
MAPNOTES_DELETELANDMARKS = "Delete "..MAPNOTES_LANDMARKS;
MAPNOTES_MAGELLAN = "(~Magellan)";
MAPNOTES_LM_CREATED = " MapNotes Created in ";
MAPNOTES_LM_MERGED = " MapNotes Merged in ";
MAPNOTES_LM_SKIPPED = " MapNotes not Noted in ";
MAPNOTES_LANDMARKS_NOTIFY = MAPNOTES_LANDMARKS.." Noted in ";

--end
