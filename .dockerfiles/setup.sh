#!/bin/bash
#apt-get update
#apt-get install -y git gcc
#luarocks install binser
#luarocks install serpent
#luarocks install penlight
#luarocks install lua-nucleo
luarocks install argparse
cd code
# Dump all expansions
# lua ./.dockerfiles/cli-dump.lua &

# Each expansion has its own dump
# lua ./.dockerfiles/cli-dump.lua -e classic &
# lua ./.dockerfiles/cli-dump.lua -e tbc &
# lua ./.dockerfiles/cli-dump.lua -e wotlk &

# Each expansion has its own dump for each type
lua ./.dockerfiles/cli-dump.lua -e era -d item &
lua ./.dockerfiles/cli-dump.lua -e era -d npc &
lua ./.dockerfiles/cli-dump.lua -e era -d object &
lua ./.dockerfiles/cli-dump.lua -e era -d quest &

lua ./.dockerfiles/cli-dump.lua -e tbc -d item &
lua ./.dockerfiles/cli-dump.lua -e tbc -d npc &
lua ./.dockerfiles/cli-dump.lua -e tbc -d object &
lua ./.dockerfiles/cli-dump.lua -e tbc -d quest &

lua ./.dockerfiles/cli-dump.lua -e wotlk -d item &
lua ./.dockerfiles/cli-dump.lua -e wotlk -d npc &
lua ./.dockerfiles/cli-dump.lua -e wotlk -d object &
lua ./.dockerfiles/cli-dump.lua -e wotlk -d quest &

wait
echo "Done"