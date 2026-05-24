---@meta _
Enum = {}

---@enum Enum.AccountCurrencyTransferResult
Enum.AccountCurrencyTransferResult = {
	Success = 0,
	InvalidCharacter = 1,
	CharacterLoggedIn = 2,
	InsufficientCurrency = 3,
	MaxQuantity = 4,
	InvalidCurrency = 5,
	NoValidSourceCharacter = 6,
	ServerError = 7,
	CannotUseCurrency = 8,
	TransactionInProgress = 9,
	CurrencyTransferDisabled = 10,
}

---@enum Enum.AccountData
Enum.AccountData = {
	Config = 0,
	Config2 = 1,
	Bindings = 2,
	Bindings2 = 3,
	Macros = 4,
	Macros2 = 5,
	UILayout = 6,
	ChatSettings = 7,
	TtsSettings = 8,
	TtsSettings2 = 9,
	FlaggedIDs = 10,
	FlaggedIDs2 = 11,
	ClickBindings = 12,
	UIEditModeAccount = 13,
	UIEditModeChar = 14,
	FrontendChatSettings = 15,
	CharacterListOrder = 16,
}

---@enum Enum.AccountDataUpdateStatus
Enum.AccountDataUpdateStatus = {
	AccountDataUpdateSuccess = 0,
	AccountDataUpdateFailed = 1,
	AccountDataUpdateCorrupt = 2,
	AccountDataUpdateToobig = 3,
}

---@enum Enum.AccountExportResult
Enum.AccountExportResult = {
	Success = 0,
	UnknownError = 1,
	Cancelled = 2,
	ShuttingDown = 3,
	TimedOut = 4,
	NoAccountFound = 5,
	RequestedInvalidCharacter = 6,
	RpcError = 7,
	FileInvalid = 8,
	FileWriteFailed = 9,
	Unavailable = 10,
	AlreadyInProgress = 11,
	FailedToLockAccount = 12,
	FailedToGenerateFile = 13,
}

---@enum Enum.AccountStateFlags
Enum.AccountStateFlags = {
	None = 0x0,
	LoadFailed = 0x1,
	InPetCombat = 0x2,
	AccountUpgradeComplete = 0x4,
	TokenEligCheckComplete = 0x8,
}

---@enum Enum.AccountStateLoadedFlags
Enum.AccountStateLoadedFlags = {
	None = "0x0000000000000000",
	AccountStateAchievementsLoaded = "0x0000000000000001",
	AccountStateCriteriaLoaded = "0x0000000000000002",
	AccountStateMountsLoaded = "0x0000000000000004",
	AccountStatePetjournalInitialized = "0x0000000000000008",
	AccountStateCurrencyCapsLoaded = "0x0000000000000010",
	AccountStateQuestLogLoaded = "0x0000000000000020",
	AccountStateCharactersLoaded = "0x0000000000000040",
	AccountStatePurchasesLoaded = "0x0000000000000080",
	AccountStateBpayDistributionObjectsLoaded = "0x0000000000000100",
	AccountStateArchivedPurchasesLoaded = "0x0000000000000200",
	AccountStateSettingsLoaded = "0x0000000000000400",
	AccountStateBpayAddLicenseObjectsLoaded = "0x0000000000000800",
	AccountStateItemCollectionsLoaded = "0x0000000000001000",
	AccountStateAuctionableTokensLoaded = "0x0000000000002000",
	AccountStateConsumableTokensLoaded = "0x0000000000004000",
	AccountStatePerksPastRewardsLoaded = "0x0000000000008000",
	AccountStateVasTransactionsLoaded = "0x0000000000010000",
	AccountStateBpayProductitemObjectsLoaded = "0x0000000000020000",
	AccountStateTrialBoostHistoryLoaded = "0x0000000000040000",
	AccountStateQuestCriteriaLoaded = "0x0000000000080000",
	AccountStateBattleNetAccountLoaded = "0x0000000000100000",
	AccountStateAccountCurrenciesLoaded = "0x0000000000200000",
	AccountStateRafBalanceLoaded = "0x0000000000400000",
	AccountStateRafRewardsLoaded = "0x0000000000800000",
	AccountStateDynamicCriteriaLoaded = "0x0000000001000000",
	AccountStateRafActivityLoaded = "0x0000000002000000",
	AccountStateRevokedRafRewardsLoaded = "0x0000000004000000",
	AccountStateAccountNotificationsLoaded = "0x0000000008000000",
	AccountStatePerksPendingPurchaseLoaded = "0x0000000010000000",
	AccountStateAccountWowlabsLoaded = "0x0000000020000000",
	AccountStatePerksHeldItemLoaded = "0x0000000040000000",
	AccountStatePerksPendingRewardsLoaded = "0x0000000080000000",
	AccountStateBitVectorsLoaded = "0x0000000100000000",
	AccountStateAccountFactionsLoaded = "0x0000000200000000",
	AccountStateAccountItemsLoaded = "0x0000000400000000",
	AccountStateCombinedQuestLogLoaded = "0x0000000800000000",
	AccountStateDataElementsLoaded = "0x0000001000000000",
	AccountStateWarbandsLoaded = "0x0000002000000000",
	AccountStateBanktabSettingsLoaded = "0x0000004000000000",
	AccountStateAccountMappingLoaded = "0x0000008000000000",
	AccountStateCharacterItemsLoaded = "0x0000010000000000",
	AccountStateCurrencyTransferLogLoaded = "0x0000020000000000",
	AccountStateLgVendorPurchaseLoaded = "0x0000040000000000",
	AccountStateFutureFeature01DataLoaded = "0x0000080000000000",
	AccountStateWarbandScenesLoaded = "0x0000100000000000",
}

---@enum Enum.AccountStoreCategoryType
Enum.AccountStoreCategoryType = {
	Creature = 1,
	TransmogSet = 2,
	Mount = 3,
	Icon = 4,
}

---@enum Enum.AccountStoreItemFlag
Enum.AccountStoreItemFlag = {
	DisplayDefaultArmor = 1,
	NotInGameReward = 2,
	DisplayAsNew = 4,
}

---@enum Enum.AccountStoreItemRewardType
Enum.AccountStoreItemRewardType = {
	Transmog = 1,
	Mount = 2,
	Pet = 3,
	Toy = 5,
	Illusion = 7,
	TransmogSet = 8,
	Tender = 9,
	Misc = 10,
	WarbandScene = 11,
}

---@enum Enum.AccountStoreItemStatus
Enum.AccountStoreItemStatus = {
	Unowned = 1,
	Refundable = 2,
	Owned = 3,
}

---@enum Enum.AccountStoreSettlementAction
Enum.AccountStoreSettlementAction = {
	NotSet = 0,
	Give = 1,
	Remove = 2,
}

---@enum Enum.AccountStoreState
Enum.AccountStoreState = {
	Available = 0,
	Unknown = 1,
	Unavailable = 2,
}

---@enum Enum.AccountStoreTransactionResult
Enum.AccountStoreTransactionResult = {
	Success = 0,
	Incomplete = 1,
	UnknownError = 2,
	TransactionInProgress = 3,
	InsufficientFunds = 4,
	ItemUnknown = 5,
	ItemAlreadyOwned = 6,
	ItemNotOwned = 7,
	InvalidCurrencyType = 8,
	OwnedButRefundTimeExpired = 9,
	NotSupported = 10,
	Unavailable = 11,
}

---@enum Enum.AccountStoreTransactionType
Enum.AccountStoreTransactionType = {
	Undefined = 0,
	Purchase = 1,
	Refund = 2,
	DebugResetHistory = 3,
	DebugRemoveItem = 4,
}

---@enum Enum.AccountTransType
Enum.AccountTransType = {
	ProxyForwarder = 0,
	Purchase = 1,
	Distribution = 2,
	Battlepet = 3,
	Achievements = 4,
	Criteria = 5,
	Mounts = 6,
	Characters = 7,
	Purchases = 8,
	ArchivedPurchases = 9,
	Distributions = 10,
	CurrencyCaps = 11,
	QuestLog = 12,
	CriteriaNotif = 13,
	Settings = 14,
	FixedLicense = 15,
	AddLicense = 16,
	ItemCollections = 17,
	AuctionableToken = 18,
	ConsumableToken = 19,
	VasTransaction = 20,
	Productitem = 21,
	TrialBoostHistory = 22,
	TrialBoostHistories = 23,
	QuestCriteria = 24,
	BattlenetAccount = 25,
	AccountCurrencies = 26,
	RafRecruiterAcceptances = 27,
	RafFriendMonth = 28,
	RafReward = 29,
	DynamicCriteria = 30,
	RafActivity = 31,
	CreateOrderInfo = 32,
	ProxyHonorInitialConversion = 33,
	ProxyCreateAccountHonor = 34,
	ProxyValidateAccountHonor = 35,
	ProxyGmSetHonor = 36,
	ProxyGenerateBpayID = 37,
	AccountNotifications = 38,
	PerkItemHold = 39,
	PerkPendingRewards = 40,
	PerkPastRewards = 41,
	PerkTransaction = 42,
	OutstandingRpc = 43,
	LoadWowlabs = 44,
	UpgradeAccount = 45,
	GetOrderStatusByPurchaseID = 46,
	Items = 47,
	BankTab = 48,
	Factions = 49,
	BitVectors = 50,
	CombinedQuestLog = 51,
	PlayerDataElements = 52,
	CharacterDataMerge = 53,
	AccountStore = 54,
	WarbandGroups = 55,
	Mapping = 56,
	CharacterItems = 57,
	CurrencyTransferLog = 58,
	LgVendorPurchase = 59,
	SaveWarbandGroups = 60,
	Profile = 61,
	WarbandSceneCollection = 62,
}

---@enum Enum.ActionBarOrientation
Enum.ActionBarOrientation = {
	Horizontal = 0,
	Vertical = 1,
}

---@enum Enum.ActionBarVisibleSetting
Enum.ActionBarVisibleSetting = {
	Always = 0,
	InCombat = 1,
	OutOfCombat = 2,
	Hidden = 3,
}

---@enum Enum.AddOnEnableState
Enum.AddOnEnableState = {
	None = 0,
	Some = 1,
	All = 2,
}

---@enum Enum.AddOnPerformanceMessageType
Enum.AddOnPerformanceMessageType = {
	SpecificAddOnChatWarning = 0,
	SpecificAddOnErrorDialog = 1,
	OverallAddOnErrorDialog = 2,
}

---@enum Enum.AddOnProfilerMetric
Enum.AddOnProfilerMetric = {
	SessionAverageTime = 0,
	RecentAverageTime = 1,
	EncounterAverageTime = 2,
	LastTime = 3,
	PeakTime = 4,
	CountTimeOver1Ms = 5,
	CountTimeOver5Ms = 6,
	CountTimeOver10Ms = 7,
	CountTimeOver50Ms = 8,
	CountTimeOver100Ms = 9,
	CountTimeOver500Ms = 10,
	CountTimeOver1000Ms = 11,
}

---@enum Enum.AddSoulbindConduitReason
Enum.AddSoulbindConduitReason = {
	None = 0,
	Cheat = 1,
	SpellEffect = 2,
	Upgrade = 3,
}

---@enum Enum.AnimaDiversionNodeState
Enum.AnimaDiversionNodeState = {
	Unavailable = 0,
	Available = 1,
	SelectedTemporary = 2,
	SelectedPermanent = 3,
	Cooldown = 4,
}

---@enum Enum.ArrowCalloutDirection
Enum.ArrowCalloutDirection = {
	Up = 0,
	Down = 1,
	Left = 2,
	Right = 3,
}

---@enum Enum.ArrowCalloutType
Enum.ArrowCalloutType = {
	None = 0,
	Generic = 1,
	WorldLootObject = 2,
	Tutorial = 3,
	WidgetContainerNoBorder = 4,
}

---@enum Enum.AssertDomain
Enum.AssertDomain = {
	Art = 0x1,
	Design = 0x2,
	Engineering = 0x4,
	Sound = 0x8,
	Tools = 0x10,
	Performance = 0x20,
	LiveOperations = 0x40,
}

---@enum Enum.AssistActionType
Enum.AssistActionType = {
	None = 0,
	LoungingPlayer = 1,
	GraveMarker = 2,
	PlacedVo = 3,
	PlayerGuardian = 4,
	PlayerSlayer = 5,
	CapturedBuff = 6,
}

---@enum Enum.AuctionHouseCommoditySortOrder
Enum.AuctionHouseCommoditySortOrder = {
	UnitPrice = 0,
	Quantity = 1,
}

---@enum Enum.AuctionHouseError
Enum.AuctionHouseError = {
	NotEnoughMoney = 0,
	HigherBid = 1,
	BidIncrement = 2,
	BidOwn = 3,
	ItemNotFound = 4,
	RestrictedAccountTrial = 5,
	HasRestriction = 6,
	IsBusy = 7,
	Unavailable = 8,
	ItemHasQuote = 9,
	DatabaseError = 10,
	MinBid = 11,
	NotEnoughItems = 12,
	RepairItem = 13,
	UsedCharges = 14,
	QuestItem = 15,
	BoundItem = 16,
	ConjuredItem = 17,
	LimitedDurationItem = 18,
	IsBag = 19,
	EquippedBag = 20,
	WrappedItem = 21,
	LootItem = 22,
	DoubleBid = 23,
	FavoritesMaxed = 24,
	ItemNotAvailable = 25,
	ItemBoundToAccountUntilEquip = 26,
}

---@enum Enum.AuctionHouseExtraColumn
Enum.AuctionHouseExtraColumn = {
	None = 0,
	Ilvl = 1,
	Slots = 2,
	Level = 3,
	Skill = 4,
}

---@enum Enum.AuctionHouseFilter
Enum.AuctionHouseFilter = {
	None = 0,
	UncollectedOnly = 1,
	UsableOnly = 2,
	CurrentExpansionOnly = 3,
	UpgradesOnly = 4,
	ExactMatch = 5,
	PoorQuality = 6,
	CommonQuality = 7,
	UncommonQuality = 8,
	RareQuality = 9,
	EpicQuality = 10,
	LegendaryQuality = 11,
	ArtifactQuality = 12,
	LegendaryCraftedItemOnly = 13,
}

---@enum Enum.AuctionHouseFilterCategory
Enum.AuctionHouseFilterCategory = {
	Uncategorized = 0,
	Equipment = 1,
	Rarity = 2,
}

---@enum Enum.AuctionHouseItemSortOrder
Enum.AuctionHouseItemSortOrder = {
	Bid = 0,
	Buyout = 1,
}

---@enum Enum.AuctionHouseNotification
Enum.AuctionHouseNotification = {
	BidPlaced = 0,
	AuctionRemoved = 1,
	AuctionWon = 2,
	AuctionOutbid = 3,
	AuctionSold = 4,
	AuctionExpired = 5,
}

---@enum Enum.AuctionHouseSortOrder
Enum.AuctionHouseSortOrder = {
	Price = 0,
	Name = 1,
	Level = 2,
	Bid = 3,
	Buyout = 4,
	TimeRemaining = 5,
}

---@enum Enum.AuctionHouseTimeLeftBand
Enum.AuctionHouseTimeLeftBand = {
	Short = 0,
	Medium = 1,
	Long = 2,
	VeryLong = 3,
}

---@enum Enum.AuctionStatus
Enum.AuctionStatus = {
	Active = 0,
	Sold = 1,
}

---@enum Enum.AuraFrameIconDirection
Enum.AuraFrameIconDirection = {
	Down = 0,
	Left = 0,
	Right = 1,
	Up = 1,
}

---@enum Enum.AuraFrameIconWrap
Enum.AuraFrameIconWrap = {
	Down = 0,
	Left = 0,
	Right = 1,
	Up = 1,
}

---@enum Enum.AuraFrameOrientation
Enum.AuraFrameOrientation = {
	Horizontal = 0,
	Vertical = 1,
}

---@enum Enum.AvgItemLevelCategories
Enum.AvgItemLevelCategories = {
	Base = 0,
	EquippedBase = 1,
	EquippedEffective = 2,
	PvP = 3,
	PvPWeighted = 4,
	EquippedEffectiveWeighted = 5,
}

---@enum Enum.AzeriteEssenceSlot
Enum.AzeriteEssenceSlot = {
	MainSlot = 0,
	PassiveOneSlot = 1,
	PassiveTwoSlot = 2,
	PassiveThreeSlot = 3,
}

---@enum Enum.AzeritePowerLevel
Enum.AzeritePowerLevel = {
	Base = 0,
	Upgraded = 1,
	Downgraded = 2,
}

---@enum Enum.BagFlag
Enum.BagFlag = {
	DontFindStack = 0x1,
	AlreadyOwner = 0x2,
	AlreadyBound = 0x4,
	Swap = 0x8,
	BagIsEmpty = 0x10,
	LookInInventory = 0x20,
	IgnoreBoundItemCheck = 0x40,
	StackOnly = 0x80,
	RecurseQuivers = 0x100,
	IgnoreBankcheck = 0x200,
	AllowBagsInNonBagSlots = 0x400,
	PreferQuivers = 0x800,
	SwapBags = 0x1000,
	IgnoreExisting = 0x2000,
	AllowPartialStack = 0x4000,
	LookInCharacterBankOnly = 0x8000,
	AllowBuyback = 0x10000,
	IgnorePetBankcheck = 0x20000,
	PreferPriorityBags = 0x40000,
	PreferNeutralPriorityBags = 0x80000,
	AsymmetricSwap = 0x100000,
	PreferReagentBags = 0x200000,
	IgnoreSoulbound = 0x400000,
	IgnoreReagentBags = 0x800000,
	LookInAccountBankOnly = 0x1000000,
	HasRefund = 0x2000000,
	SkipValidCountCheck = 0x4000000,
	AllowSoulboundItemInAccountBank = 0x8000000,
}

---@enum Enum.BagIndex
Enum.BagIndex = {
	Accountbanktab = -3,
	Characterbanktab = -2,
	Keyring = -1,
	Backpack = 0,
	Bag_1 = 1,
	Bag_2 = 2,
	Bag_3 = 3,
	Bag_4 = 4,
	ReagentBag = 5,
	CharacterBankTab_1 = 6,
	CharacterBankTab_2 = 7,
	CharacterBankTab_3 = 8,
	CharacterBankTab_4 = 9,
	CharacterBankTab_5 = 10,
	CharacterBankTab_6 = 11,
	AccountBankTab_1 = 12,
	AccountBankTab_2 = 13,
	AccountBankTab_3 = 14,
	AccountBankTab_4 = 15,
	AccountBankTab_5 = 16,
}

---@enum Enum.BagSlotFlags
Enum.BagSlotFlags = {
	DisableAutoSort = 0x1,
	ClassEquipment = 0x2,
	ClassConsumables = 0x4,
	ClassProfessionGoods = 0x8,
	ClassJunk = 0x10,
	ClassQuestItems = 0x20,
	ExcludeJunkSell = 0x40,
	ClassReagents = 0x80,
	ExpansionCurrent = 0x100,
	ExpansionLegacy = 0x200,
}

---@enum Enum.BagsDirection
Enum.BagsDirection = {
	Left = 0,
	Up = 0,
	Down = 1,
	Right = 1,
}

---@enum Enum.BagsOrientation
Enum.BagsOrientation = {
	Horizontal = 0,
	Vertical = 1,
}

---@enum Enum.BalanceType
Enum.BalanceType = {
	None = -1,
	Eclipse = 0,
}

---@enum Enum.BankLockedReason
Enum.BankLockedReason = {
	None = 0,
	NoAccountInventoryLock = 1,
	BankDisabled = 2,
	BankConversionFailed = 3,
}

---@enum Enum.BankType
Enum.BankType = {
	Character = 0,
	Guild = 1,
	Account = 2,
}

---@enum Enum.Base64Variant
Enum.Base64Variant = {
	Standard = 0,
	StandardUrlSafe = 1,
}

---@enum Enum.BattlePetAbilityFlag
Enum.BattlePetAbilityFlag = {
	DisplayAsHostileDebuff = 0x1,
	HideStrongWeakHints = 0x2,
	Passive = 0x4,
	ServerOnlyAura = 0x8,
	ShowCast = 0x10,
	StartOnCooldown = 0x20,
}

---@enum Enum.BattlePetAbilitySlot
Enum.BattlePetAbilitySlot = {
	A = 0,
	B = 1,
	C = 2,
}

---@enum Enum.BattlePetAbilityTargets
Enum.BattlePetAbilityTargets = {
	EnemyFrontPet = 0,
	FriendlyFrontPet = 1,
	Weather = 2,
	EnemyPad = 3,
	FriendlyPad = 4,
	EnemyBackPet_1 = 5,
	EnemyBackPet_2 = 6,
	FriendlyBackPet_1 = 7,
	FriendlyBackPet_2 = 8,
	Caster = 9,
	Owner = 10,
	Specific = 11,
	ProcTarget = 12,
}

---@enum Enum.BattlePetAbilityTurnFlag
Enum.BattlePetAbilityTurnFlag = {
	CanProcFromProc = 0x1,
	TriggerBySelf = 0x2,
	TriggerByFriend = 0x4,
	TriggerByEnemy = 0x8,
	TriggerByWeather = 0x10,
	TriggerByAuraCaster = 0x20,
}

---@enum Enum.BattlePetAbilityTurnType
Enum.BattlePetAbilityTurnType = {
	Normal = 0,
	TriggeredEffect = 1,
}

---@enum Enum.BattlePetAbilityType
Enum.BattlePetAbilityType = {
	Ability = 0,
	Aura = 1,
}

---@enum Enum.BattlePetAction
Enum.BattlePetAction = {
	None = 0,
	Ability = 1,
	SwitchPet = 2,
	Trap = 3,
	Skip = 4,
}

---@enum Enum.BattlePetBreedQuality
Enum.BattlePetBreedQuality = {
	Poor = 0,
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
}

---@enum Enum.BattlePetEffectFlags
Enum.BattlePetEffectFlags = {
	EnableAbilityPicker = 1,
	LuaNeedsAllPets = 2,
}

---@enum Enum.BattlePetEffectParamType
Enum.BattlePetEffectParamType = {
	Int = 0,
	Ability = 1,
}

---@enum Enum.BattlePetEvent
Enum.BattlePetEvent = {
	OnAuraApplied = 0,
	OnDamageTaken = 1,
	OnDamageDealt = 2,
	OnHealTaken = 3,
	OnHealDealt = 4,
	OnAuraRemoved = 5,
	OnRoundStart = 6,
	OnRoundEnd = 7,
	OnTurn = 8,
	OnAbility = 9,
	OnSwapIn = 10,
	OnSwapOut = 11,
	PostAuraTicks = 12,
}

---@enum Enum.BattlePetNpcEmote
Enum.BattlePetNpcEmote = {
	BattleUnused = 0,
	BattleStart = 1,
	BattleWin = 2,
	BattleLose = 3,
	PetSwap = 4,
	PetKill = 5,
	PetDie = 6,
	PetAbility = 7,
}

---@enum Enum.BattlePetNpcTeamFlag
Enum.BattlePetNpcTeamFlag = {
	MatchPlayerHighPetLevel = 1,
	NoPlayerXP = 2,
}

---@enum Enum.BattlePetOwner
Enum.BattlePetOwner = {
	Weather = 0,
	Ally = 1,
	Enemy = 2,
}

---@enum Enum.BattlePetSources
Enum.BattlePetSources = {
	Drop = 0,
	Quest = 1,
	Vendor = 2,
	Profession = 3,
	WildPet = 4,
	Achievement = 5,
	WorldEvent = 6,
	Promotion = 7,
	Tcg = 8,
	PetStore = 9,
	Discovery = 10,
	TradingPost = 11,
}

---@enum Enum.BattlePetSpeciesFlags
Enum.BattlePetSpeciesFlags = {
	NoRename = 0x1,
	WellKnown = 0x2,
	NotAcccountwide = 0x4,
	Capturable = 0x8,
	NotTradable = 0x10,
	HideFromJournal = 0x20,
	LegacyAccountUnique = 0x40,
	CantBattle = 0x80,
	HordeOnly = 0x100,
	AllianceOnly = 0x200,
	Boss = 0x400,
	RandomDisplay = 0x800,
	NoLicenseRequired = 0x1000,
	AddsAllowedWithBoss = 0x2000,
	HideUntilLearned = 0x4000,
	MatchPlayerHighPetLevel = 0x8000,
	NoWildPetAddsAllowed = 0x10000,
}

---@enum Enum.BattlePetStateFlag
Enum.BattlePetStateFlag = {
	None = 0x0,
	SwapOutLock = 0x1,
	TurnLock = 0x2,
	SpeedBonus = 0x4,
	Client = 0x8,
	MaxHealthBonus = 0x10,
	Stamina = 0x20,
	QualityDoesNotEffect = 0x40,
	DynamicScaling = 0x80,
	Power = 0x100,
	SpeedMult = 0x200,
	SwapInLock = 0x400,
	ServerOnly = 0x800,
}

---@enum Enum.BattlePetTypes
Enum.BattlePetTypes = {
	Humanoid = 0,
	Dragonkin = 1,
	Flying = 2,
	Undead = 3,
	Critter = 4,
	Magic = 5,
	Elemental = 6,
	Beast = 7,
	Aquatic = 8,
	Mechanical = 9,
}

---@enum Enum.BattlePetVisualFlag
Enum.BattlePetVisualFlag = {
	Test1 = 1,
	Test2 = 2,
	Test3 = 4,
}

---@enum Enum.BattlePetVisualRange
Enum.BattlePetVisualRange = {
	Melee = 0,
	Ranged = 1,
	InPlace = 2,
	PointBlank = 3,
	BehindMelee = 4,
	BehindRanged = 5,
}

---@enum Enum.BattlepayLicenseSynthesisFlags
Enum.BattlepayLicenseSynthesisFlags = {
	ForceToGameAccount = 1,
}

---@enum Enum.BattlepayProductChoiceType
Enum.BattlepayProductChoiceType = {
	ChoiceNone = 0,
	ChoiceOne = 1,
	SpecAndFaction = 2,
	VasCharacter = 3,
	VasCharacterAndName = 4,
}

---@enum Enum.BattlepayShopEntryBannerType
Enum.BattlepayShopEntryBannerType = {
	Featured = 0,
	Discount = 1,
	New = 2,
}

---@enum Enum.BattlepayShopEntryFlags
Enum.BattlepayShopEntryFlags = {
	None = 0,
}

---@enum Enum.BattlepetDbFlags
Enum.BattlepetDbFlags = {
	None = 0x0,
	Favorite = 0x1,
	Converted = 0x2,
	Revoked = 0x4,
	LockedForConvert = 0x8,
	LockMask = 0xC,
	Ability0Selection = 0x10,
	Ability1Selection = 0x20,
	Ability2Selection = 0x40,
	FanfareNeeded = 0x80,
	DisplayOverridden = 0x100,
	AcquiredViaLicense = 0x200,
	TradingPost = 0x400,
}

---@enum Enum.BattlepetDeletedReason
Enum.BattlepetDeletedReason = {
	Unknown = 0,
	PlayerReleased = 1,
	PlayerCaged = 2,
	Gm = 3,
	CageError = 4,
	DelJournal = 5,
	TradingPost = 6,
	AccountStore = 7,
}

---@enum Enum.BattlepetSlotLockCheat
Enum.BattlepetSlotLockCheat = {
	Cheat_2_Locked = -3,
	Cheat_1_Locked = -2,
	Cheat_0_Locked = -1,
	CheatOff = 0,
	UnlockAll = 1,
}

---@enum Enum.BindingSet
Enum.BindingSet = {
	Default = 0,
	Account = 1,
	Character = 2,
	Current = 3,
}

---@enum Enum.BnetAccountFlag
Enum.BnetAccountFlag = {
	None = 0x0,
	BattlePetTrainer = 0x1,
	RafVeteranNotified = 0x2,
	TwitterLinked = 0x4,
	TwitterHasTempSecret = 0x8,
	Employee = 0x10,
	EmployeeFlagIsManual = 0x20,
	AccountQuestBitFixUp = 0x40,
	AchievementsToBi = 0x80,
	InvalidTransmogsFixUp = 0x100,
	InvalidTransmogsFixUp2 = 0x200,
	GdprErased = 0x400,
	DarkRealmLightCopy = 0x800,
	QuestLogFlagsFixUp = 0x1000,
	WasSecured = 0x2000,
	LockedForExport = 0x4000,
	CanBuyAhGameTimeTokens = 0x8000,
	PetAchievementFixUp = 0x10000,
	IsLegacy = 0x20000,
	CataLegendaryMountChecked = 0x40000,
	CataLegendaryMountObtained = 0x80000,
}

