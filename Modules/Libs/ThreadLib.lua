---@class ThreadLib
local ThreadLib = QuestieLoader:CreateModule("ThreadLib")

--Coroutine functions
local coStatus, coResume, coCreate = coroutine.status, coroutine.resume, coroutine.create
local lType = type
-- local cTimer = C_Timer
local newTicker = C_Timer.NewTicker

---@alias ThreadLibProfilingCallbackName "OnThreadCreated"|"BeforeResume"|"AfterResume"

---@class ThreadLibProfilingCallbacks
---@field OnThreadCreated? fun(thread: thread, submittedFunction: function, callSiteStack: string?, threadName: string?)
---@field BeforeResume? fun(thread: thread)
---@field AfterResume? fun(thread: thread, success: boolean, status: string, resumeValue: any)

local profilingOwner
---@type ThreadLibProfilingCallbacks?
local profilingCallbacks

---@param callbacks ThreadLibProfilingCallbacks?
---@param callbackName ThreadLibProfilingCallbackName
---@param ... any
local function CallProfilingCallback(callbacks, callbackName, ...)
    local callback = callbacks and callbacks[callbackName]
    if not callback then
        return
    end

    -- Lua 5.1 cannot yield across pcall's C boundary; this isolates failures and forbids observer yields through the scheduler.
    local success, callbackError = pcall(callback, ...)
    if not success then
        Questie.Error("ThreadLib profiling callback failed", callbackName, callbackError)
    end
end

---Registers or replaces the callback set owned by `owner` for ThreadLib coroutine resumes.
---A foreign owner is rejected until the current owner clears its registration.
---@param owner table @Only this owner can clear the callback registration
---@param callbacks ThreadLibProfilingCallbacks?
---@return boolean accepted
function ThreadLib.SetProfilingCallbacks(owner, callbacks)
    if profilingOwner and profilingOwner ~= owner then
        return false
    end

    profilingOwner = owner
    profilingCallbacks = callbacks
    return true
end

---Clears profiling callbacks when called by their owner.
---@param owner table
function ThreadLib.ClearProfilingCallbacks(owner)
    if profilingOwner == owner then
        profilingOwner = nil
        profilingCallbacks = nil
    end
end

---Thread a function, callback function is called when the thread is done.
---@param threadFunction function @The function to thread
---@param delay integer @Anything below 0.05 is each frame
---@param errorMessage string? @What is the "Prepend" of the error message
---@param callbackFunction function? @Function to call when the thread is done
---@param errorCallback function? @Function to call when the coroutine errors; receives the error message string
---@param threadName string? @Stable operation name for profiling this job
---@return Ticker Timer @The WoW timer, run Timer:Cancel() and let the handle of the thread become orphaned to cancel
---@return thread Thread @The coroutine thread
function ThreadLib.Thread(threadFunction, delay, errorMessage, callbackFunction, errorCallback, threadName)
  if lType(threadFunction) ~= "function" then
    error("ThreadLib:Thread: threadFunction is not a function")
  end
  if lType(delay) ~= "number" then
    error("ThreadLib:Thread: delay is not a number")
  end
  if errorMessage and lType(errorMessage) ~= "string" then
    error("ThreadLib:Thread: errorMessage is not a string")
  end
  if callbackFunction and lType(callbackFunction) ~= "function" and (lType(callbackFunction) ~= "table" or not getmetatable(callbackFunction).__call) then
    error("ThreadLib:Thread: callbackFunction is not a function")
  end
  if errorCallback and lType(errorCallback) ~= "function" and (lType(errorCallback) ~= "table" or not getmetatable(errorCallback).__call) then
    error("ThreadLib:Thread: errorCallback is not a function")
  end
  if threadName ~= nil and lType(threadName) ~= "string" then
    error("ThreadLib:Thread: threadName is not a string")
  end

  local thread = coCreate(threadFunction)
  if profilingCallbacks and profilingCallbacks.OnThreadCreated then
    local callSiteStack
    -- An explicit name is the job's whole identity, so the observer never reads the stack for a named job.
    -- Collecting it anyway priced every named submission at a debugstack call - hundreds per batch in the
    -- busiest submitters - inside the very session being measured.
    if (threadName == nil or threadName == "") and lType(debugstack) == "function" then
      local stackCollected, boundedStack = pcall(debugstack, 2, 12, 0)
      if stackCollected then
        callSiteStack = boundedStack
      end
    end
    CallProfilingCallback(profilingCallbacks, "OnThreadCreated", thread, threadFunction, callSiteStack, threadName)
  end

  local timer
  timer = newTicker(delay or 0, function()
      if(coStatus(thread) == "suspended") then --It's faster not to lookup the value but instead have it here
        -- The callback set active before resume owns both boundaries, even if resumed code replaces the registration.
        -- Tested rather than called when absent: this runs on every resume of every thread, so with no profiler
        -- attached it must cost a nil check and nothing more.
        local resumeCallbacks = profilingCallbacks
        if resumeCallbacks then
            CallProfilingCallback(resumeCallbacks, "BeforeResume", thread)
        end
        local success, ret = coResume(thread)
        if resumeCallbacks then
            CallProfilingCallback(resumeCallbacks, "AfterResume", thread, success, coStatus(thread), ret)
        end

        -- Something in the coroutine went wrong, print the error and stop the timer
        if not success then
            local stack = debugstack(thread)
            Questie.Error(errorMessage or "Error in thread", ret, "\n", stack)
            timer:Cancel();
            if errorCallback then
                errorCallback(ret)
            end
        end
      elseif (coStatus(thread) == "dead") then --It's faster not to lookup the value but instead have it here
        timer:Cancel();
        if(callbackFunction) then
          callbackFunction()
        end

        --? Is this needed?
        timer = nil
        ---@diagnostic disable-next-line: cast-local-type
        thread = nil
      end
  end)
  return timer, thread
