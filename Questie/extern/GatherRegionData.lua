--[[

	Cartography data for Gatherer
	Revision: $Id: GatherRegionData.lua 275 2006-08-27 09:21:38Z islorgris $

]]


--The following (and more inside) ripped mercilessly from MapNotes:


-- Common part
GatherRegionData = { };
GatherRegionData.cityZoom    = { };
GatherRegionData.cityZoom[0] = 1.565;
GatherRegionData.cityZoom[1] = 1.687;
GatherRegionData.cityZoom[2] = 1.882;
GatherRegionData.cityZoom[3] = 2.210;
GatherRegionData.cityZoom[4] = 2.575;
GatherRegionData.cityZoom[5] = 2.651;
GatherRegionData[1]           = { scales={} };
GatherRegionData[1].scales[0] = { xscale = 11016.6, yscale = 7399.9 };
GatherRegionData[1].scales[1] = { xscale = 12897.3, yscale = 8638.1 };
GatherRegionData[1].scales[2] = { xscale = 15478.8, yscale = 10368.0 };
GatherRegionData[1].scales[3] = { xscale = 19321.8, yscale = 12992.7 };
GatherRegionData[1].scales[4] = { xscale = 25650.4, yscale = 17253.2 };
GatherRegionData[1].scales[5] = { xscale = 38787.7, yscale = 26032.1 };
GatherRegionData[2]           = { scales={} };
GatherRegionData[2].scales[0] = { xscale = 10448.3, yscale = 7072.7 };
GatherRegionData[2].scales[1] = { xscale = 12160.5, yscale = 8197.8 };
GatherRegionData[2].scales[2] = { xscale = 14703.1, yscale = 9825.0 };
GatherRegionData[2].scales[3] = { xscale = 18568.7, yscale = 12472.2 };
GatherRegionData[2].scales[4] = { xscale = 24390.3, yscale = 15628.5 };
GatherRegionData[2].scales[5] = { xscale = 37012.2, yscale = 25130.6 };

