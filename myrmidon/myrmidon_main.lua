---------------------------------------------------
-- ___  ___                    ______       _    --
-- |  \/  |                    | ___ \     | |   --
-- | .  . |_   _ _ __ _ __ ___ | |_/ / ___ | |_  --
-- | |\/| | | | | '__| '_ ` _ \| ___ \/ _ \| __| --
-- | |  | | |_| | |  | | | | | | |_/ / (_) | |_  --
-- \_|  |_/\__, |_|  |_| |_| |_\____/ \___/ \__| --
--          __/ |                                --
--         |___/                                 --
---------------------------------------------------
--          A HoN Community Bot Project          --
---------------------------------------------------
--                  Created by:                  --
--       DarkFire       VHD       Kairus101      --
---------------------------------------------------

------------------------------------------
--          Bot Initialization          --
------------------------------------------

local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

object.bRunLogic = true
object.bRunBehaviors = true
object.bUpdates = true
object.bUseShop = true

object.bRunCommands = true
object.bMoveCommands = true
object.bAttackCommands = true
object.bAbilityCommands = true
object.bOtherCommands = true

object.bReportBehavior = false
object.bDebugUtility = false
object.bDebugExecute = false

object.logger = {}
object.logger.bWriteLog = false
object.logger.bVerboseLog = false

object.core = {}
object.eventsLib = {}
object.metadata = {}
object.behaviorLib = {}
object.skills = {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventsLib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorLib.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp

local sqrtTwo = math.sqrt(2)

BotEcho('loading myrmidon_main...')

---------------------------------
--          Constants          --
---------------------------------

-- Myrmidon
object.heroName = 'Hero_Hydromancer'

-- Item buy order. internal names
behaviorLib.StartingItems =
	{"Item_RunesOfTheBlight", "2 Item_MinorTotem", "Item_ManaBattery", "Item_HealthPotion"}
behaviorLib.LaneItems =
	{"Item_Steamboots", "Item_BloodChalice", "Item_Gloves3"} 
	--chalice on a bot will be crazy. Just time it before each kill, as you would a taunt.
	--Gloves3 is alchemists bones, faster attack speed + extra gold from jungle creeps. May as well impliment it as the first of it's type.
behaviorLib.MidItems =
	{"Item_Shield2", "Item_DaemonicBreastplate"} 
	--shield2 is HotBL. This should be changed to shamans if a high ratio of recieved damage is magic. (is this possible.)
	--I'm using a guide to set up these items, so, demonic.... maybe not.
behaviorLib.LateItems =
	{"Item_SpellShards 3", "Item_Lightning2", "Item_HarkonsBlade", "Item_BehemothsHeart"}
	--spellshards, because damage is important.
	--"Lightning2 is charged hammer. More attack speed, right?
	--harkons, solid all round.
	--heart, because we need tankyness now.

-- Skillbuild. 0 is Weed Field, 1 is Magic Carp, 2 is Wave Form, 3 is Forced Evolution, 4 is Attributes
object.tSkills = {
	0, 2, 0, 1, 0,
	3, 0, 1, 1, 2,
	3, 1, 2, 2, 4,
	3, 4, 4, 4, 4,
	4, 4, 4, 4, 4
}

-- Bonus agression points if a skill/item is available for use
object.nWeedFieldUp = 7
object.nMagicCarpUp = 7
object.nWaveFormUp = 7
object.nForcedEvolutionUp = 7

-- Bonus agression points that are applied to the bot upon successfully using a skill/item
object.nWeedFieldUse = 7
object.nMagicCarpUse = 7
object.nWaveFormUse = 7
object.nForcedEvolutionUse = 7

-- Thresholds of aggression the bot must reach to use these abilities
object.nWeedFieldThreshold = 35
object.nMagicCarpThreshold = 25
object.nWaveFormThreshold = 45
object.nForcedEvolutionThreshold = 40

-- Other variables

------------------------------
--          Skills          --
------------------------------

function object:SkillBuild()
	core.VerboseLog("SkillBuild()")

	local unitSelf = self.core.unitSelf
	if  skills.abilWeedField == nil then
		skills.abilWeedField = unitSelf:GetAbility(0)
		skills.abilMagicCarp = unitSelf:GetAbility(1)
		skills.abilWaveForm = unitSelf:GetAbility(2)
		skills.abilForcedEvolution = unitSelf:GetAbility(3)
		skills.abilAttributeBoost = unitSelf:GetAbility(4)
	end

	local nPoints = unitSelf:GetAbilityPointsAvailable()
	if nPoints <= 0 then
		return
	end

	local nLevel = unitSelf:GetLevel()
	for i = nLevel, (nLevel + nPoints) do
		unitSelf:GetAbility( self.tSkills[i] ):LevelUp()
	end
end

------------------------------------------
--          FindItems Override          --
------------------------------------------

local function funcFindItemsOverride(botBrain)
	local bUpdated = object.FindItemsOld(botBrain)

	if core.itemManaBattery ~= nil and not core.itemManaBattery:IsValid() then
		core.itemManaBattery = nil
	end
	
	if core.itemSteamboots ~= nil and not core.itemSteamboots:IsValid() then
		core.itemSteamboots = nil
	end
	
	if core.itemBloodChalice ~= nil and not core.itemBloodChalice:IsValid() then
		core.itemBloodChalice = nil
	end

	if core.itemAlchBones ~= nil and not core.itemAlchBones:IsValid() then
		core.itemAlchBones = nil
	end
	
	if bUpdated then
		if core.itemManaBattery and core.itemSteamboots and core.itemBloodChalice then
			return
		end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemManaBattery == nil and curItem:GetName() == "Item_ManaBattery" then
					core.itemManaBattery = core.WrapInTable(curItem)
				elseif core.itemSteamboots == nil and curItem:GetName() == "Item_Steamboots" then
					core.itemSteamboots = core.WrapInTable(curItem)
				elseif core.itemBloodChalice == nil and curItem:GetName() == "Item_BloodChalice" then
					core.itemBloodChalice = core.WrapInTable(curItem)
				elseif core.itemAlchBones == nil and curItem:GetName() == "Item_Gloves3" then
					core.itemAlchBones = core.WrapInTable(curItem)
				end
			end
		end
	end
end

object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride

----------------------------------------
--          OnThink Override          --
----------------------------------------

function object:onthinkOverride(tGameVariables)
	self:onthinkOld(tGameVariables)
	local bDebugGadgets=true
	
	if (bDebugGadgets) then
		local tUnits = HoN.GetUnitsInRadius(core.unitSelf:GetPosition(), 2000, core.UNIT_MASK_ALIVE + core.UNIT_MASK_GADGET)
		if tUnits then
			for _, unit in pairs(tUnits) do
				core.DrawDebugArrow(core.unitSelf:GetPosition(), unit:GetPosition(), 'yellow') --flint q/r, fairy port, antipull, homecoming, kongor, chronos ult
				BotEcho(unit:GetTypeName())
			end
		end
	end
	
	--track carp here, if there is no gadget for it.
end

object.onthinkOld = object.onthink
object.onthink = object.onthinkOverride

----------------------------------------------
--          OnCombatEvent Override          --
----------------------------------------------

function object:oncombateventOverride(EventData)
	self:oncombateventOld(EventData)

	local nAddBonus = 0

	if EventData.Type == "Ability" then
		if EventData.InflictorName == "Ability_Myrmidon1" then
			nAddBonus = nAddBonus + object.nWeedFieldUse
		elseif EventData.InflictorName == "Ability_Myrmidon2" then
			nAddBonus = nAddBonus + object.nMagicCarpUse
		elseif EventData.InflictorName == "Ability_Myrmidon3" then
			nAddBonus = nAddBonus + object.nWaveFormUse
		elseif EventData.InflictorName == "Ability_Myrmidon4" then
			nAddBonus = nAddBonus + object.nForcedEvolutionUse
		end
	end

	if nAddBonus > 0 then
		core.DecayBonus(self)
		core.nHarassBonus = core.nHarassBonus + nAddBonus
	end
end

object.oncombateventOld = object.oncombatevent
object.oncombatevent = object.oncombateventOverride

----------------------------------------------------
--          CustomHarassUtility Override          --
----------------------------------------------------

local function CustomHarassUtilityFnOverride(hero)
	local nUtility = 0
	
	if skills.abilWeedField:CanActivate() then
		nUtility = nUtility + object.nWeedFieldUp
	end
	
	if skills.abilMagicCarp:CanActivate() then
		nUtility = nUtility + object.nMagicCarpUp
	end
	
	if skills.abilWaveForm:CanActivate() then
		nUtility = nUtility + object.nWaveFormUp
	end
	
	if skills.abilForcedEvolution:CanActivate() then
		nUtility = nUtility + object.nForcedEvolutionUp
	end
	
	return nUtility
end

behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride

----------------------------------------
--          Harass Behaviour          --
----------------------------------------

local function HarassHeroExecuteOverride(botBrain)
	
	local unitTarget = behaviorLib.heroTarget
	if unitTarget == nil then
		return object.harassExecuteOld(botBrain)
	end

	local unitSelf = core.unitSelf
	local vecMyPosition = unitSelf:GetPosition()
	
	local vecTargetPosition = unitTarget:GetPosition()
	local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
	local bCanSeeTarget = core.CanSeeUnit(botBrain, unitTarget)
	
	local nLastHarassUtility = behaviorLib.lastHarassUtil
	local bActionTaken = false

	--Weed Field
	if not bActionTaken then
		local abilWeedField = skills.abilWeedField
		if abilWeedField:CanActivate() and nLastHarassUtility > object.nWeedFieldThreshold then
			bActionTaken = core.OrderAbilityPosition(botBrain, skills.abilWeedField, vecTargetPosition)
		end
	end
	
	--Magic Carp
	if not bActionTaken then
		local abilMagicCarp = skills.abilMagicCarp
		if abilMagicCarp:CanActivate() and bCanSeeTarget and nLastHarassUtility > object.nMagicCarpThreshold then
			bActionTaken = core.OrderAbilityEntity(botBrain, skills.abilMagicCarp, unitTarget)
		end
	end
	
	--Wave Form
	if not bActionTaken then
		local abilWaveForm = skills.abilWaveForm
		if abilWaveForm:CanActivate() and nLastHarassUtility > object.nWaveFormThreshold then
			bActionTaken = core.OrderAbilityPosition(botBrain, skills.abilWaveForm, vecTargetPosition)
		end
	end
	
	--ForcedEvolution
	if not bActionTaken then
		local abilForcedEvolution = skills.abilForcedEvolution
		if abilForcedEvolution:CanActivate() and nLastHarassUtility>object.nForcedEvolutionThreshold then
			bActionTaken = core.OrderAbility(botBrain, skills.abilForcedEvolution)
		end
	end

	return bActionTaken
end

object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

--------------------------------------
--          UseHealthRegen          --
--------------------------------------
--
-- Utility: 0 to 40
-- Based on missing health
--
-- Execute: 
-- Use a Rune of the Blight, Health Pot, or Bottle to heal
-- Will only use Health Pot or Bottle if it is safe
--

-------- Global Constants & Variables --------
behaviorLib.nBatterySupplyHealthUtility = 0

behaviorLib.bUseBatterySupplyForHealth = true

-------- Helper Functions --------
local function GetSafeDrinkDirection()
	-- Returns vector to a safe direciton to retreat to drink if the bot is threatened
	-- Returns nil if safe
	local bDebugLines = true
	local vecSafeDirection = nil
	local vecSelfPos = core.unitSelf:GetPosition()
	local tThreateningUnits = {}
	for _, unitEnemy in pairs(core.localUnits["EnemyUnits"]) do
		local nAbsRange = core.GetAbsoluteAttackRangeToUnit(unitEnemy, unitSelf)
		local nDist = Vector3.Distance2D(vecSelfPos, unitEnemy:GetPosition())
		if nDist < nAbsRange * 1.15 then
			local unitPair = {}
			unitPair[1] = unitEnemy
			unitPair[2] = (nAbsRange * 1.15 - nDist)
			tinsert(tThreateningUnits, unitPair)
		end
	end

	local curTimeMS = HoN.GetGameTime()
	if core.NumberElements(tThreateningUnits) > 0 or eventsLib.recentDotTime > curTimeMS or #eventsLib.incomingProjectiles["all"] > 0 then
		-- Determine best "away from threat" vector
		local vecAway = Vector3.Create()
		for _, unitPair in pairs(tThreateningUnits) do
			local unitAwayVec = Vector3.Normalize(vecSelfPos - unitPair[1]:GetPosition())
			vecAway = vecAway + unitAwayVec * unitPair[2]

			if bDebugLines then
				core.DrawDebugArrow(unitPair[1]:GetPosition(), unitPair[1]:GetPosition() + unitAwayVec * unitPair[2], 'teal')
			end
		end

		if core.NumberElements(tThreateningUnits) > 0 then
			vecAway = Vector3.Normalize(vecAway)
		end

		-- Average vecAway with "retreat" vector
		local vecRetreat = Vector3.Normalize(behaviorLib.PositionSelfBackUp() - vecSelfPos)
		local vecSafeDirection = Vector3.Normalize(vecAway + vecRetreat)

		if bDebugLines then
			local nLineLen = 150
			core.DrawDebugArrow(vecSelfPos, vecSelfPos + vecRetreat * nLineLen, 'blue')
			core.DrawDebugArrow(vecSelfPos, vecSelfPos + vecAway * nLineLen, 'teal')
			core.DrawDebugArrow(vecSelfPos, vecSelfPos + vecSafeDirection * nLineLen, 'white')
			core.DrawXPosition(vecSelfPos + vecSafeDirection * core.moveVecMultiplier, 'blue')
		end
	end

	return vecSafeDirection
end

local function BatterySupplyHealthUtilFn(nHealthMissing, nCharges)
	-- With 1 Charge:
	-- Roughly 20+ when we are missing 28 health
	-- Function which crosses 20 at x=28 and 40 at x=300, convex down
	-- With 15 Charges:
	-- Roughly 20+ when we are missing 168 health
	-- Function which crosses 20 at x=168 and 30 at x=320, convex down

	local nHealAmount = 10 * nCharges
	local nHealBuffer = 18
	local nUtilityThreshold = 20

	local vecPoint = Vector3.Create(nHealAmount + nHealBuffer, nUtilityThreshold)
	local vecOrigin = Vector3.Create(-250, -30)
	return core.ATanFn(nHealthMissing, vecPoint, vecOrigin, 100)
end

-------- Behavior Functions --------
local function UseHealthRegenUtilityOverride(botBrain)
	StartProfile("Init")
	local bDebugLines = false

	local nUtility = 0
	local nBatterySupplyUtility = 0
	local nHealthPotUtility = 0
	local nBlightsUtility = 0

	local unitSelf = core.unitSelf
	local nHealthMissing = unitSelf:GetMaxHealth() - unitSelf:GetHealth()
	local tInventory = unitSelf:GetInventory()
	StopProfile()

	StartProfile("Mana Battery/Power Supply")
	if behaviorLib.bUseBatterySupplyForHealth then
		local itemManaBattery = core.itemManaBattery
		local itemPowerSupply = core.itemPowerSupply
		local itemBatterySupply = nil
		if itemManaBattery then
			itemBatterySupply = itemManaBattery
		elseif itemPowerSupply then
			itemBatterySupply = itemPowerSupply
		end

		if itemBatterySupply and itemBatterySupply:CanActivate() then
			local nCharges = itemBatterySupply:GetCharges()
			if nCharges > 0 then
				nBatterySupplyUtility = BatterySupplyHealthUtilFn(nHealthMissing, nCharges)
			end
		end
	end
	StopProfile()

	StartProfile("Health pot")
	local tHealthPots = core.InventoryContains(tInventory, "Item_HealthPotion")
	if #tHealthPots > 0 and not unitSelf:HasState("State_HealthPotion") then
		nHealthPotUtility = behaviorLib.HealthPotUtilFn(nHealthMissing)
	end
	StopProfile()

	StartProfile("Runes")
	local tBlights = core.InventoryContains(tInventory, "Item_RunesOfTheBlight")
	if #tBlights > 0 and not unitSelf:HasState("State_RunesOfTheBlight") then
		nBlightsUtility = behaviorLib.RunesOfTheBlightUtilFn(nHealthMissing)
	end
	StopProfile()

	StartProfile("End")
	nUtility = max(nBatterySupplyUtility, nHealthPotUtility, nBlightsUtility)
	nUtility = Clamp(nUtility, 0, 100)

	behaviorLib.nBatterySupplyHealthUtility = nBatterySupplyUtility
	behaviorLib.nHealthPotUtility = nHealthPotUtility
	behaviorLib.nBlightsUtility = nBlightsUtility

	if bDebugLines then
		local vecLaneForward = object.vecLaneForward
		if vecLaneForward then
			local vecPos = unitSelf:GetPosition()
			local nHalfSafeTreeAngle = behaviorLib.safeTreeAngle / 2
			local vec1 = core.RotateVec2D(-vecLaneForward, nHalfSafeTreeAngle)
			local vec2 = core.RotateVec2D(-vecLaneForward, -nHalfSafeTreeAngle)
			core.DrawDebugLine(vecPos, vecPos + vec1 * 2000, 'white')
			core.DrawDebugLine(vecPos, vecPos + vec2 * 2000, 'white')
			core.DrawDebugArrow(vecPos, vecPos + -vecLaneForward * 150, 'white')
		end
	end

	if botBrain.bDebugUtility == true and nUtility ~= 0 then
		BotEcho(format("  UseHealthRegenUtility: %g", nUtility))
	end
	StopProfile()

	return nUtility
end

local function UseHealthRegenExecuteOverride(botBrain)
	local bDebugLines = false
	local bActionTaken = false
	local unitSelf = core.unitSelf
	local vecSelfPos = unitSelf:GetPosition()
	local tInventory = unitSelf:GetInventory()
	local nMaxUtility = max(behaviorLib.nBatterySupplyHealthUtility, behaviorLib.nBlightsUtility, behaviorLib.nHealthPotUtility)

	-- Use Runes to heal
	if not bActionTaken and behaviorLib.nBlightsUtility == nMaxUtility then
		local tBlights = core.InventoryContains(tInventory, "Item_RunesOfTheBlight")
		if #tBlights > 0 and not unitSelf:HasState("State_RunesOfTheBlight") then
			-- Get closest tree
			local unitClosestTree = nil
			local nClosestTreeDistSq = 9999 * 9999
			local vecLaneForward = object.vecLaneForward
			local vecLaneForwardNeg = -vecLaneForward
			local funcRadToDeg = core.RadToDeg
			local funcAngleBetween = core.AngleBetween
			local nHalfSafeTreeAngle = behaviorLib.safeTreeAngle / 2

			core.UpdateLocalTrees()
			local tTrees = core.localTrees
			for _, unitTree in pairs(tTrees) do
				vecTreePosition = unitTree:GetPosition()
				-- "Safe" trees are backwards
				if not vecLaneForward or abs(funcRadToDeg(funcAngleBetween(vecTreePosition - vecSelfPos, vecLaneForwardNeg)) ) < nHalfSafeTreeAngle then
					local nDistSq = Vector3.Distance2DSq(vecTreePosition, vecSelfPos)
					if nDistSq < nClosestTreeDistSq then
						unitClosestTree = unitTree
						nClosestTreeDistSq = nDistSq
						if bDebugLines then
							core.DrawXPosition(vecTreePosition, 'yellow')
						end
					end
				end
			end

			if unitClosestTree then
				bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, tBlights[1], unitClosestTree)
			end
		end
	end

	-- Use Health Potion to heal
	if not bActionTaken and behaviorLib.nHealthPotUtility == nMaxUtility then
		local tHealthPots = core.InventoryContains(tInventory, "Item_HealthPotion")
		if #tHealthPots > 0 and not unitSelf:HasState("State_HealthPotion") then
			local vecRetreatDirection = GetSafeDrinkDirection()
			-- Check if it is safe to drink
			if vecRetreatDirection then
				bActionTaken = core.OrderMoveToPosClamp(botBrain, unitSelf, vecSelfPos + vecRetreatDirection * core.moveVecMultiplier, false)
			else
				bActionTaken = core.OrderItemEntityClamp(botBrain, unitSelf, tHealthPots[1], unitSelf)
			end
		end
	end

	-- Use Mana Battery/Power Supply to heal
	if not bActionTaken and behaviorLib.nBatterySupplyHealthUtility == nMaxUtility then
		local itemManaBattery = core.itemManaBattery
		local itemPowerSupply = core.itemPowerSupply
		local itemBatterySupply = nil
		if itemManaBattery then
			itemBatterySupply = itemManaBattery
		elseif itemPowerSupply then
			itemBatterySupply = itemPowerSupply
		end

		if itemBatterySupply and itemBatterySupply:CanActivate() and itemBatterySupply:GetCharges() > 0 then
			bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBatterySupply)
		end
	end

	return bActionTaken
end

behaviorLib.UseHealthRegenBehavior["Utility"] = UseHealthRegenUtilityOverride
behaviorLib.UseHealthRegenBehavior["Execute"] = UseHealthRegenExecuteOverride

------------------------------------
--          UseManaRegen          --
------------------------------------
--
-- Utility: 0 to 40
-- Based on missing mana
--
-- Execute:
-- Use Mana Battery to restore mana
--

-------- Global Constants & Variables --------
behaviorLib.nBatterySupplyManaUtility = 0

behaviorLib.bUseBatterySupplyForMana = true

-------- Helper Functions --------
function behaviorLib.BatterySupplyManaUtilFn(nManaMissing, nCharges)
	-- With 1 Charge:
	-- Roughly 20+ when we are missing 40 mana
	-- Function which crosses 20 at x=40 and 40 at x=260, convex down
	-- With 15 Charges:
	-- Roughly 20+ when we are missing 280 mana
	-- Function which crosses 20 at x=280 and 30 at x=470, convex down

	local nManaRegenAmount = 15 * nCharges
	local nManaBuffer = 25
	local nUtilityThreshold = 20

	local vecPoint = Vector3.Create(nManaRegenAmount + nManaBuffer, nUtilityThreshold)
	local vecOrigin = Vector3.Create(-60, -50)
	return core.ATanFn(nManaMissing, vecPoint, vecOrigin, 100)
end

-------- Behavior Functions --------
function behaviorLib.UseManaRegenUtility(botBrain)
	StartProfile("Init")
	local bDebugEchos = false

	local nUtility = 0
	local nBatterySupplyUtility = 0

	local unitSelf = core.unitSelf
	local nManaMissing = unitSelf:GetMaxMana() - unitSelf:GetMana()
	local tInventory = unitSelf:GetInventory()
	StopProfile()

	StartProfile("Mana Battery/Power Supply")
	if behaviorLib.bUseBatterySupplyForMana then
		local itemManaBattery = core.itemManaBattery
		local itemPowerSupply = core.itemPowerSupply
		local itemBatterySupply = nil
		if itemManaBattery then
			itemBatterySupply = itemManaBattery
		elseif itemPowerSupply then
			itemBatterySupply = itemPowerSupply
		end

		if itemBatterySupply and itemBatterySupply:CanActivate() then
			local nCharges = itemBatterySupply:GetCharges()
			if nCharges > 0 then
				nBatterySupplyUtility = behaviorLib.BatterySupplyManaUtilFn(nManaMissing, nCharges)
			end
		end
	end
	StopProfile()

	StartProfile("End")
	nUtility = max(nBatterySupplyUtility)
	nUtility = Clamp(nUtility, 0, 100)

	behaviorLib.nBatterySupplyManaUtility = nBatterySupplyUtility

	if botBrain.bDebugUtility == true and nUtility ~= 0 then
		BotEcho(format("  UseManaRegenUtility: %g", nUtility))
	end
	StopProfile()

	return nUtility
end

function behaviorLib.UseManaRegenExecute(botBrain)
	local bActionTaken = false
	local unitSelf = core.unitSelf
	local vecSelfPos = unitSelf:GetPosition()
	local tInventory = unitSelf:GetInventory()
	local nMaxUtility = max(behaviorLib.nBatterySupplyManaUtility)

	-- Use Mana Battery/Power Supply to regen mana
	if not bActionTaken and behaviorLib.nBatterySupplyManaUtility == nMaxUtility then
		local itemManaBattery = core.itemManaBattery
		local itemPowerSupply = core.itemPowerSupply
		local itemBatterySupply = nil
		if itemManaBattery then
			itemBatterySupply = itemManaBattery
		elseif itemPowerSupply then
			itemBatterySupply = itemPowerSupply
		end

		if itemBatterySupply and itemBatterySupply:CanActivate() and itemBatterySupply:GetCharges() > 0 then
			bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBatterySupply)
		end
	end

	return bActionTaken
end

behaviorLib.UseManaRegenBehavior = {}
behaviorLib.UseManaRegenBehavior["Utility"] = behaviorLib.UseManaRegenUtility
behaviorLib.UseManaRegenBehavior["Execute"] = behaviorLib.UseManaRegenExecute
behaviorLib.UseManaRegenBehavior["Name"] = "UseManaRegen"
tinsert(behaviorLib.tBehaviors, behaviorLib.UseManaRegenBehavior)

-----------------------------------
--          Custom Chat          --
-----------------------------------

core.tKillChatKeys={
    "BUAHAHAHA!",
}

core.tDeathChatKeys = {
    "Spinning out of control..",
}

BotEcho(object:GetName()..' finished loading myrmidon_main')
