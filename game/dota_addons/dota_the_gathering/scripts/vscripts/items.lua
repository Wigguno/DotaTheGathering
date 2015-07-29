-- Dota the Gathering
-- By wigguno
-- http://steamcommunity.com/id/wigguno/

-- Lua Items
-- handles the runscripts for all data-driven items

function findItemType(name)
	if string.find(name, "sword") 	then return "sword" end
	if string.find(name, "bow") 	then return "bow" end
	if string.find(name, "staff") 	then return "staff" end
	if string.find(name, "armour") 	then return "armour" end
	if string.find(name, "hide") 	then return "hide" end
	if string.find(name, "robes") 	then return "robes" end
	return nil
end

function findItemTier(name)
	return string.match(name, "%d+")
end

function OnWeaponSwitch(keys)
	--PrintTable(keys)
	local hero = keys.caster
	local item = keys.ability
	local itemType = findItemType(item:GetName())
	local itemTier = findItemTier(item:GetName())
	local modifierName = "modifier_sc_" .. itemType .. "_tier_" .. itemTier

	--print("Tier " .. itemTier .. " " .. itemType .. " finished channeling.")

	-- if the hero already has the modifier, remove it and carry on
	if hero:FindModifierByName(modifierName) then
		hero:RemoveModifierByName(modifierName)
		return
	end

	-- remove all modifiers first
	hero:RemoveModifierByName("modifier_sc_sword_tier_1")
	hero:RemoveModifierByName("modifier_sc_sword_tier_2")
	hero:RemoveModifierByName("modifier_sc_sword_tier_3")
	hero:RemoveModifierByName("modifier_sc_sword_tier_4")
	hero:RemoveModifierByName("modifier_sc_sword_tier_5")

	hero:RemoveModifierByName("modifier_sc_bow_tier_1")
	hero:RemoveModifierByName("modifier_sc_bow_tier_2")
	hero:RemoveModifierByName("modifier_sc_bow_tier_3")
	hero:RemoveModifierByName("modifier_sc_bow_tier_4")
	hero:RemoveModifierByName("modifier_sc_bow_tier_5")

	hero:RemoveModifierByName("modifier_sc_staff_tier_1")
	hero:RemoveModifierByName("modifier_sc_staff_tier_2")
	hero:RemoveModifierByName("modifier_sc_staff_tier_3")
	hero:RemoveModifierByName("modifier_sc_staff_tier_4")
	hero:RemoveModifierByName("modifier_sc_staff_tier_5")

	--print("applying modifier: " .. modifierName)
	item:ApplyDataDrivenModifier(hero, hero, modifierName, nil)

	if itemType == "sword" then
	elseif itemType == "bow" then
	elseif itemType == "staff" then
	end
end


function OnArmourSwitch(keys)
	--PrintTable(keys)
	local hero = keys.caster
	local item = keys.ability
	local itemType = findItemType(item:GetName())
	local itemTier = findItemTier(item:GetName())
	local modifierName = "modifier_sc_" .. itemType .. "_tier_" .. itemTier
	
	--print("Tier " .. itemTier .. " " .. itemType .. " finished channeling.")

	-- if the hero already has the modifier, remove it and carry on
	if hero:FindModifierByName(modifierName) then
		hero:RemoveModifierByName(modifierName)
		return
	end

	-- remove all modifiers first
	hero:RemoveModifierByName("modifier_sc_armour_tier_1")
	hero:RemoveModifierByName("modifier_sc_armour_tier_2")
	hero:RemoveModifierByName("modifier_sc_armour_tier_3")
	hero:RemoveModifierByName("modifier_sc_armour_tier_4")
	hero:RemoveModifierByName("modifier_sc_armour_tier_5")

	hero:RemoveModifierByName("modifier_sc_hide_tier_1")
	hero:RemoveModifierByName("modifier_sc_hide_tier_2")
	hero:RemoveModifierByName("modifier_sc_hide_tier_3")
	hero:RemoveModifierByName("modifier_sc_hide_tier_4")
	hero:RemoveModifierByName("modifier_sc_hide_tier_5")

	hero:RemoveModifierByName("modifier_sc_robes_tier_1")
	hero:RemoveModifierByName("modifier_sc_robes_tier_2")
	hero:RemoveModifierByName("modifier_sc_robes_tier_3")
	hero:RemoveModifierByName("modifier_sc_robes_tier_4")
	hero:RemoveModifierByName("modifier_sc_robes_tier_5")

	--print("applying modifier: " .. modifierName)
	item:ApplyDataDrivenModifier(hero, hero, modifierName, nil)

	if itemType == "armour" then
	elseif itemType == "hide" then
	elseif itemType == "robes" then
	end
