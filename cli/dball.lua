-- usage from interpreter: dbs = require("cli.dball")

local era = require("cli.dbera")
Questie = nil
local tbc = require("cli.dbtbc")
Questie = nil
local wotlk = require("cli.dbwotlk")
Questie = nil
local cata = require("cli.dbcata")
Questie = nil
local sod = require("cli.dbsod")
Questie = nil

return {["era"]=era,["tbc"]=tbc,["wotlk"]=wotlk,["cata"]=cata,["sod"]=sod}