---@enum Enum.BonusStatIndex
Enum.BonusStatIndex = {
	Mana = 0,
	Health = 1,
	Endurance = 2,
	Agility = 3,
	Strength = 4,
	Intellect = 5,
	SpiritUnused = 6,
	Stamina = 7,
	Energy = 8,
	Rage = 9,
	Focus = 10,
	WeaponSkillRatingObsolete = 11,
	DefenseSkillRating = 12,
	DodgeRating = 13,
	ParryRating = 14,
	BlockRating = 15,
	HitMeleeRating = 16,
	HitRangedRating = 17,
	HitSpellRating = 18,
	CritMeleeRating = 19,
	CritRangedRating = 20,
	CritSpellRating = 21,
	Corruption = 22,
	CorruptionResistance = 23,
	ModifiedCraftingStat_1 = 24,
	ModifiedCraftingStat_2 = 25,
	CritTakenRangedRatingObsolete = 26,
	CritTakenSpellRatingObsolete = 27,
	HasteMeleeRatingObsolete = 28,
	HasteRangedRatingObsolete = 29,
	HasteSpellRatingObsolete = 30,
	HitRating = 31,
	CritRating = 32,
	HitTakenRatingObsolete = 33,
	CritTakenRatingObsolete = 34,
	ResilienceRating = 35,
	HasteRating = 36,
	ExpertiseRating = 37,
	AttackPower = 38,
	RangedAttackPower = 39,
	Versatility = 40,
	SpellHealingDone = 41,
	SpellDamageDone = 42,
	ManaRegenerationObsolete = 43,
	Unused = 44,
	SpellPower = 45,
	HealthRegen = 46,
	SpellPenetration = 47,
	BlockValueObsolete = 48,
	MasteryRating = 49,
	ExtraArmor = 50,
	FireResistance = 51,
	FrostResistance = 52,
	HolyResistance = 53,
	ShadowResistance = 54,
	NatureResistance = 55,
	ArcaneResistance = 56,
	PvPPower = 57,
	CombatRatingUnused_0 = 58,
	CombatRatingUnused_2 = 59,
	CombatRatingUnused_3 = 60,
	CombatRatingSpeed = 61,
	CombatRatingLifesteal = 62,
	CombatRatingAvoidance = 63,
	CombatRatingSturdiness = 64,
	CombatRatingUnused_7 = 65,
	CombatRatingUnused_27 = 66,
	CombatRatingUnused_9 = 67,
	CombatRatingUnused_10 = 68,
	CombatRatingUnused_11 = 69,
	CombatRatingUnused_12 = 70,
	AgilityOrStrengthOrIntellect = 71,
	AgilityOrStrength = 72,
	AgilityOrIntellect = 73,
	StrengthOrIntellect = 74,
	ProfessionInspiration = 75,
	ProfessionResourcefulness = 76,
	ProfessionFinesse = 77,
	ProfessionDeftness = 78,
	ProfessionPerception = 79,
	ProfessionCraftingSpeed = 80,
	ProfessionMulticraft = 81,
	ProfessionIngenuity = 82,
}

---@enum Enum.BrawlType
Enum.BrawlType = {
	None = 0,
	Battleground = 1,
	Arena = 2,
	LFG = 3,
	SoloShuffle = 4,
	SoloRbg = 5,
}

---@enum Enum.CachedRewardType
Enum.CachedRewardType = {
	None = 0,
	Item = 1,
	Currency = 2,
	Quest = 3,
}

---@enum Enum.CalendarCommandType
Enum.CalendarCommandType = {
	Create = 0,
	Invite = 1,
	Rsvp = 2,
	RemoveInvite = 3,
	RemoveEvent = 4,
	Status = 5,
	ModeratorStatus = 6,
	GetCalendar = 7,
	GetEvent = 8,
	UpdateEvent = 9,
	Complain = 10,
	Notes = 11,
}

---@enum Enum.CalendarErrorType
Enum.CalendarErrorType = {
	Success = 0,
	CommunityEventsExceeded = 1,
	EventsExceeded = 2,
	SelfInvitesExceeded = 3,
	OtherInvitesExceeded = 4,
	NoPermission = 5,
	EventInvalid = 6,
	NotInvited = 7,
	UnknownError = 8,
	NotInGuild = 9,
	NotInCommunity = 10,
	TargetAlreadyInvited = 11,
	NameNotFound = 12,
	WrongFaction = 13,
	Ignored = 14,
	InvitesExceeded = 15,
	InvalidMaxSize = 16,
	InvalidDate = 17,
	InvalidTime = 18,
	NoInvites = 19,
	NeedsTitle = 20,
	EventPassed = 21,
	EventLocked = 22,
	DeleteCreatorFailed = 23,
	DataAlreadySet = 24,
	CalendarDisabled = 25,
	RestrictedAccount = 26,
	ArenaEventsExceeded = 27,
	RestrictedLevel = 28,
	Squelched = 29,
	NoInvite = 30,
	ComplaintDisabled = 31,
	ComplaintSelf = 32,
	ComplaintSameGuild = 33,
	ComplaintGm = 34,
	ComplaintLimit = 35,
	ComplaintNotFound = 36,
	EventWrongServer = 37,
	NoCommunityInvites = 38,
	InvalidSignup = 39,
	NoModerator = 40,
	ModeratorRestricted = 41,
	InvalidNotes = 42,
	InvalidTitle = 43,
	InvalidDescription = 44,
	InvalidClub = 45,
	CreatorNotFound = 46,
	EventThrottled = 47,
	InviteThrottled = 48,
	Internal = 49,
	ComplaintAdded = 50,
}

---@enum Enum.CalendarEventBits
Enum.CalendarEventBits = {
	Player = 0x1,
	GuildDeprecated = 0x2,
	System = 0x4,
	Holiday = 0x8,
	Locked = 0x10,
	AutoApprove = 0x20,
	CommunityAnnouncement = 0x40,
	RaidLockout = 0x80,
	ArenaDeprecated = 0x100,
	RaidResetDeprecated = 0x200,
	CommunitySignup = 0x400,
	GuildSignup = 0x800,
	CommunityWide = 0xC40,
	PlayerCreated = 0xD43,
	CantComplain = 0xECC,
}

---@enum Enum.CalendarEventRepeatOptions
Enum.CalendarEventRepeatOptions = {
	Never = 0,
	Weekly = 1,
	Biweekly = 2,
	Monthly = 3,
}

---@enum Enum.CalendarEventType
Enum.CalendarEventType = {
	Raid = 0,
	Dungeon = 1,
	PvP = 2,
	Meeting = 3,
	Other = 4,
	HeroicDeprecated = 5,
}

---@enum Enum.CalendarFilterFlags
Enum.CalendarFilterFlags = {
	WeeklyHoliday = 0x1,
	Darkmoon = 0x2,
	Battleground = 0x4,
	RaidLockout = 0x8,
	RaidReset = 0x10,
}

---@enum Enum.CalendarGetEventType
Enum.CalendarGetEventType = {
	Get = 0,
	Add = 1,
	Copy = 2,
}

---@enum Enum.CalendarHolidayFilterType
Enum.CalendarHolidayFilterType = {
	Weekly = 0,
	Darkmoon = 1,
	Battleground = 2,
}

---@enum Enum.CalendarInviteBits
Enum.CalendarInviteBits = {
	None = 0x0,
	PendingInvite = 0x1,
	Moderator = 0x2,
	Creator = 0x4,
	Signup = 0x8,
}

---@enum Enum.CalendarInviteSortType
Enum.CalendarInviteSortType = {
	Name = 0,
	Level = 1,
	Class = 2,
	Status = 3,
	Party = 4,
	Notes = 5,
}

---@enum Enum.CalendarInviteType
Enum.CalendarInviteType = {
	Normal = 0,
	Signup = 1,
}

---@enum Enum.CalendarModeratorStatus
Enum.CalendarModeratorStatus = {
	None = 0,
	Moderator = 1,
	Creator = 2,
}

---@enum Enum.CalendarStatus
Enum.CalendarStatus = {
	Invited = 0,
	Available = 1,
	Declined = 2,
	Confirmed = 3,
	Out = 4,
	Standby = 5,
	Signedup = 6,
	NotSignedup = 7,
	Tentative = 8,
}

---@enum Enum.CalendarTexturesType
Enum.CalendarTexturesType = {
	Dungeons = 0,
	Raid = 1,
}

---@enum Enum.CalendarType
Enum.CalendarType = {
	Player = 0,
	Community = 1,
	RaidLockout = 2,
	RaidResetDeprecated = 3,
	Holiday = 4,
	HolidayWeekly = 5,
	HolidayDarkmoon = 6,
	HolidayBattleground = 7,
}

---@enum Enum.CalendarWebActionType
Enum.CalendarWebActionType = {
	Accept = 0,
	Decline = 1,
	Remove = 2,
	ReportSpam = 3,
	Signup = 4,
	Tentative = 5,
	TentativeSignup = 6,
}

---@enum Enum.CallingStates
Enum.CallingStates = {
	QuestOffer = 0,
	QuestActive = 1,
	QuestCompleted = 2,
}

---@enum Enum.CameraModeAspectRatio
Enum.CameraModeAspectRatio = {
	Default = 0,
	LegacyLetterbox = 1,
	HighDefinition_16_X_9 = 2,
	Cinemascope_2_Dot_4_X_1 = 3,
}

---@enum Enum.CampaignState
Enum.CampaignState = {
	Invalid = 0,
	Complete = 1,
	InProgress = 2,
	Stalled = 3,
}

---@enum Enum.CaptureBarWidgetFillDirectionType
Enum.CaptureBarWidgetFillDirectionType = {
	RightToLeft = 0,
	LeftToRight = 1,
}

---@enum Enum.Causeofdeath
Enum.Causeofdeath = {
	None = 0,
	PlayerPvP = 1,
	PlayerDuel = 2,
	Creature = 3,
	Falling = 4,
	Drowning = 5,
	Fatigue = 6,
	Slime = 7,
	Lava = 8,
	Fire = 9,
}

---@enum Enum.CauseofdeathFlags
Enum.CauseofdeathFlags = {
	NoneNeeded = 0,
	PlayerNameNeeded = 1,
	CreatureNameNeeded = 2,
	ZoneNameNeeded = 4,
}

---@enum Enum.ChallengeModeHistoryFlags
Enum.ChallengeModeHistoryFlags = {
	None = 0,
	ConfirmedLeaver = 1,
}

---@enum Enum.ChallengeModeHistoryResult
Enum.ChallengeModeHistoryResult = {
	Successful = 0,
	Leaver = 1,
}

---@enum Enum.ChallengeModeHistoryStatus
Enum.ChallengeModeHistoryStatus = {
	Normal = 0,
	Leaver = 1,
}

---@enum Enum.ChannelPlayerFlags
Enum.ChannelPlayerFlags = {
	ChannelPlayerNone = 0x0,
	ChannelPlayerOwner = 0x1,
	ChannelPlayerModerator = 0x2,
	ChannelPlayerTextAllow = 0x4,
	ChannelPlayerHidden = 0x8,
}

---@enum Enum.CharCustomizationType
Enum.CharCustomizationType = {
	Skin = 0,
	Face = 1,
	Hair = 2,
	HairColor = 3,
	FacialHair = 4,
	CustomOptionTattoo = 5,
	CustomOptionHorn = 6,
	CustomOptionFacewear = 7,
	CustomOptionTattooColor = 8,
	Outfit = 9,
	Facepaint = 10,
	FacepaintColor = 11,
}

---@enum Enum.CharacterServiceInfoFlag
Enum.CharacterServiceInfoFlag = {
	RestrictToRecommendedSpecs = 1,
	AllowMaxLevelBoost = 2,
}

---@enum Enum.ChatChannelRuleset
Enum.ChatChannelRuleset = {
	None = 0,
	Mentor = 1,
	Disabled = 2,
	ChromieTimeCataclysm = 3,
	ChromieTimeBuringCrusade = 4,
	ChromieTimeWrath = 5,
	ChromieTimeMists = 6,
	ChromieTimeWoD = 7,
	ChromieTimeLegion = 8,
}

---@enum Enum.ChatChannelType
Enum.ChatChannelType = {
	None = 0,
	Custom = 1,
	PrivateParty = 2,
	PublicParty = 3,
	Communities = 4,
}

---@enum Enum.ChatToxityFilterOptOut
Enum.ChatToxityFilterOptOut = {
	FilterAll = 0,
	ExcludeFilterFriend = 1,
	ExcludeFilterGuild = 2,
	ExcludeFilterAll = 4294967295,
}

---@enum Enum.ChatWhisperTargetStatus
Enum.ChatWhisperTargetStatus = {
	CanWhisper = 0,
	CanWhisperGuild = 1,
	Offline = 2,
	WrongFaction = 3,
}

---@enum Enum.ChrCustomizationCategoryFlag
Enum.ChrCustomizationCategoryFlag = {
	UndressModel = 1,
	Subcategory = 2,
}

---@enum Enum.ChrCustomizationOptionType
Enum.ChrCustomizationOptionType = {
	Dropdown = 0,
	Checkbox = 1,
	Slider = 2,
}

---@enum Enum.ChrModelFeatureFlags
Enum.ChrModelFeatureFlags = {
	None = 0x0,
	Summons = 0x1,
	Forms = 0x2,
	Identity = 0x4,
	Deprecated0 = 0x8,
	Mounts = 0x10,
	HunterPets = 0x20,
	Players = 0x40,
}

---@enum Enum.ChrRacesAllianceType
Enum.ChrRacesAllianceType = {
	Alliance = 0,
	Horde = 1,
	NeutralOrNpc = 2,
}

---@enum Enum.CinematicType
Enum.CinematicType = {
	GlueMovie = 0,
	GameMovie = 1,
	GameClientScene = 2,
	GameCinematicSequence = 3,
}

---@enum Enum.ClickBindingInteraction
Enum.ClickBindingInteraction = {
	Target = 1,
	OpenContextMenu = 2,
}

---@enum Enum.ClickBindingType
Enum.ClickBindingType = {
	None = 0,
	Spell = 1,
	Macro = 2,
	Interaction = 3,
	PetAction = 4,
}

---@enum Enum.ClientPlatformType
Enum.ClientPlatformType = {
	Windows = 0,
	Macintosh = 1,
}

---@enum Enum.ClientSceneType
Enum.ClientSceneType = {
	DefaultSceneType = 0,
	MinigameSceneType = 1,
}

---@enum Enum.ClientSettingsConfigFlag
Enum.ClientSettingsConfigFlag = {
	ClientSettingsConfigDebug = 0x1,
	ClientSettingsConfigInternal = 0x2,
	ClientSettingsConfigPerf = 0x4,
	ClientSettingsConfigGm = 0x8,
	ClientSettingsConfigTest = 0x10,
	ClientSettingsConfigTestRetail = 0x20,
	ClientSettingsConfigBeta = 0x40,
	ClientSettingsConfigBetaRetail = 0x80,
	ClientSettingsConfigRetail = 0x100,
}

---@enum Enum.ClubActionType
Enum.ClubActionType = {
	ErrorClubActionSubscribe = 0,
	ErrorClubActionCreate = 1,
	ErrorClubActionEdit = 2,
	ErrorClubActionDestroy = 3,
	ErrorClubActionLeave = 4,
	ErrorClubActionCreateTicket = 5,
	ErrorClubActionDestroyTicket = 6,
	ErrorClubActionRedeemTicket = 7,
	ErrorClubActionGetTicket = 8,
	ErrorClubActionGetTickets = 9,
	ErrorClubActionGetBans = 10,
	ErrorClubActionGetInvitations = 11,
	ErrorClubActionRevokeInvitation = 12,
	ErrorClubActionAcceptInvitation = 13,
	ErrorClubActionDeclineInvitation = 14,
	ErrorClubActionCreateStream = 15,
	ErrorClubActionEditStream = 16,
	ErrorClubActionDestroyStream = 17,
	ErrorClubActionInviteMember = 18,
	ErrorClubActionEditMember = 19,
	ErrorClubActionEditMemberNote = 20,
	ErrorClubActionKickMember = 21,
	ErrorClubActionAddBan = 22,
	ErrorClubActionRemoveBan = 23,
	ErrorClubActionCreateMessage = 24,
	ErrorClubActionEditMessage = 25,
	ErrorClubActionDestroyMessage = 26,
}

---@enum Enum.ClubErrorType
Enum.ClubErrorType = {
	ErrorCommunitiesNone = 0,
	ErrorCommunitiesUnknown = 1,
	ErrorCommunitiesNeutralFaction = 2,
	ErrorCommunitiesUnknownRealm = 3,
	ErrorCommunitiesBadTarget = 4,
	ErrorCommunitiesWrongFaction = 5,
	ErrorCommunitiesRestricted = 6,
	ErrorCommunitiesIgnored = 7,
	ErrorCommunitiesGuild = 8,
	ErrorCommunitiesWrongRegion = 9,
	ErrorCommunitiesUnknownTicket = 10,
	ErrorCommunitiesMissingShortName = 11,
	ErrorCommunitiesProfanity = 12,
	ErrorCommunitiesTrial = 13,
	ErrorCommunitiesVeteranTrial = 14,
	ErrorCommunitiesChatMute = 15,
	ErrorClubFull = 16,
	ErrorClubNoClub = 17,
	ErrorClubNotMember = 18,
	ErrorClubAlreadyMember = 19,
	ErrorClubNoSuchMember = 20,
	ErrorClubNoSuchInvitation = 21,
	ErrorClubInvitationAlreadyExists = 22,
	ErrorClubInvalidRoleID = 23,
	ErrorClubInsufficientPrivileges = 24,
	ErrorClubTooManyClubsJoined = 25,
	ErrorClubVoiceFull = 26,
	ErrorClubStreamNoStream = 27,
	ErrorClubStreamInvalidName = 28,
	ErrorClubStreamCountAtMin = 29,
	ErrorClubStreamCountAtMax = 30,
	ErrorClubMemberHasRequiredRole = 31,
	ErrorClubSentInvitationCountAtMax = 32,
	ErrorClubReceivedInvitationCountAtMax = 33,
	ErrorClubTargetIsBanned = 34,
	ErrorClubBanAlreadyExists = 35,
	ErrorClubBanCountAtMax = 36,
	ErrorClubTicketCountAtMax = 37,
	ErrorClubTicketNoSuchTicket = 38,
	ErrorClubTicketHasConsumedAllowedRedeemCount = 39,
	ErrorClubDoesntAllowCrossFaction = 40,
	ErrorClubEditHasCrossFactionMembers = 41,
}

---@enum Enum.ClubFieldType
Enum.ClubFieldType = {
	ClubName = 0,
	ClubShortName = 1,
	ClubDescription = 2,
	ClubBroadcast = 3,
	ClubStreamName = 4,
	ClubStreamSubject = 5,
	NumTypes = 6,
}

---@enum Enum.ClubFinderApplicationUpdateType
Enum.ClubFinderApplicationUpdateType = {
	None = 0,
	AcceptInvite = 1,
	DeclineInvite = 2,
	Cancel = 3,
}

---@enum Enum.ClubFinderClubPostingStatusFlags
Enum.ClubFinderClubPostingStatusFlags = {
	None = 0,
	NeedsCacheUpdate = 1,
	ForceDescriptionChange = 2,
	ForceNameChange = 3,
	UnderReview = 4,
	Banned = 5,
	FakePost = 6,
	PendingDelete = 7,
	PostDelisted = 8,
}

---@enum Enum.ClubFinderDisableReason
Enum.ClubFinderDisableReason = {
	Muted = 0,
	Silenced = 1,
	VeteranTrial = 2,
}

---@enum Enum.ClubFinderPostingReportType
Enum.ClubFinderPostingReportType = {
	PostersName = 0,
	ClubName = 1,
	PostingDescription = 2,
	ApplicantsName = 3,
	JoinNote = 4,
}

---@enum Enum.ClubFinderRequestType
Enum.ClubFinderRequestType = {
	None = 0,
	Guild = 1,
	Community = 2,
	All = 3,
}

---@enum Enum.ClubFinderSettingFlags
Enum.ClubFinderSettingFlags = {
	None = 0,
	Dungeons = 1,
	Raids = 2,
	PvP = 3,
	RP = 4,
	Social = 5,
	Small = 6,
	Medium = 7,
	Large = 8,
	Tank = 9,
	Healer = 10,
	Damage = 11,
	EnableListing = 12,
	MaxLevelOnly = 13,
	AutoAccept = 14,
	FactionHorde = 15,
	FactionAlliance = 16,
	FactionNeutral = 17,
	SortRelevance = 18,
	SortMemberCount = 19,
	SortNewest = 20,
	LanguageReserved1 = 21,
	LanguageReserved2 = 22,
	LanguageReserved3 = 23,
	LanguageReserved4 = 24,
	LanguageReserved5 = 25,
}

---@enum Enum.ClubInvitationCandidateStatus
Enum.ClubInvitationCandidateStatus = {
	Available = 0,
	InvitePending = 1,
	AlreadyMember = 2,
}

---@enum Enum.ClubMemberPresence
Enum.ClubMemberPresence = {
	Unknown = 0,
	Online = 1,
	OnlineMobile = 2,
	Offline = 3,
	Away = 4,
	Busy = 5,
}

---@enum Enum.ClubRemovedReason
Enum.ClubRemovedReason = {
	None = 0,
	Banned = 1,
	Removed = 2,
	ClubDestroyed = 3,
}

---@enum Enum.ClubRestrictionReason
Enum.ClubRestrictionReason = {
	None = 0,
	Unavailable = 1,
}

---@enum Enum.ClubRoleIdentifier
Enum.ClubRoleIdentifier = {
	Owner = 1,
	Leader = 2,
	Moderator = 3,
	Member = 4,
}

---@enum Enum.ClubStreamNotificationFilter
Enum.ClubStreamNotificationFilter = {
	None = 0,
	Mention = 1,
	All = 2,
}

---@enum Enum.ClubStreamType
Enum.ClubStreamType = {
	General = 0,
	Guild = 1,
	Officer = 2,
	Other = 3,
}

---@enum Enum.ClubType
Enum.ClubType = {
	BattleNet = 0,
	Character = 1,
	Guild = 2,
	Other = 3,
}

---@enum Enum.ColorOverride
Enum.ColorOverride = {
	ItemQualityPoor = 0,
	ItemQualityCommon = 1,
	ItemQualityUncommon = 2,
	ItemQualityRare = 3,
	ItemQualityEpic = 4,
	ItemQualityLegendary = 5,
	ItemQualityArtifact = 6,
	ItemQualityAccount = 7,
}

---@enum Enum.CombinedQuestLogStatus
Enum.CombinedQuestLogStatus = {
	Available = 0,
	Complete = 1,
	CompleteDaily = 2,
	CompleteWeekly = 3,
	CompleteMonthly = 4,
	CompleteYearly = 5,
	CompleteGameReset = 6,
	Reset = 7,
}

---@enum Enum.CombinedQuestStatus
Enum.CombinedQuestStatus = {
	Invalid = 0,
	Completed = 1,
	NotCompleted = 2,
}

---@enum Enum.CommunicationMode
Enum.CommunicationMode = {
	PushToTalk = 0,
	OpenMic = 1,
}

---@enum Enum.CompanionConfigSlotTypes
Enum.CompanionConfigSlotTypes = {
	Role = 0,
	Utility = 1,
	Combat = 2,
}

---@enum Enum.CompanionRoleType
Enum.CompanionRoleType = {
	Dps = 0,
	Heal = 1,
	Tank = 2,
}

---@enum Enum.CompressionLevel
Enum.CompressionLevel = {
	Default = 0,
	OptimizeForSpeed = 1,
	OptimizeForSize = 2,
}

---@enum Enum.CompressionMethod
Enum.CompressionMethod = {
	Deflate = 0,
	Zlib = 1,
	Gzip = 2,
}

---@enum Enum.ConquestProgressBarDisplayType
Enum.ConquestProgressBarDisplayType = {
	FirstChest = 0,
	AdditionalChest = 1,
	Seasonal = 2,
}

---@enum Enum.ConsoleCategory
Enum.ConsoleCategory = {
	Debug = 0,
	Graphics = 1,
	Console = 2,
	Combat = 3,
	Game = 4,
	Default = 5,
	Net = 6,
	Sound = 7,
	Gm = 8,
	Reveal = 9,
	None = 10,
}

---@enum Enum.ConsoleColorType
Enum.ConsoleColorType = {
	DefaultColor = 0,
	InputColor = 1,
	EchoColor = 2,
	ErrorColor = 3,
	WarningColor = 4,
	GlobalColor = 5,
	AdminColor = 6,
	HighlightColor = 7,
	BackgroundColor = 8,
	ClickbufferColor = 9,
	PrivateColor = 10,
	DefaultGreen = 11,
}

---@enum Enum.ConsoleCommandType
Enum.ConsoleCommandType = {
	Cvar = 0,
	Command = 1,
	Macro = 2,
	Script = 3,
}

---@enum Enum.ContentTrackingError
Enum.ContentTrackingError = {
	Untrackable = 0,
	MaxTracked = 1,
	AlreadyTracked = 2,
}

---@enum Enum.ContentTrackingResult
Enum.ContentTrackingResult = {
	Success = 0,
	DataPending = 1,
	Failure = 2,
}

---@enum Enum.ContentTrackingStopType
Enum.ContentTrackingStopType = {
	Invalidated = 0,
	Collected = 1,
	Manual = 2,
}

---@enum Enum.ContentTrackingTargetType
Enum.ContentTrackingTargetType = {
	JournalEncounter = 0,
	Vendor = 1,
	Achievement = 2,
	Profession = 3,
	Quest = 4,
}

---@enum Enum.ContentTrackingType
Enum.ContentTrackingType = {
	Appearance = 0,
	Mount = 1,
	Achievement = 2,
}

---@enum Enum.ContributionAppearanceFlags
Enum.ContributionAppearanceFlags = {
	TooltipUseTimeRemaining = 0,
}

---@enum Enum.ContributionResult
Enum.ContributionResult = {
	Success = 0,
	MustBeNearNpc = 1,
	IncorrectState = 2,
	InvalidID = 3,
	QuestDataMissing = 4,
	FailedConditionCheck = 5,
	UnableToCompleteTurnIn = 6,
	InternalError = 7,
}

---@enum Enum.ContributionState
Enum.ContributionState = {
	None = 0,
	Building = 1,
	Active = 2,
	UnderAttack = 3,
	Destroyed = 4,
}

---@enum Enum.CooldownSetSpellFlags
Enum.CooldownSetSpellFlags = {
	HideAura = 1,
	PlaceHolder1 = 2,
}

---@enum Enum.CooldownViewerBarContent
Enum.CooldownViewerBarContent = {
	IconAndName = 0,
	IconOnly = 1,
	NameOnly = 2,
}

---@enum Enum.CooldownViewerCategory
Enum.CooldownViewerCategory = {
	Essential = 0,
	Utility = 1,
	TrackedBuff = 2,
	TrackedBar = 3,
}

---@enum Enum.CooldownViewerIconDirection
Enum.CooldownViewerIconDirection = {
	Left = 0,
	Right = 1,
}

---@enum Enum.CooldownViewerOrientation
Enum.CooldownViewerOrientation = {
	Horizontal = 0,
	Vertical = 1,
}

---@enum Enum.CooldownViewerVisibleSetting
Enum.CooldownViewerVisibleSetting = {
	Always = 0,
	InCombat = 1,
	Hidden = 2,
}

---@enum Enum.CovenantAbilityType
Enum.CovenantAbilityType = {
	Class = 0,
	Signature = 1,
	Soulbind = 2,
}

---@enum Enum.CovenantSkill
Enum.CovenantSkill = {
	Kyrian = 2730,
	Venthyr = 2731,
	NightFae = 2732,
	Necrolord = 2733,
}

---@enum Enum.CovenantType
Enum.CovenantType = {
	None = 0,
	Kyrian = 1,
	Venthyr = 2,
	NightFae = 3,
	Necrolord = 4,
}

---@enum Enum.CraftingOrderCustomerCategoryType
Enum.CraftingOrderCustomerCategoryType = {
	Primary = 0,
	Secondary = 1,
	Tertiary = 2,
}

---@enum Enum.CraftingOrderDuration
Enum.CraftingOrderDuration = {
	Short = 0,
	Medium = 1,
	Long = 2,
}

---@enum Enum.CraftingOrderFlags
Enum.CraftingOrderFlags = {
	None = 0x0,
	IsRecraft = 0x1,
	HasNoneReagents = 0x2,
	HasSomeReagents = 0x4,
	HasAllReagents = 0x8,
	IsFulfillable = 0x10,
}

---@enum Enum.CraftingOrderItemType
Enum.CraftingOrderItemType = {
	Reagent = 0,
	Recraft = 1,
	CraftedResult = 2,
	RemoveReagent = 3,
	NpcProvided = 4,
}

---@enum Enum.CraftingOrderReagentSource
Enum.CraftingOrderReagentSource = {
	Any = 0,
	Customer = 1,
	Crafter = 2,
	None = 3,
}