end

plotList = {}
plotOffsets = {
	fence1 = Vector(-384, 512, 0),
	fence2 = Vector(-512, 320, 0),

	fence3 = Vector(320, 512, 0),
	fence4 = Vector(512, 384, 0),

	fence5 = Vector(-320, -512, 0),
	fence6 = Vector(-512, -384, 0),

	fence7 = Vector(384, -512, 0),
	fence8 = Vector(512, -320, 0),

	door1 = Vector(0, 512, 0),
	door2 = Vector(512, 0, 0),
	door3 = Vector(0, -512, 0),
	door4 = Vector(-512, 0, 0),

	blocker1 = Vector(-512, 512, 0),
	blocker2 = Vector(-384, 512, 0),
	blocker3 = Vector(-256, 512, 0),
	blocker4 = Vector(-128, 512, 0),
	blocker5 = Vector(0,   512, 0),
	blocker6 = Vector(128, 512, 0),
	blocker7 = Vector(250, 512, 0),
	blocker8 = Vector(384, 512, 0),

	blocker9  = Vector(512, 512, 0),
	blocker10 = Vector(512, 384, 0),
	blocker11 = Vector(512, 256, 0),
	blocker12 = Vector(512, 128, 0),
	blocker13 = Vector(512, 0,   0),
	blocker14 = Vector(512, -128, 0),
	blocker15 = Vector(512, -256, 0),
	blocker16 = Vector(512, -384, 0),

	blocker17 = Vector(512, -512, 0),
	blocker18 = Vector(384, -512, 0),
	blocker19 = Vector(256, -512, 0),
	blocker20 = Vector(128, -512, 0),
	blocker21 = Vector(0,   -512, 0),
	blocker22 = Vector(-128, -512, 0),
	blocker23 = Vector(-256, -512, 0),
	blocker24 = Vector(-384, -512, 0),

	blocker25 = Vector(-512, -512, 0),
	blocker26 = Vector(-512, -384, 0),
	blocker27 = Vector(-512, -256, 0),
	blocker28 = Vector(-512, -128, 0),
	blocker29 = Vector(-512, 0, 0),
	blocker30 = Vector(-512, 128, 0),
	blocker31 = Vector(-512, 256, 0),
	blocker32 = Vector(-512, 384, 0),

	door1_out = Vector(0, 640, 0),
	door1_in  = Vector(0, 384, 0),

	door2_out = Vector(640, 0, 0),
	door2_in  = Vector(384, 0, 0),

	door3_out = Vector(0, -640, 0),
	door3_in  = Vector(0, -384, 0),

	door4_out = Vector(-640, 0, 0),
	door4_in  = Vector(-384, 0, 0),

}

function GetClosestPlotCenter(point)

	if #plotList == 0 then
		--print("Empty Plot List!")
		local kv_list = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".txt" )

		for k, v in pairs(kv_list) do
			--print("Loading GroupName: " .. k)
			for group_name, group_points in pairs(v) do
				table.insert(plotList, Vector(group_points.x, group_points.y, 128))
			end
		end
		--PrintTable(plotList)
	end

	-- Find the closest point to cast
	local closest_point = Vector(99999,99999,99999)
	local closest_dist = 99999999999

	for _, vec in pairs(plotList) do
		--print(vec)
		local dist = (vec - point):Length2D()
		if dist < closest_dist then
			closest_point = vec
			closest_dist = dist
		end
	end
	return closest_point
