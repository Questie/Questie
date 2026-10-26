---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")

-------------------------
--Import modules.
-------------------------
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptionsEngine.tabs.profiles = { ... }

local selectedDeleteProfile = nil

---Refreshes Questie visuals and option controls when a profile is changed
local function _OnProfileChanged()
    if Questie.SetIcons then
        Questie:SetIcons()
    end
    if QuestieMap and QuestieMap.RescaleIcons then
        QuestieMap:RescaleIcons()
        QuestieMap:RescaleTownsfolkIcons()
    end
    if QuestieQuest and QuestieQuest.SmoothReset then
        QuestieQuest:SmoothReset()
    end
    if QuestieTracker and QuestieTracker.Update then
        QuestieTracker:Update()
    end
    if QuestieNameplate and QuestieNameplate.RedrawIcons then
        QuestieNameplate:RedrawIcons()
    end
    QuestieOptionsEngine:RefreshStates()
end

---Returns existing profiles PLUS AceDB standard stand-in presets
---@return table<string, string>
local function _GetChooseProfiles()
    local profiles = {}

    for _, name in ipairs(Questie.db:GetProfiles({})) do
        profiles[name] = name
    end

    local keys = Questie.db.keys
    local localizedClass = UnitClass("player")

    profiles["Default"] = l10n("Default")

    if keys.char then
        profiles[keys.char] = keys.char
    end

    if keys.class then
        profiles[keys.class] = localizedClass or keys.class
    end

    if keys.realm then
        profiles[keys.realm] = keys.realm
    end

    return profiles
end

---Returns only profiles that ACTUALLY exist in the database, excluding the current profile
---@return table<string, string>
local function _GetExistingNonActiveProfiles()
    local profiles = {}
    local current = Questie.db:GetCurrentProfile()
    for _, name in ipairs(Questie.db:GetProfiles({})) do
        if name ~= current then
            profiles[name] = name
        end
    end
    return profiles
end

---Checks whether any non-active saved profile exists
---@return boolean
local function _HasExistingNonActiveProfiles()
    return next(_GetExistingNonActiveProfiles()) ~= nil
end

