-- Dota the Gathering
-- By wigguno
-- http://steamcommunity.com/id/wigguno/

-- Ty Based Crazyloon for the name "Dota the Gathering"

-- put the class into the global namespace so our external lua files work
if DTGGameMode == nil then
	_G.DTGGameMode = class({})
end

require ( "libraries/PseudoRNG" )
require ( "libraries/timers" )
require ( "libraries/util" )

require ( "filters" )
require ( "events" )

require ( "spawning" )

function Precache( context )
	-- load the game mode here to precache units used by spawners, etc.
    GameRules.DTGGameMode = DTGGameMode()

    -- precache some models
	PrecacheUnitByNameSync("prop_sc_barrier", context)
	PrecacheUnitByNameSync("prop_sc_crafter", context)
	PrecacheUnitByNameSync("prop_sc_chest", context)
	PrecacheUnitByNameSync("barrier_sc_fence", context)
	PrecacheUnitByNameSync("barrier_sc_door", context)

	PrecacheUnitByNameSync("prop_sc_rags_small_bush_clickable", context)
	PrecacheUnitByNameSync("prop_sc_rags_large_bush_clickable", context)

	PrecacheUnitByNameSync("prop_sc_tree", context)
	PrecacheUnitByNameSync("prop_sc_fish", context)
	PrecacheUnitByNameSync("prop_sc_rock", context)
	PrecacheUnitByNameSync("prop_sc_bird", context)

	PrecacheResource("particle", "particles/highlight_node_1.vpcf", context)
	PrecacheResource("particle", "particles/highlight_node_2.vpcf", context)
	PrecacheResource("particle", "particles/highlight_node_3.vpcf", context)
	PrecacheResource("particle", "particles/highlight_node_4.vpcf", context)
	PrecacheResource("particle", "particles/highlight_node_5.vpcf", context)

	PrecacheResource("particle", "particles/gather_1.vpcf", context)
	PrecacheResource("particle", "particles/gather_2.vpcf", context)
	PrecacheResource("particle", "particles/gather_3.vpcf", context)
	PrecacheResource("particle", "particles/gather_4.vpcf", context)
	PrecacheResource("particle", "particles/gather_5.vpcf", context)

	-- all the particles are defined n the tier 1 items
	PrecacheItemByNameSync("item_sc_sword_tier_1", 	context)
	PrecacheItemByNameSync("item_sc_armour_tier_1", context)

	--[[
	PrecacheItemByNameSync("item_sc_bow_tier_1", 	context)
	PrecacheItemByNameSync("item_sc_staff_tier_1", 	context)

	PrecacheItemByNameSync("item_sc_hide_tier_1", 	context)
	PrecacheItemByNameSync("item_sc_robes_tier_1", 	context)

	PrecacheItemByNameSync("item_sc_sword_tier_2", context)
	PrecacheItemByNameSync("item_sc_sword_tier_3", context)
	PrecacheItemByNameSync("item_sc_sword_tier_4", context)
	PrecacheItemByNameSync("item_sc_sword_tier_5", context)

	PrecacheItemByNameSync("item_sc_bow_tier_2", context)
	PrecacheItemByNameSync("item_sc_bow_tier_3", context)
	PrecacheItemByNameSync("item_sc_bow_tier_4", context)
	PrecacheItemByNameSync("item_sc_bow_tier_5", context)

	PrecacheItemByNameSync("item_sc_staff_tier_2", context)
	PrecacheItemByNameSync("item_sc_staff_tier_3", context)
	PrecacheItemByNameSync("item_sc_staff_tier_4", context)
	PrecacheItemByNameSync("item_sc_staff_tier_5", context)

	PrecacheItemByNameSync("item_sc_armour_tier_2", context)
	PrecacheItemByNameSync("item_sc_armour_tier_3", context)
	PrecacheItemByNameSync("item_sc_armour_tier_4", context)
	PrecacheItemByNameSync("item_sc_armour_tier_5", context)

	PrecacheItemByNameSync("item_sc_hide_tier_2", context)
	PrecacheItemByNameSync("item_sc_hide_tier_3", context)
	PrecacheItemByNameSync("item_sc_hide_tier_4", context)
	PrecacheItemByNameSync("item_sc_hide_tier_5", context)

	PrecacheItemByNameSync("item_sc_robes_tier_2", context)
	PrecacheItemByNameSync("item_sc_robes_tier_3", context)
	PrecacheItemByNameSync("item_sc_robes_tier_4", context)
	PrecacheItemByNameSync("item_sc_robes_tier_5", context)
	]]
