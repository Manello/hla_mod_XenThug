--============ Copyright (c) Manuel "Manello" Bäuerle, All rights reserved. ==========
-- Before using/modifying this code, please read LICENSE.txt
-- 
--=============================================================================

--Classnames of each enemy type
_G.EntEnums = {
	"npc_headcrab", "npc_headcrab_armored", "npc_headcrab_black", "npc_headcrab_fast", "npc_headcrab_runner", "???",
	"npc_zombie", "npc_zombie_blind", "npc_antlion", "???", "npc_fastzombie", "npc_antlionguard",
	"npc_combine", "npc_combine_s", "npc_manhack", "???", "???", "???"
}
--ATTENTION: Headcrab_Black and Headcrab_Poison load the same NPC type! Do not use npc_headcrab_poison, use black instead
 
--===============================================This table shows the layout of the enmy tables (Careful, some NPCs are broken and can't be used yet!)
-- Crab		Armor	Poison	???		Runn	Black
-- Zomb		Jeff	Antlio	???		???		???
-- Comb		CombS	Manhac	???		???		???

--If someone experiences bad perfomance, this throttles the CPU usage of the mode
--ATTENTION: The mod still works, but it will lead to bad graphic glitches. Only use if you really need it
_G.EnablePerformanceMode = false

--Enables Debugging for mappers in VConsole2
_G.DebugEnabled = true

--Polymer the player starts with
_G.MyPolymer = 5

-- IMPLEMENT OPTION TO DISABLE ENDLESS MDOE; TRIGGER AFTER END; AFTER EACH WAVE; AFTER WAVE X

--Game will initialize on the InitTrigger (so shops etc work), but waits for the first wave for this time
_G.StartDelay = 30

--Defines the time in seconds to wait in between each wave before spawning a new one
_G.WaveDelay = 10.0

--Difficulty Modifier. This will multiply the health of NPCs
_G.WaveModifier = 1.0

--Chance for each kill to drop Polymer (0.5 = 50%)
_G.PolymerDropChance = 0.75

--===============================================This table shows the layout of the enmy tables (Careful, some NPCs are broken and can't be used yet!)
-- Crab		Armor	Poison	???		Runner	???
-- Zomb		Jeff	Antlio	???		???		???
-- Comb		CombS	Manhac	???		???		???

--Defines how many of each enemy type should be in each wave
_G.WaveList = {
	
	{5, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {6, 	1,		0,		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	2, 		1, 		0, 		0, 		0},
	 
	 {4, 	2, 		2, 		0, 		1, 		0,
	 2, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {4, 	1, 		1, 		0, 		0, 		0,	--5
	 4, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {4, 	1, 		3, 		0, 		0, 		0,	
	 5, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {8, 	4, 		4, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {2, 	2, 		1, 		0, 		0, 		0,
	 5, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	3, 		2, 		0, 		0, 		0},
	 
	 {0, 	0, 		0, 		0, 		0, 		0,	--10
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	5, 		2, 		0, 		0, 		0},
	 
	 {0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	1, 		9, 		0, 		0, 		0},
	 
	 {0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		5, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {5, 	0, 		2, 		0, 		0, 		0,
	 0, 	0, 		5, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {2, 	0, 		0, 		0, 		0, 		0,	
	 8, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {0, 	0, 		0, 		0, 		0, 		0,	--15
	 9, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		2, 		0, 		0, 		0},
	 
	 {2, 	2, 		2, 		0, 		0, 		0,	
	 6, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		1, 		0, 		0, 		0},
	 
	 {0, 	0, 		0, 		0, 		0, 		0,	
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		15, 	0, 		0, 		0},
	 
	 {0, 	0, 		0, 		0, 		0, 		0,	
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	6, 		5, 		0, 		0, 		0},
}

--===============================================

-- This enables the advanced enemy placing system. With this you can define where which enemies should spawn, and also active and deactive groups on demand
_G.UseSpawnGroups = true

_G.SpawnGroup = {
	Mixed = { Enabled = true,				--Will only use this group when it is enabled
	true,	false, 	false, 	false, 	false, 	false,	--Spawns all Enemy types but only normal crabs
	true, 	true, 	true, 	true, 	true, 	true,
	true, 	true, 	true, 	true, 	true, 	true
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
	
}

--===============================================

-- Plays these sounds upon WaveSpawn / when the whole wave got killed
_G.WaveFinishSound = "Example.core_start_oneshot"
_G.WaveStartSound = "Elevator_Distillery.Mechanism_Broken_Child"

--===============================================

--You can define a shop for any item you want here
--Make sure you use the same *Name* in Hammer!
_G.Vender = {
	{Name = "Vender_Ammo",									--The shop spawner landmarks name
	Item = "item_hlvr_clip_energygun",						--The item to sell
	Prototype = "",												--Custom Prototype, only needed if you want to spawn something like the explosive jerrycan (in general for prop_static, prop_physics and so on)
	Price = 1,												--Number of Polymers needed
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						--Sound playing when selling something
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						--Sound playing when player has not enough money
	Entity = {},																	--DO NOT CHANGE Entity
	InUse = false},																	--DO NOT CHANGE InUse
	
	{Name = "Vender_Shells",				
	Item = "item_hlvr_clip_shotgun_multiple",	
	Prototype = "",
	Price = 2,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},
	InUse = false},
	
	{Name = "Vender_Grenade",				
	Item = "item_hlvr_grenade_xen",	
	Prototype = "",
	Price = 3,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},
	InUse = false},
	
	{Name = "Vender_Medkit",				
	Item = "item_healthvial",	
	Prototype = "",
	Price = 2,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
	
	{Name = "Vender_Beer",				
	Item = "prop_physics",	
	Prototype = "BeerPrototype",
	Price = 0,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
	
	{Name = "Vender_Paper",				
	Item = "prop_physics",	
	Prototype = "PaperPrototype",
	Price = 0,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
	
	{Name = "Vender_Energy",				
	Item = "Item_hlvr_clip_rapidfire",	
	Prototype = "",
	Price = 4,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
	
	{Name = "Vender_Health",				
	Item = "item_hlvr_health_station_vial",	
	Prototype = "",
	Price = 6,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
	
	{Name = "Vender_RealGrenade",				
	Item = "item_hlvr_grenade_frag",	
	Prototype = "",
	Price = 4,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
	
	{Name = "Vender_Mine",				
	Item = "item_hlvr_weapon_tripmine",	
	Prototype = "",
	Price = 4,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
	
	{Name = "Vender_Jerri",				
	Item = "prop_physics",	
	Prototype = "JerriPrototype",
	Price = 0,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
}