---@enum Enum.CraftingOrderReagentsType
Enum.CraftingOrderReagentsType = {
	All = 0,
	Some = 1,
	None = 2,
}

---@enum Enum.CraftingOrderResult
Enum.CraftingOrderResult = {
	Ok = 0,
	Aborted = 1,
	AlreadyClaimed = 2,
	AlreadyCrafted = 3,
	CannotBeOrdered = 4,
	CannotCancel = 5,
	CannotClaim = 6,
	CannotClaimOwnOrder = 7,
	CannotCraft = 8,
	CannotCreate = 9,
	CannotFulfill = 10,
	CannotRecraft = 11,
	CannotReject = 12,
	CannotRelease = 13,
	CrafterIsIgnored = 14,
	DatabaseError = 15,
	Expired = 16,
	Locked = 17,
	InvalidDuration = 18,
	InvalidMinQuality = 19,
	InvalidNotes = 20,
	InvalidReagent = 21,
	InvalidRealm = 22,
	InvalidRecipe = 23,
	InvalidRecraftItem = 24,
	InvalidSort = 25,
	InvalidTarget = 26,
	InvalidType = 27,
	MaxOrdersReached = 28,
	MissingCraftingTable = 29,
	MissingItem = 30,
	MissingNpc = 31,
	MissingOrder = 32,
	MissingRecraftItem = 33,
	NoAccountItems = 34,
	NotClaimed = 35,
	NotCrafted = 36,
	NotInGuild = 37,
	NotYetImplemented = 38,
	OutOfPublicOrderCapacity = 39,
	ServerIsNotAvailable = 40,
	ThrottleViolation = 41,
	TargetCannotCraft = 42,
	TargetLocked = 43,
	Timeout = 44,
	TooManyItems = 45,
	WrongVersion = 46,
}

---@enum Enum.CraftingOrderSortType
Enum.CraftingOrderSortType = {
	ItemName = 0,
	AveTip = 1,
	MaxTip = 2,
	Quantity = 3,
	Reagents = 4,
	Tip = 5,
	TimeRemaining = 6,
	Status = 7,
}

---@enum Enum.CraftingOrderState
Enum.CraftingOrderState = {
	None = 0,
	Creating = 1,
	Created = 2,
	Claiming = 3,
	Claimed = 4,
	Rejecting = 5,
	Rejected = 6,
	Releasing = 7,
	Crafting = 8,
	Recrafting = 9,
	Fulfilling = 10,
	Fulfilled = 11,
	Canceling = 12,
	Canceled = 13,
	Expiring = 14,
	Expired = 15,
}

---@enum Enum.CraftingOrderType
Enum.CraftingOrderType = {
	Public = 0,
	Guild = 1,
	Personal = 2,
	Npc = 3,
}

---@enum Enum.CraftingReagentItemFlag
Enum.CraftingReagentItemFlag = {
	TooltipShowsAsStatModifications = 0,
}

---@enum Enum.CraftingReagentType
Enum.CraftingReagentType = {
	Modifying = 0,
	Basic = 1,
	Finishing = 2,
	Automatic = 3,
}

---@enum Enum.CreateAllAccountData
Enum.CreateAllAccountData = {
	CreateAllNone = "0x0000000000000000",
	CreateAllAchievementsDone = "0x0000000000000001",
	CreateAllCriteriaDone = "0x0000000000000002",
	CreateAllMountsDone = "0x0000000000000004",
	CreateAllBattlepetsDone = "0x0000000000000008",
	CreateAllCurrencycapsDone = "0x0000000000000010",
	CreateAllQuestLogDone = "0x0000000000000020",
	CreateAllCharactersDone = "0x0000000000000040",
	CreateAllPurchasesDone = "0x0000000000000080",
	CreateAllBpayDistributionObjectsDone = "0x0000000000000100",
	CreateAllArchivedPurchasesDone = "0x0000000000000200",
	CreateAllSettingsDone = "0x0000000000000400",
	CreateAllBpayAddLicenseObjectsDone = "0x0000000000000800",
	CreateAllItemCollectionItemsDone = "0x0000000000001000",
	CreateAllAuctionableTokensDone = "0x0000000000002000",
	CreateAllConsumableTokensDone = "0x0000000000004000",
	CreateAllPerkPastRewardsDone = "0x0000000000008000",
	CreateAllVasTransactionsDone = "0x0000000000010000",
	CreateAllBpayProductitemObjectsDone = "0x0000000000020000",
	CreateAllTrialBoostHistoryDone = "0x0000000000040000",
	CreateAllQuestCriteriaDone = "0x0000000000080000",
	CreateObject = "0x0000000000100000",
	CreateAllAccountCurrenciesDone = "0x0000000000200000",
	CreateAllRafBalanceDone = "0x0000000000400000",
	CreateAllRafRewardsDone = "0x0000000000800000",
	CreateAllAccountDynamicCriteriaDone = "0x0000000001000000",
	CreateAllRafActivitiesDone = "0x0000000002000000",
	CreateAllRevokedRafRewardsDone = "0x0000000004000000",
	CreateAllAccountNotificationsDone = "0x0000000008000000",
	CreateAllPerkPendingPurchasesDone = "0x0000000010000000",
	CreateAllWowlabsDataDone = "0x0000000020000000",
	CreateAllPerkHeldItemsDone = "0x0000000040000000",
	CreateAllPerkPendingRewardsDone = "0x0000000080000000",
	CreateAllBitVectorsDone = "0x0000000100000000",
	CreateAllAccountFactionsDone = "0x0000000200000000",
	CreateAllAccountItemsDone = "0x0000000400000000",
	CreateAllCombinedQuestLogEntriesDone = "0x0000000800000000",
	CreateAllDataElementsDone = "0x0000001000000000",
	CreateAllWarbandGroupsDone = "0x0000002000000000",
	CreateAllBanktabSettingsDone = "0x0000004000000000",
	CreateAllAccountMappingDone = "0x0000008000000000",
	CreateAllCharacterItemsDone = "0x0000010000000000",
	CreateAllCurrencyTransferLogDone = "0x0000020000000000",
	CreateAllLgVendorPurchaseDone = "0x0000040000000000",
	CreateAllFutureFeature01DataDone = "0x0000080000000000",
	CreateAllWarbandScenesLoadedDone = "0x0000100000000000",
}

---@enum Enum.CurioRarity
Enum.CurioRarity = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
}

---@enum Enum.CurioType
Enum.CurioType = {
	Combat = 0,
	Utility = 1,
}

---@enum Enum.CurrencyDestroyReason
Enum.CurrencyDestroyReason = {
	Cheat = 0,
	Spell = 1,
	VersionUpdate = 2,
	QuestTurnin = 3,
	Vendor = 4,
	Trade = 5,
	Capped = 6,
	Garrison = 7,
	DroppedToCorpse = 8,
	BonusRoll = 9,
	FactionConversion = 10,
	FulfillCraftingOrder = 11,
	Script = 12,
	ConcentrationCast = 13,
	AccountTransfer = 14,
	HonorLoss = 15,
}

---@enum Enum.CurrencyFilterType
Enum.CurrencyFilterType = {
	None = 0,
	DiscoveredOnly = 1,
	DiscoveredAndAllAccountTransferable = 2,
}

---@enum Enum.CurrencyFlags
Enum.CurrencyFlags = {
	CurrencyTradable = 0x1,
	CurrencyAppearsInLootWindow = 0x2,
	CurrencyComputedWeeklyMaximum = 0x4,
	Currency_100_Scaler = 0x8,
	CurrencyNoLowLevelDrop = 0x10,
	CurrencyIgnoreMaxQtyOnLoad = 0x20,
	CurrencyLogOnWorldChange = 0x40,
	CurrencyTrackQuantity = 0x80,
	CurrencyResetTrackedQuantity = 0x100,
	CurrencyUpdateVersionIgnoreMax = 0x200,
	CurrencySuppressChatMessageOnVersionChange = 0x400,
	CurrencySingleDropInLoot = 0x800,
	CurrencyHasWeeklyCatchup = 0x1000,
	CurrencyDoNotCompressChat = 0x2000,
	CurrencyDoNotLogAcquisitionToBi = 0x4000,
	CurrencyNoRaidDrop = 0x8000,
	CurrencyNotPersistent = 0x10000,
	CurrencyDeprecated = 0x20000,
	CurrencyDynamicMaximum = 0x40000,
	CurrencySuppressChatMessages = 0x80000,
	CurrencyDoNotToast = 0x100000,
	CurrencyDestroyExtraOnLoot = 0x200000,
	CurrencyDontShowTotalInTooltip = 0x400000,
	CurrencyDontCoalesceInLootWindow = 0x800000,
	CurrencyAccountWide = 0x1000000,
	CurrencyAllowOverflowMailer = 0x2000000,
	CurrencyHideAsReward = 0x4000000,
	CurrencyHasWarmodeBonus = 0x8000000,
	CurrencyIsAllianceOnly = 0x10000000,
	CurrencyIsHordeOnly = 0x20000000,
	CurrencyLimitWarmodeBonusOncePerTooltip = 0x40000000,
	CurrencyUsesLedgerBalance = 0x80000000,
}

---@enum Enum.CurrencyFlagsB
Enum.CurrencyFlagsB = {
	CurrencyBUseTotalEarnedForEarned = 0x1,
	CurrencyBShowQuestXPGainInTooltip = 0x2,
	CurrencyBNoNotificationMailOnOfflineProgress = 0x4,
	CurrencyBBattlenetVirtualCurrency = 0x8,
	FutureCurrencyFlag = 0x10,
	CurrencyBDontDisplayIfZero = 0x20,
	CurrencyBScaleMaxQuantityBySeasonWeeks = 0x40,
	CurrencyBScaleMaxQuantityByWeeksSinceStart = 0x80,
	CurrencyBForceMaxQuantityOnConversion = 0x100,
	CurrencyBUnearnableBeforeMaxQuantityStart = 0x200,
}

---@enum Enum.CurrencyGainFlags
Enum.CurrencyGainFlags = {
	None = 0x0,
	BonusAward = 0x1,
	DroppedFromDeath = 0x2,
	FromAccountServer = 0x4,
	Autotracking = 0x8,
}

---@enum Enum.CurrencySource
Enum.CurrencySource = {
	ConvertOldItem = 0,
	ConvertOldPvPCurrency = 1,
	ItemRefund = 2,
	QuestReward = 3,
	Cheat = 4,
	Vendor = 5,
	PvPKillCredit = 6,
	PvPMetaCredit = 7,
	PvPScriptedAward = 8,
	Loot = 9,
	UpdatingVersion = 10,
	LFGReward = 11,
	Trade = 12,
	Spell = 13,
	ItemDeletion = 14,
	RatedBattleground = 15,
	RandomBattleground = 16,
	Arena = 17,
	ExceededMaxQty = 18,
	PvPCompletionBonus = 19,
	Script = 20,
	GuildBankWithdrawal = 21,
	Pushloot = 22,
	GarrisonBuilding = 23,
	PvPDrop = 24,
	GarrisonFollowerActivation = 25,
	GarrisonBuildingRefund = 26,
	GarrisonMissionReward = 27,
	GarrisonResourceOverTime = 28,
	QuestRewardIgnoreCapsDeprecated = 29,
	GarrisonTalent = 30,
	GarrisonWorldQuestBonus = 31,
	PvPHonorReward = 32,
	BonusRoll = 33,
	AzeriteRespec = 34,
	WorldQuestReward = 35,
	WorldQuestRewardIgnoreCapsDeprecated = 36,
	FactionConversion = 37,
	DailyQuestReward = 38,
	DailyQuestWarModeReward = 39,
	WeeklyQuestReward = 40,
	WeeklyQuestWarModeReward = 41,
	AccountCopy = 42,
	WeeklyRewardChest = 43,
	GarrisonTalentTreeReset = 44,
	DailyReset = 45,
	AddConduitToCollection = 46,
	Barbershop = 47,
	ConvertItemsToCurrencyValue = 48,
	PvPTeamContribution = 49,
	Transmogrify = 50,
	AuctionDeposit = 51,
	PlayerTrait = 52,
	PhBuffer_53 = 53,
	PhBuffer_54 = 54,
	RenownRepGain = 55,
	CraftingOrder = 56,
	CatalystBalancing = 57,
	CatalystCraft = 58,
	ProfessionInitialAward = 59,
	PlayerTraitRefund = 60,
	AccountHwmUpdate = 61,
	ConvertItemsToCurrencyAndReputation = 62,
	PhBuffer_63 = 63,
	SpellSkipLinkedCurrency = 64,
	AccountTransfer = 65,
	RenownRepGainInitialVisibility = 66,
}

---@enum Enum.CurrencyTokenCategoryFlags
Enum.CurrencyTokenCategoryFlags = {
	FlagSortLast = 0x1,
	FlagPlayerItemAssignment = 0x2,
	Hidden = 0x4,
	Virtual = 0x8,
	StartsCollapsed = 0x10,
}

---@enum Enum.CursorStyle
Enum.CursorStyle = {
	Mouse = 0,
	Crosshair = 1,
}

---@enum Enum.Cursormode
Enum.Cursormode = {
	NoCursor = 0,
	PointCursor = 1,
	CastCursor = 2,
	BuyCursor = 3,
	AttackCursor = 4,
	InteractCursor = 5,
	SpeakCursor = 6,
	InspectCursor = 7,
	PickupCursor = 8,
	TaxiCursor = 9,
	TrainerCursor = 10,
	MineCursor = 11,
	SkinCursor = 12,
	GatherCursor = 13,
	LockCursor = 14,
	MailCursor = 15,
	LootAllCursor = 16,
	RepairCursor = 17,
	RepairnpcCursor = 18,
	ItemCursor = 19,
	SkinHordeCursor = 20,
	SkinAllianceCursor = 21,
	InnkeeperCursor = 22,
	CampaignQuestCursor = 23,
	CampaignQuestTurninCursor = 24,
	QuestCursor = 25,
	QuestRepeatableCursor = 26,
	QuestTurninCursor = 27,
	QuestLegendaryCursor = 28,
	QuestLegendaryTurninCursor = 29,
	QuestImportantCursor = 30,
	QuestImportantTurninCursor = 31,
	QuestMetaCursor = 32,
	QuestMetaTurninCursor = 33,
	QuestRecurringCursor = 34,
	QuestRecurringTurninCursor = 35,
	VehicleCursor = 36,
	MapPinCursor = 37,
	PingCursor = 38,
	EnchantCursor = 39,
	StablemasterCursor = 40,
	UIMoveCursor = 41,
	UIResizeCursor = 42,
	PointErrorCursor = 43,
	CastErrorCursor = 44,
	BuyErrorCursor = 45,
	AttackErrorCursor = 46,
	InteractErrorCursor = 47,
	SpeakErrorCursor = 48,
	InspectErrorCursor = 49,
	PickupErrorCursor = 50,
	TaxiErrorCursor = 51,
	TrainerErrorCursor = 52,
	MineErrorCursor = 53,
	SkinErrorCursor = 54,
	GatherErrorCursor = 55,
	LockErrorCursor = 56,
	MailErrorCursor = 57,
	LootAllErrorCursor = 58,
	RepairErrorCursor = 59,
	RepairnpcErrorCursor = 60,
	ItemErrorCursor = 61,
	SkinHordeErrorCursor = 62,
	SkinAllianceErrorCursor = 63,
	InnkeeperErrorCursor = 64,
	CampaignQuestErrorCursor = 65,
	CampaignQuestTurninErrorCursor = 66,
	QuestErrorCursor = 67,
	QuestRepeatableErrorCursor = 68,
	QuestTurninErrorCursor = 69,
	QuestLegendaryErrorCursor = 70,
	QuestLegendaryTurninErrorCursor = 71,
	QuestImportantErrorCursor = 72,
	QuestImportantTurninErrorCursor = 73,
	QuestMetaErrorCursor = 74,
	QuestMetaTurninErrorCursor = 75,
	QuestRecurringErrorCursor = 76,
	QuestRecurringTurninErrorCursor = 77,
	VehicleErrorCursor = 78,
	MapPinErrorCursor = 79,
	PingErrorCursor = 80,
	EnchantErrorCursor = 81,
	StablemasterErrorCursor = 82,
	CustomCursor = 83,
}

---@enum Enum.CustomBindingType
Enum.CustomBindingType = {
	VoicePushToTalk = 0,
}

---@enum Enum.Damageclass
Enum.Damageclass = {
	MaskNone = 0x0,
	Physical = 0x0,
	AllPhysical = 0x1,
	Holy = 0x1,
	MaskPhysical = 0x1,
	Fire = 0x2,
	FirstResist = 0x2,
	MaskHoly = 0x2,
	MaskHolystrike = 0x3,
	Nature = 0x3,
	Frost = 0x4,
	MaskFire = 0x4,
	MaskFlamestrike = 0x5,
	Shadow = 0x5,
	Arcane = 0x6,
	LastResist = 0x6,
	MaskHolyfire = 0x6,
	MaskNature = 0x8,
	MaskStormstrike = 0x9,
	MaskHolystorm = 0xA,
	MaskFirestorm = 0xC,
	MaskFrost = 0x10,
	MaskFroststrike = 0x11,
	MaskHolyfrost = 0x12,
	MaskFrostfire = 0x14,
	MaskFroststorm = 0x18,
	MaskElemental = 0x1C,
	MaskShadow = 0x20,
	MaskShadowstrike = 0x21,
	MaskTwilight = 0x22,
	MaskShadowflame = 0x24,
	MaskShadowstorm = 0x28,
	MaskShadowfrost = 0x30,
	MaskChromatic = 0x3E,
	MaskArcane = 0x40,
	MaskSpellstrike = 0x41,
	MaskDivine = 0x42,
	MaskSpellfire = 0x44,
	MaskSpellstorm = 0x48,
	MaskSpellfrost = 0x50,
	MaskSpellshadow = 0x60,
	MaskCosmic = 0x6A,
	MaskChaos = 0x7C,
	AllMagical = 0x7E,
	MaskMagical = 0x7E,
	All = 0x7F,
}

---@enum Enum.DamageclassType
Enum.DamageclassType = {
	Physical = 0,
	Magical = 1,
}

---@enum Enum.DisableAccountProfilesFlags
Enum.DisableAccountProfilesFlags = {
	None = 0x0,
	Document = 0x1,
	SharedCollections = 0x2,
	MountsCollections = 0x4,
	PetsCollections = 0x8,
	ItemsCollections = 0x10,
}

---@enum Enum.EditModeAccountSetting
Enum.EditModeAccountSetting = {
	ShowGrid = 0,
	GridSpacing = 1,
	SettingsExpanded = 2,
	ShowTargetAndFocus = 3,
	ShowStanceBar = 4,
	ShowPetActionBar = 5,
	ShowPossessActionBar = 6,
	ShowCastBar = 7,
	ShowEncounterBar = 8,
	ShowExtraAbilities = 9,
	ShowBuffsAndDebuffs = 10,
	DeprecatedShowDebuffFrame = 11,
	ShowPartyFrames = 12,
	ShowRaidFrames = 13,
	ShowTalkingHeadFrame = 14,
	ShowVehicleLeaveButton = 15,
	ShowBossFrames = 16,
	ShowArenaFrames = 17,
	ShowLootFrame = 18,
	ShowHudTooltip = 19,
	ShowStatusTrackingBar2 = 20,
	ShowDurabilityFrame = 21,
	EnableSnap = 22,
	EnableAdvancedOptions = 23,
	ShowPetFrame = 24,
	ShowTimerBars = 25,
	ShowVehicleSeatIndicator = 26,
	ShowArchaeologyBar = 27,
	ShowCooldownViewer = 28,
}

---@enum Enum.EditModeActionBarSetting
Enum.EditModeActionBarSetting = {
	Orientation = 0,
	NumRows = 1,
	NumIcons = 2,
	IconSize = 3,
	IconPadding = 4,
	VisibleSetting = 5,
	HideBarArt = 6,
	DeprecatedSnapToSide = 7,
	HideBarScrolling = 8,
	AlwaysShowButtons = 9,
}

---@enum Enum.EditModeActionBarSystemIndices
Enum.EditModeActionBarSystemIndices = {
	MainBar = 1,
	Bar2 = 2,
	Bar3 = 3,
	RightBar1 = 4,
	RightBar2 = 5,
	ExtraBar1 = 6,
	ExtraBar2 = 7,
	ExtraBar3 = 8,
	StanceBar = 11,
	PetActionBar = 12,
	PossessActionBar = 13,
}

---@enum Enum.EditModeArchaeologyBarSetting
Enum.EditModeArchaeologyBarSetting = {
	Size = 0,
}

---@enum Enum.EditModeAuraFrameSetting
Enum.EditModeAuraFrameSetting = {
	Orientation = 0,
	IconWrap = 1,
	IconDirection = 2,
	IconLimitBuffFrame = 3,
	IconLimitDebuffFrame = 4,
	IconSize = 5,
	IconPadding = 6,
	DeprecatedShowFull = 7,
}

---@enum Enum.EditModeAuraFrameSystemIndices
Enum.EditModeAuraFrameSystemIndices = {
	BuffFrame = 1,
	DebuffFrame = 2,
}

---@enum Enum.EditModeBagsSetting
Enum.EditModeBagsSetting = {
	Orientation = 0,
	Direction = 1,
	Size = 2,
}

---@enum Enum.EditModeCastBarSetting
Enum.EditModeCastBarSetting = {
	BarSize = 0,
	LockToPlayerFrame = 1,
	ShowCastTime = 2,
}

---@enum Enum.EditModeChatFrameDisplayOnlySetting
Enum.EditModeChatFrameDisplayOnlySetting = {
	Width = 4,
	Height = 5,
}

---@enum Enum.EditModeChatFrameSetting
Enum.EditModeChatFrameSetting = {
	WidthHundreds = 0,
	WidthTensAndOnes = 1,
	HeightHundreds = 2,
	HeightTensAndOnes = 3,
}

---@enum Enum.EditModeCooldownViewerSetting
Enum.EditModeCooldownViewerSetting = {
	Orientation = 0,
	IconLimit = 1,
	IconDirection = 2,
	IconSize = 3,
	IconPadding = 4,
	Opacity = 5,
	VisibleSetting = 6,
	BarContent = 7,
	HideWhenInactive = 8,
	ShowTimer = 9,
	ShowTooltips = 10,
}

---@enum Enum.EditModeCooldownViewerSystemIndices
Enum.EditModeCooldownViewerSystemIndices = {
	Essential = 1,
	Utility = 2,
	BuffIcon = 3,
	BuffBar = 4,
}

---@enum Enum.EditModeDurabilityFrameSetting
Enum.EditModeDurabilityFrameSetting = {
	Size = 0,
}

---@enum Enum.EditModeLayoutType
Enum.EditModeLayoutType = {
	Preset = 0,
	Account = 1,
	Character = 2,
	Override = 3,
}

---@enum Enum.EditModeMicroMenuSetting
Enum.EditModeMicroMenuSetting = {
	Orientation = 0,
	Order = 1,
	Size = 2,
	EyeSize = 3,
}

---@enum Enum.EditModeMinimapSetting
Enum.EditModeMinimapSetting = {
	HeaderUnderneath = 0,
	RotateMinimap = 1,
	Size = 2,
}

---@enum Enum.EditModeObjectiveTrackerSetting
Enum.EditModeObjectiveTrackerSetting = {
	Height = 0,
	Opacity = 1,
	TextSize = 2,
}

---@enum Enum.EditModePresetLayouts
Enum.EditModePresetLayouts = {
	Modern = 0,
	Classic = 1,
}

---@enum Enum.EditModeSettingDisplayType
Enum.EditModeSettingDisplayType = {
	Dropdown = 0,
	Checkbox = 1,
	Slider = 2,
}

---@enum Enum.EditModeStatusTrackingBarSetting
Enum.EditModeStatusTrackingBarSetting = {
	Height = 0,
	Width = 1,
	TextSize = 2,
}

---@enum Enum.EditModeStatusTrackingBarSystemIndices
Enum.EditModeStatusTrackingBarSystemIndices = {
	StatusTrackingBar1 = 1,
	StatusTrackingBar2 = 2,
}

---@enum Enum.EditModeSystem
Enum.EditModeSystem = {
	ActionBar = 0,
	CastBar = 1,
	Minimap = 2,
	UnitFrame = 3,
	EncounterBar = 4,
	ExtraAbilities = 5,
	AuraFrame = 6,
	TalkingHeadFrame = 7,
	ChatFrame = 8,
	VehicleLeaveButton = 9,
	LootFrame = 10,
	HudTooltip = 11,
	ObjectiveTracker = 12,
	MicroMenu = 13,
	Bags = 14,
	StatusTrackingBar = 15,
	DurabilityFrame = 16,
	TimerBars = 17,
	VehicleSeatIndicator = 18,
	ArchaeologyBar = 19,
	CooldownViewer = 20,
}

---@enum Enum.EditModeTimerBarsSetting
Enum.EditModeTimerBarsSetting = {
	Size = 0,
}

---@enum Enum.EditModeUnitFrameSetting
Enum.EditModeUnitFrameSetting = {
	HidePortrait = 0,
	CastBarUnderneath = 1,
	BuffsOnTop = 2,
	UseLargerFrame = 3,
	UseRaidStylePartyFrames = 4,
	ShowPartyFrameBackground = 5,
	UseHorizontalGroups = 6,
	CastBarOnSide = 7,
	ShowCastTime = 8,
	ViewRaidSize = 9,
	FrameWidth = 10,
	FrameHeight = 11,
	DisplayBorder = 12,
	RaidGroupDisplayType = 13,
	SortPlayersBy = 14,
	RowSize = 15,
	FrameSize = 16,
	ViewArenaSize = 17,
}

---@enum Enum.EditModeUnitFrameSystemIndices
Enum.EditModeUnitFrameSystemIndices = {
	Player = 1,
	Target = 2,
	Focus = 3,
	Party = 4,
	Raid = 5,
	Boss = 6,
	Arena = 7,
	Pet = 8,
}

---@enum Enum.EditModeVehicleSeatIndicatorSetting
Enum.EditModeVehicleSeatIndicatorSetting = {
	Size = 0,
}

---@enum Enum.EncounterLootDropRollState
Enum.EncounterLootDropRollState = {
	NeedMainSpec = 0,
	NeedOffSpec = 1,
	Transmog = 2,
	Greed = 3,
	NoRoll = 4,
	Pass = 5,
}

---@enum Enum.EndOfMatchType
Enum.EndOfMatchType = {
	None = 0,
	Plunderstorm = 1,
}

---@enum Enum.EnvironmentalDamageFlags
Enum.EnvironmentalDamageFlags = {
	OneTime = 1,
	DmgIsPct = 2,
}

---@enum Enum.Environmentaldamagetype
Enum.Environmentaldamagetype = {
	Fatigue = 0,
	Drowning = 1,
	Falling = 2,
	Lava = 3,
	Slime = 4,
	Fire = 5,
}

---@enum Enum.ErrorDomain
Enum.ErrorDomain = {
	Assert = 0,
	AssertData = 1,
	Frame = 2,
}

---@enum Enum.EventRealmQueues
Enum.EventRealmQueues = {
	None = 0x0,
	PlunderstormSolo = 0x1,
	PlunderstormDuo = 0x2,
	PlunderstormTrio = 0x4,
	PlunderstormTraining = 0x8,
}

---@enum Enum.EventToastDisplayType
Enum.EventToastDisplayType = {
	NormalSingleLine = 0,
	NormalBlockText = 1,
	NormalTitleAndSubTitle = 2,
	NormalTextWithIcon = 3,
	LargeTextWithIcon = 4,
	NormalTextWithIconAndRarity = 5,
	Scenario = 6,
	ChallengeMode = 7,
	ScenarioClickExpand = 8,
	WeeklyRewardUnlock = 9,
	WeeklyRewardUpgrade = 10,
	FlightpointDiscovered = 11,
	CapstoneUnlocked = 12,
	SingleLineWithIcon = 13,
	Scoreboard = 14,
}

---@enum Enum.EventToastEventType
Enum.EventToastEventType = {
	LevelUp = 0,
	LevelUpSpell = 1,
	LevelUpDungeon = 2,
	LevelUpRaid = 3,
	LevelUpPvP = 4,
	PetBattleNewAbility = 5,
	PetBattleFinalRound = 6,
	PetBattleCapture = 7,
	BattlePetLevelChanged = 8,
	BattlePetLevelUpAbility = 9,
	QuestBossEmote = 10,
	MythicPlusWeeklyRecord = 11,
	QuestTurnedIn = 12,
	WorldStateChange = 13,
	Scenario = 14,
	LevelUpOther = 15,
	PlayerAuraAdded = 16,
	PlayerAuraRemoved = 17,
	SpellScript = 18,
	CriteriaUpdated = 19,
	PvPTierUpdate = 20,
	SpellLearned = 21,
	TreasureItem = 22,
	WeeklyRewardUnlock = 23,
	WeeklyRewardUpgrade = 24,
	FlightpointDiscovered = 25,
}