end

function Activate()
	GameRules.DTGGameMode:InitGameMode()
end

function DTGGameMode:InitGameMode()
	print( "Loading Dota the Gathering..." )

	math.randomseed(Time())
	self.heroesSpawned = 0

	self:RegisterEventHandlers()
	self:SpawnBaseEntities()

	self.ThinkerTable 		= {}
	self.ScoreTable 		= {}
	self.VoteTable 			= {}
	self.NodeCount 			= 0
	self.EndGameCountdown 	= 30

	self:SetupArena()
	--self:SpawnTestSetup()

	GameRules:SetGoldPerTick( 0 )
	GameRules:SetPreGameTime( 60 * 20 )
	GameRules:SetPostGameTime( 60 )
	GameRules:SetCustomVictoryMessageDuration( 1 )

	GameRules:SetSameHeroSelectionEnabled( true )	
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)

	local mode = GameRules:GetGameModeEntity()
	mode:SetAnnouncerDisabled( true )
	mode:SetFixedRespawnTime( 5 )
	mode:SetCustomHeroMaxLevel( 1 )
	mode:SetUseCustomHeroLevels( true )	

	-- set up the order filter
	mode:SetExecuteOrderFilter( Dynamic_Wrap (DTGGameMode, "ExecuteOrderFilter" ), self )
	mode:SetDamageFilter( Dynamic_Wrap (DTGGameMode, "DamageFilter_Simple" ), self )
	mode:SetThink( "OnThink", self, "GlobalThink", 1 )

	print("Load complete.")
end


function DTGGameMode:OnThink()

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME and not self.EndGameNow == true and self.EndGameCountdown > 0 then

		--print( "Template addon script is running." )

		local deadcount = 0
		for _, thinker in pairs(self.ThinkerTable) do
			--print("thinker thinking...")
			if thinker:IsNull() or not thinker:IsAlive() then
				table.remove(self.ThinkerTable, _ - deadcount)
				deadcount = deadcount + 1
			else
				if thinker.thinker_type == "wanderer" then
					--print("thinker is a bird")
					--print("time: " .. GameRules:GetGameTime() .. ". next wander: " .. thinker.next_wander_time)
					if GameRules:GetGameTime() > thinker.next_wander_time then
						local x = thinker.x + math.random(-1 * thinker.wander, thinker.wander)
						local y = thinker.y + math.random(-1 * thinker.wander, thinker.wander)
						local z = GetGroundHeight(Vector(x, y, 128), nil)

						thinker:MoveToPosition(Vector(x, y, z))
						thinker.next_wander_time = GameRules:GetGameTime() + math.random(5, 10)
					end
				end
			end
		end

		--log("Node Count: " .. self.NodeCount)
		if self.NodeCount == 0 then
			if self.EndGameCountdown == 30 then				
				local event_data =
				{
					text = "Notify_GameEnding",
					duration = 5,
				}
				CustomGameEventManager:Send_ServerToAllClients( "js_notification", event_data )
			end
			self.EndGameCountdown = self.EndGameCountdown - 1
			--log("EndGameCountdown: " .. self.EndGameCountdown)
		end

	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS
	or (GameRules:State_Get() < DOTA_GAMERULES_STATE_POST_GAME and self.EndGameNow == true) 
	or (GameRules:State_Get() < DOTA_GAMERULES_STATE_POST_GAME and self.EndGameCountdown == 0) then
		-- calculate the winrar
		local direPointsTotal 		= 0
		local radiantPointsTotal 	= 0
		
		for pid = 0, 9 do if PlayerResource:IsValidPlayer(pid) then
			local score = RecalculateScore(pid)
			if PlayerResource:GetTeam(pid) == DOTA_TEAM_GOODGUYS then
				radiantPointsTotal = radiantPointsTotal + score
			elseif PlayerResource:GetTeam(pid) == DOTA_TEAM_BADGUYS then
				direPointsTotal = direPointsTotal + score
			end
		end end

		--print("Dire: " .. direPointsTotal)
		--print("Radi: " .. radiantPointsTotal)

		if radiantPointsTotal > direPointsTotal then
			--print("RADIANT WINS")
			GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
			--self:FinishGame()
			--return nil
		end

		if direPointsTotal > radiantPointsTotal then
			--print("DIRE WINS")
			GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
			--self:FinishGame()
			--return nil
		end

	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		--print("ENDING GAME!")
		return nil
	end
	return 1
end