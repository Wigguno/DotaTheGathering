"use strict";
var localPID;
var localHero;
var interfaceOpen = false;
var InventoryContents 	= [];
var ChestContents 		= [];

function UpdateItems()
{
	for(var i =0; i < 6; i++)
	{
		$("#InventoryContents".concat(i)).itemname = Abilities.GetAbilityName(InventoryContents[i]);
		$("#ChestContents".concat(i)).itemname = Abilities.GetAbilityName(ChestContents[i]);
	}
}

function CheckDistance(entChest)
{
	var localHeroVec 	= Vector.FromArray(Entities.GetAbsOrigin(localHero));
	var invulnUnitVec 	= Vector.FromArray(Entities.GetAbsOrigin(entChest));

	var vecDist = localHeroVec.minus(invulnUnitVec);
	var dist 	= vecDist.length2D();

	//$.Msg("dist to chest: ", dist);
	
	if (dist > 192)
		OnHideHandinHUD();

	if (interfaceOpen == true)
		$.Schedule(0.1, function(){CheckDistance(entChest);});
}

function OnShowHandinHUD(data)
{
	//$.Msg("Showing Handin HUD");
	$.GetContextPanel().SetHasClass("Transform", true);
	$.GetContextPanel().SetHasClass("IsVisible", true);

	InventoryContents 	= [];
	ChestContents 		= [-1, -1, -1, -1, -1, -1];

	for(var i = 0; i < 6; i++)
	{
		var item = Entities.GetItemInSlot( localHero, i );
		InventoryContents[i] = item;		
	}
	UpdateItems();
	interfaceOpen = true;
	$.Schedule(0.1, function(){CheckDistance(data.target_index);});
}

function OnHideHandinHUD()
{
	//$.Msg("Hiding Handin HUD");
	$.GetContextPanel().SetHasClass("Transform", false);
	$.Schedule(0.3, function(){$.GetContextPanel().SetHasClass("IsVisible", false);});
	interfaceOpen = false;
}

function OnInventoryButtonPressed(data)
{
	if (interfaceOpen == true)
	{
		//$.Msg("Inventory Button ", data, " Pressed!");
		if (InventoryContents[data] != -1)
		{
			ChestContents[data] = InventoryContents[data];
			InventoryContents[data] = -1;
			UpdateItems();
		}
	}
}

function OnChestButtonPressed(data)
{
	if (interfaceOpen == true)
	{
		//$.Msg("Chest Button ", data, " Pressed!");
		if (ChestContents[data] != -1)
		{
			InventoryContents[data] = ChestContents[data];
			ChestContents[data] = -1;
			UpdateItems();
		}
	}
}

function OnFinishButton()
{
	//$.Msg("Finish Button Pressed!");
	var DepositItems = [];

	for(var i = 0; i < 6; i++)
	{
		var item = ChestContents[i];
		if (item != -1)
		{
			var itemName = Abilities.GetAbilityName(item);
			if (Entities.HasItemInInventory(localHero, itemName))
			{
				//$.Msg("Depositing ", itemName);
				DepositItems.push(itemName);
			}
		}	
	}

	if (DepositItems.length != 0)
	{
		//$.Msg(DepositItems);
		GameEvents.SendCustomGameEventToServer( "deposit_items", { "item_list" : DepositItems} );
	}
	OnHideHandinHUD();
}

(function() {
	if (GameUI.CustomUIConfig().DebugMessagesEnabled == true)
		$.Msg("Handin HUD Initialised");

	localPID 	= Players.GetLocalPlayer();
	localHero 	= Players.GetPlayerHeroEntityIndex(localPID);

	GameEvents.Subscribe("show_handin_hud", OnShowHandinHUD);
})();