---@enum Enum.EventToastFlags
Enum.EventToastFlags = {
	DisableRightClickDismiss = 1,
}

---@enum Enum.ExcludedCensorSources
Enum.ExcludedCensorSources = {
	None = 0x0,
	Friends = 0x1,
	Guild = 0x2,
	Reserve1 = 0x4,
	Reserve2 = 0x8,
	Reserve3 = 0x10,
	Reserve4 = 0x20,
	Reserve5 = 0x40,
	Reserve6 = 0x80,
	All = 0xFF,
}

---@enum Enum.ExpansionLandingPageType
Enum.ExpansionLandingPageType = {
	None = 0,
	Dragonflight = 1,
	WarWithin = 2,
}

---@enum Enum.FlightPathFaction
Enum.FlightPathFaction = {
	Neutral = 0,
	Horde = 1,
	Alliance = 2,
}

---@enum Enum.FlightPathState
Enum.FlightPathState = {
	Current = 0,
	Reachable = 1,
	Unreachable = 2,
}

---@enum Enum.FollowerAbilityCastResult
Enum.FollowerAbilityCastResult = {
	Success = 0,
	Failure = 1,
	NoPendingCast = 2,
	InvalidTarget = 3,
	InvalidFollowerSpell = 4,
	RerollNotAllowed = 5,
	SingleMissionDuration = 6,
	MustTargetFollower = 7,
	MustTargetTrait = 8,
	InvalidFollowerType = 9,
	MustBeUnique = 10,
	CannotTargetLimitedUseFollower = 11,
	MustTargetLimitedUseFollower = 12,
	AlreadyAtMaxDurability = 13,
	CannotTargetNonAutoMissionFollower = 14,
}

---@enum Enum.GameMode
Enum.GameMode = {
	Standard = 1,
	Plunderstorm = 2,
	Length = 3,
}

---@enum Enum.GamePadPowerLevel
Enum.GamePadPowerLevel = {
	Critical = 0,
	Low = 1,
	Medium = 2,
	High = 3,
	Wired = 4,
	Unknown = 5,
}

---@enum Enum.GameRule
Enum.GameRule = {
	NoDebuffLimit = 1,
	CharNameReservationEnabled = 2,
	MaxCharReservationsPerRealm = 3,
	MaxAccountCharReservationsPerContentset = 4,
	EtaRealmLaunchTime = 5,
	TrivialGroupXPPercent = 7,
	CharReservationsPerRealmReopenThreshold = 8,
	DisablePct = 9,
	HardcoreRuleset = 10,
	ReplaceAbsentGmSeconds = 11,
	ReplaceGmRankLastOnlineSeconds = 12,
	GameMode = 13,
	CharacterlessLogin = 14,
	NoMultiboxing = 15,
	VanillaNpcKnockback = 16,
	Runecarving = 17,
	TalentRespecCostMin = 18,
	TalentRespecCostMax = 19,
	TalentRespecCostStep = 20,
	VanillaRageGenerationModifier = 21,
	SelfFoundAllowed = 22,
	DisableHonorDecay = 23,
	MaxLootDropLevel = 25,
	MicrobarScale = 26,
	MaxUnitNameDistance = 27,
	MaxNameplateDistance = 28,
	UserAddonsDisabled = 29,
	UserScriptsDisabled = 30,
	NonPlayerNameplateScale = 31,
	ForcedPartyFrameScale = 32,
	CustomActionbarOverlayHeightOffset = 33,
	ForcedChatLanguage = 34,
	LandingPageFactionID = 35,
	CollectionsPanelDisabled = 36,
	CharacterPanelDisabled = 37,
	SpellbookPanelDisabled = 38,
	TalentsPanelDisabled = 39,
	AchievementsPanelDisabled = 40,
	CommunitiesPanelDisabled = 41,
	EncounterJournalDisabled = 42,
	FinderPanelDisabled = 43,
	StoreDisabled = 44,
	HelpPanelDisabled = 45,
	GuildsDisabled = 46,
	QuestLogMicrobuttonDisabled = 47,
	MapPlunderstormCircle = 48,
	AfterDeathSpectatingUI = 49,
	FrontEndChat = 50,
	UniversalNameplateOcclusion = 51,
	FastAreaTriggerTick = 52,
	AllPlayersAreFastMovers = 53,
	IgnoreChrclassDisabledFlag = 54,
	CharacterCreateUseFixedBackgroundModel = 55,
	ForceAlteredFormsOn = 56,
	PlayerNameplateDifficultyIcon = 57,
	PlayerNameplateAlternateHealthColor = 58,
	AlwaysAllowAlliedRaces = 59,
	ActionbarIconIntroDisabled = 60,
	ReleaseSpiritGhostDisabled = 61,
	DeleteItemConfirmationDisabled = 62,
	ChatLinkLevelToastsDisabled = 63,
	BagsUIDisabled = 64,
	PetBattlesDisabled = 65,
	PerksProgramActivityTrackingDisabled = 66,
	MaximizeWorldMapDisabled = 67,
	WorldMapTrackingOptionsDisabled = 68,
	WorldMapTrackingPinDisabled = 69,
	WorldMapHelpPlateDisabled = 70,
	QuestLogPanelDisabled = 71,
	QuestLogSuperTrackingDisabled = 72,
	TutorialFrameDisabled = 73,
	IngameMailNotificationDisabled = 74,
	IngameCalendarDisabled = 75,
	IngameTrackingDisabled = 76,
	IngameWhoListDisabled = 77,
	RaceAlteredFormsDisabled = 78,
	IngameFriendsListDisabled = 79,
	MacrosDisabled = 80,
	CompactRaidFrameManagerDisabled = 81,
	EditModeDisabled = 82,
	InstanceDifficultyBannerDisabled = 83,
	FullCharacterCreateDisabled = 84,
	TargetFrameBuffsDisabled = 85,
	UnitFramePvPContextualDisabled = 86,
	BlockWhileSheathedAllowed = 88,
	VanillaAccountMailInstant = 91,
	ClearMailOnRealmTransfer = 92,
	PremadeGroupFinderStyle = 93,
	PlunderstormAreaSelection = 94,
	GroupFinderCapabilities = 98,
	WorldMapLegendDisabled = 99,
	WorldMapFrameStrata = 100,
	MerchantFilterDisabled = 101,
	SummoningStones = 108,
	TransmogEnabled = 109,
	MailGameRule = 132,
	LootMethodStyle = 157,
}

---@enum Enum.GameRuleFlags
Enum.GameRuleFlags = {
	None = 0,
	AllowClient = 1,
	RequiresDefault = 2,
}

---@enum Enum.GameRuleType
Enum.GameRuleType = {
	Int = 0,
	Float = 1,
	Bool = 2,
}

---@enum Enum.GarrAutoBoardIndex
Enum.GarrAutoBoardIndex = {
	None = -1,
	AllyLeftBack = 0,
	AllyRightBack = 1,
	AllyLeftFront = 2,
	AllyCenterFront = 3,
	AllyRightFront = 4,
	EnemyLeftFront = 5,
	EnemyCenterLeftFront = 6,
	EnemyCenterRightFront = 7,
	EnemyRightFront = 8,
	EnemyLeftBack = 9,
	EnemyCenterLeftBack = 10,
	EnemyCenterRightBack = 11,
	EnemyRightBack = 12,
}

---@enum Enum.GarrAutoCombatSpellTutorialFlag
Enum.GarrAutoCombatSpellTutorialFlag = {
	None = 0,
	Single = 1,
	Column = 2,
	Row = 3,
	All = 4,
}

---@enum Enum.GarrAutoCombatTutorial
Enum.GarrAutoCombatTutorial = {
	SelectMission = 0x1,
	PlaceCompanion = 0x2,
	HealCompanion = 0x4,
	LevelHeal = 0x8,
	BeneficialEffect = 0x10,
	AttackSingle = 0x20,
	AttackColumn = 0x40,
	AttackRow = 0x80,
	AttackAll = 0x100,
	TroopTutorial = 0x200,
	EnvironmentalEffect = 0x400,
}

---@enum Enum.GarrAutoCombatantRole
Enum.GarrAutoCombatantRole = {
	None = 0,
	Melee = 1,
	RangedPhysical = 2,
	RangedMagic = 3,
	HealSupport = 4,
	Tank = 5,
}

---@enum Enum.GarrAutoEventFlags
Enum.GarrAutoEventFlags = {
	None = 0,
	AutoAttack = 1,
	Passive = 2,
	Environment = 4,
}

---@enum Enum.GarrAutoMissionEventType
Enum.GarrAutoMissionEventType = {
	MeleeDamage = 0,
	RangeDamage = 1,
	SpellMeleeDamage = 2,
	SpellRangeDamage = 3,
	Heal = 4,
	PeriodicDamage = 5,
	PeriodicHeal = 6,
	ApplyAura = 7,
	RemoveAura = 8,
	Died = 9,
}

---@enum Enum.GarrAutoPreviewTargetType
Enum.GarrAutoPreviewTargetType = {
	None = 0x0,
	Damage = 0x1,
	Heal = 0x2,
	Buff = 0x4,
	Debuff = 0x8,
}

---@enum Enum.GarrFollowerMissionCompleteState
Enum.GarrFollowerMissionCompleteState = {
	Alive = 0,
	KilledByMissionFailure = 1,
	SavedByPreventDeath = 2,
	OutOfDurability = 3,
}

---@enum Enum.GarrFollowerQuality
Enum.GarrFollowerQuality = {
	None = 0,
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Title = 6,
}

---@enum Enum.GarrTalentCostType
Enum.GarrTalentCostType = {
	Initial = 0,
	Respec = 1,
	MakePermanent = 2,
	TreeReset = 3,
}

---@enum Enum.GarrTalentFeatureSubtype
Enum.GarrTalentFeatureSubtype = {
	Generic = 0,
	Bastion = 1,
	Revendreth = 2,
	Ardenweald = 3,
	Maldraxxus = 4,
}

---@enum Enum.GarrTalentFeatureType
Enum.GarrTalentFeatureType = {
	Generic = 0,
	AnimaDiversion = 1,
	TravelPortals = 2,
	Adventures = 3,
	ReservoirUpgrades = 4,
	SanctumUnique = 5,
	SoulBinds = 6,
	AnimaDiversionMap = 7,
	Cyphers = 8,
}

---@enum Enum.GarrTalentResearchCostSource
Enum.GarrTalentResearchCostSource = {
	Talent = 0,
	Tree = 1,
}

---@enum Enum.GarrTalentSocketType
Enum.GarrTalentSocketType = {
	None = 0,
	Spell = 1,
	Conduit = 2,
}

---@enum Enum.GarrTalentTreeType
Enum.GarrTalentTreeType = {
	Tiers = 0,
	Classic = 1,
}

---@enum Enum.GarrTalentType
Enum.GarrTalentType = {
	Standard = 0,
	Minor = 1,
	Major = 2,
	Socket = 3,
}

---@enum Enum.GarrTalentUI
Enum.GarrTalentUI = {
	Generic = 0,
	CovenantSanctum = 1,
	SoulBinds = 2,
	AnimaDiversionMap = 3,
}

---@enum Enum.GarrisonFollowerType
Enum.GarrisonFollowerType = {
	FollowerType_6_0_GarrisonFollower = 1,
	FollowerType_6_0_Boat = 2,
	FollowerType_7_0_GarrisonFollower = 4,
	FollowerType_8_0_GarrisonFollower = 22,
	FollowerType_9_0_GarrisonFollower = 123,
}

---@enum Enum.GarrisonTalentAvailability
Enum.GarrisonTalentAvailability = {
	Available = 0,
	Unavailable = 1,
	UnavailableAnotherIsResearching = 2,
	UnavailableNotEnoughResources = 3,
	UnavailableNotEnoughGold = 4,
	UnavailableTierUnavailable = 5,
	UnavailablePlayerCondition = 6,
	UnavailableAlreadyHave = 7,
	UnavailableRequiresPrerequisiteTalent = 8,
}

---@enum Enum.GarrisonType
Enum.GarrisonType = {
	Type_6_0_Garrison = 2,
	Type_7_0_Garrison = 3,
	Type_8_0_Garrison = 9,
	Type_9_0_Garrison = 111,
}

---@enum Enum.GossipNpcOption
Enum.GossipNpcOption = {
	None = 0,
	Vendor = 1,
	Taxinode = 2,
	Trainer = 3,
	SpiritHealer = 4,
	Binder = 5,
	Banker = 6,
	PetitionVendor = 7,
	GuildTabardVendor = 8,
	Battlemaster = 9,
	Auctioneer = 10,
	TalentMaster = 11,
	Stablemaster = 12,
	PetSpecializationMaster = 13,
	GuildBanker = 14,
	Spellclick = 15,
	DisableXPGain = 16,
	EnableXPGain = 17,
	Mailbox = 18,
	WorldPvPQueue = 19,
	LFGDungeon = 20,
	ArtifactRespec = 21,
	CemeterySelect = 22,
	SpecializationMaster = 23,
	GlyphMaster = 24,
	QueueScenario = 25,
	GarrisonArchitect = 26,
	GarrisonMissionNpc = 27,
	ShipmentCrafter = 28,
	GarrisonTradeskillNpc = 29,
	GarrisonRecruitment = 30,
	AdventureMap = 31,
	GarrisonTalent = 32,
	ContributionCollector = 33,
	Transmogrify = 34,
	AzeriteRespec = 35,
	IslandsMissionNpc = 36,
	UIItemInteraction = 37,
	WorldMap = 38,
	Soulbind = 39,
	ChromieTimeNpc = 40,
	CovenantPreviewNpc = 41,
	RuneforgeLegendaryCrafting = 42,
	NewPlayerGuide = 43,
	RuneforgeLegendaryUpgrade = 44,
	CovenantRenownNpc = 45,
	BlackMarketAuctionHouse = 46,
	PerksProgramVendor = 47,
	ProfessionsCraftingOrder = 48,
	ProfessionsOpen = 49,
	ProfessionsCustomerOrder = 50,
	TraitSystem = 51,
	BarbersChoice = 52,
	MajorFactionRenown = 53,
	PersonalTabardVendor = 54,
	ForgeMaster = 55,
	CharacterBanker = 56,
	AccountBanker = 57,
	ProfessionRespec = 58,
	Placeholder_1 = 59,
	Placeholder_2 = 60,
	Placeholder_3 = 61,
	GuildRename = 62,
	Placeholder_4 = 63,
	ItemUpgrade = 64,
}

---@enum Enum.GossipNpcOptionDisplayFlags
Enum.GossipNpcOptionDisplayFlags = {
	ForceInteractionOnSingleChoice = 1,
}

---@enum Enum.GossipOptionRecFlags
Enum.GossipOptionRecFlags = {
	QuestLabelPrepend = 1,
	HideOptionIDFromClient = 2,
	PlayMovieLabelPrepend = 4,
}

---@enum Enum.GossipOptionRewardType
Enum.GossipOptionRewardType = {
	Item = 0,
	Currency = 1,
}

---@enum Enum.GossipOptionStatus
Enum.GossipOptionStatus = {
	Available = 0,
	Unavailable = 1,
	Locked = 2,
	AlreadyComplete = 3,
}

---@enum Enum.GossipOptionUIWidgetSetTypes
Enum.GossipOptionUIWidgetSetTypes = {
	Modifiers = 0,
	Background = 1,
}

---@enum Enum.GraphicsValidationResult
Enum.GraphicsValidationResult = {
	Supported = 0,
	Illegal = 1,
	Unsupported = 2,
	Graphics = 3,
	DualCore = 4,
	QuadCore = 5,
	CpuMem_2 = 6,
	CpuMem_4 = 7,
	CpuMem_8 = 8,
	Needs_5_0 = 9,
	Needs_6_0 = 10,
	NeedsRt = 11,
	NeedsDx12 = 12,
	NeedsDx12Vrs2 = 13,
	NeedsAppleGpu = 14,
	NeedsAmdGpu = 15,
	NeedsIntelGpu = 16,
	NeedsNvidiaGpu = 17,
	NeedsQualcommGpu = 18,
	NeedsMacOs_10_13 = 19,
	NeedsMacOs_10_14 = 20,
	NeedsMacOs_10_15 = 21,
	NeedsMacOs_11_0 = 22,
	NeedsMacOs_12_0 = 23,
	NeedsMacOs_13_0 = 24,
	NeedsWindows_10 = 25,
	NeedsWindows_11 = 26,
	MacOsUnsupported = 27,
	WindowsUnsupported = 28,
	LegacyUnsupported = 29,
	Dx11Unsupported = 30,
	Dx12Win7Unsupported = 31,
	RemoteDesktopUnsupported = 32,
	WineUnsupported = 33,
	NvapiWineUnsupported = 34,
	AppleGpuUnsupported = 35,
	AmdGpuUnsupported = 36,
	IntelGpuUnsupported = 37,
	NvidiaGpuUnsupported = 38,
	QualcommGpuUnsupported = 39,
	GpuDriver = 40,
	CompatMode = 41,
	Unknown = 42,
}

---@enum Enum.GuildErrorType
Enum.GuildErrorType = {
	Success = 0,
	UnknownError = 1,
	AlreadyInGuild = 2,
	TargetAlreadyInGuild = 3,
	InvitedToGuild = 4,
	TargetInvitedToGuild = 5,
	NameInvalid = 6,
	NameAlreadyExists = 7,
	NoPermisson = 8,
	NotInGuild = 9,
	TargetNotInGuild = 10,
	PlayerNotFound = 11,
	WrongFaction = 12,
	TargetTooHigh = 13,
	TargetTooLow = 14,
	TooManyRanks = 15,
	TooFewRanks = 16,
	RanksLocked = 17,
	RankInUse = 18,
	Ignored = 19,
	Busy = 20,
	TargetLevelTooLow = 21,
	TargetLevelTooHigh = 22,
	TooManyMembers = 23,
	InvalidBankTab = 24,
	WithdrawLimit = 25,
	NotEnoughMoney = 26,
	TeamNotFound = 27,
	BankTabFull = 28,
	BadItem = 29,
	TeamsLocked = 30,
	TooMuchMoney = 31,
	WrongBankTab = 32,
	TooManyCreate = 33,
	RankRequiresAuthenticator = 34,
	BankTabLocked = 35,
	TrialAccount = 36,
	VeteranAccount = 37,
	UndeletableDueToLevel = 38,
	LockedForMove = 39,
	GuildRepTooLow = 40,
	CantInviteSelf = 41,
	HasRestriction = 42,
	BankNotFound = 43,
	NewLeaderWrongFaction = 44,
	GuildBankNotAvailable = 45,
	NewLeaderWrongRealm = 46,
	DeleteNoAppropriateLeader = 47,
	RealmMismatch = 48,
	InCooldown = 49,
	ReservationExpired = 50,
}

---@enum Enum.HolidayCalendarFlags
Enum.HolidayCalendarFlags = {
	Alliance = 1,
	Horde = 2,
}

---@enum Enum.HolidayFlags
Enum.HolidayFlags = {
	IsRegionwide = 0x1,
	DontShowInCalendar = 0x2,
	DontDisplayEnd = 0x4,
	DontDisplayBanner = 0x8,
	NotAvailableClientSide = 0x10,
	DurationUseMinutes = 0x20,
	BeginEventOnlyOnStageChange = 0x40,
}

---@enum Enum.IconAndTextShiftTextType
Enum.IconAndTextShiftTextType = {
	None = 0,
	ShiftText = 1,
}

---@enum Enum.IconAndTextWidgetState
Enum.IconAndTextWidgetState = {
	Hidden = 0,
	Shown = 1,
	ShownWithDynamicIconFlashing = 2,
	ShownWithDynamicIconNotFlashing = 3,
}

---@enum Enum.IconState
Enum.IconState = {
	Hidden = 0,
	ShowState1 = 1,
	ShowState2 = 2,
}

---@enum Enum.InputContext
Enum.InputContext = {
	None = 0,
	Keyboard = 1,
	Mouse = 2,
	GamePad = 3,
}

---@enum Enum.InventoryType
Enum.InventoryType = {
	IndexNonEquipType = 0,
	IndexHeadType = 1,
	IndexNeckType = 2,
	IndexShoulderType = 3,
	IndexBodyType = 4,
	IndexChestType = 5,
	IndexWaistType = 6,
	IndexLegsType = 7,
	IndexFeetType = 8,
	IndexWristType = 9,
	IndexHandType = 10,
	IndexFingerType = 11,
	IndexTrinketType = 12,
	IndexWeaponType = 13,
	IndexShieldType = 14,
	IndexRangedType = 15,
	IndexCloakType = 16,
	Index2HweaponType = 17,
	IndexBagType = 18,
	IndexTabardType = 19,
	IndexRobeType = 20,
	IndexWeaponmainhandType = 21,
	IndexWeaponoffhandType = 22,
	IndexHoldableType = 23,
	IndexAmmoType = 24,
	IndexThrownType = 25,
	IndexRangedrightType = 26,
	IndexQuiverType = 27,
	IndexRelicType = 28,
	IndexProfessionToolType = 29,
	IndexProfessionGearType = 30,
	IndexEquipablespellOffensiveType = 31,
	IndexEquipablespellUtilityType = 32,
	IndexEquipablespellDefensiveType = 33,
	IndexEquipablespellWeaponType = 34,
}

---@enum Enum.ItemArmorSubclass
Enum.ItemArmorSubclass = {
	Generic = 0,
	Cloth = 1,
	Leather = 2,
	Mail = 3,
	Plate = 4,
	Cosmetic = 5,
	Shield = 6,
	Libram = 7,
	Idol = 8,
	Totem = 9,
	Sigil = 10,
	Relic = 11,
}

---@enum Enum.ItemBind
Enum.ItemBind = {
	None = 0,
	OnAcquire = 1,
	OnEquip = 2,
	OnUse = 3,
	Quest = 4,
	Unused1 = 5,
	Unused2 = 6,
	ToWoWAccount = 7,
	ToBnetAccount = 8,
	ToBnetAccountUntilEquipped = 9,
}

---@enum Enum.ItemClass
Enum.ItemClass = {
	Consumable = 0,
	Container = 1,
	Weapon = 2,
	Gem = 3,
	Armor = 4,
	Reagent = 5,
	Projectile = 6,
	Tradegoods = 7,
	ItemEnhancement = 8,
	Recipe = 9,
	CurrencyTokenObsolete = 10,
	Quiver = 11,
	Questitem = 12,
	Key = 13,
	PermanentObsolete = 14,
	Miscellaneous = 15,
	Glyph = 16,
	Battlepet = 17,
	WoWToken = 18,
	Profession = 19,
}

---@enum Enum.ItemCollectionType
Enum.ItemCollectionType = {
	ItemCollectionNone = 0,
	ItemCollectionToy = 1,
	ItemCollectionHeirloom = 2,
	ItemCollectionTransmog = 3,
	ItemCollectionTransmogSetFavorite = 4,
	ItemCollectionRuneforgeLegendaryAbility = 5,
	ItemCollectionTransmogIllusion = 6,
	ItemCollectionWarbandScene = 7,
	NumItemCollectionTypes = 7,
}

---@enum Enum.ItemCommodityStatus
Enum.ItemCommodityStatus = {
	Unknown = 0,
	Item = 1,
	Commodity = 2,
}

---@enum Enum.ItemConsumableSubclass
Enum.ItemConsumableSubclass = {
	Generic = 0,
	Potion = 1,
	Elixir = 2,
	Flasksphials = 3,
	Scroll = 4,
	Fooddrink = 5,
	Itemenhancement = 6,
	Bandage = 7,
	Other = 8,
	VantusRune = 9,
	UtilityCurio = 10,
	CombatCurio = 11,
}

---@enum Enum.ItemCreationContext
Enum.ItemCreationContext = {
	None = 0,
	DungeonNormal = 1,
	DungeonHeroic = 2,
	RaidNormal = 3,
	RaidFinder = 4,
	RaidHeroic = 5,
	RaidMythic = 6,
	PvPUnranked_1 = 7,
	PvPRanked_1 = 8,
	ScenarioNormal = 9,
	ScenarioHeroic = 10,
	QuestReward = 11,
	Store = 12,
	TradeSkill = 13,
	Vendor = 14,
	BlackMarket = 15,
	ChallengeMode_1 = 16,
	DungeonLevelUp_1 = 17,
	DungeonLevelUp_2 = 18,
	DungeonLevelUp_3 = 19,
	DungeonLevelUp_4 = 20,
	ForceNone = 21,
	Timewalker = 22,
	DungeonMythic = 23,
	PvPHonorReward = 24,
	WorldQuest_1 = 25,
	WorldQuest_2 = 26,
	WorldQuest_3 = 27,
	WorldQuest_4 = 28,
	WorldQuest_5 = 29,
	WorldQuest_6 = 30,
	MissionReward_1 = 31,
	MissionReward_2 = 32,
	ChallengeMode_2 = 33,
	ChallengeMode_3 = 34,
	ChallengeModeJackpot = 35,
	WorldQuest_7 = 36,
	WorldQuest_8 = 37,
	PvPRanked_2 = 38,
	PvPRanked_3 = 39,
	PvPRanked_4 = 40,
	PvPUnranked_2 = 41,
	WorldQuest_9 = 42,
	WorldQuest_10 = 43,
	PvPRanked_5 = 44,
	PvPRanked_6 = 45,
	PvPRanked_7 = 46,
	PvPUnranked_3 = 47,
	PvPUnranked_4 = 48,
	PvPUnranked_5 = 49,
	PvPUnranked_6 = 50,
	PvPUnranked_7 = 51,
	PvPRanked_8 = 52,
	WorldQuest_11 = 53,
	WorldQuest_12 = 54,
	WorldQuest_13 = 55,
	PvPRankedJackpot = 56,
	TournamentRealm_1 = 57,
	Relinquished = 58,
	LegendaryForge = 59,
	QuestBonusLoot = 60,
	CharacterBoost_1 = 61,
	CharacterBoost_2 = 62,
	LegendaryCrafting_1 = 63,
	LegendaryCrafting_2 = 64,
	LegendaryCrafting_3 = 65,
	LegendaryCrafting_4 = 66,
	LegendaryCrafting_5 = 67,
	LegendaryCrafting_6 = 68,
	LegendaryCrafting_7 = 69,
	LegendaryCrafting_8 = 70,
	LegendaryCrafting_9 = 71,
	WeeklyRewardsAdditional = 72,
	WeeklyRewardsConcession = 73,
	WorldQuestJackpot = 74,
	NewCharacter = 75,
	WarMode = 76,
	PvPBrawl_1 = 77,
	PvPBrawl_2 = 78,
	Torghast = 79,
	CorpseRecovery = 80,
	WorldBoss = 81,
	RaidNormalExtended = 82,
	RaidFinderExtended = 83,
	RaidHeroicExtended = 84,
	RaidMythicExtended = 85,
	CharacterBoost_3 = 86,
	ChallengeMode_4 = 87,
	PvPRanked_9 = 88,
	RaidNormalExtended_2 = 89,
	RaidFinderExtended_2 = 90,
	RaidHeroicExtended_2 = 91,
	RaidMythicExtended_2 = 92,
	RaidNormalExtended_3 = 93,
	RaidFinderExtended_3 = 94,
	RaidHeroicExtended_3 = 95,
	RaidMythicExtended_3 = 96,
	TemplateCharacter_1 = 97,
	TemplateCharacter_2 = 98,
	TemplateCharacter_3 = 99,
	TemplateCharacter_4 = 100,
	DungeonNormalJackpot = 101,
	DungeonHeroicJackpot = 102,
	DungeonMythicJackpot = 103,
	Delves_1 = 104,
	Timerunning = 105,
	Delves_2 = 106,
	Delves_3 = 107,
	DelvesJackpot = 108,
	DelvesKey_1 = 109,
	DelvesKey_2 = 110,
	DelvesKey_3 = 111,
	DelvesKey_4 = 112,
	DelvesKey_5 = 113,
	DelvesKey_6 = 114,
	DelvesKey_7 = 115,
	DelvesKey_8 = 116,
	DelvesBounty_1 = 117,
	DelvesBounty_2 = 118,
	DelvesBounty_3 = 119,
	DelvesBounty_4 = 120,
	DelvesBounty_5 = 121,
	DelvesBounty_6 = 122,
	DelvesBounty_7 = 123,
	DelvesBounty_8 = 124,
	DelvesLevelUp_1 = 125,
	DelvesLevelUp_2 = 126,
	DelvesLevelUp_3 = 127,
	DelvesLevelUp_4 = 128,
	DelvesBonus_1 = 129,
	DelvesBonus_2 = 130,
	DelvesBonus_3 = 131,
	DelvesBonus_4 = 132,
	DelvesBonus_5 = 133,
	DelvesBonus_6 = 134,
	DelvesBonus_7 = 135,
	DelvesBonus_8 = 136,
	DelvesBonus_9 = 137,
	DelvesBonus_10 = 138,
	DungeonBonus_1 = 139,
	DungeonBonus_2 = 140,
	DungeonBonus_3 = 141,
	DungeonBonus_4 = 142,
	DungeonBonus_5 = 143,
	DungeonBonus_6 = 144,
	DungeonBonus_7 = 145,
	DungeonBonus_8 = 146,
	DungeonBonus_9 = 147,
	DungeonBonus_10 = 148,
	RaidBonus_1 = 149,
	RaidBonus_2 = 150,
	RaidBonus_3 = 151,
	RaidBonus_4 = 152,
	RaidBonus_5 = 153,
	RaidBonus_6 = 154,
	RaidBonus_7 = 155,
	RaidBonus_8 = 156,
	RaidBonus_9 = 157,
	RaidBonus_10 = 158,
	DungeonHardMode_1 = 159,
	DungeonHardMode_2 = 160,
	DungeonHardMode_3 = 161,
	TournamentRealm_2 = 162,
	TournamentRealm_3 = 163,
	TournamentRealm_4 = 164,
	Warbound_1 = 165,
	Warbound_2 = 166,
	Warbound_3 = 167,
	Warbound_4 = 168,
	Warbound_5 = 169,
	Warbound_6 = 170,
	Warbound_7 = 171,
	Warbound_8 = 172,
	Warbound_9 = 173,
	Warbound_10 = 174,
	Warbound_11 = 175,
	Warbound_12 = 176,
	Warbound_13 = 177,
	Warbound_14 = 178,
	Warbound_15 = 179,
	Warbound_16 = 180,
	Warbound_17 = 181,
	Warbound_18 = 182,
	Warbound_19 = 183,
	Warbound_20 = 184,
}

