## [FOR MAPPERS, Version 0.4]

**NOTE: Updated VMap with an example of all features will follow again very soon!**

In order to enable this Mod on your custom Map you have to follow 3 simple steps:

### I. **Files**
Simply copy the included "scripts" folder into your game/hlvr/ folder.

#### Important files for you
**mapdata.lua** contains basic informations about the gamemode and the waves, everything will be covered here

**mapscript.lua** makes it possible to insert custom scripts and events into this mod, though you will need to understand scripting a bit to use it. All informations needed are included in the file itself.

### II. **Mod Settings**
All Settings which are useful for you as a mapper can be found inside the mapdata.lua, this file can be found 
under /scripts/vscripts/. In This file you can currently edit the following options:

##### **[EnablePerformanceMode]**
This will slow down the mod decreasing it's CPU usage, but it will cause graphical artifacts. Only turn it to true it if you really need it!

##### **[DebugEnabled]**
Shows useful information for mappers in the VConsole2. You should disable this upon release of your map

##### **[MyPolymer]** 
The amount of Polymer the player will start with. 

ATTENTION: You are allowed to place Polymers on the map in Hammer, but DO NOT spawn them with your custom scripts(including impulse 101)! This will corrupt XenThug's economy system and leads to a bad player experience! Also, do not set the initial polymers through the info_player_equip class! Use MyPolymers in mapdata.lua instead.

##### **[StartDelay]**
The time the player will have to explore the level before the first wave arrives

##### **[WaveDelay]**
The time the player will have to breathe after he killed a wave. After this time the next wave spawns in

##### **[WaveModifier]** 
This Value defines the difficulty with which the game starts with. The health of NPCs will be multiplied by this value.

##### **[PolymerDropChance]**
This value defines the chance of an emeny dropping polymer upon his death

##### **[WaveFinishSound]**
This sound is played once a wave has been eliminated

##### **[WaveStartSound]**
This sound is played once a wave has been spawned

#### **[WaveList]** 
In this list you can find multiple blocks of numbers. Each block encolsed in {} brackets is refering to one wave. Each number inside such a block represents the amount of enemies to spawn for this wave. I've formatted the waves in a table format so you can simply see which number represents which enemy. Here is an example:

```
-- 	Crab		ArmorCrab	PoisonCrab	???		RunnCrab	BlackCrab
--	Zombie		Jeff		Antlion		???		???		???
--	???		CombineGrunt	Manhack		CombineHeavy	CombineSuppres	CombineCaptain

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

#### **[UseSpawnGroups] 0.32 - Optional**
If set to true you will need to configure the advanced spawning system like seen below. On false it spawns enemies randomly at any landmark whichs name starts with EnemySpawn

#### **[SpawnGroup] 0.32 - Optional**
This configuration is only required if UseSpawnGroups is set to true. This system allows you to enable/disable SpawnGroups. This can be used for example to create an unlockable room in your level and only start spawning enemies in there once the player unlocked it.

The second feature of this new implementation is that you can define the enemy types which should spawn per SpawnGroup. Each spawning destination now has an assigned SpawnGroup, thus you can define which enemies should spawn in each location.

The table below has the same structure as seen in **WaveList**, simply defining which enemy types can spawn at landmarks which are assigned to this SpawnGroup. For example, all spawn landmarks named *EnemySpawn_Mixed* will only spawn zombies, antlions and manhacks. Landmarks named "EnemySpawn_Combine" will only spawn combines and manhacks.

```
-- 	Crab		ArmorCrab	PoisonCrab	???		RunnCrab	BlackCrab
--	Zombie		Jeff		Antlion		???		???		???
--	???		CombineGrunt	Manhack		CombineHeavy	CombineSuppres	CombineCaptain

