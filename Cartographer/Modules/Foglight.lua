local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

-- if you want to add data to the defaults, send ckknight@gmail.com your
-- C:\Program Files\World of Warcraft\WTF\Account\ACCOUNTNAME\SavedVariables\Cartographer.lua
-- file.

local L = AceLibrary("AceLocale-2.2"):new("Cartographer-Foglight")

L:RegisterTranslations("enUS", function() return {
	["Foglight"] = true,
	["Module to show unexplored areas on the map."] = true,
	
	["Unexplored color"] = true,
	["Change the color of the unexplored areas"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Foglight"] = "미 탐색 지역",
	["Module to show unexplored areas on the map."] = "지도에 탐험하지 못한 지역을 보여줍니다.",
	
	["Unexplored color"] = "색상",
	["Change the color of the unexplored areas"] = "탐험하지 못한 지역의 색상을 변경합니다.",
} end)

local math_mod = math.fmod or math.mod
local math_floor = math.floor
local math_ceil = math.ceil
local _G = getfenv(0)

Cartographer_Foglight = Cartographer:NewModule("Foglight", "AceHook-2.1", "AceEvent-2.0")

function Cartographer_Foglight:OnInitialize()
	ColorPickerFrame:SetFrameStrata("DIALOG")
	self.name = L["Foglight"]
	self.title = L["Foglight"]
    self.db = Cartographer:AcquireDBNamespace("Foglight")
    Cartographer:RegisterDefaults("Foglight", "profile", {
		darkR = 1,
		darkG = 1,
		darkB = 1,
		darkA = 1,
    })
	Cartographer:RegisterDefaults("Foglight", "account", {
		errata = {
			["LochModan"] = {
				["VALLEYOFKINGS"] = 397399025859,
				["IRONBANDSEXCAVATIONSITE"] = 345176801625,
				["THELSAMAR"] = 218197367040,
				["SILVERSTREAMMINE"] = 12051560683,
				["THELOCH"] = 93785057600,
				["MOGROSHSTRONGHOLD"] = 52108176699,
				["THEFARSTRIDERLODGE"] = 214247447922,
				["STONESPLINTERVALLEY"] = 373887890687,
				["STONEWROUGHTDAM"] = 12166806818,
				["GRIZZLEPAWRIDGE"] = 333184342311,
				["NORTHGATEPASS"] = 13016281318,
			},
			["BurningSteppes"] = {
				["TERRORWINGPATH"] = 50149559576,
				["PILLAROFASH"] = 306412009792,
				["BLACKROCKPASS"] = 300191897870,
				["RUINSOFTHAURISSAN"] = 106838652174,
				["DRACODAR"] = 277084433823,
				["MORGANSVIGIL"] = 334676375846,
				["BLACKROCKMOUNTAIN"] = 108629614848,
				["ALTAROFSTORMS"] = 117075833057,
				["BLACKROCKSTRONGHOLD"] = 122757063925,
				["DREADMAULROCK"] = 181130200284,
			},
			["Moonglade"] = {
				["LAKEELUNEARA"] = 95819397675,
			},
			["Barrens"] = {
				["RATCHET"] = 203520341117,
				["RAZORFENDOWNS"] = 594206117019,
				["THEMERCHANTCOAST"] = 265823555679,
				["GROLDOMFARM"] = 68161752189,
				["CAMPTAURAJO"] = 376192496785,
				["THEMORSHANRAMPART"] = 432115840,
				["AGAMAGOR"] = 251612292296,
				["HONORSSTAND"] = 139907432576,
				["THORNHILL"] = 128297599116,
				["THESLUDGEFEN"] = 478273706,
				["RAPTORGROUNDS"] = 316211837043,
				["DREADMISTPEAK"] = 68085195904,
				["LUSHWATEROASIS"] = 190435222703,
				["FIELDOFGIANTS"] = 432016611538,
				["FARWATCHPOST"] = 56426140772,
				["THEFORGOTTENPOOLS"] = 123883091064,
				["RAZORFENKRAUL"] = 576957055104,
				["NORTHWATCHFOLD"] = 330191462550,
				["THESTAGNANTOASIS"] = 227064021147,
				["BAELMODAN"] = 514774401152,
				["BLACKTHORNRIDGE"] = 496420126875,
				["BRAMBLESCAR"] = 320438703229,
				["BOULDERLODEMINE"] = 582072440,
				["THEDRYHILLS"] = 31471060168,
				["THECROSSROADS"] = 127153630363,
			},
			["Winterspring"] = {
				["LAKEKELTHERIL"] = 213021549783,
				["WINTERFALLVILLAGE"] = 170298307729,
				["FROSTWHISPERGORGE"] = 404275495112,
				["MAZTHORIL"] = 277542523065,
				["ICETHISTLEHILLS"] = 260486370429,
				["THEHIDDENGROVE"] = 29573178543,
				["TIMBERMAWPOST"] = 261159510246,
				["EVERLOOK"] = 115424305317,
				["DARKWHISPERGORGE"] = 473989068031,
				["FROSTSABERROCK"] = 7902253306,
				["OWLWINGTHICKET"] = 365694169253,
				["STARFALLVILLAGE"] = 147513835705,
				["FROSTFIREHOTSPRINGS"] = 184916521200,
			},
			["Hinterlands"] = {
				["THECREEPINGRUIN"] = 279600867508,
				["SERADANE"] = 20935101715,
				["JINTHAALOR"] = 358085850347,
				["HIRIWATHA"] = 328744509665,
				["SHAOLWATHA"] = 257223243032,
				["THEOVERLOOKCLIFFS"] = 326070753450,
				["SKULKROCK"] = 249645122720,
				["AGOLWATHA"] = 176486026445,
				["PLAGUEMISTRAVINE"] = 160153432209,
				["AERIEPEAK"] = 263080588543,
				["QUELDANILLODGE"] = 198890949817,
				["VALORWINDLAKE"] = 324604700842,
				["THEALTAROFZUL"] = 392307053768,
				["SHADRAALOR"] = 415789933763,
			},
			["Westfall"] = {
				["WESTFALLLIGHTHOUSE"] = 501652584728,
				["SENTINELHILL"] = 259235496131,
				["JANGOLODEMINE"] = 31460646103,
				["THEDUSTPLAINS"] = 405349313824,
				["MOONBROOK"] = 355741147356,
				["THEMOLSENFARM"] = 159257933025,
				["ALEXSTONFARMSTEAD"] = 279386999089,
				["DEMONTSPLACE"] = 402871477448,
				["GOLDCOASTQUARRY"] = 109752615137,
				["THEDAGGERHILLS"] = 449179729152,
				["THEJANSENSTEAD"] = 511910053,
				["SALDEANSFARM"] = 113224403169,
				["THEDEADACRE"] = 271132639432,
				["FURLBROWSPUMPKINFARM"] = 12217179346,
			},
			["Badlands"] = {
				["APOCRYPHANSREST"] = 332878001407,
				["THEDUSTBOWL"] = 213841628430,
				["THEMAKERSTERRACE"] = 7924298997,
				["CAMPCAGG"] = 459574309119,
				["CAMPBOFF"] = 366671585535,
				["LETHLORRAVINE"] = 118752746866,
				["AGMONDSEND"] = 418047605001,
				["CAMPKOSH"] = 52117598428,
				["ANGORFORTRESS"] = 159254782147,
				["MIRAGEFLATS"] = 412472295709,
				["KARGATH"] = 158914051312,
				["DUSTWINDGULCH"] = 224934442229,
				["VALLEYOFFANGS"] = 275244095718,
				["HAMMERTOESDIGSITE"] = 129315835080,
			},
			["Darkshore"] = {
				["TOWEROFALTHALAXX"] = 91758988458,
				["GROVEOFTHEANCIENTS"] = 442701621448,
				["CLIFFSPRINGRIVER"] = 101325142246,
				["AUBERDINE"] = 174279842966,
				["THEMASTERSGLAIVE"] = 547953473711,
				["REMTRAVELSEXCAVATION"] = 521005096111,
				["AMETHARAN"] = 328904946878,
				["RUINSOFMATHYSTRA"] = 534994115,
				["BASHALARAN"] = 194730200244,
			},
			["WesternPlaguelands"] = {
				["GAHRRONSWITHERING"] = 268980925620,
				["DARROWMERELAKE"] = 368822204786,
				["THONDRORILRIVER"] = 92960805069,
				["FELSTONEFIELD"] = 334248408224,
				["HEARTHGLEN"] = 17502077268,
				["THEWEEPINGCAVE"] = 213194580128,
				["NORTHRIDGELUMBERCAMP"] = 176494399708,
				["THEWRITHINGHAUNT"] = 347291711658,
				["DALSONSTEARS"] = 284941244636,
				["RUINSOFANDORHOL"] = 381451213085,
				["CAERDARROW"] = 443010946218,
				["SORROWHILL"] = 496441178412,
				["THEBULWARK"] = 314750199009,
			},
			["Desolace"] = {
				["MAGRAMVILLAGE"] = 392534717645,
				["VALLEYOFSPEARS"] = 231077082357,
				["SHADOWPREYVILLAGE"] = 417860917478,
				["TETHRISARAN"] = 452084941,
				["THUNDERAXEFORTRESS"] = 109990604990,
				["MANNOROCCOVEN"] = 408440561949,
				["SARGERON"] = 36089091357,
				["KODOGRAVEYARD"] = 262399060243,
				["KOLKARVILLAGE"] = 231491203292,
				["ETHELRETHOR"] = 65824614605,
				["SHADOWBREAKRAVINE"] = 477465087181,
				["GELKISVILLAGE"] = 457721497795,
				["RANAZJARISLE"] = 6695260260,
				["KORMEKSHUT"] = 194929393834,
				["NIJELSPOINT"] = 581167304,
			},
			["Arathi"] = {
				["THANDOLSPAN"] = 442754101448,
				["NORTHFOLDMANOR"] = 96838336742,
				["HAMMERFALL"] = 129536092365,
				["BOULDERGOR"] = 155936085237,
				["BOULDERFISTHALL"] = 389147765975,
				["CIRCLEOFWESTBINDING"] = 58126977214,
				["WITHERBARKVILLAGE"] = 358142396631,
				["DABYRIESFARMSTEAD"] = 177662544052,
				["CIRCLEOFINNERBINDING"] = 333160047826,
				["CIRCLEOFOUTERBINDING"] = 315045866666,
				["FALDIRSCOVE"] = 455446060288,
				["GOSHEKFARM"] = 296909737190,
				["THORADINSWALL"] = 148267843774,
				["REFUGEPOINT"] = 200104182959,
				["CIRCLEOFEASTBINDING"] = 120844425376,
				["STROMGARDEKEEP"] = 308277385456,
			},
			["Durotar"] = {
				["DRYGULCHRAVINE"] = 84199768274,
				["ORGRIMMAR"] = 256016829,
				["TIRAGARDEKEEP"] = 307574788286,
				["THUNDERRIDGE"] = 64767598782,
				["KOLKARCRAG"] = 511534293152,
				["RAZORHILL"] = 182989330652,
				["ECHOISLES"] = 459063673032,
				["SENJINVILLAGE"] = 412814080160,
				["SKULLROCK"] = 35920132224,
				["RAZORMANEGROUNDS"] = 203253061862,
				["VALLEYOFTRIALS"] = 343969848535,
			},
			["Tirisfal"] = {
				["RUINSOFLORDAERON"] = 388106530107,
				["MONASTARY"] = 135000159443,
				["SCARLETWATCHPOST"] = 112391871663,
				["STILLWATERPOND"] = 297840804026,
				["BALNIRFARMSTEAD"] = 350700621016,
				["BULWARK"] = 389426656486,
				["VENOMWEBVALE"] = 220911065325,
				["GARRENSHAUNT"] = 156213932206,
				["BRIGHTWATERLAKE"] = 149865922761,
				["DEATHKNELL"] = 352425555189,
				["BRILL"] = 321612052608,
				["NIGHTMAREVALE"] = 375116733683,
				["COLDHEARTHMANOR"] = 351610732694,
				["AGAMANDMILLS"] = 149601601792,
				["CRUSADEROUTPOST"] = 311039230125,
				["SOLLIDENFARMSTEAD"] = 268686225664,
			},
			["SwampOfSorrows"] = {
				["MISTYVALLEY"] = 150324167925,
				["MISTYREEDSTRAND"] = 782921984,
				["THEHARBORAGE"] = 155872081131,
				["POOLOFTEARS"] = 234668444972,
				["SORROWMURK"] = 129608561879,
				["STONARD"] = 254769687912,
				["THESHIFTINGMIRE"] = 118411734331,
				["SPLINTERSPEARJUNCTION"] = 253538582803,
				["STAGALBOG"] = 406453479769,
				["FALLOWSANCTUARY"] = 516212077,
				["ITHARIUSSCAVE"] = 281320609008,
			},
			["StonetalonMountains"] = {
				["WEBWINDERPATH"] = 303274757408,
				["BOULDERSLIDERAVINE"] = 602969058449,
				["CAMPAPARAJE"] = 613859558590,
				["WINDSHEARCRAG"] = 212107283776,
				["STONETALONPEAK"] = 259208462,
				["SUNROCKRETREAT"] = 344005433494,
				["SISHIRCANYON"] = 465428411517,
				["GRIMTOTEMPOST"] = 553677611233,
				["THECHARREDVALE"] = 251476151526,
				["MALAKAJIN"] = 625613035645,
				["MIRKFALLONLAKE"] = 156101729480,
			},
			["DunMorogh"] = {
				["ANVILMAR"] = 432880674032,
				["THETUNDRIDHILLS"] = 346292355227,
				["COLDRIDGEPASS"] = 413700063382,
				["IRONFORGE"] = 175436407099,
				["ICEFLOWLAKE"] = 179609718912,
				["FROSTMANEHOLD"] = 308391572605,
				["MISTYPINEREFUGE"] = 237823497344,
				["GOLBOLARQUARRY"] = 313096574117,
				["AMBERSTILLRANCH"] = 301248675968,
				["GNOMERAGON"] = 197742728372,
				["HELMSBEDLAKE"] = 293859403931,
				["THEGRIZZLEDDEN"] = 334263149768,
				["SOUTHERNGATEOUTPOST"] = 300404564096,
				["CHILLBREEZEVALLEY"] = 318115020980,
				["NORTHERNGATEOUTPOST"] = 186553373824,
				["BREWNALLVILLAGE"] = 267626073203,
				["KHARANOS"] = 316085051592,
				["SHIMMERRIDGE"] = 175383967872,
			},
			["SearingGorge"] = {
				["BLACKCHARCAVE"] = 393070488851,
				["THECAULDRON"] = 182798587305,
				["FIREWATCHRIDGE"] = 32301824405,
				["THESEAOFCINDERS"] = 416871113064,
				["DUSTFIREVALLEY"] = 9032807884,
				["TANNERCAMP"] = 437584632113,
				["GRIMSILTDIGSITE"] = 322640769329,
			},
			["AlteracValley"] = {
				["ICEBLOODGARRISON"] = 185035174188,
				["DUNBALDAR"] = 14323794190,
				["FROSTWOLFKEEP"] = 403071863019,
			},
			["Hilsbrad"] = {
				["EASTERNSTRAND"] = 364548260070,
				["PURGATIONISLE"] = 517657956477,
				["DURNHOLDEKEEP"] = 81165399424,
				["SOUTHPOINTTOWER"] = 206160758048,
				["WESTERNSTRAND"] = 395355254045,
				["SOUTHSHORE"] = 216260688107,
				["AZURELOADMINE"] = 295462707365,
				["NETHANDERSTEAD"] = 253970596055,
				["TARRENMILL"] = 534042844,
				["HILLSBRADFIELDS"] = 166637882673,
				["DARROWHILL"] = 165790510285,
				["DUNGAROK"] = 316348321008,
			},
			["Duskwood"] = {
				["THEROTTINGORCHARD"] = 396776151290,
				["ADDLESSTEAD"] = 367277631763,
				["RAVENHILLCEMETARY"] = 160076968286,
				["DARKSHIRE"] = 174608113979,
				["RAVENHILL"] = 324377134275,
				["THEDARKENEDBANK"] = 33379535758,
				["BRIGHTWOODGROVE"] = 126156624092,
				["TWILIGHTGROVE"] = 85138510184,
				["VULGOLOGREMOUND"] = 373917250815,
				["MANORMISTMANTLE"] = 129533918408,
				["TRANQUILGARDENSCEMETARY"] = 379754606812,
				["THEYORGENFARMSTEAD"] = 410578577643,
				["THEHUSHEDBANK"] = 141754181792,
			},
			["ThousandNeedles"] = {
				["THEGREATLIFT"] = 75377070290,
				["WINDBREAKCANYON"] = 268951580912,
				["HIGHPERCH"] = 166462683326,
				["FREEWINDPOST"] = 283842377938,
				["THESCREECHINGCANYON"] = 214936305914,
				["DARKCLOUDPINNACLE"] = 140931960013,
				["CAMPETHOK"] = 317745,
				["THESHIMMERINGFLATS"] = 322762552640,
				["SPLITHOOFCRAG"] = 206568623314,
			},
			["Ashenvale"] = {
				["WARSONGLUMBERCAMP"] = 334768537800,
				["THESHRINEOFAESSINA"] = 278208384220,
				["THERUINSOFSTARDUST"] = 400778483867,
				["THISTLEFURVILLAGE"] = 169864269055,
				["FELFIREHILL"] = 370115083509,
				["LAKEFALATHIM"] = 147240193152,
				["IRISLAKE"] = 234486969544,
				["MYSTRALLAKE"] = 372961952019,
				["NIGHTRUN"] = 277651651809,
				["MAESTRASPOST"] = 41017459927,
				["THEZORAMSTRAND"] = 30084945141,
				["SATYRNAAR"] = 242319811869,
				["FALLENSKYLAKE"] = 457987798251,
				["FIRESCARSHRINE"] = 348090711205,
				["THEHOWLINGVALE"] = 151883277522,
				["BOUGHSHADOW"] = 163032801426,
				["ASTRANAAR"] = 269794600141,
				["RAYNEWOODRETREAT"] = 256096064692,
			},
			["Teldrassil"] = {
				["THEORACLEGLADE"] = 136650670250,
				["WELLSPRINGLAKE"] = 100253565108,
				["LAKEALAMETH"] = 408479261952,
				["BANETHILHOLLOW"] = 302122223776,
				["POOLSOFARLITHRIEN"] = 336432658560,
				["DARNASSUS"] = 265320399163,
				["STARBREEZEVILLAGE"] = 314121068744,
				["GNARLPINEHOLD"] = 476053635257,
				["SHADOWGLEN"] = 164797580513,
				["RUTTHERANVILLAGE"] = 588928618624,
				["DOLANAAR"] = 347303182526,
			},
			["BlastedLands"] = {
				["DREADMAULPOST"] = 209758391541,
				["GARRISONARMORY"] = 10158809258,
				["SERPENTSCOIL"] = 150849366241,
				["THETAINTEDSCAR"] = 191348803968,
				["DARKPORTAL"] = 278574362889,
				["RISEOFTHEDEFILER"] = 132495066282,
				["ALTAROFSTORMS"] = 143132880057,
				["DREADMAULHOLD"] = 16484847811,
				["NETHERGARDEKEEP"] = 32798603449,
			},
			["Mulgore"] = {
				["WINDFURYRIDGE"] = 414318797,
				["WILDMANEWATERWELL"] = 305266873,
				["THEVENTURECOMINE"] = 256108637409,
				["REDCLOUDMESA"] = 456623640022,
				["THEGOLDENPLAINS"] = 86348382423,
				["THEROLLINGPLAINS"] = 382800689408,
				["RAVAGEDCARAVAN"] = 279668973696,
				["BLOODHOOFVILLAGE"] = 325728805120,
				["THUNDERHORNWATERWELL"] = 260243090560,
				["REDROCKS"] = 17706490061,
				["BAELDUNDIGSITE"] = 230048321746,
				["PALEMANEROCK"] = 329956668544,
				["WINTERHOOFWATERWELL"] = 396691112106,
				["THUNDERBLUFF"] = 63612109080,
			},
			["Felwood"] = {
				["SHATTERSCARVALE"] = 132392362219,
				["DEADWOODVILLAGE"] = 572732349615,
				["IRONTREEWOODS"] = 58422680791,
				["JADEFIREGLEN"] = 499638234277,
				["JADEFIRERUN"] = 31484717251,
				["BLOODVENOMFALLS"] = 282700432619,
				["TALONBRANCHGLADE"] = 97211532448,
				["JAEDENAR"] = 355692839157,
				["FELPAWVILLAGE"] = 506610928,
				["MORLOSARAN"] = 547054845073,
				["EMERALDSANCTUARY"] = 461060079801,
				["RUINSOFCONSTELLAS"] = 409407220971,
			},
			["Silverpine"] = {
				["THESEPULCHER"] = 180757889234,
				["MALDENSORCHARD"] = 487751936,
				["THESHININGSTRAND"] = 14440165632,
				["THEGREYMANEWALL"] = 480360226002,
				["DEEPELEMMINE"] = 280739621024,
				["AMBERMILL"] = 281838600432,
				["THESKITTERINGDARK"] = 40028509369,
				["NORTHTIDESHOLLOW"] = 137777774772,
				["PYREWOODVILLAGE"] = 479298974860,
				["THEDEADFIELD"] = 70214915247,
				["BERENSPERIL"] = 448265375984,
				["THEDECREPITFERRY"] = 155098211508,
				["SHADOWFANGKEEP"] = 385855160540,
				["FENRISISLE"] = 80078920954,
				["OLSENSFARTHING"] = 270983685285,
			},
			["Aszhara"] = {
				["SOUTHRIDGEBEACH"] = 379438985586,
				["BITTERREACHES"] = 43625145589,
				["FORLORNRIDGE"] = 396411272412,
				["JAGGEDREEF"] = 383953466,
				["RUINSOFELDARATH"] = 237546791177,
				["TOWEROFELDARA"] = 115748269176,
				["SHADOWSONGSHRINE"] = 453155934433,
				["THALASSIANBASECAMP"] = 128298675440,
				["THERUINEDREACHES"] = 580235952523,
				["VALORMOK"] = 245975137495,
				["HALDARRENCAMPMENT"] = 355489437896,
				["RAVENCRESTMONUMENT"] = 536376112368,
				["TEMPLEOFARKKORAN"] = 164996784318,
				["URSOLAN"] = 102448192657,
				["BAYOFSTORMS"] = 216324681998,
				["THESHATTEREDSTRAND"] = 208729753760,
				["LAKEMENNAR"] = 460945826107,
				["TIMBERMAWHOLD"] = 114079054059,
				["LEGASHENCAMPMENT"] = 47746003179,
			},
			["Elwynn"] = {
				["NORTHSHIREVALLEY"] = 158239817984,
				["EASTVALELOGGINGCAMP"] = 355073214720,
				["BRACKWELLPUMPKINPATCH"] = 450503107840,
				["FORESTSEDGE"] = 351243949312,
				["JERODSLANDING"] = 463228613888,
				["FARGODEEPMINE"] = 459811307776,
				["RIDGEPOINTTOWER"] = 467807741234,
				["CRYSTALLAKE"] = 356925010145,
				["STORMWIND"] = 415205,
				["TOWEROFAZORA"] = 314110634239,
				["GOLDSHIRE"] = 290172662000,
				["STONECAIRNLAKE"] = 204626723126,
			},
			["Tanaris"] = {
				["SANDSORROWWATCH"] = 107687886019,
				["STEAMWHEEDLEPORT"] = 81151547547,
				["SOUTHMOONRUINS"] = 385812220099,
				["WATERSPRINGFIELD"] = 180922536101,
				["DUNEMAULCOMPOUND"] = 310652323021,
				["VALLEYOFTHEWATCHERS"] = 466309251222,
				["CAVERNSOFTIME"] = 275466311835,
				["EASTMOONRUINS"] = 371929012384,
				["ABYSSALSANDS"] = 208686731479,
				["GADGETZAN"] = 98152125615,
				["THISTLESHRUBVALLEY"] = 307303278777,
				["LANDSENDBEACH"] = 549148849357,
				["ZALASHJISDEN"] = 158480871534,
				["THENOXIOUSLAIR"] = 213939069108,
				["ZULFARRAK"] = 266517714,
				["NOONSHADERUINS"] = 112228179064,
				["LOSTRIGGERCOVE"] = 236882950304,
				["BROKENPILLAR"] = 251751747694,
				["THEGAPINGCHASM"] = 399902984412,
				["SOUTHBREAKSHORE"] = 315129773271,
			},
			["Silithus"] = {
				["THESCARABWALL"] = 443577270560,
				["TWILIGHTBASECAMP"] = 211888111936,
				["HIVEASHI"] = 13163102720,
				["SOUTHWINDVILLAGE"] = 70317900160,
				["HIVEREGAL"] = 306273714688,
				["THECRYSTALVALE"] = 25879151936,
				["HIVEZORA"] = 154721059200,
			},
			["Feralas"] = {
				["SARDORISLE"] = 251473875124,
				["FERALSCARVALE"] = 353770785907,
				["ONEIROS"] = 75678988398,
				["THETWINCOLOSSALS"] = 80865383709,
				["FRAYFEATHERHIGHLANDS"] = 414965737582,
				["THEFORGOTTENCOAST"] = 275301859473,
				["THEWRITHINGDEEP"] = 320623309040,
				["DIREMAUL"] = 216298360038,
				["CAMPMOJACHE"] = 250904477851,
				["LOWERWILDS"] = 213388546273,
				["GRIMTOTEMCOMPOUND"] = 179968347256,
				["RUINSOFISILDIEN"] = 344163870910,
				["DREAMBOUGH"] = 476181654,
				["ISLEOFDREAD"] = 402854810839,
				["GORDUNNIOUTPOST"] = 152121283724,
				["RUINSOFRAVENWIND"] = 319974590,
			},
			["EasternPlaguelands"] = {
				["BLACKWOODLAKE"] = 214138334438,
				["NORTHDALE"] = 138089280702,
				["PLAGUEWOOD"] = 89298057576,
				["ZULMASHAR"] = 32856249549,
				["THEINFECTISSCAR"] = 313109269699,
				["QUELLITHIENLODGE"] = 39097358566,
				["PESTILENTSCAR"] = 370870053069,
				["THEUNDERCROFT"] = 512355358905,
				["THEFUNGALVALE"] = 280530995410,
				["THONDRORILRIVER"] = 248042070236,
				["CROWNGUARDTOWER"] = 430875776205,
				["STRATHOLME"] = 9867305200,
				["TYRSHAND"] = 506484402421,
				["LIGHTSHOPECHAPEL"] = 321799836847,
				["THEMARRISSTEAD"] = 386710844616,
				["NORTHPASSTOWER"] = 117517257968,
				["DARROWSHIRE"] = 525383945426,
				["LAKEMERELDAR"] = 497705729274,
				["EASTWALLTOWER"] = 259392700596,
				["THENOXIOUSGLADE"] = 178998435041,
				["TERRORDALE"] = 105309746366,
				["CORINSCROSSING"] = 394626498725,
			},
			["UngoroCrater"] = {
				["THESLITHERINGSCAR"] = 408407012697,
				["FIREPLUMERIDGE"] = 191511148839,
				["TERRORRUN"] = 395302958425,
				["IRONSTONEPLATEAU"] = 72551265565,
				["GOLAKKAHOTSPRINGS"] = 162262246715,
				["THEMARSHLANDS"] = 258285604150,
				["LAKKARITARPITS"] = 6610495034,
			},
			["Dustwallow"] = {
				["THEDENOFFLAME"] = 336350931199,
				["BACKBAYWETLANDS"] = 203188075920,
				["THERAMOREISLE"] = 241078318310,
				["BRACKENWALLVILLAGE"] = 241449240,
				["ALCAZISLAND"] = 23240838344,
				["THEWYRMBOG"] = 409480708381,
				["WITCHHILL"] = 442821882,
			},
			["DeadwindPass"] = {
				["KARAZHAN"] = 362133312812,
				["DEADMANSCROSSING"] = 81865848188,
				["THEVICE"] = 321495775502,
			},
			["Wetlands"] = {
				["BLACKCHANNELMARSH"] = 263147666672,
				["WHELGARSEXCAVATIONSITE"] = 220376261827,
				["GRIMBATOL"] = 247601668446,
				["MOSSHIDEFEN"] = 284020692173,
				["RAPTORRIDGE"] = 189637230782,
				["THEGREENBELT"] = 134696124601,
				["MENETHILHARBOR"] = 337168695471,
				["ANGERFANGENCAMPMENT"] = 234439763169,
				["DUNMODR"] = 22969241805,
				["THELGANROCK"] = 398851242214,
				["BLUEGILLMARSH"] = 152564857057,
				["SALTSPRAYGLEN"] = 44272173256,
				["IRONBEARDSTOMB"] = 123846452424,
				["DIREFORGEHILL"] = 124012194048,
				["SUNDOWNMARSH"] = 88143544620,
			},
			["Redridge"] = {
				["STONEWATCH"] = 231379087615,
				["ALTHERSMILL"] = 138931353835,
				["THREECORNERS"] = 304943036781,
				["GALARDELLVALLEY"] = 173558458618,
				["LAKESHIRE"] = 211614371156,
				["REDRIDGECANYONS"] = 77436540269,
				["STONEWATCHFALLS"] = 344221501760,
				["LAKERIDGEHIGHWAY"] = 357752408494,
				["RENDERSCAMP"] = 290717971,
				["LAKEEVERSTILL"] = 257837780503,
				["RENDERSVALLEY"] = 388128570833,
			},
			["Stranglethorn"] = {
				["WILDSHORE"] = 453359368357,
				["BOOTYBAY"] = 465143201937,
				["RUINSOFZULMAMWE"] = 228046533802,
				["BLOODSAILCOMPOUND"] = 305146281125,
				["KALAIRUINS"] = 94802902111,
				["MIZJAHRUINS"] = 140986398825,
				["MISTVALEVALLEY"] = 395430720637,
				["REBELCAMP"] = 297887914,
				["BALALRUINS"] = 99037036634,
				["VENTURECOBASECAMP"] = 69125403753,
				["RUINSOFJUBUWAL"] = 323517266030,
				["CRYSTALVEINMINE"] = 296714625144,
				["JAGUEROISLE"] = 529684095101,
				["BALIAMAHRUINS"] = 138901860462,
				["ZULGURUB"] = 9096622325,
				["ZUULDAIARUINS"] = 45260852339,
				["NEKMANIWELLSPRING"] = 385694682202,
				["MOSHOGGOGREMOUND"] = 101384895616,
				["RUINSOFABORAZ"] = 360070610015,
				["THEARENA"] = 203183809736,
				["RUINSOFZULKUNDA"] = 3426889853,
				["ZIATAJAIRUINS"] = 248416171136,
				["KURZENSCOMPOUND"] = 407001243,
				["THEVILEREEF"] = 96796327102,
				["LAKENAZFERITI"] = 63697974400,
				["NESINGWARYSEXPEDITION"] = 28199467148,
				["GROMGOLBASECAMP"] = 142006658158,
			},
			["Alterac"] = {
				["DANDREDSFOLD"] = 289642781,
				["THEUPLANDS"] = 83162767595,
				["DALARAN"] = 281347928364,
				["SOFERASNAZE"] = 330123510015,
				["LORDAMEREINTERNMENTCAMP"] = 432764364106,
				["CHILLWINDPOINT"] = 272313469278,
				["THEHEADLAND"] = 506061853861,
				["CRUSHRIDGEHOLD"] = 174296645912,
				["MISTYSHORE"] = 140865986780,
				["GALLOWSCORNER"] = 299999895752,
				["STRAHNBRAD"] = 113318867314,
				["GAVINSNAZE"] = 513484700832,
				["GROWLESSCAVE"] = 399764531390,
				["RUINSOFALTERAC"] = 211810516223,
				["CORRAHNSDAGGER"] = 408440570051,
			},
			["AzuremystIsle"] = {
				["AzureWatch"] = 267763581184,
				["MoongrazeWoods"] = 196965826816,
				["StillpineHold"] = 52996342016,
				["BristlelimbVillage"] = 389950996736,
				["GreezlesCamp"] = 376341528832,
				["WrathscalePoint"] = 452276247808,
				["PodWreckage"] = 375220600960,
				["PodCluster"] = 327786168576,
				["AmmenFord"] = 300114247936,
				["SiltingShore"] = 3526623488,
				["Emberglade"] = 26281771264,
				["TheExodar"] = 91346174464,
				["FairbridgeStrand"] = 373424384,
				["ValaarsBerth"] = 325528584448,
				["OdesyusLanding"] = 406243770624,
				["AmmenVale"] = 112222274011,
				["SilvermystIsle"] = 478913198336,
			},
			["Netherstorm"] = {
				["SocretharsSeat"] = 41042575616,
				["NetherstormBridge"] = 315818770688,
				["EtheriumStagingGrounds"] = 223842926848,
				["TheStormspire"] = 144194142464,
				["KirinVarVillage"] = 562080924928,
				["ManaforgeCoruu"] = 525434277120,
				["ManafrogeAra"] = 166609551616,
				["TempestKeep"] = 305564877209,
				["RuinsofFarahlon"] = 52984807936,
				["RuinsofEnkaat"] = 323461841152,
				["TheScrapField"] = 280620171520,
				["CelestialRidge"] = 186432880896,
				["ForgeBaseOG"] = 23871095040,
				["RuinedManaforge"] = 148714553600,
				["Area52"] = 416864665856,
				["EcoDomeFarfield"] = 11152916736,
				["Netherstone"] = 21906063616,
				["ManaforgeBanar"] = 301875989760,
				["ManaforgeDuro"] = 361265103104,
				["ArklonRuins"] = 426619699456,
				["TheHeap"] = 488803357952,
				["SunfuryHold"] = 484733838592,
			},
			["Hellfire"] = {
				["MagharPost"] = 118327869696,
				["ZethGor"] = 462317402534,
				["HonorHold"] = 320467108096,
				["HellfireCitadel"] = 225840670976,
				["TheLegionFront"] = 138046603520,
				["WarpFields"] = 438409892096,
				["TempleofTelhamat"] = 163249127936,
				["VoidRidge"] = 395876499712,
				["PoolsofAggonar"] = 48660742400,
				["FalconWatch"] = 350232074752,
				["ForgeCampRage"] = 27345289728,
				["DenofHaalesh"] = 442572734720,
				["TheStairofDestiny"] = 168277049600,
				["FallenSkyRidge"] = 152507252992,
				["Thrallmar"] = 165846188288,
				["ThroneofKiljaeden"] = 6942884352,
				["ExpeditionArmory"] = 443729313280,
				["RuinsofShanaar"] = 311411730688,
			},
			["BladesEdgeMountains"] = {
				["VekhaarStand"] = 436598997248,
				["ForgeCampWrath"] = 189245161728,
				["VeilLashh"] = 459845910784,
				["RuuanWeald"] = 105729491200,
				["BladesipreHold"] = 173202205952,
				["ThunderlordStronghold"] = 292482855168,
				["TheSingingRidge"] = 643039488,
				["RidgeofMadness"] = 277606721792,
				["BladedGulch"] = 158493573376,
				["CircleofWrath"] = 225946370304,
				["BashirLanding"] = 442761472,
				["MokNathalVillage"] = 319591547136,
				["Skald"] = 76941623552,
				["VeilRuuan"] = 162725495040,
				["BloodmaulOutpost"] = 398717134080,
				["Sylvanaar"] = 376113002752,
				["VortexPinnacle"] = 221365352704,
				["Grishnath"] = 30364926208,
				["JaggedRidge"] = 444997040384,
				["RavensWood"] = 59280458240,
				["FelstormPoint"] = 474481152,
				["RazorRidge"] = 357041520896,
				["ForgeCampAnger"] = 158454776224,
				["GruulsLayer"] = 87525949696,
				["DeathsDoor"] = 267899014400,
				["BrokenWilds"] = 117806727424,
				["ForgeCampTerror"] = 446827852288,
				["BloodmaulCamp"] = 102437748992,
			},
			["Ghostlands"] = {
				["GoldenmistVillage"] = 46662144,
				["ZebNowa"] = 254965890560,
				["HowlingZiggurat"] = 235506435328,
				["FarstriderEnclave"] = 146629984685,
				["DawnstarSpire"] = 603193771,
				["WindrunnerVillage"] = 125691232512,
				["Deatholme"] = 402753099264,
				["SanctumoftheSun"] = 161531560192,
				["IsleofTribulations"] = 613679360,
				["SuncrownVillage"] = 482607616,
				["SanctumoftheMoon"] = 135511933184,
				["Tranquillien"] = 2530738432,
				["ElrendarCrossing"] = 342098432,
				["BleedingZiggurat"] = 255743754496,
				["ThalassiaPass"] = 436321130752,
				["WindrunnerSpire"] = 308206108928,
				["AmaniPass"] = 249735598484,
			},
			["Zangarmarsh"] = {
				["ZabraJin"] = 249291866368,
				["AngoroshStronghold"] = 130154752,
				["TwinspireRuins"] = 267720589568,
				["BloodscaleEnclave"] = 443006845184,
				["CoilfangReservoir"] = 97121730816,
				["Telredor"] = 120856248576,
				["TheDeadMire"] = 138190258462,
				["Sporeggar"] = 216917082624,
				["CenarionRefuge"] = 345399099700,
				["TheHewnBog"] = 54990995712,
				["MarshlightLake"] = 163293954304,
				["QuaggRidge"] = 349114293504,
				["TheLagoon"] = 325880905984,
				["UmbrafenVillage"] = 495750167808,
				["TheSpawningGlen"] = 364031246592,
				["AngoroshGrounds"] = 53779628288,
				["OreborHarborage"] = 27189051648,
				["FeralfenVillage"] = 356811883008,
			},
			["BloodmystIsle"] = {
				["RuinsofLorethAran"] = 232511504640,
				["Bladewood"] = 224797131008,
				["VeridianPoint"] = 668205312,
				["TheCryoCore"] = 306323915008,
				["VindicatorsRest"] = 260089053440,
				["KesselsCrossing"] = 566404199909,
				["Axxarien"] = 146340577536,
				["TheBloodwash"] = 29307961600,
				["TheVectorCoil"] = 255596083712,
				["WrathscaleLair"] = 363552047360,
				["Middenvale"] = 436373553408,
				["Nazzivian"] = 434054103296,
				["BristlelimbEnclave"] = 440806932736,
				["TheFoulPool"] = 146260885760,
				["TalonStand"] = 84441039104,
				["BloodWatch"] = 277483880704,
				["BlacksiltShore"] = 457599863296,
				["WyrmscarIsland"] = 88689869056,
				["TheLostFold"] = 505186294016,
				["BloodcurseIsle"] = 275678232815,
				["AmberwebPass"] = 66618654976,
				["TheWarpPiston"] = 31611683072,
				["RagefeatherRidge"] = 126132420864,
				["TelathionsCamp"] = 232117108864,
				["TheCrimsonReach"] = 93997760768,
				["Mystwood"] = 518941500672,
			},
			["EversongWoods"] = {
				["Zebwatha"] = 510608475264,
				["ThuronsLivery"] = 328056570112,
				["WestSanctum"] = 342830088320,
				["TheGoldenStrand"] = 445795005568,
				["GoldenboughPass"] = 503839850752,
				["RunestoneShandor"] = 530915178752,
				["StillwhisperPond"] = 337652220160,
				["RunestoneFalithas"] = 532972482816,
				["EastSanctum"] = 400988307712,
				["SilvermoonCity"] = 93877436928,
				["TranquilShore"] = 320200769792,
				["TorWatha"] = 338908513536,
				["SunstriderIsle"] = 5573706240,
				["TheLivingWood"] = 451507642496,
				["NorthSanctum"] = 320353861888,
				["TheScortchedGrove"] = 544654622976,
				["SatherilsHaven"] = 412656861440,
				["SunsailAnchorage"] = 434034049280,
				["ElrendarFalls"] = 429031424128,
				["RuinsofSilvermoon"] = 146351063296,
				["FarstriderRetreat"] = 386022899968,
				["FairbreezeVilliage"] = 414869356800,
				["DuskwitherGrounds"] = 272291332352,
			},
			["ShadowmoonValley"] = {
				["LegionHold"] = 166539559424,
				["NetherwingLedge"] = 478350114284,
				["TheHandofGuldan"] = 97050427904,
				["IlladarPoint"] = 275028115712,
				["WildhammerStronghold"] = 246063488512,
				["ShadowmoonVilliage"] = 37703123456,
				["NetherwingCliffs"] = 331293655296,
				["EclipsePoint"] = 333219994112,
				["TheDeathForge"] = 138817306880,
				["CoilskarPoint"] = 8955363840,
				["TheWardensCage"] = 277517593088,
				["TheBlackTemple"] = 135927431564,
				["AltarofShatar"] = 100403511552,
			},
			["TerokkarForest"] = {
				["BonechewerRuins"] = 295825572096,
				["RaastokGlade"] = 165886034176,
				["SkethylMountains"] = 374133293568,
				["StonebreakerHold"] = 177583948032,
				["CarrionHill"] = 292453351680,
				["AllerianStronghold"] = 297930064128,
				["GrangolvarVilliage"] = 183760060928,
				["RefugeCaravan"] = 288094421120,
				["FirewingPoint"] = 160635027841,
				["RazorthornShelf"] = 20902576384,
				["CenarionThicket"] = 329515264,
				["RingofObservance"] = 370766250240,
				["ShattrathCity"] = 4404544000,
				["VeilRhaze"] = 388927586560,
				["TheBoneWastes"] = 287998099968,
				["TheBarrierHills"] = 4416864512,
				["SethekkTomb"] = 310568550656,
				["BleedingHollowClanRuins"] = 323304668416,
				["Tuurem"] = 36984848640,
			},
			["Nagrand"] = {
				["LaughingSkullRuins"] = 56202887424,
				["ZangarRidge"] = 58272776448,
				["TwilightRidge"] = 114901385472,
				["Telaar"] = 419165372672,
				["KilsorrowFortress"] = 459073111296,
				["ForgeCampHate"] = 165526372608,
				["RingofTrials"] = 287248220416,
				["WindyreedVillage"] = 250880459008,
				["ClanWatch"] = 390326386944,
				["SouthwindCleft"] = 277435646208,
				["ForgeCampFear"] = 266326151680,
				["Garadar"] = 153997279488,
				["WarmaulHill"] = 34524627200,
				["Halaa"] = 207583707392,
				["BurningBladeRUins"] = 359322171648,
				["ThroneoftheElements"] = 57437061376,
				["SunspringPost"] = 213904523520,
				["OshuGun"] = 358806272512,
				["WindyreedPass"] = 85452914944,
			},
			['*'] = {}
		}
	})
	
	Cartographer.options.args.Foglight = {
		name = L["Foglight"],
		desc = L["Module to show unexplored areas on the map."],
		type = 'group',
		args = {
			color = {
				name = L["Unexplored color"],
				desc = L["Change the color of the unexplored areas"],
				type = "color",
				get = "GetDarkColor",
				set = "SetDarkColor",
				hasAlpha = true,
			},
			toggle = {
				name = AceLibrary("AceLocale-2.2"):new("Cartographer")["Active"],
				desc = AceLibrary("AceLocale-2.2"):new("Cartographer")["Suspend/resume this module."],
				type = "toggle",
				order = -1,
				get = function() return Cartographer:IsModuleActive(self) end,
				set = function() Cartographer:ToggleModuleActive(self) end
			},
		},
		handler = self,
	}
end

function Cartographer_Foglight:OnEnable()
	self.overlayInfo = self.db.account.errata
	self:Hook("GetNumMapOverlays", true)
	self:Hook("WorldMapFrame_Update", true)
	if WorldMapFrame:IsShown() then
		WorldMapFrame_Update()
	end
end

function Cartographer_Foglight:OnDisable()
	for i = 1, NUM_WORLDMAP_OVERLAYS do
		local texture = _G["WorldMapOverlay"..i]
		texture:Hide()
		texture:SetVertexColor(1.0,1.0,1.0)
		texture:SetAlpha(1.0)
	end
	if WorldMapFrame:IsShown() then
		WorldMapFrame_Update()
	end
end

function Cartographer_Foglight:GetNumMapOverlays()
	if NUM_WORLDMAP_OVERLAYS == 0 then
		return self.hooks.GetNumMapOverlays()
	end
	return 0
end

function Cartographer_Foglight:WorldMapFrame_Update()
	self.hooks.WorldMapFrame_Update()
	self:WorldMapFrame_UpdateOverlays()
end

local discovered = {}
function Cartographer_Foglight:WorldMapFrame_UpdateOverlays()
	if not WorldMapFrame:IsShown() then
		return
	end
	
	local mapFileName, textureHeight = GetMapInfo()
	if not mapFileName then
		return
	end
	
	local prefix = "Interface\\WorldMap\\"..mapFileName.."\\"
	local zoneTable = self.overlayInfo[mapFileName]
	
	local numOverlays = self.hooks.GetNumMapOverlays()
	local len = string.len(prefix)+1
	for i=1, numOverlays do
		local tname,tw,th,ofx,ofy = GetMapOverlayInfo(i)
		tname = string.sub(tname, len)
		local num = tw + th * 1024 + ofx * 1048576 + ofy * 1073741824
		discovered[tname] = num
		zoneTable[tname] = num
	end
	
	local textureCount = 0
	
	for tname, num in pairs(zoneTable) do
		local textureName = prefix .. tname
		local textureWidth, textureHeight, offsetX, offsetY = math_mod(num, 1024), math_mod(math_floor(num / 1024), 1024), math_mod(math_floor(num / 1048576), 1024), math_floor(num / 1073741824)
		
		-- HACK: override *known incorrect* data with hard-coded fixes.
		if textureName == "Interface\\WorldMap\\Tirisfal\\BRIGHTWATERLAKE" then
			if offsetX == 587 then
				offsetX = 584
			end
		end
		if textureName == "Interface\\WorldMap\\Silverpine\\BERENSPERIL" then
			if offsetY == 417 then
				offsetY = 415
			end
		end

		local numTexturesWide = math_ceil(textureWidth / 256)
		local numTexturesTall = math_ceil(textureHeight / 256)
		local neededTextures = textureCount + numTexturesWide*numTexturesTall
		if neededTextures > NUM_WORLDMAP_OVERLAYS then
			for j = NUM_WORLDMAP_OVERLAYS+1, neededTextures do
				WorldMapDetailFrame:CreateTexture("WorldMapOverlay"..j, "ARTWORK")
			end
			NUM_WORLDMAP_OVERLAYS = neededTextures
		end
		for j = 1, numTexturesTall do
			local texturePixelHeight
			local textureFileHeight
			if j < numTexturesTall then
				texturePixelHeight = 256
				textureFileHeight = 256
			else
				texturePixelHeight = math_mod(textureHeight, 256)
				if texturePixelHeight == 0 then
					texturePixelHeight = 256
				end
				textureFileHeight = 16
				while textureFileHeight < texturePixelHeight do
					textureFileHeight = textureFileHeight * 2
				end
			end
			for k = 1, numTexturesWide do
				if textureCount > NUM_WORLDMAP_OVERLAYS then
					return
				end
				textureCount = textureCount + 1
				local texture = _G["WorldMapOverlay"..textureCount]
				if k < numTexturesWide then
					texturePixelWidth = 256
					textureFileWidth = 256
				else
					texturePixelWidth = math_mod(textureWidth, 256)
					if texturePixelWidth == 0 then
						texturePixelWidth = 256
					end
					textureFileWidth = 16
					while textureFileWidth < texturePixelWidth do
						textureFileWidth = textureFileWidth * 2
					end
				end
				texture:SetWidth(texturePixelWidth)
				texture:SetHeight(texturePixelHeight)
				texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
				texture:ClearAllPoints()
				texture:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", offsetX + (256 * (k-1)), -(offsetY + (256 * (j - 1))))
				texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k))

				if discovered[tname] then
					texture:SetVertexColor(1.0,1.0,1.0)
					texture:SetAlpha(1.0)
				else
					texture:SetVertexColor(self.db.profile.darkR, self.db.profile.darkG, self.db.profile.darkB)
					texture:SetAlpha(self.db.profile.darkA)
				end
				texture:Show()
			end
		end
	end
	for i = textureCount+1, NUM_WORLDMAP_OVERLAYS do
		_G["WorldMapOverlay"..i]:Hide()
	end
	for k in pairs(discovered) do
		discovered[k] = nil
	end
end


function Cartographer_Foglight:GetDarkColor()
	return self.db.profile.darkR, self.db.profile.darkG, self.db.profile.darkB, self.db.profile.darkA
end

function Cartographer_Foglight:SetDarkColor(r,g,b,a)
	if WorldMapFrame:IsShown() and WorldMapFrame:GetFrameStrata() == "FULLSCREEN" then
		ToggleWorldMap()
	end
	self.db.profile.darkR, self.db.profile.darkG, self.db.profile.darkB, self.db.profile.darkA = r,g,b,a
	self:WorldMapFrame_UpdateOverlays()
end

function Cartographer_Foglight:OnProfileEnable()
	WorldMapFrame_Update()
end
