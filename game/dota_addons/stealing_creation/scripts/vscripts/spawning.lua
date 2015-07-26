-- Stealing Creation
-- By Richard Morrison (2015)
-- wigguno@gmail.com
-- http://steamcommunity.com/id/wigguno/

-- Lua Spawning
--   Handles spawning all kinds of units and setting their variables correctly
function CStealingCreationGameMode:SpawnDoor(x, y, r, team, inside, outside, trigger)
	local otherteam = nil
	if team == DOTA_TEAM_GOODGUYS then otherteam = DOTA_TEAM_BADGUYS end
	if team == DOTA_TEAM_BADGUYS then otherteam = DOTA_TEAM_GOODGUYS end

	local door1 = CreateUnitByName("prop_sc_barrier", Vector(x, y, 128), false, nil, nil, team)
	local door2 = CreateUnitByName("prop_sc_barrier", Vector(x, y, 128), false, nil, nil, otherteam)

	door1.target_type 	= "spawn_barrier"
	door1.inside 		= inside:GetEntityIndex()
	door1.outside 		= outside:GetEntityIndex()
	door1.team 			= team
	door1.trigger 		= trigger:GetEntityIndex()

	door2.target_type 	= "spawn_barrier"
	door2.inside 		= inside:GetEntityIndex()
	door2.outside 		= outside:GetEntityIndex()
	door2.team 			= team
	door2.trigger 		= trigger:GetEntityIndex()

	Timers:CreateTimer({
		callback = function()		
			door1:SetAngles(0.0, r, 0)
			door2:SetAngles(0.0, r, 0)
			return nil
		end
	})	

end

function CStealingCreationGameMode:SpawnBaseEntities()

	-- find the entities
	local radiant_spawn_trigger 		= Entities:FindByName(nil, "radiant_spawn_area_trigger")
	local radiant_spawn_door1_inside 	= Entities:FindByName(nil, "radiant_spawn_door1_inside")
	local radiant_spawn_door1_outside 	= Entities:FindByName(nil, "radiant_spawn_door1_outside")
	local radiant_spawn_door2_inside	= Entities:FindByName(nil, "radiant_spawn_door2_inside")
	local radiant_spawn_door2_outside 	= Entities:FindByName(nil, "radiant_spawn_door2_outside")

	local dire_spawn_trigger 			= Entities:FindByName(nil, "dire_spawn_area_trigger")
	local dire_spawn_door1_inside 		= Entities:FindByName(nil, "dire_spawn_door1_inside")
	local dire_spawn_door1_outside 		= Entities:FindByName(nil, "dire_spawn_door1_outside")
	local dire_spawn_door2_inside		= Entities:FindByName(nil, "dire_spawn_door2_inside")
	local dire_spawn_door2_outside 		= Entities:FindByName(nil, "dire_spawn_door2_outside")

	self:SpawnDoor(-6400, -7296, 0, DOTA_TEAM_GOODGUYS, radiant_spawn_door1_inside, radiant_spawn_door1_outside, radiant_spawn_trigger)
	self:SpawnDoor(-7296, -6400, 90, DOTA_TEAM_GOODGUYS, radiant_spawn_door2_inside, radiant_spawn_door2_outside, radiant_spawn_trigger)

	self:SpawnDoor(3328, 4224, 0, DOTA_TEAM_BADGUYS, dire_spawn_door1_inside, dire_spawn_door1_outside, dire_spawn_trigger)
	self:SpawnDoor(4224, 3328, 90, DOTA_TEAM_BADGUYS, dire_spawn_door2_inside, dire_spawn_door2_outside, dire_spawn_trigger)



	local radiantChest 	= CreateUnitByName("prop_sc_chest", Vector(-6784, -6784, 128), false, nil, nil, DOTA_TEAM_GOODGUYS)
	local direChest 	= CreateUnitByName("prop_sc_chest", Vector(3712, 3712, 128), false, nil, nil, DOTA_TEAM_BADGUYS)
	radiantChest.target_type 	= "handin_chest"
	direChest.target_type 		= "handin_chest"


	Timers:CreateTimer({
		callback = function()		
			radiantChest:SetAngles(0, 135, 0)
			direChest:SetAngles(0, 315, 0)
			return nil
		end
	})	