_G.SpawnGroup = {
	Mixed = { Enabled = true,				--Will only use this group when it is enabled
	false,	false, 	false, 	false, 	false, 	false,	--Spawns only zombies, antlions and manhacks
	true, 	true, 	true, 	true, 	true, 	true,
	false, 	false, 	true, 	true, 	true, 	true
	},
	
	CrabGroup = { Enabled = true,
	true,	true, 	true, 	true, 	true, 	true,	--Spawns only crabs
	false, 	false, 	false, 	false, 	false, 	false,
	false, 	false, 	false, 	false, 	false, 	false
	},
	
	Combine = { Enabled = true,
	false,	false, 	false, 	false, 	false, 	false,	--Spawns only Combines and Manhacks
	false, 	false, 	false, 	false, 	false, 	false,
	false, 	true, 	true, 	false, 	false, 	false
	},
```

If you look at the table above, Enable simply defines if this SpawnGroup should be able to spawn enemies upon starting the map. You want this to be disabled in rooms which the player has to unlock first. To enable or disable you can use the following command which you have to use in one of your Outputs on the map as RunScriptCode:

```
EnableSpawnGroup(groupname, enabled)
Examples:
EnableSpawnGroup("Mixed", true)	=> will enable the Mixed spawn group, thus all EnemySpawn_Mixed landmarks will spawn their respective entities on the next wave
EnableSpawnGroup("Combine", false) => will disable the Combine spawn group, thus all EnemySpawn_Combine landmarks won't spawn anything on the next wave
```

A detailed example map will follow for mappers very soon!


#### **[Vender]**
This array stores all of your customized shops. It is very easy to use, feel free to add as many new shops as you like to.
```
_G.Vender = {
	{Name = "Vender_Ammo",						--The shop spawner landmarks name
	Item = "item_hlvr_clip_energygun",				--The item to sell
	Prototype = "",							--Custom Prototype, not supported yet, leave blank
	Price = 1,							--Number of Polymers needed
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",	--Sound playing when selling something
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",	--Sound playing when player has not enough money
	Entity = {},							--DO NOT CHANGE Entity
	InUse = false},							--DO NOT CHANGE InUse
```
As you can see the first entry defines a shop which will spawn pistol ammo. In the future "prototypes" will be supported, thus you could even spawn newspapers if you want to. (Yes you will be also able to buy NPCs here in theory). 

You can find more infos on how to set up shops in hammer below.

### III. **Markers and Triggers**
Now let's start Hammer and open up your custom map. We will have to set a few triggers and landmarks to get everything going.

##### Spawn Trigger
1. So in order to get everything started let's create a trigger which should be activated right when the player spawns, thus directly set it onto the *info_player_start* entity. (If you want to include a "preperation room" where the mod shouldn't start, just place the trigger on the exit)
2. Make sure its class is *trigger_once*, and set its Name to *SpawnTrigger*.
3. Open up the triggers *Properties* and go to *Outputs*
4. Add a new output with the following settings:
  - My output named:        OnTrigger
  - Target entities named:  SpawnTrigger
  - Via this input:         RunScriptCode
  - With a parameter:       SendToConsole("script_reload_code initXenThug")
  - Delay:                  0
  - Fire only once:         Yes
  
##### Landmarks
Now you will have to define where your enemies should spawn. For this you have to create one or multiple *info_landmark*. Make sure you name all of these landmarks *EnemySpawn*. Hammer will mark the name orange, but you can ignore that.

Note: You should leave enough space around each landmark so enemies won't bug into walls or objects. A radius of 40 inches around the spawn is recommended.

##### Respawn menu 0.4
As of 0.4 you will need to create a info_landmark with the name *PlayerMenu*, upon death the player will get teleported there.
You can in theory create your own respawn menu there, I recommend placing another scoreboard there, as well as some useable triggers to restart the map, go to the main menu and to quit the game.

*That is it! If you startup your map now it should start spawning the waves you defined. All further steps are optional, but I recommend them to improve your gameplay experience!*

### Shopsystem & Economy
Since you can walk around and fight enemies your player will run out of ammo, no matter how much you will initally give him. Thus I've implemented a shopsystem, this will enable you to create customizeable vending machines which will sell anything you want to the player once he activates its trigger. The currency is polymer and enemies are dropping that once killed. 

A vending machine consists out of a *trigger_multiple* (You can also use buttons, or anything that can fire *Outputs*) and an *info_landmark*. You can define custom venders like shown above, however keep in mind that each vender needs it's own triggers, landmarks and his own entry in the *Vender* array. 

```
UseVender("Vender_YOUR_VENDER_NAME")
```

Let's go through an example for the process of creating a vending machine:

1. Create an object for your vender. You can design it in any way you like it to. It could be even a NPC. In this example I simply used some cubes creating a hollow area.
2. Create a *info_landmark* and place it where the vender should spawn the bought items. Set the landmarks Name to how you named it in the script, for example *Vender_Ammo*. ATTENTION: You have to start the name with *Vender_*, otherwise my Mod can't find your shop.
3. Create a *trigger_multiple* in front of it. Each time the player runs into it, it will take X polymers from the player and spawn the desired item.
4. Go in the trigger properties to outputs and add a new output like the following:
  - My output named:        OnTrigger
  - Target entities named:  Vender_Ammo		<<<<<---- set here the correct name of the vender instead!
  - Via this input:         RunScriptCode
  - With a parameter:       UseVender("Vender_Ammo")	<<<- Set here the name of your Vender landmark
  - Delay:                  0
  - Fire only once:         No

You should be able to buy ammo on this vender now once you are ingame! Of course only if you have enough polymer. Example of a shop setup:

![ALT TEXT An Image of a crappy looking vender](http://cvreleague.eu/wp-content/uploads/2020/04/Unbenannt.png)

Inspiration: Make something like a food vending machine in an office building! This way you can include multiple shops in one if you want to.

### Custom buy functions 0.4
The custom buy functions will be needed for example for buyable map expansions, thus if you want to create an unlockable room, or make any other trigger purchaseable. You will need to create 3-4 lines of custom scripts to use this feature:
```
CanBuyFor(5)		=>This function will return true if the player has at least 5 Polymers in his inventory, otherwise false
BuyFor(5)		=>This function will return true if it succesfully removed 5 polymers from the players inventory. otherwise false

Example Usage:
if CanBuyFor(5) == true then
	BuyFor(5)
	-- Do your stuff you want to do right here, e.g. disabling a blockade
end
```

### Scripting addon 0.35
The way to interact with my mod is currently wip, but you can already use certain features. I highly recommend using my CommandStack.Add in general instead of SendToConsole, as it will make sure you are not interfering with my mod.

**Console Command:** In order to run a console command simply make any trigger with the output RunScriptCode with the parameter *CommandStack.Add("your console command here")*. It will execute the command as soon as the mod has time for it. (A matter of a few frames at max)

**Delayed Console Command:** In order to use a delayed console command simply make any trigger execute RunScriptCode with the parameter *CommandStack.Add("TTTTyour command here", COMMAND_DELAYEDCONSOLE)*. TTTT is the time in milliseconds to wait before the command should be executed. Always use 4 digits here, example: *0500sv_cheats 1*, waits 0.5 seconds before it enables cheats.

**Adding Events:** To add events you can simply go to your SpawnTrigger and add a new output RunScriptCode with the parameter *CommandStack.Add("OnWave_OnTrigger 3 myTriggerObject", COMMAND_INTERNAL)*. This will trigger the outputs of your object named myTriggerObject right before wave 3 spawns the enemies. More Examples:
```
--------------- [General stuff]
Trigger the outputs of a gameobject on wave 3:
CommandStack.Add("OnWave_OnTrigger 3 myTriggerObject", COMMAND_INTERNAL)

Sends a command to the console on wave 15: (Here: Spawns a zombie in front of the player)
CommandStack.Add("OnWave_Console 15 ent_create npc_zombie", COMMAND_INTERNAL)

--------------- [Features useful for story driven maps]
Pauses the wave spawning process (Shops are still working)
CommandStack.Add("OnWave_PauseSoft 5 true", COMMAND_INTERNAL)

Unpauses the wave spawning process
CommandStack.Add("OnWave_PauseSoft 6 false", COMMAND_INTERNAL)

Stops the full Mod (Nothing related to the mod will work, you have the reinitalize it again)
CommandStack.Add("OnWave_PauseHard 5 true", COMMAND_INTERNAL)

--------------- [Hooking up your own scripts into this mod]
Run a custom lua function or code piece on wave 5:
CommandStack.Add("OnWave_FireFunction 5 myCustomFunction()", COMMAND_INTERNAL)

Run a code piece on wave 7:
CommandStack.Add("OnWave_FireFunction 7 if MyPolymer >= 100 then; print("You are rich at wave 7!"); end", COMMAND_INTERNAL)
```

**That's everything you need to know about this mod for this version!**
