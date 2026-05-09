---@meta _
C_ReportSystem = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.CanReportPlayer)
---@param playerLocation PlayerLocation
---@return boolean canReport
function C_ReportSystem.CanReportPlayer(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.CanReportPlayerForLanguage)
---@param playerLocation PlayerLocation
---@return boolean canReport
function C_ReportSystem.CanReportPlayerForLanguage(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.GetMajorCategoriesForReportType)
---@param reportType Enum.ReportType
---@return Enum.ReportMajorCategory[] majorCategories
function C_ReportSystem.GetMajorCategoriesForReportType(reportType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.GetMajorCategoryString)
---@param majorCategory Enum.ReportMajorCategory
---@return string majorCategoryString
function C_ReportSystem.GetMajorCategoryString(majorCategory) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.GetMinorCategoriesForReportTypeAndMajorCategory)
---@param reportType Enum.ReportType
---@param majorCategory Enum.ReportMajorCategory
---@return Enum.ReportMinorCategory[] minorCategories
function C_ReportSystem.GetMinorCategoriesForReportTypeAndMajorCategory(reportType, majorCategory) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.GetMinorCategoryString)
---@param minorCategory Enum.ReportMinorCategory
---@return string minorCategoryString
function C_ReportSystem.GetMinorCategoryString(minorCategory) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.ReportServerLag)
function C_ReportSystem.ReportServerLag() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.ReportStuckInCombat)
function C_ReportSystem.ReportStuckInCombat() end

---Not allowed to be called by addons
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ReportSystem.SendReport)
---@param reportInfo ReportInfo
---@param playerLocation? PlayerLocation
function C_ReportSystem.SendReport(reportInfo, playerLocation) end
