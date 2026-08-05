---@meta _
---@class ContinuableContainer
ContinuableContainer = {};

---@return ContinuableContainer
function ContinuableContainer:Create() end

function ContinuableContainer:AddContinuables(tbl) end

function ContinuableContainer:AddContinuable(continuable) end

---@return boolean checkIfSatisfied
function ContinuableContainer:ContinueOnLoad(callbackFunction) end

---@return number numOutstanding
function ContinuableContainer:GetNumOutstandingLoads() end

---@return number mumOutstandingLoads
function ContinuableContainer:AreAnyLoadsOutstanding() end

function ContinuableContainer:Cancel() end

-- "private"
---@return boolean checkIfSatisfied
function ContinuableContainer:CheckIfSatisfied() end

---@return boolean areAllLoaded
function ContinuableContainer:RecheckEvictableContinuables() end
