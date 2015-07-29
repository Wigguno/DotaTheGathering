# Dota the Gathering
Dota 2 Reborn custom game based on Stealing Creation from RuneScape

Workshop page: http://steamcommunity.com/sharedfiles/filedetails/?id=488989532

# Interesting code snippets
## Right Click - Use
Right click use is accomplished by creating every interactive object as a creature with an invulnerable modifier. (game/dota_addons/dota_the_gathering/scripts/vscripts/spawning.lua)
Right clicks are captured using a mouse callback in Panorama, and modified to move-click orders. (content/dota_addons/dota_the_gathering/panorama/scripts/custom_game/stealing_creation_click_modifier.js)
Move-clicks are captured using an order-filter in lua, and if the hero is close enough to the unit, behaviour is executed(game/dota_addons/dota_the_gathering/scripts/vscripts/filters.lua)

## Custom Settings Votes
These are loaded using the panorama layout file (content/dota_addons/dota_the_gathering/panorama/layout/custom_game/gamesetup_options.xml)
The vote event is handled in DTGGameMode:OnSettingVote(), in events.lua (game/dota_addons/dota_the_gathering/scripts/vscripts/events.lua)
When the game state changes to Hero Select, the votes are tallied and acted upon (DTGGameMode:OnGameRulesStateChange in events.lua)