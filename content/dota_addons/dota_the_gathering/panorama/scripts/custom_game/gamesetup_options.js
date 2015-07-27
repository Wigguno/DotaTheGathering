"use strict";

function OnGLRadioButton(data)
{
	//a$.Msg("Game Length Radio Pressed: ", data);
	GameEvents.SendCustomGameEventToServer( "setting_vote", { "category":"game_length", "vote":data } );
}

function OnCSRadioButton(data)
{
	//$.Msg("Combat System Radio Pressed: ", data);
	GameEvents.SendCustomGameEventToServer( "setting_vote", { "category":"combat_system", "vote":data } );
}

// This function is called at the start
(function() {
	if (GameUI.CustomUIConfig().DebugMessagesEnabled == true)
	{
		$.Msg("GameSetup Options Initialised");
		Game.SetRemainingSetupTime( -1 );
		Game.SetAutoLaunchEnabled( false );
	}

})();