---@enum Enum.ItemDisplayTextDisplayStyle
Enum.ItemDisplayTextDisplayStyle = {
	WorldQuestReward = 0,
	ItemNameAndInfoText = 1,
	ItemNameOnlyCentered = 2,
	PlayerChoiceReward = 3,
}

---@enum Enum.ItemDisplayTooltipEnabledType
Enum.ItemDisplayTooltipEnabledType = {
	Enabled = 0,
	Disabled = 1,
}

---@enum Enum.ItemGemColor
Enum.ItemGemColor = {
	Meta = 0x1,
	Red = 0x2,
	Yellow = 0x4,
	Blue = 0x8,
	Hydraulic = 0x10,
	Cogwheel = 0x20,
	Iron = 0x40,
	Blood = 0x80,
	Shadow = 0x100,
	Fel = 0x200,
	Arcane = 0x400,
	Frost = 0x800,
	Fire = 0x1000,
	Water = 0x2000,
	Life = 0x4000,
	Wind = 0x8000,
	Holy = 0x10000,
	PunchcardRed = 0x20000,
	PunchcardYellow = 0x40000,
	PunchcardBlue = 0x80000,
	DominationBlood = 0x100000,
	DominationFrost = 0x200000,
	DominationUnholy = 0x400000,
	Cypher = 0x800000,
	Tinker = 0x1000000,
	Primordial = 0x2000000,
	Fragrance = 0x4000000,
	SingingThunder = 0x8000000,
	SingingSea = 0x10000000,
	SingingWind = 0x20000000,
	Fiber = 0x40000000,
}

---@enum Enum.ItemGemSubclass
Enum.ItemGemSubclass = {
	Intellect = 0,
	Agility = 1,
	Strength = 2,
	Stamina = 3,
	Spirit = 4,
	Criticalstrike = 5,
	Mastery = 6,
	Haste = 7,
	Versatility = 8,
	Other = 9,
	Multiplestats = 10,
	Artifactrelic = 11,
}

---@enum Enum.ItemMiscellaneousSubclass
Enum.ItemMiscellaneousSubclass = {
	Junk = 0,
	Reagent = 1,
	CompanionPet = 2,
	Holiday = 3,
	Other = 4,
	Mount = 5,
	MountEquipment = 6,
}

---@enum Enum.ItemModification
Enum.ItemModification = {
	TransmogrifyItemModifiedAppearanceIDSpecAll = 0,
	TransmogrifyItemModifiedAppearanceIDSpec_0 = 1,
	IncrementLevelObsolete = 2,
	BattlePetSpecies = 3,
	BattlePetBreed = 4,
	BattlePetLevel = 5,
	BattlePetCreaturedisplayid = 6,
	TransmogrifyOverrideEnchantVisualIDSpecAll = 7,
	ArtifactAppearanceID = 8,
	TimewalkerLevel = 9,
	TransmogrifyOverrideEnchantVisualIDSpec_0 = 10,
	TransmogrifyItemModifiedAppearanceIDSpec_1 = 11,
	TransmogrifyOverrideEnchantVisualIDSpec_1 = 12,
	TransmogrifyItemModifiedAppearanceIDSpec_2 = 13,
	TransmogrifyOverrideEnchantVisualIDSpec_2 = 14,
	TransmogrifyItemModifiedAppearanceIDSpec_3 = 15,
	TransmogrifyOverrideEnchantVisualIDSpec_3 = 16,
	KeystoneMapChallengeModeID = 17,
	KeystonePowerLevel = 18,
	KeystoneAffix0 = 19,
	KeystoneAffix01 = 20,
	KeystoneAffix02 = 21,
	KeystoneAffix03 = 22,
	LegionArtifactKnowledgeObsolete = 23,
	ArtifactTier = 24,
	TransmogrifyItemModifiedAppearanceIDSpec_4 = 25,
	PvPRating = 26,
	TransmogrifyOverrideEnchantVisualIDSpec_4 = 27,
	ContentTuningID = 28,
	ChangeModifiedCraftingStat_1 = 29,
	ChangeModifiedCraftingStat_2 = 30,
	TransmogrifySecondaryItemModifiedAppearanceIDSpecAll = 31,
	TransmogrifySecondaryItemModifiedAppearanceIDSpec_0 = 32,
	TransmogrifySecondaryItemModifiedAppearanceIDSpec_1 = 33,
	TransmogrifySecondaryItemModifiedAppearanceIDSpec_2 = 34,
	TransmogrifySecondaryItemModifiedAppearanceIDSpec_3 = 35,
	TransmogrifySecondaryItemModifiedAppearanceIDSpec_4 = 36,
	SoulbindConduitRank = 37,
	CraftingQualityID = 38,
	CraftingSkillLineAbilityID = 39,
	CraftingDataID = 40,
	CraftingSkillReagents = 41,
	CraftingSkillWatermark = 42,
	CraftingReagentSlot_0 = 43,
	CraftingReagentSlot_1 = 44,
	CraftingReagentSlot_2 = 45,
	CraftingReagentSlot_3 = 46,
	CraftingReagentSlot_4 = 47,
	CraftingReagentSlot_5 = 48,
	CraftingReagentSlot_6 = 49,
	CraftingReagentSlot_7 = 50,
	CraftingReagentSlot_8 = 51,
	CraftingReagentSlot_9 = 52,
	CraftingReagentSlot_10 = 53,
	CraftingReagentSlot_11 = 54,
	CraftingReagentSlot_12 = 55,
	CraftingReagentSlot_13 = 56,
	CraftingReagentSlot_14 = 57,
	Reforge = 58,
	DbidHigh = 59,
	DbidLow = 60,
}

---@enum Enum.ItemProfessionSubclass
Enum.ItemProfessionSubclass = {
	Blacksmithing = 0,
	Leatherworking = 1,
	Alchemy = 2,
	Herbalism = 3,
	Cooking = 4,
	Mining = 5,
	Tailoring = 6,
	Engineering = 7,
	Enchanting = 8,
	Fishing = 9,
	Skinning = 10,
	Jewelcrafting = 11,
	Inscription = 12,
	Archaeology = 13,
}

---@enum Enum.ItemQuality
Enum.ItemQuality = {
	Poor = 0,
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Artifact = 6,
	Heirloom = 7,
	WoWToken = 8,
}

---@enum Enum.ItemReagentSubclass
Enum.ItemReagentSubclass = {
	Reagent = 0,
	Keystone = 1,
	ContextToken = 2,
}

---@enum Enum.ItemRecipeSubclass
Enum.ItemRecipeSubclass = {
	Book = 0,
	Leatherworking = 1,
	Tailoring = 2,
	Engineering = 3,
	Blacksmithing = 4,
	Cooking = 5,
	Alchemy = 6,
	FirstAid = 7,
	Enchanting = 8,
	Fishing = 9,
	Jewelcrafting = 10,
	Inscription = 11,
}

---@enum Enum.ItemRecraftFlags
Enum.ItemRecraftFlags = {
	ItemRecraftFlagInvalid = 1,
}

---@enum Enum.ItemRedundancySlot
Enum.ItemRedundancySlot = {
	Head = 0,
	Neck = 1,
	Shoulder = 2,
	Chest = 3,
	Waist = 4,
	Legs = 5,
	Feet = 6,
	Wrist = 7,
	Hand = 8,
	Finger = 9,
	Trinket = 10,
	Cloak = 11,
	Twohand = 12,
	MainhandWeapon = 13,
	OnehandWeapon = 14,
	OnehandWeaponSecond = 15,
	Offhand = 16,
}

---@enum Enum.ItemSlotFilterType
Enum.ItemSlotFilterType = {
	Head = 0,
	Neck = 1,
	Shoulder = 2,
	Cloak = 3,
	Chest = 4,
	Wrist = 5,
	Hand = 6,
	Waist = 7,
	Legs = 8,
	Feet = 9,
	MainHand = 10,
	OffHand = 11,
	Finger = 12,
	Trinket = 13,
	Other = 14,
	NoFilter = 15,
}

---@enum Enum.ItemSocketType
Enum.ItemSocketType = {
	None = 0,
	Meta = 1,
	Red = 2,
	Yellow = 3,
	Blue = 4,
	Hydraulic = 5,
	Cogwheel = 6,
	Prismatic = 7,
	Iron = 8,
	Blood = 9,
	Shadow = 10,
	Fel = 11,
	Arcane = 12,
	Frost = 13,
	Fire = 14,
	Water = 15,
	Life = 16,
	Wind = 17,
	Holy = 18,
	PunchcardRed = 19,
	PunchcardYellow = 20,
	PunchcardBlue = 21,
	Domination = 22,
	Cypher = 23,
	Tinker = 24,
	Primordial = 25,
	Fragrance = 26,
	SingingThunder = 27,
	SingingSea = 28,
	SingingWind = 29,
	Fiber = 30,
}

---@enum Enum.ItemSoundType
Enum.ItemSoundType = {
	Pickup = 0,
	Drop = 1,
	Use = 2,
	Close = 3,
}

---@enum Enum.ItemSubclassDisplay
Enum.ItemSubclassDisplay = {
	HideSubclassInTooltips = 1,
	HideSubclassInAuction = 2,
	ShowItemCount = 4,
}

---@enum Enum.ItemSubclassFlag
Enum.ItemSubclassFlag = {
	WeaponsubclassCanparry = 0x1,
	WeaponsubclassSetfingerseq = 0x2,
	WeaponsubclassIsunarmed = 0x4,
	WeaponsubclassIsrifle = 0x8,
	WeaponsubclassIsthrown = 0x10,
	WeaponsubclassRighthandRanged = 0x20,
	ItemsubclassQuivernotrequired = 0x40,
	WeaponsubclassRanged = 0x80,
	WeaponsubclassDeprecatedReuseMe = 0x100,
	ItemsubclassUsesInvtype = 0x200,
	ArmorsubclassLfgscalingarmor = 0x400,
}

---@enum Enum.ItemTryOnReason
Enum.ItemTryOnReason = {
	Success = 0,
	WrongRace = 1,
	NotEquippable = 2,
	DataPending = 3,
}

---@enum Enum.ItemWeaponSubclass
Enum.ItemWeaponSubclass = {
	Axe1H = 0,
	Axe2H = 1,
	Bows = 2,
	Guns = 3,
	Mace1H = 4,
	Mace2H = 5,
	Polearm = 6,
	Sword1H = 7,
	Sword2H = 8,
	Warglaive = 9,
	Staff = 10,
	Bearclaw = 11,
	Catclaw = 12,
	Unarmed = 13,
	Generic = 14,
	Dagger = 15,
	Thrown = 16,
	Obsolete3 = 17,
	Crossbow = 18,
	Wand = 19,
	Fishingpole = 20,
}

---@enum Enum.Itemclassfilterflags
Enum.Itemclassfilterflags = {
	Consumable = 0x1,
	Container = 0x2,
	Weapon = 0x4,
	Gem = 0x8,
	Armor = 0x10,
	Reagent = 0x20,
	Projectile = 0x40,
	Tradegoods = 0x80,
	ItemEnhancement = 0x100,
	Recipe = 0x200,
	CurrencyTokenObsolete = 0x400,
	Quiver = 0x800,
	Questitemclassfilterflags = 0x1000,
	Key = 0x2000,
	PermanentObsolete = 0x4000,
	Miscellaneous = 0x8000,
	Glyph = 0x10000,
	Battlepet = 0x20000,
}

---@enum Enum.Itemsetflags
Enum.Itemsetflags = {
	Legacy = 1,
	UseItemHistorySetSlots = 2,
	RequiresPvPTalentsActive = 4,
}

---@enum Enum.JailersTowerType
Enum.JailersTowerType = {
	TwistingCorridors = 0,
	SkoldusHalls = 1,
	FractureChambers = 2,
	Soulforges = 3,
	Coldheart = 4,
	Mortregar = 5,
	UpperReaches = 6,
	ArkobanHall = 7,
	TormentChamberJaina = 8,
	TormentChamberThrall = 9,
	TormentChamberAnduin = 10,
	AdamantVaults = 11,
	ForgottenCatacombs = 12,
	Ossuary = 13,
	BossRush = 14,
}

---@enum Enum.JournalEncounterFlags
Enum.JournalEncounterFlags = {
	Obsolete = 0x1,
	LimitDifficulties = 0x2,
	AllianceOnly = 0x4,
	HordeOnly = 0x8,
	NoMap = 0x10,
	InternalOnly = 0x20,
	DoNotDisplayEncounter = 0x40,
}

---@enum Enum.JournalEncounterIconFlags
Enum.JournalEncounterIconFlags = {
	Tank = 0x1,
	Dps = 0x2,
	Healer = 0x4,
	Heroic = 0x8,
	Deadly = 0x10,
	Important = 0x20,
	Interruptible = 0x40,
	Magic = 0x80,
	Curse = 0x100,
	Poison = 0x200,
	Disease = 0x400,
	Enrage = 0x800,
	Mythic = 0x1000,
	Bleed = 0x2000,
}

---@enum Enum.JournalEncounterItemFlags
Enum.JournalEncounterItemFlags = {
	Obsolete = 0x1,
	LimitDifficulties = 0x2,
	DisplayAsPerPlayerLoot = 0x4,
	DisplayAsVeryRare = 0x8,
	DisplayAsExtremelyRare = 0x10,
}

---@enum Enum.JournalEncounterLocFlags
Enum.JournalEncounterLocFlags = {
	Primary = 1,
}

---@enum Enum.JournalEncounterSecTypes
Enum.JournalEncounterSecTypes = {
	Generic = 0,
	Creature = 1,
	Ability = 2,
	Overview = 3,
}

---@enum Enum.JournalEncounterSectionFlags
Enum.JournalEncounterSectionFlags = {
	StartExpanded = 1,
	LimitDifficulties = 2,
}

---@enum Enum.JournalInstanceFlags
Enum.JournalInstanceFlags = {
	Timewalker = 1,
	HideUserSelectableDifficulty = 2,
	DoNotDisplayInstance = 4,
}

---@enum Enum.JournalLinkTypes
Enum.JournalLinkTypes = {
	Instance = 0,
	Encounter = 1,
	Section = 2,
	Tier = 3,
}

---@enum Enum.LFGEntryPlaystyle
Enum.LFGEntryPlaystyle = {
	None = 0,
	Standard = 1,
	Casual = 2,
	Hardcore = 3,
}

---@enum Enum.LFGListDisplayType
Enum.LFGListDisplayType = {
	RoleCount = 0,
	RoleEnumerate = 1,
	ClassEnumerate = 2,
	HideAll = 3,
	PlayerCount = 4,
	Comment = 5,
}

---@enum Enum.LFGListFilter
Enum.LFGListFilter = {
	Recommended = 0x1,
	NotRecommended = 0x2,
	PvE = 0x4,
	PvP = 0x8,
	Timerunning = 0x10,
	CurrentExpansion = 0x20,
	CurrentSeason = 0x40,
	NotCurrentSeason = 0x80,
}

---@enum Enum.LFGRole
Enum.LFGRole = {
	Tank = 0,
	Healer = 1,
	Damage = 2,
}

---@enum Enum.LFGSlotInvalidReason
Enum.LFGSlotInvalidReason = {
	None = 0,
	ExpansionTooLow = 1,
	LevelTooLow = 2,
	LevelTooHigh = 3,
	GearTooLow = 4,
	GearTooHigh = 5,
	RaidLocked = 6,
	LevelTargetTooLow = 7,
	LevelTargetTooHigh = 8,
	AreaNotExplored = 9,
	WrongFaction = 10,
	NoValidRoles = 11,
	EngagedInPvP = 12,
	NoSpec = 13,
	CannotRunAnyChildDungeon = 14,
	Restricted = 15,
	ChromieTime = 16,
	Npe = 17,
	Timerunning = 18,
	PlayerConditionFailed = 19,
}

---@enum Enum.LanguageFlag
Enum.LanguageFlag = {
	IsExotic = 1,
	HiddenFromPlayer = 2,
	HideLanguageNameInChat = 4,
}

---@enum Enum.LeavePartyConfirmReason
Enum.LeavePartyConfirmReason = {
	QuestSync = 0,
	RestrictedChallengeMode = 1,
}

---@enum Enum.LgVendorPurchaseSettlementState
Enum.LgVendorPurchaseSettlementState = {
	Settled = 0,
	NotSettled = 1,
}

---@enum Enum.LgVendorPurchaseSqlResults
Enum.LgVendorPurchaseSqlResults = {
	Failed = 0,
	Success = 100,
	InsufficientFunds = 101,
	AlreadyOwned = 102,
	InsufficientSpent = 103,
	NotOwned = 104,
	RefundExpired = 105,
	NoRecord = 106,
	InvalidState = 107,
}

---@enum Enum.LgVendorPurchaseState
Enum.LgVendorPurchaseState = {
	NotOwned = 0,
	Owned = 1,
}

---@enum Enum.LinkedCurrencyFlags
Enum.LinkedCurrencyFlags = {
	IgnoreAdd = 0x1,
	IgnoreSubtract = 0x2,
	SuppressChatLog = 0x4,
	AddIgnoresMax = 0x8,
}

---@enum Enum.LoadConfigResult
Enum.LoadConfigResult = {
	Error = 0,
	NoChangesNecessary = 1,
	LoadInProgress = 2,
	Ready = 3,
}

---@enum Enum.LogPriority
Enum.LogPriority = {
	Fatal = 1,
	Error = 2,
	Warning = 3,
	Normal = 10,
	Debug = 30,
	Spam = 40,
}

---@enum Enum.LogicLogicop
Enum.LogicLogicop = {
	None = 0,
	And = 1,
	Or = 2,
	Xor = 3,
}

---@enum Enum.LogicMathop
Enum.LogicMathop = {
	None = 0,
	Plus = 1,
	Minus = 2,
	Times = 3,
	Div = 4,
	Mod = 5,
}

---@enum Enum.LogicRelop
Enum.LogicRelop = {
	None = 0,
	Equal = 1,
	Notequal = 2,
	Lt = 3,
	Lteq = 4,
	Gt = 5,
	Gteq = 6,
}

---@enum Enum.LootMethod
Enum.LootMethod = {
	Freeforall = 0,
	Roundrobin = 1,
	Masterlooter = 2,
	Group = 3,
	Needbeforegreed = 4,
	Personal = 5,
}

---@enum Enum.LootMethodStyles
Enum.LootMethodStyles = {
	PersonalOnly = 0,
	Vanilla = 1,
}

---@enum Enum.LootSlotType
Enum.LootSlotType = {
	None = 0,
	Item = 1,
	Money = 2,
	Currency = 3,
}

---@enum Enum.MajorFactionFeatureAbility
Enum.MajorFactionFeatureAbility = {
	Generic = 0,
	Fishing = 1,
	Hunts = 2,
}

---@enum Enum.MajorFactionType
Enum.MajorFactionType = {
	None = 0,
	DragonscaleExpedition = 1,
	MaruukCentaur = 2,
	IskaaraTuskarr = 3,
	ValdrakkenAccord = 4,
}

---@enum Enum.ManipulatorEventType
Enum.ManipulatorEventType = {
	Start = 0,
	Move = 1,
	Complete = 2,
	Delete = 3,
}

---@enum Enum.MapCanvasPosition
Enum.MapCanvasPosition = {
	None = 0,
	BottomLeft = 1,
	BottomRight = 2,
	TopLeft = 3,
	TopRight = 4,
}

---@enum Enum.MapIconUIWidgetSetType
Enum.MapIconUIWidgetSetType = {
	Tooltip = 0,
	BehindIcon = 1,
}

---@enum Enum.MapOverlayDisplayLocation
Enum.MapOverlayDisplayLocation = {
	Default = 0,
	BottomLeft = 1,
	TopLeft = 2,
	BottomRight = 3,
	TopRight = 4,
	Hidden = 5,
}

---@enum Enum.MapPinAnimationType
Enum.MapPinAnimationType = {
	None = 0,
	Pulse = 1,
}

---@enum Enum.MatchDetailType
Enum.MatchDetailType = {
	Placement = 0,
	Kills = 1,
	PlunderAcquired = 2,
}

---@enum Enum.MicroMenuOrder
Enum.MicroMenuOrder = {
	Default = 0,
	Reverse = 1,
}

---@enum Enum.MicroMenuOrientation
Enum.MicroMenuOrientation = {
	Horizontal = 0,
	Vertical = 1,
}

---@enum Enum.MinimapTrackingFilter
Enum.MinimapTrackingFilter = {
	Unfiltered = 0x0,
	Auctioneer = 0x1,
	Banker = 0x2,
	Battlemaster = 0x4,
	TaxiNode = 0x8,
	VenderFood = 0x10,
	Innkeeper = 0x20,
	Mailbox = 0x40,
	TrainerProfession = 0x80,
	VendorReagent = 0x100,
	Repair = 0x200,
	TrivialQuests = 0x400,
	Stablemaster = 0x800,
	Transmogrifier = 0x1000,
	POI = 0x2000,
	Target = 0x4000,
	Focus = 0x8000,
	QuestPoIs = 0x10000,
	Digsites = 0x20000,
	Barber = 0x40000,
	ItemUpgrade = 0x80000,
	VendorPoison = 0x100000,
	AccountCompletedQuests = 0x200000,
	AccountBanker = 0x400000,
}

---@enum Enum.ModelBlendOperation
Enum.ModelBlendOperation = {
	None = 0,
	Anim = 1,
}

---@enum Enum.ModelLightType
Enum.ModelLightType = {
	Directional = 0,
	Point = 1,
}

---@enum Enum.ModelSceneSetting
Enum.ModelSceneSetting = {
	AlignLightToOrbitDelta = 1,
}

---@enum Enum.ModelSceneType
Enum.ModelSceneType = {
	MountJournal = 0,
	PetJournalCard = 1,
	ShopCard = 2,
	EncounterJournal = 3,
	PetJournalLoadout = 4,
	ArtifactTier2 = 5,
	ArtifactTier2ForgingScene = 6,
	ArtifactTier2SlamEffect = 7,
	CommentatorVictoryFanfare = 8,
	ArtifactRelicTalentEffect = 9,
	PvPWarModeOrb = 10,
	PvPWarModeFire = 11,
	PartyPose = 12,
	AzeriteItemLevelUpToast = 13,
	AzeritePowers = 14,
	AzeriteRewardGlow = 15,
	HeartOfAzeroth = 16,
	WorldMapThreat = 17,
	Soulbinds = 18,
	JailersTowerAnimaGlow = 19,
}

---@enum Enum.ModelSoundOverrideType
Enum.ModelSoundOverrideType = {
	UseParent = 0,
	UseOverride = 1,
	Mute = 2,
}

---@enum Enum.ModelSoundTagType
Enum.ModelSoundTagType = {
	Oneshot = 1,
	Looping = 2,
}

---@enum Enum.MountType
Enum.MountType = {
	Ground = 0,
	Flying = 1,
	Aquatic = 2,
	Dragonriding = 3,
	RideAlong = 4,
}

---@enum Enum.MountTypeFlag
Enum.MountTypeFlag = {
	IsFlyingMount = 0x1,
	IsAquaticMount = 0x2,
	IsDragonRidingMount = 0x4,
	IsRideAlongMount = 0x8,
}

---@enum Enum.NavigationState
Enum.NavigationState = {
	Invalid = 0,
	Occluded = 1,
	InRange = 2,
	Disabled = 3,
}

---@enum Enum.NewCharGear
Enum.NewCharGear = {
	Start = 0,
	Preview = 1,
}

---@enum Enum.NodeOpFailureReason
Enum.NodeOpFailureReason = {
	None = 0,
	MissingEdgeConnection = 1,
	RequiredForEdge = 2,
	MissingRequiredEdge = 3,
	HasMutuallyExclusiveEdge = 4,
	NotEnoughSourcedCurrencySpent = 5,
	NotEnoughCurrencySpent = 6,
	NotEnoughGoldSpent = 7,
	MissingAchievement = 8,
	MissingQuest = 9,
	WrongSpec = 10,
	WrongSelection = 11,
	MaxRank = 12,
	DataError = 13,
	NotEnoughSourcedCurrency = 14,
	NotEnoughCurrency = 15,
	NotEnoughGold = 16,
	SameSelection = 17,
	NodeNotFound = 18,
	EntryNotFound = 19,
	RequiredForCondition = 20,
	WrongTreeID = 21,
	LevelTooLow = 22,
	TreeFlaggedNoRefund = 23,
	NodeNeverPurchasable = 24,
	AccountDataNoMatch = 25,
}

---@enum Enum.NpcCraftingOrderSetFlags
Enum.NpcCraftingOrderSetFlags = {
	CraftingOrderFlagAllowMultiple = 1,
	CraftingOrderFlagAllowDuplicate = 2,
}

---@enum Enum.PartyPlaylistEntry
Enum.PartyPlaylistEntry = {
	SoloGameMode = 0,
	DuoGameMode = 1,
	TrioGameMode = 2,
	TrainingGameMode = 3,
}

---@enum Enum.PartyPoseFlags
Enum.PartyPoseFlags = {
	HideLeaveInstanceButton = 1,
}

---@enum Enum.PartyRequestJoinRelation
Enum.PartyRequestJoinRelation = {
	None = 0,
	Friend = 1,
	Guild = 2,
	Club = 3,
	NumPartyRequestJoinRelations = 4,
}

---@enum Enum.PerksVendorCategoryType
Enum.PerksVendorCategoryType = {
	Transmog = 1,
	Mount = 2,
	Pet = 3,
	Toy = 5,
	Illusion = 7,
	Transmogset = 8,
	WarbandScene = 9,
	Stipend = 20,
	Activity = 21,
	GmAdjustment = 22,
	Achievement = 23,
	Refund = 24,
}

---@enum Enum.PermanentChatChannelType
Enum.PermanentChatChannelType = {
	None = 0,
	Zone = 1,
	Communities = 2,
	Custom = 3,
}

---@enum Enum.PetActionFeedback
Enum.PetActionFeedback = {
	Success = 0,
	Dead = 1,
	InvalidTarget = 2,
	FriendlyTarget = 3,
	NoPath = 4,
}

---@enum Enum.PetActionbuttonType
Enum.PetActionbuttonType = {
	None = 0,
	Spell = 1,
	Slot1Obsolete = 2,
	Slot2Obsolete = 3,
	Slot3Obsolete = 4,
	Slot4Obsolete = 5,
	Mode = 6,
	Orders = 7,
	Slot1 = 8,
	Slot2 = 9,
	Slot3 = 10,
	Slot4 = 11,
	Slot5 = 12,
	Slot6 = 13,
	Slot7 = 14,
	Slot8 = 15,
	Slot9 = 16,
	Slot10 = 17,
	Max = 18,
	VehicleAction = 19,
}

---@enum Enum.PetBattleQueueStatus
Enum.PetBattleQueueStatus = {
	None = 0,
	Queued = 1,
	QueuedUpdate = 2,
	AlreadyQueued = 3,
	JoinFailed = 4,
	JoinFailedSlots = 5,
	JoinFailedJournalLock = 6,
	JoinFailedNeutral = 7,
	MatchAccepted = 8,
	MatchDeclined = 9,
	MatchOpponentDeclined = 10,
	ProposalTimedOut = 11,
	Removed = 12,
	RequeuedAfterInternalError = 13,
	RequeuedAfterOpponentRemoved = 14,
	Matchmaking = 15,
	LostConnection = 16,
	Shutdown = 17,
	Suspended = 18,
	Unsuspended = 19,
	InBattle = 20,
	NoBattlingHere = 21,
}

