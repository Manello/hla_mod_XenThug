# [MOD] Half Life: Alyx - XenThug
A Half Life: Alyx Mod, classic wave defense mode

<h3>[ROADMAP, Version 0.1]</h3>

TBA

<h3>[FOR MAPPERS, Version 0.1]</h3>
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
-- Crab		Armor	Poison	???		Runn	Black
-- Zomb		Jeff	Antlio	???		???		???
-- Comb		CombS	Manhac	???		???		???

--Defines how many of each enemy type should be in each wave
_G.WaveList = {
	
  --THIS IS WAVE/BLOCK 1
	{5, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		1, 		0, 		0, 		0},
	 
   --THIS IS WAVE/BLOCK 2
	 {2, 	5,		1,		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
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
  - Fire once only:         Yes

1. Let's setup the next trigger. This trigger should include your WHOLE map, every bit where the player might be in.
2. Make sure its class is *trigger_multiple* and set its Name to *UpdateTrigger*.
3. Set its "Delay Before Reset" to 0.2
4. Open up the triggers *Properties* and go to *Outputs*
5. Add a new output with the following settings:
  - My output named:        OnTrigger
  - Target entities named:  UpdateTrigger
  - Via this input:         RunScriptCode
  - With a parameter:       SendToConsole("script_reload_code myGamemode")
  - Delay:                  0
  - Fire once only:         No
  
##### Landmarks
Now you will have to define where your enemies should spawn. For this you have to create one or multiple *info_landmark*. Make sure you name all of these landmarks *EnemySpawn*. Hammer will mark the name orange, but you can ignore that.

That is it! If you startup your map now it should start spawning the waves you defined. All further steps are optional, but I recommend them to improve your gameplay experience!

##### Shopsystem & Economy
Since you can walk around and fight enemies your player will run out of ammo, no matter how much you will initally give him. Thus I've implemented a shopsystem, this will enable you to create vending machines which will sell ammunition and health to the player once the bumps into them. The currency is polymer and enemies are dropping that once killed. (Currently you can't set how often they drop polymers, nor how much they drop as it is bugged.)

A vending machine consists out of a *trigger_multiple* and an *info_landmark*.

MORE INFO COMING ASAP ON SHOPS

<h3>[FOR MODDERS, Version 0.1]</h3>

TBA
