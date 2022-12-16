---------------------
-- TODO: Tabard takes precedence over zone/rep change

-- TODO: Handle zones with multiple factions (random/highest rep)
---------------------

local addonName, phis = ...

local phis_f = CreateFrame("Frame")

phis_f:RegisterEvent("PLAYER_ENTERING_WORLD")
phis_f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
phis_f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
phis_f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
phis_f:RegisterEvent("ADDON_LOADED")

local DESCRIPTION_LONG = "The addon changes the 'watched faction' in the reputation pane depending on different conditions:|n|n    - Equipping a tabard which provides reputation (e.g. equipping |cFF1EFF00[Tabard of Therazane]|r -> Therazane)|n    - Entering a zone which has a correspoding faction (e.g. entering the Dread Wastes -> The Klaxxi)|n    - Gaining reputation for a faction (e.g. killing a Blackfang Shaman -> The Saberstalkers)|n|nThe addon doesn't switch to a faction if it is already exalted. (Except to the paragonable factions.)|n|nUsage: The addon automatically switches the watched faction so there is nothing you have to do. You can temporarily toggle the automatic switching with '|cFF2EE6E6/pfs toggle|r'. The following options disable (and enable) the conditions for changing the watched faction."

-- slash commands
SLASH_PFS1 = "/phisfactionswitcher"
SLASH_PFS2 = "/pfs"

local item_id, rep_id, zone_name
local enabled = true -- controls the automatic switching
local player_faction = string.sub(UnitFactionGroup("player"), 1, 1) -- returns the first letter of the players faction
local collapsed_factions = {} -- will be used in the auxiliary functions to expand and collapse headers

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

-------------------------
--   AUXILIARY STUFF   --
-------------------------

local function addonPrint(str)
	print('|cFF2EE6E6'..addonName..':|r '..str)
end



SlashCmdList["PFS"] = function(args)
	-- generic help message
	if args:lower() ~= "toggle" then
		addonPrint("Version v"..GetAddOnMetadata("phisFactionSwitcher","Version"))
		addonPrint("Temporarily toggle the automatic switching of reputations with /pfs toggle")
	else	
		-- toggle the value of disabled
		enabled = not enabled
		addonPrint("phisFactionSwitcher is now "..(enabled and "enabled" or "disabled")..".")
	end
	
end

-- scans the player's reputation pane and expands all collapsed headers
-- stores which headers were collapsed so they can be collapsed again
local function expand_and_remember()
	local i = 1
	
	-- while-loop because the number of factions changes while expanding headers
	while i < GetNumFactions() do
		local faction_name, _, _, _, _, _, _, _, _, is_collapsed = GetFactionInfo(i)
		if is_collapsed then
			collapsed_factions[faction_name] = true
			ExpandFactionHeader(i)
		end
		i = i + 1
	end
end

-- scans the player's reputation pane and collapses all previously expanded headers
local function collapse_and_forget()
	local i = 1
	
	-- while-loop because the number of factions changes while expanding headers
	while i < GetNumFactions() do
		local faction_name = GetFactionInfo(i)
		if collapsed_factions[faction_name] then
			CollapseFactionHeader(i)
		end
		i = i + 1
	end
	
	collapsed_factions = {}
end

local function set_faction_index_by_id(rep_id)
	local faction_name, _, standing = GetFactionInfoByID(rep_id)
	
	-- if already exalted, don't switch
	-- except when it is a "paragonable" reputation
	if standing == 8 and not phis.paragons[rep_id] then
		return
	end
	
	-- expand faction headers so they get included in the search
	expand_and_remember()
	
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
	collapse_and_forget()
	
	return
end

local function set_faction_index_by_name(faction_name)
	if faction_name == 'Guild' then
		faction_name = GetGuildInfo('player')
	end

	-- expand faction headers so they get included in the search
	expand_and_remember()
	
	-- check for every faction in the reputation pane if its name is the same as the argument
	-- if a valid faction was found call set_faction_index_by_id() to set the faction
	local current_name
	for i = 1, GetNumFactions() do
		current_name, _, _, _, _, _, _, _, _, _, _, _, _, rep_id = GetFactionInfo(i)
		if faction_name == current_name then
			collapse_and_forget()
			set_faction_index_by_id(rep_id)
			return
		end
	end
	
	-- restore the collapsed headers again
	collapse_and_forget()
	
	return
end