---@enum Enum.PetJournalError
Enum.PetJournalError = {
	None = 0,
	PetIsDead = 1,
	JournalIsLocked = 2,
	InvalidFaction = 3,
	NoFavoritesToSummon = 4,
	NoValidRandomSummon = 5,
}

---@enum Enum.PetMode
Enum.PetMode = {
	Passive = 0,
	Defensive = 1,
	Aggressive = 2,
	Assist = 3,
}

---@enum Enum.PetOrders
Enum.PetOrders = {
	Wait = 0,
	Follow = 1,
	Attack = 2,
	Dismiss = 3,
	MoveTo = 4,
}

---@enum Enum.PetOverride
Enum.PetOverride = {
	None = 0,
	AICombatControl = 1,
	AICombatPassive = 2,
	OwnerMounted = 4,
}

---@enum Enum.PetbattleAuraStateFlags
Enum.PetbattleAuraStateFlags = {
	None = 0x0,
	Infinite = 0x1,
	Canceled = 0x2,
	InitDisabled = 0x4,
	CountdownFirstRound = 0x8,
	JustApplied = 0x10,
	RemoveEventHandled = 0x20,
}

---@enum Enum.PetbattleCheatFlags
Enum.PetbattleCheatFlags = {
	None = 0,
	AutoPlay = 1,
}

---@enum Enum.PetbattleEffectFlags
Enum.PetbattleEffectFlags = {
	None = 0x0,
	InvalidTarget = 0x1,
	Miss = 0x2,
	Crit = 0x4,
	Blocked = 0x8,
	Dodge = 0x10,
	Heal = 0x20,
	Unkillable = 0x40,
	Reflect = 0x80,
	Absorb = 0x100,
	Immune = 0x200,
	Strong = 0x400,
	Weak = 0x800,
	SuccessChain = 0x1000,
	AuraReapply = 0x2000,
}

---@enum Enum.PetbattleEffectType
Enum.PetbattleEffectType = {
	SetHealth = 0,
	AuraApply = 1,
	AuraCancel = 2,
	AuraChange = 3,
	PetSwap = 4,
	StatusChange = 5,
	SetState = 6,
	SetMaxHealth = 7,
	SetSpeed = 8,
	SetPower = 9,
	TriggerAbility = 10,
	AbilityChange = 11,
	NpcEmote = 12,
	AuraProcessingBegin = 13,
	AuraProcessingEnd = 14,
	ReplacePet = 15,
	OverrideAbility = 16,
	WorldStateUpdate = 17,
}

---@enum Enum.PetbattleEnviros
Enum.PetbattleEnviros = {
	Pad0 = 0,
	Pad1 = 1,
	Weather = 2,
}

---@enum Enum.PetbattleInputMoveMsgDebugFlag
Enum.PetbattleInputMoveMsgDebugFlag = {
	None = 0,
	DontValidate = 1,
	EnemyCast = 2,
}

---@enum Enum.PetbattleMoveType
Enum.PetbattleMoveType = {
	Quit = 0,
	Ability = 1,
	Swap = 2,
	Trap = 3,
	FinalRoundOk = 4,
	Pass = 5,
}

---@enum Enum.PetbattlePboid
Enum.PetbattlePboid = {
	P0Pet_0 = 0,
	P0Pet_1 = 1,
	P0Pet_2 = 2,
	P1Pet_0 = 3,
	P1Pet_1 = 4,
	P1Pet_2 = 5,
	EnvPad_0 = 6,
	EnvPad_1 = 7,
	EnvWeather = 8,
}

---@enum Enum.PetbattlePetStatus
Enum.PetbattlePetStatus = {
	FlagNone = 0x0,
	FlagTrapped = 0x1,
	Stunned = 0x2,
	SwapOutLocked = 0x4,
	SwapInLocked = 0x8,
}

---@enum Enum.PetbattlePlayer
Enum.PetbattlePlayer = {
	Player_0 = 0,
	Player_1 = 1,
}

---@enum Enum.PetbattlePlayerInputFlags
Enum.PetbattlePlayerInputFlags = {
	None = 0x0,
	TurnInProgress = 0x1,
	AbilityLocked = 0x2,
	SwapLocked = 0x4,
	WaitingForPet = 0x8,
}

---@enum Enum.PetbattleResult
Enum.PetbattleResult = {
	FailUnknown = 0,
	FailNotHere = 1,
	FailNotHereOnTransport = 2,
	FailNotHereUnevenGround = 3,
	FailNotHereObstructed = 4,
	FailNotWhileInCombat = 5,
	FailNotWhileDead = 6,
	FailNotWhileFlying = 7,
	FailTargetInvalid = 8,
	FailTargetOutOfRange = 9,
	FailTargetNotCapturable = 10,
	FailNotATrainer = 11,
	FailDeclined = 12,
	FailInBattle = 13,
	FailInvalidLoadout = 14,
	FailInvalidLoadoutAllDead = 15,
	FailInvalidLoadoutNoneSlotted = 16,
	FailNoJournalLock = 17,
	FailWildPetTapped = 18,
	FailRestrictedAccount = 19,
	FailOpponentNotAvailable = 20,
	FailLogout = 21,
	FailDisconnect = 22,
	Success = 23,
}

---@enum Enum.PetbattleSlot
Enum.PetbattleSlot = {
	Slot_0 = 0,
	Slot_1 = 1,
	Slot_2 = 2,
}

---@enum Enum.PetbattleSlotAbility
Enum.PetbattleSlotAbility = {
	Ability_0 = 0,
	Ability_1 = 1,
	Ability_2 = 2,
}

---@enum Enum.PetbattleSlotResult
Enum.PetbattleSlotResult = {
	Success = 0,
	SlotLocked = 1,
	SlotEmpty = 2,
	NoTracker = 3,
	NoSpeciesRec = 4,
	CantBattle = 5,
	Revoked = 6,
	Dead = 7,
	NoPet = 8,
}

---@enum Enum.PetbattleState
Enum.PetbattleState = {
	Created = 0,
	WaitingPreBattle = 1,
	RoundInProgress = 2,
	WaitingForFrontPets = 3,
	CreatedFailed = 4,
	FinalRound = 5,
	Finished = 6,
}

---@enum Enum.PetbattleTrapstatus
Enum.PetbattleTrapstatus = {
	Invalid = 0,
	CanTrap = 1,
	CantTrapNewbie = 2,
	CantTrapPetDead = 3,
	CantTrapPetHealth = 4,
	CantTrapNoRoomInJournal = 5,
	CantTrapPetNotCapturable = 6,
	CantTrapTrainerBattle = 7,
	CantTrapTwice = 8,
}

---@enum Enum.PetbattleType
Enum.PetbattleType = {
	PvE = 0,
	PvP = 1,
	Lfpb = 2,
	Npc = 3,
}

---@enum Enum.Pettameresult
Enum.Pettameresult = {
	Ok = 0,
	Invalidcreature = 1,
	Toomany = 2,
	Creaturealreadyowned = 3,
	Nottameable = 4,
	Anothersummonactive = 5,
	Unitscanttame = 6,
	Nopetavailable = 7,
	Internalerror = 8,
	Toohighlevel = 9,
	Dead = 10,
	Notdead = 11,
	Cantcontrolexotic = 12,
	Invalidslot = 13,
	EliteToohighlevel = 14,
	Numresults = 15,
}

---@enum Enum.PhaseReason
Enum.PhaseReason = {
	Phasing = 0,
	Sharding = 1,
	WarMode = 2,
	ChromieTime = 3,
}

---@enum Enum.PingMode
Enum.PingMode = {
	KeyDown = 0,
	ClickDrag = 1,
}

---@enum Enum.PingResult
Enum.PingResult = {
	Success = 0,
	FailedGeneric = 1,
	FailedSpamming = 2,
	FailedDisabledByLeader = 3,
	FailedDisabledBySettings = 4,
	FailedOutOfPingArea = 5,
	FailedSquelched = 6,
	FailedUnspecified = 7,
}

---@enum Enum.PingSubjectType
Enum.PingSubjectType = {
	Attack = 0,
	Warning = 1,
	Assist = 2,
	OnMyWay = 3,
	AlertThreat = 4,
	AlertNotThreat = 5,
}

---@enum Enum.PingTextureType
Enum.PingTextureType = {
	Center = 0,
	Expand = 1,
	Rotation = 2,
}

---@enum Enum.PingTypeFlags
Enum.PingTypeFlags = {
	DefaultPing = 1,
}

---@enum Enum.PlayerChoiceRarity
Enum.PlayerChoiceRarity = {
	Common = 0,
	Uncommon = 1,
	Rare = 2,
	Epic = 3,
}

---@enum Enum.PlayerClubRequestStatus
Enum.PlayerClubRequestStatus = {
	None = 0,
	Pending = 1,
	AutoApproved = 2,
	Declined = 3,
	Approved = 4,
	Joined = 5,
	JoinedAnother = 6,
	Canceled = 7,
}

---@enum Enum.PlayerCurrencyFlags
Enum.PlayerCurrencyFlags = {
	Incremented = 1,
	Loading = 2,
}

---@enum Enum.PlayerCurrencyFlagsDbFlags
Enum.PlayerCurrencyFlagsDbFlags = {
	IgnoreMaxQtyOnload = 0x1,
	Reuse1 = 0x2,
	InBackpack = 0x4,
	UnusedInUI = 0x8,
	Reuse2 = 0x10,
}

---@enum Enum.PlayerInteractionType
Enum.PlayerInteractionType = {
	None = 0,
	TradePartner = 1,
	Item = 2,
	Gossip = 3,
	QuestGiver = 4,
	Merchant = 5,
	TaxiNode = 6,
	Trainer = 7,
	Banker = 8,
	AlliedRaceDetailsGiver = 9,
	GuildBanker = 10,
	Registrar = 11,
	Vendor = 12,
	PetitionVendor = 13,
	GuildTabardVendor = 14,
	TalentMaster = 15,
	SpecializationMaster = 16,
	MailInfo = 17,
	SpiritHealer = 18,
	AreaSpiritHealer = 19,
	Binder = 20,
	Auctioneer = 21,
	StableMaster = 22,
	BattleMaster = 23,
	Transmogrifier = 24,
	LFGDungeon = 25,
	VoidStorageBanker = 26,
	BlackMarketAuctioneer = 27,
	AdventureMap = 28,
	WorldMap = 29,
	GarrArchitect = 30,
	GarrTradeskill = 31,
	GarrMission = 32,
	ShipmentCrafter = 33,
	GarrRecruitment = 34,
	GarrTalent = 35,
	Trophy = 36,
	PlayerChoice = 37,
	ArtifactForge = 38,
	ObliterumForge = 39,
	ScrappingMachine = 40,
	ContributionCollector = 41,
	AzeriteRespec = 42,
	IslandQueue = 43,
	ItemInteraction = 44,
	ChromieTime = 45,
	CovenantPreview = 46,
	AnimaDiversion = 47,
	LegendaryCrafting = 48,
	WeeklyRewards = 49,
	Soulbind = 50,
	CovenantSanctum = 51,
	NewPlayerGuide = 52,
	ItemUpgrade = 53,
	AdventureJournal = 54,
	Renown = 55,
	AzeriteForge = 56,
	PerksProgramVendor = 57,
	ProfessionsCraftingOrder = 58,
	Professions = 59,
	ProfessionsCustomerOrder = 60,
	TraitSystem = 61,
	BarbersChoice = 62,
	JailersTowerBuffs = 63,
	MajorFactionRenown = 64,
	PersonalTabardVendor = 65,
	ForgeMaster = 66,
	CharacterBanker = 67,
	AccountBanker = 68,
	ProfessionRespec = 69,
	PlaceholderType71 = 70,
	PlaceholderType72 = 71,
	PlaceholderType73 = 72,
	PlaceholderType74 = 73,
	PlaceholderType75 = 74,
	PlaceholderType76 = 75,
	GuildRename = 76,
	PlaceholderType77 = 77,
}

---@enum Enum.PlayerMentorshipApplicationResult
Enum.PlayerMentorshipApplicationResult = {
	Success = 0,
	AlreadyMentor = 1,
	Ineligible = 2,
}

---@enum Enum.PlayerMentorshipStatus
Enum.PlayerMentorshipStatus = {
	None = 0,
	Newcomer = 1,
	Mentor = 2,
}

---@enum Enum.PlunderstormQueueState
Enum.PlunderstormQueueState = {
	None = 0,
	Queued = 1,
	Proposed = 2,
	Suspended = 3,
}

---@enum Enum.PointsModifierSourceType
Enum.PointsModifierSourceType = {
	PlayerLevel = 0,
	SkillRank = 1,
	ProgressiveEventMissCount = 2,
	ProgressiveEventItemWinCount = 3,
	NumLooters = 4,
	BaseItemLevel = 5,
	LootLevel = 6,
	InstanceGroupSize = 7,
	QuestItemGroupMissCount = 8,
	TreasureItemPvalue = 9,
	FollowerLevelInBuilding = 10,
	FollowerQualityInBuilding = 11,
	NumGroupFriends = 12,
	FollowerLevelForCurrentShipment = 13,
	FollowerQualityForCurrentShipment = 14,
	PvPBracketRatingSpecific = 15,
	ChallengeModeLevel = 16,
	CurrencyMaxDelta = 17,
	WorldStateValue = 18,
	PlayerKeystoneLevel = 19,
	PlayerCondition = 20,
	PassesTreasureTrackingQuestEligibility = 21,
	PvPBracketRatingCurrentInstance = 22,
	PvPTeamSize = 23,
	ItemLevelHighWaterMarkAverage = 24,
	ProgressiveEventNumWinsForLootSpec = 25,
	ProgressiveEventNumRemainingForLootSpec = 26,
	WorldStateExpression = 27,
	ProgressiveEventNumRemainingForClass = 28,
	CreatureClassification = 29,
	HonorEarnedThisPvPMatch = 30,
	NumTappers = 31,
	PvPJackpotTier = 32,
	PlayerLevelContentTuningMax = 33,
	SalvagedItemIsCloth = 34,
	SalvagedItemIsLeather = 35,
	SalvagedItemIsMail = 36,
	SalvagedItemIsPlate = 37,
	SalvagedItemIsMisc = 38,
	QuestExpansionID = 39,
	Reserved_2 = 40,
	JailersTowerActiveFloorDifficulty = 41,
	NumLootSourceAuraStacks = 42,
	HasLegendaryCloakUpdgradeAvailable = 43,
	ObjectLevel = 44,
	PercentThroughContentTuning = 45,
	PvPTier = 46,
	CurrencyQuantity = 47,
	AreaGroup = 48,
	ObjectLabelID = 49,
	WeeklyMythicPlusCount = 50,
	PercentThroughExpansion = 51,
	AutoMissionScalar = 52,
	RenownCatchup = 53,
	RenownRapidCatchup = 54,
	ParagonLevel = 55,
	NumPlayersThatGainedDungeonScore = 56,
	ProfessionQualityLevel = 57,
	CraftSkill = 58,
	NumWeeklyRewardsThresholdsEarned = 59,
	SalvagedItemLevel = 60,
	ProfessionRatingFinessePercent = 61,
	ProfessionRatingPerceptionPercent = 62,
	ProfessionTraitRanksByLabel = 63,
	CreatureHealthMod = 64,
	FirstTimeQuestCompletionRewards = 65,
	PointsModifierSet = 66,
	CurrencyMaxWeeklyDelta = 67,
	RaidEncounterLevel = 68,
}

---@enum Enum.PowerType
Enum.PowerType = {
	Mana = 0,
	Rage = 1,
	Focus = 2,
	Energy = 3,
	ComboPoints = 4,
	Runes = 5,
	RunicPower = 6,
	SoulShards = 7,
	LunarPower = 8,
	HolyPower = 9,
	Alternate = 10,
	Maelstrom = 11,
	Chi = 12,
	Insanity = 13,
	BurningEmbers = 14,
	DemonicFury = 15,
	ArcaneCharges = 16,
	Fury = 17,
	Pain = 18,
	Essence = 19,
	RuneBlood = 20,
	RuneFrost = 21,
	RuneUnholy = 22,
	AlternateQuest = 23,
	AlternateEncounter = 24,
	AlternateMount = 25,
	Balance = 26,
	Happiness = 27,
	ShadowOrbs = 28,
	RuneChromatic = 29,
}

---@enum Enum.PowerTypeSign
Enum.PowerTypeSign = {
	None = -1,
	Positive = 0,
	Negative = 1,
}

---@enum Enum.PowerTypeSlot
Enum.PowerTypeSlot = {
	Slot_0 = 0,
	Slot_1 = 1,
	Slot_2 = 2,
	Slot_3 = 3,
	Slot_4 = 4,
	Slot_5 = 5,
	Slot_6 = 6,
	Slot_7 = 7,
	Slot_8 = 8,
	Slot_9 = 9,
}

---@enum Enum.PremadeGroupFinderStyle
Enum.PremadeGroupFinderStyle = {
	Disabled = 0,
	Mainline = 1,
	Vanilla = 2,
}

---@enum Enum.ProfTraitPerkNodeFlags
Enum.ProfTraitPerkNodeFlags = {
	UnlocksSubpath = 1,
	IsMajorBonus = 2,
}

---@enum Enum.Profession
Enum.Profession = {
	FirstAid = 0,
	Blacksmithing = 1,
	Leatherworking = 2,
	Alchemy = 3,
	Herbalism = 4,
	Cooking = 5,
	Mining = 6,
	Tailoring = 7,
	Engineering = 8,
	Enchanting = 9,
	Fishing = 10,
	Skinning = 11,
	Jewelcrafting = 12,
	Inscription = 13,
	Archaeology = 14,
}

---@enum Enum.ProfessionActionType
Enum.ProfessionActionType = {
	Craft = 0,
	Gather = 1,
}

---@enum Enum.ProfessionEffect
Enum.ProfessionEffect = {
	Skill = 0,
	StatInspiration = 1,
	StatResourcefulness = 2,
	StatFinesse = 3,
	StatDeftness = 4,
	StatPerception = 5,
	StatCraftingSpeed = 6,
	StatMulticraft = 7,
	UnlockReagentSlot = 8,
	ModInspiration = 9,
	ModResourcefulness = 10,
	ModFinesse = 11,
	ModDeftness = 12,
	ModPerception = 13,
	ModCraftingSpeed = 14,
	ModMulticraft = 15,
	ModUnused_1 = 16,
	ModUnused_2 = 17,
	ModCraftExtraQuantity = 18,
	ModGatherExtraQuantity = 19,
	ModCraftCritSize = 20,
	ModCraftReductionQuantity = 21,
	DecreaseDifficulty = 22,
	IncreaseDifficulty = 23,
	ModSkillGain = 24,
	AccumulateRanksByLabel = 25,
	StatIngenuity = 26,
	ModConcentration = 27,
	Tokenizer = 28,
	ModIngenuity = 29,
	ConcentrationRefund = 30,
}

---@enum Enum.ProfessionRating
Enum.ProfessionRating = {
	Inspiration = 0,
	Resourcefulness = 1,
	Finesse = 2,
	Deftness = 3,
	Perception = 4,
	CraftingSpeed = 5,
	Multicraft = 6,
	Ingenuity = 7,
	Unused_2 = 8,
}

---@enum Enum.ProfessionRatingType
Enum.ProfessionRatingType = {
	Craft = 0,
	Gather = 1,
}

---@enum Enum.ProfessionsSpecPathState
Enum.ProfessionsSpecPathState = {
	Locked = 0,
	Progressing = 1,
	Completed = 2,
}

---@enum Enum.ProfessionsSpecPerkState
Enum.ProfessionsSpecPerkState = {
	Unearned = 0,
	Pending = 1,
	Earned = 2,
}

---@enum Enum.ProfessionsSpecTabState
Enum.ProfessionsSpecTabState = {
	Locked = 0,
	Unlocked = 1,
	Unlockable = 2,
}

---@enum Enum.PvPFaction
Enum.PvPFaction = {
	Horde = 0,
	Alliance = 1,
}

---@enum Enum.PvPMatchState
Enum.PvPMatchState = {
	Inactive = 0,
	Waiting = 1,
	StartUp = 2,
	Engaged = 3,
	PostRound = 4,
	Complete = 5,
}

---@enum Enum.PvPMatchmakingType
Enum.PvPMatchmakingType = {
	Battleground = 0,
	Arena = 1,
}

---@enum Enum.PvPRanks
Enum.PvPRanks = {
	RankNone = 0,
	RankPariah = 1,
	RankOutlaw = 2,
	RankExiled = 3,
	RankDishonored = 4,
	Rank_1 = 5,
	Rank_2 = 6,
	Rank_3 = 7,
	Rank_4 = 8,
	Rank_5 = 9,
	Rank_6 = 10,
	Rank_7 = 11,
	Rank_8 = 12,
	Rank_9 = 13,
	Rank_10 = 14,
	Rank_11 = 15,
	Rank_12 = 16,
	Rank_13 = 17,
	Rank_14 = 18,
}

---@enum Enum.PvPUnitClassification
Enum.PvPUnitClassification = {
	FlagCarrierHorde = 0,
	FlagCarrierAlliance = 1,
	FlagCarrierNeutral = 2,
	CartRunnerHorde = 3,
	CartRunnerAlliance = 4,
	AssassinHorde = 5,
	AssassinAlliance = 6,
	OrbCarrierBlue = 7,
	OrbCarrierGreen = 8,
	OrbCarrierOrange = 9,
	OrbCarrierPurple = 10,
}

---@enum Enum.QuestClassification
Enum.QuestClassification = {
	Important = 0,
	Legendary = 1,
	Campaign = 2,
	Calling = 3,
	Meta = 4,
	Recurring = 5,
	Questline = 6,
	Normal = 7,
	BonusObjective = 8,
	Threat = 9,
	WorldQuest = 10,
}

---@enum Enum.QuestCompleteSpellType
Enum.QuestCompleteSpellType = {
	LegacyBehavior = 0,
	Follower = 1,
	Tradeskill = 2,
	Ability = 3,
	Aura = 4,
	Spell = 5,
	Unlock = 6,
	Companion = 7,
	QuestlineUnlock = 8,
	QuestlineReward = 9,
	QuestlineUnlockPart = 10,
	PossibleReward = 11,
}

---@enum Enum.QuestFrequency
Enum.QuestFrequency = {
	Default = 0,
	Daily = 1,
	Weekly = 2,
	ResetByScheduler = 3,
}

---@enum Enum.QuestLineFloorLocation
Enum.QuestLineFloorLocation = {
	Above = 0,
	Below = 1,
	Same = 2,
}

---@enum Enum.QuestRepeatability
Enum.QuestRepeatability = {
	None = 0,
	Daily = 1,
	Weekly = 2,
	Turnin = 3,
	World = 4,
}

---@enum Enum.QuestRewardContextFlags
Enum.QuestRewardContextFlags = {
	None = 0,
	FirstCompletionBonus = 1,
	RepeatCompletionBonus = 2,
}

---@enum Enum.QuestSessionCommand
Enum.QuestSessionCommand = {
	None = 0,
	Start = 1,
	Stop = 2,
	SessionActiveNoCommand = 3,
}

---@enum Enum.QuestSessionResult
Enum.QuestSessionResult = {
	Ok = 0,
	NotInParty = 1,
	InvalidOwner = 2,
	AlreadyActive = 3,
	NotActive = 4,
	InRaid = 5,
	OwnerRefused = 6,
	Timeout = 7,
	Disabled = 8,
	Started = 9,
	Stopped = 10,
	Joined = 11,
	Left = 12,
	OwnerLeft = 13,
	ReadyCheckFailed = 14,
	PartyDestroyed = 15,
	MemberTimeout = 16,
	AlreadyMember = 17,
	NotOwner = 18,
	AlreadyOwner = 19,
	AlreadyJoined = 20,
	NotMember = 21,
	Busy = 22,
	JoinRejected = 23,
	Logout = 24,
	Empty = 25,
	QuestNotCompleted = 26,
	Resync = 27,
	Restricted = 28,
	InPetBattle = 29,
	InvalidPublicParty = 30,
	Unknown = 31,
	InCombat = 32,
	MemberInCombat = 33,
	RestrictedCrossFaction = 34,
}

---@enum Enum.QuestTag
Enum.QuestTag = {
	Group = 1,
	PvP = 41,
	Raid = 62,
	Dungeon = 81,
	Legendary = 83,
	Heroic = 85,
	Raid10 = 88,
	Raid25 = 89,
	Scenario = 98,
	Account = 102,
	CombatAlly = 266,
	Delve = 288,
}

---@enum Enum.QuestTagType
Enum.QuestTagType = {
	Tag = 0,
	Profession = 1,
	Normal = 2,
	PvP = 3,
	PetBattle = 4,
	Bounty = 5,
	Dungeon = 6,
	Invasion = 7,
	Raid = 8,
	Contribution = 9,
	RatedReward = 10,
	InvasionWrapper = 11,
	FactionAssault = 12,
	Islands = 13,
	Threat = 14,
	CovenantCalling = 15,
	DragonRiderRacing = 16,
	Capstone = 17,
	WorldBoss = 18,
}

---@enum Enum.QuestTreasurePickerType
Enum.QuestTreasurePickerType = {
	Visible = 0,
	Hidden = 1,
	Select = 2,
}

---@enum Enum.QuestWatchType
Enum.QuestWatchType = {
	Automatic = 0,
	Manual = 1,
}

---@enum Enum.RafLinkType
Enum.RafLinkType = {
	None = 0,
	Recruit = 1,
	Friend = 2,
	Both = 3,
}

---@enum Enum.RafRecruitActivityState
Enum.RafRecruitActivityState = {
	Incomplete = 0,
	Complete = 1,
	RewardClaimed = 2,
}

---@enum Enum.RafRecruitSubStatus
Enum.RafRecruitSubStatus = {
	Trial = 0,
	Active = 1,
	Inactive = 2,
}

---@enum Enum.RafRewardType
Enum.RafRewardType = {
	Pet = 0,
	Mount = 1,
	Appearance = 2,
	Title = 3,
	GameTime = 4,
	AppearanceSet = 5,
	Illusion = 6,
	Invalid = 7,
}

---@enum Enum.RaidGroupDisplayType
Enum.RaidGroupDisplayType = {
	SeparateGroupsVertical = 0,
	SeparateGroupsHorizontal = 1,
	CombineGroupsVertical = 2,
	CombineGroupsHorizontal = 3,
}

---@enum Enum.RcoCloseReason
Enum.RcoCloseReason = {
	RcoCloseFulfill = 0,
	RcoCloseExpire = 1,
	RcoCloseCancel = 2,
	RcoCloseReject = 3,
	RcoCloseGmCancel = 4,
	RcoCloseCrafterFulfill = 5,
	RcoCloseInvalid = 6,
}

---@enum Enum.RecipeRequirementType
Enum.RecipeRequirementType = {
	SpellFocus = 0,
	Totem = 1,
	Area = 2,
}

---@enum Enum.RecruitAFriendRewardsVersion
Enum.RecruitAFriendRewardsVersion = {
	InvalidVersion = 0,
	UnusedVersionOne = 1,
	VersionTwo = 2,
	VersionThree = 3,
}

---@enum Enum.RegisterAddonMessagePrefixResult
Enum.RegisterAddonMessagePrefixResult = {
	Success = 0,
	DuplicatePrefix = 1,
	InvalidPrefix = 2,
	MaxPrefixes = 3,
}

---@enum Enum.RelativeContentDifficulty
Enum.RelativeContentDifficulty = {
	Trivial = 0,
	Easy = 1,
	Fair = 2,
	Difficult = 3,
	Impossible = 4,
}

---@enum Enum.ReportMajorCategory
Enum.ReportMajorCategory = {
	InappropriateCommunication = 0,
	GameplaySabotage = 1,
	Cheating = 2,
	InappropriateName = 3,
}

---@enum Enum.ReportMinorCategory
Enum.ReportMinorCategory = {
	TextChat = 0x1,
	Boosting = 0x2,
	Spam = 0x4,
	Afk = 0x8,
	IntentionallyFeeding = 0x10,
	BlockingProgress = 0x20,
	Hacking = 0x40,
	Botting = 0x80,
	Advertisement = 0x100,
	BTag = 0x200,
	GroupName = 0x400,
	CharacterName = 0x800,
	GuildName = 0x1000,
	Description = 0x2000,
	Name = 0x4000,
	HarmfulToMinors = 0x8000,
	Disruption = 0x10000,
	TerroristAndViolentExtremistContent = 0x20000,
	ChildSexualExploitationAndAbuse = 0x40000,
}