function QuestieOptionsEngine.tabs.profiles:Initialize()
    -- Register AceDB callbacks to keep profile display and dropdowns synced
    if Questie.db and Questie.db.RegisterCallback then
        Questie.db.RegisterCallback(QuestieOptionsEngine.tabs.profiles, "OnProfileChanged", _OnProfileChanged)
        Questie.db.RegisterCallback(QuestieOptionsEngine.tabs.profiles, "OnProfileCopied", _OnProfileChanged)
        Questie.db.RegisterCallback(QuestieOptionsEngine.tabs.profiles, "OnProfileReset", _OnProfileChanged)
    end

    return {
        title = "Profiles",
        subtitle = "Manage Profiles",
        order = 7,
        icon = 136047,
        items = {
            intro_text = {
                type = "text",
                order = 0.5,
                description = "You can change the active database profile, so you can have different settings for every character.",
                descriptionAlign = "CENTER",
                --descriptionSize = 11,
                width = "full",
            },
            current_profile_header = {
                type = "text",
                order = 1,
                width = 0.6,
                titleAlign = "RIGHT",
                get = function()
                    local current = Questie.db:GetCurrentProfile() or "Default"
                    return l10n("Current Profile: %s", Questie:Colorize(current, "yellow"))
                end,
            },
            reset_profile = {
                type = "button",
                order = 2,
                title = "Reset Profile",
                btnLabel = "Reset Profile",
                tooltip = "Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over.",
                width = 0.39,
                align = "LEFT",
                func = function()
                    Popup.Show("QUESTIE_PROFILE_RESET_CONFIRM")
                end,
            },
            choose_desc = {
                type = "text",
                order = 3,
                title = "",
                description = "You can either create a new profile by entering a name in the editbox, or choose one of the already existing profiles.",
                width = "full",
                newline = true,
            },
            new_profile = {
                type = "textbox",
                order = 4,
                title = "New",
                tooltip = "Create a new empty profile.",
                width = "half",
                get = function()
                    return ""
                end,
                set = function(val)
                    val = strtrim(val or "")
                    if val ~= "" then
                        selectedDeleteProfile = nil
                        Questie.db:SetProfile(val)
                    end
                end,
            },
            existing_profiles = {
                type = "dropdown",
                order = 5,
                title = "Existing Profiles",
                tooltip = "Select one of your currently available profiles.",
                width = "half",
                options = _GetChooseProfiles,
                get = function()
                    return Questie.db:GetCurrentProfile()
                end,
                set = function(val)
                    if val and val ~= Questie.db:GetCurrentProfile() then
                        if selectedDeleteProfile == val then
                            selectedDeleteProfile = nil
                        end
                        Questie.db:SetProfile(val)
                        _OnProfileChanged()
                    end
                end,
            },
            copy_divider = {
                type = "divider",
                order = 6,
                title = "Copy From",
                width = "full",
            },
            copy_desc = {
                type = "text",
                order = 7,
                title = "",
                description = "Copy the settings from one existing profile into the currently active profile.",
                width = "full",
            },
            copy_profile = {
                type = "dropdown",
                order = 8,
                title = "Copy From",
                tooltip = "Copy the settings from one existing profile into the currently active profile.",
                width = "half",
                options = _GetExistingNonActiveProfiles,
                enabled = _HasExistingNonActiveProfiles,
                get = function()
                    return nil
                end,
                set = function(val)
                    if val then
                        Questie.db:CopyProfile(val)
                        _OnProfileChanged()
                    end
                end,
            },
            delete_divider = {
                type = "divider",
                order = 9,
                title = "Delete a Profile",
                width = "full",
            },
            delete_desc = {
                type = "text",
                order = 10,
                title = "",
                description = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file.",
                width = "full",
            },
            delete_dropdown = {
                type = "dropdown",
                order = 11,
                title = "Profiles",
                tooltip = "Select a profile to delete from the database.",
                width = "half",
                options = _GetExistingNonActiveProfiles,
                enabled = _HasExistingNonActiveProfiles,
                get = function()
                    if selectedDeleteProfile and _GetExistingNonActiveProfiles()[selectedDeleteProfile] then
                        return selectedDeleteProfile
                    end
                    selectedDeleteProfile = nil
                    return nil
                end,
                set = function(val)
                    selectedDeleteProfile = val
                end,
            },
            delete_button = {
                type = "button",
                order = 12,
                title = "Delete",
                btnLabel = "Delete",
                tooltip = "Deletes the selected profile from the database.",
                width = "half",
                align = "LEFT",
                enabled = function()
                    return selectedDeleteProfile ~= nil and _GetExistingNonActiveProfiles()[selectedDeleteProfile] ~= nil
                end,
                func = function()
                    if selectedDeleteProfile then
                        Popup.Show("QUESTIE_PROFILE_DELETE_CONFIRM")
                    end
                end,
            },
        },
    }
end

Popup.Dialogs["QUESTIE_PROFILE_RESET_CONFIRM"] = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        Questie.db:ResetProfile()
        _OnProfileChanged()
    end,
    OnShow = function(self)
        local current = Questie.db:GetCurrentProfile() or ""
        self.Text:SetText(l10n("Are you sure you want to reset the '%s' profile to default settings?", current))
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

Popup.Dialogs["QUESTIE_PROFILE_DELETE_CONFIRM"] = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        if selectedDeleteProfile and selectedDeleteProfile ~= Questie.db:GetCurrentProfile() then
            local toDelete = selectedDeleteProfile
            selectedDeleteProfile = nil
            Questie.db:DeleteProfile(toDelete, true)
            QuestieOptionsEngine:RefreshStates()
        end
    end,
    OnShow = function(self)
        self.Text:SetText(l10n("Are you sure you want to delete the selected profile?"))
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}