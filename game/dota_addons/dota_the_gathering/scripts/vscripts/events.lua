-- Dota the Gathering
-- By wigguno
-- http://steamcommunity.com/id/wigguno/

-- Lua Events

function DTGGameMode:AddAllMats(keys)
	for pid = 0,9 do if PlayerResource:IsValidPlayer(pid) then		
		CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_1", {count=9999})
		CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_2", {count=9999})
		CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_3", {count=9999})
		CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_4", {count=9999})
		CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_5", {count=9999})
	end end
end

function DTGGameMode:EndGame(keys)
	print("Ending game")
	GameRules.DTGGameMode.EndGameNow = true
end

function RecalculateScore(pid)
	local mode = GameRules.DTGGameMode
	local score = mode.ScoreTable[pid]["type1"]
	score = score + (mode.ScoreTable[pid]["type2"] * 2)
	score = score + (mode.ScoreTable[pid]["type3"] * 3)
	score = score + (mode.ScoreTable[pid]["type4"] * 4)
	score = score + (mode.ScoreTable[pid]["type5"] * 5)
	score = score + (mode.ScoreTable[pid]["crafting"] * 1)
	return score
end

function DTGGameMode:OnPlayerPickHero(keys)
	--print("OnPlayerPickHero")
	--PrintTable(keys)

	local hero = EntIndexToHScript(keys.heroindex)
	local pid = hero:GetPlayerID()

	hero:AddAbility("ability_sc_hero_helper")
	hero:SetAbilityPoints(0)

	local ab = hero:FindAbilityByName("ability_sc_hero_helper")
	if ab then
		ab:SetLevel(1)
		--print("Added helper ability to " .. keys.hero)
	else
		print("FAILED TO ADD HELPER ABILITY TO " .. keys.hero)
	end

	print("Setting Player " .. pid .. "'s NetTables up.")
	CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_1", {count=0})
	CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_2", {count=0})
	CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_3", {count=0})
	CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_4", {count=0})
	CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_5", {count=0})
	CustomNetTables:SetTableValue("score_table", "player_" .. pid, {score=0, type1=0, type2=0, type3=0, type4=0, type5=0})

	local mode = GameRules.DTGGameMode
	mode.ScoreTable[pid] = {type1=0, type2=0, type3=0, type4=0, type5=0, crafting=0, score=0}

	-- heroesSpawned is initialised in InitGameMode()
	mode.heroesSpawned = mode.heroesSpawned + 1
	if mode.heroesSpawned == PlayerResource:GetPlayerCount() then
		GameRules:SendCustomMessage("Welcome to Dota the Gathering", DOTA_TEAM_NEUTRALS, 1)
		GameRules:SendCustomMessage("By " .. COLOR_DPURPLE .. "wigguno", DOTA_TEAM_NEUTRALS, 1)
		GameRules:SendCustomMessage("Game Length: " .. COLOR_SBLUE .. mode.game_length .. "m", DOTA_TEAM_NEUTRALS, 1)
	end

end

function DTGGameMode:OnGameRulesStateChange(keys)
	--print("Game State Change")
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		local mode 	= GameRules.DTGGameMode
		local votes = mode.VoteTable

		--[[
		-- Random tables for test purposes
		local testTable = {game_length = {}, combat_system = {}}

		local votes_a = {15, 20, 25, 30}
		local votes_b = {1, 2}

		for i = 0,9 do
			testTable.game_length[i] 	= votes_a[math.random(table.getn(votes_a))]
			testTable.combat_system[i] 	= votes_b[math.random(table.getn(votes_b))]
		end
		votes = testTable		
		]]

		mode.game_length = 0
		mode.combat_system = ""

		for category, pidVoteTable in pairs(votes) do
			
			-- Tally the votes into a new table
			local voteCounts = {}
			for pid, vote in pairs(pidVoteTable) do
				if not voteCounts[vote] then voteCounts[vote] = 0 end
				voteCounts[vote] = voteCounts[vote] + 1
			end

			--print(" ----- " .. category .. " ----- ")
			--PrintTable(voteCounts)

			-- Find the key that has the highest value (key=vote value, value=number of votes)
			local highest_vote = 0
			local highest_key = ""
			for k, v in pairs(voteCounts) do
				if v > highest_vote then
					highest_key = k
					highest_vote = v
				end
			end

			-- Check for a tie by counting how many values have the highest number of votes
			local tieTable = {}
			for k, v in pairs(voteCounts) do
				if v == highest_vote then
					table.insert(tieTable, k)
				end
			end

			-- Resolve a tie by selecting a random value from those with the highest votes
			if table.getn(tieTable) > 1 then
				--print("TIE!")
				highest_key = tieTable[math.random(table.getn(tieTable))]
			end

			-- Act on the winning vote
			if category == "game_length" then
				GameRules:SetPreGameTime( 60 * highest_key )
				mode.game_length = highest_key

			elseif category == "combat_system" then
				local gme = GameRules:GetGameModeEntity()
				if highest_key == 1 then
					gme:SetDamageFilter( Dynamic_Wrap (DTGGameMode, "DamageFilter_Simple" ), self )
					mode.combat_system = "simple"
				elseif highest_key == 2 then
					--gme:SetDamageFilter( Dynamic_Wrap (DTGGameMode, "DamageFilter_CombatTriangle" ), self )
					mode.combat_system = "triangle"
				end
			end

			print(category .. ": " .. highest_key)
		end
	end
