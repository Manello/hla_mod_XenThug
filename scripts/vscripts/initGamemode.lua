--============ Copyright (c) Manuel "Manello" Bäuerle, All rights reserved. ==========
--
--
--=============================================================================

require "mapdata";

print ("\n\n Initializing Manellos Invasion Mod...")

_G.ActivePlayer = Entities:GetLocalPlayer()

_G.NpcList = {}

_G.UPDATE_STEP_CHECK = 0
_G.UPDATE_STEP_SPAWN = 1
_G.UPDATE_STEP_REGISTER = 2
_G.UPDATE_DELAY_INIT = 3

_G.PolymerSpawnedTotal = 0
_G.PolymerTakenTotal = 0
_G.UpdateBoughtAmmo = false
_G.UpdateBoughtShells = false
_G.UpdateBoughtEnergy = false
_G.UpdateBoughtMedkit = false
_G.UpdateBoughtHealth = false

_G.AlreadySetGoods = {}
_G.PolymersFreshSpawn = {}
_G.AlreadySetPolymers = {}
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

_G.UpdateClasses = {}

_G.SpawnLocation = {}

--PrecacheEntityFromTable("npc_headcrab", 1 , 2)
_G.CommandStack = {}
_G.CommandStack.queue = {}

--=============================================================================

