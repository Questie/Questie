---@meta _
C_EncounterTimeline = {}

---Adds a predefined set of events to the timeline for display in Edit Mode.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.AddEditModeEvents)
---@return DurationSeconds loopTimerDuration
function C_EncounterTimeline.AddEditModeEvents() end

---Adds a custom event to the timeline.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.AddScriptEvent)
---@param eventInfo EncounterTimelineScriptEventRequest
---@return EncounterTimelineEventID eventID
function C_EncounterTimeline.AddScriptEvent(eventInfo) end

---Cancels all custom timeline events, removing them from the timeline.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.CancelAllScriptEvents)
function C_EncounterTimeline.CancelAllScriptEvents() end

---Removes all Edit Mode events from the timeline.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.CancelEditModeEvents)
function C_EncounterTimeline.CancelEditModeEvents() end

---Cancels a custom timeline event, removing it from the timeline.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.CancelScriptEvent)
---@param eventID EncounterTimelineEventID
function C_EncounterTimeline.CancelScriptEvent(eventID) end

---Finishes a custom timeline event, removing it from the timeline.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.FinishScriptEvent)
---@param eventID EncounterTimelineEventID
function C_EncounterTimeline.FinishScriptEvent(eventID) end

---Returns the current timestamp used for rendering the timeline display.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetCurrentTime)
---@return DurationSeconds currentTime
function C_EncounterTimeline.GetCurrentTime() end

---Returns the number of present events in the timeline by their source type.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventCountBySource)
---@param source Enum.EncounterTimelineEventSource
---@return number count
function C_EncounterTimeline.GetEventCountBySource(source) end

---Returns the duration at which timeline events will be highlighted for imminency.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventHighlightTime)
---@return DurationSeconds highlightTime
function C_EncounterTimeline.GetEventHighlightTime() end

---Returns information about a timeline event. This data is generally expected to be static for the lifetime of an event.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventInfo)
---@param eventID EncounterTimelineEventID
---@return EncounterTimelineEventInfo info
function C_EncounterTimeline.GetEventInfo(eventID) end

---Returns an unsorted list of event IDs present in the timeline.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventList)
---@return EncounterTimelineEventID[] events
function C_EncounterTimeline.GetEventList() end

---Returns the current state of a timeline event.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventState)
---@param eventID EncounterTimelineEventID
---@return Enum.EncounterTimelineEventState state
function C_EncounterTimeline.GetEventState(eventID) end

---Returns the elapsed duration of a timeline event.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventTimeElapsed)
---@param eventID EncounterTimelineEventID
---@return DurationSeconds timeElapsed
function C_EncounterTimeline.GetEventTimeElapsed(eventID) end

---Returns the remaining duration of a timeline event.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventTimeRemaining)
---@param eventID EncounterTimelineEventID
---@return DurationSeconds timeRemaining
function C_EncounterTimeline.GetEventTimeRemaining(eventID) end

---Returns a Duration object that tracks the elapsed duration of a timeline event. This object tracks the range [0, duration] of the event and automatically pauses its progression based on event state.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventTimer)
---@param eventID EncounterTimelineEventID
---@return LuaDurationObject? duration
function C_EncounterTimeline.GetEventTimer(eventID) end

---Returns information about the position of an event on the timeline.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetEventTrack)
---@param eventID EncounterTimelineEventID
---@return Enum.EncounterTimelineTrack track
---@return number? trackSortIndex
function C_EncounterTimeline.GetEventTrack(eventID) end

---Returns a sorted list of event IDs present in the timeline from shortest to longest remaining durations, meeting the requirements of the specified filters.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetSortedEventList)
---@param maxEventCount? number
---@param maxEventDuration? DurationSeconds
---@param excludeTerminalStates? boolean Default = true
---@param excludeHiddenEvents? boolean Default = true
---@return EncounterTimelineEventID[] events
function C_EncounterTimeline.GetSortedEventList(maxEventCount, maxEventDuration, excludeTerminalStates, excludeHiddenEvents) end

---Returns information for a single timeline track.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetTrackInfo)
---@param track Enum.EncounterTimelineTrack
---@return EncounterTimelineTrackInfo trackInfo
function C_EncounterTimeline.GetTrackInfo(track) end

---Returns information about all timeline tracks.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetTrackList)
---@return EncounterTimelineTrackInfo[] tracks
function C_EncounterTimeline.GetTrackList() end