end

function DTGGameMode:OnSettingVote(keys)
	--print("Custom Game Settings Vote.")
	--PrintTable(keys)

	local pid 	= keys.PlayerID
	local mode 	= GameRules.DTGGameMode

	-- VoteTable is initialised in InitGameMode()
	if not mode.VoteTable[keys.category] then mode.VoteTable[keys.category] = {} end
	mode.VoteTable[keys.category][pid] = keys.vote

	--PrintTable(mode.VoteTable)
end

function GetMatCountOrLower(matAmount, minMatType, pid)

	local nettable = "gather_table_p" .. pid;
	local returnTable = {matType=-1, canAfford=false}

	for i = minMatType, 5 do
		local matCount = CustomNetTables:GetTableValue(nettable, "type_" .. i)
		if matCount.count >= matAmount then
			returnTable = {matType=i, canAfford=true}
			break
		end
	end
	return returnTable
end

abilityUpgradeCostTable 	= {25, 30, 35, 40}
weaponPurchaseCostTable 	= {20, 25, 30, 35, 40}
armourPurchaseCostTable 	= {30, 35, 40 ,45, 50}
barrierPurchaseCostTable 	= {50, 60, 70, 80, 90}

function DTGGameMode:OnUpgradeAbilityRequest(keys)
	local pid 			= keys.PlayerID
	local player 		= PlayerResource:GetPlayer(pid)
	local hero 			= player:GetAssignedHero()
	local ability 		= hero:FindAbilityByName(keys.ability_name)
	local abilityLevel 	= ability:GetLevel()
	
	if abilityLevel >= 4 then
		local event_data =
		{
			text = "Notify_AbilityMax",
			duration = 2,
		}
		CustomGameEventManager:Send_ServerToPlayer( player, "js_notification", event_data )
		return
	end

	local upgradeCost  = abilityUpgradeCostTable[abilityLevel + 1]

	local gotMats = GetMatCountOrLower(upgradeCost, abilityLevel + 1, pid)

	if gotMats.canAfford then
		ability:SetLevel(ability:GetLevel() + 1)
		local oldTable = CustomNetTables:GetTableValue("gather_table_p" .. pid, "type_" .. gotMats.matType)
		CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_" .. gotMats.matType, {count=oldTable.count - upgradeCost})
	else
		
		local event_data =
		{
			text = "Notify_AbilityNeed" .. abilityLevel,
			duration = 2,
		}
		CustomGameEventManager:Send_ServerToPlayer( player, "js_notification", event_data )
	end
end

PointsTable = {
	item_sc_sword_tier_1 = 20,
	item_sc_sword_tier_2 = 50,
	item_sc_sword_tier_3 = 90,
	item_sc_sword_tier_4 = 140,
	item_sc_sword_tier_5 = 200,

	item_sc_bow_tier_1 = 20,
	item_sc_bow_tier_2 = 50,
	item_sc_bow_tier_3 = 90,
	item_sc_bow_tier_4 = 140,
	item_sc_bow_tier_5 = 200,

	item_sc_staff_tier_1 = 20,
	item_sc_staff_tier_2 = 50,
	item_sc_staff_tier_3 = 90,
	item_sc_staff_tier_4 = 140,
	item_sc_staff_tier_5 = 200,

	item_sc_armour_tier_1 = 30,
	item_sc_armour_tier_2 = 70,
	item_sc_armour_tier_3 = 120,
	item_sc_armour_tier_4 = 180,
	item_sc_armour_tier_5 = 250,

	item_sc_hide_tier_1 = 30,
	item_sc_hide_tier_2 = 70,
	item_sc_hide_tier_3 = 120,
	item_sc_hide_tier_4 = 180,
	item_sc_hide_tier_5 = 250,

	item_sc_robes_tier_1 = 30,
	item_sc_robes_tier_2 = 70,
	item_sc_robes_tier_3 = 120,
	item_sc_robes_tier_4 = 180,
	item_sc_robes_tier_5 = 250,
}

