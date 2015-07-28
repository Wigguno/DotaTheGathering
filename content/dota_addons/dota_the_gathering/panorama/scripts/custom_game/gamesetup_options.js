"use strict";

function OnVoteButtonPressed(category, vote)
{
	//$.Msg("Category: ", category);
	//$.Msg("Vote: ", vote);
	GameEvents.SendCustomGameEventToServer( "setting_vote", { "category":category, "vote":vote } );
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