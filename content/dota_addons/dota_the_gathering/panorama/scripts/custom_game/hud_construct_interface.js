"use strict";

var localPID;
var localHero;
var interfaceOpen = false;

function CheckDistance(entCrafter)
{
	var localHeroVec 	= Vector.FromArray(Entities.GetAbsOrigin(localHero));
	var invulnUnitVec 	= Vector.FromArray(Entities.GetAbsOrigin(entCrafter));

	var vecDist = localHeroVec.minus(invulnUnitVec);
	var dist 	= vecDist.length2D();

	//$.Msg("dist to crafter: ", dist);
	
	if (dist > 320)
		OnHideConstructHUD();

	if (interfaceOpen == true)
		$.Schedule(0.1, function(){CheckDistance(entCrafter);});
}

function OnShowConstructHUD(data)
{
	//$.Msg("Showing Construct HUD");
	$.GetContextPanel().SetHasClass("Transform", true)
	$.GetContextPanel().SetHasClass("IsVisible", true)

	interfaceOpen = true;
	$.Schedule(0.1, function(){CheckDistance(data.target_index);});

	var fishLevel 	= Abilities.GetLevel( Entities.GetAbility( localHero, 0 ) );
	var wcLevel 	= Abilities.GetLevel( Entities.GetAbility( localHero, 1 ) );
	var mineLevel 	= Abilities.GetLevel( Entities.GetAbility( localHero, 2 ) );
	var huntLevel 	= Abilities.GetLevel( Entities.GetAbility( localHero, 3 ) );

	$("#AbilityCostLabel1").text = $.Localize("#CostTier".concat(fishLevel, "Ability"));
	$("#AbilityCostLabel2").text = $.Localize("#CostTier".concat(wcLevel, "Ability"));
	$("#AbilityCostLabel3").text = $.Localize("#CostTier".concat(mineLevel, "Ability"));
	$("#AbilityCostLabel4").text = $.Localize("#CostTier".concat(huntLevel, "Ability"));

	if (fishLevel < 4)
		$("#AbilityUpgradeLabel1").text = "+";
	else
		$("#AbilityUpgradeLabel1").text = "x";

	if (wcLevel < 4)
		$("#AbilityUpgradeLabel2").text = "+";
	else
		$("#AbilityUpgradeLabel2").text = "x";
	

	if (mineLevel < 4)
		$("#AbilityUpgradeLabel3").text = "+";
	else
		$("#AbilityUpgradeLabel3").text = "x";


	if (huntLevel < 4)
		$("#AbilityUpgradeLabel4").text = "+";
	else
		$("#AbilityUpgradeLabel4").text = "x";

}

function OnHideConstructHUD()
{
	//$.Msg("Hiding Construct HUD");
	$.GetContextPanel().SetHasClass("Transform", false)
	interfaceOpen = false;
	$.Schedule(0.3, function(){$.GetContextPanel().SetHasClass("IsVisible", false);});
}

function OnUpgradeAbility(abil_index)
{
	//$.Msg("Ability Upgrade Button Pressed");
	var ability 		= Entities.GetAbility(localHero, abil_index);
	var abilityName 	= Abilities.GetAbilityName( ability );
	GameEvents.SendCustomGameEventToServer( "upgrade_ability", { "ability_name" : abilityName} );
}

var itemTable = ["sword", "bow", "staff", "armour", "hide", "robes", "barrier"]
function OnBuyButtonPressed(index, tier)
{	
	// indices: 1:Sword, 2:Bow, 3:Staff, 4:Armour, 5:Hide, 6:Robes, 7:Barrier

	//$.Msg("Buy Button Index ", index, " - tier: ", tier);
	GameEvents.SendCustomGameEventToServer( "purchase_item", {"item_name":itemTable[index - 1], "item_tier":tier})
}

// This function is called at the start
(function() {
	if (GameUI.CustomUIConfig().DebugMessagesEnabled == true)
		$.Msg("Construct HUD Initialised");

	localPID = Players.GetLocalPlayer();
	localHero = Players.GetPlayerHeroEntityIndex(localPID);

	GameEvents.Subscribe("show_construct_hud", OnShowConstructHUD);
})();