-- Update Objects which where placed in Hammer (pre-runtime)
function _G.InitPreRuntimeObjects()
	local entsFound = Entities:FindAllByClassname("Info_landmark")
	local entName = ""
	
	for i = 1, #entsFound, 1 do
		entName = entsFound[i]:GetName()
		
		if entName == "EnemySpawn" then
			SpawnLocation[#SpawnLocation + 1] = entsFound[i]
		elseif entName == "AmmoVender" then		--pew
			Stores.AmmoVender = entsFound[i]
		elseif entName == "ShellVender" then	--pow
			Stores.ShellVender = entsFound[i]
		elseif entName == "EnergyVender" then	--pewpew
			Stores.EnergyVender = entsFound[i]
		elseif entName == "MedkitVender" then	--Syringe
			Stores.MedkitVender = entsFound[i]
		elseif entName == "HealthVender" then --Yummy worm
			Stores.HealthVender = entsFound[i]
		end
	end
end

-- Commando Input
function _G.CommandStack.Add(theComm)
	CommandStack.queue[#CommandStack.queue + 1] = theComm
	if #CommandStack.queue > 30 then
		print("MOD WARNING: More than 30 Commands in Stack! Expect bad gameplay!")
	end
end

-- Single Commando Execution, returns true if more commands are available
function _G.CommandStack.Exec()
	if #CommandStack.queue > 0 then
		SendToConsole(CommandStack.queue[1])
		table.remove(CommandStack.queue, 1)
		if #CommandStack.queue > 0 then
			return true
		else
			return false
		end
	end
	return false
end

-- Checks if a Goodie was already placed
function _G.GoodAlreadySet (theEnt)
	for i, ent in ipairs(AlreadySetGoods) do
		if theEnt == ent then
			return true
		end
	end
	return false
end

-- Spawns and moves a clip
function _G.BuyAmmo(moveOnly)

	if moveOnly == false then	--Spawn Ammo
		if MyPolymer >= 1 then
			CommandStack.Add("hlvr_addresources 0 0 0 -1")
			CommandStack.Add("ent_create item_hlvr_clip_energygun")
			UpdateBoughtAmmo = true
			return
		end
	else					--Move to Spawnpoint
		-- local firstEnt = Entities:First()
		-- local currEnt = firstEnt
		
		-- repeat
			-- if currEnt:GetClassname() == "item_hlvr_clip_energygun" then
				-- if GoodAlreadySet(currEnt) == false then

					-- currEnt:SetAbsOrigin(Stores.AmmoVender:GetAbsOrigin())
					-- AlreadySetGoods[#AlreadySetGoods + 1] = currEnt
					-- UpdateBoughtAmmo = false
					-- return
				-- end
			-- end
		
			-- currEnt = Entities:Next(currEnt)
			-- if currEnt == nil then
				-- currEnt = Entities:Next(currEnt)
			-- end
		-- until (currEnt == firstEnt)
	end
	
	--print("MOD ERROR: Could not spawn at AmmoVender!")
end

-- Spawns and moves two shells
function _G.BuyShells(moveOnly)

	if moveOnly == false then	--Spawn Ammo
		if MyPolymer >= 1 then
			SendToConsole("hlvr_addresources 0 0 0 -1\n")
			SendToConsole("ent_create item_hlvr_clip_shotgun_shells_pair")
			UpdateBoughtShells = true
			return
		end
	else					--Move to Spawnpoint
		-- local firstEnt = Entities:First()
		-- local currEnt = firstEnt
		
		-- repeat
			-- if currEnt:GetClassname() == "item_hlvr_clip_shotgun_shells_pair" then
				-- if GoodAlreadySet(currEnt) == false then
				
					-- currEnt:SetAbsOrigin(Stores.ShellVender:GetAbsOrigin())
					-- AlreadySetGoods[#AlreadySetGoods + 1] = currEnt
					-- UpdateBoughtShells = false
					-- return
				-- end
			-- end
		
			-- currEnt = Entities:Next(currEnt)
			-- if currEnt == nil then
				-- currEnt = Entities:Next(currEnt)
			-- end
		-- until (currEnt == firstEnt)
	end
	
	--print("MOD ERROR: Could not spawn at ShellVender!")
end

-- Spawns and moves one energy cell
function _G.BuyEnergy(moveOnly)
	if moveOnly == false then	--Spawn Ammo
		if MyPolymer >= 1 then
			SendToConsole("hlvr_addresources 0 0 0 -3\n")
			SendToConsole("ent_create item_hlvr_clip_rapidfire")
			UpdateBoughtEnergy = true
			return
		end
	else					--Move to Spawnpoint
		-- local firstEnt = Entities:First()
		-- local currEnt = firstEnt
		
		-- repeat
			-- if currEnt:GetClassname() == "item_hlvr_clip_rapidfire" then
				-- if GoodAlreadySet(currEnt) == false then
				
					-- currEnt:SetAbsOrigin(Stores.EnergyVender:GetAbsOrigin())
					-- AlreadySetGoods[#AlreadySetGoods + 1] = currEnt
					-- UpdateBoughtEnergy = false
					-- return
				-- end
			-- end
		
			-- currEnt = Entities:Next(currEnt)
			-- if currEnt == nil then
				-- currEnt = Entities:Next(currEnt)
			-- end
		-- until (currEnt == firstEnt)
	end
	
	--print("MOD ERROR: Could not spawn at EnergyVender!")
end

-- Spawns and moves a medkit
function _G.BuyMedkit(moveOnly)
	if moveOnly == false then	--Spawn Ammo
		if MyPolymer >= 1 then
			SendToConsole("hlvr_addresources 0 0 0 -2\n")
			SendToConsole("ent_create item_healthvial")
			UpdateBoughtMedkit = true
			return
		end
	else					--Move to Spawnpoint
		-- local firstEnt = Entities:First()
		-- local currEnt = firstEnt
		
		-- repeat
			-- if currEnt:GetClassname() == "item_healthvial" then
				-- if GoodAlreadySet(currEnt) == false then
				
					-- currEnt:SetAbsOrigin(Stores.MedkitVender:GetAbsOrigin())
					-- AlreadySetGoods[#AlreadySetGoods + 1] = currEnt
					-- UpdateBoughtMedkit = false
					-- return
				-- end
			-- end
		
			-- currEnt = Entities:Next(currEnt)
			-- if currEnt == nil then
				-- currEnt = Entities:Next(currEnt)
			-- end
		-- until (currEnt == firstEnt)
	end
	
	--print("MOD ERROR: Could not spawn at MedkitVender!")
end

-- Spawns and moves a healthy worm
function _G.BuyHealth(moveOnly)
	if moveOnly == false then	--Spawn Ammo
		if MyPolymer >= 1 then
			SendToConsole("hlvr_addresources 0 0 0 -8\n")
			SendToConsole("ent_create item_hlvr_health_station_vial")
			UpdateBoughtHealth = true
			return
		end
	else					--Move to Spawnpoint
		-- local firstEnt = Entities:First()
		-- local currEnt = firstEnt
		
		-- repeat
			-- if currEnt:GetClassname() == "item_hlvr_health_station_vial" then
				-- if GoodAlreadySet(currEnt) == false then
				
					-- currEnt:SetAbsOrigin(Stores.HealthVender:GetAbsOrigin())
					-- AlreadySetGoods[#AlreadySetGoods + 1] = currEnt
					-- UpdateBoughtHealth = false
					-- return
				-- end
			-- end
		
			-- currEnt = Entities:Next(currEnt)
			-- if currEnt == nil then
				-- currEnt = Entities:Next(currEnt)
			-- end
		-- until (currEnt == firstEnt)
	end
	
	--print("MOD ERROR: Could not spawn at HealthVender!")
end


--=============================================================================
InitPreRuntimeObjects()

_G.InitGamemodeDone = true

print ("Invasion Init done!")