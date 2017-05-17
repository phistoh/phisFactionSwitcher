-- table of [tabard id] = reputation id pairs
phisTabards = {
	-- main alliance factions
	[45574] = 72,   -- Stormwind
	[45577] = 47,   -- Ironforge
	[45578] = 54,   -- Gnomeregan
	[45579] = 69,   -- Darnassus
	[45580] = 930,  -- Exodar
	[64882] = 1134, -- Gilneas
	[83079] = 1353, -- Tushui Pandaren
	
	-- main horde factions
	[64884] = 1133, -- Bilgewater Cartel
	[45581] = 76,   -- Orgrimmar
	[45582] = 530,  -- Darkspear Trolls
	[45583] = 68,   -- Undercity
	[45584] = 81,   -- Thunder Bluff
	[45585] = 911,  -- Silvermoon City
	[83080] = 1352, -- Huojin Pandaren
	
	-- Wrath of the Lich King
	[43154] = 1106, -- Argent Crusade
	[43155] = 1098, -- Knights of the Ebon Blade
	[43156] = 1091, -- The Wyrmrest Accord
	[43157] = 1090, -- Kirin Tor
	
	-- Cataclysm
	[65904] = 1173, -- Ramkahen
	[65905] = 1135, -- Earthen Ring
	[65906] = 1158, -- Guardians of Hyjal
	[65907] = 1171, -- Therazane
	[65908] = 1174, -- Wildhammer Clan
	[65909] = 1172  -- Dragonmaw Clan
}

