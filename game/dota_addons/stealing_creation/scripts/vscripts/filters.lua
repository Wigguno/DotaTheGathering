-- Stealing Creation
-- By Richard Morrison (2015)
-- wigguno@gmail.com
-- http://steamcommunity.com/id/wigguno/

-- Lua Filters

function CStealingCreationGameMode:ExecuteOrderFilter(filterTable)
	--print("-------------------------------------------------")
	--PrintTable(filterTable)
	--print("queue: " .. filterTable['queue'])

	if filterTable['order_type'] == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
		--print("-------------------------------------------------")
		--print("Captured event in Order Filter")

		local order_player 	= PlayerResource:GetPlayer(filterTable['issuer_player_id_const'])
		local order_hero 	= EntIndexToHScript(filterTable['units']['0'])
		local ent_target 	= EntIndexToHScript(filterTable['entindex_target'])
		local target_type 	= ent_target.target_type

		if target_type == "spawn_barrier" and (order_hero:GetAbsOrigin() - ent_target:GetAbsOrigin()):Length2D() >= 192 
		or target_type == "gather_node" and (order_hero:GetAbsOrigin() - ent_target:GetAbsOrigin()):Length2D() >= 192 
		or target_type == "handin_chest" and (order_hero:GetAbsOrigin() - ent_target:GetAbsOrigin()):Length2D() >= 192 
		or target_type == "crafter" and (order_hero:GetAbsOrigin() - ent_target:GetAbsOrigin()):Length2D() >= 320 
		then
			--print("dist: " .. (order_hero:GetAbsOrigin() - ent_target:GetAbsOrigin()):Length2D())
			return true
		end

		-- teleport inside and outside of bases
		if ent_target.target_type == "spawn_barrier" then 
			--print("close spawn barrier clicked")

			local target_inside 	= EntIndexToHScript(ent_target.inside)
			local target_outside 	= EntIndexToHScript(ent_target.outside)
			local target_trigger 	= EntIndexToHScript(ent_target.trigger)

			local teleport_target = nil

			-- if the hero is close enough, teleport them through
			if order_hero:GetTeam() == ent_target.team then
				if target_trigger:IsTouching(order_hero)  then
					teleport_target = target_outside
				else
					teleport_target = target_inside
				end

				FindClearSpaceForUnit(order_hero, teleport_target:GetAbsOrigin(), false)
				return false
			end

		elseif ent_target.target_type == "gather_node" then
			--print("close gather node clicked")

			-- get the helper ability off the clicking hero
			local ab = order_hero:FindAbilityByName("ability_sc_hero_helper")
			
			if ent_target.target_level == 1 then
				order_hero.gather_node = filterTable['entindex_target']
				ab:ApplyDataDrivenModifier(order_hero, order_hero, "modifier_gathering_node_1", nil)

			else
				local target_level = ent_target.target_level
				local node_type = ent_target.node_type
				--print(node_type)

				local abil = nil				
				local node_type_text = nil

				if node_type == "node_fish" then
					abil = order_hero:FindAbilityByName("ability_sc_hero_fishing")
					node_type_text = "Fishing"

				elseif node_type == "node_tree" then
					abil = order_hero:FindAbilityByName("ability_sc_hero_woodcutting")
					node_type_text = "Woodcutting"

				elseif node_type == "node_rock" then
					abil = order_hero:FindAbilityByName("ability_sc_hero_mining")
					node_type_text = "Mining"

				elseif node_type == "node_bird" then
					abil = order_hero:FindAbilityByName("ability_sc_hero_hunting")
					node_type_text = "Hunting"
					
				else 
					print("FOUND WRONG NODE TYPE ON A NODE")
					return false
				end
				
				--print("target level: " .. target_level - 1 .. ". abil level: " .. abil:GetLevel())
				if (target_level - 1) > abil:GetLevel() then
					local event_data =
					{
					    text = "Gather_" .. node_type_text .. "Level" .. target_level - 1,
					    duration = 2,
					}
					CustomGameEventManager:Send_ServerToPlayer( order_player, "js_notification", event_data )
					return false
				else
					order_hero.gather_node = filterTable['entindex_target']
					ab:ApplyDataDrivenModifier(order_hero, order_hero, "modifier_gathering_node_" .. target_level, nil)

					-- chance of gathering depends on level difference: 100% level 4 gathering a tier2 node, 50% gathering the same tier as level
					-- subtract 1 from target_level because it goes from 2-5 but ability level goes 1-4
					local gather_chance =  0.5 + ((abil:GetLevel() - (target_level - 1)) * 0.16) 
					order_hero.gather_chance = PseudoRNG.create(gather_chance)
					--print("chance of gather: " ..  gather_chance)
				end
			end

			return false
		
		elseif ent_target.target_type == "crafter" then
			--print("close crafter clicked")
			CustomGameEventManager:Send_ServerToPlayer(order_player, "show_construct_hud", {target_index = ent_target:entindex()} )
		
		elseif ent_target.target_type == "handin_chest" then
			--print("close crafter clicked")
			CustomGameEventManager:Send_ServerToPlayer(order_player, "show_handin_hud", {target_index = ent_target:entindex()} )
		end
	else
		--print("We don't care about this order.")
	end
	-- Always default to returning true (continue with the order)
	return true
