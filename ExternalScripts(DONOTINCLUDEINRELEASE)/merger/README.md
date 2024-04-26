# Merger

This collection of scripts was created to merge the database files from mangos and trinity for the cata release.

## Usage

1. Check the `require` statements at the top of the merge.lua you want to run and add the required files to the folder.
    - e.g. `cataNpcDB.lua` (which is the current cata DB), while `cataNpcDB-trinity.lua` is the trinity output which should be merged.
2. Update the DB files, so they actually return the database tables
3. Run the merge.lua script