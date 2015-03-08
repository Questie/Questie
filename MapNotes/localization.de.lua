--[[
	MapNotes: Adds a note system to the WorldMap and other AddOns that use the Plugins facility provided

	See the README file for more information.

    Special thanks to StarDust for the German translation
]]

-- Ä: C3 84 - \195\132
-- Ö: C3 96 - \195\150
-- Ü: C3 9C - \195\156
-- ß: C3 9F - \195\159
-- ä: C3 A4 - \195\164
-- ö: C3 B6 - \195\182
-- ü: C3 BC - \195\188

if GetLocale() == "deDE" then

	-- General
	MAPNOTES_NAME = "MapNotes"
	MAPNOTES_ADDON_DESCRIPTION = "F\195\188gt ein Bemerkungs/Notes System der Weltkarte hinzu."
	MAPNOTES_DOWNLOAD_SITES = "Sehe README f\195\188r Download Seiten"

	-- Inteface Configuration
	MAPNOTES_WORLDMAP_HELP_1 = "Rechts-Klicken um aus der Karte zu zoomen"
	MAPNOTES_WORLDMAP_HELP_2 = "Links-Klicken um hinein zu zoomen"
	MAPNOTES_WORLDMAP_HELP_3 = "<Strg>+Rechts-Klicken auf die Karte um das "..MAPNOTES_NAME.." Menu zu \195\182ffnen"
	MAPNOTES_CLICK_ON_SECOND_NOTE = "|cFFFF0000Karten Notizen:|r W\195\164hle eine zweite Notiz um jene\ndurch eine Linie zu verbinden/Linie wieder zu l\195\182schen."

	MAPNOTES_NEW_MENU = "Karten Notizen"
	MAPNOTES_NEW_NOTE = "Notiz erstellen"
	MAPNOTES_MININOTE_OFF = "Kurz-Notizen aussch."
	MAPNOTES_OPTIONS = "Einstellungen"
	MAPNOTES_CANCEL = "Abbrechen"

	MAPNOTES_POI_MENU = "Karten Notizen"
	MAPNOTES_EDIT_NOTE = "Notiz bearbeiten"
	MAPNOTES_MININOTE_ON = "Als Kurz-Notiz"
	MAPNOTES_SPECIAL_ACTIONS = "Spezielle Aktionen"
	MAPNOTES_SEND_NOTE = "Notiz senden"

	MAPNOTES_SPECIALACTION_MENU = "Spezielle Aktionen"
	MAPNOTES_TOGGLELINE = "Notizen verbinden"
	MAPNOTES_DELETE_NOTE = "Notiz l\195\182schen"

	MAPNOTES_EDIT_MENU = "Notiz Bearbeiten"
	MAPNOTES_SAVE_NOTE = "Speichern"
	MAPNOTES_EDIT_TITLE = "Titel (erfordert):"
	MAPNOTES_EDIT_INFO1 = "Info Zeile 1 (optional):"
	MAPNOTES_EDIT_INFO2 = "Info Zeile 2 (optional):"
	MAPNOTES_EDIT_CREATOR = "Sch\195\182pfer (optional):"

	MAPNOTES_SEND_MENU = "Notiz Senden"
	MAPNOTES_SLASHCOMMAND = "Modus wechseln"
	MAPNOTES_SEND_TITLE = "Notiz senden:"
	MAPNOTES_SEND_TIP = "Diese Notiz kann von allen Benutzern der Karten Notizen ("..MAPNOTES_NAME..") empfangen werden."
	MAPNOTES_SEND_PLAYER = "Spielername eingeben:"
	MAPNOTES_SENDTOPLAYER = "An Spieler senden"
	MAPNOTES_SENDTOPARTY = "An Gruppe senden"
	MAPNOTES_SHOWSEND = "Modus wechseln"
	MAPNOTES_SEND_SLASHTITLE = "Slash-Befehle:"
	MAPNOTES_SEND_SLASHTIP = "Dies markieren und STRG+C dr\195\188cken um in die Zwischenablage zu kopieren. (dann kann es zum Beispiel in einem Forum ver\195\182ffentlicht werden)"
	MAPNOTES_SEND_SLASHCOMMAND = "/Befehl:"

	MAPNOTES_OPTIONS_MENU = "Einstellungen"
	MAPNOTES_SAVE_OPTIONS = "Speichern"
	MAPNOTES_OWNNOTES = "Notizen anzeigen, die von diesem Charakter erstellt wurden"
	MAPNOTES_OTHERNOTES = "Notizen anzeigen, die von anderen Spielern empfangen wurden"
	MAPNOTES_HIGHLIGHT_LASTCREATED = "Zuletzt erstellte Notiz in |cFFFF0000rot|r hervorheben"
	MAPNOTES_HIGHLIGHT_MININOTE = "Notizen die als Kurz-Notiz markiert wurden in |cFF6666FFblau|r hervorheben"
	MAPNOTES_ACCEPTINCOMING = "Ankommende Notizen von anderen Spielern akzeptieren"
	MAPNOTES_INCOMING_CAP = "Ankommende Notizen ablehnen wenn\nweniger als 5 freie Notizen \195\188brig bleiben"
	MAPNOTES_AUTOPARTYASMININOTE = "Markiere Gruppen-Notizen automatisch als Kurz-Notiz"

	MAPNOTES_CREATEDBY = "Erstellt von"
	MAPNOTES_CHAT_COMMAND_ENABLE_INFO = "Dieser Befehl erlaubt es zum Beispiel Notizen, die von einer Webseite empfangen wurden, einzuf\195\188gen."
	MAPNOTES_CHAT_COMMAND_ONENOTE_INFO = "\195\156bergeht die Einstellungen, wodurch die n\195\164chste empfangene Notiz in jedem Fall akzeptiert wird."
	MAPNOTES_CHAT_COMMAND_MININOTE_INFO = "Markiert die n\195\164chste empfangene Notiz direkt als Kurz-Notiz (und f\195\188gt jene auf der Karte ein)."
	MAPNOTES_CHAT_COMMAND_MININOTEONLY_INFO = "Markiert die n\195\164chste empfangene Notiz nur als Kurz-Notiz (und f\195\188gt jene nicht auf der Karte ein)."
	MAPNOTES_CHAT_COMMAND_MININOTEOFF_INFO = "Kurz-Notizen nicht mehr anzeigen."
	MAPNOTES_CHAT_COMMAND_MNTLOC_INFO = "Setzt eine tloc auf der Karte."
	MAPNOTES_CHAT_COMMAND_QUICKNOTE = "F\195\188gt auf der momentanen Position auf der Karte eine Notiz ein."
	MAPNOTES_CHAT_COMMAND_QUICKTLOC = "F\195\188gt auf der angegebenen tloc Position auf der Karte, in der momentanen Zone, eine Notiz ein."
	MAPNOTES_MAPNOTEHELP = "Dieser Befehl kann nur zum Einf\195\188gen einer Notiz benutzt werden."
	MAPNOTES_ONENOTE_OFF = "Eine Notiz zulassen: AUS"
	MAPNOTES_ONENOTE_ON = "Eine Notiz zulassen: AN"
	MAPNOTES_MININOTE_SHOW_0 = "N\195\164chste als Kurz-Notiz: AUS"
	MAPNOTES_MININOTE_SHOW_1 = "N\195\164chste als Kurz-Notiz: AN"
	MAPNOTES_MININOTE_SHOW_2 = "N\195\164chste als Kurz-Notiz: IMMER"
	MAPNOTES_DECLINE_SLASH = "Notiz kann nicht hinzugef\195\188gt werden, zuviele Notizen in |cFFFFD100%s|r."
	MAPNOTES_DECLINE_SLASH_NEAR = "Notiz kann nicht hinzugef\195\188gt werden, sie befindet sich zu nahe an |cFFFFD100%q|r in |cFFFFD100%s|r."
	MAPNOTES_DECLINE_GET = "Notiz von |cFFFFD100%s|r konnte nicht empfangen werden: zu viele Notizen in |cFFFFD100%s|r, oder Empfang in den Einstellungen deaktiviert."
	MAPNOTES_ACCEPT_SLASH = "Notiz auf der Karte von |cFFFFD100%s|r hinzugef\195\188gt."
	MAPNOTES_ACCEPT_GET = "Notiz von |cFFFFD100%s|r in |cFFFFD100%s|r empfangen."
	MAPNOTES_PARTY_GET = "|cFFFFD100%s|r hat eine neue Gruppen-Notiz in |cFFFFD100%s|r hinzugef\195\188gt."
	MAPNOTES_DECLINE_NOTETONEAR = "|cFFFFD100%s|r hat versucht dir in |cFFFFD100%s|r eine Notiz zu senden, aber jene war zu nahe bei |cFFFFD100%q|r."
	MAPNOTES_QUICKNOTE_NOTETONEAR = "Notiz konnte nicht erstellt werden: Du befindest dich zu nahe bei |cFFFFD100%s|r."
	MAPNOTES_QUICKNOTE_NOPOSITION = "Notiz konnte nicht erstellt werden: momentane Position konnte nicht ermittelt werden."
	MAPNOTES_QUICKNOTE_DEFAULTNAME = "Schnell-Notiz"
	MAPNOTES_QUICKNOTE_OK = "Notiz auf der Karte in |cFFFFD100%s|r erstellt."
	MAPNOTES_QUICKNOTE_TOOMANY = "Es befinden sich bereits zu viele Notizen auf der Karte von |cFFFFD100%s|r."
	MAPNOTES_DELETED_BY_NAME = "Alle Karten Notizen mit dem Erzeuger |cFFFFD100%s|r und dem Namen |cFFFFD100%s|r wurden gel\195\182scht"
	MAPNOTES_DELETED_BY_CREATOR = "Alle Karten Notizen mit dem Erzeuger |cFFFFD100%s|r wurden gel\195\182scht"
	MAPNOTES_QUICKTLOC_NOTETONEAR = "Notiz konnte nicht erstellt werden: Die Position ist zu nahe bei |cFFFFD100%s|r."
	MAPNOTES_QUICKTLOC_NOZONE = "Notiz konnte nicht erstellt werden: momentane Zone konnte nicht ermittelt werden."
	MAPNOTES_QUICKTLOC_NOARGUMENT = "Benutzung: '/quicktloc xx,yy [Icon] [Title]'."
	MAPNOTES_SETMININOTE = "Setzt die Notiz als neue Kurz-Notiz."
	MAPNOTES_THOTTBOTLOC = "Thottbot Ortsangabe"
	MAPNOTES_PARTYNOTE = "Gruppen-Notiz"

	MAPNOTES_CONVERSION_COMPLETE = MAPNOTES_VERSION.." - Konvertierung abgeschlossen. \195\156berpr\195\188fen sie bitte ihre Notes."

	-- Errors
	MAPNOTES_ERROR_NO_OLD_ZONESHIFT = "FEHLER: Kein altes Zoneshift definiert."

	-- Drop Down Menu
	MAPNOTES_SHOWNOTES = "Notizen anzeigen"
	MAPNOTES_DROPDOWNTITLE = "Karten Notizen"
	MAPNOTES_DROPDOWNMENUTEXT = "Optionen"

	MAPNOTES_WARSONGGULCH = "Warsongschlucht"
	MAPNOTES_ALTERACVALLEY = "Alteractal"
	MAPNOTES_ARATHIBASIN = "Arathibecken"
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

	MN_LEVEL = "Stufe";

	-- Magellan Style LandMarks
	MAPNOTES_LANDMARKS = "Landmarks";				-- Landmarks, as in POI, or Magellan
	MAPNOTES_LANDMARKS_CHECK = "Auto-MapNote "..MAPNOTES_LANDMARKS;
	MAPNOTES_DELETELANDMARKS = "Delete "..MAPNOTES_LANDMARKS;
	MAPNOTES_MAGELLAN = "(~Magellan)";
	MAPNOTES_LM_CREATED = " MapNotes Created in ";
	MAPNOTES_LM_MERGED = " MapNotes Merged in ";
	MAPNOTES_LM_SKIPPED = " MapNotes not Noted in ";
	MAPNOTES_LANDMARKS_NOTIFY = MAPNOTES_LANDMARKS.." Noted in ";

end