local function main_eventhandler(self, event, ...)
	-- initializes the saved variable table if not present
	if (event == "ADDON_LOADED") then
		if phisFactionSwitcherSavedVars == nil then
			phisFactionSwitcherSavedVars = {
				tabard = true,
				zone_change = true,
				combat_text = true
			}
			addonPrint("Addon loaded for the first time.")
		end
		phis_f:UnregisterEvent("ADDON_LOADED")
	end

	-- do nothing if the addon is currently disabled
	if not enabled then
		return
	end
	
	-- only change watched faction if there is a watched faction
	watched_faction = GetWatchedFactionInfo()
	if not watched_faction then
		return
	end

	-- check if the player equipped/unequipped something
	if (phisFactionSwitcherSavedVars.tabard and event == "PLAYER_EQUIPMENT_CHANGED") then
		local arg1, arg2 = ...
		-- if no tabard was equipped do nothing
		if (arg1 ~= INVSLOT_TABARD) or (arg2 == true) then
			return
		end
		item_id = GetInventoryItemID("player", INVSLOT_TABARD)
		rep_id = phis.tabards[item_id]
		if rep_id ~= nil then
			set_faction_index_by_id(rep_id)
		end
		return
	end
	
	-- check if the player entered a zone with a corresponding reputation
	-- (will also get fired if the player enters the world)
	if (phisFactionSwitcherSavedVars.zone_change and ((event == "ZONE_CHANGED_NEW_AREA") or (event == "PLAYER_ENTERING_WORLD"))) then
		zone_name = GetRealZoneText()
		
		-- workaround for zones existing in both Outland and Draenor
		if zone_name == "Nagrand" or zone_name == "Shadowmoon Valley" then
			local map_id = C_Map.GetBestMapForUnit("player")
			if map_id == 550 or map_id == 539 then
				zone_name = zone_name.." (Draenor)"
			end
		end
		
		rep_id = phis.zones[zone_name]
		
		-- check if the zone has different factions dependent on Alliance/Horde
		if type(rep_id) == "table" then
			rep_id = rep_id[player_faction]
		end
		
		if rep_id ~= nil then
			set_faction_index_by_id(rep_id)
		end
		return
	end
	
	-- check the player's combat text
	if (phisFactionSwitcherSavedVars.combat_text and event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then
		local arg1 = ...

		local faction_name = nil
		local i = 1
		
		-- end the loop if either a faction name was found or if the message could not be matched to one of the "changed standing" messages
		while (faction_name == nil) and (i < #faction_standing_msg) do
			faction_name = string.match(arg1, faction_standing_msg[i])
			i = i+1
		end
		
		if faction_name ~= nil then
			set_faction_index_by_name(faction_name)
		end
	
	end
	
end

-------------------------
--    OPTIONS PANEL    --
-------------------------

-- creates a checkbox 10 px below 'anchor' and stores its state in phisFactionSwitcherSavedVars[k]
local function create_checkbox(k, parent, anchor, text)
	local checkbox = CreateFrame('CheckButton', k..'CheckButton', parent, 'UICheckButtonTemplate')
	checkbox:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, -10)
	checkbox:SetChecked(phisFactionSwitcherSavedVars[k])
	_G[k..'CheckButtonText']:SetText(' '..text)
	_G[k..'CheckButtonText']:SetFontObject('GameFontNormal')
	checkbox:SetScript('OnClick', function()
		-- when 'OnClick' runs, GetChecked() already returns the new status
		checked = checkbox:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		phisFactionSwitcherSavedVars[k] = checked
	end)
	
	return checkbox
end

local options = CreateFrame('Frame', 'phisFactionSwitcherOptionsFrame', SettingsPanel.Container)
options.name = GetAddOnMetadata(addonName,'Title')
InterfaceOptions_AddCategory(options)
options:SetScript('OnShow', function()

	--- HEADER --
	local title_string = options:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title_string:SetPoint('TOPLEFT', 10, -10)
	title_string:SetText(GetAddOnMetadata(addonName,'Title'))
	
	local version_string = options:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	version_string:SetPoint('BOTTOMLEFT', title_string, 'BOTTOMRIGHT', 4, 0)
	version_string:SetText('v'..GetAddOnMetadata(addonName,'Version'))
	
	local description_string = options:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	description_string:SetPoint('TOPLEFT', title_string, 'BOTTOMLEFT', 0, -10)
	description_string:SetJustifyH('LEFT')
	description_string:SetWidth(SettingsPanel.Container:GetWidth() - 40)
	description_string:SetNonSpaceWrap(true)
	description_string:SetText(DESCRIPTION_LONG)
	
	--- CHECKBOXES ---
	local checkboxes = {}
	checkboxes.tabard = create_checkbox('tabard', options, description_string, 'Change faction bar on equipping champion tabard')
	checkboxes.zone_change = create_checkbox('zone_change', options, checkboxes.tabard, 'Change faction bar dependent on current zone')
	checkboxes.combat_text = create_checkbox('combat_text', options, checkboxes.zone_change, 'Change faction bar to last reputation gain')
	
	options:SetScript('OnShow', nil)
end)

phis_f:SetScript("OnEvent", main_eventhandler)