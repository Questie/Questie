# Classic API availability reference

Programmatic extraction of the user's saved Warcraft Wiki comparison. Use this as a searchable **availability snapshot**, not a runtime compatibility contract. All 7,362 API rows are retained; the single source table is regrouped alphabetically into global functions and namespaces for lookup.

## Source and provenance

- Source: [World of Warcraft API/Classic](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API/Classic), Warcraft Wiki contributors.
- Saved page revision: [6802278](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API/Classic?oldid=6802278).
- Saved footer: "This page was last edited on 10 August 2026, at 08:00."
- Local input: `C:\Users\Logon\Downloads\World of Warcraft API_Classic - Warcraft Wiki - Your wiki guide to the World of Warcraft.htm`.
- WSL input: `/mnt/c/Users/Logon/Downloads/World of Warcraft API_Classic - Warcraft Wiki - Your wiki guide to the World of Warcraft.htm`.
- Input size: 3,036,792 bytes. SHA-256: `2fc51a182b065c3eedbd9207e5c66dc83ea72f767748285363f4fb2b90b451f3`.
- Local file modification time: `2026-09-20T03:18:02.786988+00:00`. This is a filesystem timestamp, **not** a verified download time or the Wiki publication date.
- Source page content is licensed [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0). This extracted and reformatted reference retains that attribution and license. The saved footer notes that pages created before October 2023 may be adapted from the Fandom Wowpedia Wiki.

No network refresh or live API probe was performed for this extraction.

## Column definitions and legend

The source introduction explicitly states these comparison versions. Header images and each checkmark's `gametype-*` class establish the same left-to-right ordering:

| Column | Client in this snapshot | Version | Build | Source marker class |
| --- | --- | --- | --- | --- |
| Era | Classic Era | 1.15.9 | 69109 | `gametype-classic_era` |
| Anniversary | Burning Crusade Classic Anniversary | 2.5.6 | 69110 | `gametype-classic_anniversary` |
| Classic | Mists of Pandaria Classic, the progression Classic channel | 5.5.4 | 69155 | `gametype-classic` |
| Retail | World of Warcraft: Midnight | 12.1.0 | 69189 | `gametype-mainline` |

- `Y`: the saved cell contains a checkmark (`✔`) for that client.
- `-`: the saved cell is **blank**, meaning availability is not marked in this comparison. This preserves the source distinction; it is not an independently verified absence or an explicit "unavailable" marker.
- No explicit negative, uncertain, or additional availability markers occurred in the source cells. There are only checkmarks and blanks.
- An API absent from this reference has **no source row**. That is distinct from a listed API with a blank client cell.
- **Forever has no column.** Retail's checkmark does not establish Forever support, despite their shared project ID.

`Wiki` describes the function's documentation link, not API availability:

- `page`: source links to a Wiki API page.
- `redirect`: source link has the `mw-redirect` class; its destination was not followed.
- `missing`: source renders `redlink-removed` with a "page does not exist" title. This means a missing Wiki page, **not** a removed API. Availability checkmarks are retained independently.

To keep thousands of rows compact, predictable per-function URLs are not repeated. For every `page` or `redirect` row, the source destination is exactly `https://warcraft.wiki.gg/wiki/API:` followed by the API name, after URL decoding. For example: [C_Item.GetItemInfo](https://warcraft.wiki.gg/wiki/API:C_Item.GetItemInfo). The API name and `Wiki` column therefore preserve each link destination and status. `missing` rows had no source hyperlink.

## Compatibility-audit interpretation

The comparison lists symbols, not argument or return contracts, restricted/secret-value behavior, hardware requirements, or guarantees about older supported builds. A checkmark is useful evidence against assuming that every namespaced API is Retail-only, but does not establish that two implementations behave identically.

Before removing a fallback, check Questie's supported client/build floor and the actual wrapper contract. Establish Forever-specific behavior separately. An API can exist yet fail internally in a particular client or context. This extraction does not approve or remove any production fallback.

### Requested item API checks

| API | Era | Anniversary | Classic | Retail | Source result |
| --- | --- | --- | --- | --- | --- |
| `C_Item.GetItemInfo` | Y | Y | Y | Y | Listed with a normal Wiki link |
| `C_Item.GetItemIconByID` | Y | Y | Y | Y | Listed with a normal Wiki link |
| `C_Item.GetItemIcon` | Y | Y | Y | Y | Listed with a normal Wiki link |
| `GetItemInfo` | n/a | n/a | n/a | n/a | No exact source row |
| `GetItemIcon` | n/a | n/a | n/a | n/a | No exact source row |

For the three namespaced APIs, all four checkmarks are present in the saved HTML. The missing rows for the two globals do not prove that legacy aliases are absent in-game.

## Extraction validation

- One API comparison table; 7,363 source rows: one five-column header and 7,362 five-column API rows.
- 7,362 distinct API names; no duplicate names, collapsed variants, or dropped data rows.
- 22,599 checkmarks and 6,849 blank client cells preserved.
- Wiki status: 6,081 normal links, 2 redirect-class links, and 1,279 missing-page spans.
- All marker values/classes, row widths, API name shapes, and link patterns were checked. Unexpected shapes cause extraction failure rather than silently being discarded.
- Generated API tables are round-tripped and compared against all parsed source rows, including every client marker and Wiki status.

The source does not subdivide its table into namespaces. The following grouping and alphabetical order are editorial; API spelling, marker state, and link status are preserved.

## API inventory

### Global functions

2,429 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `AbandonQuest` | Y | Y | Y | - | page |
| `AbandonSkill` | Y | Y | Y | Y | page |
| `AbbreviateLargeNumbers` | Y | Y | Y | Y | page |
| `AbbreviateNumbers` | Y | Y | Y | Y | page |
| `abs` | Y | Y | Y | Y | redirect |
| `AcceptAreaSpiritHeal` | Y | Y | Y | Y | page |
| `AcceptArenaTeam` | Y | Y | Y | - | page |
| `AcceptBattlefieldPort` | Y | Y | Y | Y | page |
| `AcceptDuel` | Y | Y | Y | Y | page |
| `AcceptGroup` | Y | Y | Y | Y | page |
| `AcceptGuild` | Y | Y | Y | Y | page |
| `AcceptProposal` | Y | Y | Y | Y | page |
| `AcceptQuest` | Y | Y | Y | Y | page |
| `AcceptResurrect` | Y | Y | Y | Y | page |
| `AcceptSpellConfirmationPrompt` | Y | Y | Y | Y | page |
| `AcceptTrade` | Y | Y | Y | Y | page |
| `AcknowledgeAutoAcceptQuest` | - | - | - | Y | page |
| `AcknowledgeSurvey` | Y | Y | Y | Y | missing |
| `acos` | Y | Y | Y | Y | missing |
| `AddAutoQuestPopUp` | Y | Y | Y | Y | page |
| `AddChatWindowChannel` | Y | Y | Y | Y | page |
| `AddChatWindowMessages` | Y | Y | Y | Y | page |
| `addframetext` | Y | Y | Y | Y | page |
| `AddPreviewTalentPoints` | Y | Y | Y | - | missing |
| `AddQuestWatch` | Y | Y | Y | - | page |
| `AddSourceLocationExclude` | Y | Y | Y | Y | page |
| `AddTrackedAchievement` | Y | Y | Y | - | page |
| `Ambiguate` | Y | Y | Y | Y | page |
| `AntiAliasingSupported` | Y | Y | Y | Y | missing |
| `ArchaeologyGetIconInfo` | - | - | Y | Y | page |
| `ArchaeologyMapUpdateAll` | - | - | Y | Y | page |
| `ArcheologyGetVisibleBlobID` | - | - | Y | Y | page |
| `AreClassRolesSoftSuggestions` | Y | Y | Y | Y | page |
| `AreDangerousScriptsAllowed` | Y | Y | Y | Y | page |
| `AreHighResTexturesAvailable` | Y | Y | Y | - | missing |
| `ArenaTeamDisband` | Y | Y | Y | - | page |
| `ArenaTeamInviteByName` | Y | Y | Y | - | page |
| `ArenaTeamLeave` | Y | Y | Y | - | page |
| `ArenaTeamRoster` | Y | Y | Y | - | page |
| `ArenaTeamSetLeaderByName` | Y | Y | Y | - | page |
| `ArenaTeamUninviteByName` | Y | Y | Y | - | page |
| `AreTalentsLocked` | - | - | - | Y | missing |
| `AscendStop` | Y | Y | Y | Y | page |
| `asin` | Y | Y | Y | Y | missing |
| `assert` | Y | Y | Y | Y | missing |
| `AssistUnit` | Y | Y | Y | Y | page |
| `atan` | Y | Y | Y | Y | missing |
| `atan2` | Y | Y | Y | Y | missing |
| `AttachGlyphToSpell` | - | - | - | Y | missing |
| `AttackTarget` | Y | Y | Y | Y | page |
| `AutoChooseCurrentGraphicsSetting` | Y | Y | Y | Y | missing |
| `AutoEquipCursorItem` | Y | Y | Y | Y | page |
| `AutoLootMailItem` | Y | Y | Y | Y | missing |
| `AutoStoreGuildBankItem` | Y | Y | Y | Y | page |
| `BankButtonIDToInvSlotID` | Y | Y | Y | - | page |
| `BattlefieldMgrEntryInviteResponse` | - | - | - | Y | missing |
| `BattlefieldMgrExitRequest` | - | - | - | Y | missing |
| `BattlefieldMgrQueueInviteResponse` | - | - | - | Y | missing |
| `BattlefieldMgrQueueRequest` | - | - | - | Y | missing |
| `BeginTrade` | Y | Y | Y | Y | page |
| `BNAcceptFriendInvite` | Y | Y | Y | Y | missing |
| `BNCheckBattleTagInviteToGuildMember` | Y | Y | Y | Y | missing |
| `BNCheckBattleTagInviteToUnit` | Y | Y | Y | Y | missing |
| `BNConnected` | Y | Y | Y | Y | page |
| `BNDeclineFriendInvite` | Y | Y | Y | Y | missing |
| `BNFeaturesEnabled` | Y | Y | Y | Y | missing |
| `BNFeaturesEnabledAndConnected` | Y | Y | Y | Y | missing |
| `BNGetBlockedInfo` | Y | Y | Y | Y | missing |
| `BNGetDisplayName` | Y | Y | Y | Y | missing |
| `BNGetFOFInfo` | Y | Y | Y | Y | page |
| `BNGetFriendGameAccountInfo` | Y | Y | Y | - | page |
| `BNGetFriendIndex` | Y | Y | Y | Y | page |
| `BNGetFriendInfo` | Y | Y | Y | - | page |
| `BNGetFriendInfoByID` | Y | Y | Y | - | missing |
| `BNGetFriendInviteInfo` | Y | Y | Y | - | page |
| `BNGetGameAccountInfo` | Y | Y | Y | - | missing |
| `BNGetGameAccountInfoByGUID` | Y | Y | Y | - | missing |
| `BNGetInfo` | Y | Y | Y | Y | page |
| `BNGetNumBlocked` | Y | Y | Y | Y | missing |
| `BNGetNumFOF` | Y | Y | Y | Y | missing |
| `BNGetNumFriendGameAccounts` | Y | Y | Y | - | page |
| `BNGetNumFriendInvites` | Y | Y | Y | Y | missing |
| `BNGetNumFriends` | Y | Y | Y | Y | page |
| `BNGetSelectedBlock` | Y | Y | Y | Y | missing |
| `BNGetSelectedFriend` | Y | Y | Y | Y | missing |
| `BNIsBlocked` | Y | Y | Y | Y | missing |
| `BNIsFriend` | Y | Y | Y | Y | missing |
| `BNIsSelf` | Y | Y | Y | Y | missing |
| `BNRemoveFriend` | Y | Y | Y | Y | missing |
| `BNRequestFOFInfo` | Y | Y | Y | Y | missing |
| `BNRequestInviteFriend` | Y | Y | Y | Y | missing |
| `BNSendFriendInvite` | Y | Y | Y | Y | missing |
| `BNSendFriendInviteByID` | Y | Y | Y | Y | missing |
| `BNSendVerifiedBattleTagInvite` | Y | Y | Y | - | page |
| `BNSetBlocked` | Y | Y | Y | Y | missing |
| `BNSetFriendFavoriteFlag` | Y | Y | Y | Y | page |
| `BNSetFriendNote` | Y | Y | Y | Y | page |
| `BNSetSelectedBlock` | Y | Y | Y | Y | missing |
| `BNSetSelectedFriend` | Y | Y | Y | Y | missing |
| `BNSummonFriendByIndex` | Y | Y | Y | Y | missing |
| `BNTokenFindName` | Y | Y | Y | Y | missing |
| `BreakUpLargeNumbers` | Y | Y | Y | Y | page |
| `BuyArenaCharter` | Y | Y | Y | - | missing |
| `BuybackItem` | Y | Y | Y | Y | page |
| `BuyGuildBankTab` | Y | Y | Y | Y | missing |
| `BuyGuildCharter` | Y | Y | Y | Y | page |
| `BuyMerchantItem` | Y | Y | Y | Y | page |
| `BuyStableSlot` | Y | Y | Y | - | page |
| `BuyTrainerService` | Y | Y | Y | Y | page |
| `CalculateAuctionDeposit` | Y | Y | Y | - | missing |
| `CalculateStringEditDistance` | Y | Y | Y | Y | page |
| `CallCompanion` | Y | Y | Y | Y | page |
| `CameraOrSelectOrMoveStart` | Y | Y | Y | Y | page |
| `CameraOrSelectOrMoveStop` | Y | Y | Y | Y | page |
| `CameraZoomIn` | Y | Y | Y | Y | page |
| `CameraZoomOut` | Y | Y | Y | Y | page |
| `CanAbandonQuest` | Y | Y | Y | - | page |
| `canaccessallvalues` | Y | Y | Y | Y | page |
| `canaccesssecrets` | Y | Y | Y | Y | page |
| `canaccesstable` | Y | Y | Y | Y | page |
| `canaccessvalue` | Y | Y | Y | Y | page |
| `CanAffordMerchantItem` | Y | Y | Y | Y | missing |
| `CanAutoSetGamePadCursorControl` | Y | Y | Y | Y | missing |
| `CanBeRaidTarget` | Y | Y | Y | Y | page |
| `CanCancelAuction` | Y | Y | Y | - | missing |
| `CanCancelScene` | Y | Y | Y | Y | page |
| `CancelAreaSpiritHeal` | Y | Y | Y | Y | page |
| `CancelAuction` | Y | Y | Y | - | missing |
| `CancelDuel` | Y | Y | Y | Y | page |
| `CancelItemTempEnchantment` | Y | Y | Y | - | page |
| `CancelLogout` | Y | Y | Y | Y | page |
| `CancelMasterLootRoll` | - | - | - | Y | missing |
| `CancelPendingEquip` | Y | Y | Y | Y | page |
| `CancelPetPossess` | Y | Y | Y | Y | missing |
| `CancelPreloadingMovie` | Y | Y | Y | Y | page |
| `CancelScene` | Y | Y | Y | Y | page |
| `CancelSell` | Y | Y | Y | - | page |
| `CancelShapeshiftForm` | Y | Y | Y | Y | page |
| `CancelSpellByName` | Y | Y | Y | Y | missing |
| `CancelTrackingBuff` | Y | Y | Y | - | page |
| `CancelTrade` | Y | Y | Y | Y | page |
| `CancelTradeAccept` | Y | Y | Y | Y | missing |
| `CancelUnitBuff` | Y | Y | Y | Y | page |
| `CanChangePlayerDifficulty` | Y | Y | Y | Y | page |
| `CanComplainInboxItem` | Y | Y | Y | Y | page |
| `CanDualWield` | Y | Y | Y | Y | page |
| `CanEditGuildBankTabInfo` | Y | Y | Y | Y | missing |
| `CanEditGuildEvent` | Y | Y | Y | Y | missing |
| `CanEditGuildInfo` | Y | Y | Y | Y | missing |
| `CanEditGuildTabInfo` | Y | Y | Y | Y | missing |
| `CanEditMOTD` | Y | Y | Y | Y | page |
| `CanEditPublicNote` | Y | Y | Y | Y | missing |
| `CanEjectPassengerFromSeat` | Y | Y | Y | Y | page |
| `CanExitVehicle` | Y | Y | Y | Y | missing |
| `CanGamePadControlCursor` | Y | Y | Y | Y | missing |
| `CanGuildBankRepair` | Y | Y | Y | Y | missing |
| `CanGuildDemote` | Y | Y | Y | Y | page |
| `CanGuildInvite` | Y | Y | Y | Y | page |
| `CanGuildPromote` | Y | Y | Y | Y | page |
| `CanGuildRemove` | Y | Y | Y | Y | missing |
| `CanHearthAndResurrectFromArea` | Y | Y | Y | Y | missing |
| `CanInitiateWarGame` | Y | Y | Y | Y | missing |
| `CanInspect` | Y | Y | Y | Y | page |
| `CanItemBeSocketedToArtifact` | - | - | Y | Y | page |
| `CanJoinBattlefieldAsGroup` | Y | Y | Y | Y | page |
| `CanLootUnit` | Y | Y | Y | Y | page |
| `CanMapChangeDifficulty` | Y | Y | Y | Y | page |
| `CanMerchantRepair` | Y | Y | Y | Y | page |
| `CannotBeResurrected` | Y | Y | Y | Y | missing |
| `CanPartyLFGBackfill` | Y | Y | Y | Y | missing |
| `CanReplaceGuildMaster` | Y | Y | Y | Y | page |
| `CanResetTutorials` | Y | Y | Y | Y | missing |
| `CanScanResearchSite` | - | - | Y | Y | page |
| `CanSendAuctionQuery` | Y | Y | Y | - | page |
| `CanShowAchievementUI` | Y | Y | Y | Y | page |
| `CanShowResetInstances` | Y | Y | Y | Y | page |
| `CanShowSetRoleButton` | Y | Y | Y | Y | page |
| `CanSignPetition` | Y | Y | Y | Y | missing |
| `CanSolveArtifact` | - | - | Y | Y | page |
| `CanSwitchVehicleSeat` | Y | Y | Y | Y | page |
| `CanSwitchVehicleSeats` | - | - | Y | Y | page |
| `CanUpgradeToCurrentExpansion` | Y | Y | Y | Y | page |
| `CanViewGuildRecipes` | Y | Y | Y | Y | page |
| `CanWithdrawGuildBankMoney` | Y | Y | Y | Y | missing |
| `CaseAccentInsensitiveParse` | Y | Y | Y | Y | page |
| `CastGlyph` | - | - | Y | - | page |
| `CastGlyphByID` | - | - | Y | - | page |
| `CastGlyphByName` | - | - | Y | - | page |
| `CastPetAction` | Y | Y | Y | Y | page |
| `CastShapeshiftForm` | Y | Y | Y | Y | page |
| `CastSpell` | Y | Y | Y | Y | page |
| `CastSpellByID` | Y | Y | Y | Y | missing |
| `CastSpellByName` | Y | Y | Y | Y | page |
| `ceil` | Y | Y | Y | Y | missing |
| `CenterCamera` | Y | Y | Y | Y | missing |
| `ChangeChatColor` | Y | Y | Y | Y | page |
| `ChannelBan` | Y | Y | Y | Y | page |
| `ChannelInvite` | Y | Y | Y | Y | page |
| `ChannelKick` | Y | Y | Y | Y | page |
| `ChannelModerator` | Y | Y | Y | Y | page |
| `ChannelSetAllSilent` | Y | Y | Y | Y | missing |
| `ChannelSetPartyMemberSilent` | Y | Y | Y | Y | missing |
| `ChannelToggleAnnouncements` | Y | Y | Y | Y | page |
| `ChannelUnban` | Y | Y | Y | Y | page |
| `ChannelUnmoderator` | Y | Y | Y | Y | page |
| `CheckInbox` | Y | Y | Y | Y | page |
| `CheckInteractDistance` | Y | Y | Y | Y | page |
| `CheckTalentMasterDist` | Y | Y | Y | Y | page |
| `CinematicFinished` | Y | Y | Y | Y | page |
| `CinematicStarted` | Y | Y | Y | Y | page |
| `ClassicExpansionAtLeast` | Y | Y | Y | Y | page |
| `ClassicExpansionAtMost` | Y | Y | Y | Y | page |
| `ClearAchievementComparisonUnit` | Y | Y | Y | Y | missing |
| `ClearAchievementSearchString` | Y | Y | Y | Y | missing |
| `ClearAllLFGDungeons` | Y | Y | Y | Y | missing |
| `ClearAutoAcceptQuestSound` | - | - | - | Y | missing |
| `ClearBattlemaster` | Y | Y | Y | Y | missing |
| `ClearCursor` | Y | Y | Y | Y | page |
| `ClearCursorHoveredItem` | - | - | - | Y | page |
| `ClearFailedPVPTalentIDs` | - | - | - | Y | missing |
| `ClearFailedTalentIDs` | - | - | - | Y | missing |
| `ClearFocus` | Y | Y | Y | Y | page |
| `ClearInspectPlayer` | Y | Y | Y | Y | missing |
| `ClearOutage` | Y | Y | Y | Y | page |
| `ClearOverrideBindings` | Y | Y | Y | Y | page |
| `ClearPartyAssignment` | Y | Y | Y | Y | missing |
| `ClearPendingBindConversionItem` | - | - | - | Y | page |
| `ClearRaidMarker` | Y | Y | Y | Y | page |
| `ClearSendMail` | Y | Y | Y | Y | page |
| `ClearTarget` | Y | Y | Y | Y | page |
| `ClearTutorials` | Y | Y | Y | Y | missing |
| `ClickAuctionSellItemButton` | Y | Y | Y | - | page |
| `ClickSendMailItemButton` | Y | Y | Y | Y | page |
| `ClickStablePet` | Y | Y | Y | - | page |
| `ClickTargetTradeButton` | Y | Y | Y | Y | missing |
| `ClickTradeButton` | Y | Y | Y | Y | missing |
| `ClickWorldMapActionButton` | - | - | - | Y | missing |
| `CloseArenaTeamRoster` | Y | Y | Y | - | missing |
| `CloseAuctionHouse` | Y | Y | Y | - | page |
| `CloseBankFrame` | Y | Y | Y | - | page |
| `CloseCraft` | Y | Y | Y | - | missing |
| `CloseGuildBankFrame` | Y | Y | Y | Y | missing |
| `CloseGuildRegistrar` | - | - | - | Y | missing |
| `CloseGuildRoster` | Y | Y | Y | Y | missing |
| `CloseItemText` | Y | Y | Y | Y | page |
| `CloseLoot` | Y | Y | Y | Y | page |
| `CloseMail` | Y | Y | Y | Y | page |
| `CloseMerchant` | Y | Y | Y | Y | page |
| `ClosePetition` | Y | Y | Y | Y | page |
| `ClosePetitionRegistrar` | Y | Y | Y | - | missing |
| `ClosePetStables` | Y | Y | Y | - | page |
| `CloseQuest` | Y | Y | Y | Y | missing |
| `CloseResearch` | - | - | Y | Y | page |
| `ClosestGameObjectPosition` | Y | Y | Y | Y | page |
| `ClosestUnitPosition` | Y | Y | Y | Y | page |
| `CloseTabardCreation` | Y | Y | Y | Y | missing |
| `CloseTaxiMap` | Y | Y | Y | Y | page |
| `CloseTrade` | Y | Y | Y | Y | page |
| `CloseTradeSkill` | Y | Y | Y | - | page |
| `CloseTrainer` | Y | Y | Y | Y | page |
| `CollapseAllFactionHeaders` | Y | Y | Y | - | missing |
| `CollapseCraftSkillLine` | Y | Y | Y | - | missing |
| `CollapseFactionHeader` | Y | Y | Y | - | page |
| `CollapseGuildTradeSkillHeader` | Y | Y | Y | Y | missing |
| `CollapseQuestHeader` | Y | Y | Y | Y | page |
| `CollapseSkillHeader` | Y | Y | Y | - | page |
| `CollapseTradeSkillSubClass` | Y | Y | Y | - | missing |
| `CollapseTrainerSkillLine` | Y | Y | Y | - | page |
| `CollapseWarGameHeader` | Y | Y | Y | Y | missing |
| `collectgarbage` | Y | Y | Y | Y | page |
| `CompleteLFGReadyCheck` | Y | Y | Y | Y | missing |
| `CompleteLFGRoleCheck` | Y | Y | Y | Y | missing |
| `CompleteQuest` | Y | Y | Y | Y | page |
| `ConfirmAcceptQuest` | Y | Y | Y | Y | page |
| `ConfirmBarbersChoice` | Y | Y | Y | - | page |
| `ConfirmBinder` | Y | Y | Y | - | page |
| `ConfirmBNRequestInviteFriend` | Y | Y | Y | Y | page |
| `ConfirmLootRoll` | Y | Y | Y | Y | page |
| `ConfirmLootSlot` | Y | Y | Y | Y | page |
| `ConfirmPetUnlearn` | Y | Y | Y | - | page |
| `ConfirmTalentWipe` | Y | Y | Y | Y | page |
| `ConsoleEcho` | Y | Y | Y | Y | page |
| `ConsoleExec` | Y | Y | Y | Y | page |
| `ConsoleGetAllCommands` | Y | Y | Y | Y | page |
| `ConsoleGetColorFromType` | Y | Y | Y | Y | page |
| `ConsoleGetFontHeight` | Y | Y | Y | Y | page |
| `ConsoleIsActive` | - | - | - | Y | page |
| `ConsolePrintAllMatchingCommands` | Y | Y | Y | Y | page |
| `ConsoleSetFontHeight` | Y | Y | Y | Y | page |
| `ConvertItemToBindToAccount` | - | - | - | Y | page |
| `ConvertToParty` | Y | Y | Y | - | page |
| `ConvertToRaid` | Y | Y | Y | - | missing |
| `CopyToClipboard` | Y | Y | Y | Y | page |
| `cos` | Y | Y | Y | Y | missing |
| `CraftIsEnchanting` | Y | Y | Y | - | missing |
| `CraftOnlyShowMakeable` | Y | Y | Y | - | missing |
| `CreateAbbreviateConfig` | Y | Y | Y | Y | page |
| `CreateFont` | Y | Y | Y | Y | page |
| `CreateFontFamily` | Y | Y | Y | Y | page |
| `CreateFrame` | Y | Y | Y | Y | page |
| `CreateFromMixins` | Y | Y | Y | Y | page |
| `CreateMacro` | Y | Y | Y | Y | page |
| `CreateNewRaidProfile` | Y | Y | Y | Y | missing |
| `CreateUnitHealPredictionCalculator` | Y | Y | Y | Y | page |
| `CreateWindow` | Y | Y | Y | Y | page |
| `CursorCanGoInSlot` | Y | Y | Y | - | page |
| `CursorHasItem` | Y | Y | Y | Y | page |
| `CursorHasMacro` | Y | Y | Y | Y | page |
| `CursorHasMoney` | Y | Y | Y | Y | page |
| `CursorHasSpell` | Y | Y | Y | Y | page |
| `date` | Y | Y | Y | Y | page |
| `debuglocals` | Y | Y | Y | Y | page |
| `debugprofilestart` | Y | Y | Y | Y | page |
| `debugprofilestop` | Y | Y | Y | Y | page |
| `debugstack` | Y | Y | Y | Y | page |
| `DeclineArenaTeam` | Y | Y | Y | - | page |
| `DeclineChannelInvite` | Y | Y | Y | Y | page |
| `DeclineGroup` | Y | Y | Y | Y | page |
| `DeclineGuild` | Y | Y | Y | Y | page |
| `DeclineName` | Y | Y | Y | Y | page |
| `DeclineQuest` | Y | Y | Y | Y | page |
| `DeclineResurrect` | Y | Y | Y | Y | page |
| `DeclineSpellConfirmationPrompt` | Y | Y | Y | Y | page |
| `deg` | Y | Y | Y | Y | missing |
| `DeleteCursorItem` | Y | Y | Y | Y | page |
| `DeleteGMTicket` | Y | Y | Y | Y | missing |
| `DeleteInboxItem` | Y | Y | Y | Y | page |
| `DeleteMacro` | Y | Y | Y | Y | page |
| `DeleteRaidProfile` | Y | Y | Y | Y | missing |
| `DepositGuildBankMoney` | Y | Y | Y | Y | missing |
| `DescendStop` | Y | Y | Y | Y | page |
| `DestroyTotem` | Y | Y | Y | Y | page |
| `DetectWowMouse` | Y | Y | Y | Y | missing |
| `difftime` | Y | Y | Y | Y | missing |
| `DisableSpellAutocast` | Y | Y | Y | - | missing |
| `DismissCompanion` | Y | Y | Y | Y | page |
| `Dismount` | Y | Y | Y | Y | page |
| `DisplayChannelOwner` | Y | Y | Y | Y | page |
| `DoCraft` | Y | Y | Y | - | missing |
| `DoesCurrentLocaleSellExpansionLevels` | Y | Y | Y | Y | page |
| `DoesSpellExist` | Y | Y | Y | - | page |
| `DoesTemplateExist` | Y | Y | Y | Y | page |
| `DoMasterLootRoll` | - | - | - | Y | missing |
| `DoTradeSkill` | Y | Y | Y | - | page |
| `DropCursorMoney` | Y | Y | Y | Y | page |
| `dropsecretaccess` | Y | Y | Y | Y | page |
| `dumpobject` | Y | Y | Y | Y | page |
| `DungeonAppearsInRandomLFD` | Y | Y | Y | Y | missing |
| `EditMacro` | Y | Y | Y | Y | page |
| `EJ_ClearSearch` | Y | Y | Y | Y | page |
| `EJ_EndSearch` | Y | Y | Y | Y | page |
| `EJ_GetContentTuningID` | Y | Y | Y | Y | page |
| `EJ_GetCreatureInfo` | Y | Y | Y | Y | page |
| `EJ_GetCurrentTier` | Y | Y | Y | Y | page |
| `EJ_GetDifficulty` | Y | Y | Y | Y | page |
| `EJ_GetEncounterInfo` | Y | Y | Y | Y | page |
| `EJ_GetEncounterInfoByIndex` | Y | Y | Y | Y | missing |
| `EJ_GetInstanceByIndex` | Y | Y | Y | Y | page |
| `EJ_GetInstanceForMap` | Y | Y | Y | Y | page |
| `EJ_GetInstanceInfo` | Y | Y | Y | Y | page |
| `EJ_GetInvTypeSortOrder` | Y | Y | Y | Y | page |
| `EJ_GetLootFilter` | Y | Y | Y | Y | page |
| `EJ_GetMapEncounter` | Y | Y | Y | Y | page |
| `EJ_GetNumEncountersForLootByIndex` | Y | Y | Y | Y | page |
| `EJ_GetNumLoot` | Y | Y | Y | Y | page |
| `EJ_GetNumSearchResults` | Y | Y | Y | Y | page |
| `EJ_GetNumTiers` | Y | Y | Y | Y | page |
| `EJ_GetSearchProgress` | Y | Y | Y | Y | page |
| `EJ_GetSearchResult` | Y | Y | Y | Y | page |
| `EJ_GetSearchSize` | Y | Y | Y | Y | page |
| `EJ_GetSectionPath` | Y | Y | Y | Y | page |
| `EJ_GetTierInfo` | Y | Y | Y | Y | page |
| `EJ_HandleLinkPath` | Y | Y | Y | Y | page |
| `EJ_InstanceIsRaid` | Y | Y | Y | Y | page |
| `EJ_IsLootListOutOfDate` | Y | Y | Y | Y | page |
| `EJ_IsSearchFinished` | Y | Y | Y | Y | page |
| `EJ_IsValidInstanceDifficulty` | Y | Y | Y | Y | page |
| `EJ_ResetLootFilter` | Y | Y | Y | Y | page |
| `EJ_SelectEncounter` | Y | Y | Y | Y | page |
| `EJ_SelectInstance` | Y | Y | Y | Y | page |
| `EJ_SelectTier` | Y | Y | Y | Y | page |
| `EJ_SetDifficulty` | Y | Y | Y | Y | page |
| `EJ_SetLootFilter` | Y | Y | Y | Y | page |
| `EJ_SetSearch` | Y | Y | Y | Y | page |
| `EjectPassengerFromSeat` | Y | Y | Y | Y | page |
| `EnableSpellAutocast` | Y | Y | Y | - | missing |
| `EnumerateFrames` | Y | Y | Y | Y | page |
| `EnumerateServerChannels` | Y | Y | Y | Y | page |
| `EquipCursorItem` | Y | Y | Y | Y | page |
| `EquipPendingItem` | Y | Y | Y | Y | page |
| `error` | Y | Y | Y | Y | missing |
| `exp` | Y | Y | Y | Y | missing |
| `ExpandAllFactionHeaders` | Y | Y | Y | - | missing |
| `ExpandCraftSkillLine` | Y | Y | Y | - | missing |
| `ExpandCurrencyList` | Y | Y | Y | - | page |
| `ExpandFactionHeader` | Y | Y | Y | - | page |
| `ExpandGuildTradeSkillHeader` | Y | Y | Y | Y | missing |
| `ExpandQuestHeader` | Y | Y | Y | Y | page |
| `ExpandSkillHeader` | Y | Y | Y | - | page |
| `ExpandTradeSkillSubClass` | Y | Y | Y | - | page |
| `ExpandTrainerSkillLine` | Y | Y | Y | - | page |
| `ExpandWarGameHeader` | Y | Y | Y | Y | missing |
| `FactionToggleAtWar` | Y | Y | Y | - | page |
| `fastrandom` | Y | Y | Y | Y | page |
| `FillLocalizedClassList` | Y | Y | Y | - | page |
| `FindSpellBookSlotBySpellID` | Y | Y | Y | Y | missing |
| `FlagTutorial` | Y | Y | Y | Y | missing |
| `FlashClientIcon` | Y | Y | Y | Y | page |
| `FlipCameraYaw` | Y | Y | Y | Y | page |
| `floor` | Y | Y | Y | Y | missing |
| `FlyoutHasSpell` | Y | Y | Y | Y | page |
| `FocusUnit` | Y | Y | Y | Y | page |
| `FollowUnit` | Y | Y | Y | Y | page |
| `forceinsecure` | Y | Y | Y | Y | page |
| `ForceLogout` | Y | Y | Y | Y | page |
| `ForceQuit` | Y | Y | Y | Y | page |
| `foreach` | Y | Y | Y | Y | missing |
| `foreachi` | Y | Y | Y | Y | missing |
| `ForfeitDuel` | Y | Y | Y | Y | missing |
| `format` | Y | Y | Y | Y | missing |
| `frexp` | Y | Y | Y | Y | missing |
| `gcinfo` | Y | Y | Y | Y | page |
| `GetAbandonQuestItems` | Y | Y | Y | - | missing |
| `GetAbandonQuestName` | Y | Y | Y | - | page |
| `GetAccountExpansionLevel` | Y | Y | Y | Y | page |
| `GetAchievementCategory` | Y | Y | Y | Y | page |
| `GetAchievementComparisonInfo` | Y | Y | Y | Y | page |
| `GetAchievementCriteriaInfo` | Y | Y | Y | Y | page |
| `GetAchievementCriteriaInfoByID` | Y | Y | Y | Y | missing |
| `GetAchievementGuildRep` | - | - | Y | Y | page |
| `GetAchievementInfo` | Y | Y | Y | Y | page |
| `GetAchievementLink` | Y | Y | Y | Y | page |
| `GetAchievementNumCriteria` | Y | Y | Y | Y | page |
| `GetAchievementNumRewards` | Y | Y | Y | Y | missing |
| `GetAchievementReward` | Y | Y | Y | Y | missing |
| `GetAchievementSearchProgress` | Y | Y | Y | Y | missing |
| `GetAchievementSearchSize` | Y | Y | Y | Y | missing |
| `GetActionBarToggles` | Y | Y | Y | Y | page |
| `GetActionInfo` | Y | Y | Y | Y | page |
| `GetActiveArtifactByRace` | - | - | Y | Y | page |
| `GetActiveLevel` | Y | Y | Y | Y | missing |
| `GetActiveLootRollIDs` | Y | Y | Y | Y | missing |
| `GetActiveQuestID` | - | - | - | Y | missing |
| `GetActiveTitle` | Y | Y | Y | Y | missing |
| `GetAddOnCPUUsage` | Y | Y | Y | Y | page |
| `GetAddOnMemoryUsage` | Y | Y | Y | Y | page |
| `GetAllowLowLevelRaid` | Y | Y | Y | Y | page |
| `GetAllowRecentAlliesSeeLocation` | - | - | - | Y | page |
| `GetAlternativeDefaultLanguage` | Y | Y | Y | Y | missing |
| `GetArchaeologyInfo` | - | - | Y | Y | page |
| `GetArchaeologyRaceInfo` | - | - | Y | Y | page |
| `GetArchaeologyRaceInfoByID` | - | - | Y | Y | page |
| `GetAreaSpiritHealerTime` | Y | Y | Y | Y | page |
| `GetAreaText` | Y | Y | Y | Y | page |
| `GetArenaOpponentSpec` | Y | Y | Y | Y | page |
| `GetArenaTeam` | Y | Y | Y | - | page |
| `GetArenaTeamGdfInfo` | Y | Y | Y | - | missing |
| `GetArenaTeamIndexBySize` | Y | Y | Y | - | page |
| `GetArenaTeamRosterInfo` | Y | Y | Y | - | page |
| `GetArenaTeamRosterSelection` | Y | Y | Y | - | missing |
| `GetArenaTeamRosterShowOffline` | Y | Y | Y | - | missing |
| `GetArmorPenetration` | Y | Y | Y | - | page |
| `GetArtifactInfoByRace` | - | - | Y | Y | page |
| `GetArtifactProgress` | - | - | Y | Y | page |
| `GetAttackPowerForStat` | Y | Y | Y | Y | page |
| `GetAuctionDeposit` | Y | Y | Y | - | missing |
| `GetAuctionHouseDepositRate` | Y | Y | Y | - | missing |
| `GetAuctionItemBattlePetInfo` | Y | Y | Y | - | page |
| `GetAuctionItemInfo` | Y | Y | Y | - | page |
| `GetAuctionItemLink` | Y | Y | Y | - | page |
| `GetAuctionItemSubClasses` | Y | Y | Y | - | page |
| `GetAuctionItemTimeLeft` | Y | Y | Y | - | page |
| `GetAuctionSellItemInfo` | Y | Y | Y | - | page |
| `GetAuctionSort` | Y | Y | Y | - | missing |
| `GetAutoDeclineGuildInvites` | Y | Y | Y | Y | page |
| `GetAutoDeclineNeighborhoodInvites` | Y | Y | Y | Y | page |
| `GetAutoQuestPopUp` | Y | Y | Y | Y | page |
| `GetAvailableBandwidth` | Y | Y | Y | Y | page |
| `GetAvailableLevel` | Y | Y | Y | Y | missing |
| `GetAvailableLocaleInfo` | Y | Y | Y | Y | page |
| `GetAvailableLocales` | Y | Y | Y | Y | page |
| `GetAvailableQuestInfo` | Y | Y | Y | Y | page |
| `GetAvailableTitle` | Y | Y | Y | Y | missing |
| `GetAverageItemLevel` | Y | Y | Y | Y | page |
| `GetAvoidance` | - | - | - | Y | page |
| `GetBackgroundLoadingStatus` | Y | Y | Y | Y | page |
| `GetBackpackCurrencyInfo` | Y | Y | Y | - | page |
| `GetBankSlotCost` | Y | Y | Y | - | page |
| `GetBaseDifficultyID` | Y | Y | Y | Y | page |
| `GetBattlefieldArenaFaction` | Y | Y | Y | Y | page |
| `GetBattlefieldEstimatedWaitTime` | Y | Y | Y | Y | page |
| `GetBattlefieldFlagPosition` | Y | Y | Y | - | page |
| `GetBattlefieldInstanceExpiration` | Y | Y | Y | Y | page |
| `GetBattlefieldInstanceInfo` | Y | Y | Y | - | page |
| `GetBattlefieldInstanceRunTime` | Y | Y | Y | Y | page |
| `GetBattlefieldMapIconScale` | Y | Y | Y | Y | missing |
| `GetBattlefieldPortExpiration` | Y | Y | Y | Y | page |
| `GetBattlefieldScore` | Y | Y | Y | - | page |
| `GetBattlefieldStatData` | Y | Y | Y | - | page |
| `GetBattlefieldStatInfo` | Y | Y | Y | - | page |
| `GetBattlefieldStatus` | Y | Y | Y | Y | page |
| `GetBattlefieldTeamInfo` | Y | Y | Y | Y | page |
| `GetBattlefieldTimeWaited` | Y | Y | Y | Y | page |
| `GetBattlefieldWinner` | Y | Y | Y | Y | page |
| `GetBattlegroundInfo` | Y | Y | Y | - | page |
| `GetBattlegroundPoints` | Y | Y | Y | Y | page |
| `GetBestFlexRaidChoice` | Y | Y | Y | Y | page |
| `GetBestRFChoice` | Y | Y | Y | Y | page |
| `GetBidderAuctionItems` | Y | Y | Y | - | missing |
| `GetBillingTimeRested` | Y | Y | Y | Y | page |
| `GetBinding` | Y | Y | Y | Y | page |
| `GetBindingAction` | Y | Y | Y | Y | page |
| `GetBindingKey` | Y | Y | Y | Y | page |
| `GetBindingText` | Y | Y | Y | Y | page |
| `GetBindLocation` | Y | Y | Y | Y | page |
| `GetBlockChance` | Y | Y | Y | Y | page |
| `GetBuildInfo` | Y | Y | Y | Y | page |
| `GetBuildOption` | Y | Y | Y | Y | page |
| `GetButtonMetatable` | Y | Y | Y | Y | page |
| `GetBuybackItemInfo` | Y | Y | Y | Y | page |
| `GetBuybackItemLink` | Y | Y | Y | Y | missing |
| `GetCallPetSpellInfo` | Y | Y | Y | Y | missing |
| `GetCallstackHeight` | Y | Y | Y | Y | page |
| `GetCameraFOVDefaults` | Y | Y | Y | Y | page |
| `GetCameraZoom` | Y | Y | Y | Y | page |
| `GetCategoryAchievementPoints` | Y | Y | Y | Y | missing |
| `GetCategoryInfo` | Y | Y | Y | Y | page |
| `GetCategoryList` | Y | Y | Y | Y | page |
| `GetCategoryNumAchievements` | Y | Y | Y | Y | page |
| `GetCemeteryPreference` | Y | Y | Y | Y | page |
| `GetChannelDisplayInfo` | Y | Y | Y | Y | page |
| `GetChannelList` | Y | Y | Y | Y | page |
| `GetChannelName` | Y | Y | Y | Y | page |
| `GetChatTypeIndex` | Y | Y | Y | Y | page |
| `GetChatWindowChannels` | Y | Y | Y | Y | page |
| `GetChatWindowInfo` | Y | Y | Y | Y | page |
| `GetChatWindowMessages` | Y | Y | Y | Y | page |
| `GetChatWindowSavedDimensions` | Y | Y | Y | Y | missing |
| `GetChatWindowSavedPosition` | Y | Y | Y | Y | missing |
| `GetClassicExpansionLevel` | Y | Y | Y | Y | page |
| `GetClassInfo` | Y | Y | Y | Y | page |
| `GetClickFrame` | Y | Y | Y | Y | page |
| `GetClientDisplayExpansionLevel` | Y | Y | Y | Y | page |
| `GetCollapsingStarCost` | - | - | - | Y | page |
| `GetCombatRating` | Y | Y | Y | Y | page |
| `GetCombatRatingBonus` | Y | Y | Y | Y | page |
| `GetCombatRatingBonusForCombatRatingValue` | - | - | - | Y | page |
| `GetComboPoints` | Y | Y | Y | Y | page |
| `GetCompanionCooldown` | Y | Y | Y | - | page |
| `GetCompanionInfo` | Y | Y | Y | Y | page |
| `GetComparisonAchievementPoints` | Y | Y | Y | Y | missing |
| `GetComparisonCategoryNumAchievements` | Y | Y | Y | Y | missing |
| `GetComparisonStatistic` | Y | Y | Y | Y | page |
| `GetCorpseRecoveryDelay` | Y | Y | Y | Y | page |
| `GetCorruption` | - | - | - | Y | page |
| `GetCorruptionResistance` | - | - | - | Y | page |
| `GetCraftButtonToken` | Y | Y | Y | - | missing |
| `GetCraftCooldown` | Y | Y | Y | - | missing |
| `GetCraftDescription` | Y | Y | Y | - | page |
| `GetCraftDisplaySkillLine` | Y | Y | Y | - | page |
| `GetCraftFilter` | Y | Y | Y | - | missing |
| `GetCraftIcon` | Y | Y | Y | - | missing |
| `GetCraftInfo` | Y | Y | Y | - | page |
| `GetCraftItemLink` | Y | Y | Y | - | page |
| `GetCraftName` | Y | Y | Y | - | page |
| `GetCraftNumMade` | Y | Y | Y | - | missing |
| `GetCraftNumReagents` | Y | Y | Y | - | page |
| `GetCraftReagentInfo` | Y | Y | Y | - | page |
| `GetCraftReagentItemLink` | Y | Y | Y | - | page |
| `GetCraftRecipeLink` | Y | Y | Y | - | page |
| `GetCraftSelectionIndex` | Y | Y | Y | - | missing |
| `GetCraftSkillLine` | Y | Y | Y | - | page |
| `GetCraftSlots` | Y | Y | Y | - | missing |
| `GetCraftSpellFocus` | Y | Y | Y | - | page |
| `GetCritChance` | Y | Y | Y | Y | page |
| `GetCritChanceFromAgility` | Y | Y | Y | - | missing |
| `GetCritChanceProvidesParryEffect` | - | - | - | Y | page |
| `GetCriteriaSpell` | Y | Y | Y | Y | missing |
| `GetCurrencyLink` | Y | Y | Y | - | page |
| `GetCurrencyListInfo` | Y | Y | Y | - | page |
| `GetCurrencyListSize` | Y | Y | Y | - | page |
| `GetCurrentArenaSeason` | Y | Y | Y | Y | page |
| `GetCurrentArenaSeasonUsesTeams` | Y | Y | Y | - | missing |
| `GetCurrentBindingSet` | Y | Y | Y | Y | page |
| `GetCurrentCinematicSummary` | Y | Y | Y | Y | page |
| `GetCurrentEnvironment` | Y | Y | Y | Y | missing |
| `GetCurrentEventID` | Y | Y | Y | Y | page |
| `GetCurrentGlyphNameForSpell` | - | - | - | Y | missing |
| `GetCurrentGraphicsAPI` | Y | Y | Y | Y | page |
| `GetCurrentGraphicsSetting` | Y | Y | Y | Y | missing |
| `GetCurrentGuildBankTab` | Y | Y | Y | Y | missing |
| `GetCurrentKeyBoardFocus` | Y | Y | Y | Y | page |
| `GetCurrentLevelFeatures` | Y | Y | Y | Y | missing |
| `GetCurrentLevelSpells` | Y | Y | Y | - | page |
| `GetCurrentRegion` | Y | Y | Y | Y | page |
| `GetCurrentRegionName` | Y | Y | Y | Y | page |
| `GetCurrentScaledResolution` | Y | Y | Y | Y | missing |
| `GetCurrentTitle` | Y | Y | Y | Y | page |
| `GetCursorDelta` | Y | Y | Y | Y | page |
| `GetCursorInfo` | Y | Y | Y | Y | page |
| `GetCursorMoney` | Y | Y | Y | Y | page |
| `GetCursorPosition` | Y | Y | Y | Y | page |
| `GetDailyQuestsCompleted` | Y | Y | Y | Y | missing |
| `GetDefaultLanguage` | Y | Y | Y | Y | page |
| `GetDefaultScale` | Y | Y | Y | Y | page |
| `GetDemotionRank` | Y | Y | Y | Y | missing |
| `GetDifficultyInfo` | Y | Y | Y | Y | page |
| `GetDodgeChance` | Y | Y | Y | Y | page |
| `GetDodgeChanceFromAttribute` | Y | Y | Y | Y | page |
| `GetDownloadedPercentage` | Y | Y | Y | Y | page |
| `GetDuelerInfo` | Y | Y | Y | - | missing |
| `GetDungeonDifficultyID` | Y | Y | Y | Y | page |
| `GetDungeonForRandomSlot` | Y | Y | Y | Y | missing |
| `GetEclipseDirection` | Y | Y | Y | - | page |
| `GetEditBoxMetatable` | Y | Y | Y | Y | page |
| `GetEquipmentNameFromSpell` | - | - | - | Y | missing |
| `GetErrorCallstackHeight` | Y | Y | Y | Y | page |
| `geterrorhandler` | Y | Y | Y | Y | page |
| `GetEventCPUUsage` | Y | Y | Y | Y | page |
| `GetEventTime` | Y | Y | Y | Y | page |
| `GetExpansionDisplayInfo` | Y | Y | Y | Y | page |
| `GetExpansionForLevel` | Y | Y | Y | Y | page |
| `GetExpansionLevel` | Y | Y | Y | Y | page |
| `GetExpansionTrialInfo` | Y | Y | Y | Y | page |
| `GetExpertise` | Y | Y | Y | Y | page |
| `GetExpertisePercent` | Y | Y | Y | Y | page |
| `GetFactionInfo` | Y | Y | Y | - | page |
| `GetFactionInfoByID` | Y | Y | Y | - | missing |
| `GetFailedPVPTalentIDs` | - | - | - | Y | missing |
| `GetFailedTalentIDs` | - | - | - | Y | missing |
| `getfenv` | Y | Y | Y | Y | page |
| `GetFileIDFromPath` | Y | Y | Y | Y | page |
| `GetFileStreamingStatus` | Y | Y | Y | Y | page |
| `GetFilteredAchievementID` | Y | Y | Y | Y | page |
| `GetFirstBagBankSlotIndex` | Y | Y | Y | - | page |
| `GetFirstTradeSkill` | Y | Y | Y | - | page |
| `GetFlexRaidDungeonInfo` | Y | Y | Y | Y | missing |
| `GetFlyoutID` | Y | Y | Y | Y | missing |
| `GetFlyoutInfo` | Y | Y | Y | Y | page |
| `GetFlyoutSlotInfo` | Y | Y | Y | Y | page |
| `GetFollowerTypeIDFromSpell` | - | - | - | Y | missing |
| `GetFontInfo` | Y | Y | Y | Y | page |
| `GetFonts` | Y | Y | Y | Y | page |
| `GetFontStringMetatable` | Y | Y | Y | Y | page |
| `GetFrameCPUUsage` | Y | Y | Y | Y | page |
| `GetFrameMetatable` | Y | Y | Y | Y | page |
| `GetFramerate` | Y | Y | Y | Y | page |
| `GetFramesRegisteredForEvent` | Y | Y | Y | Y | page |
| `GetFunctionCPUUsage` | Y | Y | Y | Y | page |
| `GetGameMessageInfo` | Y | Y | Y | Y | page |
| `GetGameTime` | Y | Y | Y | Y | page |
| `GetGlobalEnvironment` | Y | Y | Y | Y | missing |
| `GetGlyphClearInfo` | - | - | Y | - | page |
| `GetGlyphInfo` | - | - | Y | - | page |
| `GetGlyphSocketInfo` | - | - | Y | - | page |
| `GetGMStatus` | Y | Y | Y | Y | missing |
| `GetGMTicket` | Y | Y | Y | Y | missing |
| `GetGraphicsAPIs` | Y | Y | Y | Y | page |
| `GetGraphicsCVarValueForQualityLevel` | Y | Y | Y | Y | missing |
| `GetGreetingText` | Y | Y | Y | Y | missing |
| `GetGroupMemberCounts` | Y | Y | Y | Y | missing |
| `GetGroupPreviewTalentPointsSpent` | Y | Y | Y | - | missing |
| `GetGuildAchievementMemberInfo` | - | - | Y | Y | page |
| `GetGuildAchievementMembers` | - | - | Y | Y | page |
| `GetGuildAchievementNumMembers` | - | - | Y | Y | page |
| `GetGuildBankBonusDepositMoney` | Y | Y | Y | Y | missing |
| `GetGuildBankItemInfo` | Y | Y | Y | Y | page |
| `GetGuildBankItemLink` | Y | Y | Y | Y | page |
| `GetGuildBankMoney` | Y | Y | Y | Y | page |
| `GetGuildBankMoneyTransaction` | Y | Y | Y | Y | page |
| `GetGuildBankTabCost` | Y | Y | Y | Y | missing |
| `GetGuildBankTabInfo` | Y | Y | Y | Y | page |
| `GetGuildBankTabPermissions` | Y | Y | Y | Y | page |
| `GetGuildBankText` | Y | Y | Y | Y | missing |
| `GetGuildBankTransaction` | Y | Y | Y | Y | page |
| `GetGuildBankWithdrawGoldLimit` | Y | Y | Y | Y | page |
| `GetGuildBankWithdrawMoney` | Y | Y | Y | Y | page |
| `GetGuildCategoryList` | Y | Y | Y | Y | missing |
| `GetGuildChallengeInfo` | Y | Y | Y | Y | missing |
| `GetGuildCharterCost` | Y | Y | Y | Y | missing |
| `GetGuildEventInfo` | Y | Y | Y | Y | missing |
| `GetGuildFactionGroup` | Y | Y | Y | Y | missing |
| `GetGuildFactionInfo` | Y | Y | Y | - | page |
| `GetGuildInfo` | Y | Y | Y | Y | page |
| `GetGuildLogoInfo` | Y | Y | Y | Y | missing |
| `GetGuildMemberRecipes` | Y | Y | Y | Y | missing |
| `GetGuildNewsFilters` | Y | Y | Y | Y | missing |
| `GetGuildNewsMemberName` | Y | Y | Y | Y | missing |
| `GetGuildNewsSort` | Y | Y | Y | Y | missing |
| `GetGuildPerkInfo` | Y | Y | Y | Y | missing |
| `GetGuildRecipeInfoPostQuery` | Y | Y | Y | Y | page |
| `GetGuildRecipeMember` | Y | Y | Y | Y | page |
| `GetGuildRenameRequired` | Y | Y | Y | Y | missing |
| `GetGuildRewardInfo` | Y | Y | Y | Y | missing |
| `GetGuildRosterInfo` | Y | Y | Y | Y | page |
| `GetGuildRosterLargestAchievementPoints` | Y | Y | Y | Y | missing |
| `GetGuildRosterLastOnline` | Y | Y | Y | Y | page |
| `GetGuildRosterSelection` | Y | Y | Y | Y | page |
| `GetGuildRosterShowOffline` | Y | Y | Y | Y | page |
| `GetGuildTabardFiles` | Y | Y | Y | Y | page |
| `GetGuildTradeSkillInfo` | Y | Y | Y | Y | page |
| `GetHaste` | Y | Y | Y | Y | page |
| `GetHitModifier` | Y | Y | Y | Y | page |
| `GetHomePartyInfo` | Y | Y | Y | Y | page |
| `GetInboxHeaderInfo` | Y | Y | Y | Y | page |
| `GetInboxInvoiceInfo` | Y | Y | Y | Y | page |
| `GetInboxItem` | Y | Y | Y | Y | page |
| `GetInboxItemLink` | Y | Y | Y | Y | page |
| `GetInboxNumItems` | Y | Y | Y | Y | page |
| `GetInboxText` | Y | Y | Y | Y | page |
| `GetInspectArenaData` | Y | Y | Y | Y | page |
| `GetInspectArenaTeamData` | Y | Y | Y | - | missing |
| `GetInspectHonorData` | Y | Y | Y | Y | page |
| `GetInspectPVPRankProgress` | Y | Y | Y | - | page |
| `GetInspectSpecialization` | Y | Y | Y | - | page |
| `GetInspectTalent` | Y | Y | Y | Y | missing |
| `GetInstanceBootTimeRemaining` | Y | Y | Y | Y | page |
| `GetInstanceInfo` | Y | Y | Y | Y | page |
| `GetInstanceLockTimeRemaining` | Y | Y | Y | Y | page |
| `GetInstanceLockTimeRemainingEncounter` | Y | Y | Y | Y | page |
| `GetInventoryAlertStatus` | Y | Y | Y | Y | page |
| `GetInventoryItemBroken` | Y | Y | Y | Y | page |
| `GetInventoryItemCooldown` | Y | Y | Y | Y | page |
| `GetInventoryItemCount` | Y | Y | Y | Y | page |
| `GetInventoryItemDurability` | Y | Y | Y | Y | page |
| `GetInventoryItemEquippedUnusable` | Y | Y | Y | Y | missing |
| `GetInventoryItemGems` | Y | Y | Y | - | page |
| `GetInventoryItemID` | Y | Y | Y | Y | page |
| `GetInventoryItemLink` | Y | Y | Y | Y | page |
| `GetInventoryItemQuality` | Y | Y | Y | Y | page |
| `GetInventoryItemsForSlot` | Y | Y | Y | Y | page |
| `GetInventoryItemTexture` | Y | Y | Y | Y | page |
| `GetInventorySlotInfo` | Y | Y | Y | - | page |
| `GetInviteConfirmationInfo` | Y | Y | Y | Y | page |
| `GetInviteReferralInfo` | Y | Y | Y | - | missing |
| `GetItemLevelColor` | - | - | - | Y | page |
| `GetItemStatDelta` | Y | Y | Y | - | page |
| `GetItemStats` | Y | Y | Y | - | page |
| `GetJailersTowerLevel` | - | - | - | Y | page |
| `GetJournalInfoForSpellConfirmation` | - | - | - | Y | missing |
| `GetLanguageByIndex` | Y | Y | Y | Y | page |
| `GetLatestCompletedAchievements` | Y | Y | Y | Y | missing |
| `GetLatestCompletedComparisonAchievements` | Y | Y | Y | Y | missing |
| `GetLatestThreeSenders` | Y | Y | Y | Y | page |
| `GetLatestUpdatedComparisonStats` | Y | Y | Y | Y | missing |
| `GetLatestUpdatedStats` | Y | Y | Y | Y | missing |
| `GetLegacyRaidDifficultyID` | Y | Y | Y | Y | page |
| `GetLFDChoiceCollapseState` | Y | Y | Y | Y | missing |
| `GetLFDChoiceEnabledState` | Y | Y | Y | Y | missing |
| `GetLFDChoiceOrder` | Y | Y | Y | Y | missing |
| `GetLFDLockInfo` | Y | Y | Y | Y | missing |
| `GetLFDLockPlayerCount` | Y | Y | Y | Y | missing |
| `GetLFDRoleLockInfo` | Y | Y | Y | Y | missing |
| `GetLFDRoleRestrictions` | Y | Y | Y | Y | missing |
| `GetLFGBootProposal` | Y | Y | Y | Y | page |
| `GetLFGCategoryForID` | Y | Y | Y | Y | missing |
| `GetLFGCompletionReward` | Y | Y | Y | Y | missing |
| `GetLFGCompletionRewardItem` | Y | Y | Y | Y | missing |
| `GetLFGCompletionRewardItemLink` | Y | Y | Y | Y | missing |
| `GetLFGDeserterExpiration` | Y | Y | Y | Y | page |
| `GetLFGDungeonEncounterInfo` | Y | Y | Y | Y | page |
| `GetLFGDungeonInfo` | Y | Y | Y | Y | page |
| `GetLFGDungeonNumEncounters` | Y | Y | Y | Y | page |
| `GetLFGDungeonRewardCapBarInfo` | Y | Y | Y | Y | page |
| `GetLFGDungeonRewardCapInfo` | Y | Y | Y | Y | missing |
| `GetLFGDungeonRewardInfo` | Y | Y | Y | Y | missing |
| `GetLFGDungeonRewardLink` | Y | Y | Y | Y | missing |
| `GetLFGDungeonRewards` | Y | Y | Y | Y | missing |
| `GetLFGDungeonShortageRewardInfo` | Y | Y | Y | Y | missing |
| `GetLFGDungeonShortageRewardLink` | Y | Y | Y | Y | missing |
| `GetLFGInfoServer` | Y | Y | Y | Y | missing |
| `GetLFGInviteRoleAvailability` | Y | Y | Y | Y | missing |
| `GetLFGInviteRoleRestrictions` | Y | Y | Y | Y | missing |
| `GetLFGProposal` | Y | Y | Y | Y | page |
| `GetLFGProposalEncounter` | Y | Y | Y | Y | missing |
| `GetLFGProposalMember` | Y | Y | Y | Y | missing |
| `GetLFGQueuedList` | Y | Y | Y | Y | missing |
| `GetLFGQueueStats` | Y | Y | Y | Y | page |
| `GetLFGRandomCooldownExpiration` | Y | Y | Y | Y | page |
| `GetLFGRandomDungeonInfo` | Y | Y | Y | Y | page |
| `GetLFGReadyCheckUpdate` | Y | Y | Y | Y | missing |
| `GetLFGReadyCheckUpdateBattlegroundInfo` | Y | Y | Y | Y | missing |
| `GetLFGRoles` | Y | Y | Y | Y | page |
| `GetLFGRoleShortageRewards` | Y | Y | Y | Y | page |
| `GetLFGRoleUpdate` | Y | Y | Y | Y | missing |
| `GetLFGRoleUpdateBattlegroundInfo` | Y | Y | Y | Y | page |
| `GetLFGRoleUpdateMember` | Y | Y | Y | Y | missing |
| `GetLFGRoleUpdateSlot` | Y | Y | Y | Y | page |
| `GetLFGSuspendedPlayers` | Y | Y | Y | Y | missing |
| `GetLFRChoiceOrder` | Y | Y | Y | Y | page |
| `GetLifesteal` | - | - | - | Y | page |
| `GetLocale` | Y | Y | Y | Y | page |
| `GetLocalGameTime` | Y | Y | Y | Y | page |
| `GetLooseMacroIcons` | Y | Y | Y | Y | missing |
| `GetLooseMacroItemIcons` | Y | Y | Y | Y | missing |
| `GetLootInfo` | Y | Y | Y | Y | page |
| `GetLootRollItemInfo` | Y | Y | Y | Y | page |
| `GetLootRollItemLink` | Y | Y | Y | Y | page |
| `GetLootRollTimeLeft` | Y | Y | Y | Y | page |
| `GetLootSlotInfo` | Y | Y | Y | Y | page |
| `GetLootSlotLink` | Y | Y | Y | Y | page |
| `GetLootSlotType` | Y | Y | Y | Y | page |
| `GetLootSourceInfo` | Y | Y | Y | Y | page |
| `GetLootSpecialization` | Y | Y | Y | Y | page |
| `GetLootThreshold` | Y | Y | Y | Y | page |
| `GetMacroBody` | Y | Y | Y | Y | page |
| `GetMacroIcons` | Y | Y | Y | Y | missing |
| `GetMacroIndexByName` | Y | Y | Y | Y | page |
| `GetMacroInfo` | Y | Y | Y | Y | page |
| `GetMacroItem` | Y | Y | Y | Y | page |
| `GetMacroItemIcons` | Y | Y | Y | Y | missing |
| `GetMacroSpell` | Y | Y | Y | Y | page |
| `GetMajorTalentTreeBonuses` | Y | Y | Y | - | missing |
| `GetManaRegen` | Y | Y | Y | Y | page |
| `GetMasterLootCandidate` | Y | Y | Y | Y | page |
| `GetMastery` | Y | Y | Y | Y | page |
| `GetMasteryEffect` | Y | Y | Y | Y | page |
| `GetMaxBattlefieldID` | Y | Y | Y | Y | page |
| `GetMaxCombatRatingBonus` | Y | Y | Y | - | page |
| `GetMaxDailyQuests` | Y | Y | Y | - | missing |
| `GetMaximumExpansionLevel` | Y | Y | Y | Y | page |
| `GetMaxLevelForExpansionLevel` | Y | Y | Y | Y | page |
| `GetMaxLevelForLatestExpansion` | Y | Y | Y | Y | page |
| `GetMaxLevelForPlayerExpansion` | Y | Y | Y | Y | page |
| `GetMaxNumCUFProfiles` | Y | Y | Y | Y | missing |
| `GetMaxPlayerLevel` | Y | Y | Y | Y | page |
| `GetMaxRenderScale` | Y | Y | Y | Y | missing |
| `GetMaxRewardCurrencies` | Y | Y | Y | Y | missing |
| `GetMaxTalentTier` | - | - | - | Y | page |
| `GetMeleeHaste` | Y | Y | Y | Y | page |
| `GetMerchantFilter` | - | - | - | Y | missing |
| `GetMerchantItemCostInfo` | Y | Y | Y | Y | page |
| `GetMerchantItemCostItem` | Y | Y | Y | Y | page |
| `GetMerchantItemID` | Y | Y | Y | Y | page |
| `GetMerchantItemInfo` | Y | Y | Y | - | page |
| `GetMerchantItemLink` | Y | Y | Y | Y | page |
| `GetMerchantItemMaxStack` | Y | Y | Y | Y | page |
| `GetMerchantNumItems` | Y | Y | Y | Y | page |
| `getmetatable` | Y | Y | Y | Y | missing |
| `GetMinimapZoneText` | Y | Y | Y | Y | page |
| `GetMinimumExpansionLevel` | Y | Y | Y | Y | page |
| `GetMinorTalentTreeBonuses` | Y | Y | Y | - | missing |
| `GetMinRenderScale` | Y | Y | Y | Y | missing |
| `GetMirrorTimerInfo` | Y | Y | Y | Y | page |
| `GetMirrorTimerProgress` | Y | Y | Y | Y | page |
| `GetModifiedClick` | Y | Y | Y | Y | page |
| `GetModifiedClickAction` | Y | Y | Y | Y | missing |
| `GetModResilienceDamageReduction` | Y | Y | Y | Y | page |
| `GetMoney` | Y | Y | Y | Y | page |
| `GetMonitorAspectRatio` | Y | Y | Y | Y | missing |
| `GetMonitorCount` | Y | Y | Y | Y | missing |
| `GetMonitorName` | Y | Y | Y | Y | missing |
| `GetMouseButtonClicked` | Y | Y | Y | Y | page |
| `GetMouseButtonName` | Y | Y | Y | Y | page |
| `GetMouseFoci` | Y | Y | Y | Y | page |
| `GetMovieDownloadProgress` | Y | Y | Y | Y | page |
| `GetMultiCastTotemSpells` | Y | Y | Y | Y | page |
| `getn` | Y | Y | Y | Y | missing |
| `GetNativeRealmID` | Y | Y | Y | Y | page |
| `GetNegativeCorruptionEffectInfo` | - | - | - | Y | page |
| `GetNetIpTypes` | Y | Y | Y | Y | page |
| `GetNetStats` | Y | Y | Y | Y | page |
| `GetNextAchievement` | Y | Y | Y | Y | page |
| `GetNextCompleatedTutorial` | Y | Y | Y | Y | missing |
| `GetNextPendingInviteConfirmation` | Y | Y | Y | Y | missing |
| `GetNextPetTalentLevel` | Y | Y | Y | - | missing |
| `GetNextStableSlotCost` | Y | Y | Y | - | page |
| `GetNextTalentLevel` | Y | Y | Y | - | page |
| `GetNormalizedRealmName` | Y | Y | Y | Y | page |
| `GetNumActiveQuests` | Y | Y | Y | Y | page |
| `GetNumArchaeologyRaces` | - | - | Y | Y | page |
| `GetNumArenaOpponents` | Y | Y | Y | Y | missing |
| `GetNumArenaOpponentSpecs` | Y | Y | Y | Y | missing |
| `GetNumArenaTeamMembers` | Y | Y | Y | - | missing |
| `GetNumArtifactsByRace` | - | - | Y | Y | page |
| `GetNumAuctionItems` | Y | Y | Y | - | page |
| `GetNumAutoQuestPopUps` | Y | Y | Y | Y | page |
| `GetNumAvailableQuests` | Y | Y | Y | Y | page |
| `GetNumBankSlots` | Y | Y | Y | - | page |
| `GetNumBattlefieldFlagPositions` | Y | Y | Y | Y | missing |
| `GetNumBattlefields` | Y | Y | Y | - | page |
| `GetNumBattlefieldScores` | Y | Y | Y | Y | page |
| `GetNumBattlefieldStats` | Y | Y | Y | - | page |
| `GetNumBattlefieldVehicles` | - | - | - | Y | missing |
| `GetNumBattlegroundTypes` | - | - | Y | Y | page |
| `GetNumBindings` | Y | Y | Y | Y | page |
| `GetNumBuybackItems` | Y | Y | Y | Y | page |
| `GetNumChannelMembers` | Y | Y | Y | Y | missing |
| `GetNumClasses` | Y | Y | Y | Y | page |
| `GetNumCompanions` | Y | Y | Y | Y | page |
| `GetNumComparisonCompletedAchievements` | Y | Y | Y | Y | page |
| `GetNumCompletedAchievements` | Y | Y | Y | Y | page |
| `GetNumCrafts` | Y | Y | Y | - | page |
| `GetNumDeclensionSets` | Y | Y | Y | Y | page |
| `GetNumDisplayChannels` | Y | Y | Y | Y | page |
| `GetNumDungeonForRandomSlot` | Y | Y | Y | Y | missing |
| `GetNumExpansions` | Y | Y | Y | Y | page |
| `GetNumFactions` | Y | Y | Y | - | page |
| `GetNumFilteredAchievements` | Y | Y | Y | Y | page |
| `GetNumFlexRaidDungeons` | Y | Y | Y | Y | page |
| `GetNumFlyouts` | Y | Y | Y | Y | missing |
| `GetNumGlyphs` | - | - | Y | - | page |
| `GetNumGlyphSockets` | - | - | Y | - | page |
| `GetNumGroupChannels` | Y | Y | Y | Y | missing |
| `GetNumGroupMembers` | Y | Y | Y | Y | page |
| `GetNumGuildBankMoneyTransactions` | Y | Y | Y | Y | missing |
| `GetNumGuildBankTabs` | Y | Y | Y | Y | missing |
| `GetNumGuildBankTransactions` | Y | Y | Y | Y | missing |
| `GetNumGuildChallenges` | Y | Y | Y | Y | missing |
| `GetNumGuildEvents` | Y | Y | Y | Y | missing |
| `GetNumGuildMembers` | Y | Y | Y | Y | page |
| `GetNumGuildNews` | Y | Y | Y | Y | missing |
| `GetNumGuildPerks` | Y | Y | Y | Y | missing |
| `GetNumGuildRewards` | Y | Y | Y | Y | missing |
| `GetNumGuildTradeSkill` | Y | Y | Y | Y | missing |
| `GetNumLanguages` | Y | Y | Y | Y | page |
| `GetNumLootItems` | Y | Y | Y | Y | page |
| `GetNumMacros` | Y | Y | Y | Y | page |
| `GetNumMembersInRank` | Y | Y | Y | Y | missing |
| `GetNumModifiedClickActions` | Y | Y | Y | Y | missing |
| `GetNumPetitionNames` | Y | Y | Y | Y | page |
| `GetNumPrimaryProfessions` | Y | Y | Y | - | missing |
| `GetNumQuestChoices` | Y | Y | Y | Y | page |
| `GetNumQuestCurrencies` | Y | Y | Y | Y | missing |
| `GetNumQuestItemDrops` | Y | Y | Y | Y | missing |
| `GetNumQuestItems` | Y | Y | Y | Y | page |
| `GetNumQuestLeaderBoards` | Y | Y | Y | Y | page |
| `GetNumQuestLogChoices` | Y | Y | Y | Y | page |
| `GetNumQuestLogEntries` | Y | Y | Y | - | page |
| `GetNumQuestLogRewardCurrencies` | Y | Y | Y | - | page |
| `GetNumQuestLogRewardFactions` | - | - | - | Y | missing |
| `GetNumQuestLogRewards` | Y | Y | Y | Y | page |
| `GetNumQuestLogTasks` | - | - | - | Y | missing |
| `GetNumQuestRewards` | Y | Y | Y | Y | page |
| `GetNumQuestWatches` | Y | Y | Y | - | page |
| `GetNumRaidProfiles` | Y | Y | Y | Y | missing |
| `GetNumRandomDungeons` | Y | Y | Y | Y | page |
| `GetNumRandomScenarios` | Y | Y | Y | Y | missing |
| `GetNumRewardCurrencies` | Y | Y | Y | - | page |
| `GetNumRFDungeons` | Y | Y | Y | Y | page |
| `GetNumRoutes` | Y | Y | Y | Y | missing |
| `GetNumSavedInstances` | Y | Y | Y | Y | page |
| `GetNumSavedWorldBosses` | Y | Y | Y | Y | page |
| `GetNumScenarios` | Y | Y | Y | Y | missing |
| `GetNumShapeshiftForms` | Y | Y | Y | Y | page |
| `GetNumSkillLines` | Y | Y | Y | - | page |
| `GetNumSpecGroups` | Y | Y | Y | Y | page |
| `GetNumSpecializations` | Y | Y | Y | Y | page |
| `GetNumSpellTabs` | Y | Y | Y | - | page |
| `GetNumStableSlots` | Y | Y | Y | - | page |
| `GetNumSubgroupMembers` | Y | Y | Y | Y | page |
| `GetNumTalentGroups` | Y | Y | Y | - | page |
| `GetNumTalentPoints` | Y | Y | Y | - | missing |
| `GetNumTalents` | Y | Y | Y | - | page |
| `GetNumTalentTabs` | Y | Y | Y | - | page |
| `GetNumTitles` | Y | Y | Y | Y | page |
| `GetNumTotemSlots` | Y | Y | Y | Y | page |
| `GetNumTrackedAchievements` | Y | Y | Y | - | page |
| `GetNumTradeSkills` | Y | Y | Y | - | page |
| `GetNumTrainerServices` | Y | Y | Y | Y | page |
| `GetNumTreasurePickerItems` | - | - | - | Y | missing |
| `GetNumUnspentPvpTalents` | - | - | - | Y | missing |
| `GetNumUnspentTalents` | Y | Y | Y | Y | page |
| `GetNumWarGameTypes` | Y | Y | Y | Y | missing |
| `GetObjectiveText` | Y | Y | Y | Y | missing |
| `GetOnlyShowMakeable` | Y | Y | Y | - | missing |
| `GetOnlyShowSkillUps` | Y | Y | Y | - | missing |
| `GetOptOutOfLoot` | Y | Y | Y | Y | page |
| `GetOSLocale` | Y | Y | Y | Y | page |
| `GetOverrideAPBySpellPower` | Y | Y | Y | Y | page |
| `GetOverrideSpellPowerByAP` | Y | Y | Y | Y | page |
| `GetOwnerAuctionItems` | Y | Y | Y | - | page |
| `GetParryChance` | Y | Y | Y | Y | page |
| `GetParryChanceFromAttribute` | Y | Y | Y | Y | page |
| `GetPartyAssignment` | Y | Y | Y | Y | page |
| `GetPartyLFGBackfillInfo` | Y | Y | Y | Y | missing |
| `GetPartyLFGID` | Y | Y | Y | Y | missing |
| `GetPendingGlyphInfo` | - | - | Y | - | page |
| `GetPendingGlyphName` | - | - | - | Y | missing |
| `GetPendingInviteConfirmations` | Y | Y | Y | Y | missing |
| `GetPersonalRatedInfo` | Y | Y | Y | Y | page |
| `GetPetActionCooldown` | Y | Y | Y | Y | page |
| `GetPetActionInfo` | Y | Y | Y | Y | page |
| `GetPetActionSlotUsable` | Y | Y | Y | Y | page |
| `GetPetActionsUsable` | Y | Y | Y | Y | missing |
| `GetPetExperience` | Y | Y | Y | Y | page |
| `GetPetFoodTypes` | Y | Y | Y | Y | page |
| `GetPetHappiness` | Y | Y | Y | - | page |
| `GetPetIcon` | Y | Y | Y | Y | missing |
| `GetPetitionInfo` | Y | Y | Y | Y | page |
| `GetPetitionItemPrice` | Y | Y | Y | - | missing |
| `GetPetitionNameInfo` | Y | Y | Y | Y | missing |
| `GetPetLoyalty` | Y | Y | Y | - | page |
| `GetPetMeleeHaste` | Y | Y | Y | Y | page |
| `GetPetSpellBonusDamage` | Y | Y | Y | Y | page |
| `GetPetTimeRemaining` | Y | Y | Y | Y | missing |
| `GetPetTrainingPoints` | Y | Y | Y | - | page |
| `GetPhysicalScreenSize` | Y | Y | Y | Y | page |
| `GetPlayerFacing` | Y | Y | Y | Y | page |
| `GetPlayerInfoByGUID` | Y | Y | Y | Y | page |
| `GetPlayerTradeCurrency` | - | - | - | Y | missing |
| `GetPlayerTradeMoney` | Y | Y | Y | Y | page |
| `GetPossessInfo` | Y | Y | Y | Y | page |
| `GetPowerRegen` | Y | Y | Y | Y | page |
| `GetPowerRegenForPowerType` | Y | Y | Y | Y | page |
| `GetPrevCompleatedTutorial` | Y | Y | Y | Y | missing |
| `GetPreviewPrimaryTalentTree` | Y | Y | Y | - | missing |
| `GetPreviewTalentPointsSpent` | Y | Y | Y | - | missing |
| `GetPreviousAchievement` | Y | Y | Y | Y | page |
| `GetPreviousArenaSeason` | Y | Y | Y | Y | missing |
| `GetPreviousArenaSeasonUsesTeams` | Y | Y | Y | - | missing |
| `GetPrimarySpecialization` | Y | Y | Y | Y | missing |
| `GetProfessionInfo` | Y | Y | Y | Y | page |
| `GetProfessions` | Y | Y | Y | Y | page |
| `GetProgressText` | Y | Y | Y | Y | page |
| `GetPromotionRank` | Y | Y | Y | Y | missing |
| `GetProtocolTypes` | Y | Y | Y | Y | page |
| `GetPVPDesired` | Y | Y | Y | Y | page |
| `GetPVPGearStatRules` | - | - | - | Y | page |
| `GetPVPLastWeekStats` | Y | Y | Y | - | page |
| `GetPVPLifetimeStats` | Y | Y | Y | Y | page |
| `GetPvpPowerDamage` | Y | Y | Y | Y | page |
| `GetPvpPowerHealing` | Y | Y | Y | Y | page |
| `GetPVPRankInfo` | Y | Y | Y | - | page |
| `GetPVPRankProgress` | Y | Y | Y | - | page |
| `GetPVPRoles` | Y | Y | Y | Y | page |
| `GetPVPSessionStats` | Y | Y | Y | Y | page |
| `GetPvpTalentInfoByID` | - | - | - | Y | page |
| `GetPvpTalentInfoBySpecialization` | - | - | - | Y | missing |
| `GetPvpTalentLink` | - | - | - | Y | missing |
| `GetPVPThisWeekStats` | Y | Y | Y | - | page |
| `GetPVPTimer` | Y | Y | Y | Y | page |
| `GetPVPYesterdayStats` | Y | Y | Y | Y | page |
| `GetQuestBackgroundMaterial` | Y | Y | Y | Y | page |
| `GetQuestCurrencyID` | Y | Y | Y | Y | missing |
| `GetQuestCurrencyInfo` | Y | Y | Y | - | page |
| `GetQuestExpansion` | - | - | - | Y | missing |
| `GetQuestFactionGroup` | Y | Y | Y | Y | page |
| `GetQuestGreenRange` | Y | Y | Y | - | page |
| `GetQuestID` | Y | Y | Y | Y | page |
| `GetQuestIndexForTimer` | Y | Y | Y | - | page |
| `GetQuestIndexForWatch` | Y | Y | Y | - | page |
| `GetQuestItemInfo` | Y | Y | Y | Y | page |
| `GetQuestItemInfoLootType` | - | - | - | Y | missing |
| `GetQuestItemLink` | Y | Y | Y | Y | page |
| `GetQuestLink` | Y | Y | Y | Y | page |
| `GetQuestLogChoiceInfo` | Y | Y | Y | Y | page |
| `GetQuestLogChoiceInfoLootType` | - | - | - | Y | missing |
| `GetQuestLogCompletionText` | Y | Y | Y | Y | missing |
| `GetQuestLogCriteriaSpell` | - | - | - | Y | missing |
| `GetQuestLogGroupNum` | Y | Y | Y | - | page |
| `GetQuestLogIndexByID` | Y | Y | Y | - | page |
| `GetQuestLogIsAutoComplete` | Y | Y | Y | - | missing |
| `GetQuestLogItemDrop` | Y | Y | Y | Y | missing |
| `GetQuestLogItemLink` | Y | Y | Y | Y | page |
| `GetQuestLogLeaderBoard` | Y | Y | Y | Y | page |
| `GetQuestLogPortraitGiver` | Y | Y | Y | - | missing |
| `GetQuestLogPortraitTurnIn` | Y | Y | Y | Y | missing |
| `GetQuestLogPushable` | Y | Y | Y | - | page |
| `GetQuestLogQuestText` | Y | Y | Y | Y | page |
| `GetQuestLogQuestType` | Y | Y | Y | Y | missing |
| `GetQuestLogRequiredMoney` | Y | Y | Y | - | missing |
| `GetQuestLogRewardArenaPoints` | Y | Y | Y | - | missing |
| `GetQuestLogRewardArtifactXP` | - | - | - | Y | missing |
| `GetQuestLogRewardCurrencyInfo` | Y | Y | Y | - | page |
| `GetQuestLogRewardFactionInfo` | - | - | - | Y | missing |
| `GetQuestLogRewardHonor` | Y | Y | Y | Y | missing |
| `GetQuestLogRewardInfo` | Y | Y | Y | Y | page |
| `GetQuestLogRewardMoney` | Y | Y | Y | Y | page |
| `GetQuestLogRewardSkillPoints` | - | - | - | Y | missing |
| `GetQuestLogRewardTalents` | Y | Y | Y | - | missing |
| `GetQuestLogRewardTitle` | Y | Y | Y | Y | missing |
| `GetQuestLogRewardXP` | Y | Y | Y | Y | missing |
| `GetQuestLogSelectedID` | Y | Y | Y | - | missing |
| `GetQuestLogSelection` | Y | Y | Y | - | page |
| `GetQuestLogSpecialItemCooldown` | Y | Y | Y | Y | page |
| `GetQuestLogSpecialItemInfo` | Y | Y | Y | Y | page |
| `GetQuestLogTimeLeft` | Y | Y | Y | Y | page |
| `GetQuestLogTitle` | Y | Y | Y | - | page |
| `GetQuestMoneyToGet` | Y | Y | Y | Y | missing |
| `GetQuestObjectiveInfo` | - | - | - | Y | page |
| `GetQuestPOIBlobCount` | - | - | - | Y | missing |
| `GetQuestPOILeaderBoard` | Y | Y | Y | Y | missing |
| `GetQuestPOIs` | Y | Y | Y | Y | missing |
| `GetQuestPortraitGiver` | Y | Y | Y | Y | missing |
| `GetQuestPortraitTurnIn` | Y | Y | Y | Y | missing |
| `GetQuestProgressBarPercent` | - | - | - | Y | page |
| `GetQuestResetTime` | Y | Y | Y | Y | page |
| `GetQuestReward` | Y | Y | Y | Y | page |
| `GetQuestsCompleted` | Y | Y | Y | - | page |
| `GetQuestSortIndex` | Y | Y | Y | Y | page |
| `GetQuestTagInfo` | Y | Y | Y | - | page |
| `GetQuestText` | Y | Y | Y | Y | missing |
| `GetQuestTimers` | Y | Y | Y | - | page |
| `GetQuestUiMapID` | Y | Y | Y | Y | missing |
| `GetQuestWatchIndex` | Y | Y | Y | - | missing |
| `GetQuestWatchInfo` | Y | Y | Y | - | missing |
| `GetRaidDifficultyID` | Y | Y | Y | Y | page |
| `GetRaidProfileFlattenedOptions` | Y | Y | Y | Y | missing |
| `GetRaidProfileName` | Y | Y | Y | Y | missing |
| `GetRaidProfileOption` | Y | Y | Y | Y | missing |
| `GetRaidProfileSavedPosition` | Y | Y | Y | Y | missing |
| `GetRaidRosterInfo` | Y | Y | Y | Y | page |
| `GetRaidTargetIndex` | Y | Y | Y | Y | page |
| `GetRandomDungeonBestChoice` | Y | Y | Y | Y | missing |
| `GetRandomScenarioBestChoice` | Y | Y | Y | Y | missing |
| `GetRandomScenarioInfo` | Y | Y | Y | Y | missing |
| `GetRangedCritChance` | Y | Y | Y | Y | page |
| `GetRangedHaste` | Y | Y | Y | Y | page |
| `GetRatedBattleGroundInfo` | Y | Y | Y | Y | missing |
| `GetReadyCheckStatus` | Y | Y | Y | Y | missing |
| `GetReadyCheckTimeLeft` | Y | Y | Y | Y | missing |
| `GetRealmID` | Y | Y | Y | Y | page |
| `GetRealmName` | Y | Y | Y | Y | page |
| `GetRealZoneText` | Y | Y | Y | Y | page |
| `GetReleaseTimeRemaining` | Y | Y | Y | Y | page |
| `GetRepairAllCost` | Y | Y | Y | Y | page |
| `GetResSicknessDuration` | Y | Y | Y | Y | page |
| `GetRestrictedAccountData` | Y | Y | Y | Y | page |
| `GetRestState` | Y | Y | Y | Y | page |
| `GetRewardArenaPoints` | Y | Y | Y | - | missing |
| `GetRewardArtifactXP` | - | - | - | Y | missing |
| `GetRewardHonor` | Y | Y | Y | Y | missing |
| `GetRewardMoney` | Y | Y | Y | Y | missing |
| `GetRewardNumSkillUps` | - | - | - | Y | missing |
| `GetRewardPackArtifactPower` | - | - | - | Y | missing |
| `GetRewardPackCurrencies` | - | - | - | Y | missing |
| `GetRewardPackItems` | - | - | - | Y | missing |
| `GetRewardPackMoney` | - | - | - | Y | missing |
| `GetRewardPackTitle` | - | - | - | Y | missing |
| `GetRewardPackTitleName` | - | - | - | Y | missing |
| `GetRewardSkillLineID` | - | - | - | Y | missing |
| `GetRewardSkillPoints` | - | - | - | Y | missing |
| `GetRewardTalentPoints` | Y | Y | Y | - | missing |
| `GetRewardText` | Y | Y | Y | Y | page |
| `GetRewardTitle` | Y | Y | Y | Y | missing |
| `GetRewardXP` | Y | Y | Y | Y | page |
| `GetRFDungeonInfo` | Y | Y | Y | Y | page |
| `GetRuneCooldown` | Y | Y | Y | Y | page |
| `GetRuneCount` | - | - | - | Y | page |
| `GetRuneType` | Y | Y | Y | - | page |
| `GetRunningMacro` | Y | Y | Y | Y | missing |
| `GetRunningMacroButton` | Y | Y | Y | Y | missing |
| `GetSavedInstanceChatLink` | Y | Y | Y | Y | page |
| `GetSavedInstanceEncounterInfo` | Y | Y | Y | Y | page |
| `GetSavedInstanceInfo` | Y | Y | Y | Y | page |
| `GetSavedWorldBossInfo` | Y | Y | Y | Y | page |
| `GetScenariosChoiceOrder` | Y | Y | Y | Y | page |
| `GetScreenDPIScale` | Y | Y | Y | Y | page |
| `GetScreenHeight` | Y | Y | Y | Y | page |
| `GetScreenWidth` | Y | Y | Y | Y | page |
| `GetScriptCPUUsage` | Y | Y | Y | Y | page |
| `GetSecondsUntilParentalControlsKick` | Y | Y | Y | Y | page |
| `GetSelectedArtifactInfo` | - | - | Y | Y | page |
| `GetSelectedAuctionItem` | Y | Y | Y | - | missing |
| `GetSelectedDisplayChannel` | Y | Y | Y | Y | missing |
| `GetSelectedFaction` | Y | Y | Y | - | missing |
| `GetSelectedGlyphSpellIndex` | - | - | Y | - | page |
| `GetSelectedSkill` | Y | Y | Y | - | page |
| `GetSelectedStablePet` | Y | Y | Y | - | page |
| `GetSelectedWarGameType` | Y | Y | Y | Y | missing |
| `GetSendMailCOD` | Y | Y | Y | Y | page |
| `GetSendMailItem` | Y | Y | Y | Y | page |
| `GetSendMailItemLink` | Y | Y | Y | Y | page |
| `GetSendMailMoney` | Y | Y | Y | Y | missing |
| `GetSendMailPrice` | Y | Y | Y | Y | page |
| `GetServerExpansionLevel` | Y | Y | Y | Y | page |
| `GetServerTime` | Y | Y | Y | Y | page |
| `GetSessionTime` | Y | Y | Y | Y | page |
| `GetShapeshiftForm` | Y | Y | Y | Y | page |
| `GetShapeshiftFormCooldown` | Y | Y | Y | Y | page |
| `GetShapeshiftFormID` | Y | Y | Y | Y | page |
| `GetShapeshiftFormInfo` | Y | Y | Y | Y | page |
| `GetSheathState` | Y | Y | Y | Y | page |
| `GetShieldBlock` | Y | Y | Y | Y | page |
| `GetSkillLineInfo` | Y | Y | Y | - | page |
| `GetSoundEntryCount` | Y | Y | Y | Y | page |
| `GetSourceLocation` | Y | Y | Y | Y | page |
| `GetSpecializationInfoByID` | Y | Y | Y | Y | page |
| `GetSpecializationInfoForClassID` | Y | Y | Y | Y | page |
| `GetSpecializationInfoForSpecID` | Y | Y | Y | Y | page |
| `GetSpecializationNameForSpecID` | Y | Y | Y | Y | page |
| `GetSpecializationRole` | Y | Y | Y | Y | page |
| `GetSpecializationRoleByID` | Y | Y | Y | Y | page |
| `GetSpecializationRoleEnum` | Y | Y | Y | Y | missing |
| `GetSpecializationRoleEnumByID` | Y | Y | Y | Y | missing |
| `GetSpecializationSpells` | Y | Y | Y | Y | page |
| `GetSpecializationSystem` | Y | Y | - | Y | page |
| `GetSpecsForSpell` | Y | Y | Y | Y | missing |
| `GetSpeed` | - | - | - | Y | page |
| `GetSpellAutocast` | Y | Y | Y | - | page |
| `GetSpellAvailableLevel` | Y | Y | Y | - | missing |
| `GetSpellBaseCooldown` | Y | Y | Y | Y | page |
| `GetSpellBonusDamage` | Y | Y | Y | Y | page |
| `GetSpellBonusHealing` | Y | Y | Y | Y | page |
| `GetSpellBookItemInfo` | Y | Y | Y | - | page |
| `GetSpellBookItemName` | Y | Y | Y | - | page |
| `GetSpellBookItemTexture` | Y | Y | Y | - | page |
| `GetSpellCharges` | Y | Y | Y | - | page |
| `GetSpellConfirmationPromptsInfo` | Y | Y | Y | Y | missing |
| `GetSpellCooldown` | Y | Y | Y | - | page |
| `GetSpellCount` | Y | Y | Y | - | page |
| `GetSpellCritChance` | Y | Y | Y | Y | page |
| `GetSpellCritChanceFromIntellect` | Y | Y | Y | - | missing |
| `GetSpellDescription` | Y | Y | Y | - | page |
| `GetSpellHitModifier` | Y | Y | Y | Y | page |
| `GetSpellInfo` | Y | Y | Y | - | page |
| `GetSpellLevelLearned` | Y | Y | Y | - | page |
| `GetSpellLink` | Y | Y | Y | - | page |
| `GetSpellLossOfControlCooldown` | Y | Y | Y | - | page |
| `GetSpellPenetration` | Y | Y | Y | Y | page |
| `GetSpellPowerCost` | Y | Y | Y | - | page |
| `GetSpellRank` | Y | Y | Y | - | missing |
| `GetSpellsForCharacterUpgradeTier` | - | - | - | Y | missing |
| `GetSpellSubtext` | Y | Y | Y | - | missing |
| `GetSpellTabInfo` | Y | Y | Y | - | page |
| `GetSpellTexture` | Y | Y | Y | - | page |
| `GetSpellTradeSkillLink` | Y | Y | Y | - | missing |
| `GetStablePetFoodTypes` | Y | Y | Y | - | page |
| `GetStablePetInfo` | Y | Y | Y | - | page |
| `GetStatistic` | Y | Y | Y | Y | page |
| `GetStatisticsCategoryList` | Y | Y | Y | Y | page |
| `GetStringFromModifiers` | Y | Y | Y | Y | page |
| `GetSturdiness` | - | - | - | Y | page |
| `GetSubZoneText` | Y | Y | Y | Y | page |
| `GetSuggestedGroupNum` | Y | Y | Y | - | missing |
| `GetSuggestedGroupSize` | - | - | - | Y | missing |
| `GetSuperTrackedQuestID` | Y | Y | Y | - | missing |
| `GetTabardCreationCost` | Y | Y | Y | Y | missing |
| `GetTabardInfo` | Y | Y | Y | Y | missing |
| `GetTalentClearInfo` | Y | Y | Y | - | page |
| `GetTalentGroupRole` | Y | Y | Y | - | page |
| `GetTalentInfoByID` | Y | Y | Y | Y | missing |
| `GetTalentInfoBySpecialization` | - | - | - | Y | missing |
| `GetTalentLink` | Y | Y | Y | Y | missing |
| `GetTalentPrereqs` | Y | Y | Y | - | page |
| `GetTalentTierInfo` | Y | Y | Y | Y | page |
| `GetTalentTreeEarlySpells` | Y | Y | Y | - | missing |
| `GetTalentTreeRoles` | Y | Y | Y | - | page |
| `GetTargetTradeCurrency` | - | - | - | Y | missing |
| `GetTargetTradeMoney` | Y | Y | Y | Y | page |
| `GetTaskInfo` | - | - | - | Y | page |
| `GetTaskPOIs` | - | - | - | Y | missing |
| `GetTasksTable` | - | - | - | Y | missing |
| `GetTaxiBenchmarkMode` | Y | Y | Y | Y | page |
| `GetTaxiMapID` | Y | Y | Y | Y | page |
| `GetText` | Y | Y | Y | Y | page |
| `GetThreatStatusColor` | Y | Y | Y | Y | page |
| `GetTickTime` | Y | Y | Y | Y | page |
| `GetTime` | Y | Y | Y | Y | page |
| `GetTimePreciseSec` | Y | Y | Y | Y | page |
| `GetTitleName` | Y | Y | Y | Y | page |
| `GetTitleText` | Y | Y | Y | Y | page |
| `GetTotalAchievementPoints` | Y | Y | Y | Y | page |
| `GetTotemCannotDismiss` | Y | Y | Y | Y | page |
| `GetTotemDuration` | Y | Y | Y | Y | page |
| `GetTotemInfo` | Y | Y | Y | Y | page |
| `GetTotemTimeLeft` | Y | Y | Y | Y | page |
| `GetTrackedAchievements` | Y | Y | Y | - | page |
| `GetTrackingTexture` | Y | Y | Y | - | page |
| `GetTradePlayerItemInfo` | Y | Y | Y | Y | page |
| `GetTradePlayerItemLink` | Y | Y | Y | Y | page |
| `GetTradeSkillCooldown` | Y | Y | Y | - | missing |
| `GetTradeSkillDescription` | Y | Y | Y | - | page |
| `GetTradeSkillIcon` | Y | Y | Y | - | missing |
| `GetTradeSkillInfo` | Y | Y | Y | - | page |
| `GetTradeSkillInvSlotFilter` | Y | Y | Y | - | page |
| `GetTradeSkillInvSlots` | Y | Y | Y | - | page |
| `GetTradeSkillItemLevelFilter` | Y | Y | Y | - | missing |
| `GetTradeSkillItemLink` | Y | Y | Y | - | page |
| `GetTradeSkillItemNameFilter` | Y | Y | Y | - | missing |
| `GetTradeSkillItemStats` | Y | Y | Y | - | page |
| `GetTradeSkillLine` | Y | Y | Y | - | page |
| `GetTradeSkillListLink` | Y | Y | Y | - | page |
| `GetTradeSkillNumMade` | Y | Y | Y | - | page |
| `GetTradeSkillNumReagents` | Y | Y | Y | - | page |
| `GetTradeSkillReagentInfo` | Y | Y | Y | - | page |
| `GetTradeSkillReagentItemLink` | Y | Y | Y | - | page |
| `GetTradeSkillRecipeLink` | Y | Y | Y | - | page |
| `GetTradeskillRepeatCount` | Y | Y | Y | - | page |
| `GetTradeSkillSelectionIndex` | Y | Y | Y | - | page |
| `GetTradeSkillSubClasses` | Y | Y | Y | - | page |
| `GetTradeSkillSubClassFilter` | Y | Y | Y | - | page |
| `GetTradeSkillTools` | Y | Y | Y | - | page |
| `GetTradeTargetItemInfo` | Y | Y | Y | Y | page |
| `GetTradeTargetItemLink` | Y | Y | Y | Y | page |
| `GetTrainerGreetingText` | Y | Y | Y | Y | page |
| `GetTrainerSelectionIndex` | Y | Y | Y | Y | page |
| `GetTrainerServiceAbilityReq` | Y | Y | Y | Y | page |
| `GetTrainerServiceCost` | Y | Y | Y | Y | page |
| `GetTrainerServiceDescription` | Y | Y | Y | Y | page |
| `GetTrainerServiceIcon` | Y | Y | Y | Y | page |
| `GetTrainerServiceInfo` | Y | Y | Y | Y | page |
| `GetTrainerServiceItemLink` | Y | Y | Y | Y | page |
| `GetTrainerServiceLevelReq` | Y | Y | Y | Y | page |
| `GetTrainerServiceNumAbilityReq` | Y | Y | Y | Y | missing |
| `GetTrainerServiceSkillLine` | Y | Y | Y | Y | page |
| `GetTrainerServiceSkillReq` | Y | Y | Y | Y | page |
| `GetTrainerServiceStepIndex` | Y | Y | Y | Y | missing |
| `GetTrainerServiceTypeFilter` | Y | Y | Y | Y | page |
| `GetTrainerTradeskillRankValues` | Y | Y | Y | Y | missing |
| `GetTreasurePickerItemInfo` | - | - | - | Y | missing |
| `GetTutorialsEnabled` | Y | Y | Y | Y | missing |
| `GetUICameraInfo` | Y | Y | Y | Y | page |
| `GetUITextureKitInfo` | Y | Y | Y | - | missing |
| `GetUnitChargedPowerPoints` | - | - | - | Y | page |
| `GetUnitEmpowerHoldAtMaxTime` | Y | Y | Y | Y | page |
| `GetUnitEmpowerMinHoldTime` | Y | Y | Y | Y | page |
| `GetUnitEmpowerStageDuration` | Y | Y | Y | Y | page |
| `GetUnitHealthModifier` | Y | Y | Y | Y | page |
| `GetUnitHealthRegenRateFromSpirit` | Y | Y | Y | - | missing |
| `GetUnitManaRegenRateFromSpirit` | Y | Y | Y | - | missing |
| `GetUnitMaxHealthModifier` | Y | Y | Y | Y | page |
| `GetUnitPowerBarInfo` | Y | Y | Y | Y | page |
| `GetUnitPowerBarInfoByID` | Y | Y | Y | Y | page |
| `GetUnitPowerBarStrings` | Y | Y | Y | Y | page |
| `GetUnitPowerBarStringsByID` | Y | Y | Y | Y | page |
| `GetUnitPowerBarTextureInfo` | Y | Y | Y | Y | page |
| `GetUnitPowerBarTextureInfoByID` | Y | Y | Y | Y | page |
| `GetUnitPowerModifier` | Y | Y | Y | Y | page |
| `GetUnitSpeed` | Y | Y | Y | Y | page |
| `GetUnitTotalModifiedMaxHealthPercent` | Y | Y | Y | Y | page |
| `GetUnspentTalentPoints` | Y | Y | Y | - | page |
| `GetUpgradeExpansionLevel` | - | - | - | Y | page |
| `GetVehicleUIIndicator` | Y | Y | Y | Y | page |
| `GetVehicleUIIndicatorSeat` | Y | Y | Y | Y | page |
| `GetVersatilityBonus` | - | - | - | Y | page |
| `GetVideoCaps` | Y | Y | Y | Y | missing |
| `GetWarGameQueueStatus` | Y | Y | Y | Y | missing |
| `GetWarGameTypeInfo` | Y | Y | Y | Y | missing |
| `GetWeaponEnchantInfo` | Y | Y | Y | - | page |
| `GetWebTicket` | Y | Y | Y | Y | page |
| `GetWorldElapsedTime` | Y | Y | Y | Y | page |
| `GetWorldElapsedTimers` | Y | Y | Y | Y | missing |
| `GetWorldMapActionButtonSpellInfo` | - | - | - | Y | missing |
| `GetWorldPVPQueueMapName` | Y | Y | Y | - | missing |
| `GetWorldPVPQueueStatus` | - | - | Y | Y | page |
| `GetXPExhaustion` | Y | Y | Y | Y | page |
| `GetZoneText` | Y | Y | Y | Y | page |
| `GiveMasterLoot` | Y | Y | Y | Y | page |
| `GlyphMatchesSocket` | - | - | Y | - | page |
| `gmatch` | Y | Y | Y | Y | missing |
| `GMEuropaBugsEnabled` | Y | Y | Y | Y | missing |
| `GMEuropaComplaintsEnabled` | Y | Y | Y | Y | missing |
| `GMEuropaSuggestionsEnabled` | Y | Y | Y | Y | missing |
| `GMEuropaTicketsEnabled` | Y | Y | Y | Y | missing |
| `GMItemRestorationButtonEnabled` | Y | Y | Y | Y | missing |
| `GMQuickTicketSystemEnabled` | Y | Y | Y | Y | missing |
| `GMQuickTicketSystemThrottled` | Y | Y | Y | Y | missing |
| `GMReportLag` | Y | Y | Y | Y | missing |
| `GMRequestPlayerInfo` | Y | Y | Y | Y | page |
| `GMResponseResolve` | Y | Y | Y | Y | missing |
| `GMSubmitBug` | Y | Y | Y | - | missing |
| `GMSubmitSuggestion` | Y | Y | Y | - | missing |
| `GMSurveyAnswer` | Y | Y | Y | Y | missing |
| `GMSurveyAnswerSubmit` | Y | Y | Y | Y | missing |
| `GMSurveyCommentSubmit` | Y | Y | Y | Y | missing |
| `GMSurveyNumAnswers` | Y | Y | Y | Y | missing |
| `GMSurveyQuestion` | Y | Y | Y | Y | page |
| `GMSurveySubmit` | Y | Y | Y | Y | missing |
| `GroupHasOfflineMember` | Y | Y | Y | Y | missing |
| `gsub` | Y | Y | Y | Y | missing |
| `GuildControlAddRank` | Y | Y | Y | Y | missing |
| `GuildControlDelRank` | Y | Y | Y | Y | page |
| `GuildControlGetAllowedShifts` | Y | Y | Y | Y | missing |
| `GuildControlGetNumRanks` | Y | Y | Y | Y | missing |
| `GuildControlGetRank` | Y | Y | Y | Y | missing |
| `GuildControlGetRankName` | Y | Y | Y | Y | page |
| `GuildControlSaveRank` | Y | Y | Y | Y | page |
| `GuildControlSetRank` | Y | Y | Y | Y | page |
| `GuildControlSetRankFlag` | Y | Y | Y | Y | page |
| `GuildControlShiftRankDown` | Y | Y | Y | Y | missing |
| `GuildControlShiftRankUp` | Y | Y | Y | Y | missing |
| `GuildInfo` | Y | Y | Y | Y | page |
| `GuildMasterAbsent` | Y | Y | Y | Y | missing |
| `GuildNewsSetSticky` | Y | Y | Y | Y | missing |
| `GuildNewsSort` | Y | Y | Y | Y | missing |
| `HandleAtlasMemberCommand` | Y | Y | Y | Y | missing |
| `hasanysecretvalues` | Y | Y | Y | Y | page |
| `HasAPEffectsSpellPower` | - | - | - | Y | page |
| `HasArtifactEquipped` | - | - | - | Y | missing |
| `HasAttachedGlyph` | - | - | Y | Y | missing |
| `HasCompletedAnyAchievement` | Y | Y | Y | Y | missing |
| `HasDualWieldPenalty` | Y | Y | Y | Y | page |
| `HasFilledPetition` | Y | Y | Y | - | missing |
| `HasFullControl` | Y | Y | Y | Y | page |
| `HasIgnoreDualWieldWeapon` | Y | Y | Y | Y | page |
| `HasInboxItem` | Y | Y | Y | Y | missing |
| `HasInspectHonorData` | Y | Y | Y | - | page |
| `HasKey` | Y | Y | Y | Y | page |
| `HasLFGRestrictions` | Y | Y | Y | Y | page |
| `HasLoadedCUFProfiles` | Y | Y | Y | Y | missing |
| `HasLootSpecializations` | Y | Y | Y | Y | page |
| `HasNewMail` | Y | Y | Y | Y | missing |
| `HasNoReleaseAura` | Y | Y | Y | Y | page |
| `HasPendingGlyphCast` | - | - | Y | Y | missing |
| `HasPetSpells` | Y | Y | Y | - | page |
| `HasPetUI` | Y | Y | Y | Y | page |
| `HasSendMailItem` | Y | Y | Y | Y | missing |
| `HasSPEffectsAttackPower` | - | - | - | Y | page |
| `HasWandEquipped` | Y | Y | Y | Y | page |
| `HaveQuestData` | Y | Y | Y | Y | missing |
| `HaveQuestRewardData` | Y | Y | Y | Y | missing |
| `HearthAndResurrectFromArea` | Y | Y | Y | Y | missing |
| `HideRepairCursor` | Y | Y | Y | Y | page |
| `HonorSystemEnabled` | Y | Y | Y | - | missing |
| `hooksecurefunc` | Y | Y | Y | Y | page |
| `InActiveBattlefield` | Y | Y | Y | - | page |
| `InboxItemCanDelete` | Y | Y | Y | Y | page |
| `InCinematic` | Y | Y | Y | Y | page |
| `InCombatLockdown` | Y | Y | Y | Y | page |
| `InGuildParty` | Y | Y | Y | Y | page |
| `InitiateRolePoll` | Y | Y | Y | Y | page |
| `InitiateTrade` | Y | Y | Y | Y | page |
| `InRepairMode` | Y | Y | Y | Y | page |
| `ipairs` | Y | Y | Y | Y | page |
| `Is64BitClient` | Y | Y | Y | Y | page |
| `IsAccountSecured` | Y | Y | Y | Y | page |
| `IsAchievementEligible` | Y | Y | Y | Y | page |
| `IsActiveBattlefieldArena` | Y | Y | Y | Y | page |
| `IsActiveQuestLegendary` | Y | Y | Y | - | page |
| `IsActiveQuestTrivial` | Y | Y | Y | Y | missing |
| `IsAdvancedFlyableArea` | - | - | - | Y | page |
| `IsAllowedToUserTeleport` | Y | Y | Y | Y | page |
| `IsAltKeyDown` | Y | Y | Y | Y | page |
| `IsArenaSeasonActive` | Y | Y | Y | - | missing |
| `IsArenaSkirmish` | Y | Y | Y | Y | missing |
| `IsArenaTeamCaptain` | Y | Y | Y | - | missing |
| `IsArtifactCompletionHistoryAvailable` | - | - | Y | Y | page |
| `IsAtStableMaster` | Y | Y | Y | - | page |
| `IsAttackSpell` | Y | Y | Y | - | page |
| `IsAuctionSortReversed` | Y | Y | Y | - | page |
| `IsAutoRepeatSpell` | Y | Y | Y | - | missing |
| `IsAvailableQuestTrivial` | Y | Y | Y | Y | missing |
| `IsBattlefieldArena` | Y | Y | Y | - | missing |
| `IsBetaBuild` | Y | Y | Y | Y | page |
| `IsBindingForGamePad` | Y | Y | Y | Y | missing |
| `IsBNLogin` | Y | Y | Y | Y | missing |
| `IsBreadcrumbQuest` | - | - | - | Y | missing |
| `IsCastingGlyph` | - | - | - | Y | missing |
| `IsCemeterySelectionAvailable` | Y | Y | Y | Y | page |
| `IsChannelModerator` | Y | Y | Y | - | missing |
| `IsChannelOwner` | Y | Y | Y | - | missing |
| `IsCharacterNewlyBoosted` | Y | Y | Y | Y | page |
| `IsChatAFK` | Y | Y | Y | Y | missing |
| `IsChatChannelRaid` | Y | Y | Y | Y | missing |
| `IsChatDND` | Y | Y | Y | Y | missing |
| `IsConsumableSpell` | Y | Y | Y | - | missing |
| `IsControlKeyDown` | Y | Y | Y | Y | page |
| `IsCpuBound` | Y | Y | Y | Y | page |
| `IsCurrentQuestFailed` | Y | Y | Y | Y | missing |
| `IsCurrentSpell` | Y | Y | Y | - | page |
| `IsDebugBuild` | Y | Y | Y | Y | page |
| `IsDemonHunterAvailable` | - | - | - | Y | page |
| `IsDisplayChannelModerator` | Y | Y | Y | Y | missing |
| `IsDisplayChannelOwner` | Y | Y | Y | Y | missing |
| `IsDrivableArea` | - | - | - | Y | page |
| `IsDualWielding` | Y | Y | Y | Y | page |
| `IsEuropeanNumbers` | Y | Y | Y | Y | page |
| `IsEveryoneAssistant` | Y | Y | Y | Y | missing |
| `IsExpansionTrial` | Y | Y | Y | Y | page |
| `IsFactionInactive` | Y | Y | Y | - | page |
| `IsFalling` | Y | Y | Y | Y | page |
| `IsFishingLoot` | Y | Y | Y | Y | page |
| `IsFlyableArea` | Y | Y | Y | Y | page |
| `IsFlying` | Y | Y | Y | Y | page |
| `IsGamePadCursorControlEnabled` | Y | Y | Y | Y | missing |
| `IsGamePadFreelookEnabled` | Y | Y | Y | Y | missing |
| `IsGlyphFlagSet` | - | - | Y | - | page |
| `IsGMClient` | Y | Y | Y | Y | page |
| `IsGraphicsCVarValueSupported` | Y | Y | Y | Y | missing |
| `IsGraphicsSettingValueSupported` | Y | Y | Y | Y | missing |
| `IsGuildLeader` | Y | Y | Y | Y | page |
| `IsGuildMember` | Y | Y | Y | Y | page |
| `IsGuildRankAssignmentAllowed` | Y | Y | Y | Y | missing |
| `IsHarmfulSpell` | Y | Y | Y | - | missing |
| `IsHelpfulSpell` | Y | Y | Y | - | missing |
| `IsInActiveWorldPVP` | Y | Y | Y | Y | missing |
| `IsInArenaTeam` | Y | Y | Y | - | missing |
| `IsInAuthenticatedRank` | Y | Y | Y | Y | missing |
| `IsInCinematicScene` | Y | Y | Y | Y | page |
| `IsIndoors` | Y | Y | Y | Y | page |
| `IsInGlobalEnvironment` | Y | Y | Y | Y | missing |
| `IsInGroup` | Y | Y | Y | Y | page |
| `IsInGuild` | Y | Y | Y | Y | page |
| `IsInGuildGroup` | Y | Y | Y | Y | page |
| `IsInInstance` | Y | Y | Y | Y | page |
| `IsInJailersTower` | - | - | - | Y | page |
| `IsInLFGDungeon` | Y | Y | Y | Y | page |
| `IsInRaid` | Y | Y | Y | Y | page |
| `IsInsane` | - | - | - | Y | page |
| `IsInScenarioGroup` | Y | Y | Y | Y | missing |
| `IsInventoryItemLocked` | Y | Y | Y | Y | page |
| `IsInventoryItemProfessionBag` | Y | Y | Y | Y | missing |
| `IsItemPreferredArmorType` | Y | Y | Y | Y | page |
| `IsJailersTowerLayerTimeLocked` | - | - | - | Y | page |
| `IsKeyDown` | Y | Y | Y | Y | page |
| `IsKeyRingEnabled` | Y | Y | Y | - | missing |
| `IsLeftAltKeyDown` | Y | Y | Y | Y | page |
| `IsLeftControlKeyDown` | Y | Y | Y | Y | page |
| `IsLeftMetaKeyDown` | Y | Y | Y | Y | page |
| `IsLeftShiftKeyDown` | Y | Y | Y | Y | page |
| `IsLegacyDifficulty` | Y | Y | Y | Y | page |
| `IsLFGComplete` | Y | Y | Y | Y | page |
| `IsLFGDungeonJoinable` | Y | Y | Y | Y | page |
| `IsLinuxClient` | Y | Y | Y | Y | page |
| `IsLoggedIn` | Y | Y | Y | Y | page |
| `IsMacClient` | Y | Y | Y | Y | page |
| `IsMasterLooter` | Y | Y | Y | Y | missing |
| `IsMetaKeyDown` | Y | Y | Y | Y | page |
| `IsModifiedClick` | Y | Y | Y | Y | page |
| `IsModifierKeyDown` | Y | Y | Y | Y | page |
| `IsMounted` | Y | Y | Y | Y | page |
| `IsMouseButtonDown` | Y | Y | Y | Y | page |
| `IsMouselooking` | Y | Y | Y | Y | page |
| `IsMovieLocal` | Y | Y | Y | Y | page |
| `IsMoviePlayable` | Y | Y | Y | Y | page |
| `IsMovieReadable` | - | - | - | Y | page |
| `IsOnGroundFloorInJailersTower` | - | - | - | Y | page |
| `IsOnTournamentRealm` | Y | Y | Y | Y | page |
| `IsOutdoors` | Y | Y | Y | Y | page |
| `IsOutlineModeSupported` | Y | Y | Y | Y | missing |
| `IsOutOfBounds` | Y | Y | Y | Y | page |
| `IsPartyLFG` | Y | Y | Y | Y | missing |
| `IsPartyWorldPVP` | Y | Y | Y | Y | missing |
| `IsPassiveSpell` | Y | Y | Y | - | page |
| `IsPendingGlyphRemoval` | - | - | - | Y | missing |
| `IsPetActive` | Y | Y | Y | Y | missing |
| `IsPetAssistAvailable` | Y | Y | Y | - | missing |
| `IsPetAttackAction` | Y | Y | Y | Y | missing |
| `IsPetAttackActive` | Y | Y | Y | Y | page |
| `IsPlayerAttacking` | Y | Y | Y | - | page |
| `IsPlayerInGuildFromGUID` | Y | Y | Y | Y | page |
| `IsPlayerInWorld` | Y | Y | Y | Y | page |
| `IsPlayerMoving` | Y | Y | Y | Y | page |
| `IsPlayerNeutral` | Y | Y | Y | Y | page |
| `IsPublicBuild` | Y | Y | Y | Y | page |
| `IsPublicTestClient` | Y | Y | Y | Y | page |
| `IsPVPTimerRunning` | Y | Y | Y | Y | page |
| `IsQuestCompletable` | Y | Y | Y | Y | page |
| `IsQuestComplete` | Y | Y | Y | - | page |
| `IsQuestHardWatched` | Y | Y | Y | - | missing |
| `IsQuestIDValidSpellTarget` | - | - | - | Y | missing |
| `IsQuestItemHidden` | Y | Y | Y | Y | missing |
| `IsQuestLogSpecialItemInRange` | Y | Y | Y | Y | missing |
| `IsQuestSequenced` | - | - | - | Y | missing |
| `IsQuestWatched` | Y | Y | Y | - | missing |
| `IsRaidMarkerActive` | Y | Y | Y | Y | page |
| `IsRaidMarkerSystemEnabled` | Y | Y | Y | Y | page |
| `IsRangedWeapon` | Y | Y | Y | Y | page |
| `IsRatedBattleground` | Y | Y | Y | - | missing |
| `IsResting` | Y | Y | Y | Y | page |
| `IsRestrictedAccount` | Y | Y | Y | Y | page |
| `IsRightAltKeyDown` | Y | Y | Y | Y | page |
| `IsRightControlKeyDown` | Y | Y | Y | Y | page |
| `IsRightMetaKeyDown` | Y | Y | Y | Y | page |
| `IsRightShiftKeyDown` | Y | Y | Y | Y | page |
| `issecrettable` | Y | Y | Y | Y | page |
| `issecretvalue` | Y | Y | Y | Y | page |
| `issecure` | Y | Y | Y | Y | page |
| `issecurevalue` | Y | Y | Y | Y | page |
| `issecurevariable` | Y | Y | Y | Y | page |
| `IsSelectedSpellBookItem` | Y | Y | Y | Y | missing |
| `IsServerControlledBackfill` | Y | Y | Y | Y | missing |
| `IsShiftKeyDown` | Y | Y | Y | Y | page |
| `IsSpecializationActivateSpell` | - | - | - | Y | missing |
| `IsSpellClassOrSpec` | Y | Y | Y | Y | page |
| `IsSpellHidden` | Y | Y | Y | - | missing |
| `IsSpellInRange` | Y | Y | Y | - | page |
| `IsSpellValidForPendingGlyph` | - | - | Y | Y | missing |
| `IsStealthed` | Y | Y | Y | Y | page |
| `IsStoryQuest` | - | - | - | Y | missing |
| `IsSubmerged` | Y | Y | Y | Y | page |
| `IsSwimming` | Y | Y | Y | Y | page |
| `IsTalentSpell` | Y | Y | Y | - | page |
| `IsTargetLoose` | Y | Y | Y | Y | page |
| `IsTestBuild` | Y | Y | Y | Y | page |
| `IsThreatWarningEnabled` | Y | Y | Y | Y | page |
| `IsTitleKnown` | Y | Y | Y | Y | page |
| `IsTrackedAchievement` | Y | Y | Y | - | page |
| `IsTradeSkillLinked` | Y | Y | Y | - | page |
| `IsTradeskillTrainer` | Y | Y | Y | Y | page |
| `IsTrainerServiceLearnSpell` | Y | Y | Y | - | page |
| `IsTrialAccount` | Y | Y | Y | Y | page |
| `IsTutorialFlagged` | Y | Y | Y | Y | missing |
| `IsUnitModelReadyForUI` | Y | Y | Y | Y | page |
| `IsUnitOnQuest` | Y | Y | Y | - | page |
| `IsUnitOnQuestByQuestID` | Y | Y | Y | - | missing |
| `IsUsableSpell` | Y | Y | Y | - | page |
| `IsUsingFixedTimeStep` | Y | Y | Y | Y | page |
| `IsUsingGamepad` | Y | Y | Y | Y | page |
| `IsUsingLegacyAuctionClient` | Y | Y | Y | - | missing |
| `IsUsingMouse` | Y | Y | Y | Y | page |
| `IsUsingVehicleControls` | Y | Y | Y | Y | missing |
| `IsVehicleAimAngleAdjustable` | - | - | Y | Y | page |
| `IsVehicleAimPowerAdjustable` | - | - | Y | Y | page |
| `IsVeteranTrialAccount` | Y | Y | Y | Y | page |
| `IsWargame` | Y | Y | Y | Y | page |
| `IsWindowsClient` | Y | Y | Y | Y | page |
| `IsXPUserDisabled` | Y | Y | Y | Y | page |
| `ItemAddedToArtifact` | - | - | Y | Y | page |
| `ItemCanTargetGarrisonFollowerAbility` | - | - | - | Y | missing |
| `ItemTextGetCreator` | Y | Y | Y | Y | page |
| `ItemTextGetItem` | Y | Y | Y | Y | page |
| `ItemTextGetMaterial` | Y | Y | Y | Y | page |
| `ItemTextGetPage` | Y | Y | Y | Y | page |
| `ItemTextGetText` | Y | Y | Y | Y | page |
| `ItemTextHasNextPage` | Y | Y | Y | Y | page |
| `ItemTextIsFullPage` | Y | Y | Y | Y | missing |
| `ItemTextNextPage` | Y | Y | Y | Y | page |
| `ItemTextPrevPage` | Y | Y | Y | Y | page |
| `JoinArena` | Y | Y | Y | Y | missing |
| `JoinChannelByName` | Y | Y | Y | Y | page |
| `JoinLFG` | Y | Y | Y | Y | missing |
| `JoinPermanentChannel` | Y | Y | Y | Y | page |
| `JoinRatedBattlefield` | Y | Y | Y | Y | missing |
| `JoinRatedSoloShuffle` | - | - | - | Y | missing |
| `JoinSingleLFG` | Y | Y | Y | Y | missing |
| `JoinSkirmish` | Y | Y | Y | Y | page |
| `JoinTemporaryChannel` | Y | Y | Y | Y | page |
| `JoinWorldPVPQueue` | Y | Y | Y | - | missing |
| `JumpOrAscendStart` | Y | Y | Y | Y | page |
| `KeyRingButtonIDToInvSlotID` | Y | Y | Y | - | page |
| `LaunchURL` | Y | Y | Y | Y | page |
| `ldexp` | Y | Y | Y | Y | missing |
| `LearnPreviewTalents` | Y | Y | Y | - | missing |
| `LearnPvpTalent` | - | - | - | Y | page |
| `LearnPvpTalents` | - | - | - | Y | missing |
| `LearnTalent` | Y | Y | Y | Y | page |
| `LearnTalents` | Y | Y | Y | Y | missing |
| `LeaveBattlefield` | Y | Y | Y | Y | page |
| `LeaveChannelByLocalID` | Y | Y | Y | Y | missing |
| `LeaveChannelByName` | Y | Y | Y | Y | page |
| `LeaveLFG` | Y | Y | Y | Y | missing |
| `LeaveParty` | Y | Y | Y | - | page |
| `LeaveSingleLFG` | Y | Y | Y | Y | missing |
| `LFGTeleport` | Y | Y | Y | Y | page |
| `ListChannelByName` | Y | Y | Y | Y | page |
| `ListChannels` | Y | Y | Y | Y | page |
| `LoadBindings` | Y | Y | Y | Y | page |
| `loadstring` | Y | Y | Y | Y | page |
| `LoadURLIndex` | Y | Y | Y | Y | page |
| `LocalizedClassList` | - | - | - | Y | page |
| `log` | Y | Y | Y | Y | missing |
| `log10` | Y | Y | Y | Y | missing |
| `LoggingChat` | Y | Y | Y | Y | page |
| `LoggingCombat` | Y | Y | Y | Y | page |
| `Logout` | Y | Y | Y | Y | page |
| `LootMoneyNotify` | Y | Y | Y | Y | missing |
| `LootSlot` | Y | Y | Y | Y | page |
| `LootSlotHasItem` | Y | Y | Y | Y | page |
| `MakeModifiers` | Y | Y | Y | Y | page |
| `mapvalues` | Y | Y | Y | Y | page |
| `max` | Y | Y | Y | Y | missing |
| `min` | Y | Y | Y | Y | missing |
| `Mixin` | Y | Y | Y | Y | page |
| `mod` | Y | Y | Y | Y | missing |
| `MouselookStart` | Y | Y | Y | Y | page |
| `MouselookStop` | Y | Y | Y | Y | page |
| `MouseOverrideCinematicDisable` | Y | Y | Y | Y | page |
| `MoveAndSteerStart` | Y | Y | Y | Y | missing |
| `MoveAndSteerStop` | Y | Y | Y | Y | missing |
| `MoveBackwardStart` | Y | Y | Y | Y | page |
| `MoveBackwardStop` | Y | Y | Y | Y | page |
| `MoveForwardStart` | Y | Y | Y | Y | page |
| `MoveForwardStop` | Y | Y | Y | Y | page |
| `MoveViewDownStart` | Y | Y | Y | Y | page |
| `MoveViewDownStop` | Y | Y | Y | Y | page |
| `MoveViewInStart` | Y | Y | Y | Y | page |
| `MoveViewInStop` | Y | Y | Y | Y | page |
| `MoveViewLeftStart` | Y | Y | Y | Y | page |
| `MoveViewLeftStop` | Y | Y | Y | Y | page |
| `MoveViewOutStart` | Y | Y | Y | Y | page |
| `MoveViewOutStop` | Y | Y | Y | Y | page |
| `MoveViewRightStart` | Y | Y | Y | Y | page |
| `MoveViewRightStop` | Y | Y | Y | Y | page |
| `MoveViewUpStart` | Y | Y | Y | Y | page |
| `MoveViewUpStop` | Y | Y | Y | Y | page |
| `MultiSampleAntiAliasingSupported` | Y | Y | Y | Y | missing |
| `MuteSoundFile` | Y | Y | Y | Y | page |
| `NeutralPlayerSelectFaction` | Y | Y | Y | Y | page |
| `newproxy` | Y | Y | Y | Y | page |
| `next` | Y | Y | Y | Y | page |
| `NextView` | Y | Y | Y | Y | missing |
| `NoPlayTime` | Y | Y | Y | Y | page |
| `NotifyInspect` | Y | Y | Y | Y | page |
| `NotWhileDeadError` | Y | Y | Y | Y | page |
| `NumTaxiNodes` | Y | Y | Y | Y | page |
| `OfferPetition` | Y | Y | Y | Y | page |
| `OpeningCinematic` | Y | Y | Y | Y | page |
| `OpenTrainer` | Y | Y | Y | Y | missing |
| `OutageDetected` | Y | Y | Y | Y | page |
| `pairs` | Y | Y | Y | Y | page |
| `PartialPlayTime` | Y | Y | Y | Y | page |
| `PartyLFGStartBackfill` | Y | Y | Y | Y | missing |
| `pcall` | Y | Y | Y | Y | page |
| `pcallwithenv` | Y | Y | Y | Y | page |
| `PetAbandon` | Y | Y | Y | - | page |
| `PetAggressiveMode` | Y | Y | Y | Y | page |
| `PetAttack` | Y | Y | Y | Y | page |
| `PetCanBeAbandoned` | Y | Y | Y | Y | page |
| `PetCanBeDismissed` | Y | Y | Y | Y | missing |
| `PetCanBeRenamed` | Y | Y | Y | - | page |
| `PetDefensiveAssistMode` | - | - | - | Y | page |
| `PetDefensiveMode` | Y | Y | Y | Y | page |
| `PetDismiss` | Y | Y | Y | Y | page |
| `PetFollow` | Y | Y | Y | Y | page |
| `PetHasActionBar` | Y | Y | Y | Y | page |
| `PetHasSpellbook` | Y | Y | Y | Y | missing |
| `PetMoveTo` | Y | Y | Y | Y | missing |
| `PetPassiveMode` | Y | Y | Y | Y | page |
| `PetRename` | Y | Y | Y | - | page |
| `PetStopAttack` | Y | Y | Y | Y | page |
| `PetUsesPetFrame` | Y | Y | Y | Y | missing |
| `PetWait` | Y | Y | Y | Y | page |
| `PickupAction` | Y | Y | Y | Y | page |
| `PickupBagFromSlot` | Y | Y | Y | Y | page |
| `PickupCompanion` | Y | Y | Y | Y | page |
| `PickupCurrency` | Y | Y | Y | - | page |
| `PickupGuildBankItem` | Y | Y | Y | Y | missing |
| `PickupGuildBankMoney` | Y | Y | Y | Y | missing |
| `PickupInventoryItem` | Y | Y | Y | Y | page |
| `PickupMacro` | Y | Y | Y | Y | page |
| `PickupMerchantItem` | Y | Y | Y | Y | page |
| `PickupPetAction` | Y | Y | Y | Y | page |
| `PickupPetSpell` | Y | Y | Y | Y | page |
| `PickupPlayerMoney` | Y | Y | Y | Y | page |
| `PickupPvpTalent` | - | - | - | Y | missing |
| `PickupSpell` | Y | Y | Y | - | page |
| `PickupSpellBookItem` | Y | Y | Y | - | page |
| `PickupStablePet` | Y | Y | Y | - | page |
| `PickupTalent` | Y | Y | Y | Y | missing |
| `PitchDownStart` | Y | Y | Y | Y | missing |
| `PitchDownStop` | Y | Y | Y | Y | missing |
| `PitchUpStart` | Y | Y | Y | Y | missing |
| `PitchUpStop` | Y | Y | Y | Y | missing |
| `PlaceAction` | Y | Y | Y | Y | page |
| `PlaceAuctionBid` | Y | Y | Y | - | page |
| `PlaceGlyphInSocket` | - | - | Y | - | page |
| `PlaceRaidMarker` | Y | Y | Y | Y | page |
| `PlayAutoAcceptQuestSound` | - | - | - | Y | missing |
| `PlayerCanTeleport` | Y | Y | Y | Y | page |
| `PlayerEffectiveAttackPower` | Y | Y | Y | Y | page |
| `PlayerGetTimerunningSeasonID` | - | - | - | Y | page |
| `PlayerHasToy` | Y | Y | Y | Y | page |
| `PlayerIsInCombat` | Y | Y | Y | Y | page |
| `PlayerIsPVPInactive` | Y | Y | Y | Y | page |
| `PlayerIsSpellTarget` | Y | Y | Y | Y | page |
| `PlayerIsTimerunning` | Y | Y | Y | Y | page |
| `PlayerVehicleHasComboPoints` | - | - | - | Y | page |
| `PlayMusic` | Y | Y | Y | Y | page |
| `PlaySound` | Y | Y | Y | Y | page |
| `PlaySoundFile` | Y | Y | Y | Y | page |
| `PortGraveyard` | Y | Y | Y | Y | page |
| `PostAuction` | Y | Y | Y | - | page |
| `PreloadMovie` | Y | Y | Y | Y | page |
| `PrevView` | Y | Y | Y | Y | missing |
| `ProcessExceptionClient` | Y | Y | Y | Y | page |
| `ProcessQuestLogRewardFactions` | - | - | - | Y | missing |
| `PurchaseSlot` | Y | Y | Y | - | missing |
| `PutItemInBackpack` | Y | Y | Y | Y | page |
| `PutItemInBag` | Y | Y | Y | Y | page |
| `QueryAuctionItems` | Y | Y | Y | - | page |
| `QueryGuildBankLog` | Y | Y | Y | Y | missing |
| `QueryGuildBankTab` | Y | Y | Y | Y | missing |
| `QueryGuildBankText` | Y | Y | Y | Y | missing |
| `QueryGuildEventLog` | Y | Y | Y | Y | missing |
| `QueryGuildNews` | Y | Y | Y | Y | missing |
| `QueryGuildRecipes` | Y | Y | Y | Y | missing |
| `QueryWorldCountdownTimer` | Y | Y | Y | - | missing |
| `QuestChooseRewardError` | Y | Y | Y | Y | page |
| `QuestFlagsPVP` | Y | Y | Y | Y | missing |
| `QuestGetAutoAccept` | - | - | - | Y | page |
| `QuestGetAutoLaunched` | - | - | - | Y | missing |
| `QuestHasPOIInfo` | - | - | - | Y | missing |
| `QuestIsDaily` | Y | Y | Y | Y | page |
| `QuestIsFromAdventureMap` | - | - | - | Y | missing |
| `QuestIsFromAreaTrigger` | - | - | - | Y | page |
| `QuestIsWeekly` | - | - | - | Y | page |
| `QuestLogPushQuest` | Y | Y | Y | Y | page |
| `QuestLogRewardHasTreasurePicker` | - | - | - | Y | missing |
| `QuestLogShouldShowPortrait` | Y | Y | Y | Y | missing |
| `QuestMapUpdateAllQuests` | Y | Y | Y | Y | missing |
| `QuestPOIGetIconInfo` | Y | Y | Y | - | page |
| `QuestPOIGetQuestIDByIndex` | Y | Y | Y | - | missing |
| `QuestPOIGetQuestIDByVisibleIndex` | Y | Y | Y | - | missing |
| `QuestPOIUpdateIcons` | Y | Y | Y | Y | missing |
| `Quit` | Y | Y | Y | Y | page |
| `rad` | Y | Y | Y | Y | missing |
| `RaidProfileExists` | Y | Y | Y | Y | missing |
| `RaidProfileHasUnsavedChanges` | Y | Y | Y | Y | missing |
| `random` | Y | Y | Y | Y | missing |
| `RandomRoll` | Y | Y | Y | Y | page |
| `rawequal` | Y | Y | Y | Y | missing |
| `rawget` | Y | Y | Y | Y | missing |
| `rawset` | Y | Y | Y | Y | page |
| `RedockChatWindows` | Y | Y | Y | Y | missing |
| `RefreshLFGList` | Y | Y | Y | Y | missing |
| `RegisterEventCallback` | Y | Y | Y | Y | page |
| `RegisterStaticConstants` | Y | Y | Y | Y | missing |
| `RegisterUnitEventCallback` | Y | Y | Y | Y | page |
| `RejectProposal` | Y | Y | Y | Y | page |
| `ReleaseAction` | - | - | - | Y | missing |
| `RemoveAutoQuestPopUp` | Y | Y | Y | Y | missing |
| `RemoveChatWindowChannel` | Y | Y | Y | Y | page |
| `RemoveChatWindowMessages` | Y | Y | Y | Y | page |
| `RemoveGlyphFromSocket` | - | - | Y | - | page |
| `RemoveItemFromArtifact` | - | - | Y | Y | page |
| `RemovePvpTalent` | - | - | - | Y | missing |
| `RemoveQuestWatch` | Y | Y | Y | - | page |
| `RemoveRaidTargets` | Y | Y | Y | Y | page |
| `RemoveTalent` | Y | Y | Y | Y | missing |
| `RemoveTrackedAchievement` | Y | Y | Y | - | page |
| `RenamePetition` | Y | Y | Y | Y | page |
| `RepairAllItems` | Y | Y | Y | Y | page |
| `ReplaceGuildMaster` | Y | Y | Y | Y | page |
| `RepopMe` | Y | Y | Y | Y | page |
| `ReportBug` | Y | Y | Y | Y | page |
| `ReportPlayerIsPVPAFK` | Y | Y | Y | Y | page |
| `ReportSuggestion` | Y | Y | Y | Y | page |
| `RequestBattlefieldScoreData` | Y | Y | Y | Y | page |
| `RequestBattlegroundInstanceInfo` | Y | Y | Y | Y | page |
| `RequestBottomLeftActionBar` | - | - | - | Y | missing |
| `RequestGuildChallengeInfo` | Y | Y | Y | Y | missing |
| `RequestGuildPartyState` | Y | Y | Y | Y | missing |
| `RequestGuildRewards` | Y | Y | Y | Y | missing |
| `RequestInspectHonorData` | Y | Y | Y | - | page |
| `RequestInviteFromUnit` | Y | Y | Y | - | page |
| `RequestLFDPartyLockInfo` | Y | Y | Y | Y | missing |
| `RequestLFDPlayerLockInfo` | Y | Y | Y | Y | missing |
| `RequestPVPOptionsEnabled` | Y | Y | Y | Y | missing |
| `RequestPVPRewards` | Y | Y | Y | Y | missing |
| `RequestRaidInfo` | Y | Y | Y | Y | page |
| `RequestRandomBattlegroundInstanceInfo` | Y | Y | Y | Y | page |
| `RequestRatedInfo` | Y | Y | Y | Y | page |
| `RequestTimePlayed` | Y | Y | Y | Y | page |
| `RequeueSkirmish` | Y | Y | Y | Y | missing |
| `ResetChatColors` | Y | Y | Y | Y | missing |
| `ResetChatWindows` | Y | Y | Y | Y | missing |
| `ResetCPUUsage` | Y | Y | Y | Y | page |
| `ResetCursor` | Y | Y | Y | Y | page |
| `ResetGroupPreviewTalentPoints` | Y | Y | Y | - | missing |
| `ResetInstances` | Y | Y | Y | Y | page |
| `ResetPreviewTalentPoints` | Y | Y | Y | - | missing |
| `ResetSetMerchantFilter` | - | - | - | Y | missing |
| `ResetTutorials` | Y | Y | Y | Y | page |
| `ResetView` | Y | Y | Y | Y | missing |
| `ResistancePercent` | Y | Y | Y | Y | page |
| `RespondInstanceLock` | Y | Y | Y | Y | page |
| `RespondMailLockSendItem` | Y | Y | Y | Y | missing |
| `RespondToInviteConfirmation` | Y | Y | Y | Y | missing |
| `RestartGx` | Y | Y | Y | Y | page |
| `RestoreRaidProfileFromCopy` | Y | Y | Y | Y | missing |
| `ResurrectGetOfferer` | Y | Y | Y | Y | page |
| `ResurrectHasSickness` | Y | Y | Y | Y | page |
| `ResurrectHasTimer` | Y | Y | Y | Y | page |
| `RetrieveCorpse` | Y | Y | Y | Y | page |
| `ReturnInboxItem` | Y | Y | Y | Y | missing |
| `RollOnLoot` | Y | Y | Y | Y | page |
| `RunBinding` | Y | Y | Y | Y | page |
| `RunMacro` | Y | Y | Y | Y | page |
| `RunScript` | Y | Y | Y | Y | page |
| `SaveBindings` | Y | Y | Y | Y | page |
| `SaveRaidProfileCopy` | Y | Y | Y | Y | missing |
| `SaveView` | Y | Y | Y | Y | page |
| `Screenshot` | Y | Y | Y | Y | page |
| `scrub` | Y | Y | Y | Y | page |
| `scrubsecretvalues` | Y | Y | Y | Y | page |
| `SearchLFGGetEncounterResults` | Y | Y | Y | Y | missing |
| `SearchLFGGetJoinedID` | Y | Y | Y | Y | missing |
| `SearchLFGGetNumResults` | Y | Y | Y | Y | page |
| `SearchLFGGetPartyResults` | Y | Y | Y | Y | page |
| `SearchLFGGetResults` | Y | Y | Y | Y | page |
| `SearchLFGJoin` | Y | Y | Y | Y | page |
| `SearchLFGLeave` | Y | Y | Y | Y | missing |
| `SearchLFGSort` | Y | Y | Y | Y | missing |
| `secretwrap` | Y | Y | Y | Y | page |
| `securecall` | Y | Y | Y | Y | page |
| `securecallfunction` | Y | Y | Y | Y | page |
| `securecallmethod` | Y | Y | Y | Y | page |
| `SecureCmdOptionParse` | Y | Y | Y | Y | page |
| `securecopy` | - | - | - | Y | page |
| `secureexecuterange` | Y | Y | Y | Y | page |
| `select` | Y | Y | Y | Y | page |
| `SelectActiveQuest` | Y | Y | Y | Y | missing |
| `SelectAvailableQuest` | Y | Y | Y | Y | missing |
| `SelectCraft` | Y | Y | Y | - | missing |
| `SelectedRealmName` | Y | Y | Y | Y | page |
| `SelectQuestLogEntry` | Y | Y | Y | - | page |
| `SelectTradeSkill` | Y | Y | Y | - | missing |
| `SelectTrainerService` | Y | Y | Y | Y | page |
| `SellCursorItem` | Y | Y | Y | Y | page |
| `SendMail` | Y | Y | Y | Y | page |
| `SendSubscriptionInterstitialResponse` | - | - | - | Y | page |
| `SendSystemMessage` | Y | Y | Y | Y | page |
| `SetAbandonQuest` | Y | Y | Y | - | page |
| `SetAchievementComparisonUnit` | Y | Y | Y | Y | page |
| `SetAchievementSearchString` | Y | Y | Y | Y | page |
| `SetActionBarToggles` | Y | Y | Y | Y | page |
| `SetAllowDangerousScripts` | Y | Y | Y | Y | page |
| `SetAllowLowLevelRaid` | Y | Y | Y | Y | page |
| `SetAllowRecentAlliesSeeLocation` | - | - | - | Y | page |
| `SetArenaTeamRosterSelection` | Y | Y | Y | - | missing |
| `SetArenaTeamRosterShowOffline` | Y | Y | Y | - | missing |
| `SetAuctionsTabShowing` | Y | Y | Y | - | missing |
| `SetAutoDeclineGuildInvites` | Y | Y | Y | Y | page |
| `SetAutoDeclineNeighborhoodInvites` | Y | Y | Y | Y | page |
| `SetBarSlotFromIntro` | Y | Y | Y | Y | missing |
| `SetBattlefieldScoreFaction` | Y | Y | Y | Y | page |
| `SetBinding` | Y | Y | Y | Y | page |
| `SetBindingClick` | Y | Y | Y | Y | page |
| `SetBindingItem` | Y | Y | Y | Y | page |
| `SetBindingMacro` | Y | Y | Y | Y | page |
| `SetBindingSpell` | Y | Y | Y | Y | page |
| `SetCemeteryPreference` | Y | Y | Y | Y | page |
| `SetChannelOwner` | Y | Y | Y | Y | page |
| `SetChannelPassword` | Y | Y | Y | Y | page |
| `SetChatColorNameByClass` | Y | Y | Y | Y | missing |
| `SetChatWindowAlpha` | Y | Y | Y | Y | missing |
| `SetChatWindowColor` | Y | Y | Y | Y | missing |
| `SetChatWindowDocked` | Y | Y | Y | Y | missing |
| `SetChatWindowLocked` | Y | Y | Y | Y | missing |
| `SetChatWindowName` | Y | Y | Y | Y | missing |
| `SetChatWindowSavedDimensions` | Y | Y | Y | Y | missing |
| `SetChatWindowSavedPosition` | Y | Y | Y | Y | missing |
| `SetChatWindowShown` | Y | Y | Y | Y | missing |
| `SetChatWindowSize` | Y | Y | Y | Y | missing |
| `SetChatWindowUninteractable` | Y | Y | Y | Y | missing |
| `SetConsoleKey` | Y | Y | Y | Y | page |
| `SetCraftFilter` | Y | Y | Y | - | missing |
| `SetCurrencyBackpack` | Y | Y | Y | - | page |
| `SetCurrencyUnused` | Y | Y | Y | - | page |
| `SetCurrentGraphicsSetting` | Y | Y | Y | Y | missing |
| `SetCurrentGuildBankTab` | Y | Y | Y | Y | missing |
| `SetCurrentTitle` | Y | Y | Y | Y | page |
| `SetCursor` | Y | Y | Y | Y | page |
| `SetCursorByMode` | Y | Y | Y | Y | page |
| `SetCursorHoveredItem` | - | - | - | Y | page |
| `SetCursorHoveredItemTradeItem` | - | - | - | Y | page |
| `SetCursorPosition` | Y | Y | Y | Y | page |
| `SetCursorVirtualItem` | - | - | - | Y | page |
| `SetDungeonDifficultyID` | Y | Y | Y | Y | page |
| `SetErrorCallstackHeight` | Y | Y | Y | Y | page |
| `seterrorhandler` | Y | Y | Y | Y | page |
| `SetEuropeanNumbers` | Y | Y | Y | Y | page |
| `SetFactionActive` | Y | Y | Y | - | page |
| `SetFactionInactive` | Y | Y | Y | - | page |
| `setfenv` | Y | Y | Y | Y | page |
| `SetFocusedAchievement` | - | - | Y | Y | page |
| `SetGamePadCursorControl` | Y | Y | Y | Y | missing |
| `SetGamePadFreeLook` | Y | Y | Y | Y | missing |
| `SetGlyphFilter` | - | - | Y | - | page |
| `SetGlyphNameFilter` | - | - | Y | - | page |
| `SetGuildBankTabInfo` | Y | Y | Y | Y | page |
| `SetGuildBankTabItemWithdraw` | Y | Y | Y | Y | missing |
| `SetGuildBankTabPermissions` | Y | Y | Y | Y | page |
| `SetGuildBankText` | Y | Y | Y | Y | page |
| `SetGuildBankWithdrawGoldLimit` | Y | Y | Y | Y | page |
| `SetGuildMemberRank` | Y | Y | Y | Y | missing |
| `SetGuildNewsFilter` | Y | Y | Y | Y | missing |
| `SetGuildRosterSelection` | Y | Y | Y | Y | page |
| `SetGuildRosterShowOffline` | Y | Y | Y | Y | page |
| `SetGuildTradeSkillCategoryFilter` | Y | Y | Y | Y | missing |
| `SetGuildTradeSkillItemNameFilter` | Y | Y | Y | Y | missing |
| `SetInventoryPortraitTexture` | Y | Y | Y | - | missing |
| `SetInWorldUIVisibility` | Y | Y | Y | Y | page |
| `SetLegacyRaidDifficultyID` | Y | Y | Y | Y | page |
| `SetLFGBootVote` | Y | Y | Y | Y | missing |
| `SetLFGComment` | Y | Y | Y | Y | page |
| `SetLFGDungeon` | Y | Y | Y | Y | missing |
| `SetLFGDungeonEnabled` | Y | Y | Y | Y | missing |
| `SetLFGHeaderCollapsed` | Y | Y | Y | Y | missing |
| `SetLFGRoles` | Y | Y | Y | Y | missing |
| `SetLootPortrait` | Y | Y | Y | Y | missing |
| `SetLootSpecialization` | Y | Y | Y | Y | page |
| `SetLootThreshold` | Y | Y | Y | Y | page |
| `SetMacroItem` | Y | Y | Y | Y | missing |
| `SetMacroSpell` | Y | Y | Y | Y | page |
| `SetMerchantFilter` | - | - | - | Y | missing |
| `setmetatable` | Y | Y | Y | Y | page |
| `SetModifiedClick` | Y | Y | Y | Y | page |
| `SetMouselookOverrideBinding` | Y | Y | Y | Y | missing |
| `SetMoveEnabled` | Y | Y | Y | Y | page |
| `SetMultiCastSpell` | Y | Y | Y | Y | page |
| `SetOptOutOfLoot` | Y | Y | Y | Y | page |
| `SetOverrideBinding` | Y | Y | Y | Y | page |
| `SetOverrideBindingClick` | Y | Y | Y | Y | page |
| `SetOverrideBindingItem` | Y | Y | Y | Y | page |
| `SetOverrideBindingMacro` | Y | Y | Y | Y | page |
| `SetOverrideBindingSpell` | Y | Y | Y | Y | page |
| `SetPartyAssignment` | Y | Y | Y | Y | missing |
| `SetPendingReportArenaTeamName` | Y | Y | Y | - | missing |
| `SetPetSlot` | Y | Y | Y | - | page |
| `SetPetStablePaperdoll` | Y | Y | Y | - | page |
| `SetPOIIconOverlapDistance` | Y | Y | Y | Y | missing |
| `SetPOIIconOverlapPushDistance` | Y | Y | Y | Y | missing |
| `SetPortraitTexture` | Y | Y | Y | Y | page |
| `SetPortraitTextureFromCreatureDisplayID` | Y | Y | Y | Y | page |
| `SetPortraitToTexture` | Y | Y | Y | - | page |
| `SetPreviewPrimaryTalentTree` | Y | Y | Y | - | missing |
| `SetPrimaryTalentTree` | Y | Y | Y | - | page |
| `SetPVPRoles` | Y | Y | Y | Y | page |
| `SetRaidDifficultyID` | Y | Y | Y | Y | page |
| `SetRaidProfileOption` | Y | Y | Y | Y | missing |
| `SetRaidProfileSavedPosition` | Y | Y | Y | Y | missing |
| `SetRaidSubgroup` | Y | Y | Y | Y | page |
| `SetRaidTarget` | Y | Y | Y | Y | page |
| `SetSavedInstanceExtend` | Y | Y | Y | Y | missing |
| `setsecurehookforbidden` | Y | Y | Y | Y | missing |
| `SetSelectedArtifact` | - | - | Y | Y | page |
| `SetSelectedAuctionItem` | Y | Y | Y | - | page |
| `SetSelectedDisplayChannel` | Y | Y | Y | Y | missing |
| `SetSelectedFaction` | Y | Y | Y | - | missing |
| `SetSelectedScreenResolutionIndex` | Y | Y | Y | Y | missing |
| `SetSelectedSkill` | Y | Y | Y | - | page |
| `SetSelectedWarGameType` | Y | Y | Y | Y | missing |
| `SetSendMailCOD` | Y | Y | Y | Y | missing |
| `SetSendMailMoney` | Y | Y | Y | Y | missing |
| `SetSendMailShowing` | Y | Y | Y | Y | page |
| `SetSpecialization` | Y | Y | Y | - | page |
| `SetSpellbookPetAction` | Y | Y | Y | Y | missing |
| `SetSuperTrackedQuestID` | Y | Y | Y | - | missing |
| `settablesecurity` | - | - | - | Y | page |
| `SetTableSecurityOption` | Y | Y | Y | - | page |
| `SetTaxiBenchmarkMode` | Y | Y | Y | Y | page |
| `SetTaxiMap` | Y | Y | Y | Y | page |
| `SetTradeCurrency` | - | - | - | Y | missing |
| `SetTradeSkillInvSlotFilter` | Y | Y | Y | - | page |
| `SetTradeSkillItemLevelFilter` | Y | Y | Y | - | page |
| `SetTradeSkillItemNameFilter` | Y | Y | Y | - | missing |
| `SetTradeSkillSubClassFilter` | Y | Y | Y | - | page |
| `SetTrainerServiceTypeFilter` | Y | Y | Y | Y | page |
| `SetTurnEnabled` | Y | Y | Y | Y | page |
| `SetUIVisibility` | Y | Y | Y | Y | page |
| `SetUnitCursorTexture` | Y | Y | Y | Y | page |
| `SetupFullscreenScale` | Y | Y | Y | Y | page |
| `SetView` | Y | Y | Y | Y | page |
| `SetWatchedFactionIndex` | Y | Y | Y | - | page |
| `ShiftQuestWatches` | Y | Y | Y | - | page |
| `ShouldKnowUnitHealth` | Y | Y | Y | - | page |
| `ShouldShowExpansionUpgradeBanner` | - | - | - | Y | page |
| `ShouldShowIslandsWeeklyPOI` | - | - | - | Y | page |
| `ShouldShowSpecialSplashScreen` | - | - | - | Y | page |
| `ShowBuybackSellCursor` | Y | Y | Y | Y | missing |
| `ShowCloak` | Y | Y | Y | Y | page |
| `ShowHelm` | Y | Y | Y | Y | page |
| `ShowingCloak` | Y | Y | Y | Y | page |
| `ShowingHelm` | Y | Y | Y | Y | page |
| `ShowInventorySellCursor` | Y | Y | Y | - | missing |
| `ShowQuestComplete` | Y | Y | Y | Y | page |
| `ShowQuestOffer` | Y | Y | Y | Y | missing |
| `ShowRepairCursor` | Y | Y | Y | Y | page |
| `SignPetition` | Y | Y | Y | Y | page |
| `SimulateMouseClick` | Y | Y | Y | Y | page |
| `SimulateMouseDown` | Y | Y | Y | Y | page |
| `SimulateMouseUp` | Y | Y | Y | Y | page |
| `SimulateMouseWheel` | Y | Y | Y | Y | page |
| `sin` | Y | Y | Y | Y | redirect |
| `SitStandOrDescendStart` | Y | Y | Y | Y | page |
| `SocketInventoryItem` | Y | Y | Y | Y | missing |
| `SocketItemToArtifact` | - | - | Y | Y | page |
| `SolveArtifact` | - | - | Y | Y | page |
| `sort` | Y | Y | Y | Y | missing |
| `SortArenaTeamRoster` | Y | Y | Y | - | missing |
| `SortAuctionApplySort` | Y | Y | Y | - | missing |
| `SortAuctionClearSort` | Y | Y | Y | - | missing |
| `SortAuctionItems` | Y | Y | Y | - | page |
| `SortAuctionSetSort` | Y | Y | Y | - | page |
| `SortBattlefieldScoreData` | Y | Y | Y | Y | missing |
| `SortBGList` | - | - | Y | Y | page |
| `SortGuildRoster` | Y | Y | Y | Y | page |
| `SortGuildTradeSkill` | Y | Y | Y | Y | missing |
| `SortQuests` | Y | Y | Y | Y | missing |
| `SortQuestSortTypes` | Y | Y | Y | Y | missing |
| `SortQuestWatches` | Y | Y | Y | - | page |
| `Sound_ChatSystem_GetInputDriverNameByIndex` | Y | Y | Y | Y | missing |
| `Sound_ChatSystem_GetNumInputDrivers` | Y | Y | Y | Y | missing |
| `Sound_ChatSystem_GetNumOutputDrivers` | Y | Y | Y | Y | missing |
| `Sound_ChatSystem_GetOutputDriverNameByIndex` | Y | Y | Y | Y | missing |
| `Sound_GameSystem_GetInputDriverNameByIndex` | Y | Y | Y | Y | missing |
| `Sound_GameSystem_GetNumInputDrivers` | Y | Y | Y | Y | missing |
| `Sound_GameSystem_GetNumOutputDrivers` | Y | Y | Y | Y | missing |
| `Sound_GameSystem_GetOutputDriverNameByIndex` | Y | Y | Y | Y | missing |
| `Sound_GameSystem_RestartSoundSystem` | Y | Y | Y | Y | missing |
| `SpellCancelQueuedSpell` | Y | Y | Y | Y | missing |
| `SpellCanTargetGarrisonFollower` | - | - | - | Y | missing |
| `SpellCanTargetGarrisonFollowerAbility` | - | - | - | Y | missing |
| `SpellCanTargetGarrisonMission` | - | - | - | Y | missing |
| `SpellCanTargetItem` | Y | Y | Y | Y | missing |
| `SpellCanTargetItemID` | Y | Y | Y | Y | missing |
| `SpellCanTargetQuest` | - | - | - | Y | missing |
| `SpellCanTargetUnit` | Y | Y | Y | Y | page |
| `SpellHasRange` | Y | Y | Y | - | missing |
| `SpellIsTargeting` | Y | Y | Y | Y | page |
| `SpellStopCasting` | Y | Y | Y | Y | page |
| `SpellStopTargeting` | Y | Y | Y | Y | page |
| `SpellTargetItem` | Y | Y | Y | Y | missing |
| `SpellTargetUnit` | Y | Y | Y | Y | page |
| `SplashFrameCanBeShown` | - | - | - | Y | page |
| `SplitGuildBankItem` | Y | Y | Y | Y | missing |
| `sqrt` | Y | Y | Y | Y | missing |
| `StartAttack` | Y | Y | Y | Y | page |
| `StartAuction` | Y | Y | Y | - | page |
| `StartAutoRun` | Y | Y | Y | Y | missing |
| `StartDuel` | Y | Y | Y | Y | page |
| `StartSoloShuffleWarGameByName` | - | - | - | Y | missing |
| `StartSpectatorSoloShuffleWarGame` | - | - | - | Y | missing |
| `StartSpectatorWarGame` | Y | Y | Y | Y | missing |
| `StartWarGame` | Y | Y | Y | Y | missing |
| `StartWarGameByName` | Y | Y | Y | Y | missing |
| `StopAttack` | Y | Y | Y | Y | page |
| `StopAutoRun` | Y | Y | Y | Y | missing |
| `StopCinematic` | Y | Y | Y | Y | page |
| `StopMacro` | Y | Y | Y | Y | missing |
| `StopMusic` | Y | Y | Y | Y | page |
| `StopSound` | Y | Y | Y | Y | page |
| `StopTradeSkillRepeat` | Y | Y | Y | - | page |
| `StoreSecureReference` | Y | Y | Y | Y | missing |
| `StrafeLeftStart` | Y | Y | Y | Y | page |
| `StrafeLeftStop` | Y | Y | Y | Y | page |
| `StrafeRightStart` | Y | Y | Y | Y | page |
| `StrafeRightStop` | Y | Y | Y | Y | page |
| `strbyte` | Y | Y | Y | Y | missing |
| `strchar` | Y | Y | Y | Y | missing |
| `strcmputf8i` | Y | Y | Y | Y | missing |
| `strconcat` | Y | Y | Y | Y | missing |
| `strfind` | Y | Y | Y | Y | missing |
| `strjoin` | Y | Y | Y | Y | missing |
| `strlen` | Y | Y | Y | Y | missing |
| `strlenutf8` | Y | Y | Y | Y | page |
| `strlower` | Y | Y | Y | Y | missing |
| `strmatch` | Y | Y | Y | Y | missing |
| `strrep` | Y | Y | Y | Y | missing |
| `strrev` | Y | Y | Y | Y | missing |
| `strsplit` | Y | Y | Y | Y | missing |
| `strsplittable` | Y | Y | Y | Y | page |
| `strsub` | Y | Y | Y | Y | missing |
| `strtrim` | Y | Y | Y | Y | missing |
| `strupper` | Y | Y | Y | Y | missing |
| `Stuck` | Y | Y | Y | Y | page |
| `SubmitRequiredGuildRename` | Y | Y | Y | Y | missing |
| `SummonRandomCritter` | - | - | - | Y | page |
| `SupportsClipCursor` | Y | Y | Y | Y | page |
| `SurrenderArena` | - | - | - | Y | missing |
| `SwapRaidSubgroup` | Y | Y | Y | Y | page |
| `SwapToGlobalEnvironment` | Y | Y | Y | Y | missing |
| `SwitchAchievementSearchTab` | Y | Y | Y | Y | missing |
| `TakeInboxItem` | Y | Y | Y | Y | page |
| `TakeInboxMoney` | Y | Y | Y | Y | page |
| `TakeInboxTextItem` | Y | Y | Y | Y | missing |
| `TakeTaxiNode` | Y | Y | Y | Y | page |
| `tan` | Y | Y | Y | Y | missing |
| `TargetDirectionEnemy` | Y | Y | Y | Y | page |
| `TargetDirectionFinished` | Y | Y | Y | Y | page |
| `TargetDirectionFriend` | Y | Y | Y | Y | page |
| `TargetLastEnemy` | Y | Y | Y | Y | page |
| `TargetLastFriend` | Y | Y | Y | Y | page |
| `TargetLastTarget` | Y | Y | Y | Y | page |
| `TargetNearest` | Y | Y | Y | Y | page |
| `TargetNearestEnemy` | Y | Y | Y | Y | page |
| `TargetNearestEnemyPlayer` | Y | Y | Y | Y | page |
| `TargetNearestFriend` | Y | Y | Y | Y | page |
| `TargetNearestFriendPlayer` | Y | Y | Y | Y | page |
| `TargetNearestPartyMember` | Y | Y | Y | Y | page |
| `TargetNearestRaidMember` | Y | Y | Y | Y | page |
| `TargetPriorityHighlightEnd` | Y | Y | Y | Y | page |
| `TargetPriorityHighlightStart` | Y | Y | Y | Y | page |
| `TargetToggle` | Y | Y | Y | Y | page |
| `TargetTotem` | Y | Y | Y | Y | page |
| `TargetUnit` | Y | Y | Y | Y | page |
| `TaxiGetDestX` | Y | Y | Y | Y | page |
| `TaxiGetDestY` | Y | Y | Y | Y | page |
| `TaxiGetNodeSlot` | Y | Y | Y | Y | missing |
| `TaxiGetSrcX` | Y | Y | Y | Y | page |
| `TaxiGetSrcY` | Y | Y | Y | Y | page |
| `TaxiIsDirectFlight` | Y | Y | Y | Y | missing |
| `TaxiNodeCost` | Y | Y | Y | Y | page |
| `TaxiNodeGetType` | Y | Y | Y | Y | page |
| `TaxiNodeName` | Y | Y | Y | Y | page |
| `TaxiNodePosition` | Y | Y | Y | Y | page |
| `TaxiRequestEarlyLanding` | Y | Y | Y | Y | missing |
| `time` | Y | Y | Y | Y | page |
| `TimeoutResurrect` | Y | Y | Y | Y | page |
| `tinsert` | Y | Y | Y | Y | missing |
| `ToggleAutoRun` | Y | Y | Y | Y | page |
| `ToggleGlyphFilter` | - | - | Y | - | page |
| `TogglePetAutocast` | Y | Y | Y | Y | missing |
| `ToggleRun` | Y | Y | Y | Y | page |
| `ToggleSelfHighlight` | Y | Y | Y | Y | page |
| `ToggleSheath` | Y | Y | Y | Y | page |
| `ToggleSpellAutocast` | Y | Y | Y | - | missing |
| `ToggleWindowed` | Y | Y | Y | Y | missing |
| `tonumber` | Y | Y | Y | Y | page |
| `tostring` | Y | Y | Y | Y | page |
| `TradeSkillOnlyShowMakeable` | Y | Y | Y | - | missing |
| `TradeSkillOnlyShowSkillUps` | Y | Y | Y | - | missing |
| `tremove` | Y | Y | Y | Y | missing |
| `TriggerTutorial` | Y | Y | Y | Y | missing |
| `TurnInArenaPetition` | Y | Y | Y | - | missing |
| `TurnInGuildCharter` | Y | Y | Y | Y | missing |
| `TurnLeftStart` | Y | Y | Y | Y | page |
| `TurnLeftStop` | Y | Y | Y | Y | page |
| `TurnOrActionStart` | Y | Y | Y | Y | page |
| `TurnOrActionStop` | Y | Y | Y | Y | page |
| `TurnRightStart` | Y | Y | Y | Y | page |
| `TurnRightStop` | Y | Y | Y | Y | page |
| `type` | Y | Y | Y | Y | page |
| `UnitAffectingCombat` | Y | Y | Y | Y | page |
| `UnitAlliedRaceInfo` | - | - | - | Y | page |
| `UnitArmor` | Y | Y | Y | Y | page |
| `UnitAttackBothHands` | Y | Y | Y | - | page |
| `UnitAttackPower` | Y | Y | Y | Y | page |
| `UnitAttackSpeed` | Y | Y | Y | Y | page |
| `UnitBattlePetLevel` | Y | Y | Y | Y | page |
| `UnitBattlePetSpeciesID` | Y | Y | Y | Y | page |
| `UnitBattlePetType` | Y | Y | Y | Y | page |
| `UnitCanAssist` | Y | Y | Y | Y | page |
| `UnitCanAttack` | Y | Y | Y | Y | page |
| `UnitCanCooperate` | Y | Y | Y | Y | page |
| `UnitCanPetBattle` | Y | Y | Y | Y | page |
| `UnitCastingDuration` | Y | Y | Y | Y | page |
| `UnitCastingInfo` | Y | Y | Y | Y | page |
| `UnitChannelDuration` | Y | Y | Y | Y | page |
| `UnitChannelInfo` | Y | Y | Y | Y | page |
| `UnitCharacterPoints` | Y | Y | Y | - | page |
| `UnitChromieTimeID` | - | - | - | Y | page |
| `UnitClass` | Y | Y | Y | Y | page |
| `UnitClassBase` | Y | Y | Y | Y | page |
| `UnitClassFromGUID` | Y | Y | Y | Y | page |
| `UnitClassification` | Y | Y | Y | Y | page |
| `UnitControllingVehicle` | Y | Y | Y | Y | page |
| `UnitCreatureFamily` | Y | Y | Y | Y | page |
| `UnitCreatureID` | Y | Y | Y | Y | page |
| `UnitCreatureType` | Y | Y | Y | Y | page |
| `UnitDamage` | Y | Y | Y | Y | page |
| `UnitDefense` | Y | Y | Y | - | page |
| `UnitDetailedThreatSituation` | Y | Y | Y | Y | page |
| `UnitDistanceSquared` | Y | Y | Y | Y | page |
| `UnitEffectiveLevel` | Y | Y | Y | Y | page |
| `UnitEmpoweredChannelDuration` | Y | Y | Y | Y | page |
| `UnitEmpoweredStageDurations` | Y | Y | Y | Y | page |
| `UnitEmpoweredStagePercentages` | Y | Y | Y | Y | page |
| `UnitExists` | Y | Y | Y | Y | page |
| `UnitFactionGroup` | Y | Y | Y | Y | page |
| `UnitFullName` | Y | Y | Y | Y | page |
| `UnitGetAvailableRoles` | Y | Y | Y | Y | page |
| `UnitGetDetailedHealPrediction` | Y | Y | Y | Y | page |
| `UnitGetIncomingHeals` | Y | Y | Y | Y | page |
| `UnitGetTotalAbsorbs` | Y | Y | Y | Y | page |
| `UnitGetTotalHealAbsorbs` | Y | Y | Y | Y | page |
| `UnitGroupRolesAssigned` | Y | Y | Y | Y | page |
| `UnitGroupRolesAssignedEnum` | Y | Y | Y | Y | page |
| `UnitGUID` | Y | Y | Y | Y | page |
| `UnitHasIncomingResurrection` | Y | Y | Y | Y | page |
| `UnitHasLFGDeserter` | Y | Y | Y | Y | page |
| `UnitHasLFGRandomCooldown` | Y | Y | Y | Y | page |
| `UnitHasPowerType` | Y | Y | Y | Y | page |
| `UnitHasRelicSlot` | Y | Y | Y | Y | page |
| `UnitHasVehiclePlayerFrameUI` | Y | Y | Y | Y | page |
| `UnitHasVehicleUI` | Y | Y | Y | Y | page |
| `UnitHealth` | Y | Y | Y | Y | page |
| `UnitHealthMax` | Y | Y | Y | Y | page |
| `UnitHealthMissing` | Y | Y | Y | Y | page |
| `UnitHealthPercent` | Y | Y | Y | Y | page |
| `UnitHonor` | - | - | - | Y | page |
| `UnitHonorLevel` | - | - | - | Y | page |
| `UnitHonorMax` | - | - | - | Y | page |
| `UnitHPPerStamina` | Y | Y | Y | Y | page |
| `UnitIgnoresVehicleComboPoints` | Y | Y | Y | - | missing |
| `UnitInAnyGroup` | Y | Y | Y | Y | page |
| `UnitInBattleground` | Y | Y | Y | Y | page |
| `UnitInOtherParty` | Y | Y | Y | Y | page |
| `UnitInParty` | Y | Y | Y | Y | page |
| `UnitInPartyIsAI` | Y | Y | Y | Y | page |
| `UnitInPartyShard` | - | - | - | Y | page |
| `UnitInPhase` | Y | Y | Y | - | page |
| `UnitInRaid` | Y | Y | Y | Y | page |
| `UnitInRange` | Y | Y | Y | Y | page |
| `UnitInSubgroup` | Y | Y | Y | Y | page |
| `UnitInVehicle` | Y | Y | Y | Y | page |
| `UnitInVehicleControlSeat` | Y | Y | Y | Y | page |
| `UnitInVehicleHidesPetFrame` | Y | Y | Y | Y | page |
| `UnitIsAFK` | Y | Y | Y | Y | page |
| `UnitIsBattlePet` | Y | Y | Y | Y | page |
| `UnitIsBattlePetCompanion` | Y | Y | Y | Y | page |
| `UnitIsBossMob` | - | - | - | Y | page |
| `UnitIsCharmed` | Y | Y | Y | Y | page |
| `UnitIsCivilian` | Y | Y | Y | - | page |
| `UnitIsConnected` | Y | Y | Y | Y | page |
| `UnitIsControlling` | Y | Y | Y | Y | page |
| `UnitIsCorpse` | Y | Y | Y | Y | page |
| `UnitIsDead` | Y | Y | Y | Y | page |
| `UnitIsDeadOrGhost` | Y | Y | Y | Y | page |
| `UnitIsDND` | Y | Y | Y | Y | page |
| `UnitIsEnemy` | Y | Y | Y | Y | page |
| `UnitIsFeignDeath` | Y | Y | Y | Y | page |
| `UnitIsFriend` | Y | Y | Y | Y | page |
| `UnitIsGameObject` | Y | Y | Y | Y | page |
| `UnitIsGhost` | Y | Y | Y | Y | page |
| `UnitIsGroupAssistant` | Y | Y | Y | Y | page |
| `UnitIsGroupLeader` | Y | Y | Y | Y | page |
| `UnitIsHumanPlayer` | Y | Y | Y | Y | page |
| `UnitIsInMyGuild` | Y | Y | Y | Y | page |
| `UnitIsInteractable` | Y | Y | Y | Y | page |
| `UnitIsLieutenant` | - | - | - | Y | page |
| `UnitIsMercenary` | - | - | - | Y | page |
| `UnitIsMinion` | Y | Y | Y | Y | page |
| `UnitIsNPCAsPlayer` | Y | Y | Y | Y | page |
| `UnitIsOtherPlayersBattlePet` | Y | Y | Y | Y | page |
| `UnitIsOtherPlayersPet` | Y | Y | Y | Y | page |
| `UnitIsOwnerOrControllerOfUnit` | Y | Y | Y | Y | page |
| `UnitIsPlayer` | Y | Y | Y | Y | page |
| `UnitIsPossessed` | Y | Y | Y | Y | page |
| `UnitIsPVP` | Y | Y | Y | Y | page |
| `UnitIsPVPFreeForAll` | Y | Y | Y | Y | page |
| `UnitIsPVPSanctuary` | Y | Y | Y | Y | page |
| `UnitIsQuestBoss` | - | - | - | Y | page |
| `UnitIsRaidOfficer` | Y | Y | Y | Y | page |
| `UnitIsSameServer` | Y | Y | Y | Y | page |
| `UnitIsTapDenied` | Y | Y | Y | Y | page |
| `UnitIsTrivial` | Y | Y | Y | Y | page |
| `UnitIsUnconscious` | Y | Y | Y | Y | page |
| `UnitIsUnit` | Y | Y | Y | Y | page |
| `UnitIsVisible` | Y | Y | Y | Y | page |
| `UnitIsWildBattlePet` | Y | Y | Y | Y | page |
| `UnitLeadsAnyGroup` | Y | Y | Y | Y | page |
| `UnitLevel` | Y | Y | Y | Y | page |
| `UnitName` | Y | Y | Y | Y | page |
| `UnitNameFromGUID` | - | - | - | Y | page |
| `UnitNameplateShowsWidgetsOnly` | Y | Y | Y | Y | page |
| `UnitNameUnmodified` | Y | Y | Y | Y | page |
| `UnitNumPowerBarTimers` | Y | Y | Y | Y | page |
| `UnitOnTaxi` | Y | Y | Y | Y | page |
| `UnitOwnerGUID` | Y | Y | Y | Y | page |
| `UnitPartialPower` | Y | Y | Y | Y | page |
| `UnitPercentHealthFromGUID` | Y | Y | Y | Y | page |
| `UnitPhaseReason` | Y | Y | Y | Y | page |
| `UnitPlayerControlled` | Y | Y | Y | Y | page |
| `UnitPlayerOrPetInParty` | Y | Y | Y | Y | page |
| `UnitPlayerOrPetInRaid` | Y | Y | Y | Y | page |
| `UnitPosition` | Y | Y | Y | Y | page |
| `UnitPower` | Y | Y | Y | Y | page |
| `UnitPowerBarID` | Y | Y | Y | Y | page |
| `UnitPowerBarTimerInfo` | Y | Y | Y | Y | page |
| `UnitPowerDisplayMod` | Y | Y | Y | Y | page |
| `UnitPowerMax` | Y | Y | Y | Y | page |
| `UnitPowerMissing` | Y | Y | Y | Y | page |
| `UnitPowerPercent` | Y | Y | Y | Y | page |
| `UnitPowerType` | Y | Y | Y | Y | page |
| `UnitPvpClassification` | Y | Y | Y | Y | page |
| `UnitPVPName` | Y | Y | Y | Y | page |
| `UnitPVPRank` | Y | Y | Y | - | page |
| `UnitQuestTrivialLevelRange` | - | - | - | Y | page |
| `UnitQuestTrivialLevelRangeScaling` | - | - | - | Y | page |
| `UnitRace` | Y | Y | Y | Y | page |
| `UnitRangedAttack` | Y | Y | Y | - | page |
| `UnitRangedAttackPower` | Y | Y | Y | Y | page |
| `UnitRangedDamage` | Y | Y | Y | Y | page |
| `UnitReaction` | Y | Y | Y | Y | page |
| `UnitRealmRelationship` | Y | Y | Y | Y | page |
| `UnitResistance` | Y | Y | Y | - | page |
| `UnitSelectionColor` | Y | Y | Y | Y | page |
| `UnitSelectionType` | - | - | - | Y | page |
| `UnitSetRole` | Y | Y | Y | Y | page |
| `UnitSetRoleEnum` | Y | Y | Y | Y | page |
| `UnitSex` | Y | Y | Y | Y | page |
| `UnitSexBase` | Y | Y | Y | Y | page |
| `UnitShouldDisplayName` | Y | Y | Y | Y | page |
| `UnitShouldDisplaySpellTargetName` | Y | Y | Y | Y | page |
| `UnitSpellHaste` | Y | Y | Y | Y | page |
| `UnitSpellTargetClass` | Y | Y | Y | Y | page |
| `UnitSpellTargetName` | Y | Y | Y | Y | page |
| `UnitStagger` | Y | Y | Y | Y | page |
| `UnitStat` | Y | Y | Y | Y | page |
| `UnitSwitchToVehicleSeat` | Y | Y | Y | Y | page |
| `UnitTargetsVehicleInRaidUI` | Y | Y | Y | Y | page |
| `UnitThreatLeadSituation` | Y | Y | Y | Y | page |
| `UnitThreatPercentageOfLead` | Y | Y | Y | Y | page |
| `UnitThreatSituation` | Y | Y | Y | Y | page |
| `UnitTokenFromGUID` | Y | Y | Y | Y | page |
| `UnitTreatAsPlayerForDisplay` | Y | Y | Y | Y | page |
| `UnitTrialBankedLevels` | Y | Y | Y | Y | page |
| `UnitTrialXP` | Y | Y | Y | Y | page |
| `UnitUsingVehicle` | Y | Y | Y | Y | page |
| `UnitVehicleSeatCount` | Y | Y | Y | Y | page |
| `UnitVehicleSeatInfo` | Y | Y | Y | Y | page |
| `UnitVehicleSkin` | Y | Y | Y | Y | page |
| `UnitVehicleSkinType` | Y | Y | Y | - | missing |
| `UnitWeaponAttackPower` | - | - | - | Y | page |
| `UnitWidgetSet` | Y | Y | Y | Y | page |
| `UnitXP` | Y | Y | Y | Y | page |
| `UnitXPMax` | Y | Y | Y | Y | page |
| `UnlearnSpecialization` | Y | Y | Y | Y | missing |
| `UnmuteSoundFile` | Y | Y | Y | Y | page |
| `unpack` | Y | Y | Y | Y | page |
| `UnregisterEventCallback` | Y | Y | Y | Y | page |
| `UnregisterUnitEventCallback` | Y | Y | Y | Y | page |
| `UpdateAddOnCPUUsage` | Y | Y | Y | Y | page |
| `UpdateAddOnMemoryUsage` | Y | Y | Y | Y | page |
| `UpdateInventoryAlertStatus` | Y | Y | Y | Y | missing |
| `UpdateWarGamesList` | Y | Y | Y | Y | missing |
| `UpdateWindow` | Y | Y | Y | Y | page |
| `UseAction` | Y | Y | Y | Y | page |
| `UseInventoryItem` | Y | Y | Y | Y | page |
| `UseQuestLogSpecialItem` | Y | Y | Y | Y | missing |
| `UseToy` | Y | Y | Y | Y | page |
| `UseToyByName` | Y | Y | Y | Y | page |
| `UseWorldMapActionButtonSpellOnQuest` | - | - | - | Y | missing |
| `VehicleAimDecrement` | Y | Y | Y | Y | missing |
| `VehicleAimDownStart` | Y | Y | Y | Y | missing |
| `VehicleAimDownStop` | Y | Y | Y | Y | missing |
| `VehicleAimGetNormPower` | Y | Y | Y | Y | missing |
| `VehicleAimIncrement` | Y | Y | Y | Y | missing |
| `VehicleAimRequestAngle` | Y | Y | Y | Y | missing |
| `VehicleAimSetNormPower` | Y | Y | Y | Y | missing |
| `VehicleAimUpStart` | Y | Y | Y | Y | missing |
| `VehicleAimUpStop` | Y | Y | Y | Y | missing |
| `VehicleCameraZoomIn` | - | - | Y | - | page |
| `VehicleCameraZoomOut` | - | - | Y | - | page |
| `VehicleExit` | Y | Y | Y | Y | missing |
| `VehicleNextSeat` | Y | Y | Y | Y | missing |
| `VehiclePrevSeat` | Y | Y | Y | Y | missing |
| `ViewGuildRecipes` | Y | Y | Y | Y | missing |
| `WantsAlteredForm` | Y | Y | Y | - | missing |
| `WarGameRespond` | Y | Y | Y | Y | missing |
| `wipe` | Y | Y | Y | Y | missing |
| `WithdrawGuildBankMoney` | Y | Y | Y | Y | missing |
| `WorldLootObjectExists` | Y | Y | Y | Y | page |
| `xpcall` | Y | Y | Y | Y | page |

### bit

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `bit.arshift` | Y | Y | Y | Y | missing |
| `bit.band` | Y | Y | Y | Y | missing |
| `bit.bnot` | Y | Y | Y | Y | missing |
| `bit.bor` | Y | Y | Y | Y | missing |
| `bit.bxor` | Y | Y | Y | Y | missing |
| `bit.lshift` | Y | Y | Y | Y | missing |
| `bit.mod` | Y | Y | Y | Y | missing |
| `bit.rshift` | Y | Y | Y | Y | missing |

### C_AccountInfo

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AccountInfo.GetIDFromBattleNetAccountGUID` | Y | Y | Y | Y | page |
| `C_AccountInfo.IsGUIDBattleNetAccountType` | Y | Y | Y | Y | page |
| `C_AccountInfo.IsGUIDRelatedToLocalAccount` | Y | Y | Y | Y | page |

### C_AccountServices

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AccountServices.IsAccountLockedPostSave` | Y | Y | Y | Y | missing |
| `C_AccountServices.IsAccountSaveEnabled` | Y | Y | Y | Y | missing |
| `C_AccountServices.IsAccountSaveInProgress` | Y | Y | Y | Y | missing |
| `C_AccountServices.SaveAccountData` | Y | Y | Y | Y | missing |

### C_AccountStore

11 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AccountStore.BeginPurchase` | Y | Y | Y | Y | page |
| `C_AccountStore.GetCategories` | Y | Y | Y | Y | page |
| `C_AccountStore.GetCategoryInfo` | Y | Y | Y | Y | page |
| `C_AccountStore.GetCategoryItems` | Y | Y | Y | Y | page |
| `C_AccountStore.GetCurrencyAvailable` | Y | Y | Y | Y | page |
| `C_AccountStore.GetCurrencyIDForStore` | Y | Y | Y | Y | page |
| `C_AccountStore.GetCurrencyInfo` | Y | Y | Y | Y | page |
| `C_AccountStore.GetItemInfo` | Y | Y | Y | Y | page |
| `C_AccountStore.GetStoreFrontState` | Y | Y | Y | Y | page |
| `C_AccountStore.RefundItem` | Y | Y | Y | Y | page |
| `C_AccountStore.RequestStoreFrontInfoUpdate` | Y | Y | Y | Y | page |

### C_AchievementInfo

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AchievementInfo.AreGuildAchievementsEnabled` | Y | Y | Y | Y | page |
| `C_AchievementInfo.GetRewardItemID` | Y | Y | Y | Y | page |
| `C_AchievementInfo.GetSupercedingAchievements` | Y | Y | Y | Y | page |
| `C_AchievementInfo.IsGuildAchievement` | Y | Y | Y | Y | page |
| `C_AchievementInfo.IsValidAchievement` | Y | Y | Y | Y | page |
| `C_AchievementInfo.SetPortraitTexture` | Y | Y | Y | Y | page |

### C_AchievementTelemetry

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AchievementTelemetry.LinkAchievementInClub` | Y | Y | Y | Y | page |
| `C_AchievementTelemetry.LinkAchievementInWhisper` | Y | Y | Y | Y | page |
| `C_AchievementTelemetry.ShowAchievements` | Y | Y | Y | Y | page |

### C_ActionBar

70 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ActionBar.EnableActionRangeCheck` | Y | Y | Y | Y | page |
| `C_ActionBar.FindAssistedCombatActionButtons` | Y | Y | Y | Y | page |
| `C_ActionBar.FindFlyoutActionButtons` | - | - | - | Y | page |
| `C_ActionBar.FindPetActionButtons` | Y | Y | Y | Y | page |
| `C_ActionBar.FindSpellActionButtons` | Y | Y | Y | Y | page |
| `C_ActionBar.ForceUpdateAction` | - | - | - | Y | page |
| `C_ActionBar.GetActionAutocast` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionBarPage` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionChargeDuration` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionCharges` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionCooldown` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionCooldownDuration` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionDisplayCount` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionLossOfControlCooldownDuration` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionLossOfControlCooldownInfo` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionText` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionTexture` | Y | Y | Y | Y | page |
| `C_ActionBar.GetActionUseCount` | Y | Y | Y | Y | page |
| `C_ActionBar.GetBonusBarIndex` | Y | Y | Y | Y | page |
| `C_ActionBar.GetBonusBarIndexForSlot` | - | - | - | Y | page |
| `C_ActionBar.GetBonusBarOffset` | Y | Y | Y | Y | page |
| `C_ActionBar.GetExtraBarIndex` | Y | Y | Y | Y | page |
| `C_ActionBar.GetItemActionOnEquipSpellID` | Y | Y | Y | Y | page |
| `C_ActionBar.GetMultiCastBarIndex` | Y | Y | Y | Y | page |
| `C_ActionBar.GetOverrideBarIndex` | Y | Y | Y | Y | page |
| `C_ActionBar.GetOverrideBarSkin` | Y | Y | Y | Y | page |
| `C_ActionBar.GetPetActionPetBarIndices` | Y | Y | Y | Y | page |
| `C_ActionBar.GetProfessionQuality` | Y | Y | Y | Y | page |
| `C_ActionBar.GetProfessionQualityInfo` | - | - | - | Y | page |
| `C_ActionBar.GetSpell` | Y | Y | Y | Y | page |
| `C_ActionBar.GetTempShapeshiftBarIndex` | Y | Y | Y | Y | page |
| `C_ActionBar.GetVehicleBarIndex` | Y | Y | Y | Y | page |
| `C_ActionBar.HasAction` | Y | Y | Y | Y | page |
| `C_ActionBar.HasAssistedCombatActionButtons` | Y | Y | Y | Y | page |
| `C_ActionBar.HasBonusActionBar` | Y | Y | Y | Y | page |
| `C_ActionBar.HasExtraActionBar` | Y | Y | Y | Y | page |
| `C_ActionBar.HasFlyoutActionButtons` | - | - | - | Y | page |
| `C_ActionBar.HasOverrideActionBar` | Y | Y | Y | Y | page |
| `C_ActionBar.HasPetActionButtons` | Y | Y | Y | Y | page |
| `C_ActionBar.HasPetActionPetBarIndices` | Y | Y | Y | Y | page |
| `C_ActionBar.HasRangeRequirements` | Y | Y | Y | Y | page |
| `C_ActionBar.HasSpellActionButtons` | Y | Y | Y | Y | page |
| `C_ActionBar.HasTempShapeshiftActionBar` | Y | Y | Y | Y | page |
| `C_ActionBar.HasVehicleActionBar` | Y | Y | Y | Y | page |
| `C_ActionBar.IsActionInRange` | Y | Y | Y | Y | page |
| `C_ActionBar.IsAssistedCombatAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsAttackAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsAutoCastPetAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsAutoRepeatAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsConsumableAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsCurrentAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsEnabledAutoCastPetAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsEquippedAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsEquippedGearOutfitAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsHarmfulAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsHelpfulAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsInterruptAction` | - | - | - | Y | page |
| `C_ActionBar.IsItemAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsOnBarOrSpecialBar` | Y | Y | Y | Y | page |
| `C_ActionBar.IsPossessBarVisible` | Y | Y | Y | Y | page |
| `C_ActionBar.IsStackableAction` | Y | Y | Y | Y | page |
| `C_ActionBar.IsUsableAction` | Y | Y | Y | Y | page |
| `C_ActionBar.PutActionInSlot` | - | - | - | Y | page |
| `C_ActionBar.RegisterActionUIButton` | Y | Y | Y | Y | page |
| `C_ActionBar.SetActionBarPage` | Y | Y | Y | Y | page |
| `C_ActionBar.ShouldOverrideBarShowHealthBar` | Y | Y | Y | Y | page |
| `C_ActionBar.ShouldOverrideBarShowManaBar` | Y | Y | Y | Y | page |
| `C_ActionBar.ToggleAutoCastPetAction` | Y | Y | Y | Y | page |
| `C_ActionBar.UnregisterActionUIButton` | Y | Y | Y | Y | page |
| `C_ActionBar.UsesActionText` | Y | Y | Y | Y | page |

### C_AddOnProfiler

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AddOnProfiler.AddMeasuredCallEvent` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.AddPerformanceMessageShown` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.CheckForPerformanceMessage` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.GetAddOnMetric` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.GetApplicationMetric` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.GetOverallMetric` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.GetTicksPerSecond` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.GetTopKAddOnsForMetric` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.IsEnabled` | Y | Y | Y | Y | page |
| `C_AddOnProfiler.MeasureCall` | Y | Y | Y | Y | page |

### C_AddOns

29 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AddOns.DisableAddOn` | Y | Y | Y | Y | page |
| `C_AddOns.DisableAllAddOns` | Y | Y | Y | Y | page |
| `C_AddOns.DoesAddOnExist` | Y | Y | Y | Y | page |
| `C_AddOns.DoesAddOnHaveLoadError` | Y | Y | Y | Y | page |
| `C_AddOns.EnableAddOn` | Y | Y | Y | Y | page |
| `C_AddOns.EnableAllAddOns` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnDependencies` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnEnableState` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnInfo` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnInterfaceVersion` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnLocalTable` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnMetadata` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnName` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnNotes` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnOptionalDependencies` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnSecurity` | Y | Y | Y | Y | page |
| `C_AddOns.GetAddOnTitle` | Y | Y | Y | Y | page |
| `C_AddOns.GetNumAddOns` | Y | Y | Y | Y | page |
| `C_AddOns.GetScriptsDisallowedForBeta` | Y | Y | Y | Y | page |
| `C_AddOns.IsAddOnDefaultEnabled` | Y | Y | Y | Y | page |
| `C_AddOns.IsAddOnLoadable` | Y | Y | Y | Y | page |
| `C_AddOns.IsAddOnLoaded` | Y | Y | Y | Y | page |
| `C_AddOns.IsAddOnLoadOnDemand` | Y | Y | Y | Y | page |
| `C_AddOns.IsAddonVersionCheckEnabled` | Y | Y | Y | Y | page |
| `C_AddOns.LoadAddOn` | Y | Y | Y | Y | page |
| `C_AddOns.ResetAddOns` | Y | Y | Y | Y | page |
| `C_AddOns.ResetDisabledAddOns` | Y | Y | Y | Y | page |
| `C_AddOns.SaveAddOns` | Y | Y | Y | Y | page |
| `C_AddOns.SetAddonVersionCheck` | Y | Y | Y | Y | page |

### C_AdventureJournal

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AdventureJournal.ActivateEntry` | - | - | - | Y | missing |
| `C_AdventureJournal.CanBeShown` | - | - | - | Y | missing |
| `C_AdventureJournal.GetNumAvailableSuggestions` | - | - | - | Y | missing |
| `C_AdventureJournal.GetPrimaryOffset` | - | - | - | Y | missing |
| `C_AdventureJournal.GetReward` | - | - | - | Y | missing |
| `C_AdventureJournal.GetSuggestions` | - | - | - | Y | missing |
| `C_AdventureJournal.SetPrimaryOffset` | - | - | - | Y | missing |
| `C_AdventureJournal.UpdateSuggestions` | - | - | - | Y | missing |

### C_AdventureMap

13 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AdventureMap.Close` | - | - | - | Y | missing |
| `C_AdventureMap.GetAdventureMapTextureKit` | - | - | - | Y | page |
| `C_AdventureMap.GetMapID` | - | - | - | Y | missing |
| `C_AdventureMap.GetMapInsetDetailTileInfo` | - | - | - | Y | missing |
| `C_AdventureMap.GetMapInsetInfo` | - | - | - | Y | missing |
| `C_AdventureMap.GetNumMapInsets` | - | - | - | Y | missing |
| `C_AdventureMap.GetNumQuestOffers` | - | - | - | Y | missing |
| `C_AdventureMap.GetNumZoneChoices` | - | - | - | Y | missing |
| `C_AdventureMap.GetQuestInfo` | - | - | - | Y | missing |
| `C_AdventureMap.GetQuestOfferInfo` | - | - | - | Y | missing |
| `C_AdventureMap.GetQuestPortraitInfo` | - | - | - | Y | page |
| `C_AdventureMap.GetZoneChoiceInfo` | - | - | - | Y | missing |
| `C_AdventureMap.StartQuest` | - | - | - | Y | missing |

### C_AlliedRaces

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AlliedRaces.GetAllRacialAbilitiesFromID` | - | - | - | Y | page |
| `C_AlliedRaces.GetRaceInfoByID` | - | - | - | Y | page |

### C_AnimaDiversion

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AnimaDiversion.CloseUI` | - | - | - | Y | page |
| `C_AnimaDiversion.GetAnimaDiversionNodes` | - | - | - | Y | page |
| `C_AnimaDiversion.GetOriginPosition` | - | - | - | Y | page |
| `C_AnimaDiversion.GetReinforceProgress` | - | - | - | Y | page |
| `C_AnimaDiversion.GetTextureKit` | - | - | - | Y | page |
| `C_AnimaDiversion.OpenAnimaDiversionUI` | - | - | - | Y | page |
| `C_AnimaDiversion.SelectAnimaNode` | - | - | - | Y | page |

### C_ArdenwealdGardening

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ArdenwealdGardening.GetGardenData` | - | - | - | Y | page |
| `C_ArdenwealdGardening.IsGardenAccessible` | - | - | - | Y | page |

### C_AreaPoiInfo

9 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AreaPoiInfo.GetAreaPOIForMap` | Y | Y | Y | Y | page |
| `C_AreaPoiInfo.GetAreaPOIInfo` | Y | Y | Y | Y | page |
| `C_AreaPoiInfo.GetAreaPOISecondsLeft` | - | - | - | Y | page |
| `C_AreaPoiInfo.GetAreaPOITimeLeft` | Y | Y | Y | - | page |
| `C_AreaPoiInfo.GetDelvesForMap` | - | - | - | Y | page |
| `C_AreaPoiInfo.GetDragonridingRacesForMap` | - | - | - | Y | page |
| `C_AreaPoiInfo.GetEventsForMap` | - | - | - | Y | page |
| `C_AreaPoiInfo.GetQuestHubsForMap` | - | - | - | Y | page |
| `C_AreaPoiInfo.IsAreaPOITimed` | Y | Y | Y | Y | page |

### C_ArrowCalloutManager

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ArrowCalloutManager.AcknowledgeCallout` | Y | Y | Y | Y | missing |
| `C_ArrowCalloutManager.HideCallout` | Y | Y | Y | Y | missing |

### C_ArtifactUI

62 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ArtifactUI.AddPower` | - | - | - | Y | page |
| `C_ArtifactUI.ApplyCursorRelicToSlot` | - | - | - | Y | page |
| `C_ArtifactUI.CanApplyArtifactRelic` | - | - | - | Y | page |
| `C_ArtifactUI.CanApplyCursorRelicToSlot` | - | - | - | Y | page |
| `C_ArtifactUI.CanApplyRelicItemIDToEquippedArtifactSlot` | - | - | - | Y | page |
| `C_ArtifactUI.CanApplyRelicItemIDToSlot` | - | - | - | Y | page |
| `C_ArtifactUI.CheckRespecNPC` | - | - | - | Y | page |
| `C_ArtifactUI.Clear` | - | - | - | Y | page |
| `C_ArtifactUI.ClearForgeCamera` | - | - | - | Y | page |
| `C_ArtifactUI.ConfirmRespec` | - | - | - | Y | page |
| `C_ArtifactUI.DoesEquippedArtifactHaveAnyRelicsSlotted` | - | - | - | Y | page |
| `C_ArtifactUI.GetAppearanceInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetAppearanceInfoByID` | - | - | - | Y | page |
| `C_ArtifactUI.GetAppearanceSetInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetArtifactArtInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetArtifactInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetArtifactItemID` | - | - | - | Y | page |
| `C_ArtifactUI.GetArtifactTier` | - | - | - | Y | page |
| `C_ArtifactUI.GetArtifactXPRewardTargetInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetCostForPointAtRank` | - | - | - | Y | page |
| `C_ArtifactUI.GetEquippedArtifactArtInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetEquippedArtifactInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetEquippedArtifactItemID` | - | - | - | Y | page |
| `C_ArtifactUI.GetEquippedArtifactNumRelicSlots` | - | - | - | Y | page |
| `C_ArtifactUI.GetEquippedArtifactRelicInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetEquippedRelicLockedReason` | - | - | - | Y | page |
| `C_ArtifactUI.GetForgeRotation` | - | - | - | Y | page |
| `C_ArtifactUI.GetItemLevelIncreaseProvidedByRelic` | - | - | - | Y | page |
| `C_ArtifactUI.GetMetaPowerInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetNumAppearanceSets` | - | - | - | Y | page |
| `C_ArtifactUI.GetNumObtainedArtifacts` | - | - | - | Y | page |
| `C_ArtifactUI.GetNumRelicSlots` | - | - | - | Y | page |
| `C_ArtifactUI.GetPointsRemaining` | - | - | - | Y | page |
| `C_ArtifactUI.GetPowerHyperlink` | - | - | - | Y | page |
| `C_ArtifactUI.GetPowerInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetPowerLinks` | - | - | - | Y | page |
| `C_ArtifactUI.GetPowers` | - | - | - | Y | page |
| `C_ArtifactUI.GetPowersAffectedByRelic` | - | - | - | Y | page |
| `C_ArtifactUI.GetPowersAffectedByRelicItemLink` | - | - | - | Y | page |
| `C_ArtifactUI.GetPreviewAppearance` | - | - | - | Y | page |
| `C_ArtifactUI.GetRelicInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetRelicInfoByItemID` | - | - | - | Y | page |
| `C_ArtifactUI.GetRelicLockedReason` | - | - | - | Y | page |
| `C_ArtifactUI.GetRelicSlotType` | - | - | - | Y | page |
| `C_ArtifactUI.GetRespecArtifactArtInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetRespecArtifactInfo` | - | - | - | Y | page |
| `C_ArtifactUI.GetRespecCost` | - | - | - | Y | page |
| `C_ArtifactUI.GetTotalPowerCost` | - | - | - | Y | page |
| `C_ArtifactUI.GetTotalPurchasedRanks` | - | - | - | Y | page |
| `C_ArtifactUI.IsArtifactDisabled` | - | - | - | Y | page |
| `C_ArtifactUI.IsArtifactItem` | - | - | - | Y | page |
| `C_ArtifactUI.IsAtForge` | - | - | - | Y | page |
| `C_ArtifactUI.IsEquippedArtifactDisabled` | - | - | - | Y | page |
| `C_ArtifactUI.IsEquippedArtifactMaxed` | - | - | - | Y | page |
| `C_ArtifactUI.IsMaxedByRulesOrEffect` | - | - | - | Y | page |
| `C_ArtifactUI.IsPowerKnown` | - | - | - | Y | page |
| `C_ArtifactUI.IsViewedArtifactEquipped` | - | - | - | Y | page |
| `C_ArtifactUI.SetAppearance` | - | - | - | Y | page |
| `C_ArtifactUI.SetForgeCamera` | - | - | - | Y | page |
| `C_ArtifactUI.SetForgeRotation` | - | - | - | Y | page |
| `C_ArtifactUI.SetPreviewAppearance` | - | - | - | Y | page |
| `C_ArtifactUI.ShouldSuppressForgeRotation` | - | - | - | Y | page |

### C_AssistedCombat

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AssistedCombat.GetActionSpell` | Y | Y | Y | Y | page |
| `C_AssistedCombat.GetNextCastSpell` | Y | Y | Y | Y | page |
| `C_AssistedCombat.GetRotationSpells` | Y | Y | Y | Y | page |
| `C_AssistedCombat.IsAvailable` | Y | Y | Y | Y | page |

### C_AuctionHouse

85 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AuctionHouse.CalculateCommodityDeposit` | - | - | Y | Y | page |
| `C_AuctionHouse.CalculateItemDeposit` | - | - | Y | Y | page |
| `C_AuctionHouse.CanCancelAuction` | - | - | Y | Y | page |
| `C_AuctionHouse.CancelAuction` | - | - | Y | Y | page |
| `C_AuctionHouse.CancelCommoditiesPurchase` | - | - | Y | Y | page |
| `C_AuctionHouse.CancelSell` | - | - | Y | Y | page |
| `C_AuctionHouse.CloseAuctionHouse` | - | - | Y | Y | page |
| `C_AuctionHouse.ConfirmCommoditiesPurchase` | - | - | Y | Y | page |
| `C_AuctionHouse.ConfirmPostCommodity` | - | - | Y | Y | page |
| `C_AuctionHouse.ConfirmPostItem` | - | - | Y | Y | page |
| `C_AuctionHouse.FavoritesAreAvailable` | - | - | Y | Y | page |
| `C_AuctionHouse.GetAuctionInfoByID` | - | - | Y | Y | page |
| `C_AuctionHouse.GetAuctionItemSubClasses` | - | - | Y | Y | page |
| `C_AuctionHouse.GetAvailablePostCount` | - | - | Y | Y | page |
| `C_AuctionHouse.GetBidInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.GetBids` | - | - | Y | Y | page |
| `C_AuctionHouse.GetBidType` | - | - | Y | Y | page |
| `C_AuctionHouse.GetBrowseResults` | - | - | Y | Y | page |
| `C_AuctionHouse.GetCancelCost` | - | - | Y | Y | page |
| `C_AuctionHouse.GetCommoditySearchResultInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.GetCommoditySearchResultsQuantity` | - | - | Y | Y | page |
| `C_AuctionHouse.GetExtraBrowseInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.GetFilterGroups` | - | - | Y | Y | page |
| `C_AuctionHouse.GetItemCommodityStatus` | - | - | Y | Y | page |
| `C_AuctionHouse.GetItemKeyFromItem` | - | - | Y | Y | page |
| `C_AuctionHouse.GetItemKeyInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.GetItemKeyRequiredLevel` | - | - | Y | Y | page |
| `C_AuctionHouse.GetItemSearchResultInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.GetItemSearchResultsQuantity` | - | - | Y | Y | page |
| `C_AuctionHouse.GetMaxBidItemBid` | - | - | Y | Y | page |
| `C_AuctionHouse.GetMaxBidItemBuyout` | - | - | Y | Y | page |
| `C_AuctionHouse.GetMaxCommoditySearchResultPrice` | - | - | Y | Y | page |
| `C_AuctionHouse.GetMaxItemSearchResultBid` | - | - | Y | Y | page |
| `C_AuctionHouse.GetMaxItemSearchResultBuyout` | - | - | Y | Y | page |
| `C_AuctionHouse.GetMaxOwnedAuctionBid` | - | - | Y | Y | page |
| `C_AuctionHouse.GetMaxOwnedAuctionBuyout` | - | - | Y | Y | page |
| `C_AuctionHouse.GetNumBids` | - | - | Y | Y | page |
| `C_AuctionHouse.GetNumBidTypes` | - | - | Y | Y | page |
| `C_AuctionHouse.GetNumCommoditySearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.GetNumItemSearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.GetNumOwnedAuctions` | - | - | Y | Y | page |
| `C_AuctionHouse.GetNumOwnedAuctionTypes` | - | - | Y | Y | page |
| `C_AuctionHouse.GetNumReplicateItems` | - | - | Y | Y | page |
| `C_AuctionHouse.GetOwnedAuctionInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.GetOwnedAuctions` | - | - | Y | Y | page |
| `C_AuctionHouse.GetOwnedAuctionType` | - | - | Y | Y | page |
| `C_AuctionHouse.GetQuoteDurationRemaining` | - | - | Y | Y | page |
| `C_AuctionHouse.GetReplicateItemBattlePetInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.GetReplicateItemInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.GetReplicateItemLink` | - | - | Y | Y | page |
| `C_AuctionHouse.GetReplicateItemTimeLeft` | - | - | Y | Y | page |
| `C_AuctionHouse.GetTimeLeftBandInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.HasFavorites` | - | - | Y | Y | page |
| `C_AuctionHouse.HasFullBidResults` | - | - | Y | Y | page |
| `C_AuctionHouse.HasFullBrowseResults` | - | - | Y | Y | page |
| `C_AuctionHouse.HasFullCommoditySearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.HasFullItemSearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.HasFullOwnedAuctionResults` | - | - | Y | Y | page |
| `C_AuctionHouse.HasMaxFavorites` | - | - | Y | Y | page |
| `C_AuctionHouse.HasSearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.IsFavoriteItem` | - | - | Y | Y | page |
| `C_AuctionHouse.IsSellItemValid` | - | - | Y | Y | page |
| `C_AuctionHouse.IsThrottledMessageSystemReady` | - | - | Y | Y | page |
| `C_AuctionHouse.MakeItemKey` | - | - | Y | Y | page |
| `C_AuctionHouse.PlaceBid` | - | - | Y | Y | page |
| `C_AuctionHouse.PostCommodity` | - | - | Y | Y | page |
| `C_AuctionHouse.PostItem` | - | - | Y | Y | page |
| `C_AuctionHouse.QueryBids` | - | - | Y | Y | page |
| `C_AuctionHouse.QueryOwnedAuctions` | - | - | Y | Y | page |
| `C_AuctionHouse.RefreshCommoditySearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.RefreshItemSearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.ReplicateItems` | - | - | Y | Y | page |
| `C_AuctionHouse.RequestMoreBrowseResults` | - | - | Y | Y | page |
| `C_AuctionHouse.RequestMoreCommoditySearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.RequestMoreItemSearchResults` | - | - | Y | Y | page |
| `C_AuctionHouse.RequestOwnedAuctionBidderInfo` | - | - | Y | Y | page |
| `C_AuctionHouse.SearchForFavorites` | - | - | Y | Y | page |
| `C_AuctionHouse.SearchForItemKeys` | - | - | Y | Y | page |
| `C_AuctionHouse.SendBrowseQuery` | - | - | Y | Y | page |
| `C_AuctionHouse.SendSearchQuery` | - | - | Y | Y | page |
| `C_AuctionHouse.SendSellSearchQuery` | - | - | Y | Y | page |
| `C_AuctionHouse.SetFavoriteItem` | - | - | Y | Y | page |
| `C_AuctionHouse.ShouldAutoPopulatePrice` | - | - | Y | Y | page |
| `C_AuctionHouse.StartCommoditiesPurchase` | - | - | Y | Y | page |
| `C_AuctionHouse.SupportsCopperValues` | - | - | Y | Y | page |

### C_AuraContainerUtil

9 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AuraContainerUtil.ProcessAuraTooltipBackdropOptions` | - | - | - | Y | page |
| `C_AuraContainerUtil.ProcessAuraTooltipNineSliceOptions` | - | - | - | Y | page |
| `C_AuraContainerUtil.ProcessAuraTooltipTextureSliceOptions` | - | - | - | Y | page |
| `C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions` | - | - | - | Y | page |
| `C_AuraContainerUtil.ProcessCustomAuraButtonApplicationCountOptions` | - | - | - | Y | page |
| `C_AuraContainerUtil.ProcessCustomAuraButtonDispelTypeTextOptions` | - | - | - | Y | page |
| `C_AuraContainerUtil.ProcessCustomAuraButtonDispelTypeTextureOptions` | - | - | - | Y | page |
| `C_AuraContainerUtil.ProcessCustomAuraButtonDurationBarOptions` | - | - | - | Y | page |
| `C_AuraContainerUtil.ProcessCustomAuraButtonDurationTextOptions` | - | - | - | Y | page |

### C_AutoComplete

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AutoComplete.GetAutoCompletePresenceID` | Y | Y | Y | Y | page |
| `C_AutoComplete.GetAutoCompleteRealms` | Y | Y | Y | Y | page |
| `C_AutoComplete.GetAutoCompleteResults` | Y | Y | Y | Y | page |
| `C_AutoComplete.IsRecognizedName` | Y | Y | Y | Y | page |

### C_AzeriteEmpoweredItem

18 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AzeriteEmpoweredItem.CanSelectPower` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.ConfirmAzeriteEmpoweredItemRespec` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.GetAllTierInfo` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.GetAllTierInfoByItemID` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.GetAzeriteEmpoweredItemRespecCost` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.GetPowerInfo` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.GetPowerText` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.GetSpecsForPower` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.HasAnyUnselectedPowers` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.HasBeenViewed` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.IsAzeritePreviewSourceDisplayable` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.IsPowerAvailableForSpec` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.IsPowerSelected` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.SelectPower` | Y | Y | Y | Y | page |
| `C_AzeriteEmpoweredItem.SetHasBeenViewed` | Y | Y | Y | Y | page |

### C_AzeriteEssence

21 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AzeriteEssence.ActivateEssence` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.CanActivateEssence` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.CanDeactivateEssence` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.CanOpenUI` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.ClearPendingActivationEssence` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.CloseForge` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetEssenceHyperlink` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetEssenceInfo` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetEssences` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetMilestoneEssence` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetMilestoneInfo` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetMilestones` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetMilestoneSpell` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetNumUnlockedEssences` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetNumUsableEssences` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.GetPendingActivationEssence` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.HasNeverActivatedAnyEssences` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.HasPendingActivationEssence` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.IsAtForge` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.SetPendingActivationEssence` | Y | Y | Y | Y | page |
| `C_AzeriteEssence.UnlockMilestone` | Y | Y | Y | Y | page |

### C_AzeriteItem

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_AzeriteItem.FindActiveAzeriteItem` | Y | Y | Y | Y | page |
| `C_AzeriteItem.GetAzeriteItemXPInfo` | Y | Y | Y | Y | page |
| `C_AzeriteItem.GetPowerLevel` | Y | Y | Y | Y | page |
| `C_AzeriteItem.GetUnlimitedPowerLevel` | Y | Y | Y | Y | page |
| `C_AzeriteItem.HasActiveAzeriteItem` | Y | Y | Y | Y | page |
| `C_AzeriteItem.IsAzeriteItem` | Y | Y | Y | Y | page |
| `C_AzeriteItem.IsAzeriteItemAtMaxLevel` | Y | Y | Y | Y | page |
| `C_AzeriteItem.IsAzeriteItemByID` | Y | Y | Y | Y | page |
| `C_AzeriteItem.IsAzeriteItemEnabled` | Y | Y | Y | Y | page |
| `C_AzeriteItem.IsUnlimitedLevelingUnlocked` | Y | Y | Y | Y | page |

### C_Bank

23 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Bank.AreAnyBankTypesViewable` | - | - | - | Y | page |
| `C_Bank.AutoDepositItemsIntoBank` | - | - | - | Y | page |
| `C_Bank.CanDepositMoney` | - | - | - | Y | page |
| `C_Bank.CanPurchaseBankTab` | - | - | - | Y | page |
| `C_Bank.CanUseBank` | - | - | - | Y | page |
| `C_Bank.CanViewBank` | - | - | - | Y | page |
| `C_Bank.CanWithdrawMoney` | - | - | - | Y | page |
| `C_Bank.CloseBankFrame` | - | - | - | Y | page |
| `C_Bank.DepositMoney` | - | - | - | Y | page |
| `C_Bank.DoesBankTypeSupportAutoDeposit` | - | - | - | Y | page |
| `C_Bank.DoesBankTypeSupportMoneyTransfer` | - | - | - | Y | page |
| `C_Bank.FetchBankLockedReason` | - | - | - | Y | page |
| `C_Bank.FetchDepositedMoney` | - | - | - | Y | page |
| `C_Bank.FetchNextPurchasableBankTabData` | - | - | - | Y | page |
| `C_Bank.FetchNumPurchasedBankTabs` | - | - | - | Y | page |
| `C_Bank.FetchPurchasedBankTabData` | - | - | - | Y | page |
| `C_Bank.FetchPurchasedBankTabIDs` | - | - | - | Y | page |
| `C_Bank.FetchViewableBankTypes` | - | - | - | Y | page |
| `C_Bank.HasMaxBankTabs` | - | - | - | Y | page |
| `C_Bank.IsItemAllowedInBankType` | - | - | - | Y | page |
| `C_Bank.PurchaseBankTab` | - | - | - | Y | page |
| `C_Bank.UpdateBankTabSettings` | - | - | - | Y | page |
| `C_Bank.WithdrawMoney` | - | - | - | Y | page |

### C_BarberShop

36 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_BarberShop.ApplyCustomizationChoices` | Y | Y | Y | Y | page |
| `C_BarberShop.Cancel` | Y | Y | Y | Y | page |
| `C_BarberShop.ClearPreviewChoices` | Y | Y | Y | Y | page |
| `C_BarberShop.CycleCharCustomization` | Y | Y | Y | - | page |
| `C_BarberShop.GetAvailableCustomizations` | Y | Y | Y | Y | page |
| `C_BarberShop.GetBarbersChoiceCost` | Y | Y | Y | - | page |
| `C_BarberShop.GetCurrentCameraZoom` | Y | Y | Y | Y | page |
| `C_BarberShop.GetCurrentCharacterData` | Y | Y | Y | Y | page |
| `C_BarberShop.GetCurrentCost` | Y | Y | Y | Y | page |
| `C_BarberShop.GetCustomizationTypeInfo` | Y | Y | Y | - | page |
| `C_BarberShop.GetViewingChrModel` | Y | Y | Y | Y | page |
| `C_BarberShop.HasAlteredForm` | Y | Y | Y | Y | page |
| `C_BarberShop.HasAnyChanges` | Y | Y | Y | Y | page |
| `C_BarberShop.HasCustomizationFeature` | - | - | - | Y | page |
| `C_BarberShop.IsValidCustomizationType` | Y | Y | Y | - | page |
| `C_BarberShop.IsViewingAlteredForm` | Y | Y | Y | Y | page |
| `C_BarberShop.IsViewingNativeSex` | Y | Y | Y | - | page |
| `C_BarberShop.IsViewingVisibleSex` | Y | Y | Y | - | page |
| `C_BarberShop.MarkCustomizationChoiceAsSeen` | - | - | - | Y | page |
| `C_BarberShop.MarkCustomizationOptionAsSeen` | - | - | - | Y | page |
| `C_BarberShop.PreviewCustomizationChoice` | Y | Y | Y | Y | page |
| `C_BarberShop.RandomizeCustomizationChoices` | Y | Y | Y | Y | page |
| `C_BarberShop.ResetCameraRotation` | Y | Y | Y | Y | page |
| `C_BarberShop.ResetCustomizationChoices` | Y | Y | Y | Y | page |
| `C_BarberShop.RotateCamera` | Y | Y | Y | Y | page |
| `C_BarberShop.SaveSeenChoices` | - | - | - | Y | page |
| `C_BarberShop.SetCameraDistanceOffset` | Y | Y | Y | Y | page |
| `C_BarberShop.SetCameraZoomLevel` | Y | Y | Y | Y | page |
| `C_BarberShop.SetCustomizationChoice` | Y | Y | Y | Y | page |
| `C_BarberShop.SetModelDressState` | Y | Y | Y | Y | page |
| `C_BarberShop.SetPortraitTexture` | Y | Y | Y | - | page |
| `C_BarberShop.SetSelectedSex` | Y | Y | Y | Y | page |
| `C_BarberShop.SetViewingAlteredForm` | Y | Y | Y | Y | page |
| `C_BarberShop.SetViewingChrModel` | Y | Y | Y | Y | page |
| `C_BarberShop.SetViewingShapeshiftForm` | Y | Y | Y | Y | page |
| `C_BarberShop.ZoomCamera` | Y | Y | Y | Y | page |

### C_BattleNet

31 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_BattleNet.AreFriendTagsEnabled` | - | - | - | Y | page |
| `C_BattleNet.AreHighResTexturesInstalled` | Y | Y | Y | - | page |
| `C_BattleNet.AreTitleFriendCustomNamesEnabled` | - | - | - | Y | page |
| `C_BattleNet.AreTitleFriendsEnabled` | - | - | - | Y | page |
| `C_BattleNet.BNCheckBattleTagInviteToRecentAlly` | Y | Y | Y | Y | page |
| `C_BattleNet.BNCheckTitleFriendInviteToUnit` | - | - | - | Y | page |
| `C_BattleNet.CanToggleHighResTexturesWithoutClientReload` | - | - | Y | Y | page |
| `C_BattleNet.GetAccountInfoByGUID` | Y | Y | Y | Y | page |
| `C_BattleNet.GetAccountInfoByID` | Y | Y | Y | Y | page |
| `C_BattleNet.GetCustomTitleFriendName` | - | - | - | Y | page |
| `C_BattleNet.GetFriendAccountInfo` | Y | Y | Y | Y | page |
| `C_BattleNet.GetFriendGameAccountInfo` | Y | Y | Y | Y | page |
| `C_BattleNet.GetFriendInviteInfo` | - | - | - | Y | page |
| `C_BattleNet.GetFriendNumGameAccounts` | Y | Y | Y | Y | page |
| `C_BattleNet.GetGameAccountInfoByGUID` | Y | Y | Y | Y | page |
| `C_BattleNet.GetGameAccountInfoByID` | Y | Y | Y | Y | page |
| `C_BattleNet.InstallHighResTextures` | Y | Y | Y | Y | page |
| `C_BattleNet.InviteFriend` | Y | Y | Y | Y | page |
| `C_BattleNet.IsBattleNetFriendsListEnabled` | - | - | - | Y | page |
| `C_BattleNet.IsBattleNetFriendsListSupported` | - | - | - | Y | page |
| `C_BattleNet.SearchFriends` | - | - | - | Y | page |
| `C_BattleNet.SendGameData` | Y | Y | Y | Y | page |
| `C_BattleNet.SendTitleFriendInviteByName` | - | - | - | Y | page |
| `C_BattleNet.SendVerifiedBattleNetFriendInvite` | - | - | - | Y | page |
| `C_BattleNet.SendWhisper` | Y | Y | Y | Y | page |
| `C_BattleNet.SetAFK` | Y | Y | Y | Y | page |
| `C_BattleNet.SetAppearOffline` | - | - | - | Y | page |
| `C_BattleNet.SetCustomMessage` | Y | Y | Y | Y | page |
| `C_BattleNet.SetCustomTitleFriendName` | - | - | - | Y | page |
| `C_BattleNet.SetDND` | Y | Y | Y | Y | page |
| `C_BattleNet.SetFriendTags` | - | - | - | Y | page |

### C_BehavioralMessaging

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_BehavioralMessaging.SendNotificationReceipt` | Y | Y | Y | Y | page |

### C_BlackMarket

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_BlackMarket.Close` | Y | Y | Y | Y | page |
| `C_BlackMarket.GetHotItem` | Y | Y | Y | Y | missing |
| `C_BlackMarket.GetItemInfoByID` | Y | Y | Y | Y | page |
| `C_BlackMarket.GetItemInfoByIndex` | Y | Y | Y | Y | missing |
| `C_BlackMarket.GetNumItems` | Y | Y | Y | Y | page |
| `C_BlackMarket.IsViewOnly` | Y | Y | Y | Y | page |
| `C_BlackMarket.ItemPlaceBid` | Y | Y | Y | Y | page |
| `C_BlackMarket.RequestItems` | Y | Y | Y | Y | page |

### C_Browser

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Browser.CloseFullscreenBrowser` | - | - | - | Y | page |

### C_Calendar

90 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Calendar.AddEvent` | Y | Y | Y | Y | page |
| `C_Calendar.AreNamesReady` | Y | Y | Y | Y | page |
| `C_Calendar.CanAddEvent` | Y | Y | Y | Y | page |
| `C_Calendar.CanSendInvite` | Y | Y | Y | Y | page |
| `C_Calendar.CloseEvent` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventCanComplain` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventCanEdit` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventCanRemove` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventClipboard` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventCopy` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventGetCalendarType` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventPaste` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventRemove` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuEventSignUp` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuGetEventIndex` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuInviteAvailable` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuInviteDecline` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuInviteRemove` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuInviteTentative` | Y | Y | Y | Y | page |
| `C_Calendar.ContextMenuSelectEvent` | Y | Y | Y | Y | page |
| `C_Calendar.CreateCommunitySignUpEvent` | Y | Y | Y | Y | page |
| `C_Calendar.CreateGuildAnnouncementEvent` | Y | Y | Y | Y | page |
| `C_Calendar.CreateGuildSignUpEvent` | Y | Y | Y | Y | page |
| `C_Calendar.CreatePlayerEvent` | Y | Y | Y | Y | page |
| `C_Calendar.EventAvailable` | Y | Y | Y | Y | page |
| `C_Calendar.EventCanEdit` | Y | Y | Y | Y | page |
| `C_Calendar.EventClearAutoApprove` | Y | Y | Y | Y | page |
| `C_Calendar.EventClearLocked` | Y | Y | Y | Y | page |
| `C_Calendar.EventClearModerator` | Y | Y | Y | Y | page |
| `C_Calendar.EventDecline` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetCalendarType` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetClubId` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetInvite` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetInviteResponseTime` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetInviteSortCriterion` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetSelectedInvite` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetStatusOptions` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetTextures` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetTypes` | Y | Y | Y | Y | page |
| `C_Calendar.EventGetTypesDisplayOrdered` | Y | Y | Y | Y | page |
| `C_Calendar.EventHasPendingInvite` | Y | Y | Y | Y | page |
| `C_Calendar.EventHaveSettingsChanged` | Y | Y | Y | Y | page |
| `C_Calendar.EventInvite` | Y | Y | Y | Y | page |
| `C_Calendar.EventRemoveInvite` | Y | Y | Y | Y | page |
| `C_Calendar.EventRemoveInviteByGuid` | Y | Y | Y | Y | page |
| `C_Calendar.EventSelectInvite` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetAutoApprove` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetClubId` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetDate` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetDescription` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetInviteStatus` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetLocked` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetModerator` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetTextureID` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetTime` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetTitle` | Y | Y | Y | Y | page |
| `C_Calendar.EventSetType` | Y | Y | Y | Y | page |
| `C_Calendar.EventSignUp` | Y | Y | Y | Y | page |
| `C_Calendar.EventSortInvites` | Y | Y | Y | Y | page |
| `C_Calendar.EventTentative` | Y | Y | Y | Y | page |
| `C_Calendar.GetClubCalendarEvents` | Y | Y | Y | Y | page |
| `C_Calendar.GetDayEvent` | Y | Y | Y | Y | page |
| `C_Calendar.GetDefaultGuildFilter` | Y | Y | Y | Y | page |
| `C_Calendar.GetEventIndex` | Y | Y | Y | Y | page |
| `C_Calendar.GetEventIndexInfo` | Y | Y | Y | Y | page |
| `C_Calendar.GetEventInfo` | Y | Y | Y | Y | page |
| `C_Calendar.GetFirstPendingInvite` | Y | Y | Y | Y | page |
| `C_Calendar.GetGuildEventInfo` | Y | Y | Y | Y | page |
| `C_Calendar.GetGuildEventSelectionInfo` | Y | Y | Y | Y | page |
| `C_Calendar.GetHolidayInfo` | Y | Y | Y | Y | page |
| `C_Calendar.GetMaxCreateDate` | Y | Y | Y | Y | page |
| `C_Calendar.GetMinDate` | Y | Y | Y | Y | page |
| `C_Calendar.GetMonthInfo` | Y | Y | Y | Y | page |
| `C_Calendar.GetNextClubId` | Y | Y | Y | Y | page |
| `C_Calendar.GetNumDayEvents` | Y | Y | Y | Y | page |
| `C_Calendar.GetNumGuildEvents` | Y | Y | Y | Y | page |
| `C_Calendar.GetNumInvites` | Y | Y | Y | Y | page |
| `C_Calendar.GetNumPendingInvites` | Y | Y | Y | Y | page |
| `C_Calendar.GetRaidInfo` | Y | Y | Y | Y | page |
| `C_Calendar.IsActionPending` | Y | Y | Y | Y | page |
| `C_Calendar.IsEventOpen` | Y | Y | Y | Y | page |
| `C_Calendar.MassInviteCommunity` | Y | Y | Y | Y | page |
| `C_Calendar.MassInviteGuild` | Y | Y | Y | Y | page |
| `C_Calendar.OpenCalendar` | Y | Y | Y | Y | page |
| `C_Calendar.OpenEvent` | Y | Y | Y | Y | page |
| `C_Calendar.RemoveEvent` | Y | Y | Y | Y | page |
| `C_Calendar.SetAbsMonth` | Y | Y | Y | Y | page |
| `C_Calendar.SetMonth` | Y | Y | Y | Y | page |
| `C_Calendar.SetNextClubId` | Y | Y | Y | Y | page |
| `C_Calendar.UpdateEvent` | Y | Y | Y | Y | page |

### C_CampaignInfo

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CampaignInfo.GetAvailableCampaigns` | - | - | - | Y | page |
| `C_CampaignInfo.GetCampaignChapterInfo` | - | - | - | Y | page |
| `C_CampaignInfo.GetCampaignID` | - | - | - | Y | page |
| `C_CampaignInfo.GetCampaignInfo` | - | - | - | Y | page |
| `C_CampaignInfo.GetChapterIDs` | - | - | - | Y | page |
| `C_CampaignInfo.GetCurrentChapterID` | - | - | - | Y | page |
| `C_CampaignInfo.GetFailureReason` | - | - | - | Y | page |
| `C_CampaignInfo.GetState` | - | - | - | Y | page |
| `C_CampaignInfo.IsCampaignQuest` | - | - | - | Y | page |
| `C_CampaignInfo.SortAsNormalQuest` | - | - | - | Y | page |

### C_CatalogShop

38 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CatalogShop.BulkPurchaseProducts` | Y | Y | Y | Y | page |
| `C_CatalogShop.BulkRefundDecors` | Y | Y | Y | Y | page |
| `C_CatalogShop.CloseCatalogShopInteraction` | Y | Y | Y | Y | page |
| `C_CatalogShop.ConfirmHousingPurchase` | Y | Y | Y | Y | page |
| `C_CatalogShop.FindBestCurrencyProductForNeededAmount` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetAvailableCategoryIDs` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetAvailableTransmogRaceInfos` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetCatalogShopProductDisplayInfo` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetCategoryInfo` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetCategorySectionInfo` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetFailureInfo` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetFirstCategoryByProductID` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetNewProducts` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetProductAvailabilityTimeRemainingSecs` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetProductIDsForBundle` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetProductIDsForCategory` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetProductIDsForCategorySection` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetProductInfo` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetProductSortOrder` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetRefundableDecors` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetSectionIDsForCategory` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetSpellVisualInfoForMount` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetVCProductInfos` | Y | Y | Y | Y | page |
| `C_CatalogShop.GetVirtualCurrencyBalance` | Y | Y | Y | Y | page |
| `C_CatalogShop.HasNewProducts` | Y | Y | Y | Y | page |
| `C_CatalogShop.IsProductIncludedInAnyBundle` | Y | Y | Y | Y | page |
| `C_CatalogShop.IsShop2Enabled` | Y | Y | Y | Y | page |
| `C_CatalogShop.OnLegalDisclaimerClicked` | Y | Y | Y | Y | page |
| `C_CatalogShop.OnLegalPersonalizedOptOutClicked` | Y | Y | Y | Y | page |
| `C_CatalogShop.OpenCatalogShopInteractionFromHouse` | Y | Y | Y | Y | page |
| `C_CatalogShop.OpenCatalogShopInteractionFromShop` | Y | Y | Y | Y | page |
| `C_CatalogShop.ProductDisplayedTelemetry` | Y | Y | Y | Y | page |
| `C_CatalogShop.ProductSelectedTelemetry` | Y | Y | Y | Y | page |
| `C_CatalogShop.PurchaseProduct` | Y | Y | Y | Y | page |
| `C_CatalogShop.RefreshRefundableDecors` | Y | Y | Y | Y | page |
| `C_CatalogShop.RefreshVirtualCurrencyBalance` | Y | Y | Y | Y | page |
| `C_CatalogShop.ShouldShowHousingWarning` | Y | Y | Y | Y | page |
| `C_CatalogShop.StartHousingVCPurchaseConfirmation` | Y | Y | Y | Y | page |

### C_ChallengeMode

38 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ChallengeMode.CanUseKeystoneInCurrentMap` | - | - | - | Y | page |
| `C_ChallengeMode.ClearKeystone` | - | - | - | Y | page |
| `C_ChallengeMode.CloseKeystoneFrame` | - | - | - | Y | page |
| `C_ChallengeMode.GetActiveChallengeMapID` | Y | Y | Y | Y | page |
| `C_ChallengeMode.GetActiveKeystoneInfo` | - | - | - | Y | page |
| `C_ChallengeMode.GetAffixInfo` | - | - | - | Y | page |
| `C_ChallengeMode.GetChallengeBestTime` | Y | Y | Y | - | page |
| `C_ChallengeMode.GetChallengeCompletionInfo` | Y | Y | Y | Y | page |
| `C_ChallengeMode.GetChallengeGuildBestTimeInfo` | Y | Y | Y | - | page |
| `C_ChallengeMode.GetChallengeMapRewardInfo` | Y | Y | Y | - | page |
| `C_ChallengeMode.GetChallengeModeMapTimes` | Y | Y | Y | - | page |
| `C_ChallengeMode.GetChallengeRealmBestTimeInfo` | Y | Y | Y | - | page |
| `C_ChallengeMode.GetDeathCount` | - | - | - | Y | page |
| `C_ChallengeMode.GetDungeonScoreRarityColor` | - | - | - | Y | page |
| `C_ChallengeMode.GetGuildLeaders` | Y | Y | Y | Y | page |
| `C_ChallengeMode.GetKeystoneLevelRarityColor` | - | - | - | Y | page |
| `C_ChallengeMode.GetLeaverPenaltyWarningTimeLeft` | - | - | - | Y | page |
| `C_ChallengeMode.GetMapScoreInfo` | Y | Y | Y | Y | page |
| `C_ChallengeMode.GetMapTable` | Y | Y | Y | Y | page |
| `C_ChallengeMode.GetMapUIInfo` | Y | Y | Y | Y | page |
| `C_ChallengeMode.GetNumChallengeMapRewards` | Y | Y | Y | - | page |
| `C_ChallengeMode.GetNumMedals` | Y | Y | Y | - | missing |
| `C_ChallengeMode.GetOverallDungeonScore` | - | - | - | Y | page |
| `C_ChallengeMode.GetPowerLevelDamageHealthMod` | - | - | - | Y | page |
| `C_ChallengeMode.GetSlottedKeystoneInfo` | - | - | - | Y | page |
| `C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor` | Y | Y | Y | Y | page |
| `C_ChallengeMode.GetSpecificDungeonScoreRarityColor` | - | - | - | Y | page |
| `C_ChallengeMode.GetStartTime` | - | - | - | Y | page |
| `C_ChallengeMode.HasSlottedKeystone` | - | - | - | Y | page |
| `C_ChallengeMode.IsChallengeModeActive` | Y | Y | Y | Y | page |
| `C_ChallengeMode.IsChallengeModeEnabled` | Y | Y | Y | - | page |
| `C_ChallengeMode.IsChallengeModeResettable` | Y | Y | Y | Y | page |
| `C_ChallengeMode.RemoveKeystone` | - | - | - | Y | page |
| `C_ChallengeMode.RequestChallengeModeLeaderboard` | Y | Y | Y | - | missing |
| `C_ChallengeMode.RequestLeaders` | Y | Y | Y | Y | page |
| `C_ChallengeMode.Reset` | Y | Y | Y | Y | page |
| `C_ChallengeMode.SlotKeystone` | - | - | - | Y | page |
| `C_ChallengeMode.StartChallengeMode` | - | - | - | Y | page |

### C_CharacterServices

20 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CharacterServices.ArePaidCharacterTransfersBetweenBnetAccountsEnabled` | Y | Y | Y | Y | missing |
| `C_CharacterServices.AssignFCMDistribution` | Y | Y | Y | Y | missing |
| `C_CharacterServices.AssignNameChangeDistribution` | Y | Y | Y | Y | missing |
| `C_CharacterServices.AssignPCTDistribution` | Y | Y | Y | Y | missing |
| `C_CharacterServices.AssignRaceOrFactionChangeDistribution` | Y | Y | Y | Y | missing |
| `C_CharacterServices.AssignUpgradeDistribution` | Y | Y | Y | Y | missing |
| `C_CharacterServices.CapitalizeCharName` | Y | Y | Y | Y | missing |
| `C_CharacterServices.GetActiveCharacterUpgradeBoostType` | Y | Y | Y | Y | missing |
| `C_CharacterServices.GetActiveClassTrialBoostType` | Y | Y | Y | Y | missing |
| `C_CharacterServices.GetAutomaticBoost` | Y | Y | Y | Y | missing |
| `C_CharacterServices.GetAutomaticBoostCharacter` | Y | Y | Y | Y | missing |
| `C_CharacterServices.GetCharacterServiceDisplayData` | Y | Y | Y | Y | missing |
| `C_CharacterServices.GetCharacterServiceDisplayDataByVASType` | Y | Y | Y | Y | missing |
| `C_CharacterServices.GetCharacterServiceDisplayInfo` | Y | Y | Y | Y | missing |
| `C_CharacterServices.GetCharacterServiceDisplayOrder` | Y | Y | Y | - | missing |
| `C_CharacterServices.GetVASDistributions` | Y | Y | Y | Y | missing |
| `C_CharacterServices.HasRequiredBoostForClassTrial` | Y | Y | Y | Y | missing |
| `C_CharacterServices.HasRequiredBoostForUnrevoke` | Y | Y | Y | Y | missing |
| `C_CharacterServices.SetAutomaticBoost` | Y | Y | Y | Y | missing |
| `C_CharacterServices.SetAutomaticBoostCharacter` | Y | Y | Y | Y | missing |

### C_CharacterServicesPublic

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CharacterServicesPublic.ShouldSeeControlPopup` | Y | Y | Y | Y | missing |

### C_ChatBubbles

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ChatBubbles.GetAllChatBubbles` | Y | Y | Y | Y | page |

### C_ChatInfo

47 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ChatInfo.AreOutgoingAddonChatMessagesRestricted` | Y | Y | Y | Y | page |
| `C_ChatInfo.CancelEmote` | Y | Y | Y | Y | page |
| `C_ChatInfo.CanPlayerSpeakLanguage` | - | - | - | Y | page |
| `C_ChatInfo.CanReportPlayer` | Y | Y | Y | - | page |
| `C_ChatInfo.DropCautionaryChatMessage` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetChannelInfoFromIdentifier` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetChannelRosterInfo` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetChannelRuleset` | - | - | - | Y | page |
| `C_ChatInfo.GetChannelRulesetForChannelID` | - | - | - | Y | page |
| `C_ChatInfo.GetChannelShortcut` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetChannelShortcutForChannelID` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetChatLineSenderGUID` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetChatLineSenderName` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetChatLineText` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetChatTypeName` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetClubStreamIDs` | - | - | - | Y | page |
| `C_ChatInfo.GetColorForChatType` | - | - | - | Y | page |
| `C_ChatInfo.GetGeneralChannelID` | - | - | - | Y | page |
| `C_ChatInfo.GetGeneralChannelLocalID` | - | - | - | Y | page |
| `C_ChatInfo.GetMentorChannelID` | - | - | - | Y | page |
| `C_ChatInfo.GetNumActiveChannels` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetNumReservedChatWindows` | Y | Y | Y | Y | page |
| `C_ChatInfo.GetRegisteredAddonMessagePrefixes` | Y | Y | Y | Y | page |
| `C_ChatInfo.InChatMessagingLockdown` | Y | Y | Y | Y | page |
| `C_ChatInfo.IsAddonMessagePrefixRegistered` | Y | Y | Y | Y | page |
| `C_ChatInfo.IsChannelRegional` | - | - | - | Y | page |
| `C_ChatInfo.IsChannelRegionalForChannelID` | - | - | - | Y | page |
| `C_ChatInfo.IsChatLineCensored` | Y | Y | Y | Y | page |
| `C_ChatInfo.IsLoggingChat` | Y | Y | Y | Y | page |
| `C_ChatInfo.IsLoggingCombat` | Y | Y | Y | Y | page |
| `C_ChatInfo.IsPartyChannelType` | Y | Y | Y | Y | page |
| `C_ChatInfo.IsRegionalServiceAvailable` | - | - | - | Y | page |
| `C_ChatInfo.IsTimerunningPlayer` | Y | Y | Y | Y | page |
| `C_ChatInfo.IsValidChatLine` | Y | Y | Y | Y | page |
| `C_ChatInfo.IsValidCombatFilterName` | Y | Y | Y | Y | page |
| `C_ChatInfo.PerformEmote` | Y | Y | Y | Y | page |
| `C_ChatInfo.RegisterAddonMessagePrefix` | Y | Y | Y | Y | page |
| `C_ChatInfo.ReplaceIconAndGroupExpressions` | Y | Y | Y | Y | page |
| `C_ChatInfo.ReportServerLag` | Y | Y | Y | - | page |
| `C_ChatInfo.RequestCanLocalWhisperTarget` | - | - | - | Y | page |
| `C_ChatInfo.ResetDefaultZoneChannels` | - | - | - | Y | page |
| `C_ChatInfo.SendAddonMessage` | Y | Y | Y | Y | page |
| `C_ChatInfo.SendAddonMessageLogged` | Y | Y | Y | Y | page |
| `C_ChatInfo.SendCautionaryChatMessage` | Y | Y | Y | Y | page |
| `C_ChatInfo.SendChatMessage` | Y | Y | Y | Y | page |
| `C_ChatInfo.SwapChatChannelsByChannelIndex` | Y | Y | Y | Y | page |
| `C_ChatInfo.UncensorChatLine` | Y | Y | Y | Y | page |

### C_ChromieTime

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ChromieTime.CloseUI` | - | - | - | Y | page |
| `C_ChromieTime.GetChromieTimeExpansionOption` | - | - | - | Y | page |
| `C_ChromieTime.GetChromieTimeExpansionOptions` | - | - | - | Y | page |
| `C_ChromieTime.SelectChromieTimeOption` | - | - | - | Y | page |

### C_ClassColor

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ClassColor.GetClassColor` | Y | Y | Y | Y | page |

### C_ClassTalents

31 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ClassTalents.CanChangeTalents` | - | - | - | Y | page |
| `C_ClassTalents.CanCreateNewConfig` | - | - | - | Y | page |
| `C_ClassTalents.CanEditTalents` | - | - | - | Y | page |
| `C_ClassTalents.CommitConfig` | - | - | - | Y | page |
| `C_ClassTalents.DeleteConfig` | - | - | - | Y | page |
| `C_ClassTalents.GetActiveConfigID` | - | - | - | Y | page |
| `C_ClassTalents.GetActiveHeroTalentSpec` | - | - | - | Y | page |
| `C_ClassTalents.GetConfigIDsBySpecID` | - | - | - | Y | page |
| `C_ClassTalents.GetHasStarterBuild` | - | - | - | Y | page |
| `C_ClassTalents.GetHeroTalentSpecsForClassSpec` | - | - | - | Y | page |
| `C_ClassTalents.GetLastSelectedSavedConfigID` | - | - | - | Y | page |
| `C_ClassTalents.GetNextStarterBuildPurchase` | - | - | - | Y | page |
| `C_ClassTalents.GetStarterBuildActive` | - | - | - | Y | page |
| `C_ClassTalents.GetTraitTreeForSpec` | - | - | - | Y | page |
| `C_ClassTalents.HasUnspentHeroTalentPoints` | - | - | - | Y | page |
| `C_ClassTalents.HasUnspentTalentPoints` | - | - | - | Y | page |
| `C_ClassTalents.ImportLoadout` | - | - | - | Y | page |
| `C_ClassTalents.InitializeViewLoadout` | - | - | - | Y | page |
| `C_ClassTalents.IsConfigPopulated` | - | - | - | Y | page |
| `C_ClassTalents.LoadConfig` | - | - | - | Y | page |
| `C_ClassTalents.RenameConfig` | - | - | - | Y | page |
| `C_ClassTalents.RequestNewConfig` | - | - | - | Y | page |
| `C_ClassTalents.SaveConfig` | - | - | - | Y | page |
| `C_ClassTalents.SetStarterBuildActive` | - | - | - | Y | page |
| `C_ClassTalents.SetUsesSharedActionBars` | - | - | - | Y | page |
| `C_ClassTalents.SwitchToLoadoutByIndex` | - | - | - | Y | page |
| `C_ClassTalents.SwitchToLoadoutByName` | - | - | - | Y | page |
| `C_ClassTalents.SwitchToSpecializationByIndex` | - | - | - | Y | page |
| `C_ClassTalents.SwitchToSpecializationByName` | - | - | - | Y | page |
| `C_ClassTalents.UpdateLastSelectedSavedConfigID` | - | - | - | Y | page |
| `C_ClassTalents.ViewLoadout` | - | - | - | Y | page |

### C_ClassTrial

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ClassTrial.GetClassTrialLogoutTimeSeconds` | Y | Y | Y | Y | missing |
| `C_ClassTrial.IsClassTrialCharacter` | Y | Y | Y | Y | missing |

### C_ClickBindings

9 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ClickBindings.CanSpellBeClickBound` | - | - | - | Y | page |
| `C_ClickBindings.ExecuteBinding` | - | - | - | Y | page |
| `C_ClickBindings.GetBindingType` | - | - | - | Y | page |
| `C_ClickBindings.GetEffectiveInteractionButton` | - | - | - | Y | page |
| `C_ClickBindings.GetProfileInfo` | - | - | - | Y | page |
| `C_ClickBindings.GetTutorialShown` | - | - | - | Y | page |
| `C_ClickBindings.ResetCurrentProfile` | - | - | - | Y | page |
| `C_ClickBindings.SetProfileByInfo` | - | - | - | Y | page |
| `C_ClickBindings.SetTutorialShown` | - | - | - | Y | page |

### C_ClientScene

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ClientScene.IsSceneTypeActive` | - | - | - | Y | page |

### C_Club

84 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Club.AcceptInvitation` | Y | Y | Y | Y | page |
| `C_Club.AddClubStreamChatChannel` | Y | Y | Y | Y | page |
| `C_Club.AdvanceStreamViewMarker` | Y | Y | Y | Y | page |
| `C_Club.AreMembersReady` | Y | Y | Y | Y | page |
| `C_Club.AssignMemberRole` | Y | Y | Y | Y | page |
| `C_Club.CanResolvePlayerLocationFromClubMessageData` | Y | Y | Y | Y | page |
| `C_Club.ClearAutoAdvanceStreamViewMarker` | Y | Y | Y | Y | page |
| `C_Club.ClearClubPresenceSubscription` | Y | Y | Y | Y | page |
| `C_Club.CompareBattleNetDisplayName` | Y | Y | Y | Y | page |
| `C_Club.CreateClub` | Y | Y | Y | Y | page |
| `C_Club.CreateStream` | Y | Y | Y | Y | page |
| `C_Club.CreateTicket` | Y | Y | Y | Y | page |
| `C_Club.DeclineInvitation` | Y | Y | Y | Y | page |
| `C_Club.DestroyClub` | Y | Y | Y | Y | page |
| `C_Club.DestroyMessage` | Y | Y | Y | Y | page |
| `C_Club.DestroyStream` | Y | Y | Y | Y | page |
| `C_Club.DestroyTicket` | Y | Y | Y | Y | page |
| `C_Club.DoesAnyCommunityHaveUnreadMessages` | Y | Y | Y | Y | page |
| `C_Club.DoesCommunityHaveMembersOfTheOppositeFaction` | Y | Y | Y | Y | page |
| `C_Club.EditClub` | Y | Y | Y | Y | page |
| `C_Club.EditMessage` | Y | Y | Y | Y | page |
| `C_Club.EditStream` | Y | Y | Y | Y | page |
| `C_Club.Flush` | Y | Y | Y | Y | page |
| `C_Club.FocusCommunityStreams` | Y | Y | Y | Y | page |
| `C_Club.FocusMembers` | Y | Y | Y | Y | page |
| `C_Club.FocusStream` | Y | Y | Y | Y | page |
| `C_Club.GetAssignableRoles` | Y | Y | Y | Y | page |
| `C_Club.GetAvatarIdList` | Y | Y | Y | Y | page |
| `C_Club.GetClubCapacity` | Y | Y | Y | Y | page |
| `C_Club.GetClubInfo` | Y | Y | Y | Y | page |
| `C_Club.GetClubLimits` | Y | Y | Y | Y | page |
| `C_Club.GetClubMembers` | Y | Y | Y | Y | page |
| `C_Club.GetClubPrivileges` | Y | Y | Y | Y | page |
| `C_Club.GetClubStreamNotificationSettings` | Y | Y | Y | Y | page |
| `C_Club.GetCommunityNameResultText` | Y | Y | Y | Y | page |
| `C_Club.GetGuildClubId` | Y | Y | Y | Y | page |
| `C_Club.GetInfoFromLastCommunityChatLine` | Y | Y | Y | Y | page |
| `C_Club.GetInvitationCandidates` | Y | Y | Y | Y | page |
| `C_Club.GetInvitationInfo` | Y | Y | Y | Y | page |
| `C_Club.GetInvitationsForClub` | Y | Y | Y | Y | page |
| `C_Club.GetInvitationsForSelf` | Y | Y | Y | Y | page |
| `C_Club.GetLastTicketResponse` | Y | Y | Y | Y | page |
| `C_Club.GetMemberInfo` | Y | Y | Y | Y | page |
| `C_Club.GetMemberInfoForSelf` | Y | Y | Y | Y | page |
| `C_Club.GetMessageInfo` | Y | Y | Y | Y | page |
| `C_Club.GetMessageRanges` | Y | Y | Y | Y | page |
| `C_Club.GetMessagesBefore` | Y | Y | Y | Y | page |
| `C_Club.GetMessagesInRange` | Y | Y | Y | Y | page |
| `C_Club.GetStreamInfo` | Y | Y | Y | Y | page |
| `C_Club.GetStreams` | Y | Y | Y | Y | page |
| `C_Club.GetStreamViewMarker` | Y | Y | Y | Y | page |
| `C_Club.GetSubscribedClubs` | Y | Y | Y | Y | page |
| `C_Club.GetTickets` | Y | Y | Y | Y | page |
| `C_Club.IsAccountMuted` | Y | Y | Y | Y | page |
| `C_Club.IsBeginningOfStream` | Y | Y | Y | Y | page |
| `C_Club.IsEnabled` | Y | Y | Y | Y | page |
| `C_Club.IsRestricted` | Y | Y | Y | Y | page |
| `C_Club.IsSubscribedToStream` | Y | Y | Y | Y | page |
| `C_Club.KickMember` | Y | Y | Y | Y | page |
| `C_Club.LeaveClub` | Y | Y | Y | Y | page |
| `C_Club.RedeemTicket` | Y | Y | Y | Y | page |
| `C_Club.RequestInvitationsForClub` | Y | Y | Y | Y | page |
| `C_Club.RequestMoreMessagesBefore` | Y | Y | Y | Y | page |
| `C_Club.RequestTicket` | Y | Y | Y | Y | page |
| `C_Club.RequestTickets` | Y | Y | Y | Y | page |
| `C_Club.RevokeInvitation` | Y | Y | Y | Y | page |
| `C_Club.SendBattleTagFriendRequest` | Y | Y | Y | Y | page |
| `C_Club.SendCharacterInvitation` | Y | Y | Y | Y | page |
| `C_Club.SendInvitation` | Y | Y | Y | Y | page |
| `C_Club.SendMessage` | Y | Y | Y | Y | page |
| `C_Club.SendTitleFriendRequest` | - | - | - | Y | page |
| `C_Club.SetAutoAdvanceStreamViewMarker` | Y | Y | Y | Y | page |
| `C_Club.SetAvatarTexture` | Y | Y | Y | Y | page |
| `C_Club.SetClubMemberNote` | Y | Y | Y | Y | page |
| `C_Club.SetClubPresenceSubscription` | Y | Y | Y | Y | page |
| `C_Club.SetClubStreamNotificationSettings` | Y | Y | Y | Y | page |
| `C_Club.SetCommunityID` | Y | Y | Y | Y | page |
| `C_Club.SetFavorite` | Y | Y | Y | Y | page |
| `C_Club.SetSocialQueueingEnabled` | Y | Y | Y | Y | page |
| `C_Club.ShouldAllowClubType` | Y | Y | Y | Y | page |
| `C_Club.UnfocusAllStreams` | Y | Y | Y | Y | page |
| `C_Club.UnfocusMembers` | Y | Y | Y | Y | page |
| `C_Club.UnfocusStream` | Y | Y | Y | Y | page |
| `C_Club.ValidateText` | Y | Y | Y | Y | page |

### C_ClubFinder

55 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ClubFinder.ApplicantAcceptClubInvite` | Y | Y | Y | Y | page |
| `C_ClubFinder.ApplicantDeclineClubInvite` | Y | Y | Y | Y | page |
| `C_ClubFinder.CancelMembershipRequest` | Y | Y | Y | Y | page |
| `C_ClubFinder.CheckAllPlayerApplicantSettings` | Y | Y | Y | Y | page |
| `C_ClubFinder.ClearAllFinderCache` | Y | Y | Y | Y | page |
| `C_ClubFinder.ClearClubApplicantsCache` | Y | Y | Y | Y | page |
| `C_ClubFinder.ClearClubFinderPostingsCache` | Y | Y | Y | Y | page |
| `C_ClubFinder.DoesPlayerBelongToClubFromClubGUID` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetClubFinderDisableReason` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetClubRecruitmentSettings` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetClubTypeFromFinderGUID` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetFocusIndexFromFlag` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetPlayerApplicantLocaleFlags` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetPlayerApplicantSettings` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetPlayerClubApplicationStatus` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetPlayerSettingsFocusFlagsSelectedCount` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetPostingIDFromClubFinderGUID` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetRecruitingClubInfoFromClubID` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetRecruitingClubInfoFromFinderGUID` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetStatusOfPostingFromClubId` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetTotalMatchingCommunityListSize` | Y | Y | Y | Y | page |
| `C_ClubFinder.GetTotalMatchingGuildListSize` | Y | Y | Y | Y | page |
| `C_ClubFinder.HasAlreadyAppliedToLinkedPosting` | Y | Y | Y | Y | page |
| `C_ClubFinder.HasPostingBeenDelisted` | Y | Y | Y | Y | page |
| `C_ClubFinder.IsCommunityFinderEnabled` | Y | Y | Y | Y | page |
| `C_ClubFinder.IsEnabled` | Y | Y | Y | Y | page |
| `C_ClubFinder.IsListingEnabledFromFlags` | Y | Y | Y | Y | page |
| `C_ClubFinder.IsPostingBanned` | Y | Y | Y | Y | page |
| `C_ClubFinder.IsValidSearchString` | Y | Y | Y | Y | page |
| `C_ClubFinder.LookupClubPostingFromClubFinderGUID` | Y | Y | Y | Y | page |
| `C_ClubFinder.PlayerGetClubInvitationList` | Y | Y | Y | Y | page |
| `C_ClubFinder.PlayerRequestPendingClubsList` | Y | Y | Y | Y | page |
| `C_ClubFinder.PlayerReturnPendingCommunitiesList` | Y | Y | Y | Y | page |
| `C_ClubFinder.PlayerReturnPendingGuildsList` | Y | Y | Y | Y | page |
| `C_ClubFinder.PostClub` | Y | Y | Y | Y | page |
| `C_ClubFinder.RequestApplicantList` | Y | Y | Y | Y | page |
| `C_ClubFinder.RequestClubsList` | Y | Y | Y | Y | page |
| `C_ClubFinder.RequestMembershipToClub` | Y | Y | Y | Y | page |
| `C_ClubFinder.RequestNextCommunityPage` | Y | Y | Y | Y | page |
| `C_ClubFinder.RequestNextGuildPage` | Y | Y | Y | Y | page |
| `C_ClubFinder.RequestPostingInformationFromClubId` | Y | Y | Y | Y | page |
| `C_ClubFinder.RequestSubscribedClubPostingIDs` | Y | Y | Y | Y | page |
| `C_ClubFinder.ResetClubPostingMapCache` | Y | Y | Y | Y | page |
| `C_ClubFinder.RespondToApplicant` | Y | Y | Y | Y | page |
| `C_ClubFinder.ReturnClubApplicantList` | Y | Y | Y | Y | page |
| `C_ClubFinder.ReturnMatchingCommunityList` | Y | Y | Y | Y | page |
| `C_ClubFinder.ReturnMatchingGuildList` | Y | Y | Y | Y | page |
| `C_ClubFinder.ReturnPendingClubApplicantList` | Y | Y | Y | Y | page |
| `C_ClubFinder.SendChatWhisper` | Y | Y | Y | Y | page |
| `C_ClubFinder.SetAllRecruitmentSettings` | Y | Y | Y | Y | page |
| `C_ClubFinder.SetPlayerApplicantLocaleFlags` | Y | Y | Y | Y | page |
| `C_ClubFinder.SetPlayerApplicantSettings` | Y | Y | Y | Y | page |
| `C_ClubFinder.SetRecruitmentLocale` | Y | Y | Y | Y | page |
| `C_ClubFinder.SetRecruitmentSettings` | Y | Y | Y | Y | page |
| `C_ClubFinder.ShouldShowClubFinder` | Y | Y | Y | Y | page |

### C_ColorOverrides

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ColorOverrides.ClearColorOverrides` | - | - | - | Y | page |
| `C_ColorOverrides.GetColorForQuality` | - | - | - | Y | page |
| `C_ColorOverrides.GetColorOverrideInfo` | - | - | - | Y | page |
| `C_ColorOverrides.GetDefaultColorForQuality` | - | - | - | Y | page |
| `C_ColorOverrides.RemoveColorOverride` | - | - | - | Y | page |
| `C_ColorOverrides.SetColorOverride` | - | - | - | Y | page |

### C_ColorUtil

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ColorUtil.ConvertHSLToHSV` | Y | Y | Y | Y | page |
| `C_ColorUtil.ConvertHSVToHSL` | Y | Y | Y | Y | page |
| `C_ColorUtil.ConvertHSVToRGB` | Y | Y | Y | Y | page |
| `C_ColorUtil.ConvertRGBToHSV` | Y | Y | Y | Y | page |
| `C_ColorUtil.GenerateTextColorCode` | Y | Y | Y | Y | page |
| `C_ColorUtil.WrapTextInColor` | Y | Y | Y | Y | page |
| `C_ColorUtil.WrapTextInColorCode` | Y | Y | Y | Y | page |

### C_CombatAudioAlert

16 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CombatAudioAlert.AddToKnownTargetingList` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.GetCategoryVoice` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.GetCategoryVolume` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.GetFormatSetting` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.GetSpeakerSpeed` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.GetSpecSetting` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.GetThrottle` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.IsEnabled` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.RemoveFromKnownTargetingList` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.SetCategoryVoice` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.SetCategoryVolume` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.SetFormatSetting` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.SetSpeakerSpeed` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.SetSpecSetting` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.SetThrottle` | Y | Y | Y | Y | page |
| `C_CombatAudioAlert.SpeakText` | Y | Y | Y | Y | page |

### C_CombatLog

19 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CombatLog.AddEventFilter` | Y | Y | Y | - | page |
| `C_CombatLog.ApplyFilterSettings` | - | - | - | Y | page |
| `C_CombatLog.AreFilteredEventsEnabled` | Y | Y | Y | Y | page |
| `C_CombatLog.ClearEntries` | Y | Y | Y | Y | page |
| `C_CombatLog.ClearEventFilters` | Y | Y | Y | - | page |
| `C_CombatLog.DoesObjectMatchFilter` | Y | Y | Y | Y | page |
| `C_CombatLog.GetCurrentEntryInfo` | Y | Y | Y | - | page |
| `C_CombatLog.GetCurrentEventInfo` | Y | Y | Y | - | page |
| `C_CombatLog.GetEntryCount` | Y | Y | Y | - | page |
| `C_CombatLog.GetEntryRetentionTime` | Y | Y | Y | Y | page |
| `C_CombatLog.GetMessageLimit` | Y | Y | Y | Y | page |
| `C_CombatLog.IsCombatLogRestricted` | Y | Y | Y | Y | page |
| `C_CombatLog.RefilterEntries` | - | - | - | Y | page |
| `C_CombatLog.SeekToNewestEntry` | Y | Y | Y | - | page |
| `C_CombatLog.SeekToPreviousEntry` | Y | Y | Y | - | page |
| `C_CombatLog.SetEntryRetentionTime` | Y | Y | Y | Y | page |
| `C_CombatLog.SetFilteredEventsEnabled` | Y | Y | Y | Y | page |
| `C_CombatLog.SetMessageLimit` | Y | Y | Y | Y | page |
| `C_CombatLog.ShouldShowCurrentEntry` | Y | Y | Y | - | page |

### C_CombatText

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CombatText.GetActiveUnit` | Y | Y | Y | Y | page |
| `C_CombatText.GetCurrentEventInfo` | Y | Y | Y | Y | page |
| `C_CombatText.SetActiveUnit` | Y | Y | Y | Y | page |

### C_Commentator

144 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Commentator.AddPlayerOverrideName` | Y | Y | Y | Y | page |
| `C_Commentator.AddTrackedDefensiveAuras` | Y | Y | Y | Y | page |
| `C_Commentator.AddTrackedOffensiveAuras` | Y | Y | Y | Y | page |
| `C_Commentator.AreTeamsSwapped` | Y | Y | Y | Y | page |
| `C_Commentator.AssignPlayersToTeam` | Y | Y | Y | Y | page |
| `C_Commentator.AssignPlayersToTeamInCurrentInstance` | Y | Y | Y | Y | page |
| `C_Commentator.AssignPlayerToTeam` | Y | Y | Y | Y | page |
| `C_Commentator.CanUseCommentatorCheats` | Y | Y | Y | Y | page |
| `C_Commentator.ClearCameraTarget` | Y | Y | Y | Y | page |
| `C_Commentator.ClearFollowTarget` | Y | Y | Y | Y | page |
| `C_Commentator.ClearLookAtTarget` | Y | Y | Y | Y | page |
| `C_Commentator.EnterInstance` | Y | Y | Y | Y | page |
| `C_Commentator.ExitInstance` | Y | Y | Y | Y | page |
| `C_Commentator.FindSpectatedUnit` | Y | Y | Y | Y | page |
| `C_Commentator.FindTeamNameInCurrentInstance` | Y | Y | Y | Y | page |
| `C_Commentator.FindTeamNameInDirectory` | Y | Y | Y | Y | page |
| `C_Commentator.FlushCommentatorHistory` | Y | Y | Y | Y | page |
| `C_Commentator.FollowPlayer` | Y | Y | Y | Y | page |
| `C_Commentator.FollowUnit` | Y | Y | Y | Y | page |
| `C_Commentator.ForceFollowTransition` | Y | Y | Y | Y | page |
| `C_Commentator.GetAdditionalCameraWeight` | Y | Y | Y | Y | page |
| `C_Commentator.GetAdditionalCameraWeightByToken` | Y | Y | Y | Y | page |
| `C_Commentator.GetAllPlayerOverrideNames` | Y | Y | Y | Y | page |
| `C_Commentator.GetCamera` | Y | Y | Y | Y | page |
| `C_Commentator.GetCameraCollision` | Y | Y | Y | Y | page |
| `C_Commentator.GetCameraPosition` | Y | Y | Y | Y | page |
| `C_Commentator.GetCombatEventInfo` | Y | Y | Y | Y | page |
| `C_Commentator.GetCommentatorHistory` | Y | Y | Y | Y | page |
| `C_Commentator.GetCommentatorMatchDataState` | - | - | - | Y | page |
| `C_Commentator.GetCurrentMapID` | Y | Y | Y | Y | page |
| `C_Commentator.GetDampeningPercent` | Y | Y | Y | Y | page |
| `C_Commentator.GetDistanceBeforeForcedHorizontalConvergence` | Y | Y | Y | Y | page |
| `C_Commentator.GetDurationToForceHorizontalConvergence` | Y | Y | Y | Y | page |
| `C_Commentator.GetExcludeDistance` | Y | Y | Y | Y | page |
| `C_Commentator.GetHardlockWeight` | Y | Y | Y | Y | page |
| `C_Commentator.GetHorizontalAngleThresholdToSmooth` | Y | Y | Y | Y | page |
| `C_Commentator.GetIndirectSpellID` | Y | Y | Y | Y | page |
| `C_Commentator.GetInstanceInfo` | Y | Y | Y | Y | page |
| `C_Commentator.GetLookAtLerpAmount` | Y | Y | Y | Y | page |
| `C_Commentator.GetMapInfo` | Y | Y | Y | Y | page |
| `C_Commentator.GetMatchDuration` | Y | Y | Y | Y | page |
| `C_Commentator.GetMaxNumPlayersPerTeam` | Y | Y | Y | Y | page |
| `C_Commentator.GetMaxNumTeams` | Y | Y | Y | Y | page |
| `C_Commentator.GetMode` | Y | Y | Y | Y | page |
| `C_Commentator.GetMsToHoldForHorizontalMovement` | Y | Y | Y | Y | page |
| `C_Commentator.GetMsToHoldForVerticalMovement` | Y | Y | Y | Y | page |
| `C_Commentator.GetMsToSmoothHorizontalChange` | Y | Y | Y | Y | page |
| `C_Commentator.GetMsToSmoothVerticalChange` | Y | Y | Y | Y | page |
| `C_Commentator.GetNumMaps` | Y | Y | Y | Y | page |
| `C_Commentator.GetNumPlayers` | Y | Y | Y | Y | page |
| `C_Commentator.GetOrCreateSeries` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerAuraInfo` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerAuraInfoByUnit` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerCooldownInfo` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerCooldownInfoByUnit` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerCrowdControlInfo` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerCrowdControlInfoByUnit` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerData` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerFlagInfo` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerFlagInfoByUnit` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerItemCooldownInfo` | - | - | - | Y | page |
| `C_Commentator.GetPlayerItemCooldownInfoByUnit` | - | - | - | Y | page |
| `C_Commentator.GetPlayerOverrideName` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerSpellCharges` | Y | Y | Y | Y | page |
| `C_Commentator.GetPlayerSpellChargesByUnit` | Y | Y | Y | Y | page |
| `C_Commentator.GetPositionLerpAmount` | Y | Y | Y | Y | page |
| `C_Commentator.GetSmoothFollowTransitioning` | Y | Y | Y | Y | page |
| `C_Commentator.GetSoftlockWeight` | Y | Y | Y | Y | page |
| `C_Commentator.GetSpeedFactor` | Y | Y | Y | Y | page |
| `C_Commentator.GetStartLocation` | Y | Y | Y | Y | page |
| `C_Commentator.GetTeamColor` | Y | Y | Y | Y | page |
| `C_Commentator.GetTeamColorByUnit` | Y | Y | Y | Y | page |
| `C_Commentator.GetTimeLeftInMatch` | Y | Y | Y | Y | page |
| `C_Commentator.GetTrackedSpellID` | Y | Y | Y | Y | page |
| `C_Commentator.GetTrackedSpells` | Y | Y | Y | Y | page |
| `C_Commentator.GetTrackedSpellsByUnit` | Y | Y | Y | Y | page |
| `C_Commentator.GetUnitData` | Y | Y | Y | Y | page |
| `C_Commentator.GetWargameInfo` | Y | Y | Y | Y | page |
| `C_Commentator.HasTrackedAuras` | Y | Y | Y | Y | page |
| `C_Commentator.IsSmartCameraLocked` | Y | Y | Y | Y | page |
| `C_Commentator.IsSpectating` | Y | Y | Y | Y | page |
| `C_Commentator.IsTrackedDefensiveAura` | Y | Y | Y | Y | page |
| `C_Commentator.IsTrackedOffensiveAura` | Y | Y | Y | Y | page |
| `C_Commentator.IsTrackedSpell` | Y | Y | Y | Y | page |
| `C_Commentator.IsTrackedSpellByUnit` | Y | Y | Y | Y | page |
| `C_Commentator.IsUsingSmartCamera` | Y | Y | Y | Y | page |
| `C_Commentator.LookAtPlayer` | Y | Y | Y | Y | page |
| `C_Commentator.RemoveAllOverrideNames` | Y | Y | Y | Y | page |
| `C_Commentator.RemovePlayerOverrideName` | Y | Y | Y | Y | page |
| `C_Commentator.RequestPlayerCooldownInfo` | Y | Y | Y | Y | page |
| `C_Commentator.ResetFoVTarget` | Y | Y | Y | Y | page |
| `C_Commentator.ResetSeriesScores` | Y | Y | Y | Y | page |
| `C_Commentator.ResetSettings` | Y | Y | Y | Y | page |
| `C_Commentator.ResetTrackedAuras` | Y | Y | Y | Y | page |
| `C_Commentator.SendAddonMessage` | - | - | - | Y | page |
| `C_Commentator.SendAddonMessageLogged` | - | - | - | Y | page |
| `C_Commentator.SetAdditionalCameraWeight` | Y | Y | Y | Y | page |
| `C_Commentator.SetAdditionalCameraWeightByToken` | Y | Y | Y | Y | page |
| `C_Commentator.SetBlocklistedAuras` | Y | Y | Y | Y | page |
| `C_Commentator.SetBlocklistedCooldowns` | Y | Y | Y | Y | page |
| `C_Commentator.SetBlocklistedItemCooldowns` | - | - | - | Y | page |
| `C_Commentator.SetCamera` | Y | Y | Y | Y | page |
| `C_Commentator.SetCameraCollision` | Y | Y | Y | Y | page |
| `C_Commentator.SetCameraPosition` | Y | Y | Y | Y | page |
| `C_Commentator.SetCheatsEnabled` | Y | Y | Y | Y | page |
| `C_Commentator.SetCommentatorHistory` | Y | Y | Y | Y | page |
| `C_Commentator.SetDistanceBeforeForcedHorizontalConvergence` | Y | Y | Y | Y | page |
| `C_Commentator.SetDurationToForceHorizontalConvergence` | Y | Y | Y | Y | page |
| `C_Commentator.SetExcludeDistance` | Y | Y | Y | Y | page |
| `C_Commentator.SetFollowCameraSpeeds` | Y | Y | Y | Y | page |
| `C_Commentator.SetHardlockWeight` | Y | Y | Y | Y | page |
| `C_Commentator.SetHorizontalAngleThresholdToSmooth` | Y | Y | Y | Y | page |
| `C_Commentator.SetLookAtLerpAmount` | Y | Y | Y | Y | page |
| `C_Commentator.SetMapAndInstanceIndex` | Y | Y | Y | Y | page |
| `C_Commentator.SetMouseDisabled` | Y | Y | Y | Y | page |
| `C_Commentator.SetMoveSpeed` | Y | Y | Y | Y | page |
| `C_Commentator.SetMsToHoldForHorizontalMovement` | Y | Y | Y | Y | page |
| `C_Commentator.SetMsToHoldForVerticalMovement` | Y | Y | Y | Y | page |
| `C_Commentator.SetMsToSmoothHorizontalChange` | Y | Y | Y | Y | page |
| `C_Commentator.SetMsToSmoothVerticalChange` | Y | Y | Y | Y | page |
| `C_Commentator.SetPositionLerpAmount` | Y | Y | Y | Y | page |
| `C_Commentator.SetRequestedDebuffCooldowns` | Y | Y | Y | Y | page |
| `C_Commentator.SetRequestedDefensiveCooldowns` | Y | Y | Y | Y | page |
| `C_Commentator.SetRequestedItemCooldowns` | - | - | - | Y | page |
| `C_Commentator.SetRequestedOffensiveCooldowns` | Y | Y | Y | Y | page |
| `C_Commentator.SetSeriesScore` | Y | Y | Y | Y | page |
| `C_Commentator.SetSeriesScores` | Y | Y | Y | Y | page |
| `C_Commentator.SetSmartCameraLocked` | Y | Y | Y | Y | page |
| `C_Commentator.SetSmoothFollowTransitioning` | Y | Y | Y | Y | page |
| `C_Commentator.SetSoftlockWeight` | Y | Y | Y | Y | page |
| `C_Commentator.SetSpeedFactor` | Y | Y | Y | Y | page |
| `C_Commentator.SetTargetHeightOffset` | Y | Y | Y | Y | page |
| `C_Commentator.SetUseSmartCamera` | Y | Y | Y | Y | page |
| `C_Commentator.SnapCameraLookAtPoint` | Y | Y | Y | Y | page |
| `C_Commentator.SpellUsesItemCharges` | - | - | - | Y | page |
| `C_Commentator.StartWargame` | Y | Y | Y | Y | page |
| `C_Commentator.SwapTeamSides` | Y | Y | Y | Y | page |
| `C_Commentator.ToggleCheats` | Y | Y | Y | Y | page |
| `C_Commentator.UpdateMapInfo` | Y | Y | Y | Y | page |
| `C_Commentator.UpdatePlayerInfo` | Y | Y | Y | Y | page |
| `C_Commentator.ZoomIn` | Y | Y | Y | Y | page |
| `C_Commentator.ZoomIn_Position` | - | - | - | Y | page |
| `C_Commentator.ZoomOut` | Y | Y | Y | Y | page |
| `C_Commentator.ZoomOut_Position` | - | - | - | Y | page |

### C_ConsoleScriptCollection

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ConsoleScriptCollection.GetCollectionDataByID` | Y | Y | Y | Y | page |
| `C_ConsoleScriptCollection.GetCollectionDataByTag` | Y | Y | Y | Y | page |
| `C_ConsoleScriptCollection.GetElements` | Y | Y | Y | Y | page |
| `C_ConsoleScriptCollection.GetScriptData` | Y | Y | Y | Y | page |

### C_Container

49 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Container.CalculateTotalNumberOfFreeBagSlots` | Y | Y | Y | Y | page |
| `C_Container.ContainerIDToInventoryID` | Y | Y | Y | Y | page |
| `C_Container.ContainerRefundItemPurchase` | Y | Y | Y | Y | page |
| `C_Container.GetBackpackAutosortDisabled` | - | - | - | Y | page |
| `C_Container.GetBackpackSellJunkDisabled` | - | - | - | Y | page |
| `C_Container.GetBagName` | Y | Y | Y | Y | page |
| `C_Container.GetBagSlotFlag` | Y | Y | Y | Y | page |
| `C_Container.GetBankAutosortDisabled` | - | - | - | Y | page |
| `C_Container.GetContainerFreeSlots` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemCooldown` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemDurability` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemEquipmentSetInfo` | - | - | - | Y | page |
| `C_Container.GetContainerItemGems` | Y | Y | Y | - | page |
| `C_Container.GetContainerItemID` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemInfo` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemLink` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemPurchaseCurrency` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemPurchaseInfo` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemPurchaseItem` | Y | Y | Y | Y | page |
| `C_Container.GetContainerItemQuestInfo` | Y | Y | Y | Y | page |
| `C_Container.GetContainerNumFreeSlots` | Y | Y | Y | Y | page |
| `C_Container.GetContainerNumSlots` | Y | Y | Y | Y | page |
| `C_Container.GetInsertItemsLeftToRight` | Y | Y | Y | Y | page |
| `C_Container.GetItemCooldown` | Y | Y | Y | Y | page |
| `C_Container.GetMaxArenaCurrency` | - | - | - | Y | page |
| `C_Container.GetSortBagsRightToLeft` | - | - | - | Y | page |
| `C_Container.HasContainerItem` | Y | Y | Y | Y | page |
| `C_Container.IsBagSlotFlagEnabledOnOtherBankBags` | Y | Y | Y | - | page |
| `C_Container.IsBattlePayItem` | - | - | - | Y | page |
| `C_Container.IsContainerFiltered` | Y | Y | Y | Y | page |
| `C_Container.PickupContainerItem` | Y | Y | Y | Y | page |
| `C_Container.PlayerHasHearthstone` | - | - | - | Y | page |
| `C_Container.SetBackpackAutosortDisabled` | - | - | - | Y | page |
| `C_Container.SetBackpackSellJunkDisabled` | - | - | - | Y | page |
| `C_Container.SetBagPortraitTexture` | Y | Y | Y | Y | page |
| `C_Container.SetBagSlotFlag` | Y | Y | Y | Y | page |
| `C_Container.SetBankAutosortDisabled` | - | - | - | Y | page |
| `C_Container.SetInsertItemsLeftToRight` | Y | Y | Y | Y | page |
| `C_Container.SetItemSearch` | Y | Y | Y | Y | page |
| `C_Container.SetSortBagsRightToLeft` | - | - | - | Y | page |
| `C_Container.ShowContainerSellCursor` | Y | Y | Y | Y | page |
| `C_Container.SocketContainerItem` | Y | Y | Y | Y | page |
| `C_Container.SortAccountBankBags` | - | - | - | Y | page |
| `C_Container.SortBags` | - | - | - | Y | page |
| `C_Container.SortBank` | - | - | - | Y | page |
| `C_Container.SortBankBags` | - | - | - | Y | page |
| `C_Container.SplitContainerItem` | Y | Y | Y | Y | page |
| `C_Container.UseContainerItem` | Y | Y | Y | Y | page |
| `C_Container.UseHearthstone` | - | - | - | Y | page |

### C_ContentTracking

18 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ContentTracking.GetBestMapForTrackable` | - | - | - | Y | page |
| `C_ContentTracking.GetCollectableSourceTrackingEnabled` | - | - | - | Y | page |
| `C_ContentTracking.GetCollectableSourceTypes` | - | - | - | Y | page |
| `C_ContentTracking.GetCurrentTrackingTarget` | - | - | - | Y | page |
| `C_ContentTracking.GetEncounterTrackingInfo` | - | - | - | Y | page |
| `C_ContentTracking.GetNextWaypointForTrackable` | - | - | - | Y | page |
| `C_ContentTracking.GetObjectiveText` | - | - | - | Y | page |
| `C_ContentTracking.GetTitle` | - | - | - | Y | page |
| `C_ContentTracking.GetTrackablesOnMap` | - | - | - | Y | page |
| `C_ContentTracking.GetTrackedIDs` | - | - | - | Y | page |
| `C_ContentTracking.GetVendorTrackingInfo` | - | - | - | Y | page |
| `C_ContentTracking.GetWaypointText` | - | - | - | Y | page |
| `C_ContentTracking.IsNavigable` | - | - | - | Y | page |
| `C_ContentTracking.IsTrackable` | - | - | - | Y | page |
| `C_ContentTracking.IsTracking` | - | - | - | Y | page |
| `C_ContentTracking.StartTracking` | - | - | - | Y | page |
| `C_ContentTracking.StopTracking` | - | - | - | Y | page |
| `C_ContentTracking.ToggleTracking` | - | - | - | Y | page |

### C_ContributionCollector

18 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ContributionCollector.Close` | - | - | - | Y | page |
| `C_ContributionCollector.Contribute` | - | - | - | Y | page |
| `C_ContributionCollector.GetActive` | - | - | - | Y | page |
| `C_ContributionCollector.GetAtlases` | - | - | - | Y | page |
| `C_ContributionCollector.GetBuffs` | - | - | - | Y | page |
| `C_ContributionCollector.GetContributionAppearance` | - | - | - | Y | page |
| `C_ContributionCollector.GetContributionCollectorsForMap` | - | - | - | Y | page |
| `C_ContributionCollector.GetContributionResult` | - | - | - | Y | page |
| `C_ContributionCollector.GetDescription` | - | - | - | Y | page |
| `C_ContributionCollector.GetManagedContributionsForCreatureID` | - | - | - | Y | page |
| `C_ContributionCollector.GetName` | - | - | - | Y | page |
| `C_ContributionCollector.GetOrderIndex` | - | - | - | Y | page |
| `C_ContributionCollector.GetRequiredContributionCurrency` | - | - | - | Y | page |
| `C_ContributionCollector.GetRequiredContributionItem` | - | - | - | Y | page |
| `C_ContributionCollector.GetRewardQuestID` | - | - | - | Y | page |
| `C_ContributionCollector.GetState` | - | - | - | Y | page |
| `C_ContributionCollector.HasPendingContribution` | - | - | - | Y | page |
| `C_ContributionCollector.IsAwaitingRewardQuestData` | - | - | - | Y | page |

### C_CooldownViewer

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CooldownViewer.GetCooldownViewerCategorySet` | Y | Y | Y | Y | page |
| `C_CooldownViewer.GetCooldownViewerCooldownInfo` | Y | Y | Y | Y | page |
| `C_CooldownViewer.GetGroupBuffItems` | - | - | - | Y | page |
| `C_CooldownViewer.GetLayoutData` | Y | Y | Y | Y | page |
| `C_CooldownViewer.GetValidAlertTypes` | Y | Y | Y | Y | page |
| `C_CooldownViewer.IsCooldownViewerAvailable` | Y | Y | Y | Y | page |
| `C_CooldownViewer.SetLayoutData` | Y | Y | Y | Y | page |

### C_CovenantCallings

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CovenantCallings.AreCallingsUnlocked` | - | - | - | Y | page |
| `C_CovenantCallings.RequestCallings` | - | - | - | Y | page |

### C_CovenantPreview

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CovenantPreview.CloseFromUI` | - | - | - | Y | page |
| `C_CovenantPreview.GetCovenantInfoForPlayerChoiceResponseID` | - | - | - | Y | page |

### C_Covenants

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Covenants.GetActiveCovenantID` | - | - | - | Y | page |
| `C_Covenants.GetCovenantData` | - | - | - | Y | page |
| `C_Covenants.GetCovenantIDs` | - | - | - | Y | page |

### C_CovenantSanctumUI

16 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CovenantSanctumUI.CanAccessReservoir` | - | - | - | Y | page |
| `C_CovenantSanctumUI.CanDepositAnima` | - | - | - | Y | page |
| `C_CovenantSanctumUI.DepositAnima` | - | - | - | Y | page |
| `C_CovenantSanctumUI.EndInteraction` | - | - | - | Y | page |
| `C_CovenantSanctumUI.GetAnimaInfo` | - | - | - | Y | page |
| `C_CovenantSanctumUI.GetCurrentTalentTreeID` | - | - | - | Y | page |
| `C_CovenantSanctumUI.GetFeatures` | - | - | - | Y | page |
| `C_CovenantSanctumUI.GetRenownLevel` | - | - | - | Y | page |
| `C_CovenantSanctumUI.GetRenownLevels` | - | - | - | Y | page |
| `C_CovenantSanctumUI.GetRenownRewardsForLevel` | - | - | - | Y | page |
| `C_CovenantSanctumUI.GetSanctumType` | - | - | - | Y | page |
| `C_CovenantSanctumUI.GetSoulCurrencies` | - | - | - | Y | page |
| `C_CovenantSanctumUI.HasMaximumRenown` | - | - | - | Y | page |
| `C_CovenantSanctumUI.IsPlayerInRenownCatchUpMode` | - | - | - | Y | page |
| `C_CovenantSanctumUI.IsWeeklyRenownCapped` | - | - | - | Y | page |
| `C_CovenantSanctumUI.RequestCatchUpState` | - | - | - | Y | page |

### C_CraftingOrders

36 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CraftingOrders.AreOrderNotesDisabled` | - | - | - | Y | page |
| `C_CraftingOrders.CalculateCraftingOrderPostingFee` | - | - | - | Y | page |
| `C_CraftingOrders.CancelOrder` | - | - | - | Y | page |
| `C_CraftingOrders.CanOrderSkillAbility` | - | - | - | Y | page |
| `C_CraftingOrders.ClaimOrder` | - | - | - | Y | page |
| `C_CraftingOrders.CloseCrafterCraftingOrders` | - | - | - | Y | page |
| `C_CraftingOrders.CloseCustomerCraftingOrders` | - | - | - | Y | page |
| `C_CraftingOrders.FulfillOrder` | - | - | - | Y | page |
| `C_CraftingOrders.GetClaimedOrder` | - | - | - | Y | page |
| `C_CraftingOrders.GetCrafterBuckets` | - | - | - | Y | page |
| `C_CraftingOrders.GetCrafterOrders` | - | - | - | Y | page |
| `C_CraftingOrders.GetCraftingOrderTime` | - | - | - | Y | page |
| `C_CraftingOrders.GetCustomerCategories` | - | - | - | Y | page |
| `C_CraftingOrders.GetCustomerOptions` | - | - | - | Y | page |
| `C_CraftingOrders.GetCustomerOrders` | - | - | - | Y | page |
| `C_CraftingOrders.GetDefaultOrdersSkillLine` | - | - | - | Y | page |
| `C_CraftingOrders.GetMyOrders` | - | - | - | Y | page |
| `C_CraftingOrders.GetNumFavoriteCustomerOptions` | - | - | - | Y | page |
| `C_CraftingOrders.GetOrderClaimInfo` | - | - | - | Y | page |
| `C_CraftingOrders.GetPersonalOrdersInfo` | - | - | - | Y | page |
| `C_CraftingOrders.HasFavoriteCustomerOptions` | - | - | - | Y | page |
| `C_CraftingOrders.IsCustomerOptionFavorited` | - | - | - | Y | page |
| `C_CraftingOrders.ListMyOrders` | - | - | - | Y | page |
| `C_CraftingOrders.OpenCrafterCraftingOrders` | - | - | - | Y | page |
| `C_CraftingOrders.OpenCustomerCraftingOrders` | - | - | - | Y | page |
| `C_CraftingOrders.OrderCanBeRecrafted` | - | - | - | Y | page |
| `C_CraftingOrders.ParseCustomerOptions` | - | - | - | Y | page |
| `C_CraftingOrders.PlaceNewOrder` | - | - | - | Y | page |
| `C_CraftingOrders.RejectOrder` | - | - | - | Y | page |
| `C_CraftingOrders.ReleaseOrder` | - | - | - | Y | page |
| `C_CraftingOrders.RequestCrafterOrders` | - | - | - | Y | page |
| `C_CraftingOrders.RequestCustomerOrders` | - | - | - | Y | page |
| `C_CraftingOrders.SetCustomerOptionFavorited` | - | - | - | Y | page |
| `C_CraftingOrders.ShouldShowCraftingOrderTab` | - | - | - | Y | page |
| `C_CraftingOrders.SkillLineHasOrders` | - | - | - | Y | page |
| `C_CraftingOrders.UpdateIgnoreList` | - | - | - | Y | page |

### C_CreatureInfo

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CreatureInfo.GetClassInfo` | Y | Y | Y | Y | page |
| `C_CreatureInfo.GetCreatureFamilyIDs` | Y | Y | Y | Y | page |
| `C_CreatureInfo.GetCreatureFamilyInfo` | Y | Y | Y | Y | page |
| `C_CreatureInfo.GetCreatureID` | Y | Y | Y | Y | page |
| `C_CreatureInfo.GetCreatureTypeIDs` | Y | Y | Y | Y | page |
| `C_CreatureInfo.GetCreatureTypeInfo` | Y | Y | Y | Y | page |
| `C_CreatureInfo.GetFactionInfo` | Y | Y | Y | Y | page |
| `C_CreatureInfo.GetRaceInfo` | Y | Y | Y | Y | page |

### C_CurrencyInfo

43 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CurrencyInfo.CanTransferCurrency` | - | - | - | Y | page |
| `C_CurrencyInfo.DoesCurrentFilterRequireAccountCurrencyData` | - | - | - | Y | page |
| `C_CurrencyInfo.DoesWarModeBonusApply` | - | - | - | Y | page |
| `C_CurrencyInfo.ExpandCurrencyList` | - | - | - | Y | page |
| `C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters` | - | - | - | Y | page |
| `C_CurrencyInfo.FetchCurrencyTransferTransactions` | - | - | - | Y | page |
| `C_CurrencyInfo.GetAzeriteCurrencyID` | - | - | - | Y | page |
| `C_CurrencyInfo.GetBackpackCurrencyInfo` | - | - | - | Y | page |
| `C_CurrencyInfo.GetBasicCurrencyInfo` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.GetCoinIcon` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.GetCoinText` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.GetCoinTextureString` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.GetCostToTransferCurrency` | - | - | - | Y | page |
| `C_CurrencyInfo.GetCurrencyContainerInfo` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.GetCurrencyDescription` | - | - | - | Y | page |
| `C_CurrencyInfo.GetCurrencyFilter` | - | - | - | Y | page |
| `C_CurrencyInfo.GetCurrencyIDFromLink` | - | - | - | Y | page |
| `C_CurrencyInfo.GetCurrencyInfo` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.GetCurrencyInfoFromLink` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.GetCurrencyLink` | - | - | - | Y | page |
| `C_CurrencyInfo.GetCurrencyListInfo` | - | - | - | Y | page |
| `C_CurrencyInfo.GetCurrencyListLink` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.GetCurrencyListSize` | - | - | - | Y | page |
| `C_CurrencyInfo.GetDragonIslesSuppliesCurrencyID` | - | - | - | Y | page |
| `C_CurrencyInfo.GetFactionGrantedByCurrency` | - | - | - | Y | page |
| `C_CurrencyInfo.GetMaxTransferableAmountFromQuantity` | - | - | - | Y | page |
| `C_CurrencyInfo.GetPlayerCurrencyCategoryInfo` | - | - | - | Y | page |
| `C_CurrencyInfo.GetWarResourcesCurrencyID` | - | - | - | Y | page |
| `C_CurrencyInfo.IsAccountCharacterCurrencyDataReady` | - | - | - | Y | page |
| `C_CurrencyInfo.IsAccountTransferableCurrency` | - | - | - | Y | page |
| `C_CurrencyInfo.IsAccountWideCurrency` | - | - | - | Y | page |
| `C_CurrencyInfo.IsCurrencyContainer` | Y | Y | Y | Y | page |
| `C_CurrencyInfo.IsCurrencyTransferInProgress` | - | - | - | Y | page |
| `C_CurrencyInfo.IsCurrencyTransferTransactionDataReady` | - | - | - | Y | page |
| `C_CurrencyInfo.PickupCurrency` | - | - | - | Y | page |
| `C_CurrencyInfo.PlayerHasMaxQuantity` | - | - | - | Y | page |
| `C_CurrencyInfo.PlayerHasMaxWeeklyQuantity` | - | - | - | Y | page |
| `C_CurrencyInfo.RequestCurrencyDataForAccountCharacters` | - | - | - | Y | page |
| `C_CurrencyInfo.RequestCurrencyFromAccountCharacter` | - | - | - | Y | page |
| `C_CurrencyInfo.SetCurrencyBackpack` | - | - | - | Y | page |
| `C_CurrencyInfo.SetCurrencyBackpackByID` | - | - | - | Y | page |
| `C_CurrencyInfo.SetCurrencyFilter` | - | - | - | Y | page |
| `C_CurrencyInfo.SetCurrencyUnused` | - | - | - | Y | page |

### C_Cursor

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Cursor.GetCursorItem` | Y | Y | Y | Y | page |

### C_CurveUtil

5 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CurveUtil.CreateColorCurve` | Y | Y | Y | Y | page |
| `C_CurveUtil.CreateCurve` | Y | Y | Y | Y | page |
| `C_CurveUtil.EvaluateColorFromBoolean` | Y | Y | Y | Y | page |
| `C_CurveUtil.EvaluateColorValueFromBoolean` | Y | Y | Y | Y | page |
| `C_CurveUtil.EvaluateGameCurve` | Y | Y | Y | Y | page |

### C_CVar

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_CVar.AreCVarsLoaded` | - | - | - | Y | page |
| `C_CVar.GetCVar` | Y | Y | Y | Y | page |
| `C_CVar.GetCVarBitfield` | Y | Y | Y | Y | page |
| `C_CVar.GetCVarBool` | Y | Y | Y | Y | page |
| `C_CVar.GetCVarDefault` | Y | Y | Y | Y | page |
| `C_CVar.GetCVarInfo` | Y | Y | Y | Y | page |
| `C_CVar.RegisterCVar` | Y | Y | Y | Y | page |
| `C_CVar.ResetTestCVars` | Y | Y | Y | Y | page |
| `C_CVar.SetCVar` | Y | Y | Y | Y | page |
| `C_CVar.SetCVarBitfield` | Y | Y | Y | Y | page |

### C_DamageMeter

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_DamageMeter.GetAvailableCombatSessions` | Y | Y | Y | Y | page |
| `C_DamageMeter.GetCombatSessionFromID` | Y | Y | Y | Y | page |
| `C_DamageMeter.GetCombatSessionFromType` | Y | Y | Y | Y | page |
| `C_DamageMeter.GetCombatSessionSourceFromID` | Y | Y | Y | Y | page |
| `C_DamageMeter.GetCombatSessionSourceFromType` | Y | Y | Y | Y | page |
| `C_DamageMeter.GetSessionDurationSeconds` | Y | Y | Y | Y | page |
| `C_DamageMeter.IsDamageMeterAvailable` | Y | Y | Y | Y | page |
| `C_DamageMeter.ResetAllCombatSessions` | Y | Y | Y | Y | page |

### C_DateAndTime

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_DateAndTime.AdjustTimeByDays` | Y | Y | Y | Y | page |
| `C_DateAndTime.AdjustTimeByMinutes` | Y | Y | Y | Y | page |
| `C_DateAndTime.AdjustTimeByMonths` | - | - | - | Y | page |
| `C_DateAndTime.CompareCalendarTime` | Y | Y | Y | Y | page |
| `C_DateAndTime.GetCalendarTimeFromEpoch` | Y | Y | Y | Y | page |
| `C_DateAndTime.GetCurrentCalendarTime` | Y | Y | Y | Y | page |
| `C_DateAndTime.GetSecondsUntilDailyReset` | Y | Y | Y | Y | page |
| `C_DateAndTime.GetSecondsUntilWeeklyReset` | Y | Y | Y | Y | page |
| `C_DateAndTime.GetServerTimeLocal` | Y | Y | Y | Y | page |
| `C_DateAndTime.GetWeeklyResetStartTime` | - | - | - | Y | page |

### C_DeathInfo

5 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_DeathInfo.GetCorpseMapPosition` | Y | Y | Y | Y | page |
| `C_DeathInfo.GetDeathReleasePosition` | Y | Y | Y | Y | page |
| `C_DeathInfo.GetGraveyardsForMap` | Y | Y | Y | Y | page |
| `C_DeathInfo.GetSelfResurrectOptions` | Y | Y | Y | Y | page |
| `C_DeathInfo.UseSelfResurrectOption` | Y | Y | Y | Y | page |

### C_DeathRecap

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_DeathRecap.GetRecapEvents` | Y | Y | Y | Y | page |
| `C_DeathRecap.GetRecapLink` | Y | Y | Y | Y | page |
| `C_DeathRecap.GetRecapMaxHealth` | Y | Y | Y | Y | page |
| `C_DeathRecap.HasRecapEvents` | Y | Y | Y | Y | page |

### C_Debug

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Debug.DashboardIsEnabled` | Y | Y | Y | Y | missing |
| `C_Debug.FrameXMLDebug` | Y | Y | Y | Y | page |
| `C_Debug.GetAllPortLocsForMap` | Y | Y | Y | Y | missing |
| `C_Debug.GetMapDebugObjects` | Y | Y | Y | Y | missing |
| `C_Debug.TeleportToMapDebugObject` | Y | Y | Y | Y | missing |
| `C_Debug.TeleportToMapLocation` | Y | Y | Y | Y | missing |
| `C_Debug.ToggleDebugCharInfo` | Y | Y | Y | Y | missing |
| `C_Debug.ToggleWindDebugMenu` | Y | Y | Y | Y | missing |

### C_DelvesUI

40 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_DelvesUI.GetActiveDelveTier` | - | - | - | Y | page |
| `C_DelvesUI.GetCompanionInfoForActivePlayer` | - | - | - | Y | page |
| `C_DelvesUI.GetCreatureDisplayInfoForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetCurioLink` | - | - | - | Y | page |
| `C_DelvesUI.GetCurioNodeForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetCurioRarityByTraitCondAccountElementID` | - | - | - | Y | page |
| `C_DelvesUI.GetCurrentDelvesSeasonNumber` | - | - | - | Y | page |
| `C_DelvesUI.GetDelveEntranceBackgroundWidgetSetID` | - | - | - | Y | page |
| `C_DelvesUI.GetDelveEntranceDescriptionString` | - | - | - | Y | page |
| `C_DelvesUI.GetDelveEntranceHeaderString` | - | - | - | Y | page |
| `C_DelvesUI.GetDelveEntranceMapID` | - | - | - | Y | page |
| `C_DelvesUI.GetDelveEntranceTiers` | - | - | - | Y | page |
| `C_DelvesUI.GetDelveEntranceTitleString` | - | - | - | Y | page |
| `C_DelvesUI.GetDelvesAffixSpellsForSeason` | - | - | - | Y | page |
| `C_DelvesUI.GetDelvesFactionForSeason` | - | - | - | Y | page |
| `C_DelvesUI.GetDelvesMinRequiredLevel` | - | - | - | Y | page |
| `C_DelvesUI.GetFactionForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetFlavorNodeForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetFlavorNodeNameForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetLockedTextForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetModelSceneForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetPlayerCompanionPDEID` | - | - | - | Y | page |
| `C_DelvesUI.GetRoleNodeForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetRoleSubtreeForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetTieredEntranceOptionalAffixTraitTreeID` | - | - | - | Y | page |
| `C_DelvesUI.GetTieredEntrancePDEID` | - | - | - | Y | page |
| `C_DelvesUI.GetTieredEntranceType` | - | - | - | Y | page |
| `C_DelvesUI.GetTraitTreeForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.GetUnseenCuriosBySlotType` | - | - | - | Y | page |
| `C_DelvesUI.GetWorldTierDifficultyForActivePlayer` | - | - | - | Y | page |
| `C_DelvesUI.HasActiveDelve` | - | - | - | Y | page |
| `C_DelvesUI.HasActiveLair` | - | - | - | Y | page |
| `C_DelvesUI.HasActiveLFGLair` | - | - | - | Y | page |
| `C_DelvesUI.IsDelveEntranceTierEnabled` | - | - | - | Y | page |
| `C_DelvesUI.IsEligibleForActiveDelveRewards` | - | - | - | Y | page |
| `C_DelvesUI.IsInLair` | - | - | - | Y | page |
| `C_DelvesUI.IsTraitTreeForCompanion` | - | - | - | Y | page |
| `C_DelvesUI.RequestPartyEligibilityForDelveTiers` | - | - | - | Y | page |
| `C_DelvesUI.SaveSeenCuriosBySlotType` | - | - | - | Y | page |
| `C_DelvesUI.SelectDelveEntranceTier` | - | - | - | Y | page |

### C_Discord

19 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Discord.Authorize` | - | - | - | Y | page |
| `C_Discord.GetDiscordChannelName` | - | - | - | Y | page |
| `C_Discord.GetDiscordUserID` | - | - | - | Y | page |
| `C_Discord.GetDisplayNameType` | - | - | - | Y | page |
| `C_Discord.GetGuildLinkStatus` | - | - | - | Y | page |
| `C_Discord.GetNumDiscordChannels` | - | - | - | Y | page |
| `C_Discord.GetNumDiscordServers` | - | - | - | Y | page |
| `C_Discord.GetServerLinkableChannels` | - | - | - | Y | page |
| `C_Discord.GetServerName` | - | - | - | Y | page |
| `C_Discord.GuildLink` | - | - | - | Y | page |
| `C_Discord.GuildUnlink` | - | - | - | Y | page |
| `C_Discord.IsEnabled` | - | - | - | Y | page |
| `C_Discord.IsGuildChannelLinked` | - | - | - | Y | page |
| `C_Discord.IsGuildSettingSet` | - | - | - | Y | page |
| `C_Discord.IsUserOAuthed` | - | - | - | Y | page |
| `C_Discord.RefreshAuth` | - | - | - | Y | page |
| `C_Discord.SetGuildSetting` | - | - | - | Y | page |
| `C_Discord.UpdateDiscordServers` | - | - | - | Y | page |
| `C_Discord.UpdateGuildLobby` | - | - | - | Y | page |

### C_DurationUtil

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_DurationUtil.CreateDuration` | Y | Y | Y | Y | page |
| `C_DurationUtil.CreateDurationTextBinding` | Y | Y | Y | Y | page |
| `C_DurationUtil.CreateManualClock` | Y | Y | Y | Y | page |

### C_DyeColor

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_DyeColor.GetAllDyeColorCategories` | Y | Y | Y | Y | page |
| `C_DyeColor.GetAllDyeColors` | Y | Y | Y | Y | page |
| `C_DyeColor.GetDyeColorCategoryInfo` | Y | Y | Y | Y | page |
| `C_DyeColor.GetDyeColorForItem` | Y | Y | Y | - | page |
| `C_DyeColor.GetDyeColorForItemLocation` | Y | Y | Y | - | page |
| `C_DyeColor.GetDyeColorInfo` | Y | Y | Y | Y | page |
| `C_DyeColor.GetDyeColorsForItem` | - | - | - | Y | page |
| `C_DyeColor.GetDyeColorsForItemLocation` | - | - | - | Y | page |
| `C_DyeColor.GetDyeColorsInCategory` | Y | Y | Y | Y | page |
| `C_DyeColor.IsDyeColorOwned` | Y | Y | Y | Y | page |

### C_EditMode

11 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EditMode.ConvertLayoutInfoToString` | Y | Y | Y | Y | page |
| `C_EditMode.ConvertStringToLayoutInfo` | Y | Y | Y | Y | page |
| `C_EditMode.GetAccountSettings` | Y | Y | Y | Y | page |
| `C_EditMode.GetLayouts` | Y | Y | Y | Y | page |
| `C_EditMode.IsValidLayoutName` | Y | Y | Y | Y | page |
| `C_EditMode.OnEditModeExit` | Y | Y | Y | Y | page |
| `C_EditMode.OnLayoutAdded` | Y | Y | Y | Y | page |
| `C_EditMode.OnLayoutDeleted` | Y | Y | Y | Y | page |
| `C_EditMode.SaveLayouts` | Y | Y | Y | Y | page |
| `C_EditMode.SetAccountSetting` | Y | Y | Y | Y | page |
| `C_EditMode.SetActiveLayout` | Y | Y | Y | Y | page |

### C_EncodingUtil

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EncodingUtil.CompressString` | Y | Y | Y | Y | page |
| `C_EncodingUtil.DecodeBase64` | Y | Y | Y | Y | page |
| `C_EncodingUtil.DecodeHex` | Y | Y | Y | Y | page |
| `C_EncodingUtil.DecompressString` | Y | Y | Y | Y | page |
| `C_EncodingUtil.DeserializeCBOR` | Y | Y | Y | Y | page |
| `C_EncodingUtil.DeserializeJSON` | Y | Y | Y | Y | page |
| `C_EncodingUtil.EncodeBase64` | Y | Y | Y | Y | page |
| `C_EncodingUtil.EncodeHex` | Y | Y | Y | Y | page |
| `C_EncodingUtil.SerializeCBOR` | Y | Y | Y | Y | page |
| `C_EncodingUtil.SerializeJSON` | Y | Y | Y | Y | page |

### C_EncounterEvents

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EncounterEvents.GetEventColor` | Y | Y | Y | Y | page |
| `C_EncounterEvents.GetEventInfo` | Y | Y | Y | Y | page |
| `C_EncounterEvents.GetEventList` | Y | Y | Y | Y | page |
| `C_EncounterEvents.GetEventSound` | Y | Y | Y | Y | page |
| `C_EncounterEvents.HasEventInfo` | Y | Y | Y | Y | page |
| `C_EncounterEvents.PlayEventSound` | Y | Y | Y | Y | page |
| `C_EncounterEvents.SetEventColor` | Y | Y | Y | Y | page |
| `C_EncounterEvents.SetEventSound` | Y | Y | Y | Y | page |

### C_EncounterJournal

22 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EncounterJournal.GetBaseDifficultyID` | - | - | - | Y | page |
| `C_EncounterJournal.GetDungeonEntrancesForMap` | Y | Y | Y | Y | page |
| `C_EncounterJournal.GetEncounterJournalLink` | Y | Y | Y | Y | page |
| `C_EncounterJournal.GetEncountersOnMap` | Y | Y | Y | Y | page |
| `C_EncounterJournal.GetInstanceForGameMap` | Y | Y | Y | Y | page |
| `C_EncounterJournal.GetLootInfo` | Y | Y | Y | Y | page |
| `C_EncounterJournal.GetLootInfoByIndex` | Y | Y | Y | Y | page |
| `C_EncounterJournal.GetSectionIconFlags` | Y | Y | Y | Y | page |
| `C_EncounterJournal.GetSectionInfo` | Y | Y | Y | Y | page |
| `C_EncounterJournal.GetSlotFilter` | Y | Y | Y | Y | page |
| `C_EncounterJournal.InitalizeSelectedTier` | - | - | - | Y | page |
| `C_EncounterJournal.InstanceHasDifficultyID` | - | - | - | Y | page |
| `C_EncounterJournal.InstanceHasLoot` | Y | Y | Y | Y | page |
| `C_EncounterJournal.IsEncounterComplete` | Y | Y | Y | Y | page |
| `C_EncounterJournal.OnClose` | - | - | - | Y | page |
| `C_EncounterJournal.OnOpen` | - | - | - | Y | page |
| `C_EncounterJournal.ResetSlotFilter` | Y | Y | Y | Y | page |
| `C_EncounterJournal.SetPreviewMythicPlusLevel` | - | - | - | Y | page |
| `C_EncounterJournal.SetPreviewPvpTier` | - | - | - | Y | page |
| `C_EncounterJournal.SetSlotFilter` | Y | Y | Y | Y | page |
| `C_EncounterJournal.SetTab` | Y | Y | Y | Y | page |
| `C_EncounterJournal.StartArathiRPE` | - | - | - | Y | page |

### C_EncounterTimeline

34 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EncounterTimeline.AddEditModeEvents` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.AddScriptEvent` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.CancelAllScriptEvents` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.CancelEditModeEvents` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.CancelScriptEvent` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.FinishScriptEvent` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetCurrentTime` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventColor` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventCountBySource` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventHighlightTime` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventInfo` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventList` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventState` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventTimeElapsed` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventTimer` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventTimeRemaining` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetEventTrack` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetSortedEventList` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetTrackInfo` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetTrackList` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetTrackMaxEventDuration` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetTrackType` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.GetViewType` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.HasActiveEvents` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.HasAnyEvents` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.HasPausedEvents` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.HasVisibleEvents` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.IsEventBlocked` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.IsFeatureAvailable` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.IsFeatureEnabled` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.PauseScriptEvent` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.ResumeScriptEvent` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.SetEventIconTextures` | Y | Y | Y | Y | page |
| `C_EncounterTimeline.SetViewType` | Y | Y | Y | Y | page |

### C_EncounterWarnings

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EncounterWarnings.GetColorForSeverity` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.GetEditModeWarningInfo` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.GetPlayCustomSoundsWhenHidden` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.GetSoundKitForSeverity` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.GetWarningsShown` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.IsFeatureAvailable` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.IsFeatureEnabled` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.PlaySound` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.SetPlayCustomSoundsWhenHidden` | Y | Y | Y | Y | page |
| `C_EncounterWarnings.SetWarningsShown` | Y | Y | Y | Y | page |

### C_EndOfMatchUI

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EndOfMatchUI.GetEndOfMatchDetails` | Y | Y | Y | Y | page |

### C_Engraving

26 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Engraving.AddCategoryFilter` | Y | Y | Y | - | page |
| `C_Engraving.AddExclusiveCategoryFilter` | Y | Y | Y | - | page |
| `C_Engraving.CastRune` | Y | Y | Y | - | page |
| `C_Engraving.ClearAllCategoryFilters` | Y | Y | Y | - | page |
| `C_Engraving.ClearCategoryFilter` | Y | Y | Y | - | page |
| `C_Engraving.ClearExclusiveCategoryFilter` | Y | Y | Y | - | page |
| `C_Engraving.EnableEquippedFilter` | Y | Y | Y | - | page |
| `C_Engraving.GetCurrentRuneCast` | Y | Y | Y | - | page |
| `C_Engraving.GetEngravingModeEnabled` | Y | Y | Y | - | page |
| `C_Engraving.GetExclusiveCategoryFilter` | Y | Y | Y | - | page |
| `C_Engraving.GetNumRunesKnown` | Y | Y | Y | - | page |
| `C_Engraving.GetRuneCategories` | Y | Y | Y | - | page |
| `C_Engraving.GetRuneForEquipmentSlot` | Y | Y | Y | - | page |
| `C_Engraving.GetRuneForInventorySlot` | Y | Y | Y | - | page |
| `C_Engraving.GetRunesForCategory` | Y | Y | Y | - | page |
| `C_Engraving.HasCategoryFilter` | Y | Y | Y | - | page |
| `C_Engraving.IsEngravingEnabled` | Y | Y | Y | - | page |
| `C_Engraving.IsEquipmentSlotEngravable` | Y | Y | Y | - | page |
| `C_Engraving.IsEquippedFilterEnabled` | Y | Y | Y | - | page |
| `C_Engraving.IsInventorySlotEngravable` | Y | Y | Y | - | page |
| `C_Engraving.IsInventorySlotEngravableByCurrentRuneCast` | Y | Y | Y | - | page |
| `C_Engraving.IsKnownRuneSpell` | Y | Y | Y | - | page |
| `C_Engraving.IsRuneEquipped` | Y | Y | Y | - | page |
| `C_Engraving.RefreshRunesList` | Y | Y | Y | - | page |
| `C_Engraving.SetEngravingModeEnabled` | Y | Y | Y | - | page |
| `C_Engraving.SetSearchFilter` | Y | Y | Y | - | page |

### C_EquipmentSet

23 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EquipmentSet.AssignSpecToEquipmentSet` | Y | Y | Y | Y | page |
| `C_EquipmentSet.CanUseEquipmentSets` | Y | Y | Y | Y | page |
| `C_EquipmentSet.ClearIgnoredSlotsForSave` | Y | Y | Y | Y | page |
| `C_EquipmentSet.CreateEquipmentSet` | Y | Y | Y | Y | page |
| `C_EquipmentSet.DeleteEquipmentSet` | Y | Y | Y | Y | page |
| `C_EquipmentSet.EquipmentSetContainsLockedItems` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetEquipmentSetAssignedSpec` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetEquipmentSetForSpec` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetEquipmentSetID` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetEquipmentSetIDs` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetEquipmentSetInfo` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetIgnoredSlots` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetItemIDs` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetItemLocations` | Y | Y | Y | Y | page |
| `C_EquipmentSet.GetNumEquipmentSets` | Y | Y | Y | Y | page |
| `C_EquipmentSet.IgnoreSlotForSave` | Y | Y | Y | Y | page |
| `C_EquipmentSet.IsSlotIgnoredForSave` | Y | Y | Y | Y | page |
| `C_EquipmentSet.ModifyEquipmentSet` | Y | Y | Y | Y | page |
| `C_EquipmentSet.PickupEquipmentSet` | Y | Y | Y | Y | page |
| `C_EquipmentSet.SaveEquipmentSet` | Y | Y | Y | Y | page |
| `C_EquipmentSet.UnassignEquipmentSetSpec` | Y | Y | Y | Y | page |
| `C_EquipmentSet.UnignoreSlotForSave` | Y | Y | Y | Y | page |
| `C_EquipmentSet.UseEquipmentSet` | Y | Y | Y | Y | page |

### C_EventScheduler

11 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EventScheduler.CanShowEvents` | - | - | - | Y | page |
| `C_EventScheduler.ClearReminder` | - | - | - | Y | page |
| `C_EventScheduler.GetActiveContinentName` | - | - | - | Y | page |
| `C_EventScheduler.GetEventUiMapID` | - | - | - | Y | page |
| `C_EventScheduler.GetEventZoneName` | - | - | - | Y | page |
| `C_EventScheduler.GetOngoingEvents` | - | - | - | Y | page |
| `C_EventScheduler.GetScheduledEvents` | - | - | - | Y | page |
| `C_EventScheduler.HasData` | - | - | - | Y | page |
| `C_EventScheduler.HasSavedReminders` | - | - | - | Y | page |
| `C_EventScheduler.RequestEvents` | - | - | - | Y | page |
| `C_EventScheduler.SetReminder` | - | - | - | Y | page |

### C_EventToastManager

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EventToastManager.GetLevelUpDisplayToastsFromLevel` | Y | Y | Y | Y | page |
| `C_EventToastManager.GetNextToastToDisplay` | Y | Y | Y | Y | page |
| `C_EventToastManager.RemoveCurrentToast` | Y | Y | Y | Y | page |

### C_EventUtils

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_EventUtils.IsCallbackEvent` | Y | Y | Y | Y | page |
| `C_EventUtils.IsEventValid` | Y | Y | Y | Y | page |

### C_ExpansionTrial

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ExpansionTrial.OnTrialLevelUpDialogClicked` | - | - | - | Y | page |
| `C_ExpansionTrial.OnTrialLevelUpDialogShown` | - | - | - | Y | page |

### C_ExternalEventURL

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ExternalEventURL.HasURL` | Y | Y | Y | Y | page |
| `C_ExternalEventURL.IsNew` | Y | Y | Y | Y | page |
| `C_ExternalEventURL.LaunchURL` | Y | Y | Y | Y | page |

### C_FogOfWar

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_FogOfWar.GetFogOfWarForMap` | - | - | - | Y | page |
| `C_FogOfWar.GetFogOfWarInfo` | - | - | - | Y | page |

### C_FrameManager

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_FrameManager.GetFrameVisibilityState` | - | - | - | Y | page |

### C_FriendList

31 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_FriendList.AddFriend` | Y | Y | Y | Y | page |
| `C_FriendList.AddIgnore` | Y | Y | Y | Y | page |
| `C_FriendList.AddOrDelIgnore` | Y | Y | Y | Y | page |
| `C_FriendList.AddOrRemoveFriend` | Y | Y | Y | Y | page |
| `C_FriendList.DelIgnore` | Y | Y | Y | Y | page |
| `C_FriendList.DelIgnoreByIndex` | Y | Y | Y | Y | page |
| `C_FriendList.GetFriendInfo` | Y | Y | Y | Y | page |
| `C_FriendList.GetFriendInfoByIndex` | Y | Y | Y | Y | page |
| `C_FriendList.GetIgnoreName` | Y | Y | Y | Y | page |
| `C_FriendList.GetNumFriends` | Y | Y | Y | Y | page |
| `C_FriendList.GetNumIgnores` | Y | Y | Y | Y | page |
| `C_FriendList.GetNumOnlineFriends` | Y | Y | Y | Y | page |
| `C_FriendList.GetNumWhoResults` | Y | Y | Y | Y | page |
| `C_FriendList.GetSelectedFriend` | Y | Y | Y | Y | page |
| `C_FriendList.GetSelectedIgnore` | Y | Y | Y | Y | page |
| `C_FriendList.GetWhoInfo` | Y | Y | Y | Y | page |
| `C_FriendList.IsFriend` | Y | Y | Y | Y | page |
| `C_FriendList.IsIgnored` | Y | Y | Y | Y | page |
| `C_FriendList.IsIgnoredByGuid` | Y | Y | Y | Y | page |
| `C_FriendList.IsLegacyFriendSystemEnabled` | - | - | - | Y | page |
| `C_FriendList.IsOnIgnoredList` | Y | Y | Y | Y | page |
| `C_FriendList.RemoveFriend` | Y | Y | Y | Y | page |
| `C_FriendList.RemoveFriendByIndex` | Y | Y | Y | Y | page |
| `C_FriendList.SendWho` | Y | Y | Y | Y | page |
| `C_FriendList.SetFriendNotes` | Y | Y | Y | Y | page |
| `C_FriendList.SetFriendNotesByIndex` | Y | Y | Y | Y | page |
| `C_FriendList.SetSelectedFriend` | Y | Y | Y | Y | page |
| `C_FriendList.SetSelectedIgnore` | Y | Y | Y | Y | page |
| `C_FriendList.SetWhoToUi` | Y | Y | Y | Y | page |
| `C_FriendList.ShowFriends` | Y | Y | Y | Y | page |
| `C_FriendList.SortWho` | Y | Y | Y | Y | page |

### C_FunctionContainers

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_FunctionContainers.CreateCallback` | Y | Y | Y | Y | page |

### C_GamePad

23 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_GamePad.AddSDLMapping` | Y | Y | Y | Y | page |
| `C_GamePad.ApplyConfigs` | Y | Y | Y | Y | page |
| `C_GamePad.AxisIndexToConfigName` | Y | Y | Y | Y | page |
| `C_GamePad.ButtonBindingToIndex` | Y | Y | Y | Y | page |
| `C_GamePad.ButtonIndexToBinding` | Y | Y | Y | Y | page |
| `C_GamePad.ButtonIndexToConfigName` | Y | Y | Y | Y | page |
| `C_GamePad.ClearLedColor` | Y | Y | Y | Y | page |
| `C_GamePad.DeleteConfig` | Y | Y | Y | Y | page |
| `C_GamePad.GetActiveDeviceID` | Y | Y | Y | Y | page |
| `C_GamePad.GetAllConfigIDs` | Y | Y | Y | Y | page |
| `C_GamePad.GetAllDeviceIDs` | Y | Y | Y | Y | page |
| `C_GamePad.GetCombinedDeviceID` | Y | Y | Y | Y | page |
| `C_GamePad.GetConfig` | Y | Y | Y | Y | page |
| `C_GamePad.GetDeviceMappedState` | Y | Y | Y | Y | page |
| `C_GamePad.GetDeviceRawState` | Y | Y | Y | Y | page |
| `C_GamePad.GetLedColor` | Y | Y | Y | Y | page |
| `C_GamePad.GetPowerLevel` | Y | Y | Y | Y | page |
| `C_GamePad.IsEnabled` | Y | Y | Y | Y | page |
| `C_GamePad.SetConfig` | Y | Y | Y | Y | page |
| `C_GamePad.SetLedColor` | Y | Y | Y | Y | page |
| `C_GamePad.SetVibration` | Y | Y | Y | Y | page |
| `C_GamePad.StickIndexToConfigName` | Y | Y | Y | Y | page |
| `C_GamePad.StopVibration` | Y | Y | Y | Y | page |

### C_GameRules

24 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_GameRules.AutoConnectToGameModeRealm` | Y | Y | Y | Y | page |
| `C_GameRules.DoesGameModeHavePromo` | Y | Y | Y | Y | page |
| `C_GameRules.GetActiveGameMode` | Y | Y | Y | Y | page |
| `C_GameRules.GetCurrentEventRealmQueues` | Y | Y | Y | Y | page |
| `C_GameRules.GetCurrentGameModeDisplayInfo` | Y | Y | Y | Y | page |
| `C_GameRules.GetCurrentGameModeRecordID` | Y | Y | Y | Y | page |
| `C_GameRules.GetDisplayedGameModeRecordIDAtIndex` | Y | Y | Y | Y | page |
| `C_GameRules.GetGameModeDisplayInfoByRecordID` | Y | Y | Y | Y | page |
| `C_GameRules.GetGameModeGlueScreenName` | Y | Y | Y | Y | page |
| `C_GameRules.GetGameModePromoGlobalString` | Y | Y | Y | Y | page |
| `C_GameRules.GetGameRuleAsFloat` | Y | Y | Y | Y | page |
| `C_GameRules.GetGameRuleAsFrameStrata` | Y | Y | Y | Y | page |
| `C_GameRules.GetNumDisplayedGameModes` | Y | Y | Y | Y | page |
| `C_GameRules.IsCharacterlessLoginActive` | Y | Y | Y | Y | page |
| `C_GameRules.IsClassAllowedForGameMode` | Y | Y | Y | Y | page |
| `C_GameRules.IsGameModeEnabled` | Y | Y | Y | Y | page |
| `C_GameRules.IsGameRuleActive` | Y | Y | Y | Y | page |
| `C_GameRules.IsHardcoreActive` | Y | Y | Y | - | page |
| `C_GameRules.IsMultiActionBarVisibilityForced` | Y | Y | Y | Y | page |
| `C_GameRules.IsPersonalResourceDisplayEnabled` | Y | Y | Y | Y | page |
| `C_GameRules.IsPlunderstorm` | Y | Y | Y | Y | page |
| `C_GameRules.IsSelfFoundAllowed` | Y | Y | Y | - | page |
| `C_GameRules.IsStandard` | Y | Y | Y | Y | page |
| `C_GameRules.IsWoWHack` | Y | Y | Y | Y | page |

### C_Garrison

227 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Garrison.AddFollowerToMission` | - | - | - | Y | page |
| `C_Garrison.AllowMissionStartAboveSoftCap` | - | - | - | Y | missing |
| `C_Garrison.AreMissionFollowerRequirementsMet` | - | - | - | Y | missing |
| `C_Garrison.AssignFollowerToBuilding` | - | - | - | Y | missing |
| `C_Garrison.CancelConstruction` | - | - | - | Y | missing |
| `C_Garrison.CanGenerateRecruits` | - | - | - | Y | missing |
| `C_Garrison.CanOpenMissionChest` | - | - | - | Y | missing |
| `C_Garrison.CanSetRecruitmentPreference` | - | - | - | Y | missing |
| `C_Garrison.CanSpellTargetFollowerIDWithAddAbility` | - | - | - | Y | missing |
| `C_Garrison.CanUpgradeGarrison` | - | - | - | Y | missing |
| `C_Garrison.CastItemSpellOnFollowerAbility` | - | - | - | Y | missing |
| `C_Garrison.CastSpellOnFollower` | - | - | - | Y | missing |
| `C_Garrison.CastSpellOnFollowerAbility` | - | - | - | Y | missing |
| `C_Garrison.CastSpellOnMission` | - | - | - | Y | missing |
| `C_Garrison.ClearCompleteTalent` | - | - | - | Y | missing |
| `C_Garrison.CloseArchitect` | - | - | - | Y | missing |
| `C_Garrison.CloseGarrisonTradeskillNPC` | - | - | - | Y | missing |
| `C_Garrison.CloseMissionNPC` | - | - | - | Y | missing |
| `C_Garrison.CloseRecruitmentNPC` | - | - | - | Y | missing |
| `C_Garrison.CloseTalentNPC` | - | - | - | Y | missing |
| `C_Garrison.CloseTradeskillCrafter` | - | - | - | Y | missing |
| `C_Garrison.GenerateRecruits` | - | - | - | Y | missing |
| `C_Garrison.GetAllBonusAbilityEffects` | - | - | - | Y | missing |
| `C_Garrison.GetAllEncounterThreats` | - | - | - | Y | missing |
| `C_Garrison.GetAutoCombatDamageClassValues` | - | - | - | Y | page |
| `C_Garrison.GetAutoMissionBoardState` | - | - | - | Y | page |
| `C_Garrison.GetAutoMissionEnvironmentEffect` | - | - | - | Y | page |
| `C_Garrison.GetAutoMissionTargetingInfo` | - | - | - | Y | page |
| `C_Garrison.GetAutoMissionTargetingInfoForSpell` | - | - | - | Y | page |
| `C_Garrison.GetAutoTroops` | - | - | - | Y | page |
| `C_Garrison.GetAvailableMissions` | - | - | - | Y | page |
| `C_Garrison.GetAvailableRecruits` | - | - | - | Y | missing |
| `C_Garrison.GetBasicMissionInfo` | - | - | - | Y | page |
| `C_Garrison.GetBuffedFollowersForMission` | - | - | - | Y | missing |
| `C_Garrison.GetBuildingInfo` | - | - | - | Y | page |
| `C_Garrison.GetBuildingLockInfo` | - | - | - | Y | missing |
| `C_Garrison.GetBuildings` | - | - | - | Y | missing |
| `C_Garrison.GetBuildingsForPlot` | - | - | - | Y | missing |
| `C_Garrison.GetBuildingsForSize` | - | - | - | Y | missing |
| `C_Garrison.GetBuildingSizes` | - | - | - | Y | missing |
| `C_Garrison.GetBuildingSpecInfo` | - | - | - | Y | missing |
| `C_Garrison.GetBuildingTimeRemaining` | - | - | - | Y | missing |
| `C_Garrison.GetBuildingTooltip` | - | - | - | Y | missing |
| `C_Garrison.GetBuildingUpgradeInfo` | - | - | - | Y | missing |
| `C_Garrison.GetClassSpecCategoryInfo` | - | - | - | Y | missing |
| `C_Garrison.GetCombatAllyMission` | - | - | - | Y | missing |
| `C_Garrison.GetCombatLogSpellInfo` | - | - | - | Y | page |
| `C_Garrison.GetCompleteMissions` | - | - | - | Y | missing |
| `C_Garrison.GetCompleteTalent` | - | - | - | Y | missing |
| `C_Garrison.GetCurrencyTypes` | - | - | - | Y | missing |
| `C_Garrison.GetCurrentCypherEquipmentLevel` | - | - | - | Y | page |
| `C_Garrison.GetCurrentGarrTalentTreeFriendshipFactionID` | - | - | - | Y | page |
| `C_Garrison.GetCurrentGarrTalentTreeID` | - | - | - | Y | page |
| `C_Garrison.GetCyphersToNextEquipmentLevel` | - | - | - | Y | page |
| `C_Garrison.GetFollowerAbilities` | - | - | - | Y | page |
| `C_Garrison.GetFollowerAbilityAtIndex` | - | - | - | Y | page |
| `C_Garrison.GetFollowerAbilityAtIndexByID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAbilityCounterMechanicInfo` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAbilityCountersForMechanicTypes` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAbilityDescription` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAbilityIcon` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAbilityInfo` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAbilityIsTrait` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAbilityLink` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAbilityName` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerActivationCost` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerAutoCombatSpells` | - | - | - | Y | page |
| `C_Garrison.GetFollowerAutoCombatStats` | - | - | - | Y | page |
| `C_Garrison.GetFollowerBiasForMission` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerClassSpec` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerClassSpecAtlas` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerClassSpecByID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerClassSpecName` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerDisplayID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerInfo` | - | - | - | Y | page |
| `C_Garrison.GetFollowerInfoForBuilding` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerIsTroop` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerItemLevelAverage` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerItems` | - | - | - | Y | page |
| `C_Garrison.GetFollowerLevel` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerLevelXP` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerLink` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerLinkByID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerMissionCompleteInfo` | - | - | - | Y | page |
| `C_Garrison.GetFollowerMissionTimeLeft` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerMissionTimeLeftSeconds` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerModelItems` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerName` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerNameByID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerPortraitIconID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerPortraitIconIDByID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerQuality` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerQualityTable` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerRecentlyGainedAbilityIDs` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerRecentlyGainedTraitIDs` | - | - | - | Y | missing |
| `C_Garrison.GetFollowers` | - | - | - | Y | page |
| `C_Garrison.GetFollowerShipments` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerSoftCap` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerSourceTextByID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerSpecializationAtIndex` | - | - | - | Y | missing |
| `C_Garrison.GetFollowersSpellsForMission` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerStatus` | - | - | - | Y | missing |
| `C_Garrison.GetFollowersTraitsForMission` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerTraitAtIndex` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerTraitAtIndexByID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerTypeByID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerTypeByMissionID` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerUnderBiasReason` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerXP` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerXPTable` | - | - | - | Y | missing |
| `C_Garrison.GetFollowerZoneSupportAbilities` | - | - | - | Y | missing |
| `C_Garrison.GetGarrisonInfo` | - | - | - | Y | page |
| `C_Garrison.GetGarrisonPlotsInstancesForMap` | - | - | - | Y | page |
| `C_Garrison.GetGarrisonTalentTreeCurrencyTypes` | - | - | - | Y | page |
| `C_Garrison.GetGarrisonTalentTreeType` | - | - | - | Y | page |
| `C_Garrison.GetGarrisonUpgradeCost` | - | - | - | Y | missing |
| `C_Garrison.GetInProgressMissions` | - | - | - | Y | page |
| `C_Garrison.GetLandingPageGarrisonType` | - | - | - | Y | missing |
| `C_Garrison.GetLandingPageItems` | - | - | - | Y | missing |
| `C_Garrison.GetLandingPageShipmentCount` | - | - | - | Y | missing |
| `C_Garrison.GetLandingPageShipmentInfo` | - | - | - | Y | page |
| `C_Garrison.GetLandingPageShipmentInfoByContainerID` | - | - | - | Y | page |
| `C_Garrison.GetLooseShipments` | - | - | - | Y | page |
| `C_Garrison.GetMaxCypherEquipmentLevel` | - | - | - | Y | page |
| `C_Garrison.GetMissionBonusAbilityEffects` | - | - | - | Y | missing |
| `C_Garrison.GetMissionCompleteEncounters` | - | - | - | Y | page |
| `C_Garrison.GetMissionCost` | - | - | - | Y | missing |
| `C_Garrison.GetMissionDeploymentInfo` | - | - | - | Y | page |
| `C_Garrison.GetMissionDisplayIDs` | - | - | - | Y | missing |
| `C_Garrison.GetMissionEncounterIconInfo` | - | - | - | Y | page |
| `C_Garrison.GetMissionLink` | - | - | - | Y | missing |
| `C_Garrison.GetMissionMaxFollowers` | - | - | - | Y | missing |
| `C_Garrison.GetMissionName` | - | - | - | Y | missing |
| `C_Garrison.GetMissionRewardInfo` | - | - | - | Y | missing |
| `C_Garrison.GetMissionSuccessChance` | - | - | - | Y | missing |
| `C_Garrison.GetMissionTexture` | - | - | - | Y | missing |
| `C_Garrison.GetMissionTimes` | - | - | - | Y | missing |
| `C_Garrison.GetMissionUncounteredMechanics` | - | - | - | Y | missing |
| `C_Garrison.GetNumActiveFollowers` | - | - | - | Y | missing |
| `C_Garrison.GetNumFollowerActivationsRemaining` | - | - | - | Y | missing |
| `C_Garrison.GetNumFollowerDailyActivations` | - | - | - | Y | missing |
| `C_Garrison.GetNumFollowers` | - | - | - | Y | missing |
| `C_Garrison.GetNumFollowersForMechanic` | - | - | - | Y | missing |
| `C_Garrison.GetNumFollowersOnMission` | - | - | - | Y | missing |
| `C_Garrison.GetNumPendingShipments` | - | - | - | Y | missing |
| `C_Garrison.GetNumShipmentCurrencies` | - | - | - | Y | missing |
| `C_Garrison.GetNumShipmentReagents` | - | - | - | Y | missing |
| `C_Garrison.GetOwnedBuildingInfo` | - | - | - | Y | missing |
| `C_Garrison.GetOwnedBuildingInfoAbbrev` | - | - | - | Y | page |
| `C_Garrison.GetPartyBuffs` | - | - | - | Y | missing |
| `C_Garrison.GetPartyMentorLevels` | - | - | - | Y | missing |
| `C_Garrison.GetPartyMissionInfo` | - | - | - | Y | missing |
| `C_Garrison.GetPendingShipmentInfo` | - | - | - | Y | missing |
| `C_Garrison.GetPlots` | - | - | - | Y | missing |
| `C_Garrison.GetPlotsForBuilding` | - | - | - | Y | missing |
| `C_Garrison.GetPossibleFollowersForBuilding` | - | - | - | Y | missing |
| `C_Garrison.GetRecruitAbilities` | - | - | - | Y | missing |
| `C_Garrison.GetRecruiterAbilityCategories` | - | - | - | Y | missing |
| `C_Garrison.GetRecruiterAbilityList` | - | - | - | Y | missing |
| `C_Garrison.GetRecruitmentPreferences` | - | - | - | Y | missing |
| `C_Garrison.GetShipDeathAnimInfo` | - | - | - | Y | missing |
| `C_Garrison.GetShipmentContainerInfo` | - | - | - | Y | missing |
| `C_Garrison.GetShipmentItemInfo` | - | - | - | Y | missing |
| `C_Garrison.GetShipmentReagentCurrencyInfo` | - | - | - | Y | missing |
| `C_Garrison.GetShipmentReagentInfo` | - | - | - | Y | missing |
| `C_Garrison.GetShipmentReagentItemLink` | - | - | - | Y | missing |
| `C_Garrison.GetSpecChangeCost` | - | - | - | Y | missing |
| `C_Garrison.GetTabForPlot` | - | - | - | Y | missing |
| `C_Garrison.GetTalentInfo` | - | - | - | Y | page |
| `C_Garrison.GetTalentPointsSpentInTalentTree` | - | - | - | Y | page |
| `C_Garrison.GetTalentTreeIDsByClassID` | - | - | - | Y | page |
| `C_Garrison.GetTalentTreeInfo` | - | - | - | Y | page |
| `C_Garrison.GetTalentTreeResetInfo` | - | - | - | Y | page |
| `C_Garrison.GetTalentTreeTalentPointResearchInfo` | - | - | - | Y | page |
| `C_Garrison.GetTalentUnlockWorldQuest` | - | - | - | Y | page |
| `C_Garrison.HasAdventures` | - | - | - | Y | page |
| `C_Garrison.HasGarrison` | - | - | - | Y | missing |
| `C_Garrison.HasShipyard` | - | - | - | Y | page |
| `C_Garrison.IsAboveFollowerSoftCap` | - | - | - | Y | missing |
| `C_Garrison.IsAtGarrisonMissionNPC` | - | - | - | Y | page |
| `C_Garrison.IsEnvironmentCountered` | - | - | - | Y | page |
| `C_Garrison.IsFollowerCollected` | - | - | - | Y | missing |
| `C_Garrison.IsFollowerOnCompletedMission` | - | - | - | Y | page |
| `C_Garrison.IsInvasionAvailable` | - | - | - | Y | missing |
| `C_Garrison.IsLandingPageMinimapButtonVisible` | - | - | - | Y | page |
| `C_Garrison.IsMechanicFullyCountered` | - | - | - | Y | missing |
| `C_Garrison.IsOnGarrisonMap` | - | - | - | Y | missing |
| `C_Garrison.IsOnShipmentQuestForNPC` | - | - | - | Y | missing |
| `C_Garrison.IsOnShipyardMap` | - | - | - | Y | missing |
| `C_Garrison.IsPlayerInGarrison` | - | - | - | Y | missing |
| `C_Garrison.IsTalentConditionMet` | - | - | - | Y | page |
| `C_Garrison.IsUsingPartyGarrison` | - | - | - | Y | page |
| `C_Garrison.IsVisitGarrisonAvailable` | - | - | - | Y | missing |
| `C_Garrison.MarkMissionComplete` | - | - | - | Y | page |
| `C_Garrison.MissionBonusRoll` | - | - | - | Y | page |
| `C_Garrison.PlaceBuilding` | - | - | - | Y | missing |
| `C_Garrison.RecruitFollower` | - | - | - | Y | missing |
| `C_Garrison.RegenerateCombatLog` | - | - | - | Y | page |
| `C_Garrison.RemoveFollower` | - | - | - | Y | missing |
| `C_Garrison.RemoveFollowerFromBuilding` | - | - | - | Y | missing |
| `C_Garrison.RemoveFollowerFromMission` | - | - | - | Y | page |
| `C_Garrison.RenameFollower` | - | - | - | Y | missing |
| `C_Garrison.RequestClassSpecCategoryInfo` | - | - | - | Y | missing |
| `C_Garrison.RequestGarrisonUpgradeable` | - | - | - | Y | missing |
| `C_Garrison.RequestLandingPageShipmentInfo` | - | - | - | Y | missing |
| `C_Garrison.RequestShipmentCreation` | - | - | - | Y | missing |
| `C_Garrison.RequestShipmentInfo` | - | - | - | Y | missing |
| `C_Garrison.ResearchTalent` | - | - | - | Y | missing |
| `C_Garrison.RushHealAllFollowers` | - | - | - | Y | page |
| `C_Garrison.RushHealFollower` | - | - | - | Y | page |
| `C_Garrison.SearchForFollower` | - | - | - | Y | missing |
| `C_Garrison.SetAutoCombatSpellFastForward` | - | - | - | Y | page |
| `C_Garrison.SetBuildingActive` | - | - | - | Y | missing |
| `C_Garrison.SetBuildingSpecialization` | - | - | - | Y | missing |
| `C_Garrison.SetFollowerFavorite` | - | - | - | Y | missing |
| `C_Garrison.SetFollowerInactive` | - | - | - | Y | missing |
| `C_Garrison.SetRecruitmentPreferences` | - | - | - | Y | missing |
| `C_Garrison.SetUsingPartyGarrison` | - | - | - | Y | page |
| `C_Garrison.ShouldShowMapTab` | - | - | - | Y | missing |
| `C_Garrison.ShowFollowerNameInErrorMessage` | - | - | - | Y | missing |
| `C_Garrison.StartMission` | - | - | - | Y | page |
| `C_Garrison.SwapBuildings` | - | - | - | Y | missing |
| `C_Garrison.TargetSpellHasFollowerItemLevelUpgrade` | - | - | - | Y | missing |
| `C_Garrison.TargetSpellHasFollowerReroll` | - | - | - | Y | missing |
| `C_Garrison.TargetSpellHasFollowerTemporaryAbility` | - | - | - | Y | missing |
| `C_Garrison.UpgradeBuilding` | - | - | - | Y | missing |
| `C_Garrison.UpgradeGarrison` | - | - | - | Y | missing |

### C_GenericWidgetDisplay

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_GenericWidgetDisplay.Acknowledge` | Y | Y | Y | Y | page |
| `C_GenericWidgetDisplay.Close` | Y | Y | Y | Y | page |

### C_Glue

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Glue.IsFirstLoadThisSession` | Y | Y | Y | Y | page |
| `C_Glue.IsOnGlueScreen` | Y | Y | Y | Y | page |

### C_GlyphInfo

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_GlyphInfo.GetGlyphInfoByID` | - | - | Y | - | page |
| `C_GlyphInfo.GetGlyphLink` | - | - | Y | - | missing |

### C_GossipInfo

20 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_GossipInfo.CloseGossip` | Y | Y | Y | Y | page |
| `C_GossipInfo.ForceGossip` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetActiveQuests` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetAvailableQuests` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetCompletedOptionDescriptionString` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetCustomGossipDescriptionString` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetFriendshipReputation` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetFriendshipReputationRanks` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetNumActiveQuests` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetNumAvailableQuests` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetOptions` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetOptionUIWidgetSetsAndTypesByOptionID` | - | - | - | Y | page |
| `C_GossipInfo.GetPoiForUiMapID` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetPoiInfo` | Y | Y | Y | Y | page |
| `C_GossipInfo.GetText` | Y | Y | Y | Y | page |
| `C_GossipInfo.RefreshOptions` | - | - | - | Y | page |
| `C_GossipInfo.SelectActiveQuest` | Y | Y | Y | Y | page |
| `C_GossipInfo.SelectAvailableQuest` | Y | Y | Y | Y | page |
| `C_GossipInfo.SelectOption` | Y | Y | Y | Y | page |
| `C_GossipInfo.SelectOptionByIndex` | Y | Y | Y | Y | page |

### C_GuildBank

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_GuildBank.IsGuildBankEnabled` | Y | Y | Y | Y | page |

### C_GuildInfo

35 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_GuildInfo.AreGuildEventsEnabled` | Y | Y | Y | Y | page |
| `C_GuildInfo.CanEditOfficerNote` | Y | Y | Y | Y | page |
| `C_GuildInfo.CanSpeakInGuildChat` | Y | Y | Y | Y | page |
| `C_GuildInfo.CanViewOfficerNote` | Y | Y | Y | Y | page |
| `C_GuildInfo.Demote` | Y | Y | Y | Y | page |
| `C_GuildInfo.Disband` | Y | Y | Y | Y | page |
| `C_GuildInfo.GetGuildNewsInfo` | Y | Y | Y | Y | page |
| `C_GuildInfo.GetGuildRankOrder` | Y | Y | Y | Y | page |
| `C_GuildInfo.GetGuildTabardInfo` | Y | Y | Y | Y | page |
| `C_GuildInfo.GetInfoText` | Y | Y | Y | Y | page |
| `C_GuildInfo.GetMOTD` | Y | Y | Y | Y | page |
| `C_GuildInfo.GuildControlGetRankFlags` | Y | Y | Y | Y | page |
| `C_GuildInfo.GuildRoster` | Y | Y | Y | Y | page |
| `C_GuildInfo.Invite` | Y | Y | Y | Y | page |
| `C_GuildInfo.IsDiscordStreamSeparate` | - | - | - | Y | page |
| `C_GuildInfo.IsEncounterGuildNewsEnabled` | Y | Y | Y | Y | page |
| `C_GuildInfo.IsGuildOfficer` | Y | Y | Y | Y | page |
| `C_GuildInfo.IsGuildRankAssignmentAllowed` | Y | Y | Y | Y | page |
| `C_GuildInfo.IsGuildReputationEnabled` | Y | Y | Y | Y | page |
| `C_GuildInfo.Leave` | Y | Y | Y | Y | page |
| `C_GuildInfo.MemberExistsByName` | Y | Y | Y | Y | page |
| `C_GuildInfo.Promote` | Y | Y | Y | Y | page |
| `C_GuildInfo.QueryGuildMemberRecipes` | Y | Y | Y | Y | page |
| `C_GuildInfo.QueryGuildMembersForRecipe` | Y | Y | Y | Y | page |
| `C_GuildInfo.RemoveFromGuild` | Y | Y | Y | Y | page |
| `C_GuildInfo.RequestGuildRename` | Y | Y | Y | Y | page |
| `C_GuildInfo.RequestGuildRenameRefund` | Y | Y | Y | Y | page |
| `C_GuildInfo.RequestRenameNameCheck` | Y | Y | Y | Y | page |
| `C_GuildInfo.RequestRenameStatus` | Y | Y | Y | Y | page |
| `C_GuildInfo.SetGuildRankOrder` | Y | Y | Y | Y | page |
| `C_GuildInfo.SetInfoText` | Y | Y | Y | Y | page |
| `C_GuildInfo.SetLeader` | Y | Y | Y | Y | page |
| `C_GuildInfo.SetMOTD` | Y | Y | Y | Y | page |
| `C_GuildInfo.SetNote` | Y | Y | Y | Y | page |
| `C_GuildInfo.Uninvite` | Y | Y | Y | Y | page |

### C_Heirloom

25 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Heirloom.CanHeirloomUpgradeFromPending` | Y | Y | Y | Y | page |
| `C_Heirloom.CreateHeirloom` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetClassAndSpecFilters` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetCollectedHeirloomFilter` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetHeirloomInfo` | Y | Y | Y | Y | page |
| `C_Heirloom.GetHeirloomItemIDFromDisplayedIndex` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetHeirloomItemIDs` | Y | Y | Y | Y | page |
| `C_Heirloom.GetHeirloomLink` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetHeirloomMaxUpgradeLevel` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetHeirloomSourceFilter` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetNumDisplayedHeirlooms` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetNumHeirlooms` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetNumKnownHeirlooms` | Y | Y | Y | Y | missing |
| `C_Heirloom.GetUncollectedHeirloomFilter` | Y | Y | Y | Y | missing |
| `C_Heirloom.IsHeirloomSourceValid` | Y | Y | Y | - | missing |
| `C_Heirloom.IsItemHeirloom` | Y | Y | Y | Y | missing |
| `C_Heirloom.IsPendingHeirloomUpgrade` | Y | Y | Y | Y | missing |
| `C_Heirloom.PlayerHasHeirloom` | Y | Y | Y | Y | missing |
| `C_Heirloom.SetClassAndSpecFilters` | Y | Y | Y | Y | missing |
| `C_Heirloom.SetCollectedHeirloomFilter` | Y | Y | Y | Y | missing |
| `C_Heirloom.SetHeirloomSourceFilter` | Y | Y | Y | Y | missing |
| `C_Heirloom.SetSearch` | Y | Y | Y | Y | missing |
| `C_Heirloom.SetUncollectedHeirloomFilter` | Y | Y | Y | Y | missing |
| `C_Heirloom.ShouldShowHeirloomHelp` | Y | Y | Y | Y | missing |
| `C_Heirloom.UpgradeHeirloom` | Y | Y | Y | Y | missing |

### C_HeirloomInfo

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HeirloomInfo.AreAllCollectionFiltersChecked` | - | - | - | Y | page |
| `C_HeirloomInfo.AreAllSourceFiltersChecked` | - | - | - | Y | page |
| `C_HeirloomInfo.IsHeirloomSourceValid` | - | - | - | Y | page |
| `C_HeirloomInfo.IsUsingDefaultFilters` | - | - | - | Y | page |
| `C_HeirloomInfo.SetAllCollectionFilters` | - | - | - | Y | page |
| `C_HeirloomInfo.SetAllSourceFilters` | - | - | - | Y | page |
| `C_HeirloomInfo.SetDefaultFilters` | - | - | - | Y | page |

### C_HouseEditor

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HouseEditor.ActivateHouseEditorMode` | Y | Y | Y | Y | page |
| `C_HouseEditor.EnterHouseEditor` | Y | Y | Y | Y | page |
| `C_HouseEditor.GetActiveHouseEditorMode` | Y | Y | Y | Y | page |
| `C_HouseEditor.GetHouseEditorAvailability` | Y | Y | Y | Y | page |
| `C_HouseEditor.GetHouseEditorModeAvailability` | Y | Y | Y | Y | page |
| `C_HouseEditor.GetHouseEditorPlayerType` | - | - | - | Y | page |
| `C_HouseEditor.IsHouseEditorActive` | Y | Y | Y | Y | page |
| `C_HouseEditor.IsHouseEditorModeActive` | Y | Y | Y | Y | page |
| `C_HouseEditor.IsHouseEditorStatusAvailable` | Y | Y | Y | Y | page |
| `C_HouseEditor.LeaveHouseEditor` | Y | Y | Y | Y | page |

### C_HouseExterior

23 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HouseExterior.CancelActiveExteriorEditing` | Y | Y | Y | Y | page |
| `C_HouseExterior.GetCoreFixtureOptionsInfo` | Y | Y | Y | Y | page |
| `C_HouseExterior.GetCurrentHouseExteriorSize` | Y | Y | Y | Y | page |
| `C_HouseExterior.GetCurrentHouseExteriorType` | Y | Y | Y | Y | page |
| `C_HouseExterior.GetFixtureDebugInfoForGUID` | Y | Y | Y | Y | missing |
| `C_HouseExterior.GetHouseExteriorSizeOptions` | Y | Y | Y | Y | page |
| `C_HouseExterior.GetHouseExteriorTypeOptions` | Y | Y | Y | Y | page |
| `C_HouseExterior.GetHoveredFixtureDebugInfo` | Y | Y | Y | Y | missing |
| `C_HouseExterior.GetSelectedFixtureDebugInfo` | Y | Y | Y | Y | missing |
| `C_HouseExterior.GetSelectedFixturePointInfo` | Y | Y | Y | Y | page |
| `C_HouseExterior.HasHoveredFixture` | Y | Y | Y | Y | page |
| `C_HouseExterior.HasSelectedFixturePoint` | Y | Y | Y | Y | page |
| `C_HouseExterior.IsAnyDecorAttachedToCoreFixture` | Y | Y | Y | Y | page |
| `C_HouseExterior.IsAnyDecorAttachedToDoor` | Y | Y | Y | Y | page |
| `C_HouseExterior.IsAnyDecorAttachedToHouseExterior` | Y | Y | Y | Y | page |
| `C_HouseExterior.IsAnyDecorAttachedToSelectedFixturePoint` | Y | Y | Y | Y | page |
| `C_HouseExterior.IsExteriorDecorHidden` | Y | Y | Y | Y | page |
| `C_HouseExterior.RemoveFixtureFromSelectedPoint` | Y | Y | Y | Y | page |
| `C_HouseExterior.SelectCoreFixtureOption` | Y | Y | Y | Y | page |
| `C_HouseExterior.SelectFixtureOption` | Y | Y | Y | Y | page |
| `C_HouseExterior.SetExteriorDecorHidden` | Y | Y | Y | Y | page |
| `C_HouseExterior.SetHouseExteriorSize` | Y | Y | Y | Y | page |
| `C_HouseExterior.SetHouseExteriorType` | Y | Y | Y | Y | page |

### C_Housing

63 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Housing.AcceptNeighborhoodOwnership` | Y | Y | Y | Y | page |
| `C_Housing.CanEditCharter` | Y | Y | Y | Y | page |
| `C_Housing.CanTakeReportScreenshot` | Y | Y | Y | Y | page |
| `C_Housing.CreateGuildNeighborhood` | Y | Y | Y | Y | page |
| `C_Housing.CreateNeighborhoodCharter` | Y | Y | Y | Y | page |
| `C_Housing.DeclineNeighborhoodOwnership` | Y | Y | Y | Y | page |
| `C_Housing.DoesFactionMatchNeighborhood` | Y | Y | Y | Y | page |
| `C_Housing.EditNeighborhoodCharter` | Y | Y | Y | Y | page |
| `C_Housing.GetCurrentHouseInfo` | Y | Y | Y | Y | page |
| `C_Housing.GetCurrentHouseLevelFavor` | Y | Y | Y | Y | page |
| `C_Housing.GetCurrentHouseRefundAmount` | Y | Y | Y | Y | page |
| `C_Housing.GetCurrentNeighborhoodGUID` | Y | Y | Y | Y | page |
| `C_Housing.GetHouseLevelFavorForLevel` | Y | Y | Y | Y | page |
| `C_Housing.GetHouseLevelRewardsForLevel` | Y | Y | Y | Y | page |
| `C_Housing.GetHousingAccessFlags` | Y | Y | Y | Y | page |
| `C_Housing.GetMaxHouseLevel` | Y | Y | Y | Y | page |
| `C_Housing.GetNeighborhoodTextureSuffix` | Y | Y | Y | Y | page |
| `C_Housing.GetOthersOwnedHouses` | Y | Y | Y | Y | page |
| `C_Housing.GetPlayerOwnedHouses` | Y | Y | Y | Y | page |
| `C_Housing.GetTrackedHouseGuid` | Y | Y | Y | Y | page |
| `C_Housing.GetUIMapIDForNeighborhood` | Y | Y | Y | Y | page |
| `C_Housing.GetVisitCooldownInfo` | Y | Y | Y | Y | page |
| `C_Housing.HasHousingExpansionAccess` | Y | Y | Y | Y | page |
| `C_Housing.HouseFinderDeclineNeighborhoodInvitation` | Y | Y | Y | Y | page |
| `C_Housing.HouseFinderIgnoreNeighborhood` | - | - | - | Y | page |
| `C_Housing.HouseFinderRequestNeighborhoods` | Y | Y | Y | Y | page |
| `C_Housing.HouseFinderRequestReservationAndPort` | Y | Y | Y | Y | page |
| `C_Housing.IsHousingMarketCartFullRemoveEnabled` | Y | Y | Y | Y | page |
| `C_Housing.IsHousingMarketEnabled` | Y | Y | Y | Y | page |
| `C_Housing.IsHousingMarketShopEnabled` | Y | Y | Y | Y | page |
| `C_Housing.IsHousingServiceEnabled` | Y | Y | Y | Y | page |
| `C_Housing.IsInsideHouse` | Y | Y | Y | Y | page |
| `C_Housing.IsInsideHouseOrPlot` | Y | Y | Y | Y | page |
| `C_Housing.IsInsideOwnedHouse` | - | - | - | Y | page |
| `C_Housing.IsInsideOwnedHouseOrPlot` | - | - | - | Y | page |
| `C_Housing.IsInsideOwnedPlot` | - | - | - | Y | page |
| `C_Housing.IsInsideOwnHouse` | Y | Y | Y | - | page |
| `C_Housing.IsInsidePlot` | Y | Y | Y | Y | page |
| `C_Housing.IsOnNeighborhoodMap` | Y | Y | Y | Y | page |
| `C_Housing.LeaveHouse` | Y | Y | Y | Y | page |
| `C_Housing.OnCharterConfirmationAccepted` | Y | Y | Y | Y | page |
| `C_Housing.OnCharterConfirmationClosed` | Y | Y | Y | Y | page |
| `C_Housing.OnCreateCharterNeighborhoodClosed` | Y | Y | Y | Y | page |
| `C_Housing.OnCreateGuildNeighborhoodClosed` | Y | Y | Y | Y | page |
| `C_Housing.OnHouseFinderClickPlot` | Y | Y | Y | Y | page |
| `C_Housing.OnRequestSignatureClicked` | Y | Y | Y | Y | page |
| `C_Housing.OnSignCharterClicked` | Y | Y | Y | Y | page |
| `C_Housing.RelinquishHouse` | Y | Y | Y | Y | page |
| `C_Housing.RequestCurrentHouseInfo` | Y | Y | Y | Y | page |
| `C_Housing.RequestHouseFinderNeighborhoodData` | Y | Y | Y | Y | page |
| `C_Housing.RequestPlayerCharacterList` | Y | Y | Y | Y | page |
| `C_Housing.ResetHouse` | - | - | - | Y | page |
| `C_Housing.ReturnAfterVisitingHouse` | Y | Y | Y | Y | page |
| `C_Housing.SaveHouseSettings` | Y | Y | Y | Y | page |
| `C_Housing.SearchBNetFriendNeighborhoods` | Y | Y | Y | Y | page |
| `C_Housing.SearchBNetFriendNeighborhoodsByID` | Y | Y | Y | Y | page |
| `C_Housing.SetTrackedHouseGuid` | Y | Y | Y | Y | page |
| `C_Housing.StartTutorial` | Y | Y | Y | Y | page |
| `C_Housing.TeleportHome` | Y | Y | Y | Y | page |
| `C_Housing.TryRenameNeighborhood` | Y | Y | Y | Y | page |
| `C_Housing.ValidateCreateGuildNeighborhoodSize` | Y | Y | Y | Y | page |
| `C_Housing.ValidateNeighborhoodName` | Y | Y | Y | Y | page |
| `C_Housing.VisitHouse` | Y | Y | Y | Y | page |

### C_HousingBasicMode

22 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingBasicMode.CancelActiveEditing` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.CommitDecorMovement` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.CommitHouseExteriorPosition` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.FinishPlacingNewDecor` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.GetHoveredDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.GetSelectedDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.IsDecorSelected` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.IsFreePlaceEnabled` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.IsGridSnapEnabled` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.IsGridVisible` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.IsHouseExteriorHovered` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.IsHouseExteriorSelected` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.IsHoveringDecor` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.IsPlacingNewDecor` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.RemoveSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.RotateDecor` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.RotateHouseExterior` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.SetFreePlaceEnabled` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.SetGridSnapEnabled` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.SetGridVisible` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.StartPlacingNewDecor` | Y | Y | Y | Y | page |
| `C_HousingBasicMode.StartPlacingPreviewDecor` | Y | Y | Y | Y | page |

### C_HousingBlueprint

18 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingBlueprint.CanExportRoom` | - | - | - | Y | page |
| `C_HousingBlueprint.CanExportTypeFromCurrentLocation` | - | - | - | Y | page |
| `C_HousingBlueprint.CanImportTypeFromCurrentLocation` | - | - | - | Y | page |
| `C_HousingBlueprint.DeleteBlueprint` | - | - | - | Y | page |
| `C_HousingBlueprint.ExportBlueprint` | - | - | - | Y | page |
| `C_HousingBlueprint.ExportRoomBlueprint` | - | - | - | Y | page |
| `C_HousingBlueprint.GetBlueprintHyperlink` | - | - | - | Y | page |
| `C_HousingBlueprint.GetBlueprintTypeForCode` | - | - | - | Y | page |
| `C_HousingBlueprint.GetExportAvailability` | - | - | - | Y | page |
| `C_HousingBlueprint.GetFeatureAvailability` | - | - | - | Y | page |
| `C_HousingBlueprint.GetImportAvailability` | - | - | - | Y | page |
| `C_HousingBlueprint.ImportBlueprint` | - | - | - | Y | page |
| `C_HousingBlueprint.IsShareCodeValid` | - | - | - | Y | page |
| `C_HousingBlueprint.RenameBlueprint` | - | - | - | Y | page |
| `C_HousingBlueprint.RequestBlueprintCollection` | - | - | - | Y | page |
| `C_HousingBlueprint.RequestBlueprintContents` | - | - | - | Y | page |
| `C_HousingBlueprint.RequestBlueprintContentsForContext` | - | - | - | Y | page |
| `C_HousingBlueprint.StartImportRoomBlueprint` | - | - | - | Y | page |

### C_HousingCatalog

35 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingCatalog.CreateCatalogSearcher` | Y | Y | Y | Y | page |
| `C_HousingCatalog.DeletePreviewCartDecor` | Y | Y | Y | Y | page |
| `C_HousingCatalog.DestroyEntry` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetAllFilterTagGroups` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetAllVariantInfosForEntry` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetBundleInfo` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCartSizeLimit` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCatalogCategoryAndSubcategoryNames` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCatalogCategoryInfo` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCatalogEntryDebugInfoForID` | Y | Y | Y | Y | missing |
| `C_HousingCatalog.GetCatalogEntryInfo` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCatalogEntryInfoByItem` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCatalogEntryInfoByRecordID` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCatalogEntryVariantInfo` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetCatalogSubcategoryInfo` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetDecorMaxOwnedCount` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetDecorTotalOwnedCount` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetDestroyableInstanceCount` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetFeaturedBundles` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetFeaturedSmallProducts` | Y | Y | Y | Y | page |
| `C_HousingCatalog.GetMarketInfoForDecor` | Y | Y | Y | Y | page |
| `C_HousingCatalog.HasFeaturedEntries` | Y | Y | Y | Y | page |
| `C_HousingCatalog.HousingMarketActionAddToCart` | Y | Y | Y | Y | page |
| `C_HousingCatalog.HousingMarketActionClearCart` | Y | Y | Y | Y | page |
| `C_HousingCatalog.HousingMarketActionRemoveFromCart` | Y | Y | Y | Y | page |
| `C_HousingCatalog.HousingMarketActionViewBundle` | Y | Y | Y | Y | page |
| `C_HousingCatalog.HousingMarketActionViewInStore` | Y | Y | Y | Y | page |
| `C_HousingCatalog.IsPreviewCartItemShown` | Y | Y | Y | Y | page |
| `C_HousingCatalog.PromotePreviewDecor` | Y | Y | Y | Y | page |
| `C_HousingCatalog.RequestHousingMarketInfoRefresh` | Y | Y | Y | Y | page |
| `C_HousingCatalog.RequestHousingMarketRefundInfo` | Y | Y | Y | Y | page |
| `C_HousingCatalog.SearchCatalogCategories` | Y | Y | Y | Y | page |
| `C_HousingCatalog.SearchCatalogSubcategories` | Y | Y | Y | Y | page |
| `C_HousingCatalog.SetPreviewCartItemShown` | Y | Y | Y | Y | page |

### C_HousingCleanupMode

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingCleanupMode.GetHoveredDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingCleanupMode.IsHoveringDecor` | Y | Y | Y | Y | page |
| `C_HousingCleanupMode.RemoveSelectedDecor` | Y | Y | Y | Y | page |

### C_HousingCustomizeMode

32 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingCustomizeMode.ApplyDyeToSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.ApplyPetToSelectedDecor` | - | - | - | Y | page |
| `C_HousingCustomizeMode.ApplyThemeToRoom` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.ApplyThemeToSelectedRoomComponent` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.ApplyWallpaperToAllWalls` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.ApplyWallpaperToSelectedRoomComponent` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.CancelActiveEditing` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.ClearDyesForSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.ClearTargetRoomComponent` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.CommitDyesForSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetHoveredDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetHoveredRoomComponentInfo` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetNumDyesToRemoveOnSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetNumDyesToSpendOnSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetPreviewDyesOnSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetRecentlyUsedDyes` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetRecentlyUsedThemeSets` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetRecentlyUsedWallpapers` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetSelectedDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetSelectedDecorPetInfo` | - | - | - | Y | page |
| `C_HousingCustomizeMode.GetSelectedRoomComponentInfo` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetThemeSetInfo` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.GetWallpapersForRoomComponentType` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.IsDecorSelected` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.IsHouseExteriorDoorHovered` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.IsHoveringDecor` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.IsHoveringRoomComponent` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.IsRoomComponentSelected` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.RoomComponentSupportsVariant` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.RoomConnectionSupportsDoorType` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.SetRoomComponentCeilingType` | Y | Y | Y | Y | page |
| `C_HousingCustomizeMode.SetRoomComponentDoorType` | Y | Y | Y | Y | page |

### C_HousingDecor

38 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingDecor.AnyDecorPlacedInRoom` | - | - | - | Y | page |
| `C_HousingDecor.CancelActiveEditing` | Y | Y | Y | Y | page |
| `C_HousingDecor.CommitDecorMovement` | Y | Y | Y | Y | page |
| `C_HousingDecor.EnterPreviewState` | Y | Y | Y | Y | page |
| `C_HousingDecor.ExitPreviewState` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetAllMaxPlacementBudgets` | - | - | - | Y | page |
| `C_HousingDecor.GetAllPlacedDecor` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetAllSpentPlacementBudgets` | - | - | - | Y | page |
| `C_HousingDecor.GetDecorAssignedPetName` | - | - | - | Y | page |
| `C_HousingDecor.GetDecorCanAttachPet` | - | - | - | Y | page |
| `C_HousingDecor.GetDecorDebugInfoForGUID` | Y | Y | Y | Y | missing |
| `C_HousingDecor.GetDecorHyperlink` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetDecorIcon` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetDecorInstanceInfoForGUID` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetDecorName` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetHoveredDecorDebugInfo` | Y | Y | Y | Y | missing |
| `C_HousingDecor.GetHoveredDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetMaxPetPlacementBudget` | - | - | - | Y | page |
| `C_HousingDecor.GetMaxPlacementBudget` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetNumDecorPlaced` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetNumPreviewDecor` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetSelectedDecorDebugInfo` | Y | Y | Y | Y | missing |
| `C_HousingDecor.GetSelectedDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingDecor.GetSpentPetPlacementBudget` | - | - | - | Y | page |
| `C_HousingDecor.GetSpentPlacementBudget` | Y | Y | Y | Y | page |
| `C_HousingDecor.HasMaxPlacementBudget` | Y | Y | Y | Y | page |
| `C_HousingDecor.IsDecorSelected` | Y | Y | Y | Y | page |
| `C_HousingDecor.IsGridVisible` | Y | Y | Y | Y | page |
| `C_HousingDecor.IsHouseExteriorDoorHovered` | Y | Y | Y | Y | page |
| `C_HousingDecor.IsHouseExteriorHovered` | Y | Y | Y | Y | page |
| `C_HousingDecor.IsHoveringDecor` | Y | Y | Y | Y | page |
| `C_HousingDecor.IsModeDisabledForPreviewState` | Y | Y | Y | Y | page |
| `C_HousingDecor.IsPreviewState` | Y | Y | Y | Y | page |
| `C_HousingDecor.RemovePlacedDecorEntry` | Y | Y | Y | Y | page |
| `C_HousingDecor.RemoveSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingDecor.SetGridVisible` | Y | Y | Y | Y | page |
| `C_HousingDecor.SetPlacedDecorEntryHovered` | Y | Y | Y | Y | page |
| `C_HousingDecor.SetPlacedDecorEntrySelected` | Y | Y | Y | Y | page |

### C_HousingExpertMode

18 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingExpertMode.CancelActiveEditing` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.CommitDecorMovement` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.CommitHouseExteriorPosition` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.GetHoveredDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.GetPrecisionSubmode` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.GetPrecisionSubmodeRestriction` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.GetSelectedDecorInfo` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.IsDecorSelected` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.IsGridVisible` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.IsHouseExteriorHovered` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.IsHouseExteriorSelected` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.IsHoveringDecor` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.RemoveSelectedDecor` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.ResetPrecisionChanges` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.SelectNextRotationAxis` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.SetGridVisible` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.SetPrecisionIncrementingActive` | Y | Y | Y | Y | page |
| `C_HousingExpertMode.SetPrecisionSubmode` | Y | Y | Y | Y | page |

### C_HousingInspectMode

5 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingInspectMode.EnterInspectMode` | Y | Y | Y | Y | page |
| `C_HousingInspectMode.ExitInspectMode` | Y | Y | Y | Y | page |
| `C_HousingInspectMode.GetHoveredDecorGUID` | Y | Y | Y | Y | page |
| `C_HousingInspectMode.IsHoveringDecor` | Y | Y | Y | Y | page |
| `C_HousingInspectMode.IsInInspectMode` | Y | Y | Y | Y | page |

### C_HousingLayout

43 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingLayout.AnyRoomsOnFloor` | Y | Y | Y | Y | page |
| `C_HousingLayout.CancelActiveLayoutEditing` | Y | Y | Y | Y | page |
| `C_HousingLayout.CanSetViewedFloor` | Y | Y | - | Y | page |
| `C_HousingLayout.ConfirmStairChoice` | Y | Y | Y | Y | page |
| `C_HousingLayout.DeselectFloorplan` | Y | Y | Y | Y | page |
| `C_HousingLayout.DeselectRoomOrDoor` | Y | Y | Y | Y | page |
| `C_HousingLayout.GetBaseRoomFloor` | - | - | - | Y | page |
| `C_HousingLayout.GetHighestOccupiedFloorIndex` | - | - | - | Y | page |
| `C_HousingLayout.GetLowestOccupiedFloorIndex` | - | - | - | Y | page |
| `C_HousingLayout.GetNumActiveRooms` | Y | Y | Y | Y | page |
| `C_HousingLayout.GetNumFloors` | Y | Y | Y | - | page |
| `C_HousingLayout.GetRoomPlacementBudget` | Y | Y | Y | Y | page |
| `C_HousingLayout.GetRoomPlayerIsIn` | - | - | - | Y | page |
| `C_HousingLayout.GetSelectedBlueprintFloorplan` | - | - | - | Y | page |
| `C_HousingLayout.GetSelectedDoor` | Y | Y | Y | Y | page |
| `C_HousingLayout.GetSelectedFloorplan` | Y | Y | Y | Y | page |
| `C_HousingLayout.GetSelectedRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.GetSelectedStairwellRoomCount` | Y | Y | Y | Y | page |
| `C_HousingLayout.GetSpentPlacementBudget` | Y | Y | Y | Y | page |
| `C_HousingLayout.GetViewedFloor` | Y | Y | Y | Y | page |
| `C_HousingLayout.HasAnySelections` | Y | Y | Y | Y | page |
| `C_HousingLayout.HasRoomPlacementBudget` | Y | Y | Y | Y | page |
| `C_HousingLayout.HasSelectedBlueprintFloorplan` | - | - | - | Y | page |
| `C_HousingLayout.HasSelectedDoor` | Y | Y | Y | Y | page |
| `C_HousingLayout.HasSelectedFloorplan` | Y | Y | Y | Y | page |
| `C_HousingLayout.HasSelectedRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.HasStairs` | Y | Y | Y | Y | page |
| `C_HousingLayout.HasValidConnection` | Y | Y | Y | Y | page |
| `C_HousingLayout.IsBaseRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.IsDraggingRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.IsDraggingStairwell` | - | - | Y | - | page |
| `C_HousingLayout.MoveDraggedRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.MoveLayoutCamera` | Y | Y | Y | Y | page |
| `C_HousingLayout.RemoveRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.RoomHasStairs` | - | - | - | Y | page |
| `C_HousingLayout.RotateFocusedRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.RotateRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.SelectFloorplan` | Y | Y | Y | Y | page |
| `C_HousingLayout.SetViewedFloor` | Y | Y | Y | Y | page |
| `C_HousingLayout.StartDrag` | Y | Y | Y | Y | page |
| `C_HousingLayout.StopDrag` | Y | Y | Y | Y | page |
| `C_HousingLayout.StopDraggingRoom` | Y | Y | Y | Y | page |
| `C_HousingLayout.ZoomLayoutCamera` | Y | Y | Y | Y | page |

### C_HousingNeighborhood

30 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_HousingNeighborhood.CancelInviteToNeighborhood` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.CanReturnAfterVisitingHouse` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.DemoteToResident` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetCornerstoneHouseInfo` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetCornerstoneNeighborhoodInfo` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetCornerstonePurchaseMode` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetCurrentNeighborhoodTextureSuffix` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetDiscountedMovePrice` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetMoveCooldownTime` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetNeighborhoodMapData` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetNeighborhoodName` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetNeighborhoodPlotName` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.GetPreviousHouseIdentifier` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.HasPermissionToPurchase` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.InvitePlayerToNeighborhood` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.IsNeighborhoodManager` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.IsNeighborhoodOwner` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.IsPlayerInOtherPlayersPlot` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.IsPlotAvailableForPurchase` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.IsPlotOwnedByPlayer` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.OnBulletinBoardClosed` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.OnCornerstoneClosed` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.PromoteToManager` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.RequestNeighborhoodInfo` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.RequestNeighborhoodRoster` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.RequestPendingNeighborhoodInvites` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.TransferNeighborhoodOwnership` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.TryEvictPlayer` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.TryMoveHouse` | Y | Y | Y | Y | page |
| `C_HousingNeighborhood.TryPurchasePlot` | Y | Y | Y | Y | page |

### C_ImmersiveInteraction

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ImmersiveInteraction.HasImmersiveInteraction` | Y | Y | Y | Y | page |

### C_IncomingSummon

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_IncomingSummon.HasIncomingSummon` | Y | Y | Y | Y | page |
| `C_IncomingSummon.IncomingSummonStatus` | Y | Y | Y | Y | page |

### C_InstanceEncounter

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_InstanceEncounter.IsEncounterInProgress` | Y | Y | Y | Y | page |
| `C_InstanceEncounter.IsEncounterLimitingResurrections` | Y | Y | Y | Y | page |
| `C_InstanceEncounter.IsEncounterSuppressingRelease` | Y | Y | Y | Y | page |
| `C_InstanceEncounter.ShouldShowTimelineForEncounter` | Y | Y | Y | Y | page |

### C_InstanceLeaver

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_InstanceLeaver.IsPlayerLeaver` | - | - | - | Y | page |

### C_InterfaceFileManifest

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_InterfaceFileManifest.GetInterfaceArtFiles` | Y | Y | Y | Y | page |

### C_InvasionInfo

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_InvasionInfo.AreInvasionsAvailable` | - | - | - | Y | page |
| `C_InvasionInfo.GetInvasionForUiMapID` | - | - | - | Y | page |
| `C_InvasionInfo.GetInvasionInfo` | - | - | - | Y | page |
| `C_InvasionInfo.GetInvasionTimeLeft` | - | - | - | Y | page |

### C_IslandsQueue

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_IslandsQueue.CloseIslandsQueueScreen` | - | - | - | Y | page |
| `C_IslandsQueue.GetIslandDifficultyInfo` | - | - | - | Y | page |
| `C_IslandsQueue.GetIslandsMaxGroupSize` | - | - | - | Y | page |
| `C_IslandsQueue.GetIslandsWeeklyQuestID` | - | - | - | Y | page |
| `C_IslandsQueue.QueueForIsland` | - | - | - | Y | page |
| `C_IslandsQueue.RequestPreloadRewardData` | - | - | - | Y | page |

### C_Item

119 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Item.ActionBindsItem` | Y | Y | Y | Y | page |
| `C_Item.BindEnchant` | Y | Y | Y | Y | page |
| `C_Item.CanBeRefunded` | Y | Y | Y | Y | page |
| `C_Item.CanItemTransmogAppearance` | Y | Y | Y | Y | page |
| `C_Item.CanScrapItem` | - | - | - | Y | page |
| `C_Item.CanViewItemPowers` | - | - | - | Y | page |
| `C_Item.ConfirmBindOnUse` | Y | Y | Y | Y | page |
| `C_Item.ConfirmNoRefundOnUse` | Y | Y | Y | Y | page |
| `C_Item.ConfirmOnUse` | Y | Y | Y | Y | page |
| `C_Item.DoesItemContainSpec` | Y | Y | Y | Y | page |
| `C_Item.DoesItemExist` | Y | Y | Y | Y | page |
| `C_Item.DoesItemExistByID` | Y | Y | Y | Y | page |
| `C_Item.DoesItemMatchBonusTreeReplacement` | - | - | - | Y | page |
| `C_Item.DoesItemMatchSpellItemCondition` | - | - | - | Y | page |
| `C_Item.DoesItemMatchTargetEnchantingSpell` | - | - | - | Y | page |
| `C_Item.DoesItemMatchTrackJump` | - | - | - | Y | page |
| `C_Item.DropItemOnUnit` | Y | Y | Y | Y | page |
| `C_Item.EndBoundTradeable` | Y | Y | Y | Y | page |
| `C_Item.EndRefund` | Y | Y | Y | Y | page |
| `C_Item.EquipItemByName` | Y | Y | Y | Y | page |
| `C_Item.GetAppliedItemTransmogInfo` | Y | Y | Y | Y | page |
| `C_Item.GetBaseItemTransmogInfo` | Y | Y | Y | Y | page |
| `C_Item.GetCurrentItemLevel` | Y | Y | Y | Y | page |
| `C_Item.GetCurrentItemTransmogInfo` | Y | Y | Y | Y | page |
| `C_Item.GetDelvePreviewItemLink` | - | - | - | Y | page |
| `C_Item.GetDelvePreviewItemQuality` | - | - | - | Y | page |
| `C_Item.GetDetailedItemLevelInfo` | Y | Y | Y | Y | page |
| `C_Item.GetFirstTriggeredSpellForItem` | - | - | - | Y | page |
| `C_Item.GetItemChildInfo` | Y | Y | Y | Y | page |
| `C_Item.GetItemClassInfo` | Y | Y | Y | Y | page |
| `C_Item.GetItemConversionOutputIcon` | - | - | - | Y | page |
| `C_Item.GetItemCooldown` | - | - | - | Y | page |
| `C_Item.GetItemCount` | Y | Y | Y | Y | page |
| `C_Item.GetItemCreationContext` | Y | Y | Y | Y | page |
| `C_Item.GetItemFamily` | Y | Y | Y | Y | page |
| `C_Item.GetItemGem` | Y | Y | Y | Y | page |
| `C_Item.GetItemGemID` | Y | Y | Y | Y | page |
| `C_Item.GetItemGUID` | Y | Y | Y | Y | page |
| `C_Item.GetItemIcon` | Y | Y | Y | Y | page |
| `C_Item.GetItemIconByID` | Y | Y | Y | Y | page |
| `C_Item.GetItemID` | Y | Y | Y | Y | page |
| `C_Item.GetItemIDByGUID` | - | - | - | Y | page |
| `C_Item.GetItemIDForItemInfo` | Y | Y | Y | Y | page |
| `C_Item.GetItemInfo` | Y | Y | Y | Y | page |
| `C_Item.GetItemInfoInstant` | Y | Y | Y | Y | page |
| `C_Item.GetItemInventorySlotInfo` | Y | Y | Y | Y | page |
| `C_Item.GetItemInventorySlotKey` | Y | Y | Y | Y | page |
| `C_Item.GetItemInventoryType` | Y | Y | Y | Y | page |
| `C_Item.GetItemInventoryTypeByID` | Y | Y | Y | Y | page |
| `C_Item.GetItemLearnTransmogSet` | - | - | - | Y | page |
| `C_Item.GetItemLink` | Y | Y | Y | Y | page |
| `C_Item.GetItemLinkByGUID` | - | - | - | Y | page |
| `C_Item.GetItemLocation` | - | - | - | Y | page |
| `C_Item.GetItemMaxStackSize` | Y | Y | Y | Y | page |
| `C_Item.GetItemMaxStackSizeByID` | Y | Y | Y | Y | page |
| `C_Item.GetItemName` | Y | Y | Y | Y | page |
| `C_Item.GetItemNameByID` | Y | Y | Y | Y | page |
| `C_Item.GetItemNumAddedSockets` | Y | Y | Y | Y | page |
| `C_Item.GetItemNumSockets` | Y | Y | Y | Y | page |
| `C_Item.GetItemQuality` | Y | Y | Y | Y | page |
| `C_Item.GetItemQualityByID` | Y | Y | Y | Y | page |
| `C_Item.GetItemQualityColor` | Y | Y | Y | Y | page |
| `C_Item.GetItemSetInfo` | Y | Y | Y | Y | page |
| `C_Item.GetItemSpecInfo` | Y | Y | Y | Y | page |
| `C_Item.GetItemSpell` | Y | Y | Y | Y | page |
| `C_Item.GetItemStatDelta` | - | - | - | Y | page |
| `C_Item.GetItemStats` | - | - | - | Y | page |
| `C_Item.GetItemSubClassInfo` | Y | Y | Y | Y | page |
| `C_Item.GetItemUniqueness` | Y | Y | Y | Y | page |
| `C_Item.GetItemUniquenessByID` | Y | Y | Y | Y | page |
| `C_Item.GetItemUpgradeInfo` | - | - | - | Y | page |
| `C_Item.GetLimitedCurrencyItemInfo` | - | - | - | Y | page |
| `C_Item.GetSetBonusesForSpecializationByItemID` | - | - | - | Y | page |
| `C_Item.GetStackCount` | Y | Y | Y | Y | page |
| `C_Item.IsAnimaItemByID` | - | - | - | Y | page |
| `C_Item.IsArtifactPowerItem` | Y | Y | Y | Y | page |
| `C_Item.IsBound` | Y | Y | Y | Y | page |
| `C_Item.IsBoundToAccountUntilEquip` | - | - | - | Y | page |
| `C_Item.IsConsumableItem` | Y | Y | Y | Y | page |
| `C_Item.IsCorruptedItem` | - | - | - | Y | page |
| `C_Item.IsCosmeticItem` | - | - | - | Y | page |
| `C_Item.IsCurioItem` | - | - | - | Y | page |
| `C_Item.IsCurrentItem` | Y | Y | Y | Y | page |
| `C_Item.IsDecorItem` | - | - | - | Y | page |
| `C_Item.IsDressableItem` | Y | Y | Y | - | page |
| `C_Item.IsDressableItemByID` | - | - | - | Y | page |
| `C_Item.IsEquippableItem` | Y | Y | Y | Y | page |
| `C_Item.IsEquippedItem` | Y | Y | Y | Y | page |
| `C_Item.IsEquippedItemType` | Y | Y | Y | Y | page |
| `C_Item.IsHarmfulItem` | Y | Y | Y | Y | page |
| `C_Item.IsHelpfulItem` | Y | Y | Y | Y | page |
| `C_Item.IsItemBindToAccount` | - | - | - | Y | page |
| `C_Item.IsItemBindToAccountUntilEquip` | - | - | - | Y | page |
| `C_Item.IsItemConduit` | - | - | - | Y | page |
| `C_Item.IsItemConvertibleAndValidForPlayer` | - | - | - | Y | page |
| `C_Item.IsItemCorrupted` | - | - | - | Y | page |
| `C_Item.IsItemCorruptionRelated` | - | - | - | Y | page |
| `C_Item.IsItemCorruptionResistant` | - | - | - | Y | page |
| `C_Item.IsItemDataCached` | Y | Y | Y | Y | page |
| `C_Item.IsItemDataCachedByID` | Y | Y | Y | Y | page |
| `C_Item.IsItemGUIDInInventory` | - | - | - | Y | page |
| `C_Item.IsItemInRange` | Y | Y | Y | Y | page |
| `C_Item.IsItemKeystoneByID` | - | - | - | Y | page |
| `C_Item.IsItemSpecificToPlayerClass` | - | - | - | Y | page |
| `C_Item.IsLocked` | Y | Y | Y | Y | page |
| `C_Item.IsRelicItem` | - | - | - | Y | page |
| `C_Item.IsUsableItem` | Y | Y | Y | Y | page |
| `C_Item.ItemHasRange` | Y | Y | Y | Y | page |
| `C_Item.LockItem` | Y | Y | Y | Y | page |
| `C_Item.LockItemByGUID` | Y | Y | Y | Y | page |
| `C_Item.PickupItem` | Y | Y | Y | Y | page |
| `C_Item.ReplaceEnchant` | Y | Y | Y | Y | page |
| `C_Item.ReplaceTradeEnchant` | Y | Y | Y | Y | page |
| `C_Item.ReplaceTradeskillEnchant` | - | - | - | Y | page |
| `C_Item.RequestLoadItemData` | Y | Y | Y | Y | page |
| `C_Item.RequestLoadItemDataByID` | Y | Y | Y | Y | page |
| `C_Item.UnlockItem` | Y | Y | Y | Y | page |
| `C_Item.UnlockItemByGUID` | Y | Y | Y | Y | page |
| `C_Item.UseItemByName` | Y | Y | Y | Y | page |

### C_ItemInteraction

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ItemInteraction.ClearPendingItem` | - | - | - | Y | page |
| `C_ItemInteraction.CloseUI` | - | - | - | Y | page |
| `C_ItemInteraction.GetChargeInfo` | - | - | - | Y | page |
| `C_ItemInteraction.GetItemConversionCurrencyCost` | - | - | - | Y | page |
| `C_ItemInteraction.GetItemInteractionInfo` | - | - | - | Y | page |
| `C_ItemInteraction.GetItemInteractionSpellId` | - | - | - | Y | page |
| `C_ItemInteraction.InitializeFrame` | - | - | - | Y | page |
| `C_ItemInteraction.PerformItemInteraction` | - | - | - | Y | page |
| `C_ItemInteraction.Reset` | - | - | - | Y | page |
| `C_ItemInteraction.SetPendingItem` | - | - | - | Y | page |

### C_ItemSocketInfo

16 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ItemSocketInfo.AcceptSockets` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.ClickSocketButton` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.CloseSocketInfo` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.CompleteSocketing` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetCurrUIType` | - | - | - | Y | page |
| `C_ItemSocketInfo.GetExistingSocketInfo` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetExistingSocketLink` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetNewSocketInfo` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetNewSocketLink` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetNumSockets` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetSocketItemBoundTradeable` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetSocketItemInfo` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetSocketItemRefundable` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.GetSocketTypes` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.HasBoundGemProposed` | Y | Y | Y | Y | page |
| `C_ItemSocketInfo.IsArtifactRelicItem` | - | - | - | Y | page |

### C_ItemUpgrade

16 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ItemUpgrade.CanUpgradeItem` | Y | Y | Y | Y | page |
| `C_ItemUpgrade.ClearItemUpgrade` | Y | Y | Y | Y | page |
| `C_ItemUpgrade.CloseItemUpgrade` | Y | Y | Y | Y | page |
| `C_ItemUpgrade.GetHighWatermarkForItem` | - | - | - | Y | page |
| `C_ItemUpgrade.GetHighWatermarkForSlot` | - | - | - | Y | page |
| `C_ItemUpgrade.GetHighWatermarkSlotForItem` | - | - | - | Y | page |
| `C_ItemUpgrade.GetItemHyperlink` | Y | Y | Y | Y | page |
| `C_ItemUpgrade.GetItemUpgradeCurrentLevel` | - | - | - | Y | page |
| `C_ItemUpgrade.GetItemUpgradeEffect` | Y | Y | Y | Y | page |
| `C_ItemUpgrade.GetItemUpgradeItemInfo` | Y | Y | Y | Y | page |
| `C_ItemUpgrade.GetItemUpgradePvpItemLevelDeltaValues` | - | - | - | Y | page |
| `C_ItemUpgrade.GetNumItemUpgradeEffects` | Y | Y | Y | Y | page |
| `C_ItemUpgrade.IsItemBound` | - | - | - | Y | page |
| `C_ItemUpgrade.SetItemUpgradeFromCursorItem` | Y | Y | Y | Y | page |
| `C_ItemUpgrade.SetItemUpgradeFromLocation` | - | - | - | Y | page |
| `C_ItemUpgrade.UpgradeItem` | Y | Y | Y | Y | page |

### C_KeyBindings

11 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_KeyBindings.ActivateBindingContext` | Y | Y | Y | Y | page |
| `C_KeyBindings.DeactivateBindingContext` | Y | Y | Y | Y | page |
| `C_KeyBindings.GetBindingByKey` | Y | Y | Y | Y | page |
| `C_KeyBindings.GetBindingContextForAction` | Y | Y | Y | Y | page |
| `C_KeyBindings.GetBindingIndex` | Y | Y | Y | Y | page |
| `C_KeyBindings.GetCustomBindingType` | Y | Y | Y | Y | page |
| `C_KeyBindings.GetSearchTagsForAction` | Y | Y | Y | Y | page |
| `C_KeyBindings.GetTurnStrafeStyle` | Y | Y | Y | Y | page |
| `C_KeyBindings.IsBindingContextActive` | Y | Y | Y | Y | page |
| `C_KeyBindings.SetTurnStrafeStyle` | Y | Y | Y | Y | page |
| `C_KeyBindings.UpdateTurnStrafeBindingsForCharacter` | Y | Y | Y | Y | page |

### C_LegendaryCrafting

20 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LegendaryCrafting.CloseRuneforgeInteraction` | - | - | - | Y | page |
| `C_LegendaryCrafting.CraftRuneforgeLegendary` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgeItemPreviewInfo` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgeLegendaryComponentInfo` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgeLegendaryCost` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgeLegendaryCraftSpellID` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgeLegendaryCurrencies` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgeLegendaryUpgradeCost` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgeModifierInfo` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgeModifiers` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgePowerInfo` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgePowers` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant` | - | - | - | Y | page |
| `C_LegendaryCrafting.GetRuneforgePowerSlots` | - | - | - | Y | page |
| `C_LegendaryCrafting.IsRuneforgeLegendary` | - | - | - | Y | page |
| `C_LegendaryCrafting.IsRuneforgeLegendaryMaxLevel` | - | - | - | Y | page |
| `C_LegendaryCrafting.IsUpgradeItemValidForRuneforgeLegendary` | - | - | - | Y | page |
| `C_LegendaryCrafting.IsValidRuneforgeBaseItem` | - | - | - | Y | page |
| `C_LegendaryCrafting.MakeRuneforgeCraftDescription` | - | - | - | Y | page |
| `C_LegendaryCrafting.UpgradeRuneforgeLegendary` | - | - | - | Y | page |

### C_LevelLink

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LevelLink.IsActionLocked` | - | - | - | Y | page |
| `C_LevelLink.IsSpellLocked` | - | - | - | Y | page |

### C_LevelSquish

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LevelSquish.ConvertFollowerLevel` | - | - | - | Y | page |
| `C_LevelSquish.ConvertPlayerLevel` | - | - | - | Y | page |

### C_LFGInfo

21 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LFGInfo.AreCrossFactionGroupQueuesAllowed` | - | - | - | Y | page |
| `C_LFGInfo.CanPlayerUseGroupFinder` | Y | Y | Y | Y | page |
| `C_LFGInfo.CanPlayerUseLFD` | Y | Y | Y | Y | page |
| `C_LFGInfo.CanPlayerUseLFR` | Y | Y | Y | Y | page |
| `C_LFGInfo.CanPlayerUsePremadeGroup` | Y | Y | Y | Y | page |
| `C_LFGInfo.CanPlayerUsePVP` | - | - | - | Y | page |
| `C_LFGInfo.CanPlayerUseScenarioFinder` | Y | Y | Y | Y | page |
| `C_LFGInfo.ConfirmLfgExpandSearch` | - | - | - | Y | page |
| `C_LFGInfo.DoesActivePartyMeetPremadeLaunchCount` | - | - | - | Y | page |
| `C_LFGInfo.DoesCrossFactionQueueRequireFullPremade` | - | - | - | Y | page |
| `C_LFGInfo.GetAllEntriesForCategory` | Y | Y | Y | Y | page |
| `C_LFGInfo.GetDungeonInfo` | Y | Y | Y | Y | page |
| `C_LFGInfo.GetLevelUpInstances` | Y | Y | Y | Y | page |
| `C_LFGInfo.GetLFDLockStates` | Y | Y | Y | Y | page |
| `C_LFGInfo.GetRoleCheckDifficultyDetails` | Y | Y | Y | Y | page |
| `C_LFGInfo.HideNameFromUI` | Y | Y | Y | Y | page |
| `C_LFGInfo.IsGroupFinderEnabled` | Y | Y | Y | Y | page |
| `C_LFGInfo.IsInLFGFollowerDungeon` | Y | Y | Y | Y | page |
| `C_LFGInfo.IsLFDEnabled` | Y | Y | Y | Y | page |
| `C_LFGInfo.IsLFGFollowerDungeon` | Y | Y | Y | Y | page |
| `C_LFGInfo.IsLFREnabled` | Y | Y | Y | Y | page |

### C_LFGList

88 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LFGList.AcceptInvite` | Y | Y | Y | Y | missing |
| `C_LFGList.ApplyToGroup` | Y | Y | Y | Y | page |
| `C_LFGList.CanActiveEntryUseAutoAccept` | Y | Y | Y | Y | page |
| `C_LFGList.CancelApplication` | Y | Y | Y | Y | missing |
| `C_LFGList.CanCreateQuestGroup` | Y | Y | Y | Y | page |
| `C_LFGList.CanCreateScenarioGroup` | - | - | - | Y | page |
| `C_LFGList.ClearApplicationTextFields` | Y | Y | Y | Y | page |
| `C_LFGList.ClearCreationTextFields` | Y | Y | Y | Y | page |
| `C_LFGList.ClearSearchResults` | Y | Y | Y | Y | page |
| `C_LFGList.ClearSearchTextFields` | Y | Y | Y | Y | page |
| `C_LFGList.ConfirmCensoredActiveEntry` | - | - | - | Y | page |
| `C_LFGList.CopyActiveEntryInfoToCreationFields` | Y | Y | Y | Y | page |
| `C_LFGList.CreateListing` | Y | Y | Y | Y | page |
| `C_LFGList.CreateScenarioListing` | - | - | - | Y | page |
| `C_LFGList.DeclineApplicant` | Y | Y | Y | Y | missing |
| `C_LFGList.DeclineInvite` | Y | Y | Y | Y | missing |
| `C_LFGList.DoesCensoredTextMatch` | - | - | - | Y | page |
| `C_LFGList.DoesEntryTitleMatchPrebuiltTitle` | Y | Y | Y | Y | page |
| `C_LFGList.GetActiveEntryInfo` | Y | Y | Y | Y | page |
| `C_LFGList.GetActivityFullName` | Y | Y | Y | Y | page |
| `C_LFGList.GetActivityGroupInfo` | Y | Y | Y | Y | page |
| `C_LFGList.GetActivityIDForQuestID` | Y | Y | Y | Y | missing |
| `C_LFGList.GetActivityInfoExpensive` | Y | Y | Y | Y | page |
| `C_LFGList.GetActivityInfoTable` | Y | Y | Y | Y | page |
| `C_LFGList.GetAdvancedFilter` | - | - | - | Y | page |
| `C_LFGList.GetApplicantBestDungeonScore` | - | - | - | Y | page |
| `C_LFGList.GetApplicantDungeonScoreForListing` | Y | Y | Y | Y | page |
| `C_LFGList.GetApplicantInfo` | Y | Y | Y | Y | page |
| `C_LFGList.GetApplicantMemberInfo` | Y | Y | Y | Y | page |
| `C_LFGList.GetApplicantMemberStats` | Y | Y | Y | Y | page |
| `C_LFGList.GetApplicantPvpRatingInfoForListing` | Y | Y | Y | Y | page |
| `C_LFGList.GetApplicants` | Y | Y | Y | Y | page |
| `C_LFGList.GetApplicationInfo` | Y | Y | Y | Y | missing |
| `C_LFGList.GetApplications` | Y | Y | Y | Y | missing |
| `C_LFGList.GetAvailableActivities` | Y | Y | Y | Y | page |
| `C_LFGList.GetAvailableActivityGroups` | Y | Y | Y | Y | page |
| `C_LFGList.GetAvailableCategories` | Y | Y | Y | Y | page |
| `C_LFGList.GetAvailableLanguageSearchFilter` | Y | Y | Y | Y | missing |
| `C_LFGList.GetAvailableRoles` | Y | Y | Y | Y | missing |
| `C_LFGList.GetDefaultLanguageSearchFilter` | Y | Y | Y | Y | missing |
| `C_LFGList.GetFilteredSearchResults` | Y | Y | Y | Y | page |
| `C_LFGList.GetGroupLeaverCountsByRole` | Y | Y | Y | Y | page |
| `C_LFGList.GetKeystoneForActivity` | Y | Y | Y | Y | page |
| `C_LFGList.GetLanguageSearchFilter` | Y | Y | Y | Y | missing |
| `C_LFGList.GetLfgCategoryInfo` | Y | Y | Y | Y | page |
| `C_LFGList.GetNumApplicants` | Y | Y | Y | Y | missing |
| `C_LFGList.GetNumApplications` | Y | Y | Y | Y | missing |
| `C_LFGList.GetNumInvitedApplicantMembers` | Y | Y | Y | Y | missing |
| `C_LFGList.GetNumPendingApplicantMembers` | Y | Y | Y | Y | missing |
| `C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel` | Y | Y | Y | Y | page |
| `C_LFGList.GetPlaystyleString` | Y | Y | Y | Y | page |
| `C_LFGList.GetPremadeGroupFinderStyle` | Y | Y | Y | Y | page |
| `C_LFGList.GetRoleCheckInfo` | Y | Y | Y | Y | missing |
| `C_LFGList.GetSearchResultEncounterInfo` | Y | Y | Y | Y | missing |
| `C_LFGList.GetSearchResultFriends` | Y | Y | Y | Y | page |
| `C_LFGList.GetSearchResultInfo` | Y | Y | Y | Y | page |
| `C_LFGList.GetSearchResultLeaderInfo` | Y | Y | Y | Y | page |
| `C_LFGList.GetSearchResultMemberCounts` | Y | Y | Y | Y | missing |
| `C_LFGList.GetSearchResultPlayerInfo` | Y | Y | Y | Y | page |
| `C_LFGList.GetSearchResults` | Y | Y | Y | Y | page |
| `C_LFGList.HasActiveEntryInfo` | Y | Y | Y | Y | page |
| `C_LFGList.HasActivityList` | Y | Y | Y | Y | missing |
| `C_LFGList.HasSearchResultInfo` | Y | Y | Y | Y | page |
| `C_LFGList.InviteApplicant` | Y | Y | Y | Y | page |
| `C_LFGList.IsCensoredActiveEntryUnresolved` | - | - | - | Y | page |
| `C_LFGList.IsCurrentlyApplying` | Y | Y | Y | Y | missing |
| `C_LFGList.IsPlayerAuthenticatedForLFG` | Y | Y | Y | Y | page |
| `C_LFGList.IsPlayerValidForEndgameFieldEdits` | Y | Y | Y | Y | page |
| `C_LFGList.IsPremadeGroupFinderEnabled` | Y | Y | Y | Y | page |
| `C_LFGList.ListingUsesEndgameEditRestrictions` | Y | Y | Y | Y | page |
| `C_LFGList.RefreshApplicants` | Y | Y | Y | Y | missing |
| `C_LFGList.RemoveApplicant` | Y | Y | Y | Y | missing |
| `C_LFGList.RemoveListing` | Y | Y | Y | Y | page |
| `C_LFGList.ReportGroupAsAdvertisement` | Y | Y | Y | Y | page |
| `C_LFGList.RequestAvailableActivities` | Y | Y | Y | Y | page |
| `C_LFGList.RevealCensoredActiveEntry` | - | - | - | Y | page |
| `C_LFGList.RevealCensoredSearchResult` | - | - | - | Y | page |
| `C_LFGList.SaveAdvancedFilter` | - | - | - | Y | page |
| `C_LFGList.SaveLanguageSearchFilter` | Y | Y | Y | Y | missing |
| `C_LFGList.Search` | Y | Y | Y | Y | page |
| `C_LFGList.SetApplicantMemberRole` | Y | Y | Y | Y | missing |
| `C_LFGList.SetEntryTitle` | Y | Y | Y | Y | page |
| `C_LFGList.SetSearchToActivity` | Y | Y | Y | Y | page |
| `C_LFGList.SetSearchToQuestID` | Y | Y | Y | Y | page |
| `C_LFGList.SetSearchToScenarioID` | - | - | - | Y | page |
| `C_LFGList.UpdateListing` | Y | Y | Y | Y | page |
| `C_LFGList.ValidateRequiredDungeonScore` | Y | Y | Y | Y | page |
| `C_LFGList.ValidateRequiredPvpRatingForActivity` | Y | Y | Y | Y | page |

### C_LFGListRoles

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LFGListRoles.GetRoles` | Y | Y | Y | - | page |
| `C_LFGListRoles.GetSavedRoles` | Y | Y | Y | - | page |
| `C_LFGListRoles.SetRoles` | Y | Y | Y | - | page |

### C_LimitedInput

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LimitedInput.LimitedInputAllowed` | Y | Y | Y | Y | page |

### C_LobbyMatchmakerInfo

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LobbyMatchmakerInfo.AbandonQueue` | - | - | - | Y | page |
| `C_LobbyMatchmakerInfo.EnterQueue` | - | - | - | Y | page |
| `C_LobbyMatchmakerInfo.GetCurrQueuePlaylistEntry` | - | - | - | Y | page |
| `C_LobbyMatchmakerInfo.GetCurrQueueState` | - | - | - | Y | page |
| `C_LobbyMatchmakerInfo.GetQueueFromMainlineEnabled` | - | - | - | Y | page |
| `C_LobbyMatchmakerInfo.GetQueueStartTime` | - | - | - | Y | page |
| `C_LobbyMatchmakerInfo.IsInQueue` | Y | Y | Y | Y | page |
| `C_LobbyMatchmakerInfo.RespondToQueuePop` | - | - | - | Y | page |

### C_Log

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Log.LogErrorMessage` | Y | Y | Y | Y | page |
| `C_Log.LogMessage` | Y | Y | Y | Y | page |
| `C_Log.LogMessageWithPriority` | Y | Y | Y | Y | page |
| `C_Log.LogWarningMessage` | Y | Y | Y | Y | page |

### C_Loot

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Loot.GetLootRollDuration` | - | - | - | Y | page |
| `C_Loot.IsLegacyLootModeEnabled` | Y | Y | Y | Y | page |

### C_LootHistory

12 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LootHistory.CanMasterLoot` | Y | Y | Y | - | missing |
| `C_LootHistory.GetAllEncounterInfos` | - | - | - | Y | page |
| `C_LootHistory.GetExpiration` | Y | Y | Y | - | missing |
| `C_LootHistory.GetInfoForEncounter` | - | - | - | Y | page |
| `C_LootHistory.GetItem` | Y | Y | Y | - | page |
| `C_LootHistory.GetLootHistoryTime` | - | - | - | Y | page |
| `C_LootHistory.GetNumItems` | Y | Y | Y | - | missing |
| `C_LootHistory.GetPlayerInfo` | Y | Y | Y | - | page |
| `C_LootHistory.GetSortedDropsForEncounter` | - | - | - | Y | page |
| `C_LootHistory.GetSortedInfoForDrop` | - | - | - | Y | page |
| `C_LootHistory.GiveMasterLoot` | Y | Y | Y | - | missing |
| `C_LootHistory.SetExpiration` | Y | Y | Y | - | missing |

### C_LootJournal

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LootJournal.GetItemSetItems` | - | - | - | Y | page |
| `C_LootJournal.GetItemSets` | - | - | - | Y | page |

### C_LoreText

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LoreText.RequestLoreTextForCampaignID` | - | - | - | Y | page |

### C_LossOfControl

5 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_LossOfControl.GetActiveLossOfControlData` | Y | Y | Y | Y | page |
| `C_LossOfControl.GetActiveLossOfControlDataByUnit` | Y | Y | Y | Y | page |
| `C_LossOfControl.GetActiveLossOfControlDataCount` | Y | Y | Y | Y | page |
| `C_LossOfControl.GetActiveLossOfControlDataCountByUnit` | Y | Y | Y | Y | page |
| `C_LossOfControl.GetActiveLossOfControlDuration` | Y | Y | Y | Y | page |

### C_Macro

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Macro.GetMacroName` | Y | Y | Y | Y | page |
| `C_Macro.GetNumIcons` | Y | Y | Y | - | page |
| `C_Macro.GetSelectedMacroIcon` | Y | Y | Y | Y | page |
| `C_Macro.RunMacroText` | Y | Y | Y | Y | page |

### C_Mail

5 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Mail.CanCheckInbox` | - | - | - | Y | page |
| `C_Mail.GetCraftingOrderMailInfo` | - | - | - | Y | page |
| `C_Mail.HasInboxMoney` | Y | Y | Y | Y | page |
| `C_Mail.IsCommandPending` | Y | Y | Y | Y | page |
| `C_Mail.SetOpeningAll` | - | - | - | Y | page |

### C_MajorFactions

12 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_MajorFactions.GetCurrentRenownLevel` | - | - | - | Y | page |
| `C_MajorFactions.GetMajorFactionData` | - | - | - | Y | page |
| `C_MajorFactions.GetMajorFactionIDs` | - | - | - | Y | page |
| `C_MajorFactions.GetMajorFactionRenownInfo` | - | - | - | Y | page |
| `C_MajorFactions.GetRenownLevels` | - | - | - | Y | page |
| `C_MajorFactions.GetRenownNPCFactionID` | - | - | - | Y | page |
| `C_MajorFactions.GetRenownRewardsForLevel` | - | - | - | Y | page |
| `C_MajorFactions.HasMaximumRenown` | - | - | - | Y | page |
| `C_MajorFactions.IsMajorFactionHiddenFromExpansionPage` | - | - | - | Y | page |
| `C_MajorFactions.IsWeeklyRenownCapped` | - | - | - | Y | page |
| `C_MajorFactions.ShouldDisplayMajorFactionAsJourney` | - | - | - | Y | page |
| `C_MajorFactions.ShouldUseJourneyRewardTrack` | - | - | - | Y | page |

### C_Map

41 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Map.CanSetUserWaypointOnMap` | - | - | - | Y | page |
| `C_Map.ClearUserWaypoint` | - | - | - | Y | page |
| `C_Map.CloseWorldMapInteraction` | - | - | - | Y | page |
| `C_Map.GetAreaInfo` | Y | Y | Y | Y | page |
| `C_Map.GetBestMapForUnit` | Y | Y | Y | Y | page |
| `C_Map.GetBountySetIDForMap` | Y | Y | Y | - | page |
| `C_Map.GetBountySetMaps` | - | - | - | Y | page |
| `C_Map.GetFallbackWorldMapID` | Y | Y | Y | Y | page |
| `C_Map.GetMapArtBackgroundAtlas` | Y | Y | Y | Y | page |
| `C_Map.GetMapArtHelpTextPosition` | Y | Y | Y | Y | page |
| `C_Map.GetMapArtID` | Y | Y | Y | Y | page |
| `C_Map.GetMapArtLayers` | Y | Y | Y | Y | page |
| `C_Map.GetMapArtLayerTextures` | Y | Y | Y | Y | page |
| `C_Map.GetMapArtZoneTextPosition` | - | - | - | Y | page |
| `C_Map.GetMapBannersForMap` | Y | Y | Y | Y | page |
| `C_Map.GetMapChildrenInfo` | Y | Y | Y | Y | page |
| `C_Map.GetMapDisplayInfo` | Y | Y | Y | Y | page |
| `C_Map.GetMapGroupID` | Y | Y | Y | Y | page |
| `C_Map.GetMapGroupMembersInfo` | Y | Y | Y | Y | page |
| `C_Map.GetMapHighlightInfoAtPosition` | Y | Y | Y | Y | page |
| `C_Map.GetMapHighlightPulseInfo` | - | - | - | Y | page |
| `C_Map.GetMapInfo` | Y | Y | Y | Y | page |
| `C_Map.GetMapInfoAtPosition` | Y | Y | Y | Y | page |
| `C_Map.GetMapLevels` | Y | Y | Y | Y | page |
| `C_Map.GetMapLinksForMap` | Y | Y | Y | Y | page |
| `C_Map.GetMapPosFromWorldPos` | Y | Y | Y | Y | page |
| `C_Map.GetMapRectOnMap` | Y | Y | Y | Y | page |
| `C_Map.GetMapWorldSize` | - | - | - | Y | page |
| `C_Map.GetPlayerMapPosition` | Y | Y | Y | Y | page |
| `C_Map.GetUserWaypoint` | - | - | - | Y | page |
| `C_Map.GetUserWaypointFromHyperlink` | - | - | - | Y | page |
| `C_Map.GetUserWaypointHyperlink` | - | - | - | Y | page |
| `C_Map.GetUserWaypointPositionForMap` | - | - | - | Y | page |
| `C_Map.GetWorldPosFromMapPos` | Y | Y | Y | Y | page |
| `C_Map.HasUserWaypoint` | - | - | - | Y | page |
| `C_Map.IsCityMap` | - | - | - | Y | page |
| `C_Map.IsMapValidForNavBarDropdown` | - | - | - | Y | page |
| `C_Map.MapHasArt` | Y | Y | Y | Y | page |
| `C_Map.OpenWorldMap` | - | - | - | Y | page |
| `C_Map.RequestPreloadMap` | Y | Y | Y | Y | page |
| `C_Map.SetUserWaypoint` | - | - | - | Y | page |

### C_MapExplorationInfo

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_MapExplorationInfo.GetExploredAreaIDsAtPosition` | Y | Y | Y | Y | page |
| `C_MapExplorationInfo.GetExploredMapTextures` | Y | Y | Y | Y | page |

### C_MerchantFrame

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_MerchantFrame.GetBuybackItemID` | Y | Y | Y | Y | page |
| `C_MerchantFrame.GetItemInfo` | - | - | - | Y | page |
| `C_MerchantFrame.GetMerchantCurrencies` | - | - | - | Y | page |
| `C_MerchantFrame.GetNumJunkItems` | - | - | - | Y | page |
| `C_MerchantFrame.IsMerchantItemRefundable` | - | - | - | Y | page |
| `C_MerchantFrame.IsSellAllJunkEnabled` | - | - | - | Y | page |
| `C_MerchantFrame.SellAllJunkItems` | - | - | - | Y | page |

### C_Minimap

23 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Minimap.CanTrackBattlePets` | - | - | - | Y | page |
| `C_Minimap.ClearAllTracking` | Y | Y | Y | Y | page |
| `C_Minimap.ClearMinimapInsetInfo` | - | - | - | Y | page |
| `C_Minimap.GetDefaultTrackingValue` | - | - | - | Y | page |
| `C_Minimap.GetDrawGroundTextures` | - | - | - | Y | page |
| `C_Minimap.GetNumQuestPOIWorldEffects` | - | - | - | Y | page |
| `C_Minimap.GetNumTrackingTypes` | Y | Y | Y | Y | page |
| `C_Minimap.GetPOITextureCoords` | Y | Y | Y | Y | page |
| `C_Minimap.GetTrackingFilter` | - | - | - | Y | page |
| `C_Minimap.GetTrackingInfo` | Y | Y | Y | Y | page |
| `C_Minimap.GetUiMapID` | - | - | - | Y | page |
| `C_Minimap.GetViewRadius` | - | - | - | Y | page |
| `C_Minimap.IsFilteredOut` | - | - | - | Y | page |
| `C_Minimap.IsInsideQuestBlob` | - | - | - | Y | page |
| `C_Minimap.IsRotateMinimapIgnored` | - | - | - | Y | page |
| `C_Minimap.IsTrackingAccountCompletedQuests` | - | - | - | Y | page |
| `C_Minimap.IsTrackingBattlePets` | - | - | - | Y | page |
| `C_Minimap.IsTrackingHiddenQuests` | - | - | - | Y | page |
| `C_Minimap.SetDrawGroundTextures` | - | - | - | Y | page |
| `C_Minimap.SetIgnoreRotateMinimap` | - | - | - | Y | page |
| `C_Minimap.SetMinimapInsetInfo` | - | - | - | Y | page |
| `C_Minimap.SetTracking` | Y | Y | Y | Y | page |
| `C_Minimap.ShouldUseHybridMinimap` | - | - | - | Y | page |

### C_ModelInfo

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ModelInfo.AddActiveModelScene` | Y | Y | Y | Y | page |
| `C_ModelInfo.AddActiveModelSceneActor` | Y | Y | Y | Y | page |
| `C_ModelInfo.ClearActiveModelScene` | Y | Y | Y | Y | page |
| `C_ModelInfo.ClearActiveModelSceneActor` | Y | Y | Y | Y | page |
| `C_ModelInfo.GetModelSceneActorDisplayInfoByID` | Y | Y | Y | Y | page |
| `C_ModelInfo.GetModelSceneActorInfoByID` | Y | Y | Y | Y | page |
| `C_ModelInfo.GetModelSceneCameraInfoByID` | Y | Y | Y | Y | page |
| `C_ModelInfo.GetModelSceneInfoByID` | Y | Y | Y | Y | page |

### C_ModifiedInstance

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ModifiedInstance.GetModifiedInstanceInfoFromMapID` | - | - | - | Y | page |

### C_MountJournal

48 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_MountJournal.ApplyMountEquipment` | - | - | - | Y | page |
| `C_MountJournal.AreMountEquipmentEffectsSuppressed` | - | - | - | Y | page |
| `C_MountJournal.ClearFanfare` | Y | Y | Y | Y | page |
| `C_MountJournal.ClearRecentFanfares` | Y | Y | Y | Y | page |
| `C_MountJournal.Dismiss` | Y | Y | Y | Y | page |
| `C_MountJournal.GetAllCreatureDisplayIDsForMountID` | Y | Y | Y | Y | page |
| `C_MountJournal.GetAppliedMountEquipmentID` | - | - | - | Y | page |
| `C_MountJournal.GetCollectedDragonridingMounts` | Y | Y | Y | Y | page |
| `C_MountJournal.GetCollectedFilterSetting` | Y | Y | Y | Y | page |
| `C_MountJournal.GetDisplayedMountAllCreatureDisplayInfo` | Y | Y | Y | Y | page |
| `C_MountJournal.GetDisplayedMountID` | Y | Y | Y | Y | page |
| `C_MountJournal.GetDisplayedMountInfo` | Y | Y | Y | Y | page |
| `C_MountJournal.GetDisplayedMountInfoExtra` | Y | Y | Y | Y | page |
| `C_MountJournal.GetDynamicFlightModeSpellID` | Y | Y | Y | Y | page |
| `C_MountJournal.GetIsFavorite` | Y | Y | Y | Y | page |
| `C_MountJournal.GetMountAllCreatureDisplayInfoByID` | Y | Y | Y | Y | page |
| `C_MountJournal.GetMountEquipmentUnlockLevel` | - | - | - | Y | page |
| `C_MountJournal.GetMountFromItem` | Y | Y | Y | Y | page |
| `C_MountJournal.GetMountFromSpell` | Y | Y | Y | Y | page |
| `C_MountJournal.GetMountIDs` | Y | Y | Y | Y | page |
| `C_MountJournal.GetMountInfoByID` | Y | Y | Y | Y | page |
| `C_MountJournal.GetMountInfoExtraByID` | Y | Y | Y | Y | page |
| `C_MountJournal.GetMountLink` | Y | Y | Y | Y | page |
| `C_MountJournal.GetMountUsabilityByID` | Y | Y | Y | Y | page |
| `C_MountJournal.GetNumDisplayedMounts` | Y | Y | Y | Y | page |
| `C_MountJournal.GetNumMounts` | Y | Y | Y | Y | page |
| `C_MountJournal.GetNumMountsNeedingFanfare` | Y | Y | Y | Y | page |
| `C_MountJournal.IsDragonridingUnlocked` | Y | Y | Y | Y | page |
| `C_MountJournal.IsItemMountEquipment` | - | - | - | Y | page |
| `C_MountJournal.IsMountEquipmentApplied` | - | - | - | Y | page |
| `C_MountJournal.IsSourceChecked` | Y | Y | Y | Y | page |
| `C_MountJournal.IsTypeChecked` | Y | Y | Y | Y | page |
| `C_MountJournal.IsUsingDefaultFilters` | Y | Y | Y | Y | page |
| `C_MountJournal.IsValidSourceFilter` | Y | Y | Y | Y | page |
| `C_MountJournal.IsValidTypeFilter` | Y | Y | Y | Y | page |
| `C_MountJournal.NeedsFanfare` | Y | Y | Y | Y | page |
| `C_MountJournal.Pickup` | Y | Y | Y | Y | page |
| `C_MountJournal.PickupDynamicFlightMode` | Y | Y | Y | Y | page |
| `C_MountJournal.SetAllSourceFilters` | Y | Y | Y | Y | page |
| `C_MountJournal.SetAllTypeFilters` | Y | Y | Y | Y | page |
| `C_MountJournal.SetCollectedFilterSetting` | Y | Y | Y | Y | page |
| `C_MountJournal.SetDefaultFilters` | Y | Y | Y | Y | page |
| `C_MountJournal.SetIsFavorite` | Y | Y | Y | Y | page |
| `C_MountJournal.SetSearch` | Y | Y | Y | Y | page |
| `C_MountJournal.SetSourceFilter` | Y | Y | Y | Y | page |
| `C_MountJournal.SetTypeFilter` | Y | Y | Y | Y | page |
| `C_MountJournal.SummonByID` | Y | Y | Y | Y | page |
| `C_MountJournal.SwapDynamicFlightMode` | Y | Y | Y | Y | page |

### C_MythicPlus

22 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_MythicPlus.GetCurrentAffixes` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetCurrentSeason` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetCurrentSeasonValues` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetCurrentUIDisplaySeason` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetEndOfRunGearSequenceLevel` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetLastWeeklyBestInformation` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetOwnedKeystoneChallengeMapID` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetOwnedKeystoneLevel` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetOwnedKeystoneMapID` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetRewardLevelForDifficultyLevel` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetRewardLevelFromKeystoneLevel` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetRunHistory` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetSeasonBestAffixScoreInfoForMap` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetSeasonBestForMap` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetSeasonTimesForMap` | Y | Y | Y | - | page |
| `C_MythicPlus.GetWeeklyBestForMap` | Y | Y | Y | Y | page |
| `C_MythicPlus.GetWeeklyChestRewardLevel` | Y | Y | Y | Y | page |
| `C_MythicPlus.IsMythicPlusActive` | Y | Y | Y | Y | page |
| `C_MythicPlus.RequestCurrentAffixes` | Y | Y | Y | Y | page |
| `C_MythicPlus.RequestMapInfo` | Y | Y | Y | Y | page |
| `C_MythicPlus.RequestRewards` | Y | Y | Y | Y | page |

### C_NamePlate

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_NamePlate.GetNamePlateForUnit` | Y | Y | Y | Y | page |
| `C_NamePlate.GetNamePlates` | Y | Y | Y | Y | page |
| `C_NamePlate.GetNamePlateSize` | Y | Y | Y | Y | page |
| `C_NamePlate.SetNamePlateSize` | Y | Y | Y | Y | page |

### C_NamePlateManager

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_NamePlateManager.GetNamePlateHitTestInsets` | Y | Y | Y | Y | page |
| `C_NamePlateManager.IsNamePlateUnitBehindCamera` | Y | Y | Y | Y | page |
| `C_NamePlateManager.SetNamePlateHitTestInsets` | Y | Y | Y | Y | page |
| `C_NamePlateManager.SetNamePlateSimplified` | Y | Y | Y | Y | page |

### C_Navigation

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Navigation.GetDistance` | - | - | - | Y | page |
| `C_Navigation.GetFrame` | - | - | - | Y | page |
| `C_Navigation.GetNearestPartyMemberToken` | - | - | - | Y | page |
| `C_Navigation.GetNextWaypointForMap` | - | - | - | Y | page |
| `C_Navigation.GetTargetState` | - | - | - | Y | page |
| `C_Navigation.HasValidScreenPosition` | - | - | - | Y | page |
| `C_Navigation.WasClampedToScreen` | - | - | - | Y | page |

### C_NeighborhoodInitiative

20 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_NeighborhoodInitiative.AddTrackedInitiativeTask` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.GetActiveNeighborhood` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.GetAvailableHouseXP` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.GetInitiativeActivityLogInfo` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.GetInitiativeTaskChatLink` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.GetInitiativeTaskInfo` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.GetInitiativeTaskRewardScaling` | - | - | - | Y | page |
| `C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.GetRequiredLevel` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.GetTrackedInitiativeTasks` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.IsInitiativeEnabled` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.IsPlayerInNeighborhoodGroup` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.IsViewingActiveNeighborhood` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.PlayerHasInitiativeAccess` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.PlayerMeetsRequiredLevel` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.RemoveTrackedInitiativeTask` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.RequestInitiativeActivityLog` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.SetActiveNeighborhood` | Y | Y | Y | Y | page |
| `C_NeighborhoodInitiative.SetViewingNeighborhood` | Y | Y | Y | Y | page |

### C_NewItems

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_NewItems.ClearAll` | Y | Y | Y | Y | page |
| `C_NewItems.IsNewItem` | Y | Y | Y | Y | page |
| `C_NewItems.RemoveNewItem` | Y | Y | Y | Y | page |

### C_PaperDollInfo

20 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PaperDollInfo.CanAutoEquipCursorItem` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.CancelTemporaryEnchantment` | - | - | - | Y | page |
| `C_PaperDollInfo.CanCursorCanGoInSlot` | - | - | - | Y | page |
| `C_PaperDollInfo.GetArmorEffectiveness` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.GetArmorEffectivenessAgainstTarget` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.GetInspectAzeriteItemEmpoweredChoices` | - | - | - | Y | page |
| `C_PaperDollInfo.GetInspectGuildInfo` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.GetInspectItemLevel` | - | - | - | Y | page |
| `C_PaperDollInfo.GetInspectRatedBGBlitzData` | - | - | - | Y | page |
| `C_PaperDollInfo.GetInspectRatedBGData` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.GetInspectRatedSoloShuffleData` | - | - | - | Y | page |
| `C_PaperDollInfo.GetInventorySlotInfo` | - | - | - | Y | page |
| `C_PaperDollInfo.GetInventorySlotInfoForInvSlot` | - | - | - | Y | page |
| `C_PaperDollInfo.GetMinItemLevel` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.GetStaggerPercentage` | - | - | - | Y | page |
| `C_PaperDollInfo.GetTemporaryEnchantmentInfo` | - | - | - | Y | page |
| `C_PaperDollInfo.IsInventorySlotEnabled` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.IsRangedSlotShown` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.OffhandHasShield` | Y | Y | Y | Y | page |
| `C_PaperDollInfo.OffhandHasWeapon` | Y | Y | Y | Y | page |

### C_PartyInfo

53 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PartyInfo.AllowedToDoPartyConversion` | - | - | - | Y | page |
| `C_PartyInfo.CanFormCrossFactionParties` | - | - | - | Y | page |
| `C_PartyInfo.CanInvite` | - | - | - | Y | page |
| `C_PartyInfo.CanStartInstanceAbandonVote` | - | - | - | Y | page |
| `C_PartyInfo.ChallengeModeRestrictionsActive` | Y | Y | Y | Y | page |
| `C_PartyInfo.ConfirmConvertToRaid` | - | - | - | Y | page |
| `C_PartyInfo.ConfirmInviteTravelPass` | - | - | - | Y | page |
| `C_PartyInfo.ConfirmInviteUnit` | - | - | - | Y | page |
| `C_PartyInfo.ConfirmLeaveParty` | Y | Y | Y | Y | page |
| `C_PartyInfo.ConfirmReadyCheck` | Y | Y | Y | Y | page |
| `C_PartyInfo.ConfirmRequestInviteFromUnit` | - | - | - | Y | page |
| `C_PartyInfo.ConvertToParty` | - | - | - | Y | page |
| `C_PartyInfo.ConvertToRaid` | - | - | - | Y | page |
| `C_PartyInfo.DelveTeleportOut` | - | - | - | Y | page |
| `C_PartyInfo.DemoteAssistant` | Y | Y | Y | Y | page |
| `C_PartyInfo.DoCountdown` | Y | Y | Y | Y | page |
| `C_PartyInfo.DoReadyCheck` | Y | Y | Y | Y | page |
| `C_PartyInfo.GetActiveCategories` | Y | Y | Y | Y | page |
| `C_PartyInfo.GetAvailableLootMethods` | Y | Y | Y | Y | page |
| `C_PartyInfo.GetInstanceAbandonShutdownTime` | - | - | - | Y | page |
| `C_PartyInfo.GetInstanceAbandonVoteCooldownTime` | - | - | - | Y | page |
| `C_PartyInfo.GetInstanceAbandonVoteRequirements` | - | - | - | Y | page |
| `C_PartyInfo.GetInstanceAbandonVoteResponse` | - | - | - | Y | page |
| `C_PartyInfo.GetInstanceAbandonVoteTime` | - | - | - | Y | page |
| `C_PartyInfo.GetInviteConfirmationInvalidQueues` | Y | Y | Y | Y | page |
| `C_PartyInfo.GetInviteReferralInfo` | - | - | - | Y | page |
| `C_PartyInfo.GetLootMethod` | Y | Y | Y | Y | page |
| `C_PartyInfo.GetLootMethodStyle` | Y | Y | Y | Y | page |
| `C_PartyInfo.GetMinItemLevel` | - | - | - | Y | page |
| `C_PartyInfo.GetMinLevel` | Y | Y | Y | Y | page |
| `C_PartyInfo.GetNumInstanceAbandonGroupVoteResponses` | - | - | - | Y | page |
| `C_PartyInfo.GetRestrictPings` | - | - | - | Y | page |
| `C_PartyInfo.InviteUnit` | Y | Y | Y | Y | page |
| `C_PartyInfo.IsChallengeModeActive` | - | - | - | Y | page |
| `C_PartyInfo.IsChallengeModeKeystoneOwner` | - | - | - | Y | page |
| `C_PartyInfo.IsCrossFactionParty` | Y | Y | Y | Y | page |
| `C_PartyInfo.IsDelveComplete` | - | - | - | Y | page |
| `C_PartyInfo.IsDelveInProgress` | - | - | - | Y | page |
| `C_PartyInfo.IsGUIDInGroup` | Y | Y | Y | Y | page |
| `C_PartyInfo.IsLootMethodAvailable` | Y | Y | Y | Y | page |
| `C_PartyInfo.IsPartyFull` | Y | Y | Y | Y | page |
| `C_PartyInfo.IsPartyInJailersTower` | - | - | - | Y | page |
| `C_PartyInfo.IsPartyWalkIn` | Y | Y | Y | Y | page |
| `C_PartyInfo.LeaveParty` | - | - | - | Y | page |
| `C_PartyInfo.PromoteToAssistant` | Y | Y | Y | Y | page |
| `C_PartyInfo.PromoteToLeader` | Y | Y | Y | Y | page |
| `C_PartyInfo.RequestInviteFromUnit` | - | - | - | Y | page |
| `C_PartyInfo.SetEveryoneIsAssistant` | Y | Y | Y | Y | page |
| `C_PartyInfo.SetInstanceAbandonVoteResponse` | - | - | - | Y | page |
| `C_PartyInfo.SetLootMethod` | Y | Y | Y | Y | page |
| `C_PartyInfo.SetRestrictPings` | - | - | - | Y | page |
| `C_PartyInfo.StartInstanceAbandonVote` | - | - | - | Y | page |
| `C_PartyInfo.UninviteUnit` | Y | Y | Y | Y | page |

### C_PartyPose

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PartyPose.ExtraAction` | - | - | - | Y | page |
| `C_PartyPose.GetPartyPoseInfoByID` | - | - | - | Y | page |
| `C_PartyPose.GetPartyPoseInfoByMapID` | - | - | - | Y | page |
| `C_PartyPose.HasExtraAction` | - | - | - | Y | page |

### C_PerksActivities

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PerksActivities.AddTrackedPerksActivity` | - | - | - | Y | page |
| `C_PerksActivities.ClearPerksActivitiesPendingCompletion` | - | - | - | Y | page |
| `C_PerksActivities.GetAllPerksActivityTags` | - | - | - | Y | page |
| `C_PerksActivities.GetPerksActivitiesInfo` | - | - | - | Y | page |
| `C_PerksActivities.GetPerksActivitiesPendingCompletion` | - | - | - | Y | page |
| `C_PerksActivities.GetPerksActivityChatLink` | - | - | - | Y | page |
| `C_PerksActivities.GetPerksActivityInfo` | - | - | - | Y | page |
| `C_PerksActivities.GetPerksUIThemePrefix` | - | - | - | Y | page |
| `C_PerksActivities.GetTrackedPerksActivities` | - | - | - | Y | page |
| `C_PerksActivities.RemoveTrackedPerksActivity` | - | - | - | Y | page |

### C_PerksProgram

24 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PerksProgram.ClearFrozenPerksVendorItem` | - | - | - | Y | page |
| `C_PerksProgram.CloseInteraction` | - | - | - | Y | page |
| `C_PerksProgram.GetAvailableCategoryIDs` | - | - | - | Y | page |
| `C_PerksProgram.GetAvailableVendorItemIDs` | - | - | - | Y | page |
| `C_PerksProgram.GetCategoryInfo` | - | - | - | Y | page |
| `C_PerksProgram.GetCurrencyAmount` | - | - | - | Y | page |
| `C_PerksProgram.GetDraggedPerksVendorItem` | - | - | - | Y | page |
| `C_PerksProgram.GetFrozenPerksVendorItemInfo` | - | - | - | Y | page |
| `C_PerksProgram.GetPendingChestRewards` | - | - | - | Y | page |
| `C_PerksProgram.GetPerksProgramItemDisplayInfo` | - | - | - | Y | page |
| `C_PerksProgram.GetTimeRemaining` | - | - | - | Y | page |
| `C_PerksProgram.GetVendorItemInfo` | - | - | - | Y | page |
| `C_PerksProgram.GetVendorItemInfoRefundTimeLeft` | - | - | - | Y | page |
| `C_PerksProgram.IsAttackAnimToggleEnabled` | - | - | - | Y | page |
| `C_PerksProgram.IsFrozenPerksVendorItem` | - | - | - | Y | page |
| `C_PerksProgram.IsMountSpecialAnimToggleEnabled` | - | - | - | Y | page |
| `C_PerksProgram.ItemSelectedTelemetry` | - | - | - | Y | page |
| `C_PerksProgram.PickupPerksVendorItem` | - | - | - | Y | page |
| `C_PerksProgram.RequestCartCheckout` | - | - | - | Y | page |
| `C_PerksProgram.RequestPendingChestRewards` | - | - | - | Y | page |
| `C_PerksProgram.RequestPurchase` | - | - | - | Y | page |
| `C_PerksProgram.RequestRefund` | - | - | - | Y | page |
| `C_PerksProgram.ResetHeldItemDragAndDrop` | - | - | - | Y | page |
| `C_PerksProgram.SetFrozenPerksVendorItem` | - | - | - | Y | page |

### C_PetBattles

56 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PetBattles.AcceptPVPDuel` | Y | Y | Y | Y | page |
| `C_PetBattles.AcceptQueuedPVPMatch` | Y | Y | Y | Y | page |
| `C_PetBattles.CanAcceptQueuedPVPMatch` | Y | Y | Y | Y | page |
| `C_PetBattles.CanActivePetSwapOut` | Y | Y | Y | Y | page |
| `C_PetBattles.CancelPVPDuel` | Y | Y | Y | Y | page |
| `C_PetBattles.CanPetSwapIn` | Y | Y | Y | Y | page |
| `C_PetBattles.ChangePet` | Y | Y | Y | Y | page |
| `C_PetBattles.DeclineQueuedPVPMatch` | Y | Y | Y | Y | page |
| `C_PetBattles.ForfeitGame` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAbilityEffectInfo` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAbilityInfo` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAbilityInfoByID` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAbilityProcTurnIndex` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAbilityState` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAbilityStateModification` | Y | Y | Y | Y | page |
| `C_PetBattles.GetActivePet` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAllEffectNames` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAllStates` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAttackModifier` | Y | Y | Y | Y | page |
| `C_PetBattles.GetAuraInfo` | Y | Y | Y | Y | page |
| `C_PetBattles.GetBattleState` | Y | Y | Y | Y | page |
| `C_PetBattles.GetBreedQuality` | Y | Y | Y | Y | page |
| `C_PetBattles.GetDisplayID` | Y | Y | Y | Y | page |
| `C_PetBattles.GetForfeitPenalty` | Y | Y | Y | Y | page |
| `C_PetBattles.GetHealth` | Y | Y | Y | Y | page |
| `C_PetBattles.GetIcon` | Y | Y | Y | Y | page |
| `C_PetBattles.GetLevel` | Y | Y | Y | Y | page |
| `C_PetBattles.GetMaxHealth` | Y | Y | Y | Y | page |
| `C_PetBattles.GetName` | Y | Y | Y | Y | page |
| `C_PetBattles.GetNumAuras` | Y | Y | Y | Y | page |
| `C_PetBattles.GetNumPets` | Y | Y | Y | Y | page |
| `C_PetBattles.GetPetSpeciesID` | Y | Y | Y | Y | page |
| `C_PetBattles.GetPetType` | Y | Y | Y | Y | page |
| `C_PetBattles.GetPlayerTrapAbility` | Y | Y | Y | Y | page |
| `C_PetBattles.GetPower` | Y | Y | Y | Y | page |
| `C_PetBattles.GetPVPMatchmakingInfo` | Y | Y | Y | Y | page |
| `C_PetBattles.GetSelectedAction` | Y | Y | Y | Y | page |
| `C_PetBattles.GetSpeed` | Y | Y | Y | Y | page |
| `C_PetBattles.GetStateValue` | Y | Y | Y | Y | page |
| `C_PetBattles.GetTurnTimeInfo` | Y | Y | Y | Y | page |
| `C_PetBattles.GetXP` | Y | Y | Y | Y | page |
| `C_PetBattles.IsInBattle` | Y | Y | Y | Y | page |
| `C_PetBattles.IsPlayerNPC` | Y | Y | Y | Y | page |
| `C_PetBattles.IsSkipAvailable` | Y | Y | Y | Y | page |
| `C_PetBattles.IsTrapAvailable` | Y | Y | Y | Y | page |
| `C_PetBattles.IsWaitingOnOpponent` | Y | Y | Y | Y | page |
| `C_PetBattles.IsWildBattle` | Y | Y | Y | Y | page |
| `C_PetBattles.SetPendingReportBattlePetTarget` | Y | Y | Y | Y | page |
| `C_PetBattles.SetPendingReportTargetFromUnit` | Y | Y | Y | Y | page |
| `C_PetBattles.ShouldShowPetSelect` | Y | Y | Y | Y | page |
| `C_PetBattles.SkipTurn` | Y | Y | Y | Y | page |
| `C_PetBattles.StartPVPDuel` | Y | Y | Y | Y | page |
| `C_PetBattles.StartPVPMatchmaking` | Y | Y | Y | Y | page |
| `C_PetBattles.StopPVPMatchmaking` | Y | Y | Y | Y | page |
| `C_PetBattles.UseAbility` | Y | Y | Y | Y | page |
| `C_PetBattles.UseTrap` | Y | Y | Y | Y | page |

### C_PetInfo

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PetInfo.GetPetTalentTree` | Y | Y | Y | Y | page |
| `C_PetInfo.GetPetTamersForMap` | - | - | - | Y | page |
| `C_PetInfo.GetSpellForPetAction` | - | - | - | Y | page |
| `C_PetInfo.IsPetActionPassive` | - | - | - | Y | page |
| `C_PetInfo.PetAbandon` | - | - | - | Y | page |
| `C_PetInfo.PetAssistMode` | Y | Y | Y | Y | page |
| `C_PetInfo.PetRename` | - | - | - | Y | page |

### C_PetJournal

80 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PetJournal.CagePetByID` | Y | Y | Y | Y | page |
| `C_PetJournal.ClearFanfare` | Y | Y | Y | Y | missing |
| `C_PetJournal.ClearHoveredBattlePet` | Y | Y | Y | Y | page |
| `C_PetJournal.ClearRecentFanfares` | Y | Y | Y | Y | missing |
| `C_PetJournal.ClearSearchFilter` | Y | Y | Y | Y | page |
| `C_PetJournal.DismissSummonedPet` | Y | Y | Y | Y | page |
| `C_PetJournal.FindPetIDByName` | Y | Y | Y | Y | page |
| `C_PetJournal.GetBattlePetLink` | Y | Y | Y | Y | page |
| `C_PetJournal.GetDisplayIDByIndex` | Y | Y | Y | Y | page |
| `C_PetJournal.GetDisplayProbabilityByIndex` | Y | Y | Y | Y | page |
| `C_PetJournal.GetNonBattlePetLinkByIndex` | Y | Y | Y | Y | page |
| `C_PetJournal.GetNumCollectedInfo` | Y | Y | Y | Y | page |
| `C_PetJournal.GetNumDisplays` | Y | Y | Y | Y | page |
| `C_PetJournal.GetNumPets` | Y | Y | Y | Y | page |
| `C_PetJournal.GetNumPetsInJournal` | Y | Y | Y | Y | page |
| `C_PetJournal.GetNumPetsNeedingFanfare` | Y | Y | Y | Y | missing |
| `C_PetJournal.GetNumPetSources` | Y | Y | Y | Y | page |
| `C_PetJournal.GetNumPetTypes` | Y | Y | Y | Y | page |
| `C_PetJournal.GetOwnedBattlePetString` | Y | Y | Y | Y | page |
| `C_PetJournal.GetOwnedPetIDs` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetAbilityInfo` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetAbilityList` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetAbilityListTable` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetCooldownByGUID` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetInfoByIndex` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetInfoByItemID` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetInfoByPetID` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetInfoBySpeciesID` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetInfoTableByPetID` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetInfoTableBySpeciesID` | - | - | - | Y | page |
| `C_PetJournal.GetPetLoadOutInfo` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetModelSceneInfoBySpeciesID` | Y | Y | Y | Y | missing |
| `C_PetJournal.GetPetSortParameter` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetStats` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetSummonInfo` | Y | Y | Y | Y | page |
| `C_PetJournal.GetPetTeamAverageLevel` | Y | Y | Y | Y | page |
| `C_PetJournal.GetSearchFilter` | Y | Y | Y | Y | page |
| `C_PetJournal.GetSummonBattlePetCooldown` | Y | Y | Y | Y | missing |
| `C_PetJournal.GetSummonedPetGUID` | Y | Y | Y | Y | page |
| `C_PetJournal.GetSummonRandomFavoritePetGUID` | Y | Y | Y | Y | missing |
| `C_PetJournal.HasFavoritePets` | Y | Y | Y | Y | page |
| `C_PetJournal.IsCurrentlySummoned` | Y | Y | Y | Y | page |
| `C_PetJournal.IsFilterChecked` | Y | Y | Y | Y | page |
| `C_PetJournal.IsFindBattleEnabled` | Y | Y | Y | Y | page |
| `C_PetJournal.IsJournalReadOnly` | Y | Y | Y | Y | missing |
| `C_PetJournal.IsJournalUnlocked` | Y | Y | Y | Y | missing |
| `C_PetJournal.IsPetSourceChecked` | Y | Y | Y | Y | page |
| `C_PetJournal.IsPetTypeChecked` | Y | Y | Y | Y | page |
| `C_PetJournal.IsUsingDefaultFilters` | Y | Y | Y | Y | page |
| `C_PetJournal.PetCanBeReleased` | Y | Y | Y | Y | page |
| `C_PetJournal.PetIsCapturable` | Y | Y | Y | Y | page |
| `C_PetJournal.PetIsFavorite` | Y | Y | Y | Y | page |
| `C_PetJournal.PetIsHurt` | Y | Y | Y | Y | page |
| `C_PetJournal.PetIsLockedForConvert` | Y | Y | Y | Y | missing |
| `C_PetJournal.PetIsRevoked` | Y | Y | Y | Y | page |
| `C_PetJournal.PetIsSlotted` | Y | Y | Y | Y | page |
| `C_PetJournal.PetIsSummonable` | Y | Y | Y | Y | page |
| `C_PetJournal.PetIsTradable` | Y | Y | Y | Y | page |
| `C_PetJournal.PetIsUsable` | Y | Y | Y | Y | missing |
| `C_PetJournal.PetNeedsFanfare` | Y | Y | Y | Y | missing |
| `C_PetJournal.PetUsesRandomDisplay` | Y | Y | Y | Y | page |
| `C_PetJournal.PickupPet` | Y | Y | Y | Y | page |
| `C_PetJournal.PickupSummonRandomPet` | Y | Y | Y | Y | missing |
| `C_PetJournal.ReleasePetByID` | Y | Y | Y | Y | page |
| `C_PetJournal.SetAbility` | Y | Y | Y | Y | page |
| `C_PetJournal.SetAllPetSourcesChecked` | Y | Y | Y | Y | page |
| `C_PetJournal.SetAllPetTypesChecked` | Y | Y | Y | Y | page |
| `C_PetJournal.SetCustomName` | Y | Y | Y | Y | page |
| `C_PetJournal.SetDefaultFilters` | Y | Y | Y | Y | page |
| `C_PetJournal.SetFavorite` | Y | Y | Y | Y | page |
| `C_PetJournal.SetFilterChecked` | Y | Y | Y | Y | page |
| `C_PetJournal.SetHoveredBattlePet` | Y | Y | Y | Y | page |
| `C_PetJournal.SetPetLoadOutInfo` | Y | Y | Y | Y | page |
| `C_PetJournal.SetPetSortParameter` | Y | Y | Y | Y | page |
| `C_PetJournal.SetPetSourceChecked` | Y | Y | Y | Y | page |
| `C_PetJournal.SetPetTypeFilter` | Y | Y | Y | Y | page |
| `C_PetJournal.SetSearchFilter` | Y | Y | Y | Y | page |
| `C_PetJournal.SpellTargetBattlePet` | Y | Y | Y | Y | page |
| `C_PetJournal.SummonPetByGUID` | Y | Y | Y | Y | page |
| `C_PetJournal.SummonRandomPet` | Y | Y | Y | Y | page |

### C_PhotoSharing

11 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PhotoSharing.BeginAuthorizationFlow` | Y | Y | Y | Y | page |
| `C_PhotoSharing.ClearAuthorization` | Y | Y | Y | Y | page |
| `C_PhotoSharing.CompleteAuthorizationFlow` | Y | Y | Y | Y | page |
| `C_PhotoSharing.GetCropRatio` | Y | Y | Y | Y | page |
| `C_PhotoSharing.GetPhotoSharingAuthURL` | Y | Y | Y | Y | page |
| `C_PhotoSharing.GetStatus` | Y | Y | Y | Y | page |
| `C_PhotoSharing.IsAuthorized` | Y | Y | Y | Y | page |
| `C_PhotoSharing.IsEnabled` | Y | Y | Y | Y | page |
| `C_PhotoSharing.SetScreenshotPreviewTexture` | Y | Y | Y | Y | page |
| `C_PhotoSharing.TakePhoto` | Y | Y | Y | Y | page |
| `C_PhotoSharing.UploadPhotoToService` | Y | Y | Y | Y | page |

### C_Ping

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Ping.GetCooldownInfo` | - | - | - | Y | page |
| `C_Ping.GetDefaultPingOptions` | - | - | - | Y | page |
| `C_Ping.GetTextureKitForType` | - | - | - | Y | page |
| `C_Ping.IsPingSystemEnabled` | Y | Y | Y | Y | page |
| `C_Ping.SendMacroPing` | - | - | - | Y | page |
| `C_Ping.TogglePingListener` | - | - | - | Y | page |

### C_PlayerChoice

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PlayerChoice.GetCurrentPlayerChoiceInfo` | - | - | - | Y | page |
| `C_PlayerChoice.GetNumRerolls` | - | - | - | Y | page |
| `C_PlayerChoice.GetRemainingTime` | - | - | - | Y | page |
| `C_PlayerChoice.IsWaitingForPlayerChoiceResponse` | - | - | - | Y | page |
| `C_PlayerChoice.OnUIClosed` | - | - | - | Y | page |
| `C_PlayerChoice.RequestRerollPlayerChoice` | - | - | - | Y | page |
| `C_PlayerChoice.SendPlayerChoiceResponse` | - | - | - | Y | page |

### C_PlayerInfo

40 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PlayerInfo.CanPlayerEnterChromieTime` | - | - | - | Y | page |
| `C_PlayerInfo.CanPlayerUseAreaLoot` | - | - | - | Y | page |
| `C_PlayerInfo.CanPlayerUseMountEquipment` | - | - | - | Y | page |
| `C_PlayerInfo.CanUseItem` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetAlternateFormInfo` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetClass` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetContentDifficultyCreatureForPlayer` | - | - | - | Y | page |
| `C_PlayerInfo.GetContentDifficultyQuestForPlayer` | - | - | - | Y | page |
| `C_PlayerInfo.GetDisplayID` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetGlidingInfo` | - | - | - | Y | page |
| `C_PlayerInfo.GetInstancesUnlockedAtLevel` | - | - | - | Y | page |
| `C_PlayerInfo.GetName` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetNativeDisplayID` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetPetStableCreatureDisplayInfoID` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetPlayerCharacterData` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetPlayerMythicPlusRatingSummary` | - | - | - | Y | page |
| `C_PlayerInfo.GetRace` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GetSex` | Y | Y | Y | Y | page |
| `C_PlayerInfo.GUIDIsPlayer` | Y | Y | Y | Y | page |
| `C_PlayerInfo.HasAccountInventoryLock` | - | - | - | Y | page |
| `C_PlayerInfo.HasVisibleInvSlot` | Y | Y | Y | Y | page |
| `C_PlayerInfo.IsAccountBankEnabled` | - | - | - | Y | page |
| `C_PlayerInfo.IsCharacterBankEnabled` | - | - | - | Y | page |
| `C_PlayerInfo.IsConnected` | Y | Y | Y | Y | page |
| `C_PlayerInfo.IsDisplayRaceNative` | Y | Y | Y | Y | page |
| `C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer` | - | - | - | Y | page |
| `C_PlayerInfo.IsMirrorImage` | Y | Y | Y | Y | page |
| `C_PlayerInfo.IsPlayerEligibleForNPE` | - | - | - | Y | page |
| `C_PlayerInfo.IsPlayerEligibleForNPEv2` | - | - | - | Y | page |
| `C_PlayerInfo.IsPlayerInChromieTime` | - | - | - | Y | page |
| `C_PlayerInfo.IsPlayerInRPE` | Y | Y | Y | Y | page |
| `C_PlayerInfo.IsPlayerInTimerunningHeroicWorldTier` | - | - | - | Y | page |
| `C_PlayerInfo.IsPlayerNPERestricted` | Y | Y | Y | Y | page |
| `C_PlayerInfo.IsReturningCharacter` | - | - | - | Y | page |
| `C_PlayerInfo.IsSelfFoundActive` | Y | Y | Y | Y | page |
| `C_PlayerInfo.IsTradingPostAvailable` | - | - | - | Y | page |
| `C_PlayerInfo.IsTravelersLogAvailable` | - | - | - | Y | page |
| `C_PlayerInfo.IsTutorialsTabAvailable` | - | - | - | Y | page |
| `C_PlayerInfo.IsXPUserDisabled` | Y | Y | Y | - | page |
| `C_PlayerInfo.UnitIsSameServer` | Y | Y | Y | Y | page |

### C_PlayerInteractionManager

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PlayerInteractionManager.ClearInteraction` | Y | Y | Y | Y | page |
| `C_PlayerInteractionManager.ConfirmationInteraction` | Y | Y | Y | Y | page |
| `C_PlayerInteractionManager.InteractUnit` | Y | Y | Y | Y | page |
| `C_PlayerInteractionManager.IsInteractingWithNpcOfType` | Y | Y | Y | Y | page |
| `C_PlayerInteractionManager.IsReplacingUnit` | Y | Y | Y | Y | page |
| `C_PlayerInteractionManager.IsValidNPCInteraction` | Y | Y | Y | Y | page |
| `C_PlayerInteractionManager.ReopenInteraction` | Y | Y | Y | Y | page |

### C_PlayerMentorship

5 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PlayerMentorship.GetMentorLevelRequirement` | - | - | - | Y | page |
| `C_PlayerMentorship.GetMentorRequirements` | - | - | - | Y | page |
| `C_PlayerMentorship.GetMentorshipStatus` | - | - | - | Y | page |
| `C_PlayerMentorship.IsActivePlayerConsideredNewcomer` | - | - | - | Y | page |
| `C_PlayerMentorship.IsMentorRestricted` | - | - | - | Y | page |

### C_ProductChoice

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ProductChoice.GetChoices` | Y | Y | Y | - | missing |
| `C_ProductChoice.GetNumSuppressed` | Y | Y | Y | - | missing |
| `C_ProductChoice.GetProducts` | Y | Y | Y | - | missing |
| `C_ProductChoice.MakeSelection` | Y | Y | Y | - | missing |

### C_ProfSpecs

27 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ProfSpecs.CanRefundPath` | - | - | - | Y | page |
| `C_ProfSpecs.CanUnlockTab` | - | - | - | Y | page |
| `C_ProfSpecs.GetChildrenForPath` | - | - | - | Y | page |
| `C_ProfSpecs.GetConfigIDForSkillLine` | - | - | - | Y | page |
| `C_ProfSpecs.GetCurrencyInfoForSkillLine` | - | - | - | Y | page |
| `C_ProfSpecs.GetDefaultSpecSkillLine` | - | - | - | Y | page |
| `C_ProfSpecs.GetDescriptionForPath` | - | - | - | Y | page |
| `C_ProfSpecs.GetDescriptionForPerk` | - | - | - | Y | page |
| `C_ProfSpecs.GetEntryIDForPerk` | - | - | - | Y | page |
| `C_ProfSpecs.GetNewSpecReminderProfName` | - | - | - | Y | page |
| `C_ProfSpecs.GetPerksForPath` | - | - | - | Y | page |
| `C_ProfSpecs.GetRootPathForTab` | - | - | - | Y | page |
| `C_ProfSpecs.GetSourceTextForPath` | - | - | - | Y | page |
| `C_ProfSpecs.GetSpecTabIDsForSkillLine` | - | - | - | Y | page |
| `C_ProfSpecs.GetSpecTabInfo` | - | - | - | Y | page |
| `C_ProfSpecs.GetSpendCurrencyForPath` | - | - | - | Y | page |
| `C_ProfSpecs.GetSpendEntryForPath` | - | - | - | Y | page |
| `C_ProfSpecs.GetStateForPath` | - | - | - | Y | page |
| `C_ProfSpecs.GetStateForPerk` | - | - | - | Y | page |
| `C_ProfSpecs.GetStateForTab` | - | - | - | Y | page |
| `C_ProfSpecs.GetTabInfo` | - | - | - | Y | page |
| `C_ProfSpecs.GetUnlockEntryForPath` | - | - | - | Y | page |
| `C_ProfSpecs.GetUnlockRankForPerk` | - | - | - | Y | page |
| `C_ProfSpecs.ShouldShowPointsReminder` | - | - | - | Y | page |
| `C_ProfSpecs.ShouldShowPointsReminderForSkillLine` | - | - | - | Y | page |
| `C_ProfSpecs.ShouldShowSpecTab` | - | - | - | Y | page |
| `C_ProfSpecs.SkillLineHasSpecialization` | - | - | - | Y | page |

### C_PrototypeDialog

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PrototypeDialog.EnsureRemoved` | - | - | - | Y | page |
| `C_PrototypeDialog.SelectOption` | - | - | - | Y | page |

### C_PvP

121 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_PvP.ArePvpTalentsUnlocked` | - | - | - | Y | page |
| `C_PvP.AreTrainingGroundsEnabled` | - | - | - | Y | page |
| `C_PvP.CanDisplayDeaths` | - | - | - | Y | page |
| `C_PvP.CanDisplayHonorableKills` | - | - | - | Y | page |
| `C_PvP.CanPlayerUseRatedPVPUI` | - | - | - | Y | page |
| `C_PvP.CanPlayerUseTrainingGroundsUI` | - | - | - | Y | page |
| `C_PvP.CanSurrenderArena` | Y | Y | - | Y | page |
| `C_PvP.CanToggleWarMode` | - | - | - | Y | page |
| `C_PvP.CanToggleWarModeInArea` | - | - | - | Y | page |
| `C_PvP.ClearLocklistMap` | Y | Y | Y | - | page |
| `C_PvP.DoesMatchOutcomeAffectRating` | - | - | - | Y | page |
| `C_PvP.GetActiveBrawlInfo` | - | - | - | Y | page |
| `C_PvP.GetActiveMatchBracket` | - | - | - | Y | page |
| `C_PvP.GetActiveMatchDuration` | - | - | - | Y | page |
| `C_PvP.GetActiveMatchState` | - | - | - | Y | page |
| `C_PvP.GetActiveMatchWinner` | - | - | - | Y | page |
| `C_PvP.GetArenaCrowdControlDuration` | Y | Y | Y | Y | page |
| `C_PvP.GetArenaCrowdControlInfo` | Y | Y | Y | Y | page |
| `C_PvP.GetArenaRewards` | Y | Y | Y | Y | page |
| `C_PvP.GetArenaSkirmishRewards` | - | - | - | Y | page |
| `C_PvP.GetAssignedSpecForBattlefieldQueue` | - | - | - | Y | page |
| `C_PvP.GetAvailableBrawlInfo` | - | - | - | Y | page |
| `C_PvP.GetBattlefieldFlagPosition` | - | - | - | Y | page |
| `C_PvP.GetBattlefieldVehicleInfo` | Y | Y | Y | Y | page |
| `C_PvP.GetBattlefieldVehicles` | Y | Y | Y | Y | page |
| `C_PvP.GetBattlegroundInfo` | - | - | - | Y | page |
| `C_PvP.GetBrawlRewards` | - | - | - | Y | page |
| `C_PvP.GetBrawlSoloRBGMinItemLevel` | - | - | - | Y | page |
| `C_PvP.GetCustomVictoryStatID` | - | - | - | Y | page |
| `C_PvP.GetGlobalPvpScalingInfoForSpecID` | - | - | - | Y | page |
| `C_PvP.GetHolidayBGInfo` | Y | Y | Y | - | page |
| `C_PvP.GetHolidayBGLossRewards` | Y | Y | Y | - | page |
| `C_PvP.GetHolidayBGRewards` | Y | Y | Y | - | page |
| `C_PvP.GetHonorRewardInfo` | - | - | - | Y | page |
| `C_PvP.GetLevelUpBattlegrounds` | - | - | - | Y | page |
| `C_PvP.GetLocklistMap` | Y | Y | Y | - | page |
| `C_PvP.GetLocklistMapName` | Y | Y | Y | - | page |
| `C_PvP.GetMatchPVPStatColumn` | - | - | - | Y | page |
| `C_PvP.GetMatchPVPStatColumns` | - | - | - | Y | page |
| `C_PvP.GetNextHonorLevelForReward` | - | - | - | Y | page |
| `C_PvP.GetOutdoorPvPWaitTime` | Y | Y | Y | Y | page |
| `C_PvP.GetPersonalRatedBGBlitzSpecStats` | - | - | - | Y | page |
| `C_PvP.GetPersonalRatedSoloShuffleSpecStats` | - | - | - | Y | page |
| `C_PvP.GetPostMatchCurrencyRewards` | - | - | - | Y | page |
| `C_PvP.GetPostMatchItemRewards` | - | - | - | Y | page |
| `C_PvP.GetPVPActiveMatchPersonalRatedInfo` | - | - | - | Y | page |
| `C_PvP.GetPVPActiveRatedMatchDeserterPenalty` | - | - | - | Y | page |
| `C_PvP.GetPVPSeasonRewardAchievementID` | - | - | - | Y | page |
| `C_PvP.GetPvpTalentsUnlockedLevel` | - | - | - | Y | page |
| `C_PvP.GetPvpTierID` | - | - | - | Y | page |
| `C_PvP.GetPvpTierInfo` | - | - | - | Y | page |
| `C_PvP.GetRandomBGInfo` | Y | Y | Y | Y | page |
| `C_PvP.GetRandomBGLossRewards` | Y | Y | Y | - | page |
| `C_PvP.GetRandomBGRewards` | Y | Y | Y | Y | page |
| `C_PvP.GetRandomEpicBGInfo` | - | - | - | Y | page |
| `C_PvP.GetRandomEpicBGRewards` | - | - | - | Y | page |
| `C_PvP.GetRandomTrainingGroundRewards` | - | - | - | Y | page |
| `C_PvP.GetRatedBGRewards` | Y | Y | Y | Y | page |
| `C_PvP.GetRatedSoloRBGMinItemLevel` | - | - | - | Y | page |
| `C_PvP.GetRatedSoloRBGRewards` | - | - | - | Y | page |
| `C_PvP.GetRatedSoloShuffleMinItemLevel` | - | - | - | Y | page |
| `C_PvP.GetRatedSoloShuffleRewards` | - | - | - | Y | page |
| `C_PvP.GetRewardItemLevelsByTierEnum` | - | - | - | Y | page |
| `C_PvP.GetScoreInfo` | - | - | - | Y | page |
| `C_PvP.GetScoreInfoByPlayerGuid` | - | - | - | Y | page |
| `C_PvP.GetSeasonBestInfo` | - | - | - | Y | page |
| `C_PvP.GetSelectedBattlefieldIndex` | Y | Y | Y | - | missing |
| `C_PvP.GetSkirmishInfo` | - | - | - | Y | page |
| `C_PvP.GetSpecialEventBrawlInfo` | - | - | - | Y | page |
| `C_PvP.GetTeamInfo` | - | - | - | Y | page |
| `C_PvP.GetTrainingGrounds` | - | - | - | Y | page |
| `C_PvP.GetUIDisplaySeason` | - | - | - | Y | page |
| `C_PvP.GetWarModeRewardBonus` | - | - | - | Y | page |
| `C_PvP.GetWarModeRewardBonusDefault` | - | - | - | Y | page |
| `C_PvP.GetWeeklyChestInfo` | - | - | - | Y | page |
| `C_PvP.GetWorldPVPAreaInfo` | Y | Y | Y | - | page |
| `C_PvP.GetWorldPvPWaitTime` | Y | Y | Y | - | page |
| `C_PvP.GetZonePVPInfo` | Y | Y | Y | Y | page |
| `C_PvP.HasArenaSkirmishWinToday` | - | - | - | Y | page |
| `C_PvP.HasMatchStarted` | - | - | - | Y | page |
| `C_PvP.HasRandomTrainingGroundWinToday` | - | - | - | Y | page |
| `C_PvP.IsActiveBattlefield` | - | - | - | Y | page |
| `C_PvP.IsActiveMatchRegistered` | - | - | - | Y | page |
| `C_PvP.IsArena` | - | - | - | Y | page |
| `C_PvP.IsBattleground` | - | - | - | Y | page |
| `C_PvP.IsBattlegroundEnlistmentBonusActive` | - | - | - | Y | page |
| `C_PvP.IsBrawlSoloRBG` | Y | Y | Y | Y | page |
| `C_PvP.IsBrawlSoloShuffle` | Y | Y | Y | Y | page |
| `C_PvP.IsInBrawl` | Y | Y | Y | Y | page |
| `C_PvP.IsInRatedMatchWithDeserterPenalty` | - | - | - | Y | page |
| `C_PvP.IsMatchActive` | - | - | - | Y | page |
| `C_PvP.IsMatchComplete` | - | - | - | Y | page |
| `C_PvP.IsMatchConsideredArena` | - | - | - | Y | page |
| `C_PvP.IsMatchFactional` | - | - | - | Y | page |
| `C_PvP.IsPVPMap` | Y | Y | Y | Y | page |
| `C_PvP.IsRatedArena` | - | - | - | Y | page |
| `C_PvP.IsRatedBattleground` | - | - | - | Y | page |
| `C_PvP.IsRatedMap` | Y | Y | Y | Y | page |
| `C_PvP.IsRatedSoloRBG` | Y | Y | Y | Y | page |
| `C_PvP.IsRatedSoloShuffle` | Y | Y | Y | Y | page |
| `C_PvP.IsSoloRBG` | Y | Y | Y | Y | page |
| `C_PvP.IsSoloShuffle` | Y | Y | Y | Y | page |
| `C_PvP.IsSubZonePVPPOI` | Y | Y | Y | Y | page |
| `C_PvP.IsWarModeActive` | - | - | - | Y | page |
| `C_PvP.IsWarModeDesired` | Y | Y | Y | Y | page |
| `C_PvP.IsWarModeFeatureEnabled` | - | - | - | Y | page |
| `C_PvP.JoinBattlefield` | Y | Y | Y | Y | page |
| `C_PvP.JoinBrawl` | - | - | - | Y | page |
| `C_PvP.JoinRandomTrainingGroundArena` | - | - | - | Y | page |
| `C_PvP.JoinRandomTrainingGroundBattleground` | - | - | - | Y | page |
| `C_PvP.JoinRatedBGBlitz` | - | - | - | Y | page |
| `C_PvP.JoinTrainingGround` | - | - | - | Y | page |
| `C_PvP.RequestCrowdControlSpell` | Y | Y | Y | Y | page |
| `C_PvP.SetLocklistMap` | Y | Y | Y | - | page |
| `C_PvP.SetPVP` | Y | Y | Y | Y | page |
| `C_PvP.SetSelectedBattlefieldByIndex` | Y | Y | Y | - | missing |
| `C_PvP.SetWarModeDesired` | - | - | - | Y | page |
| `C_PvP.StartSoloRBGWarGameByName` | - | - | - | Y | page |
| `C_PvP.StartSpectatorSoloRBGWarGame` | - | - | - | Y | page |
| `C_PvP.TogglePVP` | Y | Y | Y | Y | page |
| `C_PvP.ToggleWarMode` | - | - | - | Y | page |

### C_QuestChoice

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_QuestChoice.CloseQuestChoice` | Y | Y | Y | - | page |
| `C_QuestChoice.GetQuestChoiceInfo` | Y | Y | Y | - | page |
| `C_QuestChoice.GetQuestChoiceOptionInfo` | Y | Y | Y | - | page |
| `C_QuestChoice.GetQuestChoiceRewardCurrency` | Y | Y | Y | - | page |
| `C_QuestChoice.GetQuestChoiceRewardFaction` | Y | Y | Y | - | page |
| `C_QuestChoice.GetQuestChoiceRewardInfo` | Y | Y | Y | - | page |
| `C_QuestChoice.GetQuestChoiceRewardItem` | Y | Y | Y | - | page |
| `C_QuestChoice.SendQuestChoiceResponse` | Y | Y | Y | - | page |

### C_QuestHub

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_QuestHub.IsAreaPOICurrentlyRelatedToHub` | - | - | - | Y | page |
| `C_QuestHub.IsQuestCurrentlyRelatedToHub` | - | - | - | Y | page |

### C_QuestInfoSystem

9 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_QuestInfoSystem.GetQuestClassification` | - | - | - | Y | page |
| `C_QuestInfoSystem.GetQuestHasShortExpirationWarning` | Y | Y | - | Y | page |
| `C_QuestInfoSystem.GetQuestLogRewardFavor` | - | - | - | Y | page |
| `C_QuestInfoSystem.GetQuestRewardCurrencies` | - | - | - | Y | page |
| `C_QuestInfoSystem.GetQuestRewardSpellInfo` | Y | Y | Y | Y | page |
| `C_QuestInfoSystem.GetQuestRewardSpells` | Y | Y | Y | Y | page |
| `C_QuestInfoSystem.GetQuestShouldToastCompletion` | Y | Y | Y | Y | page |
| `C_QuestInfoSystem.HasQuestRewardCurrencies` | Y | Y | Y | Y | page |
| `C_QuestInfoSystem.HasQuestRewardSpells` | Y | Y | Y | Y | page |

### C_QuestItemUse

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_QuestItemUse.CanUseQuestItemOnObject` | - | - | - | Y | page |

### C_QuestLine

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_QuestLine.GetAvailableQuestLines` | - | - | - | Y | page |
| `C_QuestLine.GetForceVisibleQuests` | - | - | - | Y | page |
| `C_QuestLine.GetQuestLineInfo` | - | - | - | Y | page |
| `C_QuestLine.GetQuestLineQuests` | - | - | - | Y | page |
| `C_QuestLine.IsComplete` | - | - | - | Y | page |
| `C_QuestLine.QuestLineIgnoresAccountCompletedFiltering` | - | - | - | Y | page |
| `C_QuestLine.RequestQuestLinesForMap` | - | - | - | Y | page |

### C_QuestLog

91 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_QuestLog.AbandonQuest` | - | - | - | Y | page |
| `C_QuestLog.AddQuestWatch` | - | - | - | Y | page |
| `C_QuestLog.AddWorldQuestWatch` | - | - | - | Y | page |
| `C_QuestLog.CanAbandonQuest` | - | - | - | Y | page |
| `C_QuestLog.DoesQuestAwardReputationWithFaction` | - | - | - | Y | page |
| `C_QuestLog.GetAbandonQuest` | - | - | - | Y | page |
| `C_QuestLog.GetAbandonQuestItems` | - | - | - | Y | page |
| `C_QuestLog.GetActivePreyQuest` | - | - | - | Y | page |
| `C_QuestLog.GetActiveThreatMaps` | - | - | - | Y | page |
| `C_QuestLog.GetAllCompletedQuestIDs` | - | - | - | Y | page |
| `C_QuestLog.GetBountiesForMapID` | - | - | - | Y | page |
| `C_QuestLog.GetBountySetInfoForMapID` | - | - | - | Y | page |
| `C_QuestLog.GetDistanceSqToQuest` | - | - | - | Y | page |
| `C_QuestLog.GetHeaderIndexForQuest` | - | - | - | Y | page |
| `C_QuestLog.GetInfo` | - | - | - | Y | page |
| `C_QuestLog.GetLogIndexForQuestID` | - | - | - | Y | page |
| `C_QuestLog.GetMapForQuestPOIs` | Y | Y | Y | Y | page |
| `C_QuestLog.GetMaxNumQuests` | Y | Y | Y | Y | page |
| `C_QuestLog.GetMaxNumQuestsCanAccept` | Y | Y | Y | Y | page |
| `C_QuestLog.GetNextWaypoint` | - | - | - | Y | page |
| `C_QuestLog.GetNextWaypointForMap` | - | - | - | Y | page |
| `C_QuestLog.GetNextWaypointText` | - | - | - | Y | page |
| `C_QuestLog.GetNumQuestLogEntries` | - | - | - | Y | page |
| `C_QuestLog.GetNumQuestObjectives` | - | - | - | Y | page |
| `C_QuestLog.GetNumQuestWatches` | - | - | - | Y | page |
| `C_QuestLog.GetNumWorldQuestWatches` | - | - | - | Y | page |
| `C_QuestLog.GetQuestAdditionalHighlights` | - | - | - | Y | page |
| `C_QuestLog.GetQuestDetailsTheme` | - | - | - | Y | page |
| `C_QuestLog.GetQuestDifficultyLevel` | - | - | - | Y | page |
| `C_QuestLog.GetQuestIDForLogIndex` | - | - | - | Y | page |
| `C_QuestLog.GetQuestIDForQuestWatchIndex` | - | - | - | Y | page |
| `C_QuestLog.GetQuestIDForWorldQuestWatchIndex` | - | - | - | Y | page |
| `C_QuestLog.GetQuestInfo` | Y | Y | Y | - | page |
| `C_QuestLog.GetQuestLogMajorFactionReputationRewards` | - | - | - | Y | page |
| `C_QuestLog.GetQuestLogPortraitGiver` | - | - | - | Y | page |
| `C_QuestLog.GetQuestObjectives` | Y | Y | Y | Y | page |
| `C_QuestLog.GetQuestRewardCurrencies` | - | - | - | Y | page |
| `C_QuestLog.GetQuestRewardCurrencyInfo` | - | - | - | Y | page |
| `C_QuestLog.GetQuestsOnMap` | Y | Y | Y | Y | page |
| `C_QuestLog.GetQuestTagInfo` | - | - | - | Y | page |
| `C_QuestLog.GetQuestType` | - | - | - | Y | page |
| `C_QuestLog.GetQuestWatchType` | - | - | - | Y | page |
| `C_QuestLog.GetRequiredMoney` | - | - | - | Y | page |
| `C_QuestLog.GetSelectedQuest` | - | - | - | Y | page |
| `C_QuestLog.GetSuggestedGroupSize` | - | - | - | Y | page |
| `C_QuestLog.GetTimeAllowed` | - | - | - | Y | page |
| `C_QuestLog.GetTitleForLogIndex` | - | - | - | Y | page |
| `C_QuestLog.GetTitleForQuestID` | - | - | - | Y | page |
| `C_QuestLog.GetZoneStoryInfo` | - | - | - | Y | page |
| `C_QuestLog.HasActiveThreats` | - | - | - | Y | page |
| `C_QuestLog.IsAccountQuest` | - | - | - | Y | page |
| `C_QuestLog.IsComplete` | - | - | - | Y | page |
| `C_QuestLog.IsFailed` | - | - | - | Y | page |
| `C_QuestLog.IsImportantQuest` | - | - | - | Y | page |
| `C_QuestLog.IsMetaQuest` | - | - | - | Y | page |
| `C_QuestLog.IsOnMap` | - | - | - | Y | page |
| `C_QuestLog.IsOnQuest` | Y | Y | Y | Y | page |
| `C_QuestLog.IsPushableQuest` | - | - | - | Y | page |
| `C_QuestLog.IsQuestBounty` | - | - | - | Y | page |
| `C_QuestLog.IsQuestCalling` | - | - | - | Y | page |
| `C_QuestLog.IsQuestCriteriaForBounty` | - | - | - | Y | page |
| `C_QuestLog.IsQuestDisabledForSession` | - | - | - | Y | page |
| `C_QuestLog.IsQuestFlaggedCompleted` | Y | Y | Y | Y | page |
| `C_QuestLog.IsQuestFlaggedCompletedOnAccount` | - | - | - | Y | page |
| `C_QuestLog.IsQuestFromContentPush` | Y | Y | Y | Y | page |
| `C_QuestLog.IsQuestInvasion` | - | - | - | Y | page |
| `C_QuestLog.IsQuestReplayable` | - | - | - | Y | page |
| `C_QuestLog.IsQuestReplayedRecently` | - | - | - | Y | page |
| `C_QuestLog.IsQuestTask` | - | - | - | Y | page |
| `C_QuestLog.IsQuestTrivial` | - | - | - | Y | page |
| `C_QuestLog.IsRepeatableQuest` | - | - | - | Y | page |
| `C_QuestLog.IsThreatQuest` | - | - | - | Y | page |
| `C_QuestLog.IsUnitOnQuest` | - | - | - | Y | page |
| `C_QuestLog.IsWorldQuest` | - | - | - | Y | page |
| `C_QuestLog.QuestCanHaveWarModeBonus` | - | - | - | Y | page |
| `C_QuestLog.QuestContainsFirstTimeRepBonusForPlayer` | - | - | - | Y | page |
| `C_QuestLog.QuestHasQuestSessionBonus` | - | - | - | Y | page |
| `C_QuestLog.QuestHasWarModeBonus` | - | - | - | Y | page |
| `C_QuestLog.QuestIgnoresAccountCompletedFiltering` | - | - | - | Y | page |
| `C_QuestLog.ReadyForTurnIn` | - | - | - | Y | page |
| `C_QuestLog.RemoveQuestWatch` | - | - | - | Y | page |
| `C_QuestLog.RemoveWorldQuestWatch` | - | - | - | Y | page |
| `C_QuestLog.RequestLoadQuestByID` | - | - | - | Y | page |
| `C_QuestLog.SetAbandonQuest` | - | - | - | Y | page |
| `C_QuestLog.SetMapForQuestPOIs` | Y | Y | Y | Y | page |
| `C_QuestLog.SetSelectedQuest` | - | - | - | Y | page |
| `C_QuestLog.ShouldDisplayTimeRemaining` | - | - | - | Y | page |
| `C_QuestLog.ShouldShowQuestRewards` | Y | Y | Y | Y | page |
| `C_QuestLog.SortQuestWatches` | - | - | - | Y | page |
| `C_QuestLog.UnitIsRelatedToActiveQuest` | - | - | - | Y | page |
| `C_QuestLog.UpdateCampaignHeaders` | - | - | - | Y | page |

### C_QuestOffer

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_QuestOffer.GetHideRequiredItems` | - | - | - | Y | page |
| `C_QuestOffer.GetQuestOfferMajorFactionReputationRewards` | - | - | - | Y | page |
| `C_QuestOffer.GetQuestRequiredCurrencyInfo` | - | - | - | Y | page |
| `C_QuestOffer.GetQuestRewardCurrencyInfo` | - | - | - | Y | page |

### C_QuestSession

14 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_QuestSession.CanStart` | Y | Y | Y | Y | page |
| `C_QuestSession.CanStop` | Y | Y | Y | Y | page |
| `C_QuestSession.Exists` | Y | Y | Y | Y | page |
| `C_QuestSession.GetAvailableSessionCommand` | Y | Y | Y | Y | page |
| `C_QuestSession.GetPendingCommand` | Y | Y | Y | Y | page |
| `C_QuestSession.GetProposedMaxLevelForSession` | Y | Y | Y | Y | page |
| `C_QuestSession.GetSessionBeginDetails` | Y | Y | Y | Y | page |
| `C_QuestSession.GetSuperTrackedQuest` | Y | Y | Y | Y | page |
| `C_QuestSession.HasJoined` | Y | Y | Y | Y | page |
| `C_QuestSession.HasPendingCommand` | Y | Y | Y | Y | page |
| `C_QuestSession.RequestSessionStart` | Y | Y | Y | Y | page |
| `C_QuestSession.RequestSessionStop` | Y | Y | Y | Y | page |
| `C_QuestSession.SendSessionBeginResponse` | Y | Y | Y | Y | page |
| `C_QuestSession.SetQuestIsSuperTracked` | Y | Y | Y | Y | page |

### C_RaidLocks

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_RaidLocks.GetRedirectedDifficultyID` | Y | Y | Y | Y | page |
| `C_RaidLocks.IsEncounterComplete` | Y | Y | Y | Y | page |
| `C_RaidLocks.IsRaidLockExtendFeatureEnabled` | Y | Y | Y | Y | page |

### C_RecentAllies

14 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_RecentAllies.CanSetRecentAllyNote` | Y | Y | Y | Y | page |
| `C_RecentAllies.GetRecentAllies` | Y | Y | Y | Y | page |
| `C_RecentAllies.GetRecentAllyByFullName` | Y | Y | Y | Y | page |
| `C_RecentAllies.GetRecentAllyByGUID` | Y | Y | Y | Y | page |
| `C_RecentAllies.IsRecentAllyByFullName` | Y | Y | Y | Y | page |
| `C_RecentAllies.IsRecentAllyByGUID` | Y | Y | Y | Y | page |
| `C_RecentAllies.IsRecentAllyDataReady` | Y | Y | Y | Y | page |
| `C_RecentAllies.IsRecentAllyPinned` | Y | Y | Y | Y | page |
| `C_RecentAllies.IsSystemEnabled` | Y | Y | Y | Y | page |
| `C_RecentAllies.IsSystemSupported` | Y | Y | Y | Y | page |
| `C_RecentAllies.SearchRecentAllies` | - | - | - | Y | page |
| `C_RecentAllies.SetRecentAllyNote` | Y | Y | Y | Y | page |
| `C_RecentAllies.SetRecentAllyPinned` | Y | Y | Y | Y | page |
| `C_RecentAllies.TryRequestRecentAlliesData` | Y | Y | Y | Y | page |

### C_RecruitAFriend

17 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_RecruitAFriend.CanSummonFriend` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.ClaimActivityReward` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.ClaimNextReward` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.GenerateRecruitmentLink` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.GetRAFInfo` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.GetRAFSystemInfo` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.GetRecruitActivityRequirementsText` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.GetRecruitInfo` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.GetSummonFriendCooldown` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.IsEnabled` | Y | Y | Y | - | page |
| `C_RecruitAFriend.IsRecruitAFriendLinked` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.IsRecruitingEnabled` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.IsSystemEnabled` | - | - | - | Y | page |
| `C_RecruitAFriend.IsSystemSupported` | - | - | - | Y | page |
| `C_RecruitAFriend.RemoveRAFRecruit` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.RequestUpdatedRecruitmentInfo` | Y | Y | Y | Y | page |
| `C_RecruitAFriend.SummonFriend` | Y | Y | Y | Y | page |

### C_Reforge

9 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Reforge.CloseReforge` | Y | Y | Y | - | page |
| `C_Reforge.GetDestinationReforgeStats` | Y | Y | Y | - | page |
| `C_Reforge.GetNumReforgeOptions` | Y | Y | Y | - | page |
| `C_Reforge.GetReforgeItemInfo` | Y | Y | Y | - | page |
| `C_Reforge.GetReforgeItemStats` | Y | Y | Y | - | page |
| `C_Reforge.GetReforgeOptionInfo` | Y | Y | Y | - | page |
| `C_Reforge.GetSourceReforgeStats` | Y | Y | Y | - | page |
| `C_Reforge.ReforgeItem` | Y | Y | Y | - | page |
| `C_Reforge.SetReforgeFromCursorItem` | Y | Y | Y | - | page |

### C_Reincarnation

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Reincarnation.GetReincarnatingCharacter` | Y | Y | Y | Y | missing |
| `C_Reincarnation.IsReincarnating` | Y | Y | Y | Y | missing |
| `C_Reincarnation.StartReincarnation` | Y | Y | Y | Y | missing |
| `C_Reincarnation.StopReincarnation` | Y | Y | Y | Y | missing |

### C_RemixArtifactUI

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_RemixArtifactUI.ClearRemixArtifactItem` | - | - | - | Y | page |
| `C_RemixArtifactUI.GetAppearanceInfoByID` | - | - | - | Y | page |
| `C_RemixArtifactUI.GetArtifactArtInfo` | - | - | - | Y | page |
| `C_RemixArtifactUI.GetArtifactItemInfo` | - | - | - | Y | page |
| `C_RemixArtifactUI.GetCurrArtifactItemID` | - | - | - | Y | page |
| `C_RemixArtifactUI.GetCurrItemSpecIndex` | - | - | - | Y | page |
| `C_RemixArtifactUI.GetCurrTraitTreeID` | - | - | - | Y | page |
| `C_RemixArtifactUI.ItemInSlotIsRemixArtifact` | - | - | - | Y | page |

### C_ReportSystem

12 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ReportSystem.CanReportPlayer` | Y | Y | Y | Y | page |
| `C_ReportSystem.CanReportPlayerForLanguage` | Y | Y | Y | Y | page |
| `C_ReportSystem.GetMajorCategoriesForReportType` | Y | Y | Y | Y | page |
| `C_ReportSystem.GetMajorCategoryString` | Y | Y | Y | Y | page |
| `C_ReportSystem.GetMinorCategoriesForReportTypeAndMajorCategory` | Y | Y | Y | Y | page |
| `C_ReportSystem.GetMinorCategoryString` | Y | Y | Y | Y | page |
| `C_ReportSystem.ReportServerLag` | Y | Y | Y | Y | page |
| `C_ReportSystem.ReportStuckInCombat` | Y | Y | Y | Y | page |
| `C_ReportSystem.RequiresScreenshotForReportType` | Y | Y | Y | Y | page |
| `C_ReportSystem.SendReport` | Y | Y | Y | Y | page |
| `C_ReportSystem.SetScreenshotPreviewTexture` | Y | Y | Y | Y | page |
| `C_ReportSystem.TakeReportScreenshot` | Y | Y | Y | Y | page |

### C_Reputation

27 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Reputation.AreLegacyReputationsShown` | - | - | - | Y | page |
| `C_Reputation.CollapseAllFactionHeaders` | - | - | - | Y | page |
| `C_Reputation.CollapseFactionHeader` | - | - | - | Y | page |
| `C_Reputation.ExpandAllFactionHeaders` | - | - | - | Y | page |
| `C_Reputation.ExpandFactionHeader` | - | - | - | Y | page |
| `C_Reputation.GetFactionDataByID` | - | - | - | Y | page |
| `C_Reputation.GetFactionDataByIndex` | - | - | - | Y | page |
| `C_Reputation.GetFactionParagonInfo` | Y | Y | Y | Y | page |
| `C_Reputation.GetGuildFactionData` | Y | Y | Y | Y | page |
| `C_Reputation.GetGuildRepExpirationTime` | - | - | - | Y | page |
| `C_Reputation.GetNumFactions` | - | - | - | Y | page |
| `C_Reputation.GetReputationSortType` | - | - | - | Y | page |
| `C_Reputation.GetSelectedFaction` | - | - | - | Y | page |
| `C_Reputation.GetWatchedFactionData` | Y | Y | Y | Y | page |
| `C_Reputation.IsAccountWideReputation` | Y | Y | Y | Y | page |
| `C_Reputation.IsFactionActive` | - | - | - | Y | page |
| `C_Reputation.IsFactionParagon` | Y | Y | Y | Y | page |
| `C_Reputation.IsFactionParagonForCurrentPlayer` | Y | Y | Y | Y | page |
| `C_Reputation.IsMajorFaction` | Y | Y | Y | Y | page |
| `C_Reputation.RequestFactionParagonPreloadRewardData` | Y | Y | Y | Y | page |
| `C_Reputation.SetFactionActive` | - | - | - | Y | page |
| `C_Reputation.SetLegacyReputationsShown` | - | - | - | Y | page |
| `C_Reputation.SetReputationSortType` | - | - | - | Y | page |
| `C_Reputation.SetSelectedFaction` | - | - | - | Y | page |
| `C_Reputation.SetWatchedFactionByID` | - | - | - | Y | page |
| `C_Reputation.SetWatchedFactionByIndex` | - | - | - | Y | page |
| `C_Reputation.ToggleFactionAtWar` | - | - | - | Y | page |

### C_ResearchInfo

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ResearchInfo.GetDigSitesForMap` | Y | Y | Y | Y | page |

### C_RestrictedActions

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_RestrictedActions.CheckAllowProtectedFunctions` | Y | Y | Y | Y | page |
| `C_RestrictedActions.GetAddOnRestrictionState` | Y | Y | Y | Y | page |
| `C_RestrictedActions.IsAddOnRestrictionActive` | Y | Y | Y | Y | page |

### C_Roleset

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Roleset.ApplyRolesetFilters` | - | - | - | Y | page |
| `C_Roleset.GetActiveAllowedRolesets` | - | - | - | Y | page |
| `C_Roleset.GetActiveBlockedRolesets` | - | - | - | Y | page |

### C_Scenario

9 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Scenario.GetBonusStepRewardQuestID` | Y | Y | Y | Y | missing |
| `C_Scenario.GetBonusSteps` | Y | Y | Y | Y | missing |
| `C_Scenario.GetInfo` | Y | Y | Y | Y | missing |
| `C_Scenario.GetProvingGroundsInfo` | Y | Y | Y | Y | page |
| `C_Scenario.GetStepInfo` | Y | Y | Y | Y | missing |
| `C_Scenario.GetSupersededObjectives` | Y | Y | Y | Y | missing |
| `C_Scenario.IsInScenario` | Y | Y | Y | Y | missing |
| `C_Scenario.ShouldShowCriteria` | Y | Y | Y | Y | missing |
| `C_Scenario.TreatScenarioAsDungeon` | Y | Y | Y | Y | missing |

### C_ScenarioInfo

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ScenarioInfo.GetCriteriaInfo` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.GetCriteriaInfoByStep` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.GetDisplayInfo` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.GetJailersTowerTypeString` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.GetScenarioIconInfo` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.GetScenarioInfo` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.GetScenarioStepInfo` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.GetTieredEntranceActiveSpells` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.GetUnitCriteriaProgressValues` | Y | Y | Y | Y | page |
| `C_ScenarioInfo.IsTieredEntranceScenario` | Y | Y | Y | Y | page |

### C_ScrappingMachineUI

11 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ScrappingMachineUI.CloseScrappingMachine` | - | - | - | Y | page |
| `C_ScrappingMachineUI.DropPendingScrapItemFromCursor` | - | - | - | Y | page |
| `C_ScrappingMachineUI.GetCurrentPendingScrapItemLocationByIndex` | - | - | - | Y | page |
| `C_ScrappingMachineUI.GetScrappingMachineName` | - | - | - | Y | page |
| `C_ScrappingMachineUI.GetScrapSpellID` | - | - | - | Y | page |
| `C_ScrappingMachineUI.HasScrappableItems` | - | - | - | Y | page |
| `C_ScrappingMachineUI.RemoveAllScrapItems` | - | - | - | Y | page |
| `C_ScrappingMachineUI.RemoveCurrentScrappingItem` | - | - | - | Y | page |
| `C_ScrappingMachineUI.RemoveItemToScrap` | - | - | - | Y | page |
| `C_ScrappingMachineUI.ScrapItems` | - | - | - | Y | page |
| `C_ScrappingMachineUI.ValidateScrappingList` | - | - | - | Y | page |

### C_ScriptedAnimations

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ScriptedAnimations.GetAllScriptedAnimationEffects` | Y | Y | Y | Y | page |

### C_SeasonInfo

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SeasonInfo.GetCurrentDisplaySeasonExpansion` | - | - | - | Y | page |
| `C_SeasonInfo.GetCurrentDisplaySeasonID` | - | - | - | Y | page |

### C_Seasons

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Seasons.GetActiveSeason` | Y | Y | Y | - | page |
| `C_Seasons.HasActiveSeason` | Y | Y | Y | - | page |

### C_Secrets

27 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Secrets.CanCompareUnitTokens` | Y | Y | Y | Y | page |
| `C_Secrets.GetPowerTypeSecrecy` | Y | Y | Y | Y | page |
| `C_Secrets.GetSpellAuraSecrecy` | Y | Y | Y | Y | page |
| `C_Secrets.GetSpellCastSecrecy` | Y | Y | Y | Y | page |
| `C_Secrets.GetSpellCooldownSecrecy` | Y | Y | Y | Y | page |
| `C_Secrets.HasSecretRestrictions` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldActionCooldownBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldAurasBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldCooldownsBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldSpellAuraBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldSpellBookItemCooldownBeSecret` | - | - | - | Y | page |
| `C_Secrets.ShouldSpellCooldownBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldTotemSlotBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldTotemSpellBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitAuraIndexBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitAuraInstanceBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitAuraSlotBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitComparisonBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitHealthMaxBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitIdentityBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitPowerBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitPowerMaxBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitSpellCastBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitSpellCastingBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitStatsBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitThreatStateBeSecret` | Y | Y | Y | Y | page |
| `C_Secrets.ShouldUnitThreatValuesBeSecret` | Y | Y | Y | Y | page |

### C_SettingsUtil

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SettingsUtil.NotifySettingsLoaded` | Y | Y | Y | Y | page |
| `C_SettingsUtil.OpenSettingsPanel` | Y | Y | Y | Y | page |

### C_SharedCharacterServices

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SharedCharacterServices.GetLastSeenCharacterUpgradePopup` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.GetLastSeenExpansionTrialPopup` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.GetUpgradeDistributions` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.HasFreePromotionalUpgrade` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.HasSeenFreePromotionalUpgradePopup` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.IsPurchaseIDPendingUpgrade` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.QueryClassTrialBoostResult` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.SetCharacterUpgradePopupSeen` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.SetExpansionTrialPopupSeen` | Y | Y | Y | Y | missing |
| `C_SharedCharacterServices.SetPromotionalPopupSeen` | Y | Y | Y | Y | missing |

### C_SocialQueue

10 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SocialQueue.GetAllGroups` | - | - | - | Y | page |
| `C_SocialQueue.GetConfig` | - | - | - | Y | page |
| `C_SocialQueue.GetGroupForPlayer` | - | - | - | Y | page |
| `C_SocialQueue.GetGroupInfo` | - | - | - | Y | page |
| `C_SocialQueue.GetGroupMembers` | - | - | - | Y | page |
| `C_SocialQueue.GetGroupQueues` | - | - | - | Y | page |
| `C_SocialQueue.IsSystemEnabled` | - | - | - | Y | page |
| `C_SocialQueue.IsSystemSupported` | - | - | - | Y | page |
| `C_SocialQueue.RequestToJoin` | - | - | - | Y | page |
| `C_SocialQueue.SignalToastDisplayed` | - | - | - | Y | page |

### C_SocialRestrictions

9 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SocialRestrictions.AcknowledgeRegionalChatDisabled` | Y | Y | Y | Y | page |
| `C_SocialRestrictions.CanReceiveChat` | Y | Y | Y | Y | page |
| `C_SocialRestrictions.CanSendChat` | Y | Y | Y | Y | page |
| `C_SocialRestrictions.IsChatDisabled` | Y | Y | Y | Y | page |
| `C_SocialRestrictions.IsFriendsDisabled` | - | - | - | Y | page |
| `C_SocialRestrictions.IsMuted` | Y | Y | Y | Y | page |
| `C_SocialRestrictions.IsSilenced` | Y | Y | Y | Y | page |
| `C_SocialRestrictions.IsSquelched` | Y | Y | Y | Y | page |
| `C_SocialRestrictions.SetChatDisabled` | Y | Y | Y | Y | page |

### C_SocialUI

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SocialUI.IsSystemEnabled` | - | - | - | Y | page |

### C_Soulbinds

39 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Soulbinds.ActivateSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.CanActivateSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.CanModifySoulbind` | - | - | - | Y | page |
| `C_Soulbinds.CanResetConduitsInSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.CanSwitchActiveSoulbindTreeBranch` | - | - | - | Y | page |
| `C_Soulbinds.CloseUI` | - | - | - | Y | page |
| `C_Soulbinds.CommitPendingConduitsInSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.FindNodeIDActuallyInstalled` | - | - | - | Y | page |
| `C_Soulbinds.FindNodeIDAppearingInstalled` | - | - | - | Y | page |
| `C_Soulbinds.FindNodeIDPendingInstall` | - | - | - | Y | page |
| `C_Soulbinds.FindNodeIDPendingUninstall` | - | - | - | Y | page |
| `C_Soulbinds.GetActiveSoulbindID` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitCollection` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitCollectionCount` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitCollectionData` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitCollectionDataAtCursor` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitCollectionDataByVirtualID` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitDisplayed` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitHyperlink` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitIDPendingInstall` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitQuality` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitRank` | - | - | - | Y | page |
| `C_Soulbinds.GetConduitSpellID` | - | - | - | Y | page |
| `C_Soulbinds.GetInstalledConduitID` | - | - | - | Y | page |
| `C_Soulbinds.GetNode` | - | - | - | Y | page |
| `C_Soulbinds.GetSoulbindData` | - | - | - | Y | page |
| `C_Soulbinds.GetSpecsAssignedToSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.GetTree` | - | - | - | Y | page |
| `C_Soulbinds.HasAnyInstalledConduitInSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.HasAnyPendingConduits` | - | - | - | Y | page |
| `C_Soulbinds.HasPendingConduitsInSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.IsConduitInstalled` | - | - | - | Y | page |
| `C_Soulbinds.IsConduitInstalledInSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.IsItemConduitByItemInfo` | - | - | - | Y | page |
| `C_Soulbinds.IsNodePendingModify` | - | - | - | Y | page |
| `C_Soulbinds.IsUnselectedConduitPendingInSoulbind` | - | - | - | Y | page |
| `C_Soulbinds.ModifyNode` | - | - | - | Y | page |
| `C_Soulbinds.SelectNode` | - | - | - | Y | page |
| `C_Soulbinds.UnmodifyNode` | - | - | - | Y | page |

### C_Sound

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Sound.GetSoundScaledVolume` | Y | Y | Y | Y | page |
| `C_Sound.IsPlaying` | Y | Y | Y | Y | page |
| `C_Sound.PlayItemSound` | Y | Y | Y | Y | page |
| `C_Sound.PlaySound` | Y | Y | Y | Y | page |
| `C_Sound.PlaySoundWithOptions` | - | - | - | Y | page |
| `C_Sound.PlayVocalErrorSound` | Y | Y | Y | Y | page |

### C_SpecializationInfo

27 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SpecializationInfo.CanPlayerUsePVPTalentUI` | - | - | - | Y | page |
| `C_SpecializationInfo.CanPlayerUseTalentSpecUI` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.CanPlayerUseTalentUI` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.GetActiveSpecGroup` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.GetAllSelectedPvpTalentIDs` | - | - | - | Y | page |
| `C_SpecializationInfo.GetClassIDFromSpecID` | - | - | - | Y | page |
| `C_SpecializationInfo.GetInspectSelectedPvpTalent` | - | - | - | Y | page |
| `C_SpecializationInfo.GetInspectSpecialization` | - | - | - | Y | page |
| `C_SpecializationInfo.GetNumSpecializationsForClassID` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.GetPvpTalentAlertStatus` | - | - | - | Y | page |
| `C_SpecializationInfo.GetPvpTalentInfo` | - | - | - | Y | page |
| `C_SpecializationInfo.GetPvpTalentSlotInfo` | - | - | - | Y | page |
| `C_SpecializationInfo.GetPvpTalentSlotUnlockLevel` | - | - | - | Y | page |
| `C_SpecializationInfo.GetPvpTalentUnlockLevel` | - | - | - | Y | page |
| `C_SpecializationInfo.GetSpecialization` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.GetSpecializationInfo` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.GetSpecializationMasterySpells` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.GetSpecIDs` | - | - | - | Y | page |
| `C_SpecializationInfo.GetSpellsDisplay` | - | - | - | Y | page |
| `C_SpecializationInfo.GetTalentInfo` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.IsInitialized` | Y | Y | Y | Y | page |
| `C_SpecializationInfo.IsPvpTalentLocked` | - | - | - | Y | page |
| `C_SpecializationInfo.MatchesCurrentSpecSet` | - | - | - | Y | page |
| `C_SpecializationInfo.SetActiveSpecGroup` | Y | Y | Y | - | page |
| `C_SpecializationInfo.SetPetSpecialization` | - | - | - | Y | page |
| `C_SpecializationInfo.SetPvpTalentLocked` | - | - | - | Y | page |
| `C_SpecializationInfo.SetSpecialization` | - | - | - | Y | page |

### C_SpectatingUI

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SpectatingUI.GetSpectateTargetInfo` | Y | Y | Y | Y | missing |
| `C_SpectatingUI.GetSpectatingPlayerSpellItemQuality` | Y | Y | Y | Y | missing |
| `C_SpectatingUI.IsSpectating` | Y | Y | Y | Y | missing |
| `C_SpectatingUI.LeaveSpectateMode` | Y | Y | Y | Y | missing |
| `C_SpectatingUI.SpectateChange` | Y | Y | Y | Y | missing |
| `C_SpectatingUI.StartSpectating` | Y | Y | Y | Y | missing |

### C_Spell

65 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Spell.CancelSpellByID` | Y | Y | Y | Y | page |
| `C_Spell.DoesSpellExist` | Y | Y | Y | Y | page |
| `C_Spell.EnableSpellRangeCheck` | Y | Y | Y | Y | page |
| `C_Spell.GetAuraStatChanges` | - | - | - | Y | page |
| `C_Spell.GetBaseSpell` | - | - | - | Y | page |
| `C_Spell.GetDeadlyDebuffInfo` | - | - | - | Y | page |
| `C_Spell.GetItemModifiedAppearancesApplied` | - | - | - | Y | page |
| `C_Spell.GetLastCategoryCooldownSource` | - | - | - | Y | page |
| `C_Spell.GetMawPowerLinkBySpellID` | - | - | - | Y | page |
| `C_Spell.GetMawPowerRarityInfoBySpellID` | - | - | - | Y | page |
| `C_Spell.GetOverrideSpell` | - | - | - | Y | page |
| `C_Spell.GetSchoolString` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellAutoCast` | - | - | - | Y | page |
| `C_Spell.GetSpellCastCount` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellChargeDuration` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellCharges` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellCooldown` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellCooldownDuration` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellDescription` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellDescriptionForItemLocation` | - | - | - | Y | page |
| `C_Spell.GetSpellDisplayCount` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellIDForSpellIdentifier` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellInfo` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellLevelLearned` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellLink` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellLossOfControlCooldownDuration` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellLossOfControlCooldownInfo` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellMaxCumulativeAuraApplications` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellName` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellPowerCost` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellQueueWindow` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellSkillLineAbilityRank` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellSubtext` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellTexture` | Y | Y | Y | Y | page |
| `C_Spell.GetSpellTradeSkillLink` | - | - | - | Y | page |
| `C_Spell.GetVisibilityInfo` | Y | Y | Y | Y | page |
| `C_Spell.IsAutoAttackSpell` | Y | Y | Y | Y | page |
| `C_Spell.IsAutoRepeatSpell` | Y | Y | Y | Y | page |
| `C_Spell.IsClassTalentSpell` | - | - | - | Y | page |
| `C_Spell.IsConsumableSpell` | Y | Y | Y | Y | page |
| `C_Spell.IsCurrentSpell` | Y | Y | Y | Y | page |
| `C_Spell.IsExternalDefensive` | Y | Y | Y | Y | page |
| `C_Spell.IsPressHoldReleaseSpell` | Y | Y | Y | Y | page |
| `C_Spell.IsPriorityAura` | Y | Y | Y | Y | page |
| `C_Spell.IsPvPTalentSpell` | - | - | - | Y | page |
| `C_Spell.IsRangedAutoAttackSpell` | Y | Y | Y | Y | page |
| `C_Spell.IsSelfBuff` | Y | Y | Y | Y | page |
| `C_Spell.IsSpellCrowdControl` | Y | Y | Y | Y | page |
| `C_Spell.IsSpellDataCached` | Y | Y | Y | Y | page |
| `C_Spell.IsSpellDisabled` | - | - | - | Y | page |
| `C_Spell.IsSpellHarmful` | Y | Y | Y | Y | page |
| `C_Spell.IsSpellHelpful` | Y | Y | Y | Y | page |
| `C_Spell.IsSpellImportant` | Y | Y | Y | Y | page |
| `C_Spell.IsSpellInRange` | Y | Y | Y | Y | page |
| `C_Spell.IsSpellPassive` | Y | Y | Y | Y | page |
| `C_Spell.IsSpellUsable` | Y | Y | Y | Y | page |
| `C_Spell.PickupSpell` | Y | Y | Y | Y | page |
| `C_Spell.RequestLoadSpellData` | Y | Y | Y | Y | page |
| `C_Spell.SetSpellAutoCastEnabled` | - | - | - | Y | page |
| `C_Spell.SpellHasRange` | Y | Y | Y | Y | page |
| `C_Spell.TargetSpellChecksItemCondition` | - | - | - | Y | page |
| `C_Spell.TargetSpellIsEnchanting` | Y | Y | Y | Y | page |
| `C_Spell.TargetSpellJumpsUpgradeTrack` | Y | Y | Y | Y | page |
| `C_Spell.TargetSpellReplacesBonusTree` | Y | Y | Y | Y | page |
| `C_Spell.ToggleSpellAutoCast` | - | - | - | Y | page |

### C_SpellActivationOverlay

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SpellActivationOverlay.IsSpellOverlayed` | Y | Y | Y | Y | page |

### C_SpellBook

46 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SpellBook.CastSpellBookItem` | - | - | - | Y | page |
| `C_SpellBook.ContainsAnyDisenchantSpell` | - | - | - | Y | page |
| `C_SpellBook.FindBaseSpellByID` | Y | Y | Y | Y | page |
| `C_SpellBook.FindFlyoutSlotBySpellID` | Y | Y | Y | Y | page |
| `C_SpellBook.FindSpellBookSlotForSpell` | - | - | - | Y | page |
| `C_SpellBook.FindSpellOverrideByID` | Y | Y | Y | Y | page |
| `C_SpellBook.GetCurrentLevelSpells` | - | - | - | Y | page |
| `C_SpellBook.GetNumSpellBookSkillLines` | - | - | - | Y | page |
| `C_SpellBook.GetSkillLineIndexByID` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemAutoCast` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemCastCount` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemChargeDuration` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemCharges` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemCooldown` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemCooldownDuration` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemDescription` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemInfo` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemLevelLearned` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemLink` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemLossOfControlCooldownDuration` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemLossOfControlCooldownInfo` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemName` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemPowerCost` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemSkillLineIndex` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemTexture` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemTradeSkillLink` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookItemType` | - | - | - | Y | page |
| `C_SpellBook.GetSpellBookSkillLineInfo` | - | - | - | Y | page |
| `C_SpellBook.HasPetSpells` | Y | Y | Y | Y | page |
| `C_SpellBook.IsAutoAttackSpellBookItem` | - | - | - | Y | page |
| `C_SpellBook.IsClassTalentSpellBookItem` | - | - | - | Y | page |
| `C_SpellBook.IsPvPTalentSpellBookItem` | - | - | - | Y | page |
| `C_SpellBook.IsRangedAutoAttackSpellBookItem` | - | - | - | Y | page |
| `C_SpellBook.IsSpellBookItemHarmful` | - | - | - | Y | page |
| `C_SpellBook.IsSpellBookItemHelpful` | - | - | - | Y | page |
| `C_SpellBook.IsSpellBookItemInRange` | - | - | - | Y | page |
| `C_SpellBook.IsSpellBookItemOffSpec` | - | - | - | Y | page |
| `C_SpellBook.IsSpellBookItemPassive` | - | - | - | Y | page |
| `C_SpellBook.IsSpellBookItemUsable` | - | - | - | Y | page |
| `C_SpellBook.IsSpellInSpellBook` | Y | Y | Y | Y | page |
| `C_SpellBook.IsSpellKnown` | Y | Y | Y | Y | page |
| `C_SpellBook.IsSpellKnownOrInSpellBook` | Y | Y | Y | Y | page |
| `C_SpellBook.PickupSpellBookItem` | - | - | - | Y | page |
| `C_SpellBook.SetSpellBookItemAutoCastEnabled` | - | - | - | Y | page |
| `C_SpellBook.SpellBookItemHasRange` | - | - | - | Y | page |
| `C_SpellBook.ToggleSpellBookItemAutoCast` | - | - | - | Y | page |

### C_SpellDiminish

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SpellDiminish.GetAllSpellDiminishCategories` | Y | Y | Y | Y | page |
| `C_SpellDiminish.GetSpellDiminishCategoryInfo` | Y | Y | Y | Y | page |
| `C_SpellDiminish.IsSystemSupported` | Y | Y | Y | Y | page |
| `C_SpellDiminish.ShouldTrackSpellDiminishCategory` | Y | Y | Y | Y | page |

### C_SplashScreen

5 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SplashScreen.AcknowledgeSplash` | - | - | - | Y | page |
| `C_SplashScreen.CanViewSplashScreen` | - | - | - | Y | page |
| `C_SplashScreen.RequestLatestSplashScreen` | - | - | - | Y | page |
| `C_SplashScreen.SendSplashScreenActionLaunchedTelem` | - | - | - | Y | page |
| `C_SplashScreen.SendSplashScreenCloseTelem` | - | - | - | Y | page |

### C_StableInfo

14 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_StableInfo.ClosePetStables` | - | - | - | Y | page |
| `C_StableInfo.GetActivePetList` | - | - | - | Y | page |
| `C_StableInfo.GetAvailablePetSpecInfos` | - | - | - | Y | page |
| `C_StableInfo.GetNumActivePets` | Y | Y | Y | Y | page |
| `C_StableInfo.GetNumStablePets` | Y | Y | Y | Y | page |
| `C_StableInfo.GetStabledPetList` | - | - | - | Y | page |
| `C_StableInfo.GetStablePetFoodTypes` | - | - | - | Y | page |
| `C_StableInfo.GetStablePetInfo` | - | - | - | Y | page |
| `C_StableInfo.IsAtStableMaster` | - | - | - | Y | page |
| `C_StableInfo.IsBonusPetSlotAvailable` | - | - | - | Y | page |
| `C_StableInfo.IsPetFavorite` | - | - | - | Y | page |
| `C_StableInfo.PickupStablePet` | - | - | - | Y | page |
| `C_StableInfo.SetPetFavorite` | - | - | - | Y | page |
| `C_StableInfo.SetPetSlot` | - | - | - | Y | page |

### C_StorePublic

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_StorePublic.DoesGroupHavePurchaseableProducts` | Y | Y | Y | Y | page |
| `C_StorePublic.EventStoreUISetShown` | Y | Y | Y | Y | page |
| `C_StorePublic.HasPurchaseableProducts` | Y | Y | Y | - | page |
| `C_StorePublic.IsEnabled` | Y | Y | Y | Y | page |

### C_StringUtil

15 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_StringUtil.CreateAbbreviatedNumberFormatter` | Y | Y | Y | Y | page |
| `C_StringUtil.CreateNumericRuleFormatter` | Y | Y | Y | Y | page |
| `C_StringUtil.CreateSecondsFormatter` | Y | Y | Y | Y | page |
| `C_StringUtil.EscapeDecimalNonPrintables` | Y | Y | Y | Y | page |
| `C_StringUtil.EscapeLuaFormatString` | Y | Y | Y | Y | page |
| `C_StringUtil.EscapeLuaPatterns` | Y | Y | Y | Y | page |
| `C_StringUtil.EscapeQuotedCodes` | Y | Y | Y | Y | page |
| `C_StringUtil.FloorToNearestString` | Y | Y | Y | Y | page |
| `C_StringUtil.GetDefaultAbbreviationBreakpoints` | Y | Y | Y | Y | page |
| `C_StringUtil.RemoveContiguousSpaces` | Y | Y | Y | Y | page |
| `C_StringUtil.RoundToNearestString` | Y | Y | Y | Y | page |
| `C_StringUtil.StripHyperlinks` | Y | Y | Y | Y | page |
| `C_StringUtil.StripTextureMarkupForLooseFiles` | Y | Y | Y | Y | page |
| `C_StringUtil.TruncateWhenZero` | Y | Y | Y | Y | page |
| `C_StringUtil.WrapString` | Y | Y | Y | Y | page |

### C_SummonInfo

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SummonInfo.CancelSummon` | Y | Y | Y | Y | page |
| `C_SummonInfo.ConfirmSummon` | Y | Y | Y | Y | page |
| `C_SummonInfo.GetSummonConfirmAreaName` | Y | Y | Y | Y | page |
| `C_SummonInfo.GetSummonConfirmSummoner` | Y | Y | Y | Y | page |
| `C_SummonInfo.GetSummonConfirmTimeLeft` | Y | Y | Y | Y | page |
| `C_SummonInfo.GetSummonReason` | Y | Y | Y | Y | page |
| `C_SummonInfo.IsSummonSkippingStartExperience` | Y | Y | Y | Y | page |

### C_SuperTrack

20 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SuperTrack.ClearAllSuperTracked` | - | - | - | Y | page |
| `C_SuperTrack.ClearSuperTrackedContent` | - | - | - | Y | page |
| `C_SuperTrack.ClearSuperTrackedMapPin` | - | - | - | Y | page |
| `C_SuperTrack.GetHighestPrioritySuperTrackingType` | - | - | - | Y | page |
| `C_SuperTrack.GetSuperTrackedContent` | - | - | - | Y | page |
| `C_SuperTrack.GetSuperTrackedItemName` | - | - | - | Y | page |
| `C_SuperTrack.GetSuperTrackedMapPin` | - | - | - | Y | page |
| `C_SuperTrack.GetSuperTrackedQuestID` | - | - | - | Y | page |
| `C_SuperTrack.GetSuperTrackedVignette` | - | - | - | Y | page |
| `C_SuperTrack.IsSuperTrackingAnything` | - | - | - | Y | page |
| `C_SuperTrack.IsSuperTrackingContent` | - | - | - | Y | page |
| `C_SuperTrack.IsSuperTrackingCorpse` | - | - | - | Y | page |
| `C_SuperTrack.IsSuperTrackingMapPin` | - | - | - | Y | page |
| `C_SuperTrack.IsSuperTrackingQuest` | - | - | - | Y | page |
| `C_SuperTrack.IsSuperTrackingUserWaypoint` | - | - | - | Y | page |
| `C_SuperTrack.SetSuperTrackedContent` | - | - | - | Y | page |
| `C_SuperTrack.SetSuperTrackedMapPin` | - | - | - | Y | page |
| `C_SuperTrack.SetSuperTrackedQuestID` | - | - | - | Y | page |
| `C_SuperTrack.SetSuperTrackedUserWaypoint` | - | - | - | Y | page |
| `C_SuperTrack.SetSuperTrackedVignette` | - | - | - | Y | page |

### C_System

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_System.GetFrameStack` | Y | Y | Y | Y | page |

### C_SystemVisibilityManager

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_SystemVisibilityManager.IsSystemVisible` | Y | Y | Y | Y | page |

### C_TableUtil

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TableUtil.FindIndexedMismatch` | Y | Y | Y | Y | page |

### C_TalkingHead

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TalkingHead.GetConversationsDeferred` | - | - | - | Y | missing |
| `C_TalkingHead.GetCurrentLineAnimationInfo` | - | - | - | Y | missing |
| `C_TalkingHead.GetCurrentLineInfo` | - | - | - | Y | missing |
| `C_TalkingHead.IgnoreCurrentTalkingHead` | - | - | - | Y | missing |
| `C_TalkingHead.IsCurrentTalkingHeadIgnored` | - | - | - | Y | missing |
| `C_TalkingHead.SetConversationsDeferred` | - | - | - | Y | missing |

### C_TaskQuest

12 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TaskQuest.DoesMapShowTaskQuestObjectives` | Y | Y | Y | Y | page |
| `C_TaskQuest.GetQuestInfoByQuestID` | Y | Y | Y | Y | page |
| `C_TaskQuest.GetQuestLocation` | Y | Y | Y | Y | page |
| `C_TaskQuest.GetQuestProgressBarInfo` | Y | Y | Y | Y | page |
| `C_TaskQuest.GetQuestsOnMap` | Y | Y | Y | Y | page |
| `C_TaskQuest.GetQuestTimeLeftMinutes` | Y | Y | Y | Y | page |
| `C_TaskQuest.GetQuestTimeLeftSeconds` | Y | Y | Y | Y | page |
| `C_TaskQuest.GetQuestUIWidgetSetByType` | - | - | - | Y | page |
| `C_TaskQuest.GetQuestZoneID` | Y | Y | Y | Y | page |
| `C_TaskQuest.GetThreatQuests` | Y | Y | Y | Y | page |
| `C_TaskQuest.IsActive` | Y | Y | Y | Y | page |
| `C_TaskQuest.RequestPreloadRewardData` | Y | Y | Y | Y | page |

### C_TaxiMap

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TaxiMap.GetAllTaxiNodes` | Y | Y | Y | Y | page |
| `C_TaxiMap.GetTaxiNodesForMap` | Y | Y | Y | Y | page |
| `C_TaxiMap.ShouldMapShowTaxiNodes` | - | - | - | Y | page |

### C_Texture

11 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Texture.ClearTitleIconTexture` | Y | Y | Y | Y | page |
| `C_Texture.GetAtlasElementID` | Y | Y | Y | Y | page |
| `C_Texture.GetAtlasElements` | Y | Y | Y | Y | page |
| `C_Texture.GetAtlasExists` | Y | Y | Y | Y | page |
| `C_Texture.GetAtlasID` | Y | Y | Y | Y | page |
| `C_Texture.GetAtlasInfo` | Y | Y | Y | Y | page |
| `C_Texture.GetFilenameFromFileDataID` | Y | Y | Y | Y | page |
| `C_Texture.GetTitleIconTexture` | Y | Y | Y | Y | page |
| `C_Texture.IsTitleIconTextureReady` | Y | Y | Y | Y | page |
| `C_Texture.SetTitleIconTexture` | Y | Y | Y | Y | page |
| `C_Texture.SetURLTexture` | Y | Y | Y | Y | page |

### C_Timer

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Timer.After` | Y | Y | Y | Y | page |
| `C_Timer.NewTicker` | Y | Y | Y | Y | page |
| `C_Timer.NewTimer` | Y | Y | Y | Y | page |

### C_TimerunningUI

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TimerunningUI.GetActiveTimerunningSeasonID` | - | - | - | Y | page |

### C_TooltipComparison

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TooltipComparison.CompareItem` | - | - | - | Y | page |
| `C_TooltipComparison.GetItemComparisonDelta` | - | - | - | Y | page |
| `C_TooltipComparison.GetItemComparisonInfo` | - | - | - | Y | page |

### C_TooltipInfo

82 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TooltipInfo.GetAchievementByID` | - | - | - | Y | page |
| `C_TooltipInfo.GetAction` | - | - | - | Y | page |
| `C_TooltipInfo.GetArtifactItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetArtifactPowerByID` | - | - | - | Y | page |
| `C_TooltipInfo.GetAzeriteEssence` | - | - | - | Y | page |
| `C_TooltipInfo.GetAzeriteEssenceSlot` | - | - | - | Y | page |
| `C_TooltipInfo.GetAzeritePower` | - | - | - | Y | page |
| `C_TooltipInfo.GetBackpackToken` | - | - | - | Y | page |
| `C_TooltipInfo.GetBagItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetBagItemChild` | - | - | - | Y | page |
| `C_TooltipInfo.GetBuybackItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetCompanionPet` | - | - | - | Y | page |
| `C_TooltipInfo.GetConduit` | - | - | - | Y | page |
| `C_TooltipInfo.GetCurrencyByID` | - | - | - | Y | page |
| `C_TooltipInfo.GetCurrencyToken` | - | - | - | Y | page |
| `C_TooltipInfo.GetEnhancedConduit` | - | - | - | Y | page |
| `C_TooltipInfo.GetEquipmentSet` | - | - | - | Y | page |
| `C_TooltipInfo.GetExistingSocketGem` | - | - | - | Y | page |
| `C_TooltipInfo.GetGuildBankItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetHeirloomByItemID` | - | - | - | Y | page |
| `C_TooltipInfo.GetHyperlink` | - | - | - | Y | page |
| `C_TooltipInfo.GetInboxItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetInstanceLockEncountersComplete` | - | - | - | Y | page |
| `C_TooltipInfo.GetInventoryItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetInventoryItemByID` | - | - | - | Y | page |
| `C_TooltipInfo.GetItemByGUID` | - | - | - | Y | page |
| `C_TooltipInfo.GetItemByID` | - | - | - | Y | page |
| `C_TooltipInfo.GetItemByItemModifiedAppearanceID` | - | - | - | Y | page |
| `C_TooltipInfo.GetItemInteractionItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetItemKey` | - | - | - | Y | page |
| `C_TooltipInfo.GetLFGDungeonReward` | - | - | - | Y | page |
| `C_TooltipInfo.GetLFGDungeonShortageReward` | - | - | - | Y | page |
| `C_TooltipInfo.GetLootCurrency` | - | - | - | Y | page |
| `C_TooltipInfo.GetLootItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetLootRollItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetMerchantCostItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetMerchantItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetMinimapMouseover` | - | - | - | Y | page |
| `C_TooltipInfo.GetMountBySpellID` | - | - | - | Y | page |
| `C_TooltipInfo.GetOutfit` | - | - | - | Y | page |
| `C_TooltipInfo.GetOwnedItemByID` | - | - | - | Y | page |
| `C_TooltipInfo.GetPetAction` | - | - | - | Y | page |
| `C_TooltipInfo.GetPossession` | - | - | - | Y | page |
| `C_TooltipInfo.GetPvpBrawl` | - | - | - | Y | page |
| `C_TooltipInfo.GetPvpTalent` | - | - | - | Y | page |
| `C_TooltipInfo.GetQuestCurrency` | - | - | - | Y | page |
| `C_TooltipInfo.GetQuestItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetQuestLogCurrency` | - | - | - | Y | page |
| `C_TooltipInfo.GetQuestLogItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetQuestLogSpecialItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetQuestPartyProgress` | - | - | - | Y | page |
| `C_TooltipInfo.GetRecipeRankInfo` | - | - | - | Y | page |
| `C_TooltipInfo.GetRecipeReagentItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetRecipeResultItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetRecipeResultItemForOrder` | - | - | - | Y | page |
| `C_TooltipInfo.GetRuneforgeResultItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetSendMailItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetShapeshift` | - | - | - | Y | page |
| `C_TooltipInfo.GetSlottedKeystone` | - | - | - | Y | page |
| `C_TooltipInfo.GetSocketedItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetSocketedRelic` | - | - | - | Y | page |
| `C_TooltipInfo.GetSocketGem` | - | - | - | Y | page |
| `C_TooltipInfo.GetSpellBookItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetSpellByID` | - | - | - | Y | page |
| `C_TooltipInfo.GetTalent` | - | - | - | Y | page |
| `C_TooltipInfo.GetTotem` | - | - | - | Y | page |
| `C_TooltipInfo.GetToyByItemID` | - | - | - | Y | page |
| `C_TooltipInfo.GetTradePlayerItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetTradeTargetItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetTrainerService` | - | - | - | Y | page |
| `C_TooltipInfo.GetTraitEntry` | - | - | - | Y | page |
| `C_TooltipInfo.GetUnit` | - | - | - | Y | page |
| `C_TooltipInfo.GetUnitAura` | - | - | - | Y | page |
| `C_TooltipInfo.GetUnitAuraByAuraInstanceID` | - | - | - | Y | page |
| `C_TooltipInfo.GetUnitBuff` | - | - | - | Y | page |
| `C_TooltipInfo.GetUnitBuffByAuraInstanceID` | - | - | - | Y | page |
| `C_TooltipInfo.GetUnitDebuff` | - | - | - | Y | page |
| `C_TooltipInfo.GetUnitDebuffByAuraInstanceID` | - | - | - | Y | page |
| `C_TooltipInfo.GetUpgradeItem` | - | - | - | Y | page |
| `C_TooltipInfo.GetWeeklyReward` | - | - | - | Y | page |
| `C_TooltipInfo.GetWorldCursor` | - | - | - | Y | page |
| `C_TooltipInfo.GetWorldLootObject` | - | - | - | Y | page |

### C_ToyBox

26 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ToyBox.ForceToyRefilter` | Y | Y | Y | Y | missing |
| `C_ToyBox.GetCollectedShown` | Y | Y | Y | Y | missing |
| `C_ToyBox.GetIsFavorite` | Y | Y | Y | Y | missing |
| `C_ToyBox.GetNumFilteredToys` | Y | Y | Y | Y | missing |
| `C_ToyBox.GetNumLearnedDisplayedToys` | Y | Y | Y | Y | missing |
| `C_ToyBox.GetNumTotalDisplayedToys` | Y | Y | Y | Y | missing |
| `C_ToyBox.GetNumToys` | Y | Y | Y | Y | page |
| `C_ToyBox.GetToyFromIndex` | Y | Y | Y | Y | page |
| `C_ToyBox.GetToyInfo` | Y | Y | Y | Y | page |
| `C_ToyBox.GetToyLink` | Y | Y | Y | Y | page |
| `C_ToyBox.GetUncollectedShown` | Y | Y | Y | Y | missing |
| `C_ToyBox.GetUnusableShown` | Y | Y | Y | Y | missing |
| `C_ToyBox.HasFavorites` | Y | Y | Y | Y | missing |
| `C_ToyBox.IsExpansionTypeFilterChecked` | Y | Y | Y | Y | missing |
| `C_ToyBox.IsSourceTypeFilterChecked` | Y | Y | Y | Y | missing |
| `C_ToyBox.IsToyUsable` | Y | Y | Y | Y | missing |
| `C_ToyBox.PickupToyBoxItem` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetAllExpansionTypeFilters` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetAllSourceTypeFilters` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetCollectedShown` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetExpansionTypeFilter` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetFilterString` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetIsFavorite` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetSourceTypeFilter` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetUncollectedShown` | Y | Y | Y | Y | missing |
| `C_ToyBox.SetUnusableShown` | Y | Y | Y | Y | missing |

### C_ToyBoxInfo

5 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ToyBoxInfo.ClearFanfare` | Y | Y | Y | Y | page |
| `C_ToyBoxInfo.IsToySourceValid` | - | - | - | Y | page |
| `C_ToyBoxInfo.IsUsingDefaultFilters` | - | - | - | Y | page |
| `C_ToyBoxInfo.NeedsFanfare` | Y | Y | Y | Y | page |
| `C_ToyBoxInfo.SetDefaultFilters` | - | - | - | Y | page |

### C_TradeInfo

4 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TradeInfo.AddTradeMoney` | Y | Y | Y | Y | page |
| `C_TradeInfo.PickupTradeMoney` | Y | Y | Y | Y | page |
| `C_TradeInfo.SetTradeMoney` | Y | Y | Y | Y | page |
| `C_TradeInfo.ShouldShowTradeOfferWarning` | Y | Y | Y | Y | page |

### C_TradeSkillUI

145 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TradeSkillUI.AnyRecipeCategoriesFiltered` | - | - | - | Y | missing |
| `C_TradeSkillUI.AreAnyInventorySlotsFiltered` | - | - | - | Y | missing |
| `C_TradeSkillUI.CancelProfessionRespec` | - | - | - | Y | page |
| `C_TradeSkillUI.CanObliterateCursorItem` | - | - | - | Y | missing |
| `C_TradeSkillUI.CanStoreEnchantInItem` | - | - | - | Y | page |
| `C_TradeSkillUI.CanTradeSkillListLink` | - | - | - | Y | missing |
| `C_TradeSkillUI.CheckRespecNPC` | - | - | - | Y | page |
| `C_TradeSkillUI.ClearInventorySlotFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.ClearPendingObliterateItem` | - | - | - | Y | missing |
| `C_TradeSkillUI.ClearRecipeCategoryFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.ClearRecipeSourceTypeFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.CloseObliterumForge` | - | - | - | Y | missing |
| `C_TradeSkillUI.CloseTradeSkill` | - | - | - | Y | page |
| `C_TradeSkillUI.ConfirmProfessionRespec` | - | - | - | Y | page |
| `C_TradeSkillUI.CraftEnchant` | - | - | - | Y | page |
| `C_TradeSkillUI.CraftRecipe` | - | - | - | Y | page |
| `C_TradeSkillUI.CraftSalvage` | - | - | - | Y | page |
| `C_TradeSkillUI.DoesRecraftingRecipeAcceptItem` | - | - | - | Y | page |
| `C_TradeSkillUI.DropPendingObliterateItemFromCursor` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetAllFilterableInventorySlots` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetAllFilterableInventorySlotsCount` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetAllProfessionTradeSkillLines` | - | - | - | Y | page |
| `C_TradeSkillUI.GetAllRecipeIDs` | - | - | - | Y | page |
| `C_TradeSkillUI.GetBaseProfessionInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetCategories` | - | - | - | Y | page |
| `C_TradeSkillUI.GetCategoryInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetChildProfessionInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetChildProfessionInfos` | - | - | - | Y | page |
| `C_TradeSkillUI.GetConcentrationCurrencyID` | - | - | - | Y | page |
| `C_TradeSkillUI.GetCraftableCount` | - | - | - | Y | page |
| `C_TradeSkillUI.GetCraftingOperationInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetCraftingOperationInfoForOrder` | - | - | - | Y | page |
| `C_TradeSkillUI.GetCraftingReagentBonusText` | - | - | - | Y | page |
| `C_TradeSkillUI.GetCraftingTargetItems` | - | - | - | Y | page |
| `C_TradeSkillUI.GetDependentReagents` | - | - | - | Y | page |
| `C_TradeSkillUI.GetEnchantItems` | - | - | - | Y | page |
| `C_TradeSkillUI.GetFactionSpecificOutputItem` | - | - | - | Y | page |
| `C_TradeSkillUI.GetFilterableInventorySlotName` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetFilterableInventorySlots` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetFilteredRecipeIDs` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetGatheringOperationInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetHideUnownedFlags` | - | - | - | Y | page |
| `C_TradeSkillUI.GetItemCraftedQualityByItemInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetItemCraftedQualityInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetItemReagentQualityByItemInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetItemReagentQualityInfo` | Y | Y | Y | Y | page |
| `C_TradeSkillUI.GetItemSlotModifications` | - | - | - | Y | page |
| `C_TradeSkillUI.GetItemSlotModificationsForOrder` | - | - | - | Y | page |
| `C_TradeSkillUI.GetObliterateSpellID` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetOnlyShowFirstCraftRecipes` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetOnlyShowMakeableRecipes` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetOnlyShowSkillUpRecipes` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetOriginalCraftRecipeID` | - | - | - | Y | page |
| `C_TradeSkillUI.GetPendingObliterateItemID` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetPendingObliterateItemLink` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetProfessionByInventorySlot` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionChildSkillLineID` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionForCursorItem` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionInfoByRecipeID` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionInfoBySkillLineID` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionInventorySlots` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionNameForSkillLineAbility` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionSkillLineID` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionSlots` | - | - | - | Y | page |
| `C_TradeSkillUI.GetProfessionSpells` | - | - | - | Y | page |
| `C_TradeSkillUI.GetQualitiesForRecipe` | - | - | - | Y | page |
| `C_TradeSkillUI.GetReagentDifficultyText` | - | - | - | Y | page |
| `C_TradeSkillUI.GetReagentSlotStatus` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeCooldown` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetRecipeDescription` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeInfoForSkillLineAbility` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeItemLevelFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetRecipeItemLink` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeItemNameFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetRecipeItemQualityInfo` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeLink` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetRecipeOutputItemData` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeQualityItemIDs` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeQualityReagentLink` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeRequirements` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeSchematic` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecipeSourceText` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetRecipesTracked` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecraftItems` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRecraftRemovalWarnings` | - | - | - | Y | page |
| `C_TradeSkillUI.GetRemainingRecasts` | - | - | - | Y | page |
| `C_TradeSkillUI.GetSalvagableItemIDs` | - | - | - | Y | page |
| `C_TradeSkillUI.GetShowLearned` | - | - | - | Y | page |
| `C_TradeSkillUI.GetShowUnlearned` | - | - | - | Y | page |
| `C_TradeSkillUI.GetSkillLineForGear` | - | - | - | Y | page |
| `C_TradeSkillUI.GetSourceTypeFilter` | - | - | - | Y | page |
| `C_TradeSkillUI.GetSubCategories` | - | - | - | Y | missing |
| `C_TradeSkillUI.GetTradeSkillDisplayName` | Y | Y | Y | Y | page |
| `C_TradeSkillUI.GetTradeSkillLineForRecipe` | - | - | - | Y | page |
| `C_TradeSkillUI.GetTradeSkillListLink` | - | - | - | Y | page |
| `C_TradeSkillUI.GetTradeSkillTexture` | Y | Y | Y | Y | missing |
| `C_TradeSkillUI.HasFavoriteOrderRecipes` | - | - | - | Y | page |
| `C_TradeSkillUI.IsAnyRecipeFromSource` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsDataSourceChanging` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsEnchantTargetValid` | - | - | - | Y | page |
| `C_TradeSkillUI.IsGuildTradeSkillsEnabled` | Y | Y | Y | Y | page |
| `C_TradeSkillUI.IsInventorySlotFiltered` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsNearProfessionSpellFocus` | - | - | - | Y | page |
| `C_TradeSkillUI.IsNPCCrafting` | - | - | - | Y | page |
| `C_TradeSkillUI.IsOriginalCraftRecipeLearned` | - | - | - | Y | page |
| `C_TradeSkillUI.IsRecipeCategoryFiltered` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsRecipeFavorite` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsRecipeFirstCraft` | - | - | - | Y | page |
| `C_TradeSkillUI.IsRecipeInBaseSkillLine` | - | - | - | Y | page |
| `C_TradeSkillUI.IsRecipeInSkillLine` | - | - | - | Y | page |
| `C_TradeSkillUI.IsRecipeProfessionLearned` | - | - | - | Y | page |
| `C_TradeSkillUI.IsRecipeRepeating` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsRecipeSearchInProgress` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsRecipeSourceTypeFiltered` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsRecipeTracked` | - | - | - | Y | page |
| `C_TradeSkillUI.IsRecraftItemEquipped` | - | - | - | Y | page |
| `C_TradeSkillUI.IsRecraftReagentValid` | - | - | - | Y | page |
| `C_TradeSkillUI.IsRuneforging` | - | - | - | Y | page |
| `C_TradeSkillUI.IsTradeSkillGuild` | - | - | - | Y | page |
| `C_TradeSkillUI.IsTradeSkillGuildMember` | - | - | - | Y | missing |
| `C_TradeSkillUI.IsTradeSkillLinked` | - | - | - | Y | page |
| `C_TradeSkillUI.IsTradeSkillReady` | - | - | - | Y | page |
| `C_TradeSkillUI.ObliterateItem` | - | - | - | Y | missing |
| `C_TradeSkillUI.OpenRecipe` | - | - | - | Y | page |
| `C_TradeSkillUI.OpenTradeSkill` | - | - | - | Y | page |
| `C_TradeSkillUI.RecraftLimitCategoryValid` | - | - | - | Y | page |
| `C_TradeSkillUI.RecraftRecipe` | - | - | - | Y | page |
| `C_TradeSkillUI.RecraftRecipeForOrder` | - | - | - | Y | page |
| `C_TradeSkillUI.SetInventorySlotFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.SetOnlyShowAvailableForOrders` | - | - | - | Y | page |
| `C_TradeSkillUI.SetOnlyShowFirstCraftRecipes` | - | - | - | Y | missing |
| `C_TradeSkillUI.SetOnlyShowMakeableRecipes` | - | - | - | Y | missing |
| `C_TradeSkillUI.SetOnlyShowSkillUpRecipes` | - | - | - | Y | page |
| `C_TradeSkillUI.SetProfessionChildSkillLineID` | - | - | - | Y | page |
| `C_TradeSkillUI.SetRecipeCategoryFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.SetRecipeFavorite` | - | - | - | Y | missing |
| `C_TradeSkillUI.SetRecipeItemLevelFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.SetRecipeItemNameFilter` | - | - | - | Y | page |
| `C_TradeSkillUI.SetRecipeSourceTypeFilter` | - | - | - | Y | missing |
| `C_TradeSkillUI.SetRecipeTracked` | - | - | - | Y | page |
| `C_TradeSkillUI.SetShowLearned` | - | - | - | Y | page |
| `C_TradeSkillUI.SetShowUnlearned` | - | - | - | Y | page |
| `C_TradeSkillUI.SetSourceTypeFilter` | - | - | - | Y | page |
| `C_TradeSkillUI.StopRecipeRepeat` | - | - | - | Y | missing |

### C_Traits

49 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Traits.CanEditConfig` | Y | Y | Y | Y | page |
| `C_Traits.CanPurchaseRank` | Y | Y | Y | Y | page |
| `C_Traits.CanRefundRank` | Y | Y | Y | Y | page |
| `C_Traits.CascadeRepurchaseRanks` | Y | Y | Y | Y | page |
| `C_Traits.ClearCascadeRepurchaseHistory` | Y | Y | Y | Y | page |
| `C_Traits.CloseTraitSystemInteraction` | Y | Y | Y | Y | page |
| `C_Traits.CommitConfig` | Y | Y | Y | Y | page |
| `C_Traits.ConfigHasStagedChanges` | Y | Y | Y | Y | page |
| `C_Traits.GenerateImportString` | Y | Y | Y | Y | page |
| `C_Traits.GenerateInspectImportString` | Y | Y | Y | Y | page |
| `C_Traits.GetConditionInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetConfigIDBySystemID` | Y | Y | Y | Y | page |
| `C_Traits.GetConfigIDByTreeID` | Y | Y | Y | Y | page |
| `C_Traits.GetConfigInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetConfigsByType` | Y | Y | Y | Y | page |
| `C_Traits.GetConfigVariationID` | Y | Y | Y | Y | page |
| `C_Traits.GetDefinitionInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetEntryInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetIncreasedTraitData` | Y | Y | Y | Y | page |
| `C_Traits.GetLoadoutSerializationVersion` | Y | Y | Y | Y | page |
| `C_Traits.GetNodeCost` | Y | Y | Y | Y | page |
| `C_Traits.GetNodeInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetStagedChanges` | Y | Y | Y | Y | page |
| `C_Traits.GetStagedChangesCost` | Y | Y | Y | Y | page |
| `C_Traits.GetSubTreeInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetSystemIDByTreeID` | Y | Y | Y | Y | page |
| `C_Traits.GetTraitCurrencyInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetTraitDescription` | Y | Y | Y | Y | page |
| `C_Traits.GetTraitSystemFlags` | Y | Y | Y | Y | page |
| `C_Traits.GetTraitSystemWidgetSetID` | Y | Y | Y | Y | page |
| `C_Traits.GetTreeCurrencyInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetTreeHash` | Y | Y | Y | Y | page |
| `C_Traits.GetTreeInfo` | Y | Y | Y | Y | page |
| `C_Traits.GetTreeNodes` | Y | Y | Y | Y | page |
| `C_Traits.HasValidInspectData` | Y | Y | Y | Y | page |
| `C_Traits.IsReadyForCommit` | Y | Y | Y | Y | page |
| `C_Traits.PurchaseAllRanks` | Y | Y | Y | Y | page |
| `C_Traits.PurchaseRank` | Y | Y | Y | Y | page |
| `C_Traits.RefundAllRanks` | Y | Y | Y | Y | page |
| `C_Traits.RefundRank` | Y | Y | Y | Y | page |
| `C_Traits.ResetTree` | Y | Y | Y | Y | page |
| `C_Traits.ResetTreeByCurrency` | Y | Y | Y | Y | page |
| `C_Traits.RollbackConfig` | Y | Y | Y | Y | page |
| `C_Traits.SetSelection` | Y | Y | Y | Y | page |
| `C_Traits.StageConfig` | Y | Y | Y | Y | page |
| `C_Traits.TalentTestUnlearnSpells` | Y | Y | Y | Y | page |
| `C_Traits.TryPurchaseAllRanks` | Y | Y | Y | Y | page |
| `C_Traits.TryPurchaseToNode` | Y | Y | Y | Y | page |
| `C_Traits.TryRefundToNode` | Y | Y | Y | Y | page |

### C_Transmog

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Transmog.CanHaveSecondaryAppearanceForSlotID` | Y | Y | Y | Y | page |
| `C_Transmog.ExtractTransmogIDList` | Y | Y | Y | Y | page |
| `C_Transmog.GetAllSetAppearancesByID` | - | - | - | Y | page |
| `C_Transmog.GetItemIDForSource` | Y | Y | Y | Y | page |
| `C_Transmog.GetSlotForInventoryType` | Y | Y | Y | Y | page |
| `C_Transmog.GetSlotVisualInfo` | Y | Y | Y | Y | page |
| `C_Transmog.IsAtTransmogNPC` | Y | Y | Y | Y | page |

### C_TransmogCollection

83 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TransmogCollection.AccountCanCollectSource` | Y | Y | Y | Y | page |
| `C_TransmogCollection.AreAllCollectionTypeFiltersChecked` | Y | Y | Y | Y | page |
| `C_TransmogCollection.AreAllSourceTypeFiltersChecked` | Y | Y | Y | Y | page |
| `C_TransmogCollection.CanAppearanceHaveIllusion` | Y | Y | Y | Y | page |
| `C_TransmogCollection.ClearNewAppearance` | Y | Y | Y | Y | page |
| `C_TransmogCollection.ClearSearch` | Y | Y | Y | Y | page |
| `C_TransmogCollection.DeleteCustomSet` | Y | Y | Y | Y | page |
| `C_TransmogCollection.EndSearch` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAllAppearanceSources` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAllFactionsShown` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAllRacesShown` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAppearanceCameraID` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAppearanceCameraIDBySource` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAppearanceInfoBySource` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAppearanceSourceDrops` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAppearanceSourceInfo` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetAppearanceSources` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetArtifactAppearanceStrings` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCategoryAppearances` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCategoryCollectedCount` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCategoryForItem` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCategoryInfo` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCategoryTotal` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetClassFilter` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCollectedShown` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCustomSetHyperlinkFromItemTransmogInfoList` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCustomSetInfo` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCustomSetItemTransmogInfoList` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetCustomSets` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetFallbackWeaponAppearance` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetFilteredCategoryCollectedCount` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetFilteredCategoryTotal` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetIllusionInfo` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetIllusions` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetIllusionStrings` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetInspectItemTransmogInfoList` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetIsAppearanceFavorite` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetItemInfo` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetItemTransmogInfoListFromCustomSetHyperlink` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetLatestAppearance` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetNumMaxCustomSets` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetNumTransmogSources` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetPairedArtifactAppearance` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetSourceIcon` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetSourceInfo` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetSourceItemID` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetSourceRequiredHoliday` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetUncollectedShown` | Y | Y | Y | Y | page |
| `C_TransmogCollection.GetValidAppearanceSourcesForClass` | Y | Y | Y | Y | page |
| `C_TransmogCollection.HasFavorites` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsAppearanceHiddenVisual` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsCategoryValidForItem` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsNewAppearance` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsSearchDBLoading` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsSearchInProgress` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsSourceTypeFilterChecked` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsSpellItemEnchantmentHiddenVisual` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsUsingDefaultFilters` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsValidCustomSetName` | Y | Y | Y | Y | page |
| `C_TransmogCollection.IsValidTransmogSource` | Y | Y | Y | Y | page |
| `C_TransmogCollection.ModifyCustomSet` | Y | Y | Y | Y | page |
| `C_TransmogCollection.NewCustomSet` | Y | Y | Y | Y | page |
| `C_TransmogCollection.PlayerCanCollectSource` | Y | Y | Y | Y | page |
| `C_TransmogCollection.PlayerHasTransmog` | Y | Y | Y | Y | page |
| `C_TransmogCollection.PlayerHasTransmogByItemInfo` | Y | Y | Y | Y | page |
| `C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance` | Y | Y | Y | Y | page |
| `C_TransmogCollection.PlayerKnowsSource` | Y | Y | Y | Y | page |
| `C_TransmogCollection.RenameCustomSet` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SearchProgress` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SearchSize` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetAllCollectionTypeFilters` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetAllFactionsShown` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetAllRacesShown` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetAllSourceTypeFilters` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetClassFilter` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetCollectedShown` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetDefaultFilters` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetIsAppearanceFavorite` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetSearch` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetSearchAndFilterCategory` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetSourceTypeFilter` | Y | Y | Y | Y | page |
| `C_TransmogCollection.SetUncollectedShown` | Y | Y | Y | Y | page |
| `C_TransmogCollection.UpdateUsableAppearances` | Y | Y | Y | Y | page |

### C_TransmogOutfitInfo

67 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TransmogOutfitInfo.AddNewOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.CanPlayerTransmogSlot` | - | - | - | Y | page |
| `C_TransmogOutfitInfo.ChangeDisplayedOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.ChangeToOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.ChangeViewedOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.ClearAllPendingSituations` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.ClearAllPendingTransmogs` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.ClearDisplayedOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.ClearOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.CommitAndApplyAllPending` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.CommitOutfitInfo` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.CommitPendingSituations` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetActiveOutfitID` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetAllSlotLocationInfo` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetAllTransmogOutfitOptionSheatheCategoryInfo` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetCollectionInfoForSlotAndOption` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetEquippedSlotOptionFromTransmogSlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetIllusionDefaultIMAIDForCollectionType` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetItemModifiedAppearanceEffectiveCategory` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetLinkedSlotInfo` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetMaxNumberOfTotalOutfitsForSource` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetMaxNumberOfUsableOutfits` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetNextOutfitCost` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetNumberOfOutfitsUnlockedForSource` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetOutfitInfo` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetOutfitInfoByName` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetOutfitInfoByPlayerFacingIndex` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetOutfitsInfo` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetOutfitSituation` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetOutfitSituationsEnabled` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetPendingTransmogCost` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetSecondarySlotState` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetSetSourcesForSlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetSlotGroupInfo` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetSourceIDsForSlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetTransmogOutfitSlotForInventoryType` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetTransmogOutfitSlotFromInventorySlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetUISituationCategoriesAndOptions` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetUnassignedAtlasForSlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetUnassignedDisplayAtlasForSlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetViewedOutfitSlotInfo` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.GetWeaponOptionsForSlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.HasPendingOutfitSituations` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.HasPendingOutfitTransmogs` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.InTransmogEvent` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.IsEquippedGearOutfitDisplayed` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.IsEquippedGearOutfitLocked` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.IsLockedOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.IsSlotWeaponSlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.IsTransmogEnabled` | - | - | Y | Y | page |
| `C_TransmogOutfitInfo.IsUsableDiscountAvailable` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.IsValidTransmogOutfitName` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.PickupOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.ResetOutfitSituations` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.RevertPendingTransmog` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SetOutfitSituationsEnabled` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SetOutfitToCustomSet` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SetOutfitToOutfit` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SetOutfitToSet` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SetPendingTransmog` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SetPendingTransmogSheatheCategory` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SetSecondarySlotState` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SetViewedWeaponOptionForSlot` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.SlotHasSecondary` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.TransmogEventActive` | Y | Y | Y | Y | page |
| `C_TransmogOutfitInfo.UpdatePendingSituation` | Y | Y | Y | Y | page |

### C_TransmogSets

41 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TransmogSets.ClearLatestSource` | Y | Y | Y | Y | page |
| `C_TransmogSets.ClearNewSource` | Y | Y | Y | Y | page |
| `C_TransmogSets.ClearSetNewSourcesForSlot` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetAllSets` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetAllSourceIDs` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetAvailableSets` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetBaseSetID` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetBaseSets` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetBaseSetsFilter` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetCameraIDs` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetFilteredBaseSetsCounts` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetFullBaseSetsCounts` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetIsFavorite` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetLatestSource` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetSetInfo` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetSetNewSources` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetSetPrimaryAppearances` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetSetsContainingSourceID` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetSetsFilter` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetSourceIDsForSlot` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetSourcesForSlot` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetTransmogSetsClassFilter` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetUsableSets` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetValidBaseSetsCountsForCharacter` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetValidClassForSet` | Y | Y | Y | Y | page |
| `C_TransmogSets.GetVariantSets` | Y | Y | Y | Y | page |
| `C_TransmogSets.HasAvailableSets` | Y | Y | Y | Y | page |
| `C_TransmogSets.HasUsableSets` | Y | Y | Y | Y | page |
| `C_TransmogSets.IsBaseSetCollected` | Y | Y | Y | Y | page |
| `C_TransmogSets.IsNewSource` | Y | Y | Y | Y | page |
| `C_TransmogSets.IsSetVisible` | Y | Y | Y | Y | page |
| `C_TransmogSets.IsUsingDefaultBaseSetsFilters` | Y | Y | Y | Y | page |
| `C_TransmogSets.IsUsingDefaultSetsFilters` | Y | Y | Y | Y | page |
| `C_TransmogSets.SetBaseSetsFilter` | Y | Y | Y | Y | page |
| `C_TransmogSets.SetDefaultBaseSetsFilters` | Y | Y | Y | Y | page |
| `C_TransmogSets.SetDefaultSetsFilters` | Y | Y | Y | Y | page |
| `C_TransmogSets.SetHasNewSources` | Y | Y | Y | Y | page |
| `C_TransmogSets.SetHasNewSourcesForSlot` | Y | Y | Y | Y | page |
| `C_TransmogSets.SetIsFavorite` | Y | Y | Y | Y | page |
| `C_TransmogSets.SetSetsFilter` | Y | Y | Y | Y | page |
| `C_TransmogSets.SetTransmogSetsClassFilter` | Y | Y | Y | Y | page |

### C_Trophy

9 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Trophy.MonumentChangeAppearanceToTrophyID` | - | - | - | Y | missing |
| `C_Trophy.MonumentCloseMonumentUI` | - | - | - | Y | missing |
| `C_Trophy.MonumentGetCount` | - | - | - | Y | missing |
| `C_Trophy.MonumentGetSelectedTrophyID` | - | - | - | Y | missing |
| `C_Trophy.MonumentGetTrophyInfoByIndex` | - | - | - | Y | missing |
| `C_Trophy.MonumentLoadList` | - | - | - | Y | missing |
| `C_Trophy.MonumentLoadSelectedTrophyID` | - | - | - | Y | missing |
| `C_Trophy.MonumentRevertAppearanceToSaved` | - | - | - | Y | missing |
| `C_Trophy.MonumentSaveSelection` | - | - | - | Y | missing |

### C_TTSSettings

19 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_TTSSettings.GetChannelEnabled` | Y | Y | Y | Y | page |
| `C_TTSSettings.GetCharacterSettingsSaved` | Y | Y | Y | Y | page |
| `C_TTSSettings.GetChatTypeEnabled` | Y | Y | Y | Y | page |
| `C_TTSSettings.GetSetting` | Y | Y | Y | Y | page |
| `C_TTSSettings.GetSpeechRate` | Y | Y | Y | Y | page |
| `C_TTSSettings.GetSpeechVolume` | Y | Y | Y | Y | page |
| `C_TTSSettings.GetVoiceOptionID` | Y | Y | Y | Y | page |
| `C_TTSSettings.GetVoiceOptionName` | Y | Y | Y | Y | page |
| `C_TTSSettings.MarkCharacterSettingsSaved` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetChannelEnabled` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetChannelKeyEnabled` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetChatTypeEnabled` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetDefaultSettings` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetSetting` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetSpeechRate` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetSpeechVolume` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetVoiceOption` | Y | Y | Y | Y | page |
| `C_TTSSettings.SetVoiceOptionName` | Y | Y | Y | Y | page |
| `C_TTSSettings.ShouldOverrideMessage` | Y | Y | Y | Y | page |

### C_Tutorial

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Tutorial.AbandonTutorialArea` | - | - | - | Y | page |
| `C_Tutorial.GetCombatEventInfo` | - | - | - | Y | page |
| `C_Tutorial.ReturnToTutorialArea` | - | - | - | Y | page |

### C_UI

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_UI.DoesAnyDisplayHaveNotch` | Y | Y | Y | Y | page |
| `C_UI.GetTopLeftNotchSafeRegion` | Y | Y | Y | Y | page |
| `C_UI.GetTopRightNotchSafeRegion` | Y | Y | Y | Y | page |
| `C_UI.GetUIParent` | - | - | - | Y | page |
| `C_UI.GetWorldFrame` | - | - | - | Y | page |
| `C_UI.Reload` | Y | Y | Y | Y | page |
| `C_UI.ShouldUIParentAvoidNotch` | Y | Y | Y | Y | page |

### C_UIColor

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_UIColor.GetColors` | Y | Y | Y | Y | page |

### C_UIFileAsset

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_UIFileAsset.GetFileID` | Y | Y | Y | Y | page |
| `C_UIFileAsset.IsKnownFile` | Y | Y | Y | Y | page |
| `C_UIFileAsset.IsLooseFile` | Y | Y | Y | Y | page |

### C_UIWidgetManager

42 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_UIWidgetManager.GetAllWidgetsBySetID` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetBelowMinimapWidgetSetID` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetBulletTextListWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetButtonHeaderWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetCaptureBarWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetCaptureZoneVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetDoubleStateIconRowVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetHorizontalCurrenciesWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetIconTextAndBackgroundWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetIconTextAndCurrenciesWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetItemDisplayVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetMapPinAnimationWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetObjectiveTrackerWidgetSetID` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetPowerBarWidgetSetID` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetSpacerVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetSpellDisplayVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetStackedResourceTrackerWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetTextColumnRowVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetTextureAndTextRowVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetTextureAndTextVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetTextureWithAnimationVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetTopCenterWidgetSetID` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetTugOfWarWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetUnitPowerBarWidgetVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetWidgetSetInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.GetZoneControlVisualizationInfo` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.RegisterUnitForWidgetUpdates` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.SetProcessingUnit` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.SetProcessingUnitGuid` | Y | Y | Y | Y | page |
| `C_UIWidgetManager.UnregisterUnitForWidgetUpdates` | Y | Y | Y | Y | page |

### C_UnitAuras

39 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_UnitAuras.AddAuraSound` | - | - | - | Y | page |
| `C_UnitAuras.AddBlockedAura` | Y | Y | Y | Y | page |
| `C_UnitAuras.AddPrivateAuraAnchor` | Y | Y | Y | Y | page |
| `C_UnitAuras.AddPrivateAuraAppliedSound` | Y | Y | Y | - | page |
| `C_UnitAuras.AuraIsBigDefensive` | Y | Y | Y | Y | page |
| `C_UnitAuras.AuraIsPrivate` | Y | Y | Y | Y | page |
| `C_UnitAuras.CancelAuraByInstanceID` | - | - | - | Y | page |
| `C_UnitAuras.ClearBlockedAuras` | Y | Y | Y | Y | page |
| `C_UnitAuras.DoesAuraHaveExpirationTime` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraApplicationDisplayCount` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraBaseDuration` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraDataByAuraInstanceID` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraDataByIndex` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraDataBySlot` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraDataBySpellName` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraDispelTypeColor` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraDuration` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetAuraSlots` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetBuffDataByIndex` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetCooldownAuraBySpellID` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetDebuffDataByIndex` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetGroupBuffVisualAlerts` | - | - | - | Y | page |
| `C_UnitAuras.GetHiddenGroupBuffs` | - | - | - | Y | page |
| `C_UnitAuras.GetPlayerAuraBySpellID` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetRefreshExtendedDuration` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetUnitAuraBySpellID` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetUnitAuraInstanceIDs` | Y | Y | Y | Y | page |
| `C_UnitAuras.GetUnitAuras` | Y | Y | Y | Y | page |
| `C_UnitAuras.IsAuraFilteredOutByInstanceID` | Y | Y | Y | Y | page |
| `C_UnitAuras.RemoveAuraSound` | - | - | - | Y | page |
| `C_UnitAuras.RemovePrivateAuraAnchor` | Y | Y | Y | Y | page |
| `C_UnitAuras.RemovePrivateAuraAppliedSound` | Y | Y | Y | - | page |
| `C_UnitAuras.ResetAuraDataProvider` | Y | Y | Y | Y | page |
| `C_UnitAuras.SetGroupBuffVisualAlerts` | - | - | - | Y | page |
| `C_UnitAuras.SetHiddenGroupBuffs` | - | - | - | Y | page |
| `C_UnitAuras.SetPrivateWarningTextAnchor` | Y | Y | Y | Y | page |
| `C_UnitAuras.SwitchAuraDataProvider` | Y | Y | Y | Y | page |
| `C_UnitAuras.TriggerPrivateAuraShowDispelType` | Y | Y | Y | - | page |
| `C_UnitAuras.WantsAlteredForm` | Y | Y | Y | Y | page |

### C_UserFeedback

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_UserFeedback.SubmitBug` | Y | Y | Y | Y | page |
| `C_UserFeedback.SubmitSuggestion` | Y | Y | Y | Y | page |

### C_VideoOptions

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_VideoOptions.GetCurrentGameWindowSize` | Y | Y | Y | Y | page |
| `C_VideoOptions.GetDefaultGameWindowSize` | Y | Y | Y | Y | page |
| `C_VideoOptions.GetGameWindowSizes` | Y | Y | Y | Y | page |
| `C_VideoOptions.GetGxAdapterInfo` | Y | Y | Y | Y | page |
| `C_VideoOptions.IsSpellVisualDensitySystemSupported` | Y | Y | Y | Y | page |
| `C_VideoOptions.SetGameWindowSize` | Y | Y | Y | Y | page |

### C_VignetteInfo

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_VignetteInfo.FindBestUniqueVignette` | - | - | - | Y | page |
| `C_VignetteInfo.GetHealthPercent` | - | - | - | Y | page |
| `C_VignetteInfo.GetRecommendedGroupSize` | - | - | - | Y | page |
| `C_VignetteInfo.GetVignetteInfo` | - | - | - | Y | page |
| `C_VignetteInfo.GetVignettePosition` | - | - | - | Y | page |
| `C_VignetteInfo.GetVignettes` | - | - | - | Y | page |

### C_VoiceChat

79 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_VoiceChat.ActivateChannel` | Y | Y | Y | Y | page |
| `C_VoiceChat.ActivateChannelTranscription` | Y | Y | Y | Y | page |
| `C_VoiceChat.BeginLocalCapture` | Y | Y | Y | Y | page |
| `C_VoiceChat.CanAccessSettings` | Y | Y | Y | Y | page |
| `C_VoiceChat.CanPlayerUseVoiceChat` | Y | Y | Y | Y | page |
| `C_VoiceChat.CreateChannel` | Y | Y | Y | Y | page |
| `C_VoiceChat.DeactivateChannel` | Y | Y | Y | Y | page |
| `C_VoiceChat.DeactivateChannelTranscription` | Y | Y | Y | Y | page |
| `C_VoiceChat.EndLocalCapture` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetActiveChannelID` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetActiveChannelType` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetAvailableInputDevices` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetAvailableOutputDevices` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetChannel` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetChannelForChannelType` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetChannelForCommunityStream` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetCommunicationMode` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetCurrentVoiceChatConnectionStatusCode` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetInputVolume` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetJoinClubVoiceChannelError` | - | - | - | Y | page |
| `C_VoiceChat.GetLocalPlayerActiveChannelMemberInfo` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetLocalPlayerMemberID` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetMasterVolumeScale` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetMemberGUID` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetMemberID` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetMemberInfo` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetMemberName` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetMemberVolume` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetOutputVolume` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetProcesses` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetPTTButtonPressedState` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetPushToTalkBinding` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetRemoteTtsVoices` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetTtsVoices` | Y | Y | Y | Y | page |
| `C_VoiceChat.GetVADSensitivity` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsChannelJoinPending` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsDeafened` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsEnabled` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsLoggedIn` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsMemberLocalPlayer` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsMemberMuted` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsMemberMutedForAll` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsMemberSilenced` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsMuted` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsParentalDisabled` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsParentalMuted` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsPlayerUsingVoice` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsSilenced` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsSpeakForMeActive` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsSpeakForMeAllowed` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsTranscribing` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsTranscriptionAllowed` | Y | Y | Y | Y | page |
| `C_VoiceChat.IsVoiceChatConnected` | Y | Y | Y | Y | page |
| `C_VoiceChat.LeaveChannel` | Y | Y | Y | Y | page |
| `C_VoiceChat.Login` | Y | Y | Y | Y | page |
| `C_VoiceChat.Logout` | Y | Y | Y | Y | page |
| `C_VoiceChat.MarkChannelsDiscovered` | Y | Y | Y | Y | page |
| `C_VoiceChat.RequestJoinAndActivateCommunityStreamChannel` | Y | Y | Y | Y | page |
| `C_VoiceChat.RequestJoinChannelByChannelType` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetCommunicationMode` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetDeafened` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetInputDevice` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetInputVolume` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetMasterVolumeScale` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetMemberMuted` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetMemberVolume` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetMuted` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetOutputDevice` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetOutputVolume` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetPortraitTexture` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetPushToTalkBinding` | Y | Y | Y | Y | page |
| `C_VoiceChat.SetVADSensitivity` | Y | Y | Y | Y | page |
| `C_VoiceChat.ShouldDiscoverChannels` | Y | Y | Y | Y | page |
| `C_VoiceChat.SpeakRemoteTextSample` | Y | Y | Y | Y | page |
| `C_VoiceChat.SpeakText` | Y | Y | Y | Y | page |
| `C_VoiceChat.StopSpeakingText` | Y | Y | Y | Y | page |
| `C_VoiceChat.ToggleDeafened` | Y | Y | Y | Y | page |
| `C_VoiceChat.ToggleMemberMuted` | Y | Y | Y | Y | page |
| `C_VoiceChat.ToggleMuted` | Y | Y | Y | Y | page |

### C_WarbandScene

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_WarbandScene.GetRandomEntryID` | - | - | - | Y | page |
| `C_WarbandScene.GetWarbandSceneEntry` | - | - | - | Y | page |
| `C_WarbandScene.HasWarbandScene` | - | - | - | Y | page |
| `C_WarbandScene.IsFavorite` | - | - | - | Y | page |
| `C_WarbandScene.SearchWarbandSceneEntries` | - | - | - | Y | page |
| `C_WarbandScene.SetFavorite` | - | - | - | Y | page |

### C_WeeklyRewards

21 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_WeeklyRewards.AreRewardsForCurrentRewardPeriod` | - | - | - | Y | page |
| `C_WeeklyRewards.CanClaimRewards` | - | - | - | Y | page |
| `C_WeeklyRewards.ClaimReward` | - | - | - | Y | page |
| `C_WeeklyRewards.CloseInteraction` | - | - | - | Y | page |
| `C_WeeklyRewards.GetActivities` | - | - | - | Y | page |
| `C_WeeklyRewards.GetActivityEncounterInfo` | - | - | - | Y | page |
| `C_WeeklyRewards.GetConquestWeeklyProgress` | - | - | - | Y | page |
| `C_WeeklyRewards.GetDifficultyIDForActivityTier` | - | - | - | Y | page |
| `C_WeeklyRewards.GetExampleRewardItemHyperlinks` | - | - | - | Y | page |
| `C_WeeklyRewards.GetItemHyperlink` | - | - | - | Y | page |
| `C_WeeklyRewards.GetNextActivitiesIncrease` | - | - | - | Y | page |
| `C_WeeklyRewards.GetNextMythicPlusIncrease` | - | - | - | Y | page |
| `C_WeeklyRewards.GetNumCompletedDungeonRuns` | - | - | - | Y | page |
| `C_WeeklyRewards.GetSortedProgressForActivity` | - | - | - | Y | page |
| `C_WeeklyRewards.HasAvailableRewards` | - | - | - | Y | page |
| `C_WeeklyRewards.HasGeneratedRewards` | - | - | - | Y | page |
| `C_WeeklyRewards.HasInteraction` | - | - | - | Y | page |
| `C_WeeklyRewards.IsWeeklyChestRetired` | - | - | - | Y | page |
| `C_WeeklyRewards.OnUIInteract` | - | - | - | Y | page |
| `C_WeeklyRewards.ShouldShowFinalRetirementMessage` | - | - | - | Y | page |
| `C_WeeklyRewards.ShouldShowRetirementMessage` | - | - | - | Y | page |

### C_Widget

3 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_Widget.IsFrameWidget` | Y | Y | Y | Y | page |
| `C_Widget.IsRenderableWidget` | Y | Y | Y | Y | missing |
| `C_Widget.IsWidget` | Y | Y | Y | Y | page |

### C_WorldLootObject

8 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_WorldLootObject.DoesSlotMatchInventoryType` | - | - | - | Y | page |
| `C_WorldLootObject.GetWorldLootObjectDistanceSquared` | - | - | - | Y | page |
| `C_WorldLootObject.GetWorldLootObjectInfo` | - | - | - | Y | page |
| `C_WorldLootObject.GetWorldLootObjectInfoByGUID` | - | - | - | Y | page |
| `C_WorldLootObject.IsWorldLootObject` | - | - | - | Y | page |
| `C_WorldLootObject.IsWorldLootObjectByGUID` | - | - | - | Y | page |
| `C_WorldLootObject.IsWorldLootObjectInRange` | - | - | - | Y | page |
| `C_WorldLootObject.OnWorldLootObjectClick` | - | - | - | Y | page |

### C_WowLabsDataManager

7 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_WowLabsDataManager.GetConfirmedWoWLabsArea` | - | - | - | Y | missing |
| `C_WowLabsDataManager.GetWoWLabsAreaInfo` | - | - | - | Y | missing |
| `C_WowLabsDataManager.IsInPrematch` | - | - | - | Y | missing |
| `C_WowLabsDataManager.PushCircleInfoToLua` | - | - | - | Y | missing |
| `C_WowLabsDataManager.QuerySelectedWoWLabsArea` | - | - | - | Y | missing |
| `C_WowLabsDataManager.QueryWoWLabsAreaInfo` | - | - | - | Y | missing |
| `C_WowLabsDataManager.SelectWoWLabsArea` | - | - | - | Y | missing |

### C_WoWLabsMatchmaking

25 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_WoWLabsMatchmaking.AcceptPartyInvite` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.CanEnterMatchmaking` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.ClearFastLogin` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.DeclinePartyInvite` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.GetAutoQueueOnLogout` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.GetCurrentParty` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.GetInQueueTimeStart` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.GetNumPartyInvites` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.GetPartyInviteByIndex` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.GetPartyPlaylistEntry` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.GetPartySize` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.IsAloneInWoWLabsParty` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.IsFastLogin` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.IsFindingMatch` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.IsPartyFull` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.IsPartyLeader` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.IsPlayer` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.IsPlayerReady` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.IsWowLabsMatchmakingMember` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.LeaveParty` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.RemovePlayerFromParty` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.SendPartyInvite` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.SetAutoQueueOnLogout` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.SetPartyPlaylistEntry` | - | - | - | Y | missing |
| `C_WoWLabsMatchmaking.SetPlayerReady` | - | - | - | Y | missing |

### C_WowSurvey

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_WowSurvey.OpenSurvey` | Y | Y | Y | Y | page |
| `C_WowSurvey.TriggerSurveyServe` | Y | Y | Y | Y | page |

### C_WowTokenPublic

11 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_WowTokenPublic.BuyToken` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.GetCommerceSystemStatus` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.GetCurrentMarketPrice` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.GetGuaranteedPrice` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.GetListedAuctionableTokenInfo` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.GetNumListedAuctionableTokens` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.IsAuctionableWowToken` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.IsConsumableWowToken` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.UpdateListedAuctionableTokens` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.UpdateMarketPrice` | Y | Y | Y | Y | missing |
| `C_WowTokenPublic.UpdateTokenCount` | Y | Y | Y | Y | missing |

### C_WowTokenUI

1 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_WowTokenUI.StartTokenSell` | Y | Y | Y | Y | page |

### C_XMLUtil

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_XMLUtil.GetTemplateInfo` | Y | Y | Y | Y | page |
| `C_XMLUtil.GetTemplates` | Y | Y | Y | Y | page |

### C_ZoneAbility

2 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `C_ZoneAbility.GetActiveAbilities` | - | - | - | Y | page |
| `C_ZoneAbility.GetZoneAbilityIcon` | - | - | - | Y | page |

### coroutine

6 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `coroutine.create` | Y | Y | Y | Y | page |
| `coroutine.resume` | Y | Y | Y | Y | page |
| `coroutine.running` | Y | Y | Y | Y | missing |
| `coroutine.status` | Y | Y | Y | Y | missing |
| `coroutine.wrap` | Y | Y | Y | Y | page |
| `coroutine.yield` | Y | Y | Y | Y | page |

### math

27 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `math.abs` | Y | Y | Y | Y | page |
| `math.acos` | Y | Y | Y | Y | missing |
| `math.asin` | Y | Y | Y | Y | missing |
| `math.atan` | Y | Y | Y | Y | missing |
| `math.atan2` | Y | Y | Y | Y | missing |
| `math.ceil` | Y | Y | Y | Y | page |
| `math.cos` | Y | Y | Y | Y | missing |
| `math.cosh` | Y | Y | Y | Y | missing |
| `math.deg` | Y | Y | Y | Y | missing |
| `math.exp` | Y | Y | Y | Y | page |
| `math.floor` | Y | Y | Y | Y | page |
| `math.fmod` | Y | Y | Y | Y | page |
| `math.frexp` | Y | Y | Y | Y | missing |
| `math.ldexp` | Y | Y | Y | Y | missing |
| `math.log` | Y | Y | Y | Y | missing |
| `math.log10` | Y | Y | Y | Y | missing |
| `math.max` | Y | Y | Y | Y | missing |
| `math.min` | Y | Y | Y | Y | missing |
| `math.modf` | Y | Y | Y | Y | missing |
| `math.pow` | Y | Y | Y | Y | missing |
| `math.rad` | Y | Y | Y | Y | missing |
| `math.random` | Y | Y | Y | Y | page |
| `math.sin` | Y | Y | Y | Y | page |
| `math.sinh` | Y | Y | Y | Y | missing |
| `math.sqrt` | Y | Y | Y | Y | missing |
| `math.tan` | Y | Y | Y | Y | missing |
| `math.tanh` | Y | Y | Y | Y | missing |

### string

18 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `string.byte` | Y | Y | Y | Y | page |
| `string.char` | Y | Y | Y | Y | page |
| `string.concat` | Y | Y | Y | Y | page |
| `string.find` | Y | Y | Y | Y | page |
| `string.format` | Y | Y | Y | Y | page |
| `string.gfind` | Y | Y | Y | Y | missing |
| `string.gmatch` | Y | Y | Y | Y | missing |
| `string.gsub` | Y | Y | Y | Y | page |
| `string.join` | Y | Y | Y | Y | page |
| `string.len` | Y | Y | Y | Y | page |
| `string.lower` | Y | Y | Y | Y | page |
| `string.match` | Y | Y | Y | Y | page |
| `string.rep` | Y | Y | Y | Y | page |
| `string.reverse` | Y | Y | Y | Y | page |
| `string.split` | Y | Y | Y | Y | page |
| `string.sub` | Y | Y | Y | Y | page |
| `string.trim` | Y | Y | Y | Y | page |
| `string.upper` | Y | Y | Y | Y | page |

### table

15 APIs.

| API | Era | Anniversary | Classic | Retail | Wiki |
| --- | --- | --- | --- | --- | --- |
| `table.concat` | Y | Y | Y | Y | page |
| `table.count` | Y | Y | Y | Y | page |
| `table.create` | Y | Y | Y | Y | page |
| `table.foreach` | Y | Y | Y | Y | page |
| `table.foreachi` | Y | Y | Y | Y | page |
| `table.freeze` | Y | Y | Y | Y | page |
| `table.getn` | Y | Y | Y | Y | page |
| `table.insert` | Y | Y | Y | Y | page |
| `table.isfrozen` | Y | Y | Y | Y | page |
| `table.maxn` | Y | Y | Y | Y | missing |
| `table.remove` | Y | Y | Y | Y | page |
| `table.removemulti` | Y | Y | Y | Y | page |
| `table.setn` | Y | Y | Y | Y | page |
| `table.sort` | Y | Y | Y | Y | page |
| `table.wipe` | Y | Y | Y | Y | page |