---Returns the maximum permitted event duration on a single timeline track.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetTrackMaxEventDuration)
---@param track Enum.EncounterTimelineTrack
---@return DurationSeconds maxEventDuration
function C_EncounterTimeline.GetTrackMaxEventDuration(track) end

---Returns the type of a single timeline track.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetTrackType)
---@param track Enum.EncounterTimelineTrack
---@return Enum.EncounterTimelineTrackType trackType
function C_EncounterTimeline.GetTrackType(track) end

---Returns the current view type of the timeline.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.GetViewType)
---@return Enum.EncounterTimelineViewType viewType
function C_EncounterTimeline.GetViewType() end

---Returns true if the timeline contains any events in the active state.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.HasActiveEvents)
---@return boolean hasActiveEvents
function C_EncounterTimeline.HasActiveEvents() end

---Returns true if the timeline contains any events in any state.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.HasAnyEvents)
---@return boolean hasAnyEvents
function C_EncounterTimeline.HasAnyEvents() end

---Returns true if the timeline contains any events in the paused state.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.HasPausedEvents)
---@return boolean hasPausedEvents
function C_EncounterTimeline.HasPausedEvents() end

---Returns true if the timeline contains any events that are on visible tracks.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.HasVisibleEvents)
---@return boolean hasVisibleEvents
function C_EncounterTimeline.HasVisibleEvents() end

---Returns true if the event is in a 'blocked' state, where the cast for this event may not occur due to encounter conditions not being met.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.IsEventBlocked)
---@param eventID EncounterTimelineEventID
---@return boolean blocked
function C_EncounterTimeline.IsEventBlocked(eventID) end

---Returns true if the encounter timeline feature is available on this client.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.IsFeatureAvailable)
---@return boolean isAvailable
function C_EncounterTimeline.IsFeatureAvailable() end

---Returns true if the encounter timeline feature has been enabled by the player. This function will always return false if the feature is not available.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.IsFeatureEnabled)
---@return boolean isAvailableAndEnabled
function C_EncounterTimeline.IsFeatureEnabled() end

---Pauses a custom timeline event, hiding it from the timeline. A paused event can later be resumed to show it again, or canceled.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.PauseScriptEvent)
---@param eventID EncounterTimelineEventID
function C_EncounterTimeline.PauseScriptEvent(eventID) end

---Resumes a custom timeline event, showing it on the timeline again if it is currently paused.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.ResumeScriptEvent)
---@param eventID EncounterTimelineEventID
function C_EncounterTimeline.ResumeScriptEvent(eventID) end

---Updates a given vector of texture objects to reference art assets for icons associated with an event.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.SetEventIconTextures)
---@param eventID EncounterTimelineEventID
---@param includeIcons Enum.EncounterEventIconmask
---@param textures SimpleTexture[]
function C_EncounterTimeline.SetEventIconTextures(eventID, includeIcons, textures) end

---Changes the view type for the timeline. This adjusts track layouts to be more appropriate for a specific mode and optimizes event processing.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterTimeline.SetViewType)
---@param viewType Enum.EncounterTimelineViewType
function C_EncounterTimeline.SetViewType(viewType) end

---@class EncounterTimelineEventFilter
---@field maxEventCount number?
---@field maxEventDuration DurationSeconds?
---@field excludeTerminalStates boolean? Default = true
---@field excludeHiddenEvents boolean? Default = true

---@class EncounterTimelineEventInfo
---@field id EncounterTimelineEventID
---@field source Enum.EncounterTimelineEventSource
---@field spellName string
---@field spellID number
---@field iconFileID fileID
---@field duration DurationSeconds
---@field maxQueueDuration DurationSeconds
---@field icons Enum.EncounterEventIconmask
---@field severity Enum.EncounterEventSeverity
---@field color colorRGB
---@field isApproximate boolean

---@class EncounterTimelineScriptEventRequest
---@field spellID number
---@field iconFileID fileID
---@field duration DurationSeconds
---@field maxQueueDuration DurationSeconds? Default = 0
---@field overrideName stringView? Default = 
---@field icons Enum.EncounterEventIconmask?
---@field severity Enum.EncounterEventSeverity? Default = Medium
---@field paused boolean? Default = false

---@class EncounterTimelineTrackInfo
---@field id Enum.EncounterTimelineTrack
---@field type Enum.EncounterTimelineTrackType
---@field minimumDuration DurationSeconds?
---@field maximumDuration DurationSeconds?
---@field minimumEventIntroDuration DurationSeconds?
---@field minimumEventGapDuration DurationSeconds?
---@field maximumEventCount number?
---@field sortDirection Enum.EncounterTimelineEventSortDirection?