end

function CStealingCreationGameMode:SpawnRags(x, y)

	local z = GetGroundHeight(Vector(x, y, 128), nil)

	for n = 1,3 do
		local loc = Vector(x + math.random(-256, 256), y + math.random(-256, 256), z)
		local prop_rags_click = CreateUnitByName("prop_sc_rags_large_bush_clickable", loc, true, nil, nil, DOTA_TEAM_NEUTRALS)

		--SetRenderingEnabled(prop_rags_click:GetEntityHandle(), false)
		--prop_rags_click:AddNewModifier(prop_rags_click, nil, "modifier_invisible", nil)
		--prop_rags_click:AddNoDraw()
		--prop_rags_click:SetRenderColor(255, 255, 255)
		
		-- Attach some variables to the doors so we know their behaviour later
		prop_rags_click.target_type 	= "gather_node"
		prop_rags_click.node_type 		= "node_rags"
		prop_rags_click.target_level 	= 1

		Timers:CreateTimer(function()
			local angle = math.random(360)
			prop_rags_click:SetAngles(0.0, angle, 0)
			return
		end)
	end

	for n = 1,5 do
		local loc = Vector(x + math.random(-256, 256), y + math.random(-256, 256), z)
		local prop_rags_click = CreateUnitByName("prop_sc_rags_small_bush_clickable", loc, true, nil, nil, DOTA_TEAM_NEUTRALS)

		--SetRenderingEnabled(prop_rags_click:GetEntityHandle(), false)
		--prop_rags_click:AddNewModifier(prop_rags_click, nil, "modifier_invisible", nil)
		--prop_rags_click:AddNoDraw()
		--prop_rags_click:SetRenderColor(255, 255, 255)

		-- Attach some variables to the doors so we know their behaviour later
		prop_rags_click.target_type 	= "gather_node"
		prop_rags_click.node_type 		= "node_rags"
		prop_rags_click.target_level 	= 1

		Timers:CreateTimer(function()
			local angle = math.random(360)
			prop_rags_click:SetAngles(0.0, angle, 0)
			return
		end)
	end
end

function CStealingCreationGameMode:SpawnTrees(x, y, tier)

	local z = GetGroundHeight(Vector(x, y, 128), nil)
	for n = 1,5 do
		local prop_tree = CreateUnitByName("prop_sc_tree", Vector(x + math.random(-256, 256), y + math.random(-256, 256), z), true, nil, nil, DOTA_TEAM_NEUTRALS)
		
		local abil = prop_tree:FindAbilityByName("ability_sc_node_prop")
		abil:ApplyDataDrivenModifier(prop_tree, prop_tree, "modifier_node_level_" .. tier, nil)

		-- Attach some variables to the birds so we know their behaviour later
		prop_tree.target_type 	= "gather_node"
		prop_tree.node_type 	= "node_tree"
		prop_tree.target_level 	= tier

		prop_tree.thinker_type 		= "wanderer"
		prop_tree.x 				= x
		prop_tree.y 				= y
		prop_tree.wander 			= 256
		prop_tree.next_wander_time 	= GameRules:GetGameTime() + math.random(5, 10)
		table.insert(self.ThinkerTable, prop_tree)
	end
end

function CStealingCreationGameMode:SpawnFish(x, y, tier)

	local z = GetGroundHeight(Vector(x, y, 128), nil)
	for n = 1,5 do
		local prop_fish = CreateUnitByName("prop_sc_fish", Vector(x + math.random(-256, 256), y + math.random(-256, 256), z), true, nil, nil, DOTA_TEAM_NEUTRALS)
		
		local abil = prop_fish:FindAbilityByName("ability_sc_node_prop")
		abil:ApplyDataDrivenModifier(prop_fish, prop_fish, "modifier_node_level_" .. tier, nil)

		-- Attach some variables to the birds so we know their behaviour later
		prop_fish.target_type 	= "gather_node"
		prop_fish.node_type 	= "node_fish"
		prop_fish.target_level 	= tier

		prop_fish.thinker_type 		= "wanderer"
		prop_fish.x 				= x
		prop_fish.y 				= y
		prop_fish.wander 			= 256
		prop_fish.next_wander_time 	= GameRules:GetGameTime() + math.random(5, 10)
		table.insert(self.ThinkerTable, prop_fish)
	end