-- table modified for french locale
if ( GetLocale() == "frFR" ) then -- 1.8.0 WoW patch values

	GatherRegionData[1][0]  = { name = "Kalimdor" };
	GatherRegionData[1][1]  = { scale = 0.15670371525706, xoffset = 0.41757282062541, yoffset = 0.33126468682991, name = "Ashenvale" };
	GatherRegionData[1][2]  = { scale = 0.13779501505279, xoffset = 0.55282036918049, yoffset = 0.30400571307545, name = "Aszhara" };
	GatherRegionData[1][3]  = { scale = 0.19293573573141, xoffset = 0.47237382938446, yoffset = 0.17390990272233, name = "Winterspring" };
	GatherRegionData[1][4]  = { scale = 0.10054401185671, xoffset = 0.44927594451520, yoffset = 0.76494573629405, name = "UngoroCrater" };
	GatherRegionData[1][5]  = { scale = 0.02876626176374, xoffset = 0.38392150175204, yoffset = 0.10441296545475, name = "Darnassis" };
	GatherRegionData[1][6]  = { scale = 0.14368294970080, xoffset = 0.51709782709100, yoffset = 0.44802818134926, name = "Durotar" };
	GatherRegionData[1][7]  = { scale = 0.12219839120669, xoffset = 0.34873187115693, yoffset = 0.50331046935371, name = "Desolace" };
	GatherRegionData[1][8]  = { scale = 0.18885970960818, xoffset = 0.31589651244686, yoffset = 0.61820581746798, name = "Feralas" };
	GatherRegionData[1][9]  = { scale = 0.15625084006464, xoffset = 0.41995800144849, yoffset = 0.23097545880609, name = "Felwood" };
	GatherRegionData[1][10] = { scale = 0.13272833611061, xoffset = 0.37556627748617, yoffset = 0.40285135292988, name = "StonetalonMountains" };
	GatherRegionData[1][11] = { scale = 0.27539211944292, xoffset = 0.39249347333450, yoffset = 0.45601063260257, name = "Barrens" };
	GatherRegionData[1][12] = { scale = 0.14266384095509, xoffset = 0.49026338351379, yoffset = 0.60461876174686, name = "Dustwallow" };
	GatherRegionData[1][13] = { scale = 0.11956582877920, xoffset = 0.47554411191734, yoffset = 0.68342356389650, name = "ThousandNeedles" };
	GatherRegionData[1][14] = { scale = 0.13960673216274, xoffset = 0.40811854919226, yoffset = 0.53286226907346, name = "Mulgore" };
	GatherRegionData[1][15] = { scale = 0.03811449638057, xoffset = 0.56378554142668, yoffset = 0.42905218646258, name = "Ogrimmar" };
	GatherRegionData[1][16] = { scale = 0.06292695969921, xoffset = 0.50130287793373, yoffset = 0.17560823085517, name = "Moonglade" };
	GatherRegionData[1][17] = { scale = 0.09468465888932, xoffset = 0.39731975488374, yoffset = 0.76460608512626, name = "Silithus" };
	GatherRegionData[1][18] = { scale = 0.17799008894522, xoffset = 0.38383175154516, yoffset = 0.18206216123156, name = "Darkshore" };
	GatherRegionData[1][19] = { scale = 0.18750104661175, xoffset = 0.46971301480866, yoffset = 0.76120931364891, name = "Tanaris" };
	GatherRegionData[1][20] = { scale = 0.13836131003639, xoffset = 0.36011098024729, yoffset = 0.03948322979210, name = "Teldrassil" };
	GatherRegionData[1][21] = { scale = 0.02836291430658, xoffset = 0.44972878210917, yoffset = 0.55638479002362, name = "ThunderBluff" };
	GatherRegionData[2][0]  = { name = "Azeroth" };
	GatherRegionData[2][1]  = { scale = 0.07670475476181, xoffset = 0.43087243362495, yoffset = 0.73224350550454, name = "Duskwood" };
	GatherRegionData[2][2]  = { scale = 0.03819701270887, xoffset = 0.41531450060561, yoffset = 0.67097280492581, name = "Stormwind" };
	GatherRegionData[2][3]  = { scale = 0.12837403412087, xoffset = 0.36837217317549, yoffset = 0.15464954319582, name = "Tirisfal" };
	GatherRegionData[2][4]  = { scale = 0.09090931690055, xoffset = 0.42424361247460, yoffset = 0.30113436864162, name = "Hilsbrad" };
	GatherRegionData[2][5]  = { scale = 0.13991525534426, xoffset = 0.40335096278072, yoffset = 0.48339696712179, name = "DunMorogh" };
	GatherRegionData[2][6]  = { scale = 0.07102298961531, xoffset = 0.47822105868635, yoffset = 0.73863555048516, name = "DeadwindPass" };
	GatherRegionData[2][7]  = { scale = 0.09860350595046, xoffset = 0.41092682316676, yoffset = 0.65651531970162, name = "Elwynn" };
	GatherRegionData[2][8]  = { scale = 0.11931848806212, xoffset = 0.35653502290090, yoffset = 0.24715695496522, name = "Silverpine" };
	GatherRegionData[2][9]  = { scale = 0.06338794005823, xoffset = 0.46372051266487, yoffset = 0.57812379382509, name = "SearingGorge" };
	GatherRegionData[2][10] = { scale = 0.10227310921644, xoffset = 0.47916793249546, yoffset = 0.32386170078419, name = "Arathi" };
	GatherRegionData[2][11] = { scale = 0.02248317426784, xoffset = 0.47481923366335, yoffset = 0.51289242617182, name = "Ironforge" };
	GatherRegionData[2][12] = { scale = 0.06170112311456, xoffset = 0.49917278340928, yoffset = 0.68359285304999, name = "Redridge" };
	GatherRegionData[2][13] = { scale = 0.10937523495111, xoffset = 0.49929119700867, yoffset = 0.25567971676068, name = "Hinterlands" };
	GatherRegionData[2][14] = { scale = 0.11745423014662, xoffset = 0.46561438951659, yoffset = 0.40971063365152, name = "Wetlands" };
	GatherRegionData[2][15] = { scale = 0.07839152145224, xoffset = 0.51118749188138, yoffset = 0.50940913489577, name = "LochModan" };
	GatherRegionData[2][16] = { scale = 0.10996723642661, xoffset = 0.51663255550387, yoffset = 0.15624753972085, name = "EasternPlaguelands" };
	GatherRegionData[2][17] = { scale = 0.12215946583965, xoffset = 0.44270955019641, yoffset = 0.17471356786018, name = "WesternPlaguelands" };
	GatherRegionData[2][18] = { scale = 0.06516347991404, xoffset = 0.51769795272070, yoffset = 0.72815974701615, name = "SwampOfSorrows" };
	GatherRegionData[2][19] = { scale = 0.09943208435841, xoffset = 0.36884571674582, yoffset = 0.71874918595783, name = "Westfall" };
	GatherRegionData[2][20] = { scale = 0.07954563533736, xoffset = 0.43229874660542, yoffset = 0.25425926375262, name = "Alterac" };
	GatherRegionData[2][21] = { scale = 0.08321525646393, xoffset = 0.04621224670174, yoffset = 0.61780780524905, name = "BurningSteppes" };
	GatherRegionData[2][22] = { scale = 0.09517074521836, xoffset = 0.48982154167011, yoffset = 0.76846519986510, name = "BlastedLands" };
	GatherRegionData[2][23] = { scale = 0.07066771883566, xoffset = 0.51361415033147, yoffset = 0.56915717993261, name = "Badlands" };
	GatherRegionData[2][24] = { scale = 0.02727719546939, xoffset = 0.42973999245660, yoffset = 0.23815358517831, name = "Undercity" };
	GatherRegionData[2][25] = { scale = 0.18128603034401, xoffset = 0.39145470225916, yoffset = 0.79412224886668, name = "Stranglethorn" };

