#!/bin/bash
#apt-get update
#apt-get install -y git gcc
#luarocks install binser
#luarocks install serpent
#luarocks install penlight
#luarocks install lua-nucleo
cd code
lua ./cli/validate-era.lua
lua ./cli/validate-sod.lua
lua ./cli/validate-tbc.lua
lua ./cli/validate-wotlk.lua
