#!/bin/bash
#apt-get update
#apt-get install -y git gcc
#luarocks install binser
#luarocks install serpent
#luarocks install penlight
#luarocks install lua-nucleo
cd code
# Entity database validation is owned by QuestieTDB.
lua ./cli/validate-loader-usage.lua
