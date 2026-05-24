---@meta _
C_GamePad = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.AddSDLMapping)
---@param platform Enum.ClientPlatformType
---@param mapping string
---@return boolean success
function C_GamePad.AddSDLMapping(platform, mapping) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.ApplyConfigs)
function C_GamePad.ApplyConfigs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.AxisIndexToConfigName)
---@param axisIndex number
---@return string? configName
function C_GamePad.AxisIndexToConfigName(axisIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.ButtonBindingToIndex)
---@param bindingName string
---@return number? buttonIndex
function C_GamePad.ButtonBindingToIndex(bindingName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.ButtonIndexToBinding)
---@param buttonIndex number
---@return string? bindingName
function C_GamePad.ButtonIndexToBinding(buttonIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.ButtonIndexToConfigName)
---@param buttonIndex number
---@return string? configName
function C_GamePad.ButtonIndexToConfigName(buttonIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.ClearLedColor)
function C_GamePad.ClearLedColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.DeleteConfig)
---@param configID GamePadConfigID
function C_GamePad.DeleteConfig(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetActiveDeviceID)
---@return number deviceID
function C_GamePad.GetActiveDeviceID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetAllConfigIDs)
---@return GamePadConfigID[] configIDs
function C_GamePad.GetAllConfigIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetAllDeviceIDs)
---@return number[] deviceIDs
function C_GamePad.GetAllDeviceIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetCombinedDeviceID)
---@return number deviceID
function C_GamePad.GetCombinedDeviceID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetConfig)
---@param configID GamePadConfigID
---@return GamePadConfig? config
function C_GamePad.GetConfig(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetDeviceMappedState)
---@param deviceID? number
---@return GamePadMappedState? state
function C_GamePad.GetDeviceMappedState(deviceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetDeviceRawState)
---@param deviceID number
---@return GamePadRawState? rawState
function C_GamePad.GetDeviceRawState(deviceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetLedColor)
---@return colorRGB color
function C_GamePad.GetLedColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.GetPowerLevel)
---@param deviceID? number
---@return Enum.GamePadPowerLevel powerLevel
function C_GamePad.GetPowerLevel(deviceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.IsEnabled)
---@return boolean enabled
function C_GamePad.IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.SetConfig)
---@param config GamePadConfig
function C_GamePad.SetConfig(config) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.SetLedColor)
---@param color colorRGB
function C_GamePad.SetLedColor(color) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.SetVibration)
---@param vibrationType string
---@param intensity number
function C_GamePad.SetVibration(vibrationType, intensity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.StickIndexToConfigName)
---@param stickIndex number
---@return string? configName
function C_GamePad.StickIndexToConfigName(stickIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GamePad.StopVibration)
function C_GamePad.StopVibration() end

---@class GamePadAxisConfig
---@field axis string
---@field shift number?
---@field scale number?
---@field deadzone number?
---@field buttonThreshold number?
---@field buttonPos string?
---@field buttonNeg string?
---@field comment string?

---@class GamePadConfig
---@field comment string?
---@field name string?
---@field configID GamePadConfigID
---@field labelStyle string?
---@field rawButtonMappings GamePadRawButtonMapping[]
---@field rawAxisMappings GamePadRawAxisMapping[]
---@field axisConfigs GamePadAxisConfig[]
---@field stickConfigs GamePadStickConfig[]

---@class GamePadConfigID
---@field vendorID number?
---@field productID number?

---@class GamePadMappedState
---@field name string
---@field labelStyle string
---@field buttonCount number
---@field axisCount number
---@field stickCount number
---@field buttons boolean[]
---@field axes number[]
---@field sticks GamePadStick[]

---@class GamePadRawAxisMapping
---@field rawIndex number
---@field axis string?
---@field comment string?

---@class GamePadRawButtonMapping
---@field rawIndex number
---@field button string?
---@field axis string?
---@field axisValue number?
---@field comment string?

---@class GamePadRawState
---@field name string
---@field vendorID number
---@field productID number
---@field rawButtonCount number
---@field rawAxisCount number
---@field rawButtons boolean[]
---@field rawAxes number[]

---@class GamePadStick
---@field x number
---@field y number
---@field len number

---@class GamePadStickConfig
---@field stick string
---@field axisX string?
---@field axisY string?
---@field deadzone number?
---@field deadzoneX number?
---@field deadzoneY number?
---@field comment string?
