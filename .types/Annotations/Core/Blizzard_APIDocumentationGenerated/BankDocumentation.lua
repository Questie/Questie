---@meta _
C_Bank = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.AreAnyBankTypesViewable)
---@return boolean areAnyBankTypesViewable
function C_Bank.AreAnyBankTypesViewable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.AutoDepositItemsIntoBank)
---@param bankType Enum.BankType
function C_Bank.AutoDepositItemsIntoBank(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.CanDepositMoney)
---@param bankType Enum.BankType
---@return boolean canDepositMoney
function C_Bank.CanDepositMoney(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.CanPurchaseBankTab)
---@param bankType Enum.BankType
---@return boolean canPurchaseBankTab
function C_Bank.CanPurchaseBankTab(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.CanUseBank)
---@param bankType Enum.BankType
---@return boolean canUseBank
function C_Bank.CanUseBank(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.CanViewBank)
---@param bankType Enum.BankType
---@return boolean canViewBank
function C_Bank.CanViewBank(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.CanWithdrawMoney)
---@param bankType Enum.BankType
---@return boolean canWithdrawMoney
function C_Bank.CanWithdrawMoney(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.CloseBankFrame)
function C_Bank.CloseBankFrame() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.DepositMoney)
---@param bankType Enum.BankType
---@param amount WOWMONEY
function C_Bank.DepositMoney(bankType, amount) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.DoesBankTypeSupportAutoDeposit)
---@param bankType Enum.BankType
---@return boolean doesBankTypeSupportAutoDeposit
function C_Bank.DoesBankTypeSupportAutoDeposit(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.DoesBankTypeSupportMoneyTransfer)
---@param bankType Enum.BankType
---@return boolean doesBankTypeSupportMoneyTransfer
function C_Bank.DoesBankTypeSupportMoneyTransfer(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.FetchBankLockedReason)
---@param bankType Enum.BankType
---@return Enum.BankLockedReason? reason
function C_Bank.FetchBankLockedReason(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.FetchDepositedMoney)
---@param bankType Enum.BankType
---@return WOWMONEY amount
function C_Bank.FetchDepositedMoney(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.FetchNextPurchasableBankTabData)
---@param bankType Enum.BankType
---@return PurchasableBankTabData? nextPurchasableTabData
function C_Bank.FetchNextPurchasableBankTabData(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.FetchNumPurchasedBankTabs)
---@param bankType Enum.BankType
---@return number numPurchasedBankTabs
function C_Bank.FetchNumPurchasedBankTabs(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.FetchPurchasedBankTabData)
---@param bankType Enum.BankType
---@return BankTabData[] purchasedBankTabData
function C_Bank.FetchPurchasedBankTabData(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.FetchPurchasedBankTabIDs)
---@param bankType Enum.BankType
---@return Enum.BagIndex[] purchasedBankTabIDs
function C_Bank.FetchPurchasedBankTabIDs(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.FetchViewableBankTypes)
---@return Enum.BankType[] viewableBankTypes
function C_Bank.FetchViewableBankTypes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.HasMaxBankTabs)
---@param bankType Enum.BankType
---@return boolean hasMaxBankTabs
function C_Bank.HasMaxBankTabs(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.IsItemAllowedInBankType)
---@param bankType Enum.BankType
---@param itemLocation ItemLocation
---@return boolean isItemAllowedInBankType
function C_Bank.IsItemAllowedInBankType(bankType, itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.PurchaseBankTab)
---@param bankType Enum.BankType
function C_Bank.PurchaseBankTab(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.UpdateBankTabSettings)
---@param bankType Enum.BankType
---@param tabID Enum.BagIndex
---@param tabName string
---@param tabIcon string
---@param depositFlags Enum.BagSlotFlags
function C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Bank.WithdrawMoney)
---@param bankType Enum.BankType
---@param amount WOWMONEY
function C_Bank.WithdrawMoney(bankType, amount) end

---@class BankTabData
---@field ID number
---@field bankType Enum.BankType
---@field name string
---@field icon fileID
---@field depositFlags Enum.BagSlotFlags
---@field tabCleanupConfirmation string
---@field tabNameEditBoxHeader string

---@class PurchasableBankTabData
---@field tabCost BigUInteger
---@field canAfford boolean
---@field purchasePromptTitle string
---@field purchasePromptBody string
---@field purchasePromptConfirmation string
