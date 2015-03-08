--[[
	MapNotes: Adds a note system to the WorldMap and other AddOns that use the Plugins facility provided

	See the README file for more information.
]]

MAPNOTES_VERSION = "3.00.20000";
MAPNOTES_EDITION = "Fan's Update";

-- Commands
MAPNOTES_ENABLE_COMMANDS = { "/mapnote", "/mapnotes", "/mn" };				
MAPNOTES_ONENOTE_COMMANDS = { "/onenote", "/allowonenote", "/aon", "/mn1" };		
MAPNOTES_MININOTE_COMMANDS = { "/nextmininote", "/nmn", "/mnmn" };			
MAPNOTES_MININOTEONLY_COMMANDS = { "/nextmininoteonly", "/nmno", "/mnmn1" };		
MAPNOTES_MININOTEOFF_COMMANDS = { "/mininoteoff", "/mno", "/mnmn0" };			
MAPNOTES_MNTLOC_COMMANDS = { "/mntloc" }
MAPNOTES_QUICKNOTE_COMMANDS = { "/quicknote", "/qnote", "/mnq" };			
MAPNOTES_QUICKTLOC_COMMANDS = { "/quicktloc", "/qtloc", "/mnqtloc" };
MAPNOTES_SEARCH_COMMANDS = { "/mnsearch", "/mns" };
MAPNOTES_HLIGHT_COMMANDS = { "/mnhighlight", "/mnhl" };
MAPNOTES_MINICOORDS_COMMANDS = { "/mnminic" };
MAPNOTES_MAPCOORDS_COMMANDS = { "/mnmapc" };
MAPNOTES_NTARGET_COMMANDS = { "/mnt" };
MAPNOTES_MTARGET_COMMANDS = { "/mnm" };
-- Import Commands
MAPNOTES_IMPORT_METAMAP = { "/MapNotes_Import_MetaMap" };				--Telic_4
MAPNOTES_IMPORT_ALPHAMAP = { "/MapNotes_Import_AlphaMap" };				--Telic_4
MAPNOTES_IMPORT_ALPHAMAPBG = { "/MapNotes_Import_AlphaMapBG" };				--Telic_4
MAPNOTES_IMPORT_CTMAPMOD = { "/MapNotes_Import_CTMapMod" };				--Telic_4


MapNotes_Mininote_UpdateRate = 0.01;	-- Telic_3   I think 0.03 would be sufficient and more efficient... (Was 0.01) (Bizzarre Minimap timer reset)
MapNotes_MinDiff = 7;
MAPNOTES_MAXLINES = 100;

MN_MISC_GFX_PATH = "Interface\\AddOns\\MapNotes\\MiscGFX";		-- Moved here as now also used in Utilities.lua
MN_POI_ICONS_PATH = "Interface\\AddOns\\MapNotes\\POIIcons";

MapNotes_Colors = {};
MapNotes_Colors[0] = {r = 1.0, g = 0.82, b = 0.0};
MapNotes_Colors[1] = {r = 0.55, g = 0.46, b = 0.04};
MapNotes_Colors[2] = {r = 0.87, g = 0.06, b = 0.0};
MapNotes_Colors[3] = {r = 0.56, g = 0.0, b = 0.0};
MapNotes_Colors[4] = {r = 0.18, g = 0.7, b = 0.2};
MapNotes_Colors[5] = {r = 0.0, g = 0.39, b = 0.05};
MapNotes_Colors[6] = {r = 0.42, g = 0.47, b = 0.87};
MapNotes_Colors[7] = {r = 0.25, g = 0.35, b = 0.66};
MapNotes_Colors[8] = {r = 1.0, g = 1.0, b = 1.0};
MapNotes_Colors[9] = {r = 0.65, g = 0.65, b = 0.65};



-- Do NOT Localise any names in this array --

