--============ Copyright (c) Manuel "Manello" Bäuerle, All rights reserved. ==========
-- Before using/modifying this code, please read LICENSE.txt
-- 
--=============================================================================

--Force next iteration of Script
function ForceNextIteration()
	if UpdateStep == UPDATE_STEP_CHECK then
		UpdateStep = UPDATE_STEP_SPAWN
	elseif UpdateStep == UPDATE_STEP_SPAWN then
		UpdateStep = UPDATE_STEP_REGISTER
	elseif UpdateStep == UPDATE_STEP_REGISTER then
		UpdateStep = UPDATE_STEP_CHECK
	end
	
	SendToConsole("script_reload_code myGamemode")

end

--Register each enemy DIRECTLY after it spawned
--returns true on successfully registering one NPC
function RegisterNewEnemy(enemyClass)
	local firstEnt = Entities:First()
	local currEnt = firstEnt
	
	while true do
		if currEnt:GetClassname() == enemyClass then
			if IsEnemyRegistered(currEnt) == false then
				NpcList[#NpcList + 1] = currEnt
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
function UpdateEnemyList(generatedClasses)
	NpcList = {}

	for i = 1, #generatedClasses, 1 do
		repeat until (RegisterNewEnemy(generatedClasses[i]) == false)
	end
end

--Check if an Enemy got registered by my scripts
function IsEnemyRegistered(theEnemyEnt)

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
function SpawnWave(waveNr)
	
	UpdateClasses = {} 
	local c = 1
	local d = 1
	for i = 1, #WaveList[waveNr], 1 do
		if WaveList[waveNr][i] ~= 0 then
			UpdateClasses[c] = EntEnums[i]

			for j = 1, WaveList[waveNr][i], 1 do
				SendToConsole("ent_create "..EntEnums[i])
				
				d = d + 1
				if d > #SpawnLocation then
					d = 1
				end
			end
			
			c = c + 1
		end
	end	
end

--Sets Wave Positions and Difficulty
function SetWavePositions()
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
function IsWaveAlive()
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

-- Mark Entities for Deletion (1 delete per call)
function CleanupWave()
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

-- Gets Killed Ents
function GetRecentKills()
	local firstEnt = Entities:First()
	local currEnt = firstEnt
	local killedEnts = {}
	local isFreshKill = true
	
	repeat
		isFreshKill = true
		if currEnt:IsAlive() == false then
			for i, ent in ipairs(PolymersFreshSpawn) do
				if ent == currEnt then
					isFreshKill = false
					break
				end
			end
			
			if isFreshKill == true then
				killedEnts[#killedEnts + 1] = currEnt
				PolymersFreshSpawn[#PolymersFreshSpawn + 1] = currEnt
			end
		end
	
		currEnt = Entities:Next(currEnt)
		if currEnt == nil then
			currEnt = Entities:Next(currEnt)
		end
	until (currEnt == firstEnt)
	
	return killedEnts
end

-- Polymer Economy function
function DoPolymerEconomy()

	--move old
	--local firstEnt = Entities:First()
	--local currEnt = firstEnt
	--local isSet = false
	
	--if UpdatePolymers == true then
	--	repeat
	--		isSet = false
	--		
	--		if #AlreadySetPolymers == 0 then
	--			break
			-- end
			
			-- if currEnt:GetClassname() == "item_hlvr_crafting_currency_small" then
				-- for i, ent in ipairs(AlreadySetPolymers) do
					-- if ent == currEnt then
						-- isSet = true
						-- break
					-- end
				-- end
				
				-- if isSet == false then
					-- currEnt:SetAbsOrigin(PolymersFreshSpawn[1]:GetAbsOrigin())
					-- AlreadySetPolymers[#AlreadySetPolymers + 1] = currEnt
					-- table.remove(PolymersFreshSpawn, 1)
				-- end
			-- end
		
			-- currEnt = Entities:Next(currEnt)
			-- if currEnt == nil then
				-- currEnt = Entities:Next(currEnt)
			-- end
		-- until (currEnt == firstEnt)
	
		-- UpdatePolymers = false
	-- end

	--add new
	local killedEnts = GetRecentKills()
	if #killedEnts > 0 then
		--for i, deadEnt in ipairs(killedEnts) do
			SendToConsole("ent_create item_hlvr_crafting_currency_small")
		--end
		UpdatePolymers = true
	end
end

--=============================================================================

if InitGamemodeDone == true then
	if UpdateStep == UPDATE_DELAY_INIT then
		UpdateStepTimer = UpdateStepTimer + 1
		print ("Starting game ", UpdateStepTimer, "/10")
		
		if UpdateStepTimer == 2 then
			CommandStack.Add("sv_cheats 1")
			CommandStack.Add("sv_autosave 0")
			CommandStack.Add("impulse 101")
			CommandStack.Add("hlvr_addresources 0 0 0 "..tostring(-20+MyPolymer))
			
		elseif UpdateStepTimer == 10 then
			UpdateStepTimer = 0
			UpdateStep = UPDATE_STEP_SPAWN
		end
		
		CommandStack.Exec()
		
	elseif UpdateStep == UPDATE_STEP_CHECK then
		
		CommandStack.Exec()
		
		if #ToDelete > 0 then
			if ToDelete[#ToDelete] ~= nil then
				CommandStack.Add("ent_remove "..tostring(ToDelete[#ToDelete]:entindex()))
				table.remove(ToDelete)
			end
		end
	
		if UpdateBoughtAmmo == true then
			_G.BuyAmmo(true)
		end
		if UpdateBoughtShells == true then
			_G.BuyShells(true)
		end
		if UpdateBoughtEnergy == true then
			_G.BuyEnergy(true)
		end
		if UpdateBoughtMedkit == true then
			_G.BuyMedkit(true)
		end
		if UpdateBoughtHealth == true then
			_G.BuyHealth(true)
		end
		
		DoPolymerEconomy()
	
		if IsWaveAlive() == false then
			CleanupWave()
			UpdateStep = UPDATE_STEP_SPAWN
		end
		
	elseif UpdateStep == UPDATE_STEP_SPAWN then
		
		print("Spawning Wave "..tostring(CurrentWave))
		
		SpawnWave(CurrentWave)
		
		CurrentWave = CurrentWave + 1
		if CurrentWave > #WaveList then
			CurrentWave = 1
			WaveModifier = WaveModifier * 2
		end
		
		UpdateStep = UPDATE_STEP_REGISTER
		
	elseif UpdateStep == UPDATE_STEP_REGISTER then
		
		UpdateEnemyList(UpdateClasses)
		SetWavePositions()
		
		UpdateStep = UPDATE_STEP_CHECK
	
	end
end
