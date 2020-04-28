--============ Copyright (c) Manuel "Manello" Bäuerle, All rights reserved. ==========
-- Before using/modifying this code, please read LICENSE.txt
-- 
-- This file contains all functions used specifically by XenThug
--=============================================================================

--Check if an Enemy got registered by my scripts
function _G.IsEnemyRegistered(theEnemyEnt)

	if #NpcList == 0 then
		return false
	end

	local i = 1
	repeat
		if NpcList[i].handle == theEnemyEnt then
			return true
		end
		i = i + 1
	until(i > #NpcList)
	
	return false
end

--Checks if all ents of a wave spawned in, and registers them
function _G.HasWaveSpawned()
	for i = 1, #NpcList, 1 do
		if NpcList[i].handle == nil then
			local npcLookup = Entities:FindByName(Entities:First(), NpcList[i].name)
			if npcLookup == nil then
				return false
			else
				NpcList[i].handle = npcLookup
				
				if DebugEnabled == true then
					ModDebug("Registered Enemy: "..npcLookup:GetName().." "..npcLookup:GetClassname().." "..npcLookup:GetModelName())
				end
			end
		end		
	end
	
	return true
end

--Yup
function _G.SpawnWave(waveNr)
	NpcList = {}
	local c = 1
	local d = 1
	for i = 1, #WaveList[waveNr], 1 do
		if WaveList[waveNr][i] ~= 0 then

			for j = 1, WaveList[waveNr][i], 1 do
				local npcString = "XT"..tostring(TotalNpcCounter)
				local modelString = ""
				
				if EntEnums[i] == "combineVariant_heavy" then
					modelString = "models/characters/combine_soldier_heavy/combine_soldier_heavy.vmdl"
				elseif EntEnums[i] == "combineVariant_suppressor" then
					modelString = "models/characters/combine_suppressor/combine_suppressor.vmdl"
				elseif EntEnums[i] == "combineVariant_captain" then
					modelString = "models/characters/combine_soldier_captain/combine_captain.vmdl"
				end	
				
				if modelString == "" then
					CommandStack.Add("ent_create "..EntEnums[i].." {\"targetname\" \""..npcString.."\"}")
				else
					CommandStack.Add("ent_create ".."npc_combine_s".." {\"targetname\" \""..npcString.."\" \"model\" "..modelString.."\"}")
				end
				
				NpcList[#NpcList + 1] = {name = npcString, handle = nil}
				TotalNpcCounter = TotalNpcCounter + 1
				
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
			NpcList[i].handle:SetAbsOrigin(SpawnLocation[d]:GetAbsOrigin())
			NpcList[i].handle:SetOrigin(SpawnLocation[d]:GetOrigin())
			NpcList[i].handle:SetHealth(NpcList[i].handle:GetHealth() * WaveModifier)
			
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
			
			NpcList[i].handle:SetAbsOrigin(spawnLocationSelected:GetAbsOrigin())
			NpcList[i].handle:SetOrigin(spawnLocationSelected:GetOrigin())
			NpcList[i].handle:SetHealth(NpcList[i].handle:GetHealth() * WaveModifier)
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
			if SpawnGroup[k][ReturnIndexFromClass(NpcList[npcCounter].handle:GetClassname())] == true then
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
			if SpawnGroup[k][ReturnIndexFromClass(NpcList[npcCounter].handle:GetClassname())] == true then
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
		if SpawnGroup[groupname][ReturnIndexFromClass(NpcList[npcCounter].handle:GetClassname())] == true then	--Spawngroup can spawn NPC
			
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
	for i, npc in ipairs(NpcList) do
		local npcLookup = Entities:FindByName(Entities:First(), npc.name)
		if npcLookup ~= nil then
			if npcLookup:GetClassname() ~= "prop_ragdoll" then
				return true
			end
		end
	end
	
	return false
end

-- Mark Entities for Deletion (1 delete per tick)
function _G.CleanupWave()
	local firstEnt = Entities:First()
	local currEnt = firstEnt
	
	repeat
		if currEnt:GetClassname() == "prop_ragdoll" then	--TO-FIX: Take the preregistered and dont delete them
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

-- Checks if the player can buy something for X polymers. Used by custom scripts
function _G.CanBuyFor(amount)
	if MyPolymer >= amount then
		return true
	else
		return false
	end
end

-- Buys something for X Polymers. Used by custom scripts
function _G.BuyFor(amount)
	if MyPolymer >= amount then
		MyPolymer = MyPolymer - amount
		return true
	else
		if DebugEnabled == true then
			ModDebug("[Warning] Failed to buy something")
		end
		return false
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

-- Sets the wave number on all wave boards
function _G.SetWaveboard ()
	for i, board in ipairs(Waveboard) do
		board:SetMessage("Wave\n"..tostring(TotalWavesPlayed))
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
	if HardPause == false then
		if InitGamemodeDone == true then
			if DelayActive() == false then
				if SoftPause == false then
					if UpdateStep == UPDATE_DELAY_INIT then
						UpdateStepTimer = UpdateStepTimer + 1
						
						if DebugEnabled == true then
							ModDebug("Starting game "..tostring(UpdateStepTimer).."/20")
						end
						
						if UpdateStepTimer == 2 then
							CommandStack.Add("sv_cheats 1")
							CommandStack.Add("sv_autosave 0")
							CommandStack.Add("buddha 1")
							CommandStack.Add("hlvr_heartbeat_enable 1")
							CommandStack.Add("0500hlvr_addresources 0 0 0 "..tostring(MyPolymer), COMMAND_DELAYEDCONSOLE)
							
							if _G.InitMap ~= nil then
								InitMap()
							end
							
						elseif UpdateStepTimer == 20 then
							UpdateStepTimer = 0
							UpdateStep = UPDATE_STEP_SPAWN
							DelayStart(StartDelay)
						end
						
					elseif UpdateStep == UPDATE_STEP_CHECK then
					
						if PlayerDied == false then
							if ActivePlayer:GetHealth() <= 1.5 and PlayerDied == false then
							
								local teleportTo = Entities:FindByName(Entities:First(), "PlayerMenu")
								if teleportTo == nil then
									ModDebug("[ERROR] Failed to find PlayerMenu teleport location! Cant kill player. CRASH")
									return
								end
								
								ActivePlayer:SetOrigin(teleportTo:GetOrigin())
								ActivePlayer:SetAbsOrigin(teleportTo:GetAbsOrigin())
								local posString = "setpos "..tostring(math.floor(teleportTo:GetAbsOrigin().x)).." "..tostring(math.floor(teleportTo:GetAbsOrigin().y)).." "..tostring(math.floor(teleportTo:GetAbsOrigin().z))
								
								PlayerDied = true
								
								--Remove headcrab for the case on is on players face
								local aliveCrabs = Entities:FindAllByClassname("npc_headcrab")
								for i, crab in ipairs(aliveCrabs) do
									CommandStack.Add("ent_remove "..tostring(crab:entindex()))
								end
								
								posString = "0300"..posString
								CommandStack.Add(posString, COMMAND_DELAYEDCONSOLE)
								
								CommandStack.Add("hlvr_heartbeat_enable 0")
							end
						
							if IsWaveAlive() == false and WaveIsDead == false then
								DelayStart(WaveDelay)										--Delay needed to avoid immortal headcrab
								WaveIsDead = true
								
								EmitSoundOn(WaveFinishSound, ActivePlayer)
								
								WaveDoInternalCommands(CurrentWave)
								
								return FrameTime()
							end
							
							if WaveIsDead == true then
								CleanupWave()
							
								WaveIsDead = false
								UpdateStep = UPDATE_STEP_SPAWN
								
								if UseScoreboard == true then
									GetNextScore()
									SetScore()
								end
								
								if DebugEnabled == true then
									ModDebug("Wave dead. Cleanup started.")
								end
							end
						else
							if PortedPlayerToMenu == false then
								ModDebug("Finished game with a score of "..tostring(ScoreTotal).." in "..tostring(TotalWavesPlayed).." Waves")
								local teleportTo = Entities:FindByName(Entities:First(), "PlayerMenu")
								
								if 		(math.abs(ActivePlayer:GetOrigin().x) - math.abs(teleportTo:GetAbsOrigin().x)) > 3 
									or	(math.abs(ActivePlayer:GetOrigin().y) - math.abs(teleportTo:GetAbsOrigin().y)) > 3
									or	(math.abs(ActivePlayer:GetOrigin().z) - math.abs(teleportTo:GetAbsOrigin().z)) > 3 then
									
									CommandStack.Add("sv_cheats 1")
									ActivePlayer:SetOrigin(teleportTo:GetOrigin())
									ActivePlayer:SetAbsOrigin(teleportTo:GetAbsOrigin())
									
									local posString = "setpos "..tostring(math.floor(teleportTo:GetAbsOrigin().x)).." "..tostring(math.floor(teleportTo:GetAbsOrigin().y)).." "..tostring(math.floor(teleportTo:GetAbsOrigin().z))
									CommandStack.Add(posString)
								else
									PortedPlayerToMenu = true
									if DebugEnabled == true then
										ModDebug("Player Teleported.")
									end
								end
							end
						end
						
					elseif UpdateStep == UPDATE_STEP_SPAWN then
							
						if DebugEnabled == true then
							ModDebug("Spawning Wave "..tostring(CurrentWave))
						end
						
						TotalWavesPlayed = TotalWavesPlayed + 1
						if UseWaveboard == true then
							SetWaveboard()
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
							SetWavePositions()
							EmitSoundOn(WaveStartSound, ActivePlayer)
							
							UpdateStep = UPDATE_STEP_CHECK
						end
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
end