-- table modified for german locale
elseif ( GetLocale() == "deDE" ) then -- Jodo Change / 1.11 WoW Patch values

	GatherRegionData[1][0] = { name = "Kalimdor" };
	GatherRegionData[1][1] = { scale = 0.15670371525706, xoffset = 0.41757282062541, yoffset = 0.33126468682991, name = "Ashenvale" };
	GatherRegionData[1][2] = { scale = 0.13779501505279, xoffset = 0.55282036918049, yoffset = 0.30400571307545, name = "Azshara" };
	GatherRegionData[1][3] = { scale = 0.27539211944292, xoffset = 0.39249347333450, yoffset = 0.45601063260257, name = "Brachland" };
	GatherRegionData[1][4] = { scale = 0.02876626176374, xoffset = 0.38392150175204, yoffset = 0.10441296545475, name = "Darnassus" };
	GatherRegionData[1][5] = { scale = 0.12219839120669, xoffset = 0.34873187115693, yoffset = 0.50331046935371, name = "Desolace" };
	GatherRegionData[1][6] = { scale = 0.17799008894522, xoffset = 0.38383175154516, yoffset = 0.18206216123156, name = "Dunkelk\195\188ste" };
	GatherRegionData[1][7] = { scale = 0.14368294970080, xoffset = 0.51709782709100, yoffset = 0.44802818134926, name = "Durotar" };
	GatherRegionData[1][8] = { scale = 0.18885970960818, xoffset = 0.31589651244686, yoffset = 0.61820581746798, name = "Feralas" };
	GatherRegionData[1][9] = { scale = 0.14266384095509, xoffset = 0.49026338351379, yoffset = 0.60461876174686, name = "Marschen von Dustwallow" };
	GatherRegionData[1][10] = { scale = 0.06292695969921, xoffset = 0.50130287793373, yoffset = 0.17560823085517, name = "Moonglade" };
	GatherRegionData[1][11] = { scale = 0.13960673216274, xoffset = 0.40811854919226, yoffset = 0.53286226907346, name = "Mulgore" };
	GatherRegionData[1][12] = { scale = 0.03811449638057, xoffset = 0.56378554142668, yoffset = 0.42905218646258, name = "Orgrimmar" };
	GatherRegionData[1][13] = { scale = 0.09468465888932, xoffset = 0.39731975488374, yoffset = 0.76460608512626, name = "Silithus" };
	GatherRegionData[1][14] = { scale = 0.13272833611061, xoffset = 0.37556627748617, yoffset = 0.40285135292988, name = "Steinkrallengebirge" };
	GatherRegionData[1][15] = { scale = 0.18750104661175, xoffset = 0.46971301480866, yoffset = 0.76120931364891, name = "Tanaris" };
	GatherRegionData[1][16] = { scale = 0.11956582877920, xoffset = 0.47554411191734, yoffset = 0.68342356389650, name = "Tausend Nadeln" };
	GatherRegionData[1][17] = { scale = 0.13836131003639, xoffset = 0.36011098024729, yoffset = 0.03948322979210, name = "Teldrassil" };
	GatherRegionData[1][18] = { scale = 0.15625084006464, xoffset = 0.41995800144849, yoffset = 0.23097545880609, name = "Teufelswald" };
	GatherRegionData[1][19] = { scale = 0.02836291430658, xoffset = 0.44972878210917, yoffset = 0.55638479002362, name = "Thunder Bluff" };
	GatherRegionData[1][20] = { scale = 0.10054401185671, xoffset = 0.44927594451520, yoffset = 0.76494573629405, name = "Un'Goro-Krater" };
	GatherRegionData[1][21] = { scale = 0.19293573573141, xoffset = 0.47237382938446, yoffset = 0.17390990272233, name = "Winterspring" };
	GatherRegionData[2][0] = { name = "Die \195\182stlichen K\195\182nigreiche" };
	GatherRegionData[2][1] = { scale = 0.07954563533736, xoffset = 0.43229874660542, yoffset = 0.25425926375262, name = "Alteracgebirge" };
	GatherRegionData[2][2] = { scale = 0.10227310921644, xoffset = 0.47916793249546, yoffset = 0.32386170078419, name = "Arathihochland" };
	GatherRegionData[2][3] = { scale = 0.08321525646393, xoffset = 0.04621224670174, yoffset = 0.61780780524905, name = "Brennende Steppe" };
	GatherRegionData[2][4] = { scale = 0.13991525534426, xoffset = 0.40335096278072, yoffset = 0.48339696712179, name = "Dun Morogh" };
	GatherRegionData[2][5] = { scale = 0.07670475476181, xoffset = 0.43087243362495, yoffset = 0.73224350550454, name = "D\195\164mmerwald" };
	GatherRegionData[2][6] = { scale = 0.07102298961531, xoffset = 0.47822105868635, yoffset = 0.73863555048516, name = "Gebirgspass der Totenwinde" };
	GatherRegionData[2][7] = { scale = 0.10937523495111, xoffset = 0.49929119700867, yoffset = 0.25567971676068, name = "Hinterland" };
	GatherRegionData[2][8] = { scale = 0.02248317426784, xoffset = 0.47481923366335, yoffset = 0.51289242617182, name = "Ironforge" };
	GatherRegionData[2][9] = { scale = 0.07839152145224, xoffset = 0.51118749188138, yoffset = 0.50940913489577, name = "Loch Modan" };
	GatherRegionData[2][10] = { scale = 0.06170112311456, xoffset = 0.49917278340928, yoffset = 0.68359285304999, name = "Rotkammgebirge" };
	GatherRegionData[2][11] = { scale = 0.18128603034401, xoffset = 0.39145470225916, yoffset = 0.79412224886668, name = "Schlingendorntal" };
	GatherRegionData[2][12] = { scale = 0.06338794005823, xoffset = 0.46372051266487, yoffset = 0.57812379382509, name = "Sengende Schlucht" };
	GatherRegionData[2][13] = { scale = 0.11931848806212, xoffset = 0.35653502290090, yoffset = 0.24715695496522, name = "Silderwald" };
	GatherRegionData[2][14] = { scale = 0.03819701270887, xoffset = 0.41531450060561, yoffset = 0.67097280492581, name = "Stormwind" };
	GatherRegionData[2][15] = { scale = 0.11745423014662, xoffset = 0.46561438951659, yoffset = 0.40971063365152, name = "Sumpfland" };
	GatherRegionData[2][16] = { scale = 0.06516347991404, xoffset = 0.51769795272070, yoffset = 0.72815974701615, name = "S\195\188mpfe des Elends" };
	GatherRegionData[2][17] = { scale = 0.12837403412087, xoffset = 0.36837217317549, yoffset = 0.15464954319582, name = "Tirisfal" };
	GatherRegionData[2][18] = { scale = 0.02727719546939, xoffset = 0.42973999245660, yoffset = 0.23815358517831, name = "Undercity" };
	GatherRegionData[2][19] = { scale = 0.09517074521836, xoffset = 0.48982154167011, yoffset = 0.76846519986510, name = "Verw\195\188steten Lande" };
	GatherRegionData[2][20] = { scale = 0.09090931690055, xoffset = 0.42424361247460, yoffset = 0.30113436864162, name = "Vorgebirge von Hillsbrad" };
	GatherRegionData[2][21] = { scale = 0.09860350595046, xoffset = 0.41092682316676, yoffset = 0.65651531970162, name = "Wald von Elwynn" };
	GatherRegionData[2][22] = { scale = 0.09943208435841, xoffset = 0.36884571674582, yoffset = 0.71874918595783, name = "Westfall" };
	GatherRegionData[2][23] = { scale = 0.12215946583965, xoffset = 0.44270955019641, yoffset = 0.17471356786018, name = "Westliche Pestl\195\164nder" };
	GatherRegionData[2][24] = { scale = 0.07066771883566, xoffset = 0.51361415033147, yoffset = 0.56915717993261, name = "\195\150dland" };
	GatherRegionData[2][25] = { scale = 0.10996723642661, xoffset = 0.51663255550387, yoffset = 0.15624753972085, name = "\195\150stliche Pestl\195\164nder" };

