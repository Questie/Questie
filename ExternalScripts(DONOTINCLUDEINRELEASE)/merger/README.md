# Merger

This collection of scripts was created to merge the database files from mangos and trinity for the cata release.

## Usage

1. First you need to install [LuaFileSystem](https://lunarmodules.github.io/luafilesystem/manual.html#introduction)
    - `luarocks install luafilesystem`
2. Check the `require` statements at the top of the `merge.lua` script you want to run and add the required files to the `data` folder.
    - e.g. `cataNpcDB.lua` (which is the current cata DB), while `cataNpcDB-trinity.lua` is the trinity output which should be merged.
    - The `printToFile` import is an exception
3. Modify the DB files, so they actually return the database tables
    - They need to start with `return {` and end with a `}`
4. Run the `merge.lua` script
5. The output will be in the `output/merged-file.lua`
6. Take the content of the `output/merged-file.lua` and replace the base DB data for the correct expansion with it

### Update with TBC and WotLK data

NPCs and objects also have a `merge-tbc-wotlk-cata.lua` script. These scripts re-use the spawn data from the TBC and WotLK DB, because the data of the cata DB (both mangos and trinity) has worse spawn data. You run this script just the `merge.lua` above.

### MoP

Use the `merge-cata-mop.lua` script to merge the cata DB with the mop DB. This will take all pre-mop data from the cata DB.

Use the `extractMopIds.lua` script to extract the mop ids from the cata DB. This will create a new file called `mopIds.txt` which contains all quest ID which were added with MoP. Use it in the sqlua repository, to get all quests that were added with MoP.
