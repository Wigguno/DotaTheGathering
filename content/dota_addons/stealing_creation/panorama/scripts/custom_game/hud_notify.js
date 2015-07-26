"use strict";

var localPID;
var localHero;
var notifyDuration = 0;

function NotifyTimer()
{
	//$.Msg("tick: ", notifyDuration);
	if (notifyDuration > 0)
	{
		notifyDuration = notifyDuration - 1;
	}
	if (notifyDuration <= 0)
	{
		$.GetContextPanel().SetHasClass("IsVisible", false);
	}
	$.Schedule(0.1, function(){NotifyTimer();});
}

function OnNotify(event_data)
{
	//$.Msg( "OnNotify: " , event_data );
	//$.Msg("#".concat(event_data.text));
	$("#NotifyLabel1").text = $.Localize("#".concat(event_data.text));
	$.GetContextPanel().SetHasClass("IsVisible", true);

	notifyDuration = event_data.duration * 10
}

// This function is called at the start
(function() {
	if (GameUI.CustomUIConfig().DebugMessagesEnabled == true)
		$.Msg("Notification HUD Initialised");

	localPID = Players.GetLocalPlayer();
	localHero = Players.GetPlayerHeroEntityIndex(localPID);
	$.Schedule(0.1, function(){NotifyTimer();});

	GameEvents.Subscribe( "js_notification", OnNotify);
})();