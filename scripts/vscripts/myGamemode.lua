--============ Copyright (c) Manuel "Manello" Bäuerle, All rights reserved. ==========
-- Before using/modifying this code, please read LICENSE.txt
-- 
-- This file contains all functions used specifically by XenThug
--=============================================================================

--Register each enemy DIRECTLY after it spawned
--returns true on successfully registering one NPC
function _G.RegisterNewEnemy(enemyClass)
	local firstEnt = Entities:First()
	local currEnt = firstEnt
	
	while true do
		if currEnt:GetClassname() == enemyClass then
			if IsEnemyRegistered(currEnt) == false then
				NpcList[#NpcList + 1] = currEnt
				
				if DebugEnabled == true then
					ModDebug("Registered Enemy: "..currEnt:GetClassname())
				end
				return true
			end
		end
		
		currEnt = Entities:Next(currEnt)
		if currEnt == nil then
			currEnt = Entities:Next(currEnt)
		end
		if currEnt == firstEnt then
			break
		end
	end
	
	return false
end

--Registers all recently generated enemies
function _G.UpdateEnemyList(generatedClasses)
	NpcList = {}

	for i = 1, #generatedClasses, 1 do
		repeat until (RegisterNewEnemy(generatedClasses[i]) == false)
	end
end

--Check if an Enemy got registered by my scripts
function _G.IsEnemyRegistered(theEnemyEnt)

	if #NpcList == 0 then
		return false
	end

	local i = 1
	repeat
		if NpcList[i] == theEnemyEnt then
			return true
		end
		i = i + 1
	until(i > #NpcList)
	
	return false
end

--Yup
function _G.SpawnWave(waveNr)
	
	UpdateClasses = {} 
	UpdateClassesAmounts = {}
	local c = 1
	local d = 1
	for i = 1, #WaveList[waveNr], 1 do
		if WaveList[waveNr][i] ~= 0 then
			UpdateClasses[c] = EntEnums[i]
			UpdateClassesAmounts[c] = WaveList[waveNr][i]

			for j = 1, WaveList[waveNr][i], 1 do
				SendToConsole("ent_create "..EntEnums[i])
				
				d = d + 1
				if d > #SpawnLocation then
					d = 1
				end
				
				if DebugEnabled == true then
					ModDebug("Spawning Enemy: " .. EntEnums[i])
				end
			end
			
			c = c + 1
		end
	end	
end

--Sets Wave Positions and Difficulty
function _G.SetWavePositions()
	local d = 1
	for i = 1, #NpcList, 1 do
		NpcList[i]:SetAbsOrigin(SpawnLocation[d]:GetAbsOrigin())
		NpcList[i]:SetHealth(NpcList[i]:GetHealth() * WaveModifier)
		--Eventuell Hörreichweite der Gegner extrem erhöhen so das sie einen immer hören?
		
		d = d + 1
		if d > #SpawnLocation then
			d = 1
		end
	end
end

--Yo
function _G.IsWaveAlive()
	local firstEnt = Entities:First()
	local currEnt = firstEnt
	
	local currClass = ""
	repeat
		currClass = currEnt:GetClassname()
		for i = 1, #UpdateClasses, 1 do
			if currClass == UpdateClasses[i] then
				if currEnt:IsAlive() == true then
					return true
				else
					break
				end
			end
		end
	
		currEnt = Entities:Next(currEnt)
		if currEnt == nil then
			currEnt = Entities:Next(currEnt)
		end
	until (currEnt == firstEnt)
	
	return false
end

--Checks if all ents of a wave spawned in
function _G.HasWaveSpawned()
	for i, class in ipairs(UpdateClasses) do
		if UpdateClassesAmounts[i] > #Entities:FindAllByClassname(class) then
			return false
		end
	end
	return true
end

-- Mark Entities for Deletion (1 delete per tick)
function _G.CleanupWave()
	local firstEnt = Entities:First()
	local currEnt = firstEnt
	
	repeat
		if currEnt:GetClassname() == "prop_ragdoll" then
			ToDelete[#ToDelete + 1] = currEnt
		end
	
		currEnt = Entities:Next(currEnt)
		if currEnt == nil then
			currEnt = Entities:Next(currEnt)
		end
	until (currEnt == firstEnt)
end

-- Gets Killed Ents and registers their corpses
function _G.GetRecentKills()
	local corpseList = Entities:FindAllByClassname("prop_ragdoll")
	local killedEnts = {}
	local isFreshKill = true
	
	for c = 1, #corpseList, 1 do
		isFreshKill = true
		if corpseList[c]:IsAlive() == false then
			--See if the corpe is Deco/Or already used as a polymer spawn
			for i, ent in ipairs(AlreadySetCorpses) do
				if ent == corpseList[c] then
					isFreshKill = false
					break
				end
			end
			
			if isFreshKill == true then
				killedEnts[#killedEnts + 1] = corpseList[c]
				PolymersFreshSpawnPos[#PolymersFreshSpawnPos + 1] = corpseList[c]
				AlreadySetCorpses[#AlreadySetCorpses + 1] = corpseList[c]
			end
		end
	end
	
	return killedEnts
end

-- Polymer Economy function
function _G.DoPolymerEconomy()
	--check if player picked something up
	local allPolymers = Entities:FindAllByClassname("item_hlvr_crafting_currency_small")
	
	if (#allPolymers + TotalPolymersPickedUp) < TotalPolymersSpawned then
		local numberOfPickups = TotalPolymersSpawned - (#allPolymers + TotalPolymersPickedUp)
		TotalPolymersPickedUp = TotalPolymersPickedUp + numberOfPickups
		MyPolymer = MyPolymer + numberOfPickups
	--check if map spawned new polymers 
	elseif (#allPolymers + TotalPolymersPickedUp) > TotalPolymersSpawned then
		TotalPolymersSpawned = #allPolymers + TotalPolymersPickedUp
	end

	--check which polymers are new
	if UpdatePolymers == true then
		local isSet = false
		local allPolymers = Entities:FindAllByClassname("item_hlvr_crafting_currency_small")
		
		for i = 1, #allPolymers, 1 do
			isSet = false
			for j = 1, #AlreadySetPolymers, 1 do
				if allPolymers[i] == AlreadySetPolymers[j] then
					isSet = true
				end
			end
			
			--move old polymers which got spawned last tick to the right position
			if isSet == false then
				if #PolymersFreshSpawnPos == 0 then
					if DebugEnabled == true then
						ModDebug("Found new Polymer but no corpse to spawn it at!")
					end
				else
					allPolymers[i]:SetOrigin(PolymersFreshSpawnPos[#PolymersFreshSpawnPos]:GetAbsOrigin())
					AlreadySetPolymers[#AlreadySetPolymers + 1] = allPolymers[i]
					table.remove(PolymersFreshSpawnPos, #PolymersFreshSpawnPos)
				end
			end
		end
		UpdatePolymers = false
	end

	--add new polymers
	local killedEnts = GetRecentKills()
	if #killedEnts > 0 then
		--for i, deadEnt in ipairs(killedEnts) do
		if math.random() < PolymerDropChance then
			SendToConsole("ent_create item_hlvr_crafting_currency_small")
			TotalPolymersSpawned = TotalPolymersSpawned + 1
			UpdatePolymers = true
		end
		--end
	end
end

-- Manages a buy request from a shop
function _G.UseVender(vendername)

	local venderIndex = 0
	for i, vend in ipairs(Vender) do
		if vendername == vend.Name then
			venderIndex = i
			break
		end
	end
	
	if venderIndex == 0 then
		ModDebug("[WARNING] Accessing non-existing shop!")
		return
	end
	
	if Vender[venderIndex].InUse == false then
		if MyPolymer >= Vender[venderIndex].Price then
			CommandStack.Add("hlvr_addresources 0 0 0 -"..tostring(Vender[venderIndex].Price))
			CommandStack.Add("ent_create "..Vender[venderIndex].Item)
			MyPolymer = MyPolymer - Vender[venderIndex].Price
			Vender[venderIndex].InUse = true
			EmitSoundOn(Vender[venderIndex].SoundSell, Vender[venderIndex].Entity)
			
			if DebugEnabled == true then
				ModDebug("Bought Pistol Ammo!")
			end
			return
		else
			EmitSoundOn(Vender[venderIndex].SoundNoMoney, Vender[venderIndex].Entity)
		end
	end
end

-- Sets the right position for a bought item
function _G.UpdateVenders()
	for i, vend in ipairs(Vender) do
		if vend.InUse == true then
			local lookupItems = Entities:FindAllByClassname(vend.Item)
			for j = 1, #lookupItems, 1 do
				if GoodAlreadySet(lookupItems[j]) == true then
					break
				else
					if vend.Model ~= "" then
						lookupItems[j]:SetModel(vend.Model)
					end
					lookupItems[j]:SetOrigin(vend.Entity:GetOrigin())
					AlreadySetGoods[#AlreadySetGoods + 1] = lookupItems[j]
					vend.InUse = false
				end
			end
		end
	end
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

--=============================================================================

function GamemodeThink()
	if InitGamemodeDone == true then
		if DelayActive() == false then
			if UpdateStep == UPDATE_DELAY_INIT then
				UpdateStepTimer = UpdateStepTimer + 1
				
				if DebugEnabled == true then
					ModDebug("Starting game ", UpdateStepTimer, "/10")
				end
				
				if UpdateStepTimer == 2 then
					CommandStack.Add("sv_cheats 1")
					CommandStack.Add("sv_autosave 0")
					CommandStack.Add("0500hlvr_addresources 0 0 0 "..tostring(MyPolymer), COMMAND_DELAYEDCONSOLE)
				elseif UpdateStepTimer == 10 then
					UpdateStepTimer = 0
					UpdateStep = UPDATE_STEP_SPAWN
				end
				
				CommandStack.Exec()
				
			elseif UpdateStep == UPDATE_STEP_CHECK then
				
				if DebugEnabled == true then
					--ModDebug("Running... Wave alive?")
				end
				
				CommandStack.Exec()
				
				if #ToDelete > 0 then
					if ToDelete[#ToDelete] ~= nil then
						AlreadyDeletedCorpses[#AlreadyDeletedCorpses + 1] = ToDelete[#ToDelete]
						CommandStack.Add("ent_remove "..tostring(ToDelete[#ToDelete]:entindex()))
						table.remove(ToDelete)
						
						if DebugEnabled == true then
							ModDebug("Deleted one corpse.")
						end
					end
				end
			
				UpdateVenders()
				DoPolymerEconomy()
			
				if IsWaveAlive() == false then
					CleanupWave()
					EmitSoundOn(WaveFinishSound, ActivePlayer)
					DelayStart(WaveDelay)
					UpdateStep = UPDATE_STEP_SPAWN
					
					if DebugEnabled == true then
						ModDebug("Wave dead. Cleanup started.")
					end
				end
				
			elseif UpdateStep == UPDATE_STEP_SPAWN then
				
				if DebugEnabled == true then
					ModDebug("Spawning Wave "..tostring(CurrentWave))
				end
				
				SpawnWave(CurrentWave)
				
				CurrentWave = CurrentWave + 1
				if CurrentWave > #WaveList then
					CurrentWave = 1
					WaveModifier = WaveModifier * 2
				end
				
				UpdateStep = UPDATE_STEP_REGISTER
				
			elseif UpdateStep == UPDATE_STEP_REGISTER then
				
				if DebugEnabled == true then
					ModDebug("Registering new wave!")
				end
				
				if HasWaveSpawned() == true then
					UpdateEnemyList(UpdateClasses)
					SetWavePositions()
					EmitSoundOn(WaveStartSound, ActivePlayer)
					
					UpdateStep = UPDATE_STEP_CHECK
				end
			end
		end
	end
	
	UpdateModClock()
	
	if EnablePerformanceMode == true then
		return FrameTime()*16
	else
		return FrameTime()
	end
end
