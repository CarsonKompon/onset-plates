# Onset Plates Gamemode
Plates Gamemode by Carson K. for the game [Onset](https://store.steampowered.com/app/1105810/Onset/)

https://www.youtube.com/watch?v=vWBPih-tpes

[![IMAGE ALT TEXT](/screenshots/in-game.png)](https://www.youtube.com/watch?v=vWBPih-tpes)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Inspired by [Plates of Fate](https://www.roblox.com/games/564086481/Plates-of-Fate-Mayhem) and [Lab Experiment](https://www.roblox.com/games/1229173778/Lab-Experiment)

**DISCLAIMER: I HAVE NOT TESTED THIS GAMEMODE IN MULTIPLAYER AS I DON'T HAVE ANYONE ELSE TO TEST WITH. EVERYTHING SHOULD WORK IN THEORY, BUT HASN'T BEEN TESTED EVER. IF YOU'RE INTERESTED IN HELPING ME TEST EVERY ONCE IN A WHILE HIT ME UP ON DISCORD**
 

## Getting Started
- Download the packages [i18n](https://github.com/OnfireNetwork/i18n) and [DialogUI](https://github.com/OnfireNetwork/dialogui) by OnfireNetwork
- Run the included accounts.sql file on a database named "plates"
- Adjust your server's server_config.json to include the following plugins and packages:
```json
"plugins": [
    "mariadb"
],
"packages": [
    "i18n",
    "dialogui",
    "default",
    "plates"
],
```


## Adding Custom Events
In `server\effects.lua` add a new event to it's respective list. Give it a unique name, or just use a number that hasn't been used yet
```lua
_("plate_event_custom")
```

In `i18n\en.json` you can create the event's text.
```json
"plate_event_custom": " Plate(s) will have a custom event in "
```
This text displays like so:
```lua
playerAmount .. EVENT_TEXT .. timeLeft .. "..."
```
So an example of a valid string would be:
```lua
" Plate(s) will receive a spinning death bar in "
```
Which would display as
```
2 Plate(s) will receive a spinning death bar in 3...
```

Finally, you can program what your effect will do back in `server\effects.lua` towards the bottom of `function EffectPlate(player, command)`
```lua
elseif command == commandNumber then
    --Plate Grow x2 EXAMPLE:
    PlayerData[player].plateScale = PlayerData[player].plateScale * 2
end
```
NOTE: `commandNumber` is equal to the event's position in the `events[commandType]` table (Where `commandType` is 1 for Plate/Player Events and 2 for Game Events)
You can test your event in-game with `/effect <commandNumber>`



## Additional Notes

**If you're going to create any Objects, NPCs, or Pickups make sure they get cleaned up where they need to be cleaned up so no additional errors are caused.
Some common cleanup locations are:**
- `OnPlayerQuit` in `server\playerevents.lua`
- `OnPlayerDeath` in `server\playerevents.lua`
- `CheckGameOver` in `server\game.lua` (Ends game)
- `ResetPlate` in `server\plates.lua` (Called when plate is destroyed or reset `/effect 20`)



## Events

Server-Side Events:
- `OnPlateGameStart`
- `OnPlateGameEnd`



## Support
- [Twitter @CarsonKompon](https://twitter.com/CarsonKompon)
- Discord @Carson#1111
