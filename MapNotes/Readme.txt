******************************************
MapNotes (Fan's Update) README v3.00.20000
******************************************

Released: November 24, 2006
Maintainer: Telic <telic@hotmail.co.uk>
Original code: Sir.Bender <Meog on WoW Forums>
Contributors:
ciphersimian
Oystein <opium@geheb.com>
Legorol <legorol@cosmosui.org>
StarDust
Vjeux
Jorol
Marsman
Sinaloit
dodgizzla
Foogray
Khisanth
... and MANY others whose names didn't appear in the code anywhere


***********
Description
***********

Adds a note system to the WorldMap helping you keep track of interesting locations.
MapNotes(Fan's Update) also provides a Plugin interface for other AddOns to take advantage of the note making ability. AlphaMap(Fans Update) uses this interface to allow Note creation on AlphaMap Maps of Instances, BattleGrounds, and World Boss Maps. This version of MapNotes comes with in-built support for creation of notes on Atlas maps, also using this Plugin interface.
For these purpose MapNotes offers the following main functions:
1. Marking notes on the WorldMap
2. Showing one of these notes on the MiniMap (see MiniNote)
3. Allows any other AddOn to use MapNotes note creation ability to mark notes on frames within their own AddOn :
- Marking notes on AlphaMap (Fan's Update) Instance maps
- Marking notes on Atlas maps


********
Features
********

[Slash Commands]
================

/mapnote    OR    /mapnotes    OR    /mn
Only used to insert a Map Note by a slash command (which you can create in the Send Menu), for example, to put a note at the Entrance of Stormwind City on the map Elwynn Forest:

 "/mapnote k<WM Elwynn> x<0.320701> y<0.491480> t<Stormwind> i1<Entrance> i2<> cr<ciphersimian> i<0> tf<0> i1f<0> i2f<0>"

NOTE: The above would all be on one line Description of the identifiers:

k<#> - Key based on the map name from GetMapInfo() prefixed by "WM " (English name on all clients - never localised) Varies for other AddOns using the Plugin functionality
x<#> - X coordinate, based on the GetPlayerMapPosition() function
y<#> - Y coordinate, based on the GetPlayerMapPosition() function
t<text> - Title for the MapNote
i1<text> - first line of text displayed under the Title in the MapNote (Info 1)
i2<text> - second line of text displayed under the Title in the MapNote (Info 2)
cr<text> - Creator of the MapNote
i<#> - icon to use for the MapNote, AddOns/MapNotes/POIIcons/Icon#.tga
tf<#> - color of the Title, AddOns/MapNotes/POIIcons/Color#.tga
i1f<#> - color of the Info 1 line (colors as above)
i1f<#> - color of the Info 2 line (colors as above)



/onenote [on|off]    OR    /allowonenote [on|off]    OR    /aon [on|off]    OR    /mn1 [on|off]
Allows you to receive the next note, even if you have disabled receiving in the options.  If invoked with no parameters, it will toggle the current state.


/nextmininote [on|off]    OR    /nmn [on|off]     OR     /mnmn [on|off]
Shows the next note created (using any method) as a MiniNote and also puts it on the WorldMap.  If invoked with no parameters, it will toggle the current state.


/nextmininoteonly [on|off]    OR    /nmno [on|off]
Like the previous command, but doesn't put the note on the WorldMap.


/mininoteoff    OR    /mno
Turns the MiniNote off.


/mntloc tbX,tbY
Sets a "Thottbot location" on the map. Use it with no arguments to toggle it off.
X and Y are in "Thottbot coordinates" which can be represented as follows:
 local x,y = GetPlayerMapPosition()
 local tbX = math.floor(x*100)
 local tbY = math.floor(y*100)
This note is not bound to the map you are currently on.  Left click on it and select "Create New Note" to turn it into a standard note on the map you are viewing.


/quicknote [icon] [name]    OR    /qnote [icon] [name]
Adds a note at your current location, icon and name are optional (icon any number from 0 to 9, AddOns/MapNotes/POIIcons/Icon#.tga)


/quicktloc xx,yy [icon] [name]    OR    /qtloc xx,yy [icon] [name]
Addes a note on the map you are currently on at the given thottbot location, icon and name are optional (icon any number from 0 to 9, AddOns/MapNotes/POIIcons/Icon#.tga)


NEW SLASH COMMANDS IN MapNotes(Fan's Update)

/mnsearch [search text]     OR     /mns [search text]
If you want to search for a note, to see if one exists, or where it is, then you can use this command, and MapNotes will print out a report in the chat window, displaying the names of all maps which have a note containing that text


/mnhighlight [note name]     OR     /mnhl [note name]
If you have lots of notes and want to clearly identify a single one on a map, or if you want a certain note to remain highlighted, then use this command and they will be displayed with a green circle around them.
If there are several notes with that name, then they will all be highlighted


/mnmapc
Toggle the display of Player and Cursor Coordinates on the World Map
Control-Left-Click and drag the coordinates to move them to a different position on the World Map if you are not happy with the default.


/mnminic
Toggle the display of Player coordinates below the Minimap.



/mnt
Creates a quicknote at the Player's current location if the Player has no target.
If the Player does have a target, then it will create a note for that target at the Player's current location.


/mnm
Creates a note for the Player's target at the Player's current location.
OR Merges the details for the Player's current target in to a Map Note that has already been created at the Player's current location.
MUST have targetted a Player/NPC/Mob for this to work.


IMPORTANT NOTE ON THE IMPORT FUNCTIONS BELOW
All of the functions below are mainly designed for people who have just installed MapNotes (Fan's Update).  If you have been using this version of MapNotes for some time already, and have your own notes, then these functions may overwrite your existing notes. YOU HAVE BEEN WARNED.


/MapNotes_Import_MetaMap
If you want to move from MetaMapNotes to MapNotes, then log in to the game with both AddOns enabled,  use the above command, after which you will receive notification in the chat window on how many notes have been imported; Then log out, and disable MetaMap. Don't try to use MapNotes at the same time as MetaMap for any other purposes, as the results may be unpredictable


/MapNotes_Import_AlphaMap
If you have AlphaMap installed, and want to convert the in-built Instance and World Boss notes in to MapNotes notes, then use the above command, and you will see a message in the chat window informing you of how many notes have been imported in to MapNotes.
This does NOT import Battleground notes by default, as AlphaMap's in built Battleground functionality works best without MapNotes overlaying the BG Objectives.
NOTE: You don't have to import notes from AlphaMap, to make MapNotes on AlphaMap Instance/Battleground/WorldBoss maps. You can create any notes you like manually.


/MapNotes_Import_AlphaMapBG
As mentioned above, the basic "/MapNotes_Import_AlphaMap" command does not import Battleground notes by default. If you do want to import AlphaMap Battlegournd map notes, then use this command to do so.


/MapNotes_Import_CTMapMod
If you want to move from using CTMapMod to MapNotes (Fan's Update), then log in to the game with both AddOns enabled, use the above command, after which you will receive notification in the chat window on how many notes have been imported; Then log out, and disable CTMapMod.




[Key Bindings]
==============

QuickNote/TargetNote
Creates a quicknote at the Player's current location if the Player has no target.
If the Player does have a target, then it will create a note for that target at the Player's current location.


Merge Target Note
Creates a note for the Player's target at the Player's current location.
OR Merges the details for the Player's current target in to a Map Note that has already been created at the Player's current location.
MUST have targetted a Player/NPC/Mob for this to work.





[First Steps]
=============

(The AlphaMap and Atlas Plugins use the same basic functionality as below)

<Control>+Right-Click (on the WorldMap)

<Control>+Right-clicking on the WorldMap opens the MapNotes menu.
In this menu you will find 4 different buttons:

Create Note - This will open the Edit Menu and create a note at the position you clicked
Turn MiniNote Off - If the MiniNote is enabled this is one way to turn it off
Options - This opens the Options Menu (covered in more detail below)
Cancel - Closes the menu

NOTE: A left click on a note also opens the menu, but "Create Note" won't be available.

Move The Mouse Over A Note
Move the mouse over a note to see the tooltip with the information you entered.

Right-Click (on a Note)

Right-clicking on a note opens the other MapNotes menu.  Right clicking anywhere else results in zooming out. Here you will find the following buttons:

Edit Note - This button opens the Edit Menu to change the note you clicked on.
Set As MiniNote - Sets the note as the current MiniNote.
Send Note - Opens the Send Menu.
Delete Note - Deletes the note without further questioning.
Cancel - Closes the Menu


[Edit Menu]
===========

With this menu you can create new notes and edit existing notes.

1. Select the icon style you want to use for your note.

2. Title: Enter it in the editbox and select a color in which it will be displayed in the tooltip.
NOTE: The title field is mandatory, you cannot create a note without a title - to prevent this the "Save" button is disabled when the title field is empty.

3. Infoline 1 and 2: Here you can insert additional information for your note and color it in one of the colors below the editbox.

4. Creator: Enter the name of the player or AddOn that created the note


[The MiniNote]
==============

    A MiniNote is a note placed on the MiniMap.  Moving the mouse over the
MiniNote shows the title of the note.

    To show one of your notes on the MiniMap go to the Worldmap, right click on
a note and choose "Set As MiniNote".

    To hide the note on the MiniMap, you can go to the WorldMap, left click and
choose "Turn MiniNote Off" or use the slash command /mininoteoff (/mno).

    The MiniNote is turned off if the MapNote corresponding to it is deleted.
If you want a MiniNote without a MapNote use the /nextmininoteonly (/nmno)
slash command before creating the note.


[Send Notes To Other Players]
=============================

After clicking "Send Note" in the MapNotes Menu the Send Menu will show up.

1. Enter the name of the player you want to send a note to
NOTE: Targeting the player before opening the WorldMap will auto insert the name.

2. Send To Player
Choose this option to send the note to the player entered above.
NOTE: These notes can also be received by Carto+ users.

3. Send To Party
This will send the note to the entire party. Only Players in your Party that have MapNotes (Fan's Update) installed will receive the note. You will not Spam anybody with strange MapNote coordinates if they do not have this AddOn installed.

4. Change Mode
This toggles between Send To Player/Send To Party and Get Slash Command
Get Slash Command - Inserts a slash command in the editbox which can be highlighted and then copied to the clipboard.  After this you can post it on a forum or in chat and other MapNotes users can insert this note by copying the slash command to the chatline.


******************************
MapNotes ZoneShift Conversions
******************************

The MapNotes keying system has been completely re-written in this Version, and no longer uses the Continent/Zone combined key.
Instead, it is based on Map data that doesn't change between different language clients.
Hopefully this should future proof your database against any changes to zone lists caused by future WoW patches, or changing clients, or moving your database from one Client version to another. It should also allow two people who are using different Clients on the same Server to send notes to each other, without any client zone-shift, or version zone-shift errors.
If you are upgrading from an older version of MapNotes, to this version, your notes will be updated automatically.
However, if your database already had zone shift errors, then those errors will still exist after upgrading your database to this version.

Because of these changes, people upgrading from old versions will lose there old style data and will not be able to revert to their old version unless they have saved a copy of their MapNotes.lua database file.


*******
Options
*******

If the checkbox in front of an icon style is checked the notes with this style will be displayed, otherwise they will be hidden.

1.) Show notes created by your character
Enable to show notes with the creator field set to your character name

2.) Show notes received from other characters
Enable to show notes with the creator field set to anything other than your character name

3.) Highlight last created note in red

4.) Highlight note selected for MiniNote in blue

5.) Accept incoming notes from other players
Enable to allow other players to send MapNotes to you via whisper, etc.
NOTE: You can override this option for the next note only with the slash command /allowonenote (/aon).

6.) Decline notes if they would leave less than 5 notes free
The current limit is 100 notes per zone so this option will prevent other people from using your last 5 note slots in a zone.  The slash command /allowonenote (/aon) overrides this setting as well.  This checkbox is disabled if accept incoming notes is turned off.

7.) Map Coordinates
Enable to display your player AND cursor coordinates on the World Map.
Control-Click on the coordinates to move them to a different position on the World Map Frame, if you are not happy with the default.

8.) Minimap Coordinates
Enable to display your player coordinates below the Minimap.
If you are NOT targetting anything, then  ALT-Left-Click  on these coordinates to create a QuickNote.
If you are targetting something, then  ALT-Left-Click  to create a Target note with details about the current target at the PLAYER'S current location - you will be warned if you are too near to an existing note to create a new note.
If you are targetting something, then you may also  ALT-Right-Click  if you wish to create a note for your Target at the PLAYER'S current location. However, if a MapNote already exists at Player's location, then the details will be merged with the existing note.
(Key Bindings have also been created for these two functions)



**********
Change Log
**********

=======================================
Changes in v3.00.20000 from v2.40.11200
=======================================

- Burning Crusade Compatibility

- changed the way the options work so that using a Checkbox takes affect immediately and the 'Save' button is no longer required

- added new check-box on Options frame to auto-note Landmarks. Based on Magellan functionality.

- added new button on Options frame to delete auto-noted Landmarks in the current zone.







=======================================
Changes in v2.40.11200 from v2.30.11200
=======================================

- Added 90% Traditional Chinese Localisation

- If the Thottbott note is set as a Mininote, then I now make sure the Mininote is removed when the Thottbott note is deleted.
(Thottbott notes are set using the "/mntloc xx,yy" slash command)

- Some preliminary coding changes for compatiblity with The Burning Crusade Expansion pack. (Not fully compatible yet)



=======================================
Changes in v2.30.11200 from v2.25.11200
=======================================

- Added 90% Korean Localisation (Thanks to Gigabyte)

- Fixed a compatibility issue with AddOns that intercept Mouse clicks on the MiniMap (e.g. SilverTrack)

- Made sure coordinates are correct for current Zone when the WorldMap / AlphaMap closes

- Removed a debug message about MiniNote Map Key that should not have been left in ;p



=======================================
Changes in v2.25.11200 from v2.00.11200
=======================================

- NEW option to display Player and Cursor Coordinates on the World Map.
Control-Left-Click and drag the coordinates to move them to a different position on the World Map if you are not happy with the default.
Use the "/mnmapc" slash command to toggle display of World Map coordinates, or the new checkbox on the Options Frame

- NEW option to display Player Coordinates below the Minimap.
If you are NOT targetting anything, then  ALT-Left-Click  on these coordinates to create a QuickNote.
If you are targetting something, then  ALT-Left-Click  to create a Target Note at the PLAYER'S current location - you will be warned if you are too near to an existing note to create a new note.
If you are targetting something, then you may also  ALT-Right-Click  if you wish to create a note for your Target at the PLAYER'S current location. However when  ALT-Right-Clicking  the Minimap Coordinates, if a MapNote already exists at Player's location, then the details will be merged with the existing note.
Use the "/mnminic" slash command to toggle display of Minimap coordinates, or the new checkbox on the Options Frame.

- NEW Key bindings available that will do the same thing as Clicking on the Minimap Coordinates.
i.e. either create a new QuickNote/TargetNote,  or Create/Merge a TargetNote.

- NEW Slash commands can be used for the same functions :
/mnt	- create a new QuickNote/TargetNote at the player's Current location
/mnm	- create/merge a TargetNote for the Player's current target at the Player's current location



==================================================================
Changes from the Base Version to MapNotes(Fan's Update)v2.00.11200
==================================================================

NOTE: IF UPGRADING FROM PREVIOUS VERSIONS OF MAPNOTES - BACKUP YOUR MAPNOTES.LUA
DATABASE FILE FROM YOUR SAVEDVARIABLES FOLDER FIRST

- This version of MapNotes changes the Keying system used to record notes. If you are upgrading from a previous version of MapNotes, then it is important to save a copy of your MapNotes.lua file from your saved variables directory.
Because of these changes, people upgrading from old versions will lose there old style data and will not be able to revert to their old version unless they have saved a copy of their MapNotes.lua database file.
See the "MapNotes ZoneShift Conversions" section of the Readme.txt file for more details.

- You can now make notes on the Continent Maps and the overal World Map

- You can now make notes on Battleground Maps


MapNotes PlugIn Interface and Support for AlphaMap & Atlas
----------------------------------------------------------
- Added the ability to create MapNotes on AlphaMap (Fan's Update) v2.60.11200 Instance, Battleground, & World Boss Maps.  Note that AlphaMap already supports the display of MapNotes on World maps, and you must still use the World Map to create World map notes; However, you can now make MapNotes on the AlphaMap when displaying Instances, Battlegrounds, and World Boss maps.(This functionality is actually built in to AlphaMap itself, and takes advantage of the PlugIn feature now built in to this version of MapNotes.)

- Added the ability to create MapNotes on Atlas maps. (Again, this uses the Plugin features added to this version of MapNotes, but I have included the Atlas support natively, and it should work with most recent versions of Atlas)

- Provided a PlugIn interface by which other AddOns can add their own Frames over which MapNotes can then create MapNotes. Other Developers should see the extensive comments in the code, and check AlphaMap (Fan's Update) for an example of how to use this interface. (Read Plugins.lua)


MapNotes Import Functions
-------------------------
- For people moving from MetaMap or CTMapMod, there are 2 new slash commands available for people to import the notes made in those AddOns in to this version of MapNotes.
There are also 2 commands available to import AlphaMap's built in notes if you prefer to use MapNotes notes instead of AlphaMap's own.
All of these functions are mainly designed for people who have just installed MapNotes (Fan's Update).  If you have been using this version of MapNotes for some time already, and have your own notes, then these functions may overwrite your existing notes.
See the Slash Commands section for details on use.


Movable MapNotes
----------------
- You can now Control-Alt-Click Drag Notes to move them to different locations on the Map. No need to delete and re-create, just ctrl-alt-drag.


Changes to the Party Note
-------------------------
- First of all, the bug causing it to not be displayed on the World Map has been fixed.

- Shift-Right clicking places the note, and now Shift-Right clicking will also remove it, and make sure the MiniMap icon is also removed

- Removed the dependancy on Sky. Only members of your Party who also have MapNotes (Fan's Update) installed will receive a note. You will NOT spam the members of your party who do not have this AddOn with strange MapNotes coordinates.


Changes to the MiniMapNote
--------------------------
- Stopped the Mininote from preventing use of the WorldMap

- Made sure the Mininote stops displaying if the underlying MapNote is deleted


Change to Maximum number of Notes
---------------------------------
- No longer a maximum number of notes/lines. Notes and Lines are now created dynamically which will save memory for most people


MapNotes Search Feature
-----------------------
- Can now search your MapNotes database for certain text, and MapNotes will report the number and locations of all notes containing that text to the default chat window
(SEE Slash Commands)


MapNotes Highlighting
---------------------
- If you have lots of notes and want to clearly identify a single one on a map, or if you want a certain note to remain highlighted, then use this command and they will be displayed with a green circle around them.
If there are several notes with that name, then they will all be highlighted
(SEE Slash Commands)


Miscallaneous Changes
---------------------
- Compatibility changes ensuring the menu frames are always fully opaque and appear near the cursor when the WorldMap has been altered by other AddOns.

- Made some updates more immediate so that maps/frames show new/deleted notes/lines as soon as you add/delete them.

- Multiple small bug fixes





SEE Readme.old.txt FOR HISTORIC CHANGES TO EARLIER VERSIONS OF MAPNOTS