MAPNOTES_BASEKEYS = {
	["WM LochModan"] = {
		["miniData"] = {
			["scale"] = 0.07839152145224,
			["xoffset"] = 0.51118749188138,
			["yoffset"] = 0.50940913489577,
		},
	},
	["WM BurningSteppes"] = {
		["miniData"] = {
			["scale"] = 0.08321525646393001,
			["xoffset"] = 0.04621224670174,
			["yoffset"] = 0.61780780524905,
		},
	},
	["WM Moonglade"] = {
		["miniData"] = {
			["scale"] = 0.06292695969921,
			["xoffset"] = 0.50130287793373,
			["yoffset"] = 0.17560823085517,
		},
	},
	["WM Barrens"] = {
		["miniData"] = {
			["scale"] = 0.27539211944292,
			["xoffset"] = 0.3924934733345,
			["yoffset"] = 0.45601063260257,
		},
	},
	["WM Winterspring"] = {
		["miniData"] = {
			["scale"] = 0.19293573573141,
			["xoffset"] = 0.47237382938446,
			["yoffset"] = 0.17390990272233,
		},
	},
	["WM Ogrimmar"] = {
		["miniData"] = {
			["scale"] = 0.03811449638057,
			["xoffset"] = 0.56378554142668,
			["yoffset"] = 0.42905218646258,
		},
	},
	["WM Westfall"] = {
		["miniData"] = {
			["scale"] = 0.09943208435841,
			["xoffset"] = 0.36884571674582,
			["yoffset"] = 0.71874918595783,
		},
	},
	["WM Badlands"] = {
		["miniData"] = {
			["scale"] = 0.07066771883566,
			["xoffset"] = 0.51361415033147,
			["yoffset"] = 0.56915717993261,
		},
	},
	["WM Darkshore"] = {
		["miniData"] = {
			["scale"] = 0.17799008894522,
			["xoffset"] = 0.38383175154516,
			["yoffset"] = 0.18206216123156,
		},
	},
	["WM Undercity"] = {
		["miniData"] = {
			["scale"] = 0.02727719546939,
			["xoffset"] = 0.4297399924566,
			["yoffset"] = 0.23815358517831,
		},
	},
	["WM Desolace"] = {
		["miniData"] = {
			["scale"] = 0.12219839120669,
			["xoffset"] = 0.34873187115693,
			["yoffset"] = 0.50331046935371,
		},
	},
	["WM Tanaris"] = {
		["miniData"] = {
			["scale"] = 0.18750104661175,
			["xoffset"] = 0.46971301480866,
			["yoffset"] = 0.76120931364891,
		},
	},
	["WM Durotar"] = {
		["miniData"] = {
			["scale"] = 0.1436829497008,
			["xoffset"] = 0.5170978270910001,
			["yoffset"] = 0.44802818134926,
		},
	},
	["WM Silithus"] = {
		["miniData"] = {
			["scale"] = 0.18885969712845,
			["xoffset"] = 0.33763582469211,
			["yoffset"] = 0.7581522495192899,
		},
	},
	["WM SwampOfSorrows"] = {
		["miniData"] = {
			["scale"] = 0.06516347991404001,
			["xoffset"] = 0.5176979527207,
			["yoffset"] = 0.7281597470161501,
		},
	},
	["WM StonetalonMountains"] = {
		["miniData"] = {
			["scale"] = 0.13272833611061,
			["xoffset"] = 0.37556627748617,
			["yoffset"] = 0.40285135292988,
		},
	},
	["WM Darnassis"] = {
		["miniData"] = {
			["scale"] = 0.02876626176374,
			["xoffset"] = 0.38392150175204,
			["yoffset"] = 0.10441296545475,
		},
	},
	["WM Alterac"] = {
		["miniData"] = {
			["scale"] = 0.07954563533736,
			["xoffset"] = 0.43229874660542,
			["yoffset"] = 0.25425926375262,
		},
	},
	["WM SearingGorge"] = {
		["miniData"] = {
			["scale"] = 0.06338794005822999,
			["xoffset"] = 0.46372051266487,
			["yoffset"] = 0.5781237938250901,
		},
	},
	["WM AlteracValley"] = {
		["miniData"] = {
			["scale"] = 0.13,
			["xoffset"] = 0.41757282062541,
			["yoffset"] = 0.33126468682991,
		},
	},
	["WM Hilsbrad"] = {
		["miniData"] = {
			["scale"] = 0.09090931690055,
			["xoffset"] = 0.4242436124746,
			["yoffset"] = 0.30113436864162,
		},
	},
	["WM Wetlands"] = {
		["miniData"] = {
			["scale"] = 0.11745423014662,
			["xoffset"] = 0.46561438951659,
			["yoffset"] = 0.40971063365152,
		},
	},
	["WM Duskwood"] = {
		["miniData"] = {
			["scale"] = 0.07670475476181,
			["xoffset"] = 0.43087243362495,
			["yoffset"] = 0.73224350550454,
		},
	},
	["WM ThousandNeedles"] = {
		["miniData"] = {
			["scale"] = 0.1195658287792,
			["xoffset"] = 0.47554411191734,
			["yoffset"] = 0.6834235638965001,
		},
	},
	["WM WesternPlaguelands"] = {
		["miniData"] = {
			["scale"] = 0.12215946583965,
			["xoffset"] = 0.44270955019641,
			["yoffset"] = 0.17471356786018,
		},
	},
	["WM Ashenvale"] = {
		["miniData"] = {
			["scale"] = 0.15670371525706,
			["xoffset"] = 0.41757282062541,
			["yoffset"] = 0.33126468682991,
		},
	},
	["WM Teldrassil"] = {
		["miniData"] = {
			["scale"] = 0.13836131003639,
			["xoffset"] = 0.36011098024729,
			["yoffset"] = 0.0394832297921,
		},
	},
	["WM Tirisfal"] = {
		["miniData"] = {
			["scale"] = 0.12837403412087,
			["xoffset"] = 0.36837217317549,
			["yoffset"] = 0.15464954319582,
		},
	},
	["WM Mulgore"] = {
		["miniData"] = {
			["scale"] = 0.13960673216274,
			["xoffset"] = 0.40811854919226,
			["yoffset"] = 0.53286226907346,
		},
	},
	["WM Ironforge"] = {
		["miniData"] = {
			["scale"] = 0.02248317426784,
			["xoffset"] = 0.47481923366335,
			["yoffset"] = 0.51289242617182,
		},
	},
	["WM Felwood"] = {
		["miniData"] = {
			["scale"] = 0.15625084006464,
			["xoffset"] = 0.41995800144849,
			["yoffset"] = 0.23097545880609,
		},
	},
	["WM Silverpine"] = {
		["miniData"] = {
			["scale"] = 0.11931848806212,
			["xoffset"] = 0.3565350229009,
			["yoffset"] = 0.24715695496522,
		},
	},
	["WM Aszhara"] = {
		["miniData"] = {
			["scale"] = 0.13779501505279,
			["xoffset"] = 0.5528203691804901,
			["yoffset"] = 0.30400571307545,
		},
	},
	["WM Hinterlands"] = {
		["miniData"] = {
			["scale"] = 0.10937523495111,
			["xoffset"] = 0.49929119700867,
			["yoffset"] = 0.25567971676068,
		},
	},
	["WM ArathiBasin"] = {
		["miniData"] = {
			["scale"] = 0.045,
			["xoffset"] = 0.41757282062541,
			["yoffset"] = 0.33126468682991,
		},
	},
	["WM UngoroCrater"] = {
		["miniData"] = {
			["scale"] = 0.10054401185671,
			["xoffset"] = 0.4492759445152,
			["yoffset"] = 0.7649457362940501,
		},
	},
	["WM Stormwind"] = {
		["miniData"] = {
			["scale"] = 0.03819701270887,
			["xoffset"] = 0.41531450060561,
			["yoffset"] = 0.67097280492581,
		},
	},
	["WM Elwynn"] = {
		["miniData"] = {
			["scale"] = 0.09860350595046,
			["xoffset"] = 0.41092682316676,
			["yoffset"] = 0.65651531970162,
		},
	},
	["WM Redridge"] = {
		["miniData"] = {
			["scale"] = 0.06170112311456,
			["xoffset"] = 0.49917278340928,
			["yoffset"] = 0.68359285304999,
		},
	},
	["WM EasternPlaguelands"] = {
		["miniData"] = {
			["scale"] = 0.10996723642661,
			["xoffset"] = 0.51663255550387,
			["yoffset"] = 0.15624753972085,
		},
	},
	["WM DunMorogh"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		},
	},
	["WM DeadwindPass"] = {
		["miniData"] = {
			["scale"] = 0.07102298961531001,
			["xoffset"] = 0.47822105868635,
			["yoffset"] = 0.7386355504851601,
		},
	},
	["WM Feralas"] = {
		["miniData"] = {
			["scale"] = 0.18885970960818,
			["xoffset"] = 0.31589651244686,
			["yoffset"] = 0.61820581746798,
		},
	},
	["WM BlastedLands"] = {
		["miniData"] = {
			["scale"] = 0.09517074521836,
			["xoffset"] = 0.48982154167011,
			["yoffset"] = 0.7684651998651,
		},
	},
	["WM WarsongGulch"] = {
		["miniData"] = {
			["scale"] = 0.035,
			["xoffset"] = 0.41757282062541,
			["yoffset"] = 0.33126468682991,
		},
	},
	["WM Arathi"] = {
		["miniData"] = {
			["scale"] = 0.10227310921644,
			["xoffset"] = 0.47916793249546,
			["yoffset"] = 0.32386170078419,
		},
	},
	["WM Dustwallow"] = {
		["miniData"] = {
			["scale"] = 0.14266384095509,
			["xoffset"] = 0.49026338351379,
			["yoffset"] = 0.60461876174686,
		},
	},
	["WM Stranglethorn"] = {
		["miniData"] = {
			["scale"] = 0.18128603034401,
			["xoffset"] = 0.39145470225916,
			["yoffset"] = 0.79412224886668,
		},
	},
	["WM ThunderBluff"] = {
		["miniData"] = {
			["scale"] = 0.02836291430658,
			["xoffset"] = 0.44972878210917,
			["yoffset"] = 0.55638479002362,
		}
	},
	["WM ShattrathCity"] = {
		["miniData"] = {
			["scale"] = 0.03811449638057,
			["xoffset"] = 0.56378554142668,
			["yoffset"] = 0.42905218646258,
		}
	},
	["WM EversongWoods"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM Zangarmarsh"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM Nagrand"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM Netherstorm"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM BloodmystIsle"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM Hellfire"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM TheExodar"] = {
		["miniData"] = {
			["scale"] = 0.03811449638057,
			["xoffset"] = 0.56378554142668,
			["yoffset"] = 0.42905218646258,
		}
	},
	["WM ShadowmoonValley"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM TerokkarForest"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM Ghostlands"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM BladesEdgeMountains"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM AzuremystIsle"] = {
		["miniData"] = {
			["scale"] = 0.13991525534426,
			["xoffset"] = 0.40335096278072,
			["yoffset"] = 0.48339696712179,
		}
	},
	["WM SilvermoonCity"] = {
		["miniData"] = {
			["scale"] = 0.03811449638057,
			["xoffset"] = 0.56378554142668,
			["yoffset"] = 0.42905218646258,
		}
	},
};