end

function CStealingCreationGameMode:SpawnRocks(x, y, tier)

	local z = GetGroundHeight(Vector(x, y, 128), nil)
	for n = 1,5 do
		local prop_rock = CreateUnitByName("prop_sc_rock", Vector(x + math.random(-256, 256), y + math.random(-256, 256), z), true, nil, nil, DOTA_TEAM_NEUTRALS)
		
		local abil = prop_rock:FindAbilityByName("ability_sc_node_prop")
		abil:ApplyDataDrivenModifier(prop_rock, prop_rock, "modifier_node_level_" .. tier, nil)

		-- Attach some variables to the birds so we know their behaviour later
		prop_rock.target_type 	= "gather_node"
		prop_rock.node_type 	= "node_rock"
		prop_rock.target_level 	= tier

		prop_rock.thinker_type 		= "wanderer"
		prop_rock.x 				= x
		prop_rock.y 				= y
		prop_rock.wander 			= 256
		prop_rock.next_wander_time 	= GameRules:GetGameTime() + math.random(5, 10)
		table.insert(self.ThinkerTable, prop_rock)
	end
end

function CStealingCreationGameMode:SpawnBirds(x, y, tier)

	local z = GetGroundHeight(Vector(x, y, 128), nil)
	for n = 1,5 do
		local prop_bird = CreateUnitByName("prop_sc_bird", Vector(x + math.random(-256, 256), y + math.random(-256, 256), z), true, nil, nil, DOTA_TEAM_NEUTRALS)
		
		local abil = prop_bird:FindAbilityByName("ability_sc_node_prop")
		abil:ApplyDataDrivenModifier(prop_bird, prop_bird, "modifier_node_level_" .. tier, nil)

		-- Attach some variables to the birds so we know their behaviour later
		prop_bird.target_type 	= "gather_node"
		prop_bird.node_type 	= "node_bird"
		prop_bird.target_level 	= tier

		prop_bird.thinker_type 		= "wanderer"
		prop_bird.x 				= x
		prop_bird.y 				= y
		prop_bird.wander 			= 256
		prop_bird.next_wander_time 	= GameRules:GetGameTime() + math.random(5, 10)
		table.insert(self.ThinkerTable, prop_bird)
	end
end

function CStealingCreationGameMode:SpawnCrafter(x, y)

	local z = GetGroundHeight(Vector(x, y, 128), nil)

	prop_crafter = CreateUnitByName("prop_sc_crafter", Vector(x, y, z), false, nil, nil, DOTA_TEAM_NEUTRALS)
	prop_crafter:SetHullRadius(192)

	-- Attach some variables to the doors so we know their behaviour later
	prop_crafter.target_type 	= "crafter"
end

