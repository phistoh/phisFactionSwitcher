---------------------
-- TODO: Tabard takes precedence over zone/rep change

-- TODO: Handle zones with multiple factions (random/highest rep)
---------------------

-- slash commands
SLASH_PREPS1 = "/phisreputationswitcher"
SLASH_PREPS2 = "/prepswitch"
SLASH_PREPS3 = "/preps"

-- initialize variables
local item_id, rep_id, zone_name
local enabled = true -- controls the automatic switching
local player_faction = string.sub(UnitFactionGroup("player"), 1, 1) -- returns the first letter of the players faction
local collapsed_factions = {} -- will be used in the auxilliary functions to expand and collapse headers
-- list of factions with paragon rewards
local paragons = {
	[1828]=true, -- Highmountain Tribe
	[1859]=true, -- The Nightfallen
	[1883]=true, -- Dreamweavers
	[1900]=true, -- Court of Farondis
	[1948]=true, -- Valajar
	[2045]=true  -- Armies of the Legionfall
}
-- the different "faction standing changed" messages with %s replaced by a pattern with captures
local faction_standing_msg = {
	string.gsub(FACTION_STANDING_INCREASED, "%%s", "(.+)"),
	string.gsub(FACTION_STANDING_INCREASED_GENERIC, "%%s", "(.+)"),
	string.gsub(FACTION_STANDING_DECREASED, "%%s", "(.+)"),
	string.gsub(FACTION_STANDING_DECREASED_GENERIC, "%%s", "(.+)"),
	string.gsub(FACTION_STANDING_INCREASED_ACH_BONUS, "%%s", "(.+)"),
	string.gsub(FACTION_STANDING_INCREASED_BONUS, "%%s", "(.+)"),
	string.gsub(FACTION_STANDING_INCREASED_DOUBLE_BONUS, "%%s", "(.+)")
}

-- slash command will be used to toggle reputation back to current zone
SlashCmdList["PREPS"] = function(args)
	-- generic help message
	if args:lower() ~= "toggle" then
		print("phisFactionSwitcher v"..GetAddOnMetadata("phisFactionSwitcher","Version"))
		print("Toggle the automatic switching of reputations with /preps toggle")
	end
	
	-- toggle the value of disabled
	enabled = not enabled
	print("phisFactionSwitcher is now "..(enabled and "enabled" or "disabled")..".")
	
end

-- function which handles the events
local function phis_OnEvent(self, event, ...)

	-- do nothing if the addon is currently disabled
	if not enabled then
		return
	end

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
	if (event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then
		local arg1 = ...
		
		-- extract the faction name out of the string
		local faction_name = nil
		local i = 1
		
		-- end the loop if either a faction name was found or if the message could not be matched to one of the "changed standing" messages
		while (faction_name == nil) and (i < #faction_standing_msg) do
			faction_name = string.match(arg1, faction_standing_msg[i])
			i = i+1
		end
		
		-- watch the faction
		if faction_name ~= nil then
			phis_SetFactionIndexByName(faction_name)
		end
	
	end
	
end

-- searches the index of a faction (given by id)
function phis_SetFactionIndexByID(rep_id)
	local faction_name, _, standing = GetFactionInfoByID(rep_id)
	
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
	-- if a valid faction was found call phis_SetFactionIndexByID() to set the faction
	local current_name
	for i = 1, GetNumFactions() do
		current_name, _, _, _, _, _, _, _, _, _, _, _, _, rep_id = GetFactionInfo(i)
		if faction_name == current_name then
			phis_CollapseAndForget()
			phis_SetFactionIndexByID(rep_id)
			return
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

-- create frame as event listener
local phis_f = CreateFrame("Frame")

-- register events
phis_f:RegisterEvent("PLAYER_ENTERING_WORLD")
phis_f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
phis_f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
phis_f:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")

-- set script
phis_f:SetScript("OnEvent", phis_OnEvent)