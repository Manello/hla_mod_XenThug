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
_G.MyPolymer = 15

--Defines the time in seconds to wait in between each wave before spawning a new one
_G.WaveDelay = 5.0

--Difficulty Modifier. This will multiply the health of NPCs
_G.WaveModifier = 1.0

--Chance for each kill to drop Polymer (0.5 = 50%)
_G.PolymerDropChance = 0.7

--===============================================This table shows the layout of the enmy tables (Careful, some NPCs are broken and can't be used yet!)
-- Crab		Armor	Poison	???		Runn	Black
-- Zomb		Jeff	Antlio	???		???		???
-- Comb		CombS	Manhac	???		???		???

--Defines how many of each enemy type should be in each wave
_G.WaveList = {
	
	{5, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {4, 	5,		1,		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		1, 		0, 		0, 		0},
	 
	 {8, 	6, 		2, 		0, 		1, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0},
	 
	 {8, 	8, 		8, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		1, 		0, 		0, 		0},
	 
	 {9, 	9, 		9, 		0, 		0, 		0,
	 0, 	0, 		0, 		0, 		0, 		0,
	 0, 	0, 		9, 		0, 		0, 		0},
}

--===============================================

-- Plays these sounds upon WaveSpawn / when the whole wave got killed
_G.WaveFinishSound = "Elevator_Distillery.Mechanism_Broken_Child"
_G.WaveStartSound = "Elevator_Distillery.Mechanism_Broken_Child"

--===============================================

--You can define a shop for any item you want here
--Make sure you use the same *Name* in Hammer!
_G.Vender = {
	{Name = "Vender_Ammo",									--The shop spawner landmarks name
	Item = "item_hlvr_clip_energygun",						--The item to sell
	Model = "",												--Custom Model, only needed if you want to spawn something like the explosive jerrycan (in general for prop_static, prop_physics and so on)
	Price = 1,												--Number of Polymers needed
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						--Sound playing when selling something
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						--Sound playing when player has not enough money
	Entity = {},																	--DO NOT CHANGE Entity
	InUse = false},																	--DO NOT CHANGE InUse
	
	{Name = "Vender_Shells",				
	Item = "item_hlvr_clip_shotgun_single",	
	Model = "",
	Price = 1,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},
	InUse = false},
	
	{Name = "Vender_Energy",				
	Item = "item_hlvr_clip_rapidfire",	
	Model = "",
	Price = 3,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},
	InUse = false},
	
	{Name = "Vender_Medkit",				
	Item = "item_healthvial",	
	Model = "",
	Price = 2,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},	
	InUse = false},
	
	{Name = "Vender_Gas",									--Explosive Jerry can example
	Item = "prop_physics",	
	Model = "models/props/explosive_jerrican_1.vmdl",		--ATTENTION: Lua does not handle "\" these slashes! use the "/" ones!
	Price = 3,							
	SoundSell = "CombatStrider.Warp_Cannon_Failed_Shot_Mech",						
	SoundNoMoney = "Elevator_Distillery.Mechanism_Broken_Child",						
	Entity = {},
	InUse = false},
}