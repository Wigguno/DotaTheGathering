/* 
	modify some right clicks on certain entities
*/

"use strict";

var CONSUME_EVENT = true;
var CONTINUE_PROCESSING_EVENT = false;

// Handle Left Button events
function OnLeftButtonPressed()
{
	//$.Msg("LEFT BUTTON CAST")
}

// Handle the invuln unit right-click behaviour
// (transform right-clicks to m-clicks, with a queued m-click once the hero is close)
function InvulnEntityClicked(localHeroIndex, targetEntIndex)
{
	//$.Msg("Processing invuln click event in JS")

	// Find the distance between the hero and the invuln entity
	var localHeroVec 	= Vector.FromArray(Entities.GetAbsOrigin(localHeroIndex));
	var invulnUnitVec 	= Vector.FromArray(Entities.GetAbsOrigin(targetEntIndex));

	var vecDist = localHeroVec.minus(invulnUnitVec);
	var dist = vecDist.length2D();

	//$.Msg(dist)

	var orderMove = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_TARGET,
		TargetIndex : targetEntIndex,
		Queue : false,
		ShowEffects : true
	};

	var orderStop = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_STOP,
		TargetIndex : targetEntIndex,
		Queue : false,
		ShowEffects : true
	};

	if (dist < 192)
	{	
		// if the hero is close, then just change it to an m-click
		Game.PrepareUnitOrders( orderStop );
		Game.PrepareUnitOrders( orderMove );
	}
	else
	{
		// if the hero is far, change it to an m-click, and queue another m-click once the hero gets close
		Game.PrepareUnitOrders( orderMove );

		orderMove.Queue = true;
		Game.PrepareUnitOrders( orderMove );

	}

}

// Handle Right Button events
// Find any entities right-clicked on
// if the units are invuln, modify the right-click behaviour
function OnRightButtonPressed()
{
	//$.Msg("RIGHT BUTTON CAST")
	var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	var mouseEntities = GameUI.FindScreenEntities( GameUI.GetCursorPosition() );
	mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex != localHeroIndex; } );

	var accurateEntities = mouseEntities.filter( function( e ) { return e.accurateCollision; } );
	if ( accurateEntities.length > 0 )
	{
		for ( var e of accurateEntities )
		{
			//$.Msg("ACCURATE ENTITY")
			if ( Entities.IsInvulnerable( e.entityIndex ) )
			{
				//$.Msg("INVULNERABLE UNIT CLICKED")
				InvulnEntityClicked(localHeroIndex, e.entityIndex);
				return CONSUME_EVENT;
			}
		}
	}

	if ( mouseEntities.length > 0 )
	{
		//$.Msg("ENTITY")
		var e = mouseEntities[0];
		if ( Entities.IsInvulnerable( e.entityIndex ) )
		{
			//$.Msg("INVULNERABLE UNIT CLICKED")
			InvulnEntityClicked(localHeroIndex, e.entityIndex);
			return CONSUME_EVENT;
		}
	}

	return CONTINUE_PROCESSING_EVENT;
}


// Main mouse event callback
GameUI.SetMouseCallback( function( eventName, arg ) {

	//$.Msg("MOUSE: ", eventName, " -- ", arg, " -- ", GameUI.GetClickBehaviors())

	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
		return CONTINUE_PROCESSING_EVENT;

	if ( eventName === "pressed" || eventName === "doublepressed")		
	{
		//$.Msg("MOUSE: ", eventName, " -- ", arg, " -- ", GameUI.GetClickBehaviors())

		// on right click, call the right-click function
		if ( arg === 1 )
		{	
			//$.Msg("RIGHT BUTTON CAST")
			return OnRightButtonPressed();
		}
	}
	return CONTINUE_PROCESSING_EVENT;
} );

(function() {
	if (GameUI.CustomUIConfig().DebugMessagesEnabled == true)
		$.Msg("Right Click Override JS Loaded.");
	
})();