---@enum Enum.ReportSubComplaintTypes
Enum.ReportSubComplaintTypes = {
	Inappropriate = 0,
	Advertising = 1,
}

---@enum Enum.ReportType
Enum.ReportType = {
	Chat = 0,
	InWorld = 1,
	ClubFinderPosting = 2,
	ClubFinderApplicant = 3,
	GroupFinderPosting = 4,
	GroupFinderApplicant = 5,
	ClubMember = 6,
	GroupMember = 7,
	Friend = 8,
	Pet = 9,
	BattlePet = 10,
	Calendar = 11,
	Mail = 12,
	PvP = 13,
	PvPScoreboard = 14,
	PvPGroupMember = 15,
	CraftingOrder = 16,
}

---@enum Enum.ReputationSortType
Enum.ReputationSortType = {
	None = 0,
	Account = 1,
	Character = 2,
}

---@enum Enum.RestrictPingsTo
Enum.RestrictPingsTo = {
	None = 0,
	Lead = 1,
	Assist = 2,
	TankHealer = 3,
}

---@enum Enum.RuneforgePowerFilter
Enum.RuneforgePowerFilter = {
	All = 0,
	Relevant = 1,
	Available = 2,
	Unavailable = 3,
}

---@enum Enum.RuneforgePowerState
Enum.RuneforgePowerState = {
	Available = 0,
	Unavailable = 1,
	Invalid = 2,
}

---@enum Enum.ScreenLocationType
Enum.ScreenLocationType = {
	Center = 0,
	Left = 1,
	Right = 2,
	Top = 3,
	Bottom = 4,
	TopLeft = 5,
	TopRight = 6,
	LeftOutside = 7,
	RightOutside = 8,
	LeftRight = 9,
	TopBottom = 10,
	LeftRightOutside = 11,
}

---@enum Enum.ScriptedAnimationBehavior
Enum.ScriptedAnimationBehavior = {
	None = 0,
	TargetShake = 1,
	TargetKnockBack = 2,
	SourceRecoil = 3,
	SourceCollideWithTarget = 4,
	UIParentShake = 5,
}

---@enum Enum.ScriptedAnimationFlags
Enum.ScriptedAnimationFlags = {
	UseTargetAsSource = 1,
}

---@enum Enum.ScriptedAnimationTrajectory
Enum.ScriptedAnimationTrajectory = {
	AtSource = 0,
	AtTarget = 1,
	Straight = 2,
	CurveLeft = 3,
	CurveRight = 4,
	CurveRandom = 5,
	HalfwayBetween = 6,
}

---@enum Enum.ScrubStringFlags
Enum.ScrubStringFlags = {
	None = 0,
	TruncateNewLines = 1,
	AllowBarCodes = 2,
	StripControlCodes = 4,
}

---@enum Enum.SeasonID
Enum.SeasonID = {
	NoSeason = 0,
	SeasonOfMastery = 1,
	SeasonOfDiscovery = 2,
	Hardcore = 3,
	Fresh = 11,
	FreshHardcore = 12,
}

---@enum Enum.SelfResurrectOptionType
Enum.SelfResurrectOptionType = {
	Spell = 0,
	Item = 1,
}

---@enum Enum.SendAddonMessageResult
Enum.SendAddonMessageResult = {
	Success = 0,
	InvalidPrefix = 1,
	InvalidMessage = 2,
	AddonMessageThrottle = 3,
	InvalidChatType = 4,
	NotInGroup = 5,
	TargetRequired = 6,
	InvalidChannel = 7,
	ChannelThrottle = 8,
	GeneralError = 9,
	NotInGuild = 10,
}

---@enum Enum.SendReportResult
Enum.SendReportResult = {
	Success = 0,
	GeneralError = 1,
	TooManyReports = 2,
	RequiresChatLine = 3,
	RequiresChatLineOrVoice = 4,
}

---@enum Enum.SharedStringFlag
Enum.SharedStringFlag = {
	InternalOnly = 1,
}

---@enum Enum.Siflag
Enum.Siflag = {
	None = 0x0,
	Disablepositionallpf = 0x1,
	UseModCastSpeed = 0x2,
	AutocreatedByBroadcastText = 0x4,
	Playsequential = 0x8,
	Affectedbyaltitude = 0x10,
	Noduplicates = 0x20,
	Ignoresuppressors = 0x40,
	CasterOwnsTargetSound = 0x80,
	Dontplayindoors = 0x100,
	Looping = 0x200,
	Dontplayunderwater = 0x400,
	Affectedbysanity = 0x800,
	Dontstopondeath = 0x1000,
	Playonlyforowner = 0x2000,
	Ignorevopriority = 0x4000,
	Onlyplayindoors = 0x8000,
	Onlyplayunderwater = 0x10000,
}

---@enum Enum.SkinningState
Enum.SkinningState = {
	None = 0,
	Reserved = 1,
	Skinning = 2,
	Looting = 3,
	Skinned = 4,
}

---@enum Enum.SlotRegion
Enum.SlotRegion = {
	Invalid = 0,
	PlayerEquip = 1,
	PlayerBags = 2,
	PlayerInv = 3,
	CharacterBank = 4,
	AccountBank = 5,
}

---@enum Enum.SlotRegionMask
Enum.SlotRegionMask = {
	Invalid = 0x1,
	PlayerEquip = 0x2,
	PlayerBags = 0x4,
	PlayerInv = 0x8,
	CharacterBank = 0x10,
	AccountBank = 0x40,
}

---@enum Enum.SocialWhoOrigin
Enum.SocialWhoOrigin = {
	Unknown = 0,
	Social = 1,
	Chat = 2,
	Item = 3,
}

---@enum Enum.SoftTargetEnableFlags
Enum.SoftTargetEnableFlags = {
	None = 0,
	Gamepad = 1,
	Kbm = 2,
	Any = 3,
}

---@enum Enum.SortPlayersBy
Enum.SortPlayersBy = {
	Role = 0,
	Group = 1,
	Alphabetical = 2,
}

---@enum Enum.SoulbindConduitFlags
Enum.SoulbindConduitFlags = {
	VisibleToGetallsoulbindconduitScript = 1,
}

---@enum Enum.SoulbindConduitInstallResult
Enum.SoulbindConduitInstallResult = {
	Success = 0,
	InvalidItem = 1,
	InvalidConduit = 2,
	InvalidTalent = 3,
	DuplicateConduit = 4,
	ForgeNotInProximity = 5,
	SocketNotEmpty = 6,
}

---@enum Enum.SoulbindConduitTransactionType
Enum.SoulbindConduitTransactionType = {
	Install = 0,
	Uninstall = 1,
}

---@enum Enum.SoulbindConduitType
Enum.SoulbindConduitType = {
	Finesse = 0,
	Potency = 1,
	Endurance = 2,
	Flex = 3,
}

---@enum Enum.SoulbindNodeState
Enum.SoulbindNodeState = {
	Unavailable = 0,
	Unselected = 1,
	Selectable = 2,
	Selected = 3,
}

---@enum Enum.SoundBusFlag
Enum.SoundBusFlag = {
	Disablepositionallpf = 1,
}

---@enum Enum.SpecializationSystem
Enum.SpecializationSystem = {
	TalentTab = 0,
	ChrSpecialization = 1,
}

---@enum Enum.SpellBookItemType
Enum.SpellBookItemType = {
	None = 0,
	Spell = 1,
	FutureSpell = 2,
	PetAction = 3,
	Flyout = 4,
}

---@enum Enum.SpellBookSkillLineIndex
Enum.SpellBookSkillLineIndex = {
	General = 1,
	Class = 2,
	MainSpec = 3,
	OffSpecStart = 4,
}

---@enum Enum.SpellBookSpellBank
Enum.SpellBookSpellBank = {
	Player = 0,
	Pet = 1,
}

---@enum Enum.SpellDisplayBorderColor
Enum.SpellDisplayBorderColor = {
	None = 0,
	Black = 1,
	White = 2,
	Red = 3,
	Yellow = 4,
	Orange = 5,
	Purple = 6,
	Green = 7,
	Blue = 8,
}

---@enum Enum.SpellDisplayIconDisplayType
Enum.SpellDisplayIconDisplayType = {
	Buff = 0,
	Debuff = 1,
	Circular = 2,
	NoBorder = 3,
}

---@enum Enum.SpellDisplayTextShownStateType
Enum.SpellDisplayTextShownStateType = {
	Shown = 0,
	Hidden = 1,
}

---@enum Enum.SpellDisplayTint
Enum.SpellDisplayTint = {
	None = 0,
	Red = 1,
}

---@enum Enum.SplashScreenType
Enum.SplashScreenType = {
	WhatsNew = 0,
	SeasonRollOver = 1,
}

---@enum Enum.StableResult
Enum.StableResult = {
	MaxSlots = 0,
	InsufficientFunds = 1,
	NotStableMaster = 2,
	InvalidSlot = 3,
	NoPet = 4,
	AlreadyStabled = 5,
	AlreadySummoned = 6,
	NotFound = 7,
	StableSuccess = 8,
	UnstableSuccess = 9,
	ReviveSuccess = 10,
	CantControlExotic = 11,
	InternalError = 12,
	CheckForLuaHack = 13,
	BuySlotSuccess = 14,
	FavoriteToggle = 15,
	PetRenamed = 16,
}

---@enum Enum.StartTimerType
Enum.StartTimerType = {
	PvPBeginTimer = 0,
	ChallengeModeCountdown = 1,
	PlayerCountdown = 2,
	PlunderstormCountdown = 3,
}

---@enum Enum.StatusBarColorTintValue
Enum.StatusBarColorTintValue = {
	None = 0,
	Black = 1,
	White = 2,
	Red = 3,
	Yellow = 4,
	Orange = 5,
	Purple = 6,
	Green = 7,
	Blue = 8,
}

---@enum Enum.StatusBarOverrideBarTextShownType
Enum.StatusBarOverrideBarTextShownType = {
	Never = 0,
	Always = 1,
	OnlyOnMouseover = 2,
	OnlyNotOnMouseover = 3,
}

---@enum Enum.StatusBarValueTextType
Enum.StatusBarValueTextType = {
	Hidden = 0,
	Percentage = 1,
	Value = 2,
	Time = 3,
	TimeShowOneLevelOnly = 4,
	ValueOverMax = 5,
	ValueOverMaxNormalized = 6,
}

---@enum Enum.SubcontainerType
Enum.SubcontainerType = {
	Bag = 0,
	Equipped = 1,
	Bankgeneric = 2,
	Bankbag = 3,
	Mail = 4,
	Auction = 5,
	Keyring = 6,
	GuildBank0 = 7,
	GuildBank1 = 8,
	GuildBank2 = 9,
	GuildBank3 = 10,
	GuildBank4 = 11,
	GuildBank5 = 12,
	GuildOverflow = 13,
	Equipablespells = 14,
	CurrencytokenOboslete = 15,
	GuildBank6 = 16,
	GuildBank7 = 17,
	GuildBank8 = 18,
	GuildBank9 = 19,
	GuildBank10 = 20,
	GuildBank11 = 21,
	Reagentbank = 22,
	Childequipmentstorage = 23,
	Quarantine = 24,
	CreatedImmediately = 25,
	BuybackSlots = 26,
	CachedReward = 27,
	EquippedBags = 28,
	EquippedProfession1 = 29,
	EquippedProfession2 = 30,
	EquippedCooking = 31,
	EquippedFishing = 32,
	EquippedReagentbag = 33,
	CraftingOrder = 34,
	CraftingOrderReagents = 35,
	AccountBankTabs = 36,
	CurrencyTransfer = 37,
	CharacterBankTabs = 38,
	HousingDecorConversion = 39,
}

---@enum Enum.SubscriptionInterstitialResponseType
Enum.SubscriptionInterstitialResponseType = {
	Clicked = 0,
	Closed = 1,
	WebRedirect = 2,
}

---@enum Enum.SubscriptionInterstitialType
Enum.SubscriptionInterstitialType = {
	Standard = 0,
	LeftNpeArea = 1,
	MaxLevel = 2,
}

---@enum Enum.SummonStatus
Enum.SummonStatus = {
	None = 0,
	Pending = 1,
	Accepted = 2,
	Declined = 3,
}

---@enum Enum.SuperTrackingMapPinType
Enum.SuperTrackingMapPinType = {
	AreaPOI = 0,
	QuestOffer = 1,
	TaxiNode = 2,
	DigSite = 3,
}

---@enum Enum.SuperTrackingType
Enum.SuperTrackingType = {
	Quest = 0,
	UserWaypoint = 1,
	Corpse = 2,
	Scenario = 3,
	Content = 4,
	PartyMember = 5,
	MapPin = 6,
	Vignette = 7,
}

---@enum Enum.TimeEventFlag
Enum.TimeEventFlag = {
	GlueScreenShortcut = 1,
	WeeklyReset = 2,
	GlobalLaunch = 4,
}

---@enum Enum.TitleIconVersion
Enum.TitleIconVersion = {
	Small = 0,
	Medium = 1,
	Large = 2,
}

---@enum Enum.TooltipComparisonMethod
Enum.TooltipComparisonMethod = {
	Single = 0,
	WithBothHands = 1,
	WithBagMainHandItem = 2,
	WithBagOffHandItem = 3,
}

---@enum Enum.TooltipDataItemBinding
Enum.TooltipDataItemBinding = {
	Quest = 0,
	Account = 1,
	BnetAccount = 2,
	Soulbound = 3,
	BindToAccount = 4,
	BindToBnetAccount = 5,
	BindOnPickup = 6,
	BindOnEquip = 7,
	BindOnUse = 8,
	AccountUntilEquipped = 9,
	BindToAccountUntilEquipped = 10,
}

---@enum Enum.TooltipDataLineType
Enum.TooltipDataLineType = {
	None = 0,
	Blank = 1,
	UnitName = 2,
	GemSocket = 3,
	AzeriteEssenceSlot = 4,
	AzeriteEssencePower = 5,
	LearnableSpell = 6,
	UnitThreat = 7,
	QuestObjective = 8,
	AzeriteItemPowerDescription = 9,
	RuneforgeLegendaryPowerDescription = 10,
	SellPrice = 11,
	ProfessionCraftingQuality = 12,
	SpellName = 13,
	CurrencyTotal = 14,
	ItemEnchantmentPermanent = 15,
	UnitOwner = 16,
	QuestTitle = 17,
	QuestPlayer = 18,
	NestedBlock = 19,
	ItemBinding = 20,
	RestrictedRaceClass = 21,
	RestrictedFaction = 22,
	RestrictedSkill = 23,
	RestrictedPvPMedal = 24,
	RestrictedReputation = 25,
	RestrictedSpellKnown = 26,
	RestrictedLevel = 27,
	EquipSlot = 28,
	ItemName = 29,
	Separator = 30,
	ToyName = 31,
	ToyText = 32,
	ToyEffect = 33,
	ToyDuration = 34,
	RestrictedArena = 35,
	RestrictedBg = 36,
	ToyFlavorText = 37,
	ToyDescription = 38,
	ToySource = 39,
	GemSocketEnchantment = 40,
	ItemLevel = 41,
	ItemUpgradeLevel = 42,
}

---@enum Enum.TooltipDataType
Enum.TooltipDataType = {
	Item = 0,
	Spell = 1,
	Unit = 2,
	Corpse = 3,
	Object = 4,
	Currency = 5,
	BattlePet = 6,
	UnitAura = 7,
	AzeriteEssence = 8,
	CompanionPet = 9,
	Mount = 10,
	PetAction = 11,
	Achievement = 12,
	EnhancedConduit = 13,
	EquipmentSet = 14,
	InstanceLock = 15,
	PvPBrawl = 16,
	RecipeRankInfo = 17,
	Totem = 18,
	Toy = 19,
	CorruptionCleanser = 20,
	MinimapMouseover = 21,
	Flyout = 22,
	Quest = 23,
	QuestPartyProgress = 24,
	Macro = 25,
	Debug = 26,
}

---@enum Enum.TooltipSide
Enum.TooltipSide = {
	Left = 0,
	Right = 1,
	Top = 2,
	Bottom = 3,
}

---@enum Enum.TooltipTextureAnchor
Enum.TooltipTextureAnchor = {
	LeftTop = 0,
	LeftCenter = 1,
	LeftBottom = 2,
	RightTop = 3,
	RightCenter = 4,
	RightBottom = 5,
	All = 6,
}

---@enum Enum.TooltipTextureRelativeRegion
Enum.TooltipTextureRelativeRegion = {
	LeftLine = 0,
	RightLine = 1,
}

---@enum Enum.TrackedSpellCategory
Enum.TrackedSpellCategory = {
	None = 0,
	Offensive = 1,
	Defensive = 2,
	Debuff = 3,
	RacialAbility = 4,
}

---@enum Enum.TradeskillOrderDuration
Enum.TradeskillOrderDuration = {
	Short = 1,
	Medium = 2,
	Long = 3,
}

---@enum Enum.TradeskillOrderRecipient
Enum.TradeskillOrderRecipient = {
	Public = 1,
	Guild = 2,
	Private = 3,
}

---@enum Enum.TradeskillOrderStatus
Enum.TradeskillOrderStatus = {
	Unclaimed = 1,
	Started = 2,
	Completed = 3,
	Expired = 4,
}

---@enum Enum.TradeskillRecipeType
Enum.TradeskillRecipeType = {
	Item = 1,
	Salvage = 2,
	Enchant = 3,
	Recraft = 4,
	Gathering = 5,
}

---@enum Enum.TradeskillRelativeDifficulty
Enum.TradeskillRelativeDifficulty = {
	Optimal = 0,
	Medium = 1,
	Easy = 2,
	Trivial = 3,
}

---@enum Enum.TradeskillSlotDataType
Enum.TradeskillSlotDataType = {
	Reagent = 1,
	ModifiedReagent = 2,
	Currency = 3,
}

---@enum Enum.TraitCombatConfigFlags
Enum.TraitCombatConfigFlags = {
	ActiveForSpec = 1,
	StarterBuild = 2,
	SharedActionBars = 4,
}

---@enum Enum.TraitCondFlag
Enum.TraitCondFlag = {
	IsGate = 1,
	IsAlwaysMet = 2,
	IsSufficient = 4,
}

---@enum Enum.TraitConditionType
Enum.TraitConditionType = {
	Available = 0,
	Visible = 1,
	Granted = 2,
	Increased = 3,
	DisplayError = 4,
}

---@enum Enum.TraitConfigDbState
Enum.TraitConfigDbState = {
	Ready = 0,
	Created = 1,
	Removed = 2,
	Deleted = 3,
}

---@enum Enum.TraitConfigType
Enum.TraitConfigType = {
	Invalid = 0,
	Combat = 1,
	Profession = 2,
	Generic = 3,
}

---@enum Enum.TraitCurrencyFlag
Enum.TraitCurrencyFlag = {
	ShowQuantityAsSpent = 0x1,
	TraitSourcedShowMax = 0x2,
	UseClassIcon = 0x4,
	UseSpecIcon = 0x8,
}

---@enum Enum.TraitCurrencyType
Enum.TraitCurrencyType = {
	Gold = 0,
	CurrencyTypesBased = 1,
	TraitSourced = 2,
}

---@enum Enum.TraitDefinitionSubType
Enum.TraitDefinitionSubType = {
	DragonflightRed = 0,
	DragonflightBlue = 1,
	DragonflightGreen = 2,
	DragonflightBronze = 3,
	DragonflightBlack = 4,
}

---@enum Enum.TraitEdgeType
Enum.TraitEdgeType = {
	VisualOnly = 0,
	DeprecatedRankConnection = 1,
	SufficientForAvailability = 2,
	RequiredForAvailability = 3,
	MutuallyExclusive = 4,
	DeprecatedSelectionOption = 5,
}

---@enum Enum.TraitEdgeVisualStyle
Enum.TraitEdgeVisualStyle = {
	None = 0,
	Straight = 1,
}

---@enum Enum.TraitNodeEntryType
Enum.TraitNodeEntryType = {
	SpendHex = 0,
	SpendSquare = 1,
	SpendCircle = 2,
	SpendSmallCircle = 3,
	DeprecatedSelect = 4,
	DragAndDrop = 5,
	SpendDiamond = 6,
	ProfPath = 7,
	ProfPerk = 8,
	ProfPathUnlock = 9,
}

---@enum Enum.TraitNodeFlag
Enum.TraitNodeFlag = {
	ShowMultipleIcons = 0x1,
	NeverPurchasable = 0x2,
	TestPositionLocked = 0x4,
	TestGridPositioned = 0x8,
}

---@enum Enum.TraitNodeGroupFlag
Enum.TraitNodeGroupFlag = {
	AvailableByDefault = 1,
}

---@enum Enum.TraitNodeType
Enum.TraitNodeType = {
	Single = 0,
	Tiered = 1,
	Selection = 2,
	SubTreeSelection = 3,
}

---@enum Enum.TraitPointsOperationType
Enum.TraitPointsOperationType = {
	None = -1,
	Set = 0,
	Multiply = 1,
}

---@enum Enum.TraitSystemFlag
Enum.TraitSystemFlag = {
	AllowMultipleLoadoutsPerTree = 1,
	ShowSpendConfirmation = 2,
	AllowEditInCombat = 4,
}

---@enum Enum.TraitTreeFlag
Enum.TraitTreeFlag = {
	CannotRefund = 1,
	HideSingleRankNumbers = 2,
}

---@enum Enum.TransmogCameraVariation
Enum.TransmogCameraVariation = {
	None = 0,
	CloakBackpack = 1,
	RightShoulder = 1,
}

---@enum Enum.TransmogCollectionType
Enum.TransmogCollectionType = {
	None = 0,
	Head = 1,
	Shoulder = 2,
	Back = 3,
	Chest = 4,
	Shirt = 5,
	Tabard = 6,
	Wrist = 7,
	Hands = 8,
	Waist = 9,
	Legs = 10,
	Feet = 11,
	Wand = 12,
	OneHAxe = 13,
	OneHSword = 14,
	OneHMace = 15,
	Dagger = 16,
	Fist = 17,
	Shield = 18,
	Holdable = 19,
	TwoHAxe = 20,
	TwoHSword = 21,
	TwoHMace = 22,
	Staff = 23,
	Polearm = 24,
	Bow = 25,
	Gun = 26,
	Crossbow = 27,
	Warglaives = 28,
	Paired = 29,
}

---@enum Enum.TransmogIllusionFlags
Enum.TransmogIllusionFlags = {
	HideUntilCollected = 1,
	PlayerConditionGrantsOnLogin = 2,
}

---@enum Enum.TransmogModification
Enum.TransmogModification = {
	Main = 0,
	Secondary = 1,
}

---@enum Enum.TransmogPendingType
Enum.TransmogPendingType = {
	Apply = 0,
	Revert = 1,
	ToggleOn = 2,
	ToggleOff = 3,
}

---@enum Enum.TransmogSearchType
Enum.TransmogSearchType = {
	Items = 1,
	BaseSets = 2,
	UsableSets = 3,
}

---@enum Enum.TransmogSlot
Enum.TransmogSlot = {
	Head = 0,
	Shoulder = 1,
	Back = 2,
	Chest = 3,
	Body = 4,
	Tabard = 5,
	Wrist = 6,
	Hand = 7,
	Waist = 8,
	Legs = 9,
	Feet = 10,
	Mainhand = 11,
	Offhand = 12,
}

---@enum Enum.TransmogSource
Enum.TransmogSource = {
	None = 0,
	JournalEncounter = 1,
	Quest = 2,
	Vendor = 3,
	WorldDrop = 4,
	HiddenUntilCollected = 5,
	CantCollect = 6,
	Achievement = 7,
	Profession = 8,
	NotValidForTransmog = 9,
	TradingPost = 10,
}

---@enum Enum.TransmogType
Enum.TransmogType = {
	Appearance = 0,
	Illusion = 1,
}

---@enum Enum.TransmogUseErrorType
Enum.TransmogUseErrorType = {
	None = 0,
	PlayerCondition = 1,
	Skill = 2,
	Ability = 3,
	Reputation = 4,
	Holiday = 5,
	HotRecheckFailed = 6,
	Class = 7,
	Race = 8,
	Faction = 9,
	ItemProficiency = 10,
}

---@enum Enum.TtsBoolSetting
Enum.TtsBoolSetting = {
	PlaySoundSeparatingChatLineBreaks = 0,
	AddCharacterNameToSpeech = 1,
	PlayActivitySoundWhenNotFocused = 2,
	AlternateSystemVoice = 3,
	NarrateMyMessages = 4,
}

---@enum Enum.TtsVoiceType
Enum.TtsVoiceType = {
	Standard = 0,
	Alternate = 1,
}

---@enum Enum.TugOfWarMarkerArrowShownState
Enum.TugOfWarMarkerArrowShownState = {
	Never = 0,
	Always = 1,
	FlashOnMove = 2,
}

---@enum Enum.TugOfWarStyleValue
Enum.TugOfWarStyleValue = {
	DefaultYellow = 0,
	ArchaeologyBrown = 1,
}

---@enum Enum.UIActionType
Enum.UIActionType = {
	DefaultAction = 0,
	UpdateMapSystem = 1,
}

---@enum Enum.UICursorType
Enum.UICursorType = {
	Default = 0,
	Item = 1,
	Money = 2,
	Spell = 3,
	PetAction = 4,
	Merchant = 5,
	ActionBar = 6,
	Macro = 7,
	AmmoObsolete = 8,
	Pet = 9,
	GuildBank = 10,
	GuildBankMoney = 11,
	EquipmentSet = 12,
	Currency = 13,
	Flyout = 14,
	VoidItem = 15,
	BattlePet = 16,
	Mount = 17,
	Toy = 18,
	ConduitCollectionItem = 19,
	PerksProgramVendorItem = 20,
}

---@enum Enum.UIFrameType
Enum.UIFrameType = {
	JailersTowerBuffs = 0,
}

---@enum Enum.UIItemInteractionFlags
Enum.UIItemInteractionFlags = {
	DisplayWithInset = 0x1,
	ConfirmationHasDelay = 0x2,
	ConversionMode = 0x4,
	ClickShowsFlyout = 0x8,
	AddCurrency = 0x10,
	UsesCharges = 0x20,
}

---@enum Enum.UIItemInteractionType
Enum.UIItemInteractionType = {
	None = 0,
	CastSpell = 1,
	CleanseCorruption = 2,
	RunecarverScrapping = 3,
	ItemConversion = 4,
}

---@enum Enum.UIMapFlag
Enum.UIMapFlag = {
	NoHighlight = 0x1,
	ShowOverlays = 0x2,
	ShowTaxiNodes = 0x4,
	GarrisonMap = 0x8,
	FallbackToParentMap = 0x10,
	NoHighlightTexture = 0x20,
	ShowTaskObjectives = 0x40,
	NoWorldPositions = 0x80,
	HideArchaeologyDigs = 0x100,
	DoNotTranslateBranches = 0x200,
	HideIcons = 0x400,
	HideVignettes = 0x800,
	ForceAllOverlayExplored = 0x1000,
	FlightMapShowZoomOut = 0x2000,
	FlightMapAutoZoom = 0x4000,
	ForceOnNavbar = 0x8000,
	AlwaysAllowUserWaypoints = 0x10000,
	AlwaysAllowTaxiPathing = 0x20000,
	ForceAllowMapLinks = 0x40000,
	DoNotShowOnNavbar = 0x80000,
	IsCityMap = 0x100000,
	IgnoreInTranslationsToParent = 0x200000,
}

---@enum Enum.UIMapGroupFlag
Enum.UIMapGroupFlag = {
	ShowIconsAcrossFloors = 1,
}

---@enum Enum.UIMapSystem
Enum.UIMapSystem = {
	World = 0,
	Taxi = 1,
	Adventure = 2,
	Minimap = 3,
}

---@enum Enum.UIMapType
Enum.UIMapType = {
	Cosmic = 0,
	World = 1,
	Continent = 2,
	Zone = 3,
	Dungeon = 4,
	Micro = 5,
	Orphan = 6,
}

---@enum Enum.UIModelSceneActorFlag
Enum.UIModelSceneActorFlag = {
	Deprecated1 = 0x1,
	UseCenterForOriginX = 0x2,
	UseCenterForOriginY = 0x4,
	UseCenterForOriginZ = 0x8,
}

---@enum Enum.UIModelSceneContext
Enum.UIModelSceneContext = {
	None = -1,
	PerksProgram = 0,
}

---@enum Enum.UIModelSceneFlags
Enum.UIModelSceneFlags = {
	SheatheWeapon = 1,
	HideWeapon = 2,
	Autodress = 4,
}

---@enum Enum.UISystemType
Enum.UISystemType = {
	InGameNavigation = 0,
}

---@enum Enum.UITextureSliceMode
Enum.UITextureSliceMode = {
	Stretched = 0,
	Tiled = 1,
}