end

function CheckPlotVacancy(keys)
	--print("On Barrier Place!!")
	--PrintTable(keys)

	local caster 		= keys.caster
	local centerPoint 	= GetClosestPlotCenter(keys.target_points[1])
	local team 			= caster:GetTeam()
	local plot_empty 	= true
	local player 		= PlayerResource:GetPlayer(caster:GetPlayerID())

	-- Find fences nearby
	local nearbyUnits = Entities:FindAllInSphere(centerPoint, 750)
	for k, v in pairs(nearbyUnits) do
		if v.GetUnitName and v:GetUnitName() == "barrier_sc_fence" then
			--print("Barrier already on this plot")
			plot_empty = false

			local event_data =
			{
				text 		= "Barrier_PlotOccupied",
				duration 	= 2,
			}
			CustomGameEventManager:Send_ServerToPlayer( player, "js_notification", event_data )

			caster:Stop()
			break;
		end
	end
	return plot_empty
end


function OnBarrierPlace(keys)
	--print("On Barrier Place!!")
	--PrintTable(keys)

	-- Re-test the plot vacancy
	if not CheckPlotVacancy(keys) then
		return
	end

	local centerPoint 	= GetClosestPlotCenter(keys.target_points[1])
	local team 			= keys.caster:GetTeam()
	local tier 			= tonumber(keys.Tier)

	--print("Distance to closest point: " .. closest_dist)
	--print(closest_point)

	local barrierEntities = {}
	barrierEntities.fences = {}
	barrierEntities.doors = {}
	barrierEntities.blockers = {}

	local parent_index = 0

	for i = 1,8 do
		--print("spawning fence: " .. i)
		local fence_instance = CreateUnitByName("barrier_sc_fence", centerPoint + plotOffsets["fence"..i], false, nil, nil, team)
		if i == 1 then
			parent_index = fence_instance:entindex()
		else
			fence_instance.parent = parent_index
		end
		fence_instance:SetBaseMaxHealth(1000 * tier)
		fence_instance:SetMaxHealth(1000 * tier)
		fence_instance:Heal(5000, fence_instance)
		table.insert(barrierEntities.fences, fence_instance:entindex())
	end

	local vec_BL = centerPoint + Vector(-512, -512, 0)
	local vec_TR = centerPoint + Vector(512, 512, 0)

	for i = 1,4 do
		--print("spawning door: " .. i)
		local door_instance 	= CreateUnitByName("barrier_sc_door", centerPoint + plotOffsets["door"..i], false, nil, nil, team)
		door_instance.parent 	= parent_index

		door_instance.target_type 	= "plot_barrier"
		door_instance.inside 		= centerPoint + plotOffsets["door" .. i .. "_in"]
		door_instance.outside 		= centerPoint + plotOffsets["door" .. i .. "_out"]
		door_instance.BL 			= vec_BL
		door_instance.TR 			= vec_TR

		table.insert(barrierEntities.doors, door_instance:entindex())
	end

	for i = 1,32 do
		--print("spawning blocker: " .. i)
		local blocker_instance = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin=centerPoint + plotOffsets['blocker'..i], block_fow=0})
		blocker_instance.parent = parent_index
		table.insert(barrierEntities.blockers, blocker_instance:entindex())
	end

	-- Add the entities to the fences
	EntIndexToHScript(barrierEntities.fences[1]).children = barrierEntities

	Timers:CreateTimer({
		callback = function()		
			EntIndexToHScript(barrierEntities.fences[1]):SetAngles(0, 90, 0)
			EntIndexToHScript(barrierEntities.fences[2]):SetAngles(0, 180, 0)

			EntIndexToHScript(barrierEntities.fences[3]):SetAngles(0, 90, 0)
			EntIndexToHScript(barrierEntities.fences[4]):SetAngles(0, 0, 0)

			EntIndexToHScript(barrierEntities.fences[5]):SetAngles(0, 270, 0)
			EntIndexToHScript(barrierEntities.fences[6]):SetAngles(0, 180, 0)

			EntIndexToHScript(barrierEntities.fences[7]):SetAngles(0, 270, 0)
			EntIndexToHScript(barrierEntities.fences[8]):SetAngles(0, 0, 0)

			EntIndexToHScript(barrierEntities.doors[1]):SetAngles(15, 90, 0)
			EntIndexToHScript(barrierEntities.doors[2]):SetAngles(15, 0, 0)
			EntIndexToHScript(barrierEntities.doors[3]):SetAngles(15, 270, 0)
			EntIndexToHScript(barrierEntities.doors[4]):SetAngles(15, 180, 0)
			return nil
		end
	})	

	-- Find units within the area
	local nearbyUnits = FindUnitsInRadius(
		DOTA_TEAM_NEUTRALS, -- Set the search team to the neutrals team
		centerPoint, -- The search origin
		nil, -- leave as nil
		800, -- search radius is just over 512 * srqt(2) (diagonal distance to corners, plus some extra)
		DOTA_UNIT_TARGET_TEAM_ENEMY, -- team flags. both radiant and dire are enemies of the neutrals
		DOTA_UNIT_TARGET_HERO, -- Unit flags. I assume you're looking for only heroes
		DOTA_UNIT_TARGET_FLAG_NONE, -- dunno what this is
		FIND_ANY_ORDER, -- nor this
		false)-- leave false

	for _, unit in pairs(nearbyUnits) do
		local unit_loc = unit:GetAbsOrigin()
		-- Check if the unit is within the box we are building a barrier around
		if unit_loc.x > vec_BL.x and
		unit_loc.x < vec_TR.x and
		unit_loc.y > vec_BL.y and 
		unit_loc.y < vec_TR.y then			
			if unit:GetTeam() == team then
				local abil = unit:FindAbilityByName("ability_sc_hero_helper")	
				unit.protected_by = barrierEntities.doors[1]			
				abil:ApplyDataDrivenModifier(unit, unit, "modifier_protected", nil)
			else
				FindClearSpaceForUnit(unit, centerPoint + plotOffsets["door3_out"], true)
			end
		end
	end


