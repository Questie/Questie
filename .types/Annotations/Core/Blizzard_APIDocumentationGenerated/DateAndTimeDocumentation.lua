---@meta _
C_DateAndTime = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.AdjustTimeByDays)
---@param date CalendarTime
---@param days number
---@return CalendarTime newDate
function C_DateAndTime.AdjustTimeByDays(date, days) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.AdjustTimeByMinutes)
---@param date CalendarTime
---@param minutes number
---@return CalendarTime newDate
function C_DateAndTime.AdjustTimeByMinutes(date, minutes) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.AdjustTimeByMonths)
---@param date CalendarTime
---@param months number
---@return CalendarTime newDate
function C_DateAndTime.AdjustTimeByMonths(date, months) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.CompareCalendarTime)
---@param lhsCalendarTime CalendarTime
---@param rhsCalendarTime CalendarTime
---@return number comparison
function C_DateAndTime.CompareCalendarTime(lhsCalendarTime, rhsCalendarTime) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.GetCalendarTimeFromEpoch)
---@param epoch BigUInteger
---@return CalendarTime date
function C_DateAndTime.GetCalendarTimeFromEpoch(epoch) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.GetCurrentCalendarTime)
---@return CalendarTime date
function C_DateAndTime.GetCurrentCalendarTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.GetSecondsUntilDailyReset)
---@return time_t seconds
function C_DateAndTime.GetSecondsUntilDailyReset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.GetSecondsUntilWeeklyReset)
---@return time_t seconds
function C_DateAndTime.GetSecondsUntilWeeklyReset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.GetServerTimeLocal)
---@return time_t serverTimeLocal
function C_DateAndTime.GetServerTimeLocal() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.GetWeeklyResetStartTime)
---@return time_t seconds
function C_DateAndTime.GetWeeklyResetStartTime() end