-- table of ["zone name"] = reputation id pairs
-- or ["zone name"] = {["A"] = rep id, ["H"] = rep id} pairs for zones with different reputations for Alliance/Horde
phisZones = {
	-- Kalimdor
	["Mount Hyjal"] = 1158,									-- Guardians of Hyjal
	["Uldum"] = 1173,										-- Ramkahen
	["Vashj\'ir"] = 5146,									-- The Earthen Ring
	["Winterspring"] = 577,									-- Everlook
	["Tanaris"] = 369,										-- Gadgetzan
	["Northern Barrens"] = 470,								-- Ratchet
	["Felwood"] = 576,										-- Timbermaw Hold
	["Warsong Gulch"] = {["A"] = 890, ["H"] = 889},			-- Silverwing Sentinels / Warsong Outriders
	
	-- Eastern Kingdoms
	["The Cape of Stranglethorn"] = 21,						-- Booty Bay
	["Burning Steppes"] = 59,								-- Thorium Brotherhood
	["Searing Gorge"] = 59,									-- Thorium Brotherhood
	["Ghostlands"] = 922,									-- Tranquillien
	["Twilight Highlands"] = {["A"] = 1174, ["H"] = 1172},	-- Wildhammer Clan / Dragonmaw Clan
	["Tol Barad"] = {["A"] = 1177, ["H"] = 1178},			-- Baradin's Wardens / Hellscream's Reach
	["Tol Barad Peninsula"] = {["A"] = 1177, ["H"] = 1178},	-- Baradin's Wardens / Hellscream's Reach
	["Alterac Valley"] = {["A"] = 730, ["H"] = 729},		-- Stormpike Guard / Frostwolf Clan
	["Arathi Basin"] = {["A"] = 509, ["H"] = 510},			-- The League of Arathor / The Defilers
	["Isle of Quel\'Danas"] = 1077,							-- Shattered Sun Offensive
	
	-- Outlands
	["Zangarmarsh"] = 942,									-- Cenarion Expedition
	["Hellfire Peninsula"] = {["A"] = 946, ["H"] = 947},	-- Honor Hold / Thrallmar
	["Nagrand"] = {["A"] = 978, ["H"] = 941},				-- Kurenai / Mag'har
	["Shadowmoon Valley"] = 1015,							-- Netherwing
	["Blade\'s Edge Mountains"] = 1038,						-- Ogri'la
	["Netherstorm"] = 933,									-- The Consortium
	
	-- Northrend
	["Zul\'Drak"] = 1106,									-- Argent Crusade
	["Icecrown"] = 1098,									-- Knights of the Ebon Blade
	["The Storm Peaks"] = 1119,								-- The Sons of Hodir
	["Dragonblight"] = 1091,								-- The Wyrmrest Accord
	["Howling Fjord"] = {["A"] = 1068, ["H"] = 1067},		-- Explorer's League / The Hand of Vengeance
	["Borean Tundra"] = {["A"] = 1050, ["H"] = 1064},		-- Valiance Expedition / The Taunka
	
	-- Pandaria
	["Dread Wastes"] = 1337,								-- The Klaxxi
	["Timeless Isle"] = 1492,								-- Emperor Shaohao
	["Vale of Eternal Blossoms"] = 1269,					-- Golden Lotus
	["The Jade Forest"] = {["A"] = 1242, ["H"] = 1228},		-- Pearlfin Jinyu / Forest Hozen
	["Townlong Steppes"] = 1270,							-- Shado-Pan
	["Krasarang Wilds"] = 1302,								-- The Anglers
	["Valley of the Four Winds"] = 1272,					-- The Tillers
	["Isle of Thunder"] = {["A"] = 1387, ["H"] = 1388},		-- Kirin Tor Offensive / Sunreaver Onslaught
	
	-- Draenor
	["Spires of Arak"] = 1515,								-- Arakkoa Outcasts
	["Nagrand (Draenor)"] = 1711,							-- Steamwheedle Preservation Society
	["Ashran"] = {["A"] = 1682, ["H"] = 1681},				-- Wrynn's Vanguard / Vol'jin's Spear
	["Frostfire Ridge"] = 1445,								-- Frostwolf Orcs
	["Shadowmoon Valley (Draenor)"] = 1731,					-- Council of Exarchs
	
	-- Broken Isles
	["Azsuna"] = 1900,										-- Court of Farondis
	["Val\'sharah"] = 1883,									-- Dreamweavers
	["Highmountain"] = 1828,								-- Highmountain Tribe
	["Suramar"] = 1859,										-- The Nightfallen
	["Stormheim"] = 1948,									-- Valajar
	["Broken Shore"] = 2045,								-- Armies of the Legionfall
	
	-- Other
	["Deepholm"] = 1171,									-- Therazane
	["Darkmoon Island"] = 909,								-- Darkmoon Faire
	
	-- Dungeons
	["Old Hillsbrad Foothills"] = 989,						-- Keepers of Time
	["The Black Morass"] = 989,								-- Keepers of Time
	["The Shattered Halls"] = {["A"] = 946, ["H"] = 947},	-- Honor Hold / Thrallmar
	["The Blood Furnace"] = {["A"] = 946, ["H"] = 947},		-- Honor Hold / Thrallmar
	["Hellfire Ramparts"] = {["A"] = 946, ["H"] = 947},		-- Honor Hold / Thrallmar
	["The Slave Pens"] = 942,								-- Cenarion Expedition
	["The Underbog"] = 942,									-- Cenarion Expedition
	["The Steamvault"] = 942,								-- Cenarion Expedition
	["Mana-Tombs"] = 933,									-- The Consortium
	["Sethekk Halls"] = 1011,								-- Lower City
	["Shadow Labyrinth"] = 1011,							-- Lower City
	["The Mechanar"] = 935,									-- The Sha'tar
	["The Arcatraz"] = 935,									-- The Sha'tar
	["The Botanica"] = 935,									-- The Sha'tar
	["Magisters\' Terrace"] = 1077,							-- Shattered Sun Offensive
	
	-- Raids
	["Firelands"] = 1204,									-- Avengers of Hyjal
	["Black Temple"] = 1012,								-- Ashtongue Deathsworn
	["Temple of Ahn\'Qiraj"] = 910,							-- Brood of Nozdormu
	["Ruins of Ahn\'Qiraj"] = 609,							-- Cenarion Circle
	["The Molten Core"] = 749,									-- Hydraxian Waterlords
	["Throne of Tunder"] = 1435,							-- Shado-Pan Assault
	["Hyjal Summit"] = 990,									-- The Scale of Sands
	["Icecrown Citadel"] = 1156,							-- The Ashen Verdict
	["Karazhan"] = 967										-- The Violet Eye
}