-- english/US locale
else

	GatherRegionData[1][0]  = { name = "Kalimdor" };
	GatherRegionData[1][1]  = { scale = 0.15670371525706, xoffset = 0.41757282062541, yoffset = 0.33126468682991, name = "Ashenvale" };
	GatherRegionData[1][2]  = { scale = 0.13779501505279, xoffset = 0.55282036918049, yoffset = 0.30400571307545, name = "Aszhara" };
	GatherRegionData[1][3]  = { scale = 0.17799008894522, xoffset = 0.38383175154516, yoffset = 0.18206216123156, name = "Darkshore" };
	GatherRegionData[1][4]  = { scale = 0.02876626176374, xoffset = 0.38392150175204, yoffset = 0.10441296545475, name = "Darnassis" };
	GatherRegionData[1][5]  = { scale = 0.12219839120669, xoffset = 0.34873187115693, yoffset = 0.50331046935371, name = "Desolace" };
	GatherRegionData[1][6]  = { scale = 0.14368294970080, xoffset = 0.51709782709100, yoffset = 0.44802818134926, name = "Durotar" };
	GatherRegionData[1][7]  = { scale = 0.14266384095509, xoffset = 0.49026338351379, yoffset = 0.60461876174686, name = "Dustwallow" };
	GatherRegionData[1][8]  = { scale = 0.15625084006464, xoffset = 0.41995800144849, yoffset = 0.23097545880609, name = "Felwood" };
	GatherRegionData[1][9]  = { scale = 0.18885970960818, xoffset = 0.31589651244686, yoffset = 0.61820581746798, name = "Feralas" };
	GatherRegionData[1][10] = { scale = 0.06292695969921, xoffset = 0.50130287793373, yoffset = 0.17560823085517, name = "Moonglade" };
	GatherRegionData[1][11] = { scale = 0.13960673216274, xoffset = 0.40811854919226, yoffset = 0.53286226907346, name = "Mulgore" };
	GatherRegionData[1][12] = { scale = 0.03811449638057, xoffset = 0.56378554142668, yoffset = 0.42905218646258, name = "Ogrimmar" };
	GatherRegionData[1][13] = { scale = 0.09468465888932, xoffset = 0.39731975488374, yoffset = 0.76460608512626, name = "Silithus" };
	GatherRegionData[1][14] = { scale = 0.13272833611061, xoffset = 0.37556627748617, yoffset = 0.40285135292988, name = "StonetalonMountains" };
	GatherRegionData[1][15] = { scale = 0.18750104661175, xoffset = 0.46971301480866, yoffset = 0.76120931364891, name = "Tanaris" };
	GatherRegionData[1][16] = { scale = 0.13836131003639, xoffset = 0.36011098024729, yoffset = 0.03948322979210, name = "Teldrassil" };
	GatherRegionData[1][17] = { scale = 0.27539211944292, xoffset = 0.39249347333450, yoffset = 0.45601063260257, name = "Barrens" };
	GatherRegionData[1][18] = { scale = 0.11956582877920, xoffset = 0.47554411191734, yoffset = 0.68342356389650, name = "ThousandNeedles" };
	GatherRegionData[1][19] = { scale = 0.02836291430658, xoffset = 0.44972878210917, yoffset = 0.55638479002362, name = "ThunderBluff" };
	GatherRegionData[1][20] = { scale = 0.10054401185671, xoffset = 0.44927594451520, yoffset = 0.76494573629405, name = "UngoroCrater" };
	GatherRegionData[1][21] = { scale = 0.19293573573141, xoffset = 0.47237382938446, yoffset = 0.17390990272233, name = "Winterspring" };
	GatherRegionData[2][0]  = { name = "Azeroth" };
	GatherRegionData[2][1]  = { scale = 0.07954563533736, xoffset = 0.43229874660542, yoffset = 0.25425926375262, name = "Alterac" };
	GatherRegionData[2][2]  = { scale = 0.10227310921644, xoffset = 0.47916793249546, yoffset = 0.32386170078419, name = "Arathi" };
	GatherRegionData[2][3]  = { scale = 0.07066771883566, xoffset = 0.51361415033147, yoffset = 0.56915717993261, name = "Badlands" };
	GatherRegionData[2][4]  = { scale = 0.09517074521836, xoffset = 0.48982154167011, yoffset = 0.76846519986510, name = "BlastedLands" };
	GatherRegionData[2][5]  = { scale = 0.08321525646393, xoffset = 0.04621224670174, yoffset = 0.61780780524905, name = "BurningSteppes" };
	GatherRegionData[2][6]  = { scale = 0.07102298961531, xoffset = 0.47822105868635, yoffset = 0.73863555048516, name = "DeadwindPass" };
	GatherRegionData[2][7]  = { scale = 0.13991525534426, xoffset = 0.40335096278072, yoffset = 0.48339696712179, name = "DunMorogh" };
	GatherRegionData[2][8]  = { scale = 0.07670475476181, xoffset = 0.43087243362495, yoffset = 0.73224350550454, name = "Duskwood" };
	GatherRegionData[2][9]  = { scale = 0.10996723642661, xoffset = 0.51663255550387, yoffset = 0.15624753972085, name = "EasternPlaguelands" };
	GatherRegionData[2][10] = { scale = 0.09860350595046, xoffset = 0.41092682316676, yoffset = 0.65651531970162, name = "Elwynn" };
	GatherRegionData[2][11] = { scale = 0.09090931690055, xoffset = 0.42424361247460, yoffset = 0.30113436864162, name = "Hilsbrad" };
	GatherRegionData[2][12] = { scale = 0.02248317426784, xoffset = 0.47481923366335, yoffset = 0.51289242617182, name = "Ironforge" };
	GatherRegionData[2][13] = { scale = 0.07839152145224, xoffset = 0.51118749188138, yoffset = 0.50940913489577, name = "LochModan" };
	GatherRegionData[2][14] = { scale = 0.06170112311456, xoffset = 0.49917278340928, yoffset = 0.68359285304999, name = "Redridge" };
	GatherRegionData[2][15] = { scale = 0.06338794005823, xoffset = 0.46372051266487, yoffset = 0.57812379382509, name = "SearingGorge" };
	GatherRegionData[2][16] = { scale = 0.11931848806212, xoffset = 0.35653502290090, yoffset = 0.24715695496522, name = "Silverpine" };
	GatherRegionData[2][17] = { scale = 0.03819701270887, xoffset = 0.41531450060561, yoffset = 0.67097280492581, name = "Stormwind" };
	GatherRegionData[2][18] = { scale = 0.18128603034401, xoffset = 0.39145470225916, yoffset = 0.79412224886668, name = "Stranglethorn" };
	GatherRegionData[2][19] = { scale = 0.06516347991404, xoffset = 0.51769795272070, yoffset = 0.72815974701615, name = "SwampOfSorrows" };
	GatherRegionData[2][20] = { scale = 0.10937523495111, xoffset = 0.49929119700867, yoffset = 0.25567971676068, name = "Hinterlands" };
	GatherRegionData[2][21] = { scale = 0.12837403412087, xoffset = 0.36837217317549, yoffset = 0.15464954319582, name = "Tirisfal" };
	GatherRegionData[2][22] = { scale = 0.02727719546939, xoffset = 0.42973999245660, yoffset = 0.23815358517831, name = "Undercity" };
	GatherRegionData[2][23] = { scale = 0.12215946583965, xoffset = 0.44270955019641, yoffset = 0.17471356786018, name = "WesternPlaguelands" };
	GatherRegionData[2][24] = { scale = 0.09943208435841, xoffset = 0.36884571674582, yoffset = 0.71874918595783, name = "Westfall" };
	GatherRegionData[2][25] = { scale = 0.11745423014662, xoffset = 0.46561438951659, yoffset = 0.40971063365152, name = "Wetlands" };