function GetRandomFromPlotTable(PlotTable)
	local table_keys = {}
	for k, v in pairs(PlotTable) do 
		table.insert(table_keys, k)
	end
	return table_keys[math.random(#table_keys)]
end

function CStealingCreationGameMode:SetupArena()
	local kv_file = "scripts/maps/" .. GetMapName() .. ".txt"
	local kv = LoadKeyValues( kv_file )
	self.SpawnTable = kv or {}

	--PrintTable(kv)
	local plotTypeTable = {"Lumber", "Pond", "Mine", "Birds"}
	local plotTypeRoll = ChoicePseudoRNG.create( {0.25, 0.25, 0.25, 0.25} )

	local plotTierTable = nil
	local plotTierRoll  = nil

	-----------------------------------------------------------------------------------------------------------------------
	-- RADIANT EASY PLOTS
	print("----- RADIANT EASY -----")

	-- Do the guaranteed plots first
	local crafter1_loc = table.removekey(self.SpawnTable.easy_radiant, GetRandomFromPlotTable(self.SpawnTable.easy_radiant))	
	local rags1_loc = table.removekey(self.SpawnTable.easy_radiant, GetRandomFromPlotTable(self.SpawnTable.easy_radiant))	
	local rags2_loc = table.removekey(self.SpawnTable.easy_radiant, GetRandomFromPlotTable(self.SpawnTable.easy_radiant))

	self:SpawnCrafter(tonumber(crafter1_loc.x), tonumber(crafter1_loc.y))
	self:SpawnRags(tonumber(rags1_loc.x), tonumber(rags1_loc.y))
	self:SpawnRags(tonumber(rags2_loc.x), tonumber(rags2_loc.y))

	plotTierTable = {2, 3}
	plotTierRoll  = ChoicePseudoRNG.create( {0.7, 0.3} )

	for i = 1,4 do
		local plot_type = plotTypeTable[plotTypeRoll:Choose()]
		local plot_tier = plotTierTable[plotTierRoll:Choose()]
		local plot_loc 	= table.removekey(self.SpawnTable.easy_radiant, GetRandomFromPlotTable(self.SpawnTable.easy_radiant))

		if plot_type == "Lumber" then
			self:SpawnTrees(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Pond" then
			self:SpawnFish(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Mine" then
			self:SpawnRocks(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Birds" then
			self:SpawnBirds(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		end

		print("Spawned tier " .. plot_tier .. " " .. plot_type)
	end

	-----------------------------------------------------------------------------------------------------------------------
	-- DIRE EASY PLOTS
	print("----- DIRE EASY -----")

	local crafter2_loc = table.removekey(self.SpawnTable.easy_dire, GetRandomFromPlotTable(self.SpawnTable.easy_dire))
	local rags3_loc = table.removekey(self.SpawnTable.easy_dire, GetRandomFromPlotTable(self.SpawnTable.easy_dire))	
	local rags4_loc = table.removekey(self.SpawnTable.easy_dire, GetRandomFromPlotTable(self.SpawnTable.easy_dire))	

	self:SpawnCrafter(tonumber(crafter2_loc.x), tonumber(crafter2_loc.y))
	self:SpawnRags(tonumber(rags3_loc.x), tonumber(rags3_loc.y))
	self:SpawnRags(tonumber(rags4_loc.x), tonumber(rags4_loc.y))

	plotTierTable = {2, 3}
	plotTierRoll  = ChoicePseudoRNG.create( {0.7, 0.3} )

	for i = 1,4 do
		local plot_type = plotTypeTable[plotTypeRoll:Choose()]
		local plot_tier = plotTierTable[plotTierRoll:Choose()]
		local plot_loc 	= table.removekey(self.SpawnTable.easy_dire, GetRandomFromPlotTable(self.SpawnTable.easy_dire))

		if plot_type == "Lumber" then
			self:SpawnTrees(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Pond" then
			self:SpawnFish(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Mine" then
			self:SpawnRocks(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Birds" then
			self:SpawnBirds(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		end

		print("Spawned tier " .. plot_tier .. " " .. plot_type)
	end

	-----------------------------------------------------------------------------------------------------------------------
	-- MEDIUM 1 PLOTS
	print("----- MEDIUM 1 -----")

	plotTierTable = {2, 3, 4 ,5}
	plotTierRoll  = ChoicePseudoRNG.create( {0.2, 0.3, 0.4, 0.1} )

	for i = 1,8 do
		local plot_type = plotTypeTable[plotTypeRoll:Choose()]
		local plot_tier = plotTierTable[plotTierRoll:Choose()]
		local plot_loc 	= table.removekey(self.SpawnTable.medium_1, GetRandomFromPlotTable(self.SpawnTable.medium_1))

		if plot_type == "Lumber" then
			self:SpawnTrees(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Pond" then
			self:SpawnFish(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Mine" then
			self:SpawnRocks(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Birds" then
			self:SpawnBirds(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		end

		print("Spawned tier " .. plot_tier .. " " .. plot_type)
	end


	-----------------------------------------------------------------------------------------------------------------------
	-- MEDIUM 2 PLOTS
	print("----- MEDIUM 2 -----")

	plotTierTable = {2, 3, 4 ,5}
	plotTierRoll  = ChoicePseudoRNG.create( {0.2, 0.3, 0.4, 0.1} )

	for i = 1,8 do
		local plot_type = plotTypeTable[plotTypeRoll:Choose()]
		local plot_tier = plotTierTable[plotTierRoll:Choose()]
		local plot_loc 	= table.removekey(self.SpawnTable.medium_2, GetRandomFromPlotTable(self.SpawnTable.medium_2))

		if plot_type == "Lumber" then
			self:SpawnTrees(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Pond" then
			self:SpawnFish(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Mine" then
			self:SpawnRocks(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Birds" then
			self:SpawnBirds(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		end

		print("Spawned tier " .. plot_tier .. " " .. plot_type)
	end


	-----------------------------------------------------------------------------------------------------------------------
	-- HARD PLOTS
	print("----- HARD -----")

	plotTierTable = {4 ,5}
	plotTierRoll  = ChoicePseudoRNG.create( {0.2, 0.8} )

	local plot_type = plotTypeTable[plotTypeRoll:Choose()]
	local plot_tier = 5
	local plot_loc 	= table.removekey(self.SpawnTable.hard, GetRandomFromPlotTable(self.SpawnTable.hard))

	if plot_type == "Lumber" then
		self:SpawnTrees(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
	elseif plot_type == "Pond" then
		self:SpawnFish(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
	elseif plot_type == "Mine" then
		self:SpawnRocks(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
	elseif plot_type == "Birds" then
		self:SpawnBirds(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
	end
	print("Spawned tier " .. plot_tier .. " " .. plot_type)

	for i = 1,3 do
		local plot_type = plotTypeTable[plotTypeRoll:Choose()]
		local plot_tier = plotTierTable[plotTierRoll:Choose()]
		local plot_loc 	= table.removekey(self.SpawnTable.hard, GetRandomFromPlotTable(self.SpawnTable.hard))

		if plot_type == "Lumber" then
			self:SpawnTrees(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Pond" then
			self:SpawnFish(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Mine" then
			self:SpawnRocks(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		elseif plot_type == "Birds" then
			self:SpawnBirds(tonumber(plot_loc.x), tonumber(plot_loc.y), plot_tier)
		end

		print("Spawned tier " .. plot_tier .. " " .. plot_type)
	end

end

function CStealingCreationGameMode:SpawnTestSetup()

	--self:SpawnTrees(-6656, -4608, 2)
	--self:SpawnFish(-6656, -4608, 2)
	--self:SpawnRocks(-6656, -4608, 2)
	--self:SpawnBirds(-6656, -4608, 2)

	local x = -6656
	local y = -4608

	self:SpawnTrees(x + (2048 * 0), y + (2048 * 0), 2)
	self:SpawnTrees(x + (2048 * 1), y + (2048 * 0), 3)
	self:SpawnTrees(x + (2048 * 2), y + (2048 * 0), 4)
	self:SpawnTrees(x + (2048 * 3), y + (2048 * 0), 5)

	self:SpawnFish(x + (2048 * 0), y + (2048 * 1), 2)
	self:SpawnFish(x + (2048 * 1), y + (2048 * 1), 3)
	self:SpawnFish(x + (2048 * 2), y + (2048 * 1), 4)
	self:SpawnFish(x + (2048 * 3), y + (2048 * 1), 5)

	self:SpawnRocks(x + (2048 * 0), y + (2048 * 2), 2)
	self:SpawnRocks(x + (2048 * 1), y + (2048 * 2), 3)
	self:SpawnRocks(x + (2048 * 2), y + (2048 * 2), 4)
	self:SpawnRocks(x + (2048 * 3), y + (2048 * 2), 5)

	self:SpawnBirds(x + (2048 * 0), y + (2048 * 3), 2)
	self:SpawnBirds(x + (2048 * 1), y + (2048 * 3), 3)
	self:SpawnBirds(x + (2048 * 2), y + (2048 * 3), 4)
	self:SpawnBirds(x + (2048 * 3), y + (2048 * 3), 5)

	self:SpawnCrafter(x + (2048 * 1), y + (2048 * -1))
	self:SpawnRags(x + (2048 * 2), y + (2048 * -1))
end
