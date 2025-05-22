# Merger

This collection of scripts was created to merge the database files from mangos and trinity for the cata release.

## Usage

1. Check the `require` statements at the top of the merge.lua you want to run and add the required files to the folder.
    - e.g. `cataNpcDB.lua` (which is the current cata DB), while `cataNpcDB-trinity.lua` is the trinity output which should be merged.
2. Update the DB files, so they actually return the database tables
3. Run the merge.lua script

### MoP

Use the `merge-cata-mop.lua` script to merge the cata DB with the mop DB. This will take all pre-mop data from the cata DB.

Use the `extractMopIds.lua` script to extract the mop ids from the cata DB. This will create a new file called `mopIds.txt` which contains all quest ID which were added with MoP. Use it in the sqlua repository, to get all quests that were added with MoP.