end


-- Zone Match Table for use in GathererUI_ZoneRematch function
GathererUI_ZoneMatchTable = { 
	-- French transition matrix
	["FR 1_11_0"] = {
		["FR 1_12_0"] = { -- Identical for name fixes purpose only
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ,20, 21 },
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 };
		};
	},
	["FR 1_12_0"] = {
		["FR 1_12_0"] = { -- Identical for name fixes purpose only
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ,20, 21 },
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 };
		};
		["US/UK"] = { 
			{ 1,  2, 21, 20,  4, 6,  5,  9,  8, 14, 17,  7, 18, 11, 12, 10, 13,  3, 15, 16, 19 },
			{ 8, 17,  21, 11, 7, 6, 10, 16, 15,  2, 12, 14, 20, 25, 13,  9, 23, 19, 24,  1,  5, 4, 3, 22, 18 };
		},
	},
	-- German transition matrix
	["DE 1_11_0"] = {
		["DE 1_12_0"] = { -- Identical for name fixes purpose only
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ,20, 21 },
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 };
		},
	},
	["DE 1_12_0"] = {
		["DE 1_12_0"] = { -- Identical for name fixes purpose only
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ,20, 21 },
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 };
		},
	},
	["US/UK"] = {
		["FR 1_12_0"] = { 
			{  1, 2, 18,  5,  7, 6, 12, 9,  8, 16, 14, 15, 17, 10, 19, 20, 11, 13, 21,  4,  3 },
			{ 20,10, 23, 22, 21, 6,  5, 1, 16,  7,  4, 11, 15, 12,  9,  8,  2, 25, 18, 13,  3, 24, 17, 19, 14 };
		},
		["US/UK"] = { -- Identical for name fixes purpose only
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ,20, 21 },
			{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 };
		};
	},
};

