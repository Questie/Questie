---@meta _
---[FrameXML](https://www.townlong-yak.com/framexml/go/SecondsToMinutes)
---@param seconds number
---@return number
function SecondsToMinutes(seconds) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MinutesToSeconds)
---@param minutes number
---@return number
function MinutesToSeconds(minutes) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/HasTimePassed)
---@param testTime number
---@param amountOfTime number
---@return boolean
function HasTimePassed(testTime, amountOfTime) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SecondsToClock)
---@param seconds number
---@param displayZeroHours? boolean
---@return string
function SecondsToClock(seconds, displayZeroHours) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SecondsToTime)
---@param seconds number
---@param noSeconds? boolean
---@param notAbbreviated? boolean
---@param maxCount? number
---@param roundUp? boolean
---@return string
function SecondsToTime(seconds, noSeconds, notAbbreviated, maxCount, roundUp) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MinutesToTime)
---@param mins number
---@param hideDays? boolean
---@return string
function MinutesToTime(mins, hideDays) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SecondsToTimeAbbrev)
---@param seconds number
---@return string format
---@return number time
function SecondsToTimeAbbrev(seconds) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/FormatShortDate)
---@param day number
---@param month number
---@param year number
---@return string
function FormatShortDate(day, month, year) end
