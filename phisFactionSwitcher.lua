---------------------
-- TODO: Tabard takes precedence over zone/rep change

-- TODO: Handle zones with multiple factions (random/highest rep)

-- TODO: Vashj'ir subzones
---------------------

-- slash commands
SLASH_PREPS1 = "/phisreputationswitcher"
SLASH_PREPS2 = "/prepswitch"
SLASH_PREPS3 = "/preps"

-- slash command will be used to toggle reputation back to current zone
SlashCmdList["PREPS"] = function(args)
	-- phis_OnEvent(phis_f, "ZONE_CHANGED_NEW_AREA")
end

-- initialize variables
local item_id, rep_id, zone_name
local player_faction = string.sub(UnitFactionGroup("player"), 1, 1) -- returns the first letter of the players faction
local collapsed_factions = {} -- will be used in the auxilliary functions to expand and collapse headers

-- function which handles the events
local function phis_OnEvent(self, event, ...)
	-- check if the player equipped/unequipped something
	if (event == "PLAYER_EQUIPMENT_CHANGED") then
		local arg1, arg2 = ...
		-- if the changed item was not a tabard or if an item was unequipped do nothing
		if (arg1 ~= INVSLOT_TABARD) or (arg2 ~= 1) then
			return
		end
		-- get the id of the equipped tabard
		item_id = GetInventoryItemID("player", INVSLOT_TABARD)
		-- get the corresponding reputation id from the table
		rep_id = phisTabards[item_id]
		-- if a rep_id was found, set the watched faction to it
		if rep_id ~= nil then
			phis_SetFactionIndexByID(rep_id)
		end
		return
	end
	
	-- check if the player entered a zone with a corresponding reputation
	-- (will also get fired if the player enters the world)
	if (event == "ZONE_CHANGED_NEW_AREA") or (event == "PLAYER_ENTERING_WORLD") then
		-- get name of the zone
		zone_name = GetRealZoneText()
		
		-- workaround for zones existing in Outland and Draenor
		if zone_name == "Nagrand" or zone_name == "Shadowmoon Valley" then
			local map_id = GetCurrentMapAreaID()
			if map_id == 950 or map_id == 947 then
				zone_name = zone_name.." (Draenor)"
			end
		end
		
		-- get the corresponding reputation id from the table
		rep_id = phisZones[zone_name]
		
		-- check if rep_id is a table
		-- and if it is, get the rep_id corresponding to Alliance/Horde
		if type(rep_id) == "table" then
			rep_id = rep_id[player_faction]
		end
		
		-- if a rep_id was found, set the watched faction to it
		if rep_id ~= nil then
			phis_SetFactionIndexByID(rep_id)
		end
		return
	end
	
	-- check the player's combat text
	if (event == "COMBAT_TEXT_UPDATE") then
		local arg1, arg2 = ...
		
		-- if it is not about reputation gain/loss do nothing
		if (arg1 ~= "FACTION") then
			return
		end
		
		-- watch the faction
		phis_SetFactionIndexByName(arg2)
	
	end
	
end

-- searches the index of a faction (given by id)
function phis_SetFactionIndexByID(rep_id)
	local faction_name, _, standing = GetFactionInfoByID(rep_id)
	
	-- list of factions with paragon rewards
	local paragons = {
						[1828]=true, -- Highmountain Tribe
						[1859]=true, -- The Nightfallen
						[1883]=true, -- Dreamweavers
						[1900]=true, -- Court of Farondis
						[1948]=true, -- Valajar
						[2045]=true  -- Armies of the Legionfall
					}
	
	-- if already exalted, don't switch
	-- except when it is a "paragonable" reputation
	if standing == 8 and not paragons[rep_id] then
		-- print("Already exalted with "..faction_name..".")
		return
	end
	
	-- expand faction headers so they get included in the search
	phis_ExpandAndRemember()
	
	-- check for every faction in the reputation pane if its name is the same as the one corresponding to rep_id
	-- if a valid faction was found check if it is active and switch to it
	local current_name
	for i = 1, GetNumFactions() do
		current_name = GetFactionInfo(i)
		if faction_name == current_name then
			if not IsFactionInactive(i) then
				SetWatchedFactionIndex(i)
			end
			break
		end
	end
	
	-- restore the collapsed headers again
	phis_CollapseAndForget()
	
	return
end

-- searches the index of a faction (given by name)
function phis_SetFactionIndexByName(faction_name)
	-- expand faction headers so they get included in the search
	phis_ExpandAndRemember()
	
	-- check for every faction in the reputation pane if its name is the same as the argument
	-- if a valid faction was found check if it is active and switch to it
	local current_name
	for i = 1, GetNumFactions() do
		current_name, _, standing = GetFactionInfo(i)
		if faction_name == current_name then
			-- if the faction is inactive, end the loop
			if IsFactionInactive(i) then
				break
			end
			-- if the player is already exalted, end the loop
			if standing == 8 then
				-- print("Already exalted with "..faction_name..".")
				break
			end
			-- set the faction
			SetWatchedFactionIndex(i)
			break
		end
	end
	
	-- restore the collapsed headers again
	phis_CollapseAndForget()
	
	return
end

-- scans the player's reputation pane and expands all collapsed headers
-- stores which headers were collapsed so they can be collapsed again
function phis_ExpandAndRemember()
	local i = 1
	
	-- while-loop because the number of factions changes while expanding headers
	while i < GetNumFactions() do
		-- check if the current faction is collapsed
		local faction_name, _, _, _, _, _, _, _, _, is_collapsed = GetFactionInfo(i)
		if is_collapsed then
			-- if it is, remember its name and expand it
			collapsed_factions[faction_name] = true
			ExpandFactionHeader(i)
		end
		i = i + 1
	end
end

-- scans the player's reputation pane and collapses all previously expanded headers
function phis_CollapseAndForget()
	local i = 1
	
	-- while-loop because the number of factions changes while expanding headers
	while i < GetNumFactions() do
		-- get the name of the faction
		local faction_name = GetFactionInfo(i)
		-- and check if it was previously collapsed
		if collapsed_factions[faction_name] then
			-- if so, collapse it
			CollapseFactionHeader(i)
		end
		i = i + 1
	end
	-- empty the table again
	collapsed_factions = {}
end

-- create frame es event listener
local phis_f = CreateFrame("Frame")

-- register events
phis_f:RegisterEvent("PLAYER_ENTERING_WORLD")
phis_f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
phis_f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
phis_f:RegisterEvent("COMBAT_TEXT_UPDATE")

-- set script
phis_f:SetScript("OnEvent", phis_OnEvent)
