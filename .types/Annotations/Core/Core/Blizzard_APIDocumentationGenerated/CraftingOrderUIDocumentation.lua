---@meta _
C_CraftingOrders = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.AreOrderNotesDisabled)
---@return boolean areNotesDisabled
function C_CraftingOrders.AreOrderNotesDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.CalculateCraftingOrderPostingFee)
---@param skillLineAbilityID number
---@param orderType Enum.CraftingOrderType
---@param orderDuration Enum.CraftingOrderDuration
---@return WOWMONEY deposit
function C_CraftingOrders.CalculateCraftingOrderPostingFee(skillLineAbilityID, orderType, orderDuration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.CanOrderSkillAbility)
---@param skillLineAbilityID number
---@return boolean canOrder
function C_CraftingOrders.CanOrderSkillAbility(skillLineAbilityID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.CancelOrder)
---@param orderID BigUInteger
function C_CraftingOrders.CancelOrder(orderID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.ClaimOrder)
---@param orderID BigUInteger
---@param profession Enum.Profession
function C_CraftingOrders.ClaimOrder(orderID, profession) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.CloseCrafterCraftingOrders)
function C_CraftingOrders.CloseCrafterCraftingOrders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.CloseCustomerCraftingOrders)
function C_CraftingOrders.CloseCustomerCraftingOrders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.FulfillOrder)
---@param orderID BigUInteger
---@param crafterNote string
---@param profession Enum.Profession
function C_CraftingOrders.FulfillOrder(orderID, crafterNote, profession) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetClaimedOrder)
---@return CraftingOrderInfo? order
function C_CraftingOrders.GetClaimedOrder() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetCrafterBuckets)
---@return CraftingOrderBucketInfo[] buckets
function C_CraftingOrders.GetCrafterBuckets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetCrafterOrders)
---@return CraftingOrderInfo[] orders
function C_CraftingOrders.GetCrafterOrders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetCraftingOrderTime)
---@return BigUInteger time
function C_CraftingOrders.GetCraftingOrderTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetCustomerCategories)
---@return CraftingOrderCustomerCategory[] categories
function C_CraftingOrders.GetCustomerCategories() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetCustomerOptions)
---@param params CraftingOrderCustomerSearchParams
---@return CraftingOrderCustomerSearchResults results
function C_CraftingOrders.GetCustomerOptions(params) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetCustomerOrders)
---@return CraftingOrderInfo[] customerOrders
function C_CraftingOrders.GetCustomerOrders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetDefaultOrdersSkillLine)
---@return number? skillLineID
function C_CraftingOrders.GetDefaultOrdersSkillLine() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetMyOrders)
---@return CraftingOrderInfo[] myOrders
function C_CraftingOrders.GetMyOrders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetNumFavoriteCustomerOptions)
---@return BigUInteger numFavorites
function C_CraftingOrders.GetNumFavoriteCustomerOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetOrderClaimInfo)
---@param profession Enum.Profession
---@return CraftingOrderClaimsRemainingInfo claimInfo
function C_CraftingOrders.GetOrderClaimInfo(profession) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.GetPersonalOrdersInfo)
---@return CraftingOrderPersonalOrdersInfo[] infos
function C_CraftingOrders.GetPersonalOrdersInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.HasFavoriteCustomerOptions)
---@return boolean hasFavorites
function C_CraftingOrders.HasFavoriteCustomerOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.IsCustomerOptionFavorited)
---@param recipeID number
---@return boolean favorited
function C_CraftingOrders.IsCustomerOptionFavorited(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.ListMyOrders)
---@param request CraftingOrderRequestMyOrdersInfo
function C_CraftingOrders.ListMyOrders(request) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.OpenCrafterCraftingOrders)
function C_CraftingOrders.OpenCrafterCraftingOrders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.OpenCustomerCraftingOrders)
function C_CraftingOrders.OpenCustomerCraftingOrders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.OrderCanBeRecrafted)
---@param orderID BigUInteger
---@return boolean recraftable
function C_CraftingOrders.OrderCanBeRecrafted(orderID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.ParseCustomerOptions)
function C_CraftingOrders.ParseCustomerOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.PlaceNewOrder)
---@param orderInfo NewCraftingOrderInfo
function C_CraftingOrders.PlaceNewOrder(orderInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.RejectOrder)
---@param orderID BigUInteger
---@param crafterNote string
---@param profession Enum.Profession
function C_CraftingOrders.RejectOrder(orderID, crafterNote, profession) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.ReleaseOrder)
---@param orderID BigUInteger
---@param profession Enum.Profession
function C_CraftingOrders.ReleaseOrder(orderID, profession) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.RequestCrafterOrders)
---@param request CraftingOrderRequestInfo
function C_CraftingOrders.RequestCrafterOrders(request) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.RequestCustomerOrders)
---@param request CraftingOrderRequestInfo
function C_CraftingOrders.RequestCustomerOrders(request) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.SetCustomerOptionFavorited)
---@param recipeID number
---@param favorited boolean
function C_CraftingOrders.SetCustomerOptionFavorited(recipeID, favorited) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.ShouldShowCraftingOrderTab)
---@return boolean showTab
function C_CraftingOrders.ShouldShowCraftingOrderTab() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.SkillLineHasOrders)
---@param skillLineID number
---@return boolean hasOrders
function C_CraftingOrders.SkillLineHasOrders(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CraftingOrders.UpdateIgnoreList)
function C_CraftingOrders.UpdateIgnoreList() end

---@class CraftingOrderRequestInfo
---@field orderType Enum.CraftingOrderType
---@field selectedSkillLineAbility number?
---@field searchFavorites boolean
---@field initialNonPublicSearch boolean
---@field primarySort CraftingOrderSortInfo
---@field secondarySort CraftingOrderSortInfo
---@field forCrafter boolean
---@field offset number
---@field callback CraftingOrderRequestCallback
---@field profession Enum.Profession?

---@class CraftingOrderRequestMyOrdersInfo
---@field primarySort CraftingOrderSortInfo
---@field secondarySort CraftingOrderSortInfo
---@field offset number
---@field callback CraftingOrderRequestMyOrdersCallback
