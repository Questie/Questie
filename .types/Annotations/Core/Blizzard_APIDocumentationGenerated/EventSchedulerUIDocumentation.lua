---@meta _
C_EventScheduler = {}

---Clears reminder on a scheduled event. Must use endTime to identify which specific instance in the case of repeating ones.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.ClearReminder)
---@param eventKey string
function C_EventScheduler.ClearReminder(eventKey) end

---Returns the name of the continent with current events
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.GetActiveContinentName)
---@return string name
function C_EventScheduler.GetActiveContinentName() end

---Will try to figure out a UiMap for an areaPOI.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.GetEventUiMapID)
---@param areaPoiID number
---@return number? uiMapID
function C_EventScheduler.GetEventUiMapID(areaPoiID) end

---Will try to figure out a map zone name for an areaPOI
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.GetEventZoneName)
---@param areaPoiID number
---@return string? name
function C_EventScheduler.GetEventZoneName(areaPoiID) end

---Will request data from the server on a throttle
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.GetOngoingEvents)
---@return OngoingEventInfo[] events
function C_EventScheduler.GetOngoingEvents() end

---Will request data from the server on a throttle
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.GetScheduledEvents)
---@return ScheduledEventInfo[] events
function C_EventScheduler.GetScheduledEvents() end

---True if the server sent a list, even if the list had 0 events.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.HasData)
---@return boolean hasData
function C_EventScheduler.HasData() end

---Returns whether there are any event reminders saved. Can include reminders that have expired since set and haven't gotten removed yet. Has to be called after cvars are loaded.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.HasSavedReminders)
---@return boolean hasSavedReminders
function C_EventScheduler.HasSavedReminders() end

---Requests events from the server, subject to throttle
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.RequestEvents)
function C_EventScheduler.RequestEvents() end

---Sets reminder on a scheduled event. Must use endTime to identify which specific instance in the case of repeating ones.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventScheduler.SetReminder)
---@param eventKey string
function C_EventScheduler.SetReminder(eventKey) end

---@class OngoingEventInfo
---@field areaPoiID number
---@field rewardsClaimed boolean? Default = false

---@class ScheduledEventInfo
---@field eventKey string
---@field areaPoiID number
---@field startTime time_t
---@field endTime time_t
---@field duration time_t
---@field hasReminder boolean? Default = false
---@field rewardsClaimed boolean? Default = false
