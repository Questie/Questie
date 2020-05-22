dofile("wow_api.lua")
dofile("../LibStub/LibStub.lua")
dofile("../CallbackHandler-1.0/CallbackHandler-1.0.lua")
dofile("../LibSharedMedia-3.0/LibSharedMedia-3.0.lua")

local SML = LibStub("LibSharedMedia-3.0")

local callback_result
function callback_test(...)
	callback_result = {...}
end

SML.RegisterCallback("test", "LibSharedMedia_Registered", callback_test)
SML.RegisterCallback("test", "LibSharedMedia_SetGlobal", callback_test)

-- fetch existing font
assert(SML:Fetch("font", "Morpheus") == [[Fonts\MORPHEUS.TTF]])
assert(SML:Fetch("font", "Morpheus", true) == [[Fonts\MORPHEUS.TTF]])

-- fetch non-existing font
assert(SML:Fetch("font", "random_name") == [[Fonts\FRIZQT__.TTF]])
assert(SML:Fetch("font", "random_name", true) == nil)

-- fetch non-existing type
assert(SML:Fetch("random_type", "random_name") == nil)
assert(SML:Fetch("random_type", "random_name", true) == nil)

-- register new font
callback_result = nil
assert(SML:Register("font", "newfont", "newfontfile"))
assert(callback_result[1] == "LibSharedMedia_Registered" and callback_result[2] == "font" and callback_result[3] == "newfont")

-- register existing font
callback_result = nil
assert(not SML:Register("font", "newfont", "newfontfile"))
assert(not callback_result)

-- register font disabled for current locale
callback_result = nil
assert(not SML:Register("font", "anotherfont", "anotherfontfile", SML.LOCALE_BIT_koKR))
assert(not callback_result)

-- :IsValid()
assert(SML:IsValid("font"))
assert(SML:IsValid("font", "newfont"))
assert(not SML:IsValid("random_type"))
assert(not SML:IsValid("font", "random_name"))

-- :HashTable returns handle to internal table
assert(SML:HashTable("font") == SML.MediaTable.font)
assert(SML:HashTable("random_type") == nil)

-- :List returns handle to internal table
assert(SML:List("font") == SML.MediaList.font)
assert(SML:List("random_type") == nil)

-- no global set for font
assert(SML:GetGlobal("font") == nil)

-- setting new global for font
callback_result = nil
assert(SML:SetGlobal("font", "newfont"))
assert(callback_result[1] == "LibSharedMedia_SetGlobal" and callback_result[2] == "font" and callback_result[3] == "newfont")

-- testing global for font
assert(SML:GetGlobal("font") == "newfont")

-- fetch existing font
assert(SML:Fetch("font", "Morpheus") == "newfontfile")
assert(SML:Fetch("font", "Morpheus", true) == "newfontfile")

-- fetch non-existing font
assert(SML:Fetch("font", "random_name") == "newfontfile")
assert(SML:Fetch("font", "random_name", true) == "newfontfile")

-- non-existing keys or nil reset override
callback_result = nil
assert(SML:SetGlobal("font"))
assert(callback_result[1] == "LibSharedMedia_SetGlobal" and callback_result[2] == "font" and callback_result[3] == nil)

callback_result = nil
assert(SML:SetGlobal("font", "random_name"))
assert(callback_result[1] == "LibSharedMedia_SetGlobal" and callback_result[2] == "font" and callback_result[3] == nil)

-- :SetDefault
assert(not SML:SetDefault("font", "newfont"))

------------------------------------------------
print "OK"