---@meta _
---[Documentation](https://www.townlong-yak.com/framexml/go/ReportInfoMixin)
---@class ReportInfoMixin
ReportInfoMixin = {}

function ReportInfoMixin:Clear() end

---@param mailIndex number
function ReportInfoMixin:SetMailIndex(mailIndex) end

---@param clubFinderGUID string
function ReportInfoMixin:SetClubFinderGUID(clubFinderGUID) end

---@param reportTarget string
function ReportInfoMixin:SetReportTarget(reportTarget) end

---@param comment string
function ReportInfoMixin:SetComment(comment) end

---@param groupFinderSearchResultID number
function ReportInfoMixin:SetGroupFinderSearchResultID(groupFinderSearchResultID) end

---@param groupFinderApplicantID number
function ReportInfoMixin:SetGroupFinderApplicantID(groupFinderApplicantID) end

---@param reportType Enum.ReportType
function ReportInfoMixin:SetReportType(reportType) end

---@param majorCategory Enum.ReportMajorCategory
function ReportInfoMixin:SetReportMajorCategory(majorCategory) end

---@param minorCategoryFlags Enum.ReportMinorCategory
function ReportInfoMixin:SetMinorCategoryFlags(minorCategoryFlags) end

---@param petGUID string
function ReportInfoMixin:SetPetGUID(petGUID) end

---@param reportType? Enum.ReportType
---@param majorCategory Enum.ReportMajorCategory
---@param minorCategoryFlags Enum.ReportMinorCategory
function ReportInfoMixin:SetBasicReportInfo(reportType, majorCategory, minorCategoryFlags) end
