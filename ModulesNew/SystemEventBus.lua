---@class SystemEventBus : MessageHandler
local SystemEventBus = QuestieLoader:CreateModule("SystemEventBus")

local MessageHandlerFactory = QuestieLoader:ImportModule("MessageHandlerFactory")

SystemEventBus = Mixin(SystemEventBus, MessageHandlerFactory.New("SystemEventBus")) --[[@as SystemEventBus]]


SystemEventBus.events = {
    ACE_DB_LOADED = "ACE-DB-LOADED",
    INITIALIZE_DONE = "INITIALIZE-DONE", -- Called when all modules are loaded and initialized (End of QuestieInit)

    KEY_PRESS = {
        MODIFIER_PRESSED_SHIFT      = "KEY_PRESS-KEY_PRESS_MODIFIER_PRESSED_SHIFT",
        MODIFIER_RELEASED_SHIFT     = "KEY_PRESS-KEY_PRESS_MODIFIER_RELEASED_SHIFT",
        MODIFIER_PRESSED_CTRL       = "KEY_PRESS-KEY_PRESS_MODIFIER_PRESSED_CTRL",
        MODIFIER_RELEASED_CTRL      = "KEY_PRESS-KEY_PRESS_MODIFIER_RELEASED_CTRL",
        MODIFIER_PRESSED_ALT        = "KEY_PRESS-KEY_PRESS_MODIFIER_PRESSED_ALT",
        MODIFIER_RELEASED_ALT       = "KEY_PRESS-KEY_PRESS_MODIFIER_RELEASED_ALT",
    }
}
