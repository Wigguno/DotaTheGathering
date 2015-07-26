"use strict";
var localPID;
var localHero;

function OnMouseOverBlock(tier)
{
	$.Msg("Mouse over tier " , tier, " block image.")
}

function OnScoreTableChanged( table_name, key, data)
{
	if (key == "player_".concat(localPID))
	{
		//$.Msg( "Table ", table_name, " changed: '", key, "' = ", data );
		$("#ClayScoreDisplay1").text = data.score
	}
}

// Called with the gather table is updated at all
function OnGatherTableChanged( table_name, key, data )
{
	//$.Msg( "Table ", table_name, " changed: '", key, "' = ", data );
	if(key == "type_1")
	{
		$("#ClayCountDisplay1").text = data.count.toString();
	}
	else if(key == "type_2")
	{
		$("#ClayCountDisplay2").text = data.count.toString()
	}
	else if(key == "type_3")
	{
		$("#ClayCountDisplay3").text = data.count.toString()
	}
	else if(key == "type_4")
	{
		$("#ClayCountDisplay4").text = data.count.toString()
	}
	else if(key == "type_5")
	{
		$("#ClayCountDisplay5").text = data.count.toString()
	}
	else
		$.Msg("UNRECOGNISED GATHER TYPE")
}

// This function is called at the start
(function() {
	if (GameUI.CustomUIConfig().DebugMessagesEnabled == true)
		$.Msg("Inventory HUD Initialised");

	localPID = Players.GetLocalPlayer();
	localHero = Players.GetPlayerHeroEntityIndex(localPID);

	CustomNetTables.SubscribeNetTableListener( "gather_table_p".concat(localPID), OnGatherTableChanged );
	CustomNetTables.SubscribeNetTableListener( "score_table", OnScoreTableChanged );

})();