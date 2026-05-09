---@meta _
C_SplashScreen = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SplashScreen.AcknowledgeSplash)
function C_SplashScreen.AcknowledgeSplash() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SplashScreen.CanViewSplashScreen)
---@return boolean canView
function C_SplashScreen.CanViewSplashScreen() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SplashScreen.RequestLatestSplashScreen)
---@param fromGameMenu boolean
function C_SplashScreen.RequestLatestSplashScreen(fromGameMenu) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SplashScreen.SendSplashScreenActionLaunchedTelem)
function C_SplashScreen.SendSplashScreenActionLaunchedTelem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SplashScreen.SendSplashScreenCloseTelem)
function C_SplashScreen.SendSplashScreenCloseTelem() end

---@class SplashScreenInfo
---@field textureKit textureKit
---@field minDisplayCharLevel number
---@field minQuestDisplayLevel number
---@field soundKitID number
---@field allianceQuestID number?
---@field hordeQuestID number?
---@field header string
---@field topLeftFeatureTitle string
---@field topLeftFeatureDesc string
---@field bottomLeftFeatureTitle string
---@field bottomLeftFeatureDesc string
---@field rightFeatureTitle string
---@field rightFeatureDesc string
---@field shouldShowQuest boolean
---@field screenType Enum.SplashScreenType
---@field gameMenuRequest boolean
