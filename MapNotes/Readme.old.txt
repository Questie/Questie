*******************************************************************************
                            MapNotes README v1800.7
*******************************************************************************

Released: October 30, 2005
Maintainer: ciphersimian <ciphersimian@gmail.com>
Original code: Sir.Bender <Meog on WoW Forums>
Contributors:
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

Download from any of the following:
    http://www.curse-gaming.com/mod.php?addid=1285
    http://www.wowinterface.com/downloads/fileinfo.php?s=&id=3985
    http://ui.worldofwar.net/ui.php?id=769
    http://www.wowguru.com/ui/mapnotes/


*******************************************************************************
                                  Description
*******************************************************************************

Adds a note system to the WorldMap helping you keep track of interesting
locations.  For this purpose MapNotes offers two main functions:

1. Marking notes on the WorldMap
2. Showing one of these notes on the MiniMap (see MiniNote)


*******************************************************************************
                                    Features
*******************************************************************************

                                [Slash Commands]

/mapnote
    Only used to insert a Map Note by a slash command (which you can create in
    the Send Menu), for example, to put a note at the Entrance of Stormwind
    City on the map Elwynn Forest:

    /mapnote c<2> z<10> x<0.320701> y<0.491480> t<Stormwind City> i1<Entrance>
        i2<> cr<ciphersimian> i<0> tf<0> i1f<0> i2f<0>

    NOTE: The above would all be on one line

    Description of the identifiers:

        c<#> - continent number, based on the GetMapContinents() array on the
               English client
        z<#> - zone number, based on the GetMapZones() array on the English
               client
        x<#> - X coordinate, based on the GetPlayerMapPosition() function
        y<#> - Y coordinate, based on the GetPlayerMapPosition() function
        t<text> - Title for the MapNote
        i1<text> - first line of text displayed under the Title in the
                   MapNote (Info 1)
        i2<text> - second line of text displayed under the Title in the
                   MapNote (Info 2)
        cr<text> - Creator of the MapNote
        i<#> - icon to use for the MapNote, AddOns/MapNotes/POIIcons/Icon#.tga
        tf<#> - color of the Title, AddOns/MapNotes/POIIcons/Color#.tga
        i1f<#> - color of the Info 1 line (colors as above)
        i1f<#> - color of the Info 2 line (colors as above)

/onenote [on|off], /allowonenote [on|off], /aon [on|off]
    Allows you to receive the next note, even if you have disabled receiving in
    the options.  If invoked with no parameters, it will toggle the current
    state.

/nextmininote [on|off], /nmn [on|off]
    Shows the next note created (using any method) as a MiniNote and also puts
    it on the WorldMap.  If invoked with no parameters, it will toggle the
    current state.

/nextmininoteonly [on|off], /nmno [on|off]
    Like the previous command, but doesn't put the note on the WorldMap.

/mininoteoff, /mno
    Turns the MiniNote off.

/mntloc tbX,tbY
    Sets a "Thottbot location" on the map. Use it with no arguments to toggle
    it off.

    X and Y are in "Thottbot coordinates" which can be represented as follows:

        local x,y = GetPlayerMapPosition()
        local tbX = math.floor(x*100)
        local tbY = math.floor(y*100)

    This note is not bound to the map you are currently on.  Left click on it
    and select "Create New Note" to turn it into a standard note on the map you
    are viewing.