MapNotes_CityConst = {
	[0] = {
		["cityscale"] = 1.565,
	},
	[1] = {
		["cityscale"] = 1.687,
	},
	[2] = {
		["cityscale"] = 1.882,
	},
	[3] = {
		["cityscale"] = 2.210,
	},
	[4] = {
		["cityscale"] = 2.575,
	},
	[5] = {
		["cityscale"] = 2.651,
	}
};

MapNotes_MiniConst = {};
MapNotes_MiniConst[1] = {};
MapNotes_MiniConst[2] = {};
MapNotes_MiniConst = {
	[1] = {
		[0] = {
			["xscale"] = 11016.6,
			["yscale"] = 7399.9,
		},
		[1] = {
			["xscale"] = 12897.3,
			["yscale"] = 8638.1,
		},
		[2] = {
			["xscale"] = 15478.8,
			["yscale"] = 10368.0,
		},
		[3] = {
			["xscale"] = 19321.8,
			["yscale"] = 12992.7,
		},
		[4] = {
			["xscale"] = 25650.4,
			["yscale"] = 17253.2,
		},
		[5] = {
			["xscale"] = 38787.7,
			["yscale"] = 26032.1,
		}
	},
	[2] = {
		[0] = {
			["xscale"] = 10448.3,
			["yscale"] = 7072.7,
		},
		[1] = {
			["xscale"] = 12160.5,
			["yscale"] = 8197.8,
		},
		[2] = {
			["xscale"] = 14703.1,
			["yscale"] = 9825.0,
		},
		[3] = {
			["xscale"] = 18568.7,
			["yscale"] = 12472.2,
		},
		[4] = {
			["xscale"] = 24390.3,
			["yscale"] = 15628.5,
		},
		[5] = {
			["xscale"] = 37012.2,
			["yscale"] = 25130.6,
		}
	},
	[3] = {
		[0] = {
			["xscale"] = 10448.3,
			["yscale"] = 7072.7,
		},
		[1] = {
			["xscale"] = 12160.5,
			["yscale"] = 8197.8,
		},
		[2] = {
			["xscale"] = 14703.1,
			["yscale"] = 9825.0,
		},
		[3] = {
			["xscale"] = 18568.7,
			["yscale"] = 12472.2,
		},
		[4] = {
			["xscale"] = 24390.3,
			["yscale"] = 15628.5,
		},
		[5] = {
			["xscale"] = 37012.2,
			["yscale"] = 25130.6,
		}
	},
};

MAPNOTES_DEFAULT_MINIDATA = {
			["scale"] = 0.15,
			["xoffset"] = 0.4,
			["yoffset"] = 0.4,
};