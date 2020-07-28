# Sonic Water
SourceMod plugin for TF2 that makes all water in the game function like that from _Sonic the Hedgehog_ games.

Players are able to stay and swim at the surface of the water, which makes it a lot easier to hop out. While underwater, rather than traditional swimming, players move around like normal in a low-gravity environment. Players only experience 30% of their standard gravity, which means they're able to jump to the surface of the water channels in Well. Since they're also actually properly standing in water, they can also use teleporters underwater.

To recover air, players simply have to surface in any capacity and their air timer will be completely reset. 

There are currently no CVARs or anything to manually adjust the timing short of editing the source - the timing is currently matched to that of Sonic 2 for SEGA Genesis. In the future I'll probably add a CVAR that lets you adjust the air timer.

The use of sounds is also hard-coded into the plugin, and will function fine without it, but will provide no indicators to players of how much time they have left before drowning. This plugin does not add the sounds to the downloads table - you must use [sm_downloader](https://forums.alliedmods.net/showthread.php?p=602270) or a similar plugin to accomplish this.