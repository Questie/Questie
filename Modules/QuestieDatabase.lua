---A small profile database owned by Questie.
---@class QuestieDatabase
local QuestieDatabase = QuestieLoader:CreateModule("QuestieDatabase")

local function _CopyDefaults(target, defaults)
    for key, value in pairs(defaults or {}) do
        if type(value) == "table" then
            local child = target[key]
            if type(child) ~= "table" then
                child = {}
                target[key] = child
            end
            _CopyDefaults(child, value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

local function _CopyTable(source)
    local result = {}
    for key, value in pairs(source or {}) do
        if type(value) == "table" then
            result[key] = _CopyTable(value)
        else
            result[key] = value
        end
    end
    return result
end

local function _CharacterKey()
    local player, surname
    if UnitNameUnmodified then
        player, surname = UnitNameUnmodified("player")
    elseif UnitName then
        player = UnitName("player")
    else
        player = "Unknown"
    end
    if RegionalUniqueNamesEnabled and RegionalUniqueNamesEnabled() and surname then
        player = player .. " " .. tostring(surname)
    end
    local realm = GetRealmName and GetRealmName() or "Unknown"
    return player .. " - " .. realm
end

local function _FireCallbacks(db, event, ...)
    for _, registration in pairs(db._callbacks) do
        if registration.event == event then
            local callback = registration.callback
            if type(callback) == "string" then
                callback = registration.target[callback]
                if callback then
                    callback(registration.target, event, db, ...)
                end
            elseif callback then
                callback(event, db, ...)
            end
        end
    end
end

local function _BuildDb(saved, defaults)
    saved.profileKeys = saved.profileKeys or {}
    saved.profiles = saved.profiles or {}
    saved.global = saved.global or {}
    saved.char = saved.char or {}

    local charKey = _CharacterKey()
    local profileName = saved.profileKeys[charKey]
    if type(profileName) ~= "string" or profileName == "" or #profileName > 50 then
        profileName = "Default"
        saved.profileKeys[charKey] = profileName
    end

    saved.profiles[profileName] = saved.profiles[profileName] or {}
    _CopyDefaults(saved.profiles[profileName], defaults.profile)
    saved.char[charKey] = saved.char[charKey] or {}
    _CopyDefaults(saved.char[charKey], defaults.char)
    _CopyDefaults(saved.global, defaults.global)

    local db = {
        sv = saved,
        profiles = saved.profiles,
        profile = saved.profiles[profileName],
        char = saved.char[charKey],
        global = saved.global,
        keys = {profile = profileName, char = charKey},
        defaults = defaults,
        _callbacks = {},
    }

    function db:RegisterCallback(target, event, callback)
        db._callbacks[#db._callbacks + 1] = {target = target, event = event, callback = callback}
    end

    function db:GetCurrentProfile()
        return db.keys.profile
    end

    function db:GetProfiles(result)
        result = result or {}
        wipe(result)
        local count = 0
        for name in pairs(db.profiles) do
            count = count + 1
            result[count] = name
        end
        if not db.profiles[db.keys.profile] then
            count = count + 1
            result[count] = db.keys.profile
        end
        return result, count
    end

    function db:SetProfile(name)
        if name == db.keys.profile then
            return
        end
        if type(name) ~= "string" or name == "" or #name > 50 or name:match("^ +$") then
            error("Invalid profile name", 2)
        end
        db.profiles[name] = db.profiles[name] or {}
        _CopyDefaults(db.profiles[name], defaults.profile)
        db.keys.profile = name
        db.profile = db.profiles[name]
        db.sv.profileKeys[db.keys.char] = name
        _FireCallbacks(db, "OnProfileChanged", name)
    end

    function db:CopyProfile(name)
        if name == db.keys.profile then
            error("Cannot copy the active profile", 2)
        end
        if not db.profiles[name] then
            error("Profile does not exist", 2)
        end
        db.profiles[db.keys.profile] = _CopyTable(db.profiles[name])
        _CopyDefaults(db.profiles[db.keys.profile], defaults.profile)
        db.profile = db.profiles[db.keys.profile]
        _FireCallbacks(db, "OnProfileCopied", name)
    end

    function db:ResetProfile()
        db.profiles[db.keys.profile] = {}
        _CopyDefaults(db.profiles[db.keys.profile], defaults.profile)
        db.profile = db.profiles[db.keys.profile]
        _FireCallbacks(db, "OnProfileReset")
    end

    function db:DeleteProfile(name, silent)
        if name == db.keys.profile then
            error("Cannot delete the active profile", 2)
        end
        if not db.profiles[name] and not silent then
            error("Profile does not exist", 2)
        end
        db.profiles[name] = nil
    end

    return db
end

---@param savedVariable string
---@param defaults table
---@return table
function QuestieDatabase:New(savedVariable, defaults)
    local saved = _G[savedVariable]
    if type(saved) ~= "table" then
        saved = {}
        _G[savedVariable] = saved
    end
    return _BuildDb(saved, defaults)
end

return QuestieDatabase