---@enum Enum.UIWidgetBlendModeType
Enum.UIWidgetBlendModeType = {
	Opaque = 0,
	Additive = 1,
}

---@enum Enum.UIWidgetButtonEnabledState
Enum.UIWidgetButtonEnabledState = {
	Disabled = 0,
	Enabled = 1,
}

---@enum Enum.UIWidgetButtonIconType
Enum.UIWidgetButtonIconType = {
	Exit = 0,
	Speak = 1,
	Undo = 2,
	Checkmark = 3,
	RedX = 4,
}

---@enum Enum.UIWidgetFlag
Enum.UIWidgetFlag = {
	UniversalWidget = 1,
}

---@enum Enum.UIWidgetFontType
Enum.UIWidgetFontType = {
	Normal = 0,
	Shadow = 1,
	Outline = 2,
}

---@enum Enum.UIWidgetHorizontalDirection
Enum.UIWidgetHorizontalDirection = {
	LeftToRight = 0,
	RightToLeft = 1,
}

---@enum Enum.UIWidgetLayoutDirection
Enum.UIWidgetLayoutDirection = {
	Default = 0,
	Vertical = 1,
	Horizontal = 2,
	Overlap = 3,
	HorizontalForceNewRow = 4,
}

---@enum Enum.UIWidgetModelSceneLayer
Enum.UIWidgetModelSceneLayer = {
	None = 0,
	Front = 1,
	Back = 2,
}

---@enum Enum.UIWidgetMotionType
Enum.UIWidgetMotionType = {
	Instant = 0,
	Smooth = 1,
}

---@enum Enum.UIWidgetOverrideState
Enum.UIWidgetOverrideState = {
	Inactive = 0,
	Active = 1,
}

---@enum Enum.UIWidgetRewardShownState
Enum.UIWidgetRewardShownState = {
	Hidden = 0,
	ShownEarned = 1,
	ShownUnearned = 2,
}

---@enum Enum.UIWidgetScale
Enum.UIWidgetScale = {
	OneHundred = 0,
	Ninty = 1,
	Eighty = 2,
	Seventy = 3,
	Sixty = 4,
	Fifty = 5,
	OneHundredTen = 6,
	OneHundredTwenty = 7,
	OneHundredThirty = 8,
	OneHundredForty = 9,
	OneHundredFifty = 10,
	OneHundredSixty = 11,
	OneHundredSeventy = 12,
	OneHundredEighty = 13,
	OneHundredNinety = 14,
	TwoHundred = 15,
}

---@enum Enum.UIWidgetSetLayoutDirection
Enum.UIWidgetSetLayoutDirection = {
	Vertical = 0,
	Horizontal = 1,
	Overlap = 2,
}

---@enum Enum.UIWidgetSpellButtonCooldownType
Enum.UIWidgetSpellButtonCooldownType = {
	HideCooldown = 0,
	ShowCooldown = 1,
	ShowCooldownAndDisableOnCooldown = 2,
}

---@enum Enum.UIWidgetTextFormatType
Enum.UIWidgetTextFormatType = {
	None = 0,
	TimeOneLevel = 1,
	TimeTwoLevel = 2,
	LeadingZeroesWithSixDigits = 3,
}

---@enum Enum.UIWidgetTextSizeType
Enum.UIWidgetTextSizeType = {
	Small12Pt = 0,
	Medium16Pt = 1,
	Large24Pt = 2,
	Huge27Pt = 3,
	Standard14Pt = 4,
	Small10Pt = 5,
	Small11Pt = 6,
	Medium18Pt = 7,
	Large20Pt = 8,
}

---@enum Enum.UIWidgetTextureAndTextSizeType
Enum.UIWidgetTextureAndTextSizeType = {
	Small = 0,
	Medium = 1,
	Large = 2,
	Huge = 3,
	Standard = 4,
	Medium2 = 5,
}

---@enum Enum.UIWidgetTooltipLocation
Enum.UIWidgetTooltipLocation = {
	Default = 0,
	BottomLeft = 1,
	Left = 2,
	TopLeft = 3,
	Top = 4,
	TopRight = 5,
	Right = 6,
	BottomRight = 7,
	Bottom = 8,
}

---@enum Enum.UIWidgetUpdateAnimType
Enum.UIWidgetUpdateAnimType = {
	None = 0,
	Flash = 1,
	FlashAndAnimateNumber = 2,
}

---@enum Enum.UIWidgetVisualizationType
Enum.UIWidgetVisualizationType = {
	IconAndText = 0,
	CaptureBar = 1,
	StatusBar = 2,
	DoubleStatusBar = 3,
	IconTextAndBackground = 4,
	DoubleIconAndText = 5,
	StackedResourceTracker = 6,
	IconTextAndCurrencies = 7,
	TextWithState = 8,
	HorizontalCurrencies = 9,
	BulletTextList = 10,
	ScenarioHeaderCurrenciesAndBackground = 11,
	TextureAndText = 12,
	SpellDisplay = 13,
	DoubleStateIconRow = 14,
	TextureAndTextRow = 15,
	ZoneControl = 16,
	CaptureZone = 17,
	TextureWithAnimation = 18,
	DiscreteProgressSteps = 19,
	ScenarioHeaderTimer = 20,
	TextColumnRow = 21,
	Spacer = 22,
	UnitPowerBar = 23,
	FillUpFrames = 24,
	TextWithSubtext = 25,
	MapPinAnimation = 26,
	ItemDisplay = 27,
	TugOfWar = 28,
	ScenarioHeaderDelves = 29,
	ButtonHeader = 30,
}

---@enum Enum.UnitMirrorPetFlags
Enum.UnitMirrorPetFlags = {
	Renameable = 0x1,
	Dismissable = 0x2,
	RecentlyTamed = 0x4,
	Stampede = 0x8,
	ExtraPet = 0x10,
}

---@enum Enum.UnitSex
Enum.UnitSex = {
	Male = 0,
	Female = 1,
	None = 2,
	Both = 3,
	Neutral = 4,
}

---@enum Enum.ValidateNameResult
Enum.ValidateNameResult = {
	Success = 0,
	Failure = 1,
	NoName = 2,
	TooShort = 3,
	TooLong = 4,
	InvalidCharacter = 5,
	MixedLanguages = 6,
	Profane = 7,
	Reserved = 8,
	InvalidApostrophe = 9,
	MultipleApostrophes = 10,
	ThreeConsecutive = 11,
	InvalidSpace = 12,
	ConsecutiveSpaces = 13,
	RussianConsecutiveSilentCharacters = 14,
	RussianSilentCharacterAtBeginningOrEnd = 15,
	DeclensionDoesntMatchBaseName = 16,
	SpacesDisallowed = 17,
}

---@enum Enum.VasPurchaseProgress
Enum.VasPurchaseProgress = {
	Invalid = 0,
	PrePurchase = 1,
	PaymentPending = 2,
	ApplyingLicense = 3,
	WaitingOnQueue = 4,
	Ready = 5,
	ProcessingFactionChange = 6,
	Complete = 7,
}

---@enum Enum.ViewArenaSize
Enum.ViewArenaSize = {
	Two = 0,
	Three = 1,
}

---@enum Enum.ViewRaidSize
Enum.ViewRaidSize = {
	Ten = 0,
	TwentyFive = 1,
	Forty = 2,
}

---@enum Enum.VignetteObjectiveType
Enum.VignetteObjectiveType = {
	None = 0,
	Defeat = 1,
	DefeatShowRemainingHealth = 2,
}

---@enum Enum.VignetteType
Enum.VignetteType = {
	Normal = 0,
	PvPBounty = 1,
	Torghast = 2,
	Treasure = 3,
	FyrakkFlight = 4,
}

---@enum Enum.Vocalerrorsounds
Enum.Vocalerrorsounds = {
	Inventoryfull = 0,
	Outofammo = 1,
	NoequipLevel = 2,
	NoequipEver = 3,
	BoundNodrop = 4,
	Itemcooling = 5,
	Cantdrinkmore = 6,
	Canteatmore = 7,
	Cantinvite = 8,
	Inviteebusy = 9,
	Targettoofar = 10,
	Invalidtarget = 11,
	Spellcooling = 12,
	CantlearnLevel = 13,
	Locked = 14,
	Nomana = 15,
	Notwhiledead = 16,
	Cantloot = 17,
	Cantcreate = 18,
	Declinegroup = 19,
	Alreadyingroup = 20,
	Alreadyinguild = 21,
	Cantaffordbankslot = 22,
	Toomanybankslots = 23,
	CanteatMoving = 24,
	Notabag = 25,
	Cantputbag = 26,
	Wrongslot = 27,
	Ammoonlyinbag = 28,
	Bagfull = 29,
	Itemmaxcount = 30,
	CantlootDidntkill = 31,
	CantlootWrongfacing = 32,
	CantlootLocked = 33,
	CantlootNotstandingObsolete = 34,
	CantlootToofar = 35,
	Cantattackrongdirection = 36,
	CantattackNotstandingObsolete = 37,
	CantattackNotarget = 38,
	Notenoughgold = 39,
	Notenoughmoney = 40,
	Cantequip2HSkill = 41,
	Cantequip2Hequipped = 42,
	Cantequip2HNoskill = 43,
	Notequippable = 44,
	Genericnotarget = 45,
	CantcastOutofrange = 46,
	Potioncooling = 47,
	Proficiencyneeded = 48,
	Mustequippitem = 49,
	Abilitycooling = 50,
	Cantuseitem = 51,
	Chestinuse = 52,
	FoodcoolingObsolete = 53,
	CanttaxiNomoney = 54,
	Cantuselocked = 55,
	Noequipslotavailable = 56,
	Cantusetoofar = 57,
	Cantswap = 58,
	CanttradeSoulbound = 59,
	Cantflyhere = 60,
	Itemlocked = 61,
	Guildpermissions = 62,
	Norage = 63,
	Noenergy = 64,
	Noessence = 65,
	Invaliditemtarget = 66,
	ExhaustedObsolete = 67,
}

---@enum Enum.VoiceChannelErrorReason
Enum.VoiceChannelErrorReason = {
	Unknown = 0,
	IsBattleNetChannel = 1,
}

---@enum Enum.VoiceChatStatusCode
Enum.VoiceChatStatusCode = {
	Success = 0,
	OperationPending = 1,
	TooManyRequests = 2,
	LoginProhibited = 3,
	ClientNotInitialized = 4,
	ClientNotLoggedIn = 5,
	ClientAlreadyLoggedIn = 6,
	ChannelNameTooShort = 7,
	ChannelNameTooLong = 8,
	ChannelAlreadyExists = 9,
	AlreadyInChannel = 10,
	TargetNotFound = 11,
	Failure = 12,
	ServiceLost = 13,
	UnableToLaunchProxy = 14,
	ProxyConnectionTimeOut = 15,
	ProxyConnectionUnableToConnect = 16,
	ProxyConnectionUnexpectedDisconnect = 17,
	Disabled = 18,
	UnsupportedChatChannelType = 19,
	InvalidCommunityStream = 20,
	PlayerSilenced = 21,
	PlayerVoiceChatParentalDisabled = 22,
	InvalidInputDevice = 23,
	InvalidOutputDevice = 24,
}

---@enum Enum.VoiceTtsDestination
Enum.VoiceTtsDestination = {
	RemoteTransmission = 0,
	LocalPlayback = 1,
	RemoteTransmissionWithLocalPlayback = 2,
	QueuedRemoteTransmission = 3,
	QueuedLocalPlayback = 4,
	QueuedRemoteTransmissionWithLocalPlayback = 5,
	ScreenReader = 6,
}

---@enum Enum.VoiceTtsStatusCode
Enum.VoiceTtsStatusCode = {
	Success = 0,
	InvalidEngineType = 1,
	EngineAllocationFailed = 2,
	NotSupported = 3,
	MaxCharactersExceeded = 4,
	UtteranceBelowMinimumDuration = 5,
	InputTextEnqueued = 6,
	SdkNotInitialized = 7,
	DestinationQueueFull = 8,
	EnqueueNotNecessary = 9,
	UtteranceNotFound = 10,
	ManagerNotFound = 11,
	InvalidArgument = 12,
	InternalError = 13,
}

---@enum Enum.WarbandSceneFlags
Enum.WarbandSceneFlags = {
	DoNotInclude = 0x1,
	HiddenUntilCollected = 0x2,
	CannotBeSaved = 0x4,
	AwardedAutomatically = 0x8,
	IsDefault = 0x10,
}

---@enum Enum.WeaponSlot
Enum.WeaponSlot = {
	MainHand = 0,
	OffHand = 1,
}

---@enum Enum.WeeklyRewardChestActivityType
Enum.WeeklyRewardChestActivityType = {
	Scenario = 0,
	LFGDungeons = 1,
	World = 2,
}

---@enum Enum.WeeklyRewardChestClaimRewardResult
Enum.WeeklyRewardChestClaimRewardResult = {
	Success = 0,
	InvalidThreshold = 1,
	PlayerNotFound = 2,
	InvalidSlot = 3,
	TooManyItems = 4,
	DbError = 5,
	LockFailure = 6,
	CountExceeded = 7,
}

---@enum Enum.WeeklyRewardChestThresholdType
Enum.WeeklyRewardChestThresholdType = {
	None = 0,
	Activities = 1,
	RankedPvP = 2,
	Raid = 3,
	AlsoReceive = 4,
	Concession = 5,
	World = 6,
}

---@enum Enum.WeeklyRewardProgressResult
Enum.WeeklyRewardProgressResult = {
	Success = 0,
	NoSeason = 1,
	TimedOut = 2,
	DbError = 3,
	NoPlayer = 4,
}

---@enum Enum.WidgetAnimationType
Enum.WidgetAnimationType = {
	None = 0,
	Fade = 1,
}

---@enum Enum.WidgetCurrencyClass
Enum.WidgetCurrencyClass = {
	Currency = 0,
	Item = 1,
}

---@enum Enum.WidgetEnabledState
Enum.WidgetEnabledState = {
	Disabled = 0,
	Yellow = 1,
	Red = 2,
	White = 3,
	Green = 4,
	Artifact = 5,
	Black = 6,
	BrightBlue = 7,
}

---@enum Enum.WidgetGlowAnimType
Enum.WidgetGlowAnimType = {
	None = 0,
	Pulse = 1,
}

---@enum Enum.WidgetIconSizeType
Enum.WidgetIconSizeType = {
	Small = 0,
	Medium = 1,
	Large = 2,
	Standard = 3,
}

---@enum Enum.WidgetIconSourceType
Enum.WidgetIconSourceType = {
	Spell = 0,
	Item = 1,
}

---@enum Enum.WidgetOpacityType
Enum.WidgetOpacityType = {
	OneHundred = 0,
	Ninety = 1,
	Eighty = 2,
	Seventy = 3,
	Sixty = 4,
	Fifty = 5,
	Forty = 6,
	Thirty = 7,
	Twenty = 8,
	Ten = 9,
	Zero = 10,
}

---@enum Enum.WidgetShowGlowState
Enum.WidgetShowGlowState = {
	HideGlow = 0,
	ShowGlow = 1,
}

---@enum Enum.WidgetShownState
Enum.WidgetShownState = {
	Hidden = 0,
	Shown = 1,
}

---@enum Enum.WidgetTextHorizontalAlignmentType
Enum.WidgetTextHorizontalAlignmentType = {
	Left = 0,
	Center = 1,
	Right = 2,
}

---@enum Enum.WidgetUnitPowerBarFlashMomentType
Enum.WidgetUnitPowerBarFlashMomentType = {
	FlashWhenMax = 0,
	FlashWhenMin = 1,
	NeverFlash = 2,
}

---@enum Enum.WoWEntitlementType
Enum.WoWEntitlementType = {
	Item = 0,
	Mount = 1,
	Battlepet = 2,
	Toy = 3,
	Appearance = 4,
	AppearanceSet = 5,
	GameTime = 6,
	Title = 7,
	Illusion = 8,
	Invalid = 9,
}

---@enum Enum.WoWLabsAreaType
Enum.WoWLabsAreaType = {
	PlunderstormDropSparse = 0,
	PlunderstormDropMedium = 1,
	PlunderstormDropDense = 2,
}

---@enum Enum.WorldCursorAnchorType
Enum.WorldCursorAnchorType = {
	None = 0,
	Default = 1,
	Cursor = 2,
	Nameplate = 3,
}

---@enum Enum.WorldQuestQuality
Enum.WorldQuestQuality = {
	Common = 0,
	Rare = 1,
	Epic = 2,
}

---@enum Enum.ZoneControlActiveState
Enum.ZoneControlActiveState = {
	Inactive = 0,
	Active = 1,
}

---@enum Enum.ZoneControlDangerFlashType
Enum.ZoneControlDangerFlashType = {
	ShowOnGoodStates = 0,
	ShowOnBadStates = 1,
	ShowOnBoth = 2,
	ShowOnNeither = 3,
}

---@enum Enum.ZoneControlFillType
Enum.ZoneControlFillType = {
	SingleFillClockwise = 0,
	SingleFillCounterClockwise = 1,
	DoubleFillClockwise = 2,
	DoubleFillCounterClockwise = 3,
}

---@enum Enum.ZoneControlLeadingEdgeType
Enum.ZoneControlLeadingEdgeType = {
	NoLeadingEdge = 0,
	UseLeadingEdge = 1,
}

---@enum Enum.ZoneControlMode
Enum.ZoneControlMode = {
	BothStatesAreGood = 0,
	State1IsGood = 1,
	State2IsGood = 2,
	NeitherStateIsGood = 3,
}

---@enum Enum.ZoneControlState
Enum.ZoneControlState = {
	State1 = 0,
	State2 = 1,
}

Constants = {
	AccountStoreConsts = {
		PlunderstormStoreFrontID = 1,
		PlunderstormPlunderCurrencyID = 3139,
	},
	AuctionConstants = {
		DEFAULT_AUCTION_PRICE_MULTIPLIER = 1.5,
	},
	CalendarGetEventTypeConstants = {
		DEFAULT_CALENDAR_GET_EVENT_TYPE = 0,
	},
	Callings = {
		MaxCallings = 3,
	},
	CharCustomizationConstants = {
		NUM_CUSTOM_DISPLAY = 4,
		CHAR_CUSTOMIZE_CUSTOM_DISPLAY_OPTION_FIRST = 5,
		CHAR_CUSTOMIZE_CUSTOM_DISPLAY_OPTION_LAST = 8,
		NAME_RESERVATION_DAYS = 30,
	},
	ContentTrackingConsts = {
		MaxTrackedAchievements = 10,
		MaxTrackedCollectableSources = 15,
	},
	CooldownViewerUIConstants = {
		COOLDOWN_VIEWER_LINKED_SPELLS_SIZE = 4,
		COOLDOWN_VIEWER_CATEGORY_SET_SIZE = 16,
	},
	CraftingOrderConsts = {
		NPC_CRAFTING_ORDER_NUM_SUPPORTED_REWARDS = 2,
		MAX_CRAFTING_ORDER_FAVORITE_RECIPES = 100,
	},
	CurrencyConsts = {
		HONOR_PER_CURRENCY = 10,
		PLAYER_CURRENCY_CLIENT_FLAGS = 12,
		CLASSIC_CONQUEST_CURRENCY_ID = 390,
		CONQUEST_POINTS_CURRENCY_ID = 390,
		CONQUEST_ARENA_AND_BG_META_CURRENCY_ID = 483,
		CONQUEST_ARENA_META_CURRENCY_ID = 483,
		CONQUEST_BG_META_CURRENCY_ID = 484,
		CONQUEST_RATED_BG_META_CURRENCY_ID = 484,
		CONQUEST_ASHRAN_META_CURRENCY_ID = 692,
		ARTIFACT_KNOWLEDGE_CURRENCY_ID = 1171,
		WAR_RESOURCES_CURRENCY_ID = 1560,
		ACCOUNT_WIDE_HONOR_CURRENCY_ID = 1585,
		ACCOUNT_WIDE_HONOR_LEVEL_CURRENCY_ID = 1586,
		CONQUEST_CURRENCY_ID = 1602,
		HONOR_CURRENCY_ID = 1792,
		ECHOES_OF_NYALOTHA_CURRENCY_ID = 1803,
		CURRENCY_ID_WILLING_SOUL = 1810,
		CURRENCY_ID_RESERVOIR_ANIMA = 1813,
		CURRENCY_ID_RENOWN = 1822,
		CURRENCY_ID_RENOWN_KYRIAN = 1829,
		CURRENCY_ID_RENOWN_VENTHYR = 1830,
		CURRENCY_ID_RENOWN_NIGHT_FAE = 1831,
		CURRENCY_ID_RENOWN_NECROLORD = 1832,
		CLASSIC_ARENA_POINTS_CURRENCY_ID = 1900,
		CLASSIC_HONOR_CURRENCY_ID = 1901,
		DRAGON_ISLES_SUPPLIES_CURRENCY_ID = 2003,
		CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO = 2032,
		QUESTIONMARK_INV_ICON = 134400,
		PVP_CURRENCY_CONQUEST_ALLIANCE_INV_ICON = 463448,
		PVP_CURRENCY_CONQUEST_HORDE_INV_ICON = 463449,
		PVP_CURRENCY_HONOR_ALLIANCE_INV_ICON = 463450,
		PVP_CURRENCY_HONOR_HORDE_INV_ICON = 463451,
		MAX_CURRENCY_QUANTITY = 100000000,
	},
	DelvesConsts = {
		DELVES_COMPANION_INFO_SELECTION_CHARACTER_DATA_ELEMENT_ID = 13,
		DELVES_COMPANION_TOOLTIP_WIDGET_SET_ID = 1331,
		DELVES_MIN_PLAYER_LEVEL_CONTENT_TUNING_ID = 2677,
		DELVES_NORMAL_KEY_CURRENCY_ID = 3028,
	},
	EditModeConsts = {
		EditModeMaxLayoutsPerType = 5,
		EditModeMinGridSpacing = 20,
		EditModeDefaultGridSpacing = 100,
		EditModeMaxGridSpacing = 300,
	},
	EncodingLimits = {
		EncodingStackSizeLimit = 100,
		EncodingDecompressSizeLimit = 104857600,
	},
	EventScheduler = {
		SCHEDULED_EVENT_REMINDER_DEAD_SECONDS = 10,
		SCHEDULED_EVENT_FUTURE_LIMIT = 12,
		SCHEDULED_EVENT_REMINDER_WARNING_SECONDS = 300,
		SCHEDULED_EVENT_PAST_LIMIT_SECONDS = 3600,
	},
	ITEM_WEAPON_SUBCLASSConstants = {
		ITEM_WEAPON_SUBCLASS_NONE = -1,
	},
	InventoryConstants = {
		NumReagentBagSlots = 1,
		NumBagSlots = 4,
		NumAccountBankSlots = 5,
		MAX_TRANSACTION_BANK_TABS = 6,
		NumCharacterBankSlots = 6,
	},
	ItemConsts = {
		CURRENT_ARTIFACT_POWERS_VERSION = 1,
		DEFAULT_ARTIFACT_POWERS_VERSION = 1,
		CURRENT_ITEM_SAVE_VERSION = 2,
		DEFAULT_ITEM_SAVE_VERSION = 2,
		NUM_ITEM_ENCHANTMENT_SOCKETS = 3,
		DEFAULT_RETENTION = 7,
		MAX_LOOT_OBJECT_ITEMS = 31,
		INVALID_TRANSACTION_BANK_TAB_SLOT = 255,
	},
	LFGConstsExposed = {
		GROUP_FINDER_MAX_ACTIVITY_CAPACITY = 16,
	},
	LFG_ROLEConstants = {
		LFG_ROLE_NO_ROLE = -1,
		LFG_ROLE_ANY = 3,
	},
	LevelConstsExposed = {
		MIN_ACHIEVEMENT_LEVEL = 10,
		MIN_RES_SICKNESS_LEVEL = 10,
	},
	LootConsts = {
		MasterLootQualityThreshold = 5,
	},
	MajorFactionsConsts = {
		PLUNDERSTORM_MAJOR_FACTION_ID = 2593,
		WORLD_STATE_RENOWN_CAP_10_0 = 19735,
		WORLD_STATE_RAPID_RENOWN_CAP_10_0 = 20851,
	},
	MoneyFormattingConstants = {
		GOLD_REWARD_THRESHOLD_TO_HIDE_COPPER = 10,
	},
	MountDynamicFlightConsts = {
		TRAIT_SYSTEM_ID = 1,
		TREE_ID = 672,
	},
	PetConsts = {
		PETNUMBER_INVALIDSLOT = -1,
		PETNUMBER_PENDINGPET = -1,
		PETNUMBER_INVALIDPET = 0,
		MAX_SUMMONABLE_PETS = 25,
	},
	PetConsts_PostCata = {
		NUM_PET_SLOTS_DEATHKNIGHT = 1,
		NUM_PET_SLOTS_MAGE = 1,
		EXTRA_PET_STABLE_SLOT = 5,
		MAX_SUMMONABLE_HUNTER_PETS = 5,
		NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL = 5,
		STABLED_PETS_FIRST_SLOT_INDEX = 5,
		NUM_PET_SLOTS_WARLOCK = 25,
		MAX_STABLE_SLOTS = 200,
		MAX_NUM_PET_SLOTS = 205,
		NUM_PET_SLOTS_HUNTER = 205,
	},
	PetConsts_PreWrath = {
		EXTRA_PET_STABLE_SLOT = -1,
		NUM_PET_SLOTS_DEATHKNIGHT = 0,
		NUM_PET_SLOTS_MAGE = 1,
		NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL = 1,
		MAX_STABLE_SLOTS = 2,
		MAX_SUMMONABLE_HUNTER_PETS = 5,
		STABLED_PETS_FIRST_SLOT_INDEX = 5,
		MAX_NUM_PET_SLOTS = 25,
		NUM_PET_SLOTS_WARLOCK = 25,
		NUM_PET_SLOTS_HUNTER = 205,
	},
	PetConsts_Wrath = {
		EXTRA_PET_STABLE_SLOT = -1,
		NUM_PET_SLOTS_DEATHKNIGHT = 1,
		NUM_PET_SLOTS_MAGE = 1,
		NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL = 1,
		MAX_STABLE_SLOTS = 4,
		MAX_SUMMONABLE_HUNTER_PETS = 5,
		STABLED_PETS_FIRST_SLOT_INDEX = 5,
		MAX_NUM_PET_SLOTS = 25,
		NUM_PET_SLOTS_WARLOCK = 25,
		NUM_PET_SLOTS_HUNTER = 205,
	},
	ProfessionConsts = {
		NUM_PRIMARY_PROFESSIONS = 2,
		CLASSIC_PROFESSION_PARENT_TIER_INDEX = 4,
		MAX_CRAFTING_REAGENT_SLOTS = 12,
		CRAFTING_ORDER_ITEM_RETENTION = 30,
		RUNEFORGING_ROOT_CATEGORY_ID = 210,
		RUNEFORGING_SKILL_LINE_ID = 960,
		CRAFTING_ORDER_CLAIM_DURATION = 1800,
		PUBLIC_CRAFTING_ORDER_STALE_THRESHOLD = 14400,
	},
	PvpInfoConsts = {
		MAX_PVP_LOCK_LIST_MAP = 2,
		MaxPlayersPerInstance = 80,
	},
	QuestWatchConsts = {
		MAX_WORLD_QUEST_WATCHES_AUTOMATIC = 1,
		MAX_WORLD_QUEST_WATCHES_MANUAL = 5,
		MAX_QUEST_WATCHES = 25,
	},
	SpellBookSpellIDs = {
		SPELL_ID_DISMISS_PET = 2641,
	},
	SpellCooldownConsts = {
		GLOBAL_RECOVERY_CATEGORY = 133,
	},
	TimerunningConsts = {
		TIMERUNNING_SEASON_NONE = 0,
		TIMERUNNING_SEASON_PANDARIA = 1,
		TIMERUNNING_ITEM_CTR = 2905,
		TIMERUNNING_STARTLOC_ID_ALLIANCE = 10211,
		TIMERUNNING_STARTLOC_ID_HORDE = 10212,
	},
	TraitConsts = {
		VIEW_TRAIT_CONFIG_ID = -3,
		STARTER_BUILD_TRAIT_CONFIG_ID = -2,
		INSPECT_TRAIT_CONFIG_ID = -1,
		MAX_COMBAT_TRAIT_CONFIGS = 40,
		COMMIT_COMBAT_TRAIT_CONFIG_CHANGES_SPELL_ID = 384255,
	},
	Transmog = {
		MainHandTransmogIsIndividualWeapon = -1,
		MainHandTransmogIsPairedWeapon = 0,
		NoTransmogID = 0,
	},
	WeeklyRewardsConsts = {
		ABORT_ITEM_RETENTION_DAYS = 15,
		WEEKLY_REWARD_ITEM_RETENTION_DAYS = 15,
	},
}