end

function CStealingCreationGameMode:DamageFilter_CombatTriangle(filterTable)
	--PrintTable(filterTable)

	local attackHero 			= EntIndexToHScript(filterTable['entindex_attacker_const'])
	local victimHero 			= EntIndexToHScript(filterTable['entindex_victim_const'])
	local outgoingDamageType 	= "nil"
	local outgoingShieldType 	= "nil"
	local incomingShieldType 	= "nil"

	local outgoingDamageTier 	= 0
	local outgoingShieldTier 	= 0
	local incomingShieldTier 	= 0

	local originalDamage 		= filterTable['damage']
	local newDamage 			= originalDamage

	if not attackHero:IsRealHero() or not victimHero:IsRealHero() then
		return true
	end

	-- find the damage type
	local attackHeroModifiers = attackHero:FindAllModifiers()
	for _, mod in pairs(attackHeroModifiers) do
		if string.find(mod:GetName(), "sword") 	then 	outgoingDamageType = "melee" 	outgoingDamageTier = string.match(mod:GetName(), "%d+")	end
		if string.find(mod:GetName(), "bow") 	then 	outgoingDamageType = "ranged" 	outgoingDamageTier = string.match(mod:GetName(), "%d+") end	
		if string.find(mod:GetName(), "staff")	then 	outgoingDamageType = "mage" 	outgoingDamageTier = string.match(mod:GetName(), "%d+") end
		if string.find(mod:GetName(), "armour") and not string.find(mod:GetName(), "passive")	then outgoingShieldType = "melee" 	outgoingShieldTier = string.match(mod:GetName(), "%d+")	end
		if string.find(mod:GetName(), "hide") 	and not string.find(mod:GetName(), "passive")	then outgoingShieldType = "ranged" 	outgoingShieldTier = string.match(mod:GetName(), "%d+")	end
		if string.find(mod:GetName(), "robes") 	and not string.find(mod:GetName(), "passive")	then outgoingShieldType = "mage" 	outgoingShieldTier = string.match(mod:GetName(), "%d+")	end
	end

	local victimHeroModifiers = victimHero:FindAllModifiers()
	for _, mod in pairs(victimHeroModifiers) do
		if string.find(mod:GetName(), "armour") and not string.find(mod:GetName(), "passive")	then incomingShieldType = "melee" 	incomingShieldTier = string.match(mod:GetName(), "%d+") end
		if string.find(mod:GetName(), "hide") 	and not string.find(mod:GetName(), "passive")	then incomingShieldType = "ranged" 	incomingShieldTier = string.match(mod:GetName(), "%d+") end
		if string.find(mod:GetName(), "robes") 	and not string.find(mod:GetName(), "passive")	then incomingShieldType = "mage" 	incomingShieldTier = string.match(mod:GetName(), "%d+") end
	end


	print("(" .. outgoingShieldType .. "[" .. outgoingShieldTier .. "]) " .. outgoingDamageType .. "[" .. outgoingDamageTier .. "]" .. " -- " .. originalDamage .. " -> (" .. incomingShieldType .. "[" .. incomingShieldTier .. "])")

	-- 20% Damage bonus for matching sheild to weapon
	if outgoingDamageType == outgoingShieldType and outgoingDamageType ~= "nil" and outgoingShieldType ~= "nil" then
		local bonus = 0.1 * outgoingDamageTier
		newDamage = newDamage + (originalDamage * bonus)
		print("+ " .. bonus * 100 .. "% Bonus (weapon + shield match)")

	-- Damage penalty for not matching shield to weapon
	elseif outgoingDamageType ~= outgoingShieldType and outgoingDamageType ~= "nil" and outgoingShieldType ~= "nil" then
		local penalty = (0.5 - (0.1 * outgoingDamageTier))
		newDamage = newDamage - (originalDamage * penalty)
		print("- " .. penalty * 100 .. "% Penalty (weapon + shield mismatch)")

	end

	if outgoingDamageType == incomingShieldType and incomingShieldIType ~= "nil" and outgoingDamageType ~= "nil" then
		local penalty = (0.1 * incomingShieldTier)
		newDamage = newDamage - (originalDamage * penalty)
		print("- " .. penalty * 100 .. "% Penalty (enemy shield block)")
		
	elseif (outgoingDamageType == "melee" and incomingShieldType == "ranged") or 
	(outgoingDamageType == "ranged" and incomingShieldType == "mage") or
	(outgoingDamageType == "mage" and incomingShieldType == "melee") then

		local bonus = (0.5 - (0.1 * incomingShieldTier))
		newDamage = newDamage + (originalDamage * bonus)
		print("+ " .. bonus * 100 .. "% Bonus (enemy shield weakness)")
	end

	print("(" .. outgoingShieldType .. "[" .. outgoingShieldTier .. "]) " .. outgoingDamageType .. "[" .. outgoingDamageTier .. "]" .. " -- " .. newDamage .. " -> (" .. incomingShieldType .. "[" .. incomingShieldTier .. "])")
	
	filterTable['damage'] = newDamage
	return false