end

function OnHealthLinkDamaged(keys)
	--print("Health linked unit damaged!")
	--PrintTable(keys)

	local unit = keys.unit
	local unitIndex = unit:entindex()
	local linkedList = nil

	if unit.parent then
		local parent = EntIndexToHScript(unit.parent)
		linkedList = parent.children
	else
		linkedList = unit.children
	end

	if linkedList == nil then
		print("FAIL")
		return
	end


	for k, linkedIndex in pairs(linkedList.fences) do
		if linkedIndex ~= unitIndex then
			EntIndexToHScript(linkedIndex):SetHealth(unit:GetHealth())
		end
	end
end

function OnHealthLinkDeath(keys)
	--print("Health linked unit died!")
	--PrintTable(keys)

	local unit = keys.unit
	local unitIndex = unit:entindex()
	local linkedList = nil

	if unit.parent then
		local parent = EntIndexToHScript(unit.parent)
		linkedList = parent.children
	else
		linkedList = unit.children
	end

	if linkedList == nil then
		print("FAIL")
		return
	end


	for k, linkedIndex in pairs(linkedList.fences) do
		EntIndexToHScript(linkedIndex):RemoveSelf()
	end
	for k, linkedIndex in pairs(linkedList.blockers) do
		EntIndexToHScript(linkedIndex):RemoveSelf()
	end
	for k, linkedIndex in pairs(linkedList.doors) do
		EntIndexToHScript(linkedIndex):RemoveSelf()
	end
	
end

function CheckProtectedStatus(keys)
	--PrintTable(keys)

	local hero 		= EntIndexToHScript(keys.caster_entindex)
	if not hero.protected_by then
		hero:RemoveModifierByName("modifier_protected")
		return
	end
	local protector = EntIndexToHScript(hero.protected_by)
	if not protector or protector:IsNull() then
		hero:RemoveModifierByName("modifier_protected")
	end
end