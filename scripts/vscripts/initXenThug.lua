--============ Copyright (c) Manuel "Manello" Bäuerle, All rights reserved. ==========
--
-- This file contains generic functions, globals and constants
--=============================================================================

require "mapdata"

print ("\n\n Initializing Manellos XenThug Mod...")

_G.ActivePlayer = Entities:GetLocalPlayer()

_G.NpcList = {}
--NpcList[1] = { name = "",
--				 handle = nil}

_G.UPDATE_STEP_CHECK = 0
_G.UPDATE_STEP_SPAWN = 1
_G.UPDATE_STEP_REGISTER = 2
_G.UPDATE_DELAY_INIT = 3

_G.MAX_TIME_AS_RAGDOLL = 10		--Time for npcs as a ragdoll before they are declared as dead

_G.PolymerSpawnedTotal = 0
_G.PolymerTakenTotal = 0
_G.UpdateBoughtSomething = {}

_G.AlreadySetGoods = {}

_G.PolymersFreshSpawnPos = {}
_G.AlreadySetPolymers = {}
_G.AlreadySetCorpses = {}
_G.UpdatePolymers = false

_G.Stores = {
	AmmoVender = 0,
	ShellVender = 0,
	EnergyVender = 0,
	MedkitVender = 0,
	HealthVender = 0
}

_G.CurrentWave = 1

_G.UpdateStep = UPDATE_DELAY_INIT
_G.UpdateStepTimer = 0

_G.ToDelete = {}
_G.AlreadyDeletedCorpses = {}

_G.DelaySeconds = 0
_G.DelayLastTime = 0

_G.SpawnGenerationArray = {}
_G.SpawnLocation = {}
_G.SpawnGroupContainer = {}	--This container holds the indexes of the SpawnLocation seperated by groups
_G.SpawnGroupsCompiled = {}
_G.TotalNpcCounter = 0
_G.TotalSquadCounter = 0
_G.CurrentSquadCounter = 0

_G.Waveboard = {}
_G.TotalWavesPlayed = 0

_G.Wavetimer = {}
_G.FirstWaveSpawned = false

_G.PlayerDied = false
_G.PortedPlayerToMenu = false

_G.WaveIsDead = false
_G.DoubleCheckAlive = 0

_G.Scoreboard = {}
_G.ScoreForThisRound = 0
_G.ScoreTotal = 0
_G.ScorePerKill = {
	5, 		5, 		20, 	0, 		25, 		20,
	25, 	0, 		10,		0, 		0, 			0,
	30, 	30,		10,		35, 	30, 		35
}

--PrecacheEntityFromTable("npc_headcrab", 1 , 2)
_G.CommandStack = {}
_G.CommandStack.queue = {}
_G.CommandStack.delayedComActive = false
_G.CommandStack.delayStart = 0
_G.CommandStack.delaySeconds = 0
--_G.CommandStack.queue[1].command = ""
--_G.CommandStack.queue[1].mode = 

_G.COMMAND_NONE = 0
_G.COMMAND_CONSOLE = 1
_G.COMMAND_INTERNAL = 2
_G.COMMAND_LUA = 3
_G.COMMAND_DELAYEDCONSOLE = 4	--The first 4 chars have to be digits containing the delay in ms!

_G.ModClock = 0

_G.OnWave = {}
-- OnWave[WaveNum][ComNum] = {
--				command = "",
--				params = ""
-- }

_G.SoftPause = false
_G.HardPause = false

--=============================================================================

-- Yo
function _G.SetSoftPause(is)
	SoftPause = is
end

-- Yeh
function _G.SetHardPause(is)
	HardPause = is
end

-- Does all the commands registered for that wave
function _G.WaveDoInternalCommands(wave)
	if OnWave[wave] ~= nil then
		for i = 1, #OnWave[wave], 1 do
			ExecInternalCommand(OnWave[wave][i])
		end
	end
end

--Trim whitespaces
function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Executes Internal commands
function _G.ExecInternalCommand(comObj)
	if comObj.command == "OnWave_OnTrigger" then		--Fires outputs of the specified entity before wave x
		local theEnt = Entities:FindByName(Entities:First(), comObj.params)
		
		if theEnt == nil then
			ModDebug("[WARNING]: Could not find entity for internal command")
			return
		end
		
		CommandStack.Add("ent_fire_output ".. comObj.params .." ontrigger", COMMAND_CONSOLE)
		
	elseif comObj.command == "OnWave_FireFunction" then	--Fires a lua script function before wave x
		local f = loadstring(comObj.params)
		f()
		
	elseif comObj.command == "OnWave_Console" then		--Sends a command to the console before wave x
		SendToConsole(comObj.params)
	
	elseif comObj.command == "OnWave_PauseSoft" then		--Pauses the Mod before wave x, Shops and passive stuff still works until unpaused
		if trim(string.lower(comObj.params)) == "true" then
			SoftPause = true
		else
			SoftPause = false
		end
	
	elseif comObj.command == "OnWave_PauseHard" then		--Pauses the Mod before wave x, nothing related to XenThug will work until unpaused
		if trim(string.lower(comObj.params)) == "true" then
			HardPause = true
		else
			HardPause = false
		end
	
	else
		ModDebug("[WARNING]: Ignored unknown internal command!")
		return
	end
	
	if DebugEnabled == true then
		ModDebug("Executed internal command: " .. comObj.command)
	end