/quicknote [icon] [name], /qnote [icon] [name]
    Adds a note at your current location, icon and name are optional (icon any
    number from 0 to 9, AddOns/MapNotes/POIIcons/Icon#.tga)

/quicktloc xx,yy [icon] [name], /qtloc xx,yy [icon] [name]
    Addes a note on the map you are currently on at the given thottbot
    location, icon and name are optional (icon any number from 0 to 9,
    AddOns/MapNotes/POIIcons/Icon#.tga)


                                 [First Steps]

<Control>+Right-Click (on the WorldMap)

    <Control>+Right-clicking on the WorldMap opens the MapNotes menu.  In this
menu you will find 4 different buttons:

    Create Note
        This will open the Edit Menu and create a note at the position you
        clicked
    Turn MiniNote Off
        If the MiniNote is enabled this is one way to turn it off
    Options
        This opens the Options Menu (covered in more detail below)
    Cancel
        Closes the menu

    NOTE: A left click on a note also opens the menu, but "Create Note" won't
          be available.

Move The Mouse Over A Note

    Move the mouse over a note to see the tooltip with the information you
    entered.

Right-Click (on a Note)

    Right-clicking on a note opens the other MapNotes menu.  Right clicking
anywhere else results in zooming out.  Here you will find the following
buttons:

    Edit Note
        This button opens the Edit Menu to change the note you clicked on.
    Set As MiniNote
        Sets the note as the current MiniNote.
    Send Note
        Opens the Send Menu.
    Delete Note
        Deletes the note without further questioning.
    Cancel
        Closes the Menu


                                  [Edit Menu]

With this menu you can create new notes and edit existing notes.

    1. Select the icon style you want to use for your note.

    2. Title: Enter it in the editbox and select a color in which it will be
       displayed in the tooltip.
           NOTE: The title field is mandatory, you cannot create a note without
                 a title - to prevent this the "Save" button is disabled when
                 the title field is empty.

    3. Infoline 1 and 2: Here you can insert additional information for your
       note and color it in one of the colors below the editbox.

    4. Creator: Enter the name of the player or AddOn that created the note


                                 [The MiniNote]

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

After clicking "Send Note" in the MapNotes Menu the Send Menu will show up.

    1. Enter the name of the player you want to send a note to
           NOTE: Targeting the player before opening the WorldMap will auto
                 insert the name.

    2. Send To Player
        Choose this option to send the note to the player entered above.
            NOTE: These notes can also be received by Carto+ users.

    3. Send To Party (requires Sky)
        This will send the note to the entire party. (No player name needs to
        be filled in.)

    4. Change Mode
        This toggles between Send To Player/Send To Party and Get Slash Command

        Get Slash Command
            Inserts a slash command in the editbox which can be highlighted
            and then copied to the clipboard.  After this you can post it
            on a forum or in chat and other MapNotes users can insert this
            note by copying the slash command to the chatline.


*******************************************************************************
                         MapNotes ZoneShift Conversions
*******************************************************************************

Non-English clients have a different zone numbering than the English clients,
and thus need to map their zone numbers to the English ones (so that MiniMap
scaling and such will be correct, for MiniMap notes).

Some older versions of MapNotes supplied in some compilations for these
languages didn't implement the ZoneShifts (ZoneShifts were implemented in
MapNotes 0.5.4.)  To use this version, you need to convert your current notes
to the correct ZoneShift.

In addition, in some cases you might need to convert from an incorrect
ZoneShift to a correct one (for example, for anyone with a French client that
used 1.5c of this version of MapNotes, which supplied an incorrect ZoneShift.)

This version of MapNotes provides one function for each of these.

IMPORTANT: Backup SavedVariables/MapNotes.lua BEFORE you call any one of these
functions.

To convert from a client which didn't use ZoneShifts:
Simply log into WoW, and do: '/script MapNotes_ConvertOldNotes()'

To convert from an invalid ZoneShift to the correct one:
Edit localization.COUNTRYCODE.lua in the version of MapNotes you are upgrading
to, and uncomment (or add) your previous MapNotes_ZoneShift (it needs to be
called MapNotes_ZoneShiftOld) from the version of MapNotes you are upgrading
from.  To convert notes created with the incorrect ZoneShift supplied in 1.5c,
uncomment the old ZoneShift with the 'French 1.5.0 invalid' label

Then type (in WoW) '/script MapNotes_ConvertFromOldZoneShift()'.

If this doesn't work, or you need any help, please e-mail me.


*******************************************************************************
                                    Options
*******************************************************************************

If the checkbox in front of an icon style is checked the notes with this style
will be displayed, otherwise they will be hidden.

Show notes created by your character
    Enable to show notes with the creator field set to your character name

Show notes received from other characters
    Enable to show notes with the creator field set to anything other than your
    character name

Highlight last created note in red

Highlight note selected for MiniNote in blue

Accept incoming notes from other players
    Enable to allow other players to send MapNotes to you via whisper, etc.

    NOTE: You can override this option for the next note only with the slash
          command /allowonenote (/aon).

Decline notes if they would leave less than 5 notes free
    The current limit is 100 notes per zone so this option will prevent other
    people from using your last 5 note slots in a zone.  The slash command
    /allowonenote (/aon) overrides this setting as well.  This checkbox is
    disabled if accept incoming notes is turned off.


*******************************************************************************
                                  Change Notes
*******************************************************************************

                                [Version 1800.7]
                           Released October 30, 2005

+ Restored Right-click to zoom out, you can now bring up the MapNotes menu with
    <Control>+Right-Click


                                [Version 1800.6]
                           Released October 29, 2005

+ Fixed problems with bringing up menus when a MapNote is at the same location
    as the player icon on the WorldMap


                                [Version 1800.5]
                           Released October 27, 2005

+ Fixed some texture weirdness when toggling lines off on the WorldMap
+ Visual improvements to the buttons (eliminated the "stretched" look)


                                [Version 1800.4]
                           Released October 26, 2005

+ Fixed a bug in the hooking of Minimap_OnClick


                                [Version 1800.3]
                           Released October 24, 2005

+ Fixed a bug where you couldn't click on the color swatches in the Edit Note
    menu


                                [Version 1800.2]
                           Released October 23, 2005

+ Changed the type of clicks used to interact with the WorldMap.  This was a
    pretty big decision but there were lots of problems with the old methods
    and my goal was to make it as intuitive as possible without breaking any
    of the default functionality.  Right-click now brings up the MapNotes menu
    on the WorldMap.  Left-click works exactly the same as it does without
    MapNotes installed unless you click on a MapNote.  If you want to zoom out
    you have to use the Zoom Out button, magnifying glass icon or the drop
    down continent menu.  Alternatively you can hold down control and right
    click to zoom out.  Hopefully this works for everyone, I think this is a
    much better better way to handle the map clicks once you get used to it.
+ Removed WorldMapButton_OnUpdate hook, now listing to WORLD_MAP_UPDATE event
+ Fixed another bug in Mininote handling when notes are deleted
+ Improved the MapNotes Lines functionality, cleaned the code up, made the
    lines darker and more crisp, should eliminate problems with them
    not showing up with some anti-aliasing schemes, etc.
+ Removed DarkerBackground.tga image, replaced with UI-Tooltip-Background
+ Fixed a bug where zooming out when using MapNotes always zoomed all the way
    out to the world view of both continents instead of zooming out one level.
    This also removed the WorldMapZoomOutButton_OnClick hook.
+ Removed support for MapNotes Gathering
+ Replaced all usage of GetZoneText() with GetRealZoneText()
+ Fixed bug where party note and tloc weren't working


                                [Version 1800.1]
                           Released October 16, 2005

+ IMPORTANT: New German ZoneShift for this version.  See section on MapNotes
    ZoneShift Conversions if you have a German client.
+ Changed version numbering scheme, new version numbers will be the WoW
    Interface .toc version the release was designed to work with followed by a
    period and the number of WoWKB releases since the last .toc change.
+ Created this README file
+ Cleaned up the code quite a bit, eliminated some duplicated code, still lots
    of cleanup left to go
+ Got rid of the dependency on Sea.  I looked into this quite a bit and see no
    advantage to using Sea just for the sake of hooking functions.  I
    reorganized the code a bit and tried to identify all the hooked functions
    and put all the hooking in once place, as much as possible.  In future
    versions I will be trying to remove some of the hooking altogether.
+ Moved Legorol's CurrentZoneFix into a seperate file in anticipation of it
    someday not being necessary
+ Moved MapNotes_Const into a seperate file, mostly because it's a lot of ugly
    information that isn't useful to look at when editing the main file
+ Updated myAddOns support to use the _Register method instead of inserting
    into it's data structure directly and add info for several of it's other
    available fields
+ Moved a few strings to the localization files
+ Added MapNotes_DeleteNotesByCreatorAndName API function, creator is required,
    name is optional - if name is not specified all notes with the specified
    creator will be deleted
+ Fixed some bugs in the MiniNote handling when the note it represents or one
    after it is deleted
+ Removed references to nonexistent "print1" function, if anyone has any idea
    what this is/was please let me know.
+ Resized all the UI elements to better fit the localized versions
+ Made the Creator field an editable field from the Edit Menu, though the
    color of this field is not customizable.
+ Probably some other things I forgot about as I was going - this code is a
    real mess.  Alas, I'm working on that.


                              [Version 1.5d_1700]

+ Updated TOC
+ Updated format of the world map OnUpdate function
+ Added scaling for the new BG.


                                 [Version 1.5d]

+ New (correct) French zoneshift added. See above notice about conversions.


                                 [Version 1.5c]

+ New zoneshifts for French clients (IMPORTANT: The zone ordering changed for
    the French clients in the 1.5.0 patch. I'm still trying to confirm a
    working zoneshift, bear with me).
+ Minor fix for a bug that cropped up when trying to place quicknotes in BGs
    and having no existing map notes there.
+ (Re)Added the ability to place map notes on your own location on the map.


                                 [Version 1.5b]

+ Upgraded Legorol's CurrentZoneFix to version 2
+ Changed some Minimap code, among other things it won't show if you're outside
    its zone now.
+ Added basic myAddOns support
+ Holding down Control while clicking on the world map now allows you to place
    a note in spots where clicking would normally zoom out.
+ A couple of other minor fixes and adjustments.


                                 [Version 1.5a]

+ The fix for deleting notes in the BGs accidentally made it impossible to
    delete any notes -outside- the BGs.  Fixed!
+ Minor fix for a bug that cropped up if you had a Mininote set in the BGs
    and left them without removing the note.


                                 [Version 1.5]

+ Changed ToC to match new patch number
+ Merged changes from Sinaloit of the Cosmos team 'Converted from
    Cosmos_RegisterChatCommand to Sky.registerSlashCommand, updated default
    slash commands fixed thottbot_replace, Sky users can now send notes to non
    Sky users (cannot receive though).'
+ Fixed maps in the BGs (again, Blizzard made an API change).
+ Quicknotes works in the BGs now.
+ And you can delete notes in the BGs too, now.


                                 [Version 1.4a]

+ Fixed a Minimap bug for non-Sea users (yet another one)


                                 [Version 1.4]

+ Fixed map clicking for non-Sea users
+ Fixed sending notes to players without having Sky installed.
+ Changed hooked functions to play nicer with other AddOns.
+ Now supports placing map notes in the Battlegrounds.  MiniNotes should work
    there as well (At least in Warsong, Alterac will have scaling issues until
    it reopens and I can test it).

                                 [Version 1.3]

+ Fixed the BGs again (Note: Placing notes in them don't work yet.  It's
    something I'm working on, but it requires changing substantial amounts of
    code)
+ Fixed the wrong-map-on-M bug for German and French clients, using Legorol's
    CurrentZoneFix.

                                 [Version 1.2a]

+ Fixed zone bug.  In effect, removing the BG fix.  I'll see about finding a
    better method of solving that tomorrow.


                                 [Version 1.2]

+ Fixed stack overflow error.
+ Fixed setting notes in Ironforge, Thunder Bluff and Undercity (I hope)
+ The old Map Notes replaced the Blizzard code for setting player, group and
    corpse locations on the map.  Removed that and let Blizzards take over
    (Reason: I had to run Blizzards code to set raid member positions anyway.
    No point in doing things twice)
+ When adding a new note on the map: Hitting enter will store the note, ESC
    will close the map.
+ Added code to set the map correctly when you first log in (You know, WoW
    would always open the map to the whole-continent view, until you moved into
    another zone. This fixes it.)


                                 [Version 1.1]

+ Integrated support for Sky, from the Cosmos version.  Modified to support Sky
    without Cosmos (Needed for sending map notes to the party.  Map Notes in
    general works fine without Sky).


                                 [Version 1.0]

+ Fixed setting notes in Ironforge
+ Incorporated changes by dodgizzla, to see raid members on the world map, and
    suppressing errors in the BGs.
