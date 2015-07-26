"use strict";
var localPID;
var localHero;

(function() {
	if (GameUI.CustomUIConfig().DebugMessagesEnabled == true)
		$.Msg("Scoreboard Initialised");

	localPID 	= Players.GetLocalPlayer();
	localHero 	= Players.GetPlayerHeroEntityIndex(localPID);
})();