end

-- Commando Input
function _G.CommandStack.Add(theComm, theMode)
	if theMode == COMMAND_NONE then
		return
	else
		if theMode == nil then
			theMode = COMMAND_CONSOLE
		end
		CommandStack.queue[#CommandStack.queue + 1] = {command = theComm, mode = theMode}
	end
	
	if #CommandStack.queue > 100 then
		ModDebug("[WARNING]: More than 100 Commands in Stack! Expect bad gameplay!")
	end
end

-- Single Commando Execution, returns true if more commands are available
function _G.CommandStack.Exec()
	if CommandStack.delayedComActive == false then
		if #CommandStack.queue > 0 then
			if CommandStack.queue[1].mode == COMMAND_CONSOLE then
				SendToConsole(CommandStack.queue[1].command)
				table.remove(CommandStack.queue, 1)
				
			elseif CommandStack.queue[1].mode == COMMAND_INTERNAL then	--using -1 as the wave will instantly execute the command
				local ComWords = {}
				for word in CommandStack.queue[1].command:gmatch("[%w_]+") do table.insert(ComWords, word) end
				local WaveNum = tonumber(ComWords[2])

				if WaveNum ~= -1 then	--Add execution for wave x

					if OnWave[WaveNum] == nil then
						OnWave[WaveNum] = {}
					end
					
					OnWave[WaveNum][#OnWave[WaveNum] + 1] = {}
					OnWave[WaveNum][#OnWave[WaveNum]].command = ComWords[1]
					if #ComWords > 2 then
						local paramString = ""
						for i = 3, #ComWords, 1 do
							paramString = paramString .. ComWords[i] .. " "
						end
						OnWave[WaveNum][#OnWave[WaveNum]].params = paramString:gsub("^%s*(.-)%s*$", "%1")
					else
						OnWave[WaveNum][#OnWave[WaveNum]].params = ""
					end
					
				else	--Execute now
					local paramString = ""
					for i = 3, #ComWords, 1 do
						paramString = paramString .. " " .. ComWords[i]
					end
					local myComObj = {command = ComWords[1], params = paramString}
					ExecInternalCommand(myComObj)
				end	
				
				table.remove(CommandStack.queue, 1)
				
			elseif CommandStack.queue[1].mode == COMMAND_LUA then
				local f = loadstring(CommandStack.queue[1].command)
				f()
				
				table.remove(CommandStack.queue, 1)
				
			elseif CommandStack.queue[1].mode == COMMAND_DELAYEDCONSOLE then
				CommandStack.delayedComActive = true
				CommandStack.delayStart = ModClock
				CommandStack.delaySeconds = tonumber(string.sub(CommandStack.queue[1].command, 1, 4)) / 1000
			end
		end
	else
		local timeDiff = ModClock - CommandStack.delayStart 
		CommandStack.delaySeconds = CommandStack.delaySeconds - math.abs(timeDiff)
		CommandStack.delayStart = ModClock
		
		if CommandStack.delaySeconds <= 0 then
			SendToConsole(string.sub(CommandStack.queue[1].command, 5))
			table.remove(CommandStack.queue, 1)
			CommandStack.delayedComActive = false
		end
	end
	
	if #CommandStack.queue > 0 then
		return true
	else
		return false
	end
	return false
end

--Returns the index the mod uses for a npc class
function _G.ReturnIndexFromClass(strClass)
	for i = 1, #EntEnums, 1 do
		if EntEnums[i] == strClass then
			return i
		end
	end
	return nil
end

-- Outputs a Mod debug message
function _G.ModDebug(str)
	print("[MOD][XenThug]: " .. str)
end

-- Outputs a Mod warning message
function _G.ModWarn(str)
	print("[MOD][XenThug][WARNING]: " .. str)
end

-- Outputs a Mod error message
function _G.ModError(str)
	print("[MOD][XenThug][ERROR]: " .. str)
end

-- Assigns a SpawnLocation to a SpawnGroup, checks before if the SpawnGroup exists
function _G.RegisterSpawnGroup(name, spawnLocIndex)
	local groupExists = false
	for k, group in pairs(SpawnGroupContainer) do
		if k == name then
			groupExists = true
			break
		end
	end
	
	if groupExists == false then
		SpawnGroupContainer[name] = {}
		
		if DebugEnabled == true then
			ModDebug("Creating new SpawnGroup: "..name)
		end
	end
	
	SpawnGroupContainer[name][#SpawnGroupContainer[name] + 1] = spawnLocIndex
end

-- Update Objects which where placed in Hammer (pre-runtime)
function _G.InitPreRuntimeObjects()
	AlreadySetCorpses = Entities:FindAllByClassname("prop_ragdoll")		--ignore existing corspes as mappers use them as deco
	AlreadyDeletedCorpses = Entities:FindAllByClassname("prop_ragdoll")
	
	local entsFound = Entities:FindAllByClassname("info_landmark")
	local entName = ""
	
	for i = 1, #entsFound, 1 do
		entName = entsFound[i]:GetName()
		
		if string.sub(entName, 1, 10) == "EnemySpawn" then		--Spawn Location, can be either only EnemySpawn, so without SpawnGroups
			if string.len(entName) == string.len("EnemySpawn") then
				SpawnLocation[#SpawnLocation + 1] = entsFound[i]
			else												--Or it can be with an attached name, with SpawnGroups (e.g. EnemySpawn_MyGroup, the _ is mandatory)
				SpawnLocation[#SpawnLocation + 1] = entsFound[i]
				RegisterSpawnGroup(string.sub(entName, 12), #SpawnLocation)
			end
			if DebugEnabled == true then
				ModDebug("Found Location: SpawnLocation")
			end
			
		elseif string.sub(entName, 1, 6) == "Vender" then		--Vender, e.g. Vender_Ammo
			for j, vend in ipairs(Vender) do
				if vend.Name == entName then
					vend.Entity = entsFound[i]
				end
			end
			
			if DebugEnabled == true then
				ModDebug("Found Location: "..entName)
			end
		end
	end
	AlreadySetPolymers = Entities:FindAllByClassname("item_hlvr_crafting_currency_small")
	TotalPolymersSpawned = #AlreadySetPolymers + MyPolymer	--ACHTUNG: EVT WIEDER IN DEN FOR LOOP?
	
	local firstEnt = Entities:First()
	local currEnt = firstEnt
	
	repeat
		if currEnt ~= nil then
			AlreadySetGoods[#AlreadySetGoods + 1] = currEnt
		end
	
		currEnt = Entities:Next(currEnt)
		if currEnt == nil then
			currEnt = Entities:Next(currEnt)
		end
	until (currEnt == firstEnt)
	
	Scoreboard = Entities:FindAllByName("Scoreboard")
	Waveboard = Entities:FindAllByName("Waveboard")
	Wavetimer = Entities:FindAllByName("Wavetimer")
end

--Prints all Entities which are visible in the CURRENT TICK
function _G.DebugListEnts()
	local firstEnt = Entities:First()
	local currEnt = firstEnt
	
	repeat
		ModDebug("Entity: " .. currEnt:GetClassname())
	
		currEnt = Entities:Next(currEnt)
		if currEnt == nil then
			currEnt = Entities:Next(currEnt)
		end
	until (currEnt == firstEnt)
end

--Starts a delay for X seconds, stops the full script update process for this time
function _G.DelayStart(secs)
	DelaySeconds = secs
	DelayLastTime = ModClock
	
	if DebugEnabled == true then
		ModDebug("Started Delay with "..tostring(secs).." seconds")
	end
end

--Returns true if the Delay is still active
function _G.DelayActive()
	local timeDiff = ModClock - DelayLastTime
	DelaySeconds = DelaySeconds - math.abs(timeDiff/1000)
	
	if DelaySeconds <= 0 then
		DelaySeconds = 0
		return false
	end
	
	return true
end

--Updates the time in seconds passed since XenThug started up
function _G.UpdateModClock()
	if EnablePerformanceMode == true then
		ModClock = ModClock + FrameTime()*16
	else
		ModClock = ModClock + FrameTime()
	end
end

--Returns daytime in seconds
function _G.TimeInSeconds()
	return (LocalTime().Seconds + LocalTime().Minutes * 60 + LocalTime().Hours * 60 * 60)
end

--Toggles Debug mode from Console
function _G.ToggleDebug()
	DebugEnabled = not DebugEnabled
	if DebugEnabled == true then
		ModDebug("Debugging is now enabled!")
	else
		ModDebug("Debugging is now disabled!")
	end
end

--=============================================================================
InitPreRuntimeObjects()

_G.InitGamemodeDone = true

require "XenThugGamemode"

require "mapscript"

ActivePlayer:SetThink(GamemodeThink, "xenthug_think", 0)

ListenToGameEvent("player_drop_resin_in_backpack", Event_PolymerPickedUp, nil)
ListenToGameEvent("player_eject_clip", Event_ClipGameWorkaround, nil)
ListenToGameEvent("player_retrieved_backpack_clip", Event_ClipGameWorkaround, nil)
ListenToGameEvent("player_pistol_clip_inserted", Event_ClipGameWorkaround, nil)

Convars:RegisterCommand("xt_debug", ToggleDebug, "Toggles the debug mode for XenThug", 0)

print ("Invasion Init done!")