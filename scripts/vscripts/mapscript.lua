--============ Copyright (c) Manuel "Manello" Bäuerle, All rights reserved. ==========
-- Before using/modifying this code, please read LICENSE.txt
-- 
-- This file contains per-map functions defined by the mapper. Everything in here will be initialized upon start
-- A InitMap() function will be executed upon the start of the mod
--=============================================================================

-- Custom variable for map Warehouse
_G.Map_BoughtBlueKey = false

-- Custom function for map Warehouse
function _G.Map_BuyBlueKey()
	print("called")
	if MyPolymer >= 4 and Map_BoughtBlueKey == false then
		print("about to")
		local theKey = Entities:FindAllByName("BlueKey")
		if theKey[1] == nil then
			ModDebug("Could not find the BlueKey!")
		else
			MyPolymer = MyPolymer - 4
			CommandStack.Add("hlvr_addresources 0 0 0 -4")
			theKey[1]:SetOrigin(Entities:FindByName(Entities:First(), "Map_BlueKey"):GetOrigin())
			BoughtBlueKey = true
			EmitSoundOn("CombatStrider.Warp_Cannon_Failed_Shot_Mech", ActivePlayer)
		end
	else
		EmitSoundOn("Elevator_Distillery.Mechanism_Broken_Child", ActivePlayer)
	end
end

-- Executes custom commands on init
function _G.InitMap()
	--Put here custom init commands, for example register your per-wave events
	
	--Examples:
	--CommandStack.Add("god 1", COMMAND_CONSOLE)			
	-- => Sends that command to the console, executes asap
	
	--CommandStack.Add("if MyPolymer > 3 then; print("I have more than 3 polymer"); end", COMMAND_LUA)			
	-- => Executes a piece of Lua asap
	
	--CommandStack.Add("0250sv_cheats 1", COMMAND_DELAYEDCONSOLE)
	-- => Executes a console command after XXXX ms (Note: For this time all other commands have to wait as well)
	
	--CommandStack.Add("OnWave_OnTrigger 5 myTriggerName", COMMAND_INTERNAL)
	-- => Trigger the outputs of one of your triggers at wave 5
	
	--CommandStack.Add("OnWave_FireFunction 7 print("This is wave 7"); print("The second line of code")", COMMAND_INTERNAL)
	-- => Execute a piece of lua code at wave 7
	
	--CommandStack.Add("OnWave_FireFunction 7 myCustomFunction()", COMMAND_INTERNAL)
	-- => Execute a piece of lua code at wave 7, in this case myCustomFunction which can be defined in this file
	
	--CommandStack.Add("OnWave_PauseSoft 8 true", COMMAND_INTERNAL)
	-- => Pauses the wave spawning process at wave 8, shops and so on still work (false unpauses)
	
	--CommandStack.Add("OnWave_PauseHard 8 true", COMMAND_INTERNAL)
	-- => Stops the mod, you won't be able to resume it until you reload the initXenThug file
end