end

function CStealingCreationGameMode:DamageFilter_Simple(filterTable)
	--PrintTable(filterTable)

	local attackHero 			= EntIndexToHScript(filterTable['entindex_attacker_const'])
	local victimHero 			= EntIndexToHScript(filterTable['entindex_victim_const'])

	local outgoingDamageTier 	= 0
	local incomingShieldTier 	= 0

	local originalDamage 		= filterTable['damage']
	local newDamage 			= originalDamage

	if not attackHero:IsRealHero() or not victimHero:IsRealHero() then
		return true
	end

	-- find the damage type
	local attackHeroModifiers = attackHero:FindAllModifiers()
	for _, mod in pairs(attackHeroModifiers) do
		if string.find(mod:GetName(), "sword") 	then  	outgoingDamageTier = string.match(mod:GetName(), "%d+")	end
		if string.find(mod:GetName(), "bow") 	then 	outgoingDamageTier = string.match(mod:GetName(), "%d+") end	
		if string.find(mod:GetName(), "staff")	then 	outgoingDamageTier = string.match(mod:GetName(), "%d+") end
	end

	local victimHeroModifiers = victimHero:FindAllModifiers()
	for _, mod in pairs(victimHeroModifiers) do
		if string.find(mod:GetName(), "armour") and not string.find(mod:GetName(), "passive")	then incomingShieldTier = string.match(mod:GetName(), "%d+") end
		if string.find(mod:GetName(), "hide") 	and not string.find(mod:GetName(), "passive")	then incomingShieldTier = string.match(mod:GetName(), "%d+") end
		if string.find(mod:GetName(), "robes") 	and not string.find(mod:GetName(), "passive")	then incomingShieldTier = string.match(mod:GetName(), "%d+") end
	end

	--print("{[" .. outgoingDamageTier .. "]}" .. " -- " .. originalDamage .. " -> ([" .. incomingShieldTier .. "])")

	local bonus 	= 1 - (0.2 * outgoingDamageTier)
	local penalty 	= (0.1 * incomingShieldTier * bonus)

	newDamage = newDamage - (originalDamage * penalty)
	--print("- " .. penalty * 100 .. "% Penalty (enemy shield block)")

	--print("{[" .. outgoingDamageTier .. "]}" .. " -- " .. newDamage .. " -> ([" .. incomingShieldTier .. "])")

	filterTable['damage'] = newDamage
	return true
end