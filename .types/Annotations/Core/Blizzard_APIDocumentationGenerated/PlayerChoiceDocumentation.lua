---@meta _
C_PlayerChoice = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerChoice.GetCurrentPlayerChoiceInfo)
---@return PlayerChoiceInfo choiceInfo
function C_PlayerChoice.GetCurrentPlayerChoiceInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerChoice.GetNumRerolls)
---@return number numRerolls
function C_PlayerChoice.GetNumRerolls() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerChoice.GetRemainingTime)
---@return number? remainingTime
function C_PlayerChoice.GetRemainingTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerChoice.IsWaitingForPlayerChoiceResponse)
---@return boolean isWaitingForResponse
function C_PlayerChoice.IsWaitingForPlayerChoiceResponse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerChoice.OnUIClosed)
function C_PlayerChoice.OnUIClosed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerChoice.RequestRerollPlayerChoice)
function C_PlayerChoice.RequestRerollPlayerChoice() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerChoice.SendPlayerChoiceResponse)
---@param responseID number
function C_PlayerChoice.SendPlayerChoiceResponse(responseID) end

---@class PlayerChoiceInfo
---@field objectGUID WOWGUID
---@field choiceID number
---@field questionText string
---@field pendingChoiceText string
---@field uiTextureKit textureKit
---@field hideWarboardHeader boolean
---@field keepOpenAfterChoice boolean
---@field showChoicesAsList boolean
---@field options PlayerChoiceOptionInfo[]
---@field soundKitID number?
---@field closeUISoundKitID number?

---@class PlayerChoiceOptionButtonInfo
---@field id number
---@field text string
---@field disabled boolean
---@field showCheckmark boolean
---@field hideButtonShowText boolean
---@field selected boolean
---@field confirmation string?
---@field tooltip string?
---@field rewardQuestID number?
---@field soundKitID number?
---@field listText string?

---@class PlayerChoiceOptionInfo
---@field id number
---@field description string
---@field header string
---@field choiceArtID number
---@field desaturatedArt boolean
---@field disabledOption boolean
---@field hasRewards boolean
---@field rewardInfo PlayerChoiceOptionRewardInfo
---@field uiTextureKit textureKit
---@field maxStacks number
---@field buttons PlayerChoiceOptionButtonInfo[]
---@field widgetSetID number?
---@field spellID number?
---@field rarity Enum.PlayerChoiceRarity?
---@field typeArtID number?
---@field headerIconAtlasElement string?
---@field subHeader string?
---@field consolidateWidgets boolean

---@class PlayerChoiceOptionRewardInfo
---@field currencyRewards PlayerChoiceRewardCurrencyInfo[]
---@field itemRewards PlayerChoiceRewardItemInfo[]
---@field repRewards PlayerChoiceRewardReputationInfo[]

---@class PlayerChoiceRewardCurrencyInfo
---@field currencyId number
---@field name string
---@field currencyTexture number
---@field quantity number
---@field isCurrencyContainer boolean

---@class PlayerChoiceRewardItemInfo
---@field itemId number
---@field name string
---@field quantity number

---@class PlayerChoiceRewardReputationInfo
---@field factionId number
---@field quantity number
