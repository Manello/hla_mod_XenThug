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
				CommandStack.Add("ent_create "..EntEnums[i])
				
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
	if UseSpawnGroups ~= true then	--Old simple system
		local d = 1
		for i = 1, #NpcList, 1 do
			if NpcList[i]:GetClassname() == "npc_manhack" then
				NpcList[i]:SetAbsOrigin(SpawnLocation[d]:GetAbsOrigin())
				NpcList[i]:SetOrigin(SpawnLocation[d]:GetOrigin())
				NpcList[i]:SetHealth(NpcList[i]:GetHealth() * WaveModifier)
			else
				NpcList[i]:SetAbsOrigin(SpawnLocation[d]:GetAbsOrigin())
				NpcList[i]:SetHealth(NpcList[i]:GetHealth() * WaveModifier)
			end
			
			d = d + 1
			if d > #SpawnLocation then
				d = 1
			end
		end
	else		--new advanced system
		local spawnLocationSelected = {}
		
		for k, group in pairs(SpawnGroupContainer) do
			SpawnGroupLocationIterator[k] = 1
			SpawnGroupIsFull[k] = false
		end
		
		for i = 1, #NpcList, 1 do
			spawnLocationSelected = ScanGroupsForSpawnLocation(i)
			
			if NpcList[i]:GetClassname() == "npc_manhack" then
				NpcList[i]:SetAbsOrigin(spawnLocationSelected:GetAbsOrigin())
				NpcList[i]:SetOrigin(spawnLocationSelected:GetOrigin())
				NpcList[i]:SetHealth(NpcList[i]:GetHealth() * WaveModifier)
			else
				NpcList[i]:SetAbsOrigin(spawnLocationSelected:GetAbsOrigin())
				NpcList[i]:SetHealth(NpcList[i]:GetHealth() * WaveModifier)
			end
		end
	end
end

-- Enables or disables a SpawnGroup
function _G.EnableSpawnGroup(name, enable)
	SpawnGroup[name].Enabled = enable
end

--Looks for the next free SpawnLocation in all groups, returns it on success, otherwise returns first one in array and prints error
--EXTENDS SetWavePositions
_G.SpawnGroupIsFull = {}
function _G.ScanGroupsForSpawnLocation(npcCounter)
	-- If current group is full
	-- If all groups are full
	local success, location = false, {}
	local foundLocation = false
	
	for k, group in pairs(SpawnGroupContainer) do
		if SpawnGroup[k].Enabled == true and SpawnGroupIsFull[k] == false then
			if SpawnGroup[k][ReturnIndexFromClass(NpcList[npcCounter]:GetClassname())] == true then
				success, location = FindFreeLocationInGroup(k, npcCounter)
				if success == true then
					if DebugEnabled == true then
						ModDebug("Added Enemy to SpawnGroup "..k)
					end
					
					return location
				else
					SpawnGroupIsFull[k] = true
					SpawnGroupLocationIterator[k] = 1
					
					if DebugEnabled == true then
						ModDebug("One SpawnGroup is fully saturated")
					end
				end
			end
		end
	end
	
	ModDebug("[Warning] More Enemies than Spawn Locations available")
	
	--All SpawnGroupsAreFull or none are suitable for this NPC. 
	--Now reset SpawnGroupIsFull + SpawnGroupLocationIterator and do it again
	
	for k, group in pairs(SpawnGroupContainer) do
		SpawnGroupLocationIterator[k] = 1
		SpawnGroupIsFull[k] = false
	end
	success, location = false, {}
	
	for k, group in pairs(SpawnGroupContainer) do
		if SpawnGroup[k].Enabled == true and SpawnGroupIsFull[k] == false then
			if SpawnGroup[k][ReturnIndexFromClass(NpcList[npcCounter]:GetClassname())] == true then
				success, location = FindFreeLocationInGroup(k, npcCounter)
				if success == true then
					return location
				else
					SpawnGroupIsFull[k] = true
				end
			end
		end
	end
	
	ModDebug("[Warning] Could not select the right SpawnGroup for this NPC")
	
	--If we didn't return until now there is no SpawnGroup available for this npc. Spawn him at the first enabled location and throw error
	for k, group in ipairs(SpawnGroupContainer) do
		if SpawnGroup[k].Enabled == true then
			if SpawnGroupContainer[k][1] == nil then
				ModDebug("[CRITICAL ALERT] No position available to spawn NPC! Mod may crash NOW or gameplay brakes!")
				return nil
			else
				ModDebug("[ALERT] NO position available for this NPC, spawning at random! Fix me!!!!!")
				return SpawnGroupContainer[k][1]
			end
		end
	end
end

--Looks for the next free SpawnLocation in a SpawnGroup for a certain npc
--EXTENDS ScanGroupsForSpawnLocation
_G.SpawnGroupLocationIterator = {}
function _G.FindFreeLocationInGroup(groupname, npcCounter)
	if SpawnGroup[groupname].Enabled == true then
		if SpawnGroup[groupname][ReturnIndexFromClass(NpcList[npcCounter]:GetClassname())] == true then	--Spawngroup can spawn NPC
			
			--Now look if you can find a free place in this spawn group
			if SpawnGroupLocationIterator[groupname] > #SpawnGroupContainer[groupname] then
				return false, nil	--returns false + nil if this spawn group already used all spawn locations
			else
				SpawnGroupLocationIterator[groupname] = SpawnGroupLocationIterator[groupname] + 1
				return true, SpawnLocation[SpawnGroupContainer[groupname][SpawnGroupLocationIterator[groupname] - 1]] --On success return the location
			end
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