function DTGGameMode:OnDepositItems(keys)
	local pid 			= keys.PlayerID
	local player 		= PlayerResource:GetPlayer(pid)
	local hero 			= player:GetAssignedHero()
	local points 		= 0

	--print("Deposit Items.")
	--PrintTable(keys)
	for _, itemName in pairs(keys.item_list) do
		if hero:HasItemInInventory(itemName) then
			points = points + PointsTable[itemName]
			--print(itemName .. " -> +" .. PointsTable[itemName])

			local item = FindItemByName(hero, itemName)
			if item then hero:RemoveItem(item) end
		end
	end

	--print ("adding " .. points .. " points")

	local mode = GameRules.DTGGameMode
	mode.ScoreTable[pid]["crafting"] 	= mode.ScoreTable[pid]["crafting"] + points
	mode.ScoreTable[pid]["score"] 		= RecalculateScore(pid)
	CustomNetTables:SetTableValue("score_table", "player_" .. pid, mode.ScoreTable[pid])

end

function DTGGameMode:OnPurchaseItemRequest(keys)
	local pid 			= keys.PlayerID
	local player 		= PlayerResource:GetPlayer(pid)
	local hero 			= player:GetAssignedHero()
	local item 			= "item_sc_" .. keys.item_name .. "_tier_" .. keys.item_tier
	local purchaseType	= nil
	local purchaseCost 	= nil

	if keys.item_name == "sword" or keys.item_name == "bow" or keys.item_name == "staff" then
		purchaseType 	= "Weapon"
		purchaseCost 	= weaponPurchaseCostTable[keys.item_tier]
	elseif keys.item_name == "armour" or keys.item_name == "hide" or keys.item_name == "robes" then
		purchaseType 	= "Armour"
		purchaseCost 	= armourPurchaseCostTable[keys.item_tier]
	elseif keys.item_name == "barrier" then
		purchaseType 	= "Barrier"
		purchaseCost 	= barrierPurchaseCostTable[keys.item_tier]
	else
		return
	end

	local gotMats = GetMatCountOrLower(purchaseCost, keys.item_tier, pid)

	if gotMats.canAfford then
		local item = CreateItem(item, hero, hero)
		hero:AddItem(item)

		local oldTable = CustomNetTables:GetTableValue("gather_table_p" .. pid, "type_" .. gotMats.matType)
		CustomNetTables:SetTableValue("gather_table_p" .. pid, "type_" .. gotMats.matType, {count=oldTable.count - purchaseCost})
	else
		local textstr = "Notify_" .. purchaseType .. "Need" .. keys.item_tier
		local event_data =
		{
			text = textstr,
			duration = 2,
		}
		CustomGameEventManager:Send_ServerToPlayer( player, "js_notification", event_data )
	end
end

-- Register all the listeners at the start
function DTGGameMode:RegisterEventHandlers()
	print("Registering Event Listeners.")

	GameRules.DTGGameMode.EndGameNow = false

	Convars:RegisterCommand("sc_add_all_mats", Dynamic_Wrap(DTGGameMode, "AddAllMats"), "adds lots of all mats to all players", FCVAR_CHEAT)
	Convars:RegisterCommand("sc_end_game", Dynamic_Wrap(DTGGameMode, "EndGame"), "ends the game", FCVAR_CHEAT)

	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(DTGGameMode, "OnPlayerPickHero"), DTGGameMode)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(DTGGameMode, "OnGameRulesStateChange"), DTGGameMode)

	CustomGameEventManager:RegisterListener( "setting_vote", 	Dynamic_Wrap(DTGGameMode, "OnSettingVote"))
	CustomGameEventManager:RegisterListener( "upgrade_ability", Dynamic_Wrap(DTGGameMode, "OnUpgradeAbilityRequest"))
	CustomGameEventManager:RegisterListener( "deposit_items", 	Dynamic_Wrap(DTGGameMode, "OnDepositItems"))
	CustomGameEventManager:RegisterListener( "purchase_item", 	Dynamic_Wrap(DTGGameMode, "OnPurchaseItemRequest"))
end