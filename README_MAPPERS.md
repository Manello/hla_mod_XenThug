## [FOR MAPPERS, Version 0.2]
In order to enable this Mod on your custom Map you have to follow 3 simple steps:

### I. **Files**
Simply copy the included "scripts" folder into your game/hlvr/ folder.

### II. **Mod Settings**
All Settings which are useful for you as a mapper can be found inside the mapdata.lua, which can be found 
under /scripts/vscripts/. In This file you can currently edit the following options:

##### **[EnablePerformanceMode]**
This will slow down the mod decreasing it's CPU usage, but it will cause graphical artifacts. Only turn it to true it if you really need it!

##### **[DebugEnabled]**
Shows useful information for mappers in the VConsole2. You should disable this upon release of your map

##### **[MyPolymer]** 
The amount of Polymer the player will start with. 

ATTENTION: You are allowed to place Polymers on the map in Hammer, but DO NOT spawn them with your custom scripts(including impulse 101)! This will corrupt XenThug's economy system and leads to a bad player experience! Also, do not set the initial polymers through the info_player_equip class! Use MyPolymers in mapdata.lua instead.

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

#### **[Vender]**
This array stores all of your customized shops. It is very easy to use, feel free to add as many new shops as you like to.
```
_G.Vender = {
	{Name = "Vender_Ammo",						--The shop spawner landmarks name
	Item = "item_hlvr_clip_energygun",				--The item to sell
	Model = "",							--Custom Model, only needed if you want to spawn something like the explosive jerrycan (in general for prop_static, prop_physics and so on)
	Price = 1,							--Number of Polymers needed
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",	--Sound playing when selling something
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",	--Sound playing when player has not enough money
	Entity = {},							--DO NOT CHANGE Entity
	InUse = false},							--DO NOT CHANGE InUse
	
	{Name = "Vender_Gas",						--Explosive Jerry can example
	Item = "prop_physics",	
	Model = "models/props/explosive_jerrican_1.vmdl",		--ATTENTION: Lua does not handle "\" these slashes! use the "/" ones!
	Price = 3,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},
	InUse = false},
```
As you can see the first entry defines a shop which will spawn pistol ammo, the second one is an example for spawning any prop you want to have. You could even spawn newspapers if you want to. (Yes you can also buy NPCs here in theory). 

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
  - With a parameter:       SendToConsole("script_reload_code initGamemode")
  - Delay:                  0
  - Fire only once:         Yes
  
##### Landmarks
Now you will have to define where your enemies should spawn. For this you have to create one or multiple *info_landmark*. Make sure you name all of these landmarks *EnemySpawn*. Hammer will mark the name orange, but you can ignore that.

Note: You should leave enough space around each landmark so enemies won't bug into walls or objects. A radius of 40 inches around the spawn is recommended.

*That is it! If you startup your map now it should start spawning the waves you defined. All further steps are optional, but I recommend them to improve your gameplay experience!*

### Shopsystem & Economy
Since you can walk around and fight enemies your player will run out of ammo, no matter how much you will initally give him. Thus I've implemented a shopsystem, this will enable you to create customizeable vending machines which will sell anything you want to the player once he activates its trigger. The currency is polymer and enemies are dropping that once killed. 

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
2. Create a *info_landmark* and place it where the vender should spawn the bought items. Set the landmarks Name to how you named it in the script, for example *Vender_Ammo*. ATTENTION: You have to start the name with *Vender_*, otherwise my Mod can't find your shop.
3. Create a *trigger_multiple* in front of it. Each time the player runs into it, it will take X polymers from the player and spawn the desired item. The trigger should be higher than the player, and as wide as the vending machine.
4. Go to its properties to Outputs and add a new output like the following:
  - My output named:        OnTrigger
  - Target entities named:  Vender_Ammo		<<<<<---- set here the correct type instead!
  - Via this input:         RunScriptCode
  - With a parameter:       UseVender("Vender_Ammo")	<<<- Set here the name of your Vender landmark
  - Delay:                  0
  - Fire only once:         No

You should be able to buy ammo on this vender now once you are ingame! Of course only if you have enough polymer. Example of a shop setup:

![ALT TEXT An Image of a crappy looking vender](http://cvreleague.eu/wp-content/uploads/2020/04/Unbenannt.png)

**NEW:** You can still use the old setup like mentioned above, but now the Script supports any Trigger / Event as long as it is doing the *RunScriptCode* with the parameter *UseVender("Vender_YourVenderName")*. Thus you can now also use buttons/leavers/whatever you can create in Hammer.

Inspiration: Make something like a food vending machine in an office building! This way you can include multiple shops in one if you want to.

**That's everything you need to know about this mod for this version!**