function _G.Event_PolymerPickedUp(eventInfo)
	MyPolymer = MyPolymer + 1
end

-- Polymer Economy function
function _G.DoPolymerEconomy()
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
			UpdatePolymers = true
		end
		--end
	end
end

-- Manages a buy request from a shop
function _G.UseVender(vendername)

	local venderIndex = 0
	for i, vend in ipairs(Vender) do
		if vendername == vend.Name and vend.Entity ~= nil then
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
			
			if Vender[venderIndex].Prototype == "" then
				CommandStack.Add("ent_create "..Vender[venderIndex].Item)
				Vender[venderIndex].InUse = true
			else
				local prototype = Entities:FindByName(Entities:First(), Vender[venderIndex].Prototype)
				local protoSpawn = SpawnEntityFromTableSynchronous(Vender[venderIndex].Item, prototype)
				protoSpawn:SetOrigin(Vender[venderIndex].Entity:GetOrigin())
			end
			
			MyPolymer = MyPolymer - Vender[venderIndex].Price
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
					if vend.Prototype ~= "" then
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

-- Mag ejection workaround
function _G.Event_ClipGameWorkaround()
	local lookupItems = Entities:FindAllByClassname("item_hlvr_clip_energygun")
	for j = 1, #lookupItems, 1 do
		if GoodAlreadySet(lookupItems[j]) == true then
		else
			AlreadySetGoods[#AlreadySetGoods + 1] = lookupItems[j]
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

-- Does the scoreboard stuff
function _G.SetScore()
	ScoreTotal = ScoreTotal + ScoreForThisRound
	
	for i, board in ipairs(Scoreboard) do
		board:SetMessage("Score\n"..tostring(ScoreTotal))
	end
end

-- Calculates the score for the round which just started
function _G.GetNextScore()
	ScoreForThisRound = 0
	local lastWave = CurrentWave
	if lastWave > 1 then
		lastWave = lastWave - 1
	end
	for i = 1, #WaveList[lastWave], 1 do
		ScoreForThisRound = ScoreForThisRound + WaveList[lastWave][i] * ScorePerKill[i]
	end
end

-- Doing the Polymer eco for weapon upgrades
-- function _G.WeaponUpgraded(weapon, upgradeType)
	-- if weapon == "pistol" then
		-- if upgradeType == "sight" then
		
		-- elseif upgradeType == "burst" then
		
		-- end
	-- elseif weapon == "shotgun" then
		-- if upgradeType == "double" then
		
		-- elseif upgradeType == "grenade" then
		
		-- end
	-- elseif weapon == "rapidfire" then
	
	-- end
-- end

-- Triggered when the player uses the crafting station
-- function _G.Event_UpgradePistol_Lasersight(eventInfo)
	-- WeaponUpgraded("pistol", "sight")
-- end

-- function _G.Event_UpgradePistol_Burstfire(eventInfo)
	-- WeaponUpgraded("pistol", "burst")
-- end

-- A FEW UPGRADES MIGHT CAUSE BUGS AS WE DON'T HAVE THE GAME EVENTS FOR IT

-- function _G.Event_UpgradeShotgun_Double(eventInfo)
	-- WeaponUpgraded("shotgun", "double")
-- end

-- function _G.Event_UpgradeShotgun_Grenade(eventInfo)
	-- WeaponUpgraded("shotgun", "grenade")
-- end



--=============================================================================

--Gegner werden manchmal nicht registriert/positioniert? Also eine ganze welle steckt manchmal dort fest wo der spieler hinschaut

function GamemodeThink()
	if InitGamemodeDone == true then
		if DelayActive() == false then
			if UpdateStep == UPDATE_DELAY_INIT then
				UpdateStepTimer = UpdateStepTimer + 1
				
				if DebugEnabled == true then
					ModDebug("Starting game "..tostring(UpdateStepTimer).."/20")
				end
				
				if UpdateStepTimer == 2 then
					CommandStack.Add("sv_cheats 1")
					CommandStack.Add("sv_autosave 0")
					CommandStack.Add("0500hlvr_addresources 0 0 0 "..tostring(MyPolymer), COMMAND_DELAYEDCONSOLE)
				elseif UpdateStepTimer == 20 then
					UpdateStepTimer = 0
					UpdateStep = UPDATE_STEP_SPAWN
					DelayStart(StartDelay)
				end
				
			elseif UpdateStep == UPDATE_STEP_CHECK then
			
				if IsWaveAlive() == false then
					CleanupWave()
					EmitSoundOn(WaveFinishSound, ActivePlayer)

					UpdateStep = UPDATE_STEP_SPAWN
					
					DelayStart(WaveDelay)
					
					GetNextScore()
					SetScore()
					
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
				
				if HasWaveSpawned() == true then
					UpdateEnemyList(UpdateClasses)
					SetWavePositions()
					EmitSoundOn(WaveStartSound, ActivePlayer)
					
					UpdateStep = UPDATE_STEP_CHECK
				end
			end
		end
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
	
	UpdateModClock()
	
	if EnablePerformanceMode == true then
		return FrameTime()*16
	else
		return FrameTime()
	end
end