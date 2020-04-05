# [MOD] Half Life: Alyx - XenThug
A Half Life: Alyx Mod including a classic wave defense gamemode

It is currently work in progress and will receive frequent updates. 
Right now the mod supports:
- Spawning different kind of waves, respawning new enemies when nobody is alive anymore
- Drops polymer as a currency on the death of an enemy
- Has vending machines at which the player can buy ammo/health for polymer
- Endless mode, if all map-defined waves got spawned it starts over again, but doubles the enemies life each time!
- Portable to any map without a ton of work!

https://www.youtube.com/watch?v=UeSIuSt_FSo&feature=youtu.be

Here is a list of the currently available maps:

- **Test map:** This map is simply a proof of concept and is contained in the testmap.zip! To play the map simply place the content of this zip file inside your Half-Life Alyx/game/hlvr folder, and in steam add a "+map invasion01" startup parameter to Half Life:Alyx! (And no, it will not break your game, simply remove the startup parameter to play the normal game again)

### [ROADMAP, Version 0.1]

##### Features coming soonTM:
- Fix spawn positions of items in shops
- Fix spawn positions of polymers on kills
- Add shops for the following Items: trip mines, grenades, xen grenades
- Make shop prices customizeable for mappers
- Implement a configurable drop chance for polymers
- Implement a configurable amount of polymers per kill
- Add a break function to give the player time to buy stuff after each wave

##### Features coming after soonTM
- Fix navmesh for Zombies and Combines
- Integrate scriptable Output callbacks, for example after a wave died to call custom functions
- Add a framework for showing text ingame, for example for shops
- Optimize code and serialize everything
- And more stuff, not writing everything down yet

### [FOR MAPPERS, Version 0.1]
In order to enable this Mod on your custom Map you have to follow 3 simple steps:

#### I. **Files**
Simply copy the included "scripts" folder into your game/hlvr/ folder.

#### II. **Mod Settings**
All Settings which are useful for you as a mapper can be found inside the mapdata.lua, which can be found 
under /scripts/vscripts/. In This file you can currently edit the following options:

##### **[MyPolymer]** 
The amount of Polymer the player will start with.

##### **[WaveModifier]** 
This Value defines the difficulty with which the game starts with. The health of NPCs will be multiplied by this value.

##### **[WaveList]** 
In this list you can find multiple blocks of numbers. Each block encolsed in {} brackets is refering to one wave. Each number inside such a block represents the amount of enemies to spawn for this wave. I've formatted the waves in a table format so you can simply see which number represents which enemy. Here is an example:

```
-- 	Crab		ArmorCrab	PoisonCrab	???		RunnCrab	BlackCrab
--	Zombie		Jeff		Antlion		???		???		???
--	Combine		Combine S	Manhack		???		???		???

--Defines how many of each enemy type should be in each wave
_G.WaveList = {
	
  --THIS IS WAVE/BLOCK 1
	{5, 		0, 		0, 		0, 		0, 		0,
	 0, 		0, 		0, 		0, 		0, 		0,
	 0, 		0, 		1, 		0, 		0, 		0},
	 
   --THIS IS WAVE/BLOCK 2
	 {2, 		5,		1,		0, 		0, 		0,
	 0, 		0, 		0, 		0, 		0, 		0,
	 0, 		0, 		0, 		0, 		0, 		0},
}
```
As you can see in this example we are spawning 5 normal headcrabs and one manhack in the first wave.
The second wave spawns 2 headcrabs, 5 armored headcrabs and 1 poisonous headcrab.

For now don't try to spawn more than 80 per wave as it can result in quite bad lag.

#### III. **Markers and Triggers**
Now let's start Hammer and open up your custom map. We will have to set a few triggers and landmarks to get everything going.