end

---Thread a function, callback function is called when the thread is done.
---@param threadFunction function @The function to thread
---@param delay integer @Anything below 0.05 is each frame
---@param callbackFunction function @Function to call when the thread is done
---@return Ticker Timer @The WoW timer, run Timer:Cancel() and let the handle of the thread become orphaned to cancel
---@return thread Thread @The coroutine thread
function ThreadLib.ThreadCallback(threadFunction, delay, callbackFunction)
  return ThreadLib.Thread(threadFunction, delay, nil, callbackFunction)
end

---Thread a function, using a specific error message.
---@param threadFunction function @The function to thread
---@param delay integer @Anything below 0.05 is each frame
---@param errorMessage string @What is the "Prepend" of the error message
---@return Ticker Timer @The WoW timer, run Timer:Cancel() and let the handle of the thread become orphaned to cancel
---@return thread Thread @The coroutine thread
function ThreadLib.ThreadError(threadFunction, delay, errorMessage)
  return ThreadLib.Thread(threadFunction, delay, errorMessage)
end

---Thread a function
---@param threadFunction function @The function to thread
---@param delay integer @Anything below 0.05 is each frame
---@return Ticker Timer @The WoW timer, run Timer:Cancel() and let the handle of the thread become orphaned to cancel
---@return thread Thread @The coroutine thread
function ThreadLib.ThreadSimple(threadFunction, delay)
  return ThreadLib.Thread(threadFunction, delay)
end

---Thread a function and start it instantly
---@param threadFunction function @The function to thread
---@return Ticker Timer @The WoW timer, run Timer:Cancel() and let the handle of the thread become orphaned to cancel
---@return thread Thread @The coroutine thread
function ThreadLib.ThreadInstant(threadFunction)
  return ThreadLib.Thread(threadFunction, 0)
end

---Thread a function and start it instantly. Callback function is called when the thread is done.
---@param threadFunction function @The function to thread
---@param callbackFunction function @Function to call when the thread is done
---@return Ticker Timer @The WoW timer, run Timer:Cancel() and let the handle of the thread become orphaned to cancel
---@return thread Thread @The coroutine thread
function ThreadLib.ThreadCallbackInstant(threadFunction, callbackFunction)
  return ThreadLib.Thread(threadFunction, 0, nil, callbackFunction)
end


--? This was kind of a halv baked idea, that i questioned was even good, but i don't really want to delete it yet.
--[[

  ---@class Thread
  ---@field private _thread thread
  ---@field private _timer Ticker
  ---@field private _callback function?
  ---@field Kill fun()
  local newThread = {
    _thread = coCreate(threadFunction),
    _callback = callbackFunction,

    Continue = ThreadContinue,

    ---@param self Thread
    Kill = function(self)
      print(Questie.DEBUG_CRITICAL, "[ThreadLib] Thread cancelled")
      self._timer:Cancel()
      self._thread = nil
      self._timer = nil
      self.Kill = nil
      self.Continue = nil
    end
  }

  newThread._timer = newTicker(delay or 0, function()
      if(coStatus(newThread._thread) == "suspended") then --It's faster not to lookup the value but instead have it here
        local success, ret = coResume(newThread._thread)
        -- Something in the coroutine went wrong, print the error and stop the timer
        if not success then
            Questie.Error(errorMessage or "Error in thread", ret)
            newThread._timer:Cancel();
        end
      elseif (coStatus(newThread._thread) == "dead") then --It's faster not to lookup the value but instead have it here
        newThread._timer:Cancel();
        if(newThread._callback) then
          callbackFunction()
        end
        newThread._thread = nil
        newThread._timer = nil
        wipe(newThread)
      end
  end)

  return newThread

]]--
