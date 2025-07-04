---@meta _
-- ----------------------------------------------------------------------------
-- AceBucket-3.0
-- ----------------------------------------------------------------------------
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-bucket-3-0)
---@class AceBucket-3.0
local AceBucket = {}

---@param event FrameEvent|FrameEvent[] The event to listen for, or a table of events.
---@param interval number The Bucket interval (burst interval)
---@param callback? function|string The callback function to call when the event is triggered (funcref or method, defaults to a method with the event name)
--- ---
---@return string bucketHandle -- The handle of the bucket (for unregistering)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-bucket-3-0#title-2)
function AceBucket:RegisterBucketEvent(event, interval, callback) end

---@param message string|string[] The message to listen for, or a table of messages.
---@param interval number The Bucket interval (burst interval)
---@param callback? function|string The callback function, either as a function reference, or a string pointing to a method of the addon object.
--- ---
---@return string bucketHandle -- The handle of the bucket (for unregistering)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-bucket-3-0#title-3)
function AceBucket:RegisterBucketMessage(message, interval, callback) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-bucket-3-0#title-4)
function AceBucket:UnregisterAllBuckets() end

---@param handle string The handle of the bucket as returned by RegisterBucket
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-bucket-3-0#title-5)
function AceBucket:UnregisterBucket(handle) end
