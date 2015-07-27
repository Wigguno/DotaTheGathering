-- Stealing Creation
-- By wigguno
-- http://steamcommunity.com/id/wigguno/


-- Lua Gathering
-- these functions are called by RunScript blocks from the helper ability

function killNode(node)
	if node.node_type == "node_pond" then
		local prop_water = EntIndexToHScript(prop_pond_base.prop_water)
		prop_water:RemoveAbility("ability_sc_fogged_prop")
		prop_water:RemoveModifierByName("modifier_sc_fogged_prop")
		prop_water:ForceKill(false)		
	end
	
	node:RemoveAbility("ability_sc_node_prop")
	node:RemoveModifierByName("modifier_sc_prop")
	node:ForceKill(false)

	local mode = GameRules.stealing_creation
	mode.NodeCount = mode.NodeCount - 1
end

function GatherClay(clayLevel, gatherCount, gatherPlayer, gatherHero)
	local oldTable = CustomNetTables:GetTableValue("gather_table_p" .. gatherPlayer, "type_" .. clayLevel)
	CustomNetTables:SetTableValue("gather_table_p" .. gatherPlayer, "type_" .. clayLevel, {count=oldTable.count+gatherCount})

	local part = ParticleManager:CreateParticle("particles/gather_" .. clayLevel .. ".vpcf", PATTACH_ABSORIGIN_FOLLOW, gatherHero)
	ParticleManager:SetParticleControl(part, 0, gatherHero:GetAbsOrigin())
	ParticleManager:SetParticleControl(part, 1, Vector(1,0,0))

end

function OnGather_1(keys)
	OnGather(keys, 1)
end

function OnGather_2(keys)
	OnGather(keys, 2)
end

function OnGather_3(keys)
	OnGather(keys, 3)
end

function OnGather_4(keys)
	OnGather(keys, 4)
end

function OnGather_5(keys)
	OnGather(keys, 5)
end

function OnGather(keys, tier)
	--PrintTable(keys)
	local gatherHero 		= EntIndexToHScript(keys.caster_entindex)
	local gatherNode 		= EntIndexToHScript(gatherHero.gather_node)
	local gatherNode_Health = gatherNode:GetHealth()
	local pid 				= gatherHero:GetPlayerID()

	if gatherNode_Health == 0 then
		gatherHero:RemoveModifierByName("modifier_gathering_node_" .. tier)
		return 
	end

	if tier == 1 or gatherHero.gather_chance:Next() then
		local mode = GameRules.stealing_creation
		mode.ScoreTable[pid]["type" .. tier] = mode.ScoreTable[pid]["type" .. tier] + 1
		mode.ScoreTable[pid]["score"] = RecalculateScore(pid)
		--print("[" .. pid .. "] newscore: " .. mode.ScoreTable[pid]["score"])
		CustomNetTables:SetTableValue("score_table", "player_" .. pid, mode.ScoreTable[pid])

		if gatherNode_Health == 1 then
			--print("Killing node")
			killNode(gatherNode)
			gatherHero:RemoveModifierByName("modifier_gathering_node_" .. tier)
			RemoveHighlightNode(keys)
		end

		gatherNode:SetHealth(gatherNode_Health - 1)

		-- Give the person +1 mat
		local pid = gatherHero:GetPlayerID()
		GatherClay(tier, 1, pid, gatherHero)
	end
end

function CreateHighlightNode(keys)
	local gatherHero 	= EntIndexToHScript(keys.caster_entindex)
	local gatherNode 	= EntIndexToHScript(gatherHero.gather_node)
	local gatherPlayer 	= PlayerResource:GetPlayer(gatherHero:GetPlayerID())
	local nodeLoc 		= gatherNode:GetAbsOrigin()
	local attach 		= PATTACH_ABSORIGIN_FOLLOW
	local gather_level 	= tostring(gatherNode.target_level)
	local part_path		= "particles/highlight_node_" .. gather_level .. ".vpcf"

	local part = ParticleManager:CreateParticleForPlayer(part_path, attach, gatherNode, gatherPlayer)
	ParticleManager:SetParticleControl(part, 0, nodeLoc)

	gatherHero.HighlightNodeParticle = part
end

function RemoveHighlightNode(keys)
	local gatherHero 	= EntIndexToHScript(keys.caster_entindex)
	ParticleManager:DestroyParticle(gatherHero.HighlightNodeParticle, false)
end