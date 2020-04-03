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

--Polymer the player starts with
_G.MyPolymer = 2

--Difficulty Modifier. This will multiply the health of NPCs
_G.WaveModifier = 1.0

--Chance for each enemy type to drop Polymer (0.5 = 50%)
--NOT SUPPORTED YET
_G.PolymerDropChance = {
	0.5, 	0.5, 	0.5, 	0.0, 	0.5, 	0.5,
	0.5, 	0.5, 	0.5, 	0.0, 	0.0, 	0.0,
	0.5, 	0.5, 	0.5, 	0.0, 	0.0, 	0.0
}

--Maximum number of Polymers dropped per kill.
--The Mod will drop a Random number between 1 and your set Maximum
--NOT SUPPORTED YET
_G.PolymerForKillMax = {
	1, 		1, 		1, 		0, 		1, 		1,
	2, 		3, 		1, 		0, 		0, 		0,
	2, 		2, 		1, 		0, 		0, 		0
}

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