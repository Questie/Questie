---@meta _

---@alias MenuResponder fun(data: any, menuInputData: MenuInputData, menu: MenuProxy): MenuResponse? # data = element:GetData()

---@alias MenuDescriptionInitializer fun(frame: Frame, elementDescription: ElementMenuDescriptionProxy, menu: MenuProxy)

---@class MenuInputData
---@field context MenuInputContext
---@field buttonName mouseButton?

---@alias MenuResponse
---| 1 # `MenuResponse.Open` - Menu remains open and unchanged
---| 2 # `MenuResponse.Refresh` - All frames in the menu are reinitialized
---| 3 # `MenuResponse.Close` - Parent menus remain open but this menu closes
---| 4 # `MenuResponse.CloseAll` - All menus close

---@alias MenuInputContext
---| 1 # `MenuInputContext.None`
---| 2 # `MenuInputContext.MouseButton`
---| 3 # `MenuInputContext.MouseWheel`

---@alias MenuGridDirection
---| 2 # `MenuConstants.VerticalGridDirection`
---| 3 # `MenuConstants.HorizontalGridDirection`