##### General Triggers
1. So in order to get everything started let's create a trigger which should be activated right when the player spawns, thus directly set it onto the *info_player_start* entity.
2. Make sure its class is *trigger_once*, and set its Name to *SpawnTrigger*.
3. Open up the triggers *Properties* and go to *Outputs*
4. Add a new output with the following settings:
  - My output named:        OnTrigger
  - Target entities named:  SpawnTrigger
  - Via this input:         RunScriptCode
  - With a parameter:       SendToConsole("script_reload_code initGamemode")
  - Delay:                  0
  - Fire only once:         Yes

1. Let's setup the next trigger. This trigger should include your WHOLE map, every bit where the player might be in.
2. Make sure its class is *trigger_multiple* and set its Name to *UpdateTrigger*.
3. Set its "Delay Before Reset" to 1
4. Open up the triggers *Properties* and go to *Outputs*
5. Add a new output with the following settings:
  - My output named:        OnTrigger
  - Target entities named:  UpdateTrigger
  - Via this input:         RunScriptCode
  - With a parameter:       SendToConsole("script_reload_code myGamemode")
  - Delay:                  0
  - Fire only once:         No
  
##### Landmarks
Now you will have to define where your enemies should spawn. For this you have to create one or multiple *info_landmark*. Make sure you name all of these landmarks *EnemySpawn*. Hammer will mark the name orange, but you can ignore that.

*That is it! If you startup your map now it should start spawning the waves you defined. All further steps are optional, but I recommend them to improve your gameplay experience!*

##### Shopsystem & Economy
Since you can walk around and fight enemies your player will run out of ammo, no matter how much you will initally give him. Thus I've implemented a shopsystem, this will enable you to create vending machines which will sell ammunition and health to the player once the bumps into them. The currency is polymer and enemies are dropping that once killed. (Currently you can't set how often they drop polymers, nor how much they drop as it is bugged.)

A vending machine consists out of a *trigger_multiple* and an *info_landmark*. Each type of Vending machine can only exist ONCE, here are all types which are available right now:

```
AmmoVender		--Spawns a pistol mag, costs 1 polymer
	RunScriptCode:	 _G.BuyAmmo(false)
	
ShellVender		--Spawns two shotgun shells, costs 1 polymer
	RunScriptCode:	 _G.BuyShells(false)	
	
EnergyVender		--Spawns one smg energy cell, costs 3 polymer
	RunScriptCode:	 _G.BuyEnergy(false)
	
MedkitVender		--Spawns one healing syringe, cost 2 polymer
	RunScriptCode:	 _G.BuyMedkit(false)
	
HealthVender		--Spawns a vial which is used in combines healing stations, costs 8 polymer
	RunScriptCode:	 _G.BuyHealth(false)
	
More to be added soon
```

Let's go through the process of creating a vending machine:

1. Create an object for your vender. You can design it in any way you like it to. It could be even a NPC. In this example I simply used some cubes creating a hollow area.
2. Create a *info_landmark* and place it where the vender should spawn the bought items. Set the landmarks Name to its type, for example *AmmoVender*.
3. Create a *trigger_multiple* in front of it. Each time the player runs into it, it will take X polymers from the player and spawn the desired item. The trigger should be higher than the player, and as wide as the vending machine.
4. Go to its properties to Outputs and add a new output like the following:
  - My output named:        OnTrigger
  - Target entities named:  AmmoVender		<<<<<---- set here the correct type instead!
  - Via this input:         RunScriptCode
  - With a parameter:       _G.BuyAmmo(false)
  - Delay:                  0
  - Fire only once:         No

You should be able to buy ammo on this vender now once you are ingame! Of course only if you have enough polymer. Example of a shop setup:

![ALT TEXT An Image of a crappy looking vender](http://cvreleague.eu/wp-content/uploads/2020/04/Unbenannt.png)

**That's everything you need to know about this mod for this version!**

Do you have questions? Reach out to me in Discord! (Manello#1406)
If you are in general interested in updates for this and my future mods follow me on [Twitter](https://twitter.com/manellomb/)!
And if you have questions about mapping or modding in general, please join this [Discord](https://discord.gg/Yt86zaG)!
