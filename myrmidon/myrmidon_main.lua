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

--BUG: Myrm stalled out - no movement, sitting in lane safe away from any units.  Yellow arrow to jungle camps still toggling.  Courier was dead...
--		Perhaps trying to buy on non-existant courier??

-- NOTE: bCanSeeTarget in HarassHeroExecute only needs to be checked if we are using OrderAbilityEntity or OrderItemEntity
-- Note2: I reverted the Steamboots change because the well provides 4% of your max mana/health per second so switching to agi has no effect

--Proposed TO-DO list
--	Items:
--		Refine item choices
--  		Need to decide on gank/support/tank/nuke build (or variable build?)
--			I propose adding Lex Talionis after red boots and chalice. Provides magic armor and nice damage amp to burst skills
--			Consider adding grimoire/lightbrand for boosted magic dmg?  Maybe insanitarious for stronger attacks in ult form?
--			Add BKB for late game so we can fight in ult form up close without getting stunned/nuked?
--		Chalice, use whenever we have > 80%(?) hp but < 60%(?) mana.

--  Retreat behavior
--		Ult if about to die (for +hp)
--		Waveform away (pick node nearest max range wave away from threat).
--			Can we detect incoming damage sources before they hit (MOA nuke, hammer stun, ellonia ult) and wave away?
--		Weed/carp to slow down pursuer?

--  Harass behavior
--		Weed:
--			Test/refine target's location prediction?  Currently using Stolen's RA meteor code, but only tracks current target...
--			If carp active, track target and carp locations.  Estimate intercept and cast weed field so that it triggers at time/location of carp intercept?
--			If target is stunned/slowed/snared/etc, boost aggression on weed?  Easy to land if target not moving!
--		Carp:
--			Cast on targets out of attack range that have HP pot on
--			Set up thresholds/sequence to cast before weed when possible (allow setup synergy for better chance of landing weed field)
--		Wave:
--			For far off targets with low hp, use to close distance in order to get nukes off?
--			For close targets, use in a way to pass through enemy target (to slow target)
--		Ult:
--			Turn on when target is slow/immobalized and we are in close/melee range?

--  Other
--		I can implement mana pots into UseManaRegen if we want to use them (The code is already written just needs to be copy-pasted) -DarkFire

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

runfile "bots/jungleLib.lua"
local jungleLib = object.jungleLib

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
object.nWeedFieldUp = 5
object.nMagicCarpUp = 3
object.nWaveFormUp = 2
object.nForcedEvolutionUp = 4

-- Bonus agression points that are applied to the bot upon successfully using a skill/item
object.nWeedFieldUse = 4
object.nMagicCarpUse = 4
object.nWaveFormUse = 2
object.nForcedEvolutionUse = 20

-- Thresholds of aggression the bot must reach to use these abilities
object.nWeedFieldThreshold = 45
object.nMagicCarpThreshold = 0 -- 0??
object.nWaveFormThreshold = 70 -- was 100
object.nWaveFormRetreatThreshold = 50
object.nForcedEvolutionThreshold = 60

-- Other variables
object.nOldRetreatFactor = 0.9--Decrease the value of the normal retreat behavior
object.nMaxLevelDifference = 4--Ensure hero will not be too carefull
object.nEnemyBaseThreat = 6--Base threat. Level differences and distance alter the actual threat level.

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
		if core.itemManaBattery and core.itemSteamboots and core.itemBloodChalice and core.itemAlchBones then
			return
		end

		local inventory = core.unitSelf:GetInventory(false)
		for slot = 1, 6 do
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

local bTrackingCarp=false
local uCarpTarget

function object:onthinkOverride(tGameVariables)
	self:onthinkOld(tGameVariables)
	jungleLib.assess(self)
	local bDebugGadgets=false
	local unitSelf=core.unitSelf
	
	if (bDebugGadgets or bTrackingCarp) then
		local tUnits = HoN.GetUnitsInRadius(unitSelf:GetPosition(), 2000, core.UNIT_MASK_ALIVE + core.UNIT_MASK_GADGET)
		if tUnits then
			for _, unit in pairs(tUnits) do
			
				-- CARP
				--Carp speed is 600.
				--Carp gadget is "Gadget_Hydromancer_Ability2_Reveal", and it is at the position of the carp itself.
				if (bTrackingCarp and unit:GetTypeName()=="Gadget_Hydromancer_Ability2_Reveal") then--carp is alive
					if (uCarpTarget and uCarpTarget:GetPosition()) then
						--BotEcho("Time till carp hit: "..Vector3.Distance2DSq(unit:GetPosition(),uCarpTarget:GetPosition() )/(600*600))
					end
				end
				
				if (bTrackingCarp and unit:GetTypeName()=="Gadget_Hydromancer_Ability2_Reveal_Linger") then -- carp is now dead
					bTrackingCarp=false
				end
				
				if (bDebugGadgets) then
					core.DrawDebugArrow(unitSelf:GetPosition(), unit:GetPosition(), 'yellow') --flint q/r, fairy port, antipull, homecoming, kongor, chronos ult
					BotEcho(unit:GetTypeName())
				end
			end
		end
	end

	-- Toggle Steamboots for more Health/Mana
	local itemSteamboots = core.itemSteamboots
	if itemSteamboots and itemSteamboots:CanActivate() then
		local unitSelf = core.unitSelf
		local sKey = itemSteamboots:GetActiveModifierKey()
		local sCurrentBehavior = core.GetCurrentBehaviorName(self)
		if sKey == "str" then
			-- Toggle away from STR if health is high enough
			if unitSelf:GetHealthPercent() > .65 or sCurrentBehavior == "UseHealthRegen" or sCurrentBehavior == "UseManaRegen" then
				self:OrderItem(itemSteamboots.object, false)
			end
		elseif sKey == "agi" then
			-- Toggle away from AGI when we're not using Regen items or at well
			if sCurrentBehavior ~= "UseHealthRegen" and sCurrentBehavior ~= "UseManaRegen" and not unitSelf:HasState("State_RunesOfTheBlight") and not unitSelf:HasState("State_HealthPotion") then
				self:OrderItem(itemSteamboots.object, false)
			end
		elseif sKey == "int" then
			-- Toggle away from INT if health gets too low
			if unitSelf:GetHealthPercent() < .45 or sCurrentBehavior == "UseHealthRegen" or sCurrentBehavior == "UseManaRegen" then
				self:OrderItem(itemSteamboots.object, false)
			end
		end
	end
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
--          Weed Field Logic          --
----------------------------------------

-- A fixed list seems to be better then to check on each cycle if its  exist
-- so we create it here
local tRelativeMovements = {}
local function createRelativeMovementTable(key)
	--BotEcho('Created a relative movement table for: '..key)
	tRelativeMovements[key] = {
		vLastPos = Vector3.Create(),
		vRelMov = Vector3.Create(),
		timestamp = 0
	}
--	BotEcho('Created a relative movement table for: '..tRelativeMovements[key].timestamp)
end

createRelativeMovementTable("MyrmField") -- for landing Weed Field

-- tracks movement for targets based on a list, so its reusable
-- key is the identifier for different uses (fe. RaMeteor for his path of destruction)
-- vTargetPos should be passed the targets position of the moment
-- to use this for prediction add the vector to a units position and multiply it
-- the function checks for 100ms cycles so one second should be multiplied by 20
local function relativeMovement(sKey, vTargetPos)
	local debugEchoes = false
	
	local gameTime = HoN.GetGameTime()
	local key = sKey
	local vLastPos = tRelativeMovements[key].vLastPos
	local nTS = tRelativeMovements[key].timestamp
	local timeDiff = gameTime - nTS 
	
	if debugEchoes then
		BotEcho('Updating relative movement for key: '..key)
		BotEcho('Relative Movement position: '..vTargetPos.x..' | '..vTargetPos.y..' at timestamp: '..nTS)
		BotEcho('Relative lastPosition is this: '..vLastPos.x)
	end
	
	if timeDiff >= 90 and timeDiff <= 140 then -- 100 should be enough (every second cycle)
		local relativeMov = vTargetPos-vLastPos
		
		if vTargetPos.LengthSq > vLastPos.LengthSq
		then relativeMov =  relativeMov*-1 end
		
		tRelativeMovements[key].vRelMov = relativeMov
		tRelativeMovements[key].vLastPos = vTargetPos
		tRelativeMovements[key].timestamp = gameTime
		
		
		if debugEchoes then
			BotEcho('Relative movement -- x: '..relativeMov.x..' y: '..relativeMov.y)
			BotEcho('^r---------------Return new-'..tRelativeMovements[key].vRelMov.x)
		end
		
		return relativeMov
	elseif timeDiff >= 150 then
		tRelativeMovements[key].vRelMov =  Vector3.Create(0,0)
		tRelativeMovements[key].vLastPos = vTargetPos
		tRelativeMovements[key].timestamp = gameTime
	end
	
	if debugEchoes then BotEcho('^g---------------Return old-'..tRelativeMovements[key].vRelMov.x) end
	return tRelativeMovements[key].vRelMov
end

---------------------------------------
--          Harass Behavior          --
---------------------------------------

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
	
	local nWeedFieldDelay = 1100 -- nCastTime = 1000 --can we extract this from ability/affector? casttime="500" and castactiontime="100" and impactdelay="1000"
	local vecRelativeMov = relativeMovement("MyrmField", vecTargetPosition) * (nWeedFieldDelay / 100) --updating every 100ms

	local nLastHarassUtility = behaviorLib.lastHarassUtil
	local bActionTaken = false
	
	-- Blood Chalice
	if core.itemBloodChalice and core.itemBloodChalice:CanActivate() and unitTarget:GetHealthPercent() <= .15 then
		botBrain:OrderItem(core.itemBloodChalice.object or core.itemBloodChalice, false)
	end
	
	--Weed Field
	--Currently trying to use Stolen's Ra prediction code.  Consider reworking and track all old hero positions?
	if not bActionTaken then
		local bDebugEchoes = true
		local abilWeedField = skills.abilWeedField
		if abilWeedField:CanActivate() and nLastHarassUtility > object.nWeedFieldThreshold then
			local nRange = abilWeedField:GetRange()
			if Vector3.Distance2DSq(vecMyPosition, vecTargetPredictPosition) < nRange * nRange then
				local nCarpMovespeedSq = 600 * 600
				local vecTargetPredictPosition = vecTargetPosition + vecRelativeMov
				if not bTrackingCarp then
					bActionTaken = core.OrderAbilityPosition(botBrain, skills.abilWeedField, vecTargetPredictPosition)
					if bDebugEchoes then BotEcho("Casting weed field!") end
				-- If carp homing on target, wait till it gets close?
				elseif ((nWeedFieldDelay * nWeedFieldDelay) / (1000 * 1000)) < (Vector3.Distance2DSq(uCarpTarget:GetPosition(), vecTargetPredictPosition) / nCarpMovespeedSq) then --perfect time to cast weed field!
					bActionTaken = core.OrderAbilityPosition(botBrain, skills.abilWeedField, vecTargetPredictPosition)
				end
			end
		end
		
		if bDebugEchoes then
			local nRange = abilWeedField:GetRange()
			core.DrawXPosition(vecTargetPosition + vecRelativeMov, 'red', 100) --vecTargetPredictPosition
			core.DrawDebugArrow(vecTargetPosition, vecTargetPosition + vecRelativeMov, 'red') --predicted target movement path
			core.DrawDebugArrow(vecMyPosition, vecMyPosition + (Vector3.Normalize((vecTargetPosition + vecRelativeMov) - vecMyPosition)) * nRange, 'green') --weed field range aimed at predicted position
		end
	end

	--Magic Carp
	if not bActionTaken then
		local abilMagicCarp = skills.abilMagicCarp
		if abilMagicCarp:CanActivate() and bCanSeeTarget and nLastHarassUtility > object.nMagicCarpThreshold then
			local nRange = abilMagicCarp:GetRange()
			if nTargetDistanceSq < (nRange * nRange) then
				bActionTaken = core.OrderAbilityEntity(botBrain, skills.abilMagicCarp, unitTarget)
				if bActionTaken then
					uCarpTarget = unitTarget
					bTrackingCarp = true
				end
			end
		end
	end
	
	--Wave Form
	if not bActionTaken then
		local bDebugEchoes = true
		local abilWaveForm = skills.abilWaveForm
		if abilWaveForm:CanActivate() and nLastHarassUtility > object.nWaveFormThreshold then
			local nRange = abilWaveForm:GetRange()
			local nWaveOvershoot = 128 --try to get this many units past target to guarantee slow and position nicely to ult or block
			local vecWaveFormTarget = vecTargetPosition + nWaveOvershoot * Vector3.Normalize(vecTargetPosition - vecMyPosition)
			if Vector3.Distance2DSq(vecMyPosition, vecWaveFormTarget) < (nRange * nRange) then
				bActionTaken = core.OrderAbilityPosition(botBrain, skills.abilWaveForm, vecWaveFormTarget)
			else
				bActionTaken = core.OrderAbilityPosition(botBrain, skills.abilWaveForm, vecTargetPosition)
			end
		end
	
		if bDebugEchoes then
			local nRange = abilWaveForm:GetRange()
			local nWaveOvershoot = 128
			local vecWaveFormTarget = vecTargetPosition + nWaveOvershoot * Vector3.Normalize(vecTargetPosition - vecMyPosition)
			if Vector3.Distance2DSq(vecMyPosition, vecWaveFormTarget) < (nRange * nRange) then
				core.DrawXPosition(vecWaveFormTarget, 'blue', 100)
			else 
				core.DrawXPosition(vecMyPosition + Vector3.Normalize(vecTargetPosition - vecMyPosition) * nRange, 'blue', 100)
			end
		end
	end
	
	--ForcedEvolution
	--Need to check that target is not magic immune or our melee attack will not be effective?
	if not bActionTaken and bCanSeeTarget then
		local abilForcedEvolution = skills.abilForcedEvolution
		if abilForcedEvolution:CanActivate() and nLastHarassUtility > object.nForcedEvolutionThreshold and nTargetDistanceSq < (200 * 200) then
			bActionTaken = core.OrderAbility(botBrain, skills.abilForcedEvolution)
		end
	end
	
	if not bActionTaken then
		bActionTaken = object.harassExecuteOld(botBrain)
	end

	return bActionTaken
end

object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

-----------------------------------------------
--          UseHealthRegen Override          --
-----------------------------------------------

-------- Global Constants & Variables --------
behaviorLib.nBatterySupplyHealthUtility = 0

behaviorLib.bUseBatterySupplyForHealth = true

-------- Helper Functions --------
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

	local unitSelf = core.unitSelf
	local nHealthMissing = unitSelf:GetMaxHealth() - unitSelf:GetHealth()
	StopProfile()

	StartProfile("Mana Battery/Power Supply")
	if behaviorLib.bUseBatterySupplyForHealth then
		local itemBatterySupply = core.itemManaBattery or core.itemPowerSupply
		if itemBatterySupply and itemBatterySupply:CanActivate() then
			local nCharges = itemBatterySupply:GetCharges()
			if nCharges > 0 then
				nBatterySupplyUtility = BatterySupplyHealthUtilFn(nHealthMissing, nCharges)
			end
		end
	end
	StopProfile()
	
	local nOldUtility = object.useHealthRegenUtilityOld(botBrain)

	StartProfile("End")
	nUtility = max(nBatterySupplyUtility, nOldUtility)
	nUtility = Clamp(nUtility, 0, 100)

	behaviorLib.nBatterySupplyHealthUtility = nBatterySupplyUtility

	return nUtility
end

local function UseHealthRegenExecuteOverride(botBrain)
	local bDebugLines = false
	local bActionTaken = false
	local unitSelf = core.unitSelf
	local vecSelfPos = unitSelf:GetPosition()
	local tInventory = unitSelf:GetInventory()
	local nMaxUtility = max(behaviorLib.nBatterySupplyHealthUtility, behaviorLib.nBlightsUtility, behaviorLib.nHealthPotUtility)

	-- Wait for Steamboots toggling
	if not bActionTaken then
		local itemSteamboots = core.itemSteamboots
		if itemSteamboots and itemSteamboots:GetActiveModifierKey() ~= "agi" then
			-- Stall the function
			return true
		end
	end

	-- Use Mana Battery/Power Supply to heal
	if not bActionTaken and behaviorLib.nBatterySupplyHealthUtility == nMaxUtility then
		local itemBatterySupply = core.itemManaBattery or core.itemPowerSupply
		if itemBatterySupply and itemBatterySupply:CanActivate() and itemBatterySupply:GetCharges() > 0 then
			bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemBatterySupply)
		end
	end

	if not bActionTaken then
		return object.useHealthRegenExecuteOld(botBrain)
	end

	return bActionTaken
end

object.useHealthRegenUtilityOld = behaviorLib.UseHealthRegenBehavior["Utility"]
behaviorLib.UseHealthRegenBehavior["Utility"] = UseHealthRegenUtilityOverride
object.useHealthRegenExecuteOld = behaviorLib.UseHealthRegenBehavior["Execute"]
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
		local itemBatterySupply = core.itemManaBattery or core.itemPowerSupply
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
	
	-- Wait for Steamboots toggling
	if not bActionTaken then
		local itemSteamboots = core.itemSteamboots
		if itemSteamboots and itemSteamboots:GetActiveModifierKey() ~= "agi" then
			-- Stall the function
			return true
		end
	end

	-- Use Mana Battery/Power Supply to regen mana
	if not bActionTaken and behaviorLib.nBatterySupplyManaUtility == nMaxUtility then
		local itemBatterySupply = core.itemManaBattery or core.itemPowerSupply
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

-----------------------------------------------
--          Predictive Last Hitting          --
--                                           --
--          Developed by paradox870          --
-----------------------------------------------

local function GetAttackDamageOnCreep(botBrain, unitCreepTarget)

	if not unitCreepTarget or not core.CanSeeUnit(botBrain, unitCreepTarget) then
		return nil
	end

	local unitSelf = core.unitSelf

	--Get positioning information
	local vecSelfPos = unitSelf:GetPosition()
	local vecTargetPos = unitCreepTarget:GetPosition() 
	local nExpectedCreepDamage = 0
	local nExpectedTowerDamage = 0

	--Get projectile info
	if (unitSelf:GetAttackType() ~= "melee") then --needed for ult.
	local nProjectileSpeed = unitSelf:GetAttackProjectileSpeed()
		local nProjectileTravelTime = Vector3.Distance2D(vecSelfPos, vecTargetPos) / nProjectileSpeed
		if bDebugEchos then BotEcho ("Projectile travel time: " .. nProjectileTravelTime ) end 
		
		local tNearbyAttackingCreeps = nil
		local tNearbyAttackingTowers = nil

		--Get the creeps and towers on the opposite team
		-- of our target
		if unitCreepTarget:GetTeam() == unitSelf:GetTeam() then
			tNearbyAttackingCreeps = core.localUnits['EnemyCreeps']
			tNearbyAttackingTowers = core.localUnits['EnemyTowers']
		else
			tNearbyAttackingCreeps = core.localUnits['AllyCreeps']
			tNearbyAttackingTowers = core.localUnits['AllyTowers']
		end

		--Determine the damage expected on the creep by other creeps
		for i, unitCreep in pairs(tNearbyAttackingCreeps) do
			if unitCreep:GetAttackTarget() == unitCreepTarget then
				local nCreepAttacks = 1 + math.floor(unitCreep:GetAttackSpeed() * nProjectileTravelTime)
				nExpectedCreepDamage = nExpectedCreepDamage + unitCreep:GetFinalAttackDamageMin() * nCreepAttacks
			end
		end

		--Determine the damage expected on the creep by other towers
		for i, unitTower in pairs(tNearbyAttackingTowers) do
			if unitTower:GetAttackTarget() == unitCreepTarget then
				local nTowerAttacks = 1 + math.floor(unitTower:GetAttackSpeed() * nProjectileTravelTime)
				nExpectedTowerDamage = nExpectedTowerDamage + unitTower:GetFinalAttackDamageMin() * nTowerAttacks
			end
		end
	end

	return nExpectedCreepDamage + nExpectedTowerDamage
end

function GetCreepAttackTargetOverride(botBrain, unitEnemyCreep, unitAllyCreep) --called pretty much constantly
	local bDebugEchos = false

	--Get info about self
	local unitSelf = core.unitSelf
	local nDamageMin = unitSelf:GetFinalAttackDamageMin()

	if unitEnemyCreep and core.CanSeeUnit(botBrain, unitEnemyCreep) then
		local nTargetHealth = unitEnemyCreep:GetHealth()
		--Only attack if, by the time our attack reaches the target
		-- the damage done by other sources brings the target's health
		-- below our minimum damage
		if nDamageMin >= (nTargetHealth - GetAttackDamageOnCreep(botBrain, unitEnemyCreep)) then
			if bDebugEchos then BotEcho("Returning an enemy") end
			return unitEnemyCreep
		end
	end

	if unitAllyCreep then
		local nTargetHealth = unitAllyCreep:GetHealth()

		--Only attack if, by the time our attack reaches the target
		-- the damage done by other sources brings the target's health
		-- below our minimum damage
		if nDamageMin >= (nTargetHealth - GetAttackDamageOnCreep(botBrain, unitAllyCreep)) then
			local bActuallyDeny = true
			
			--[Difficulty: Easy] Don't deny
			if core.nDifficulty == core.nEASY_DIFFICULTY then
				bActuallyDeny = false
			end
			
			-- [Tutorial] Hellbourne *will* deny creeps after shit gets real
			if core.bIsTutorial and core.bTutorialBehaviorReset == true and core.myTeam == HoN.GetHellbourneTeam() then
				bActuallyDeny = true
			end
			
			if bActuallyDeny then
				if bDebugEchos then BotEcho("Returning an ally") end
				return unitAllyCreep
			end
		end
	end

	return nil
end

object.getCreepAttackTargetOld = behaviorLib.GetCreepAttackTarget
behaviorLib.GetCreepAttackTarget = GetCreepAttackTargetOverride

function AttackCreepsExecuteOverride(botBrain)
	local unitSelf = core.unitSelf
	local unitCreepTarget = core.unitCreepTarget

	if (unitSelf:GetAttackType() ~= "melee") and unitCreepTarget and core.CanSeeUnit(botBrain, unitCreepTarget) then
		--Get info about the target we are about to attack
		local vecSelfPos = unitSelf:GetPosition()
		local vecTargetPos = unitCreepTarget:GetPosition()
		local nDistSq = Vector3.Distance2DSq(vecSelfPos, vecTargetPos)
		local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, currentTarget, true)
	
		--Only attack if, by the time our attack reaches the target
		-- the damage done by other sources brings the target's health
		-- below our minimum damage, and we are in range and can attack right now
		if nDistSq < nAttackRangeSq and unitSelf:IsAttackReady() then
			return core.OrderAttackClamp(botBrain, unitSelf, unitCreepTarget)

		--Otherwise get within 70% of attack range if not already
		-- This will decrease travel time for the projectile
		elseif (nDistSq > nAttackRangeSq * 0.5) then 
			local vecDesiredPos = core.AdjustMovementForTowerLogic(vecTargetPos)
			return core.OrderMoveToPosClamp(botBrain, unitSelf, vecDesiredPos, false)

		--If within a good range, just hold tight
		else
			return core.OrderHoldClamp(botBrain, unitSelf, false)
		end
	else
		return object.AttackCreepsExecuteOld
	end
end

object.AttackCreepsExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.AttackCreepsBehavior["Execute"] = AttackCreepsExecuteOverride

--------------------------------------------------
--          RetreatFromThreat Override          --
--------------------------------------------------

--This function returns the position of the enemy hero.
--If he is not shown on map it returns the last visible spot
--as long as it is not older than 10s
local function funcGetEnemyPosition(unitEnemy)
	if unitEnemy == nil  then return Vector3.Create(20000, 20000) end 
	local tEnemyPosition = core.unitSelf.tEnemyPosition
	local tEnemyPositionTimestamp = core.unitSelf.tEnemyPositionTimestamp
	if tEnemyPosition == nil then
		-- initialize new table
		core.unitSelf.tEnemyPosition = {}
		core.unitSelf.tEnemyPositionTimestamp = {}
		tEnemyPosition = core.unitSelf.tEnemyPosition
		tEnemyPositionTimestamp = core.unitSelf.tEnemyPositionTimestamp
		local tEnemyTeam = HoN.GetHeroes(core.enemyTeam)
		--vector beyond map
		for x, hero in pairs(tEnemyTeam) do
			tEnemyPosition[hero:GetUniqueID()] = Vector3.Create(20000, 20000)
			tEnemyPositionTimestamp[hero:GetUniqueID()] = HoN.GetGameTime()
		end
		
	end
	local vecPosition = unitEnemy:GetPosition()
	--enemy visible?
	if vecPosition then
		--update table
		tEnemyPosition[unitEnemy:GetUniqueID()] = unitEnemy:GetPosition()
		tEnemyPositionTimestamp[unitEnemy:GetUniqueID()] = HoN.GetGameTime()
	end
	--return position, 10s memory
	if tEnemyPositionTimestamp[unitEnemy:GetUniqueID()] <= HoN.GetGameTime() + 10000 then
		return tEnemyPosition[unitEnemy:GetUniqueID()]
	else
		return Vector3.Create(20000, 20000)
	end
end

local function funcGetThreatOfEnemy(unitEnemy)
	if unitEnemy == nil or not unitEnemy:IsAlive() then return 0 end
	local unitSelf = core.unitSelf
	local nDistanceSq = Vector3.Distance2DSq(unitSelf:GetPosition(), funcGetEnemyPosition (unitEnemy))
	if nDistanceSq > 4000000 then return 0 end			
	local nMyLevel = unitSelf:GetLevel()
	local nEnemyLevel = unitEnemy:GetLevel()
	--Level differences increase / decrease actual nThreat
	local nThreat = object.nEnemyBaseThreat + Clamp(nEnemyLevel - nMyLevel, 0, object.nMaxLevelDifference)
	--Magic-Formel: Threat to Range, T(700²) = 2, T(1100²) = 1.5, T(2000²)= 0.75
	nThreat = Clamp(3*(112810000-nDistanceSq) / (4*(19*nDistanceSq+32810000)),0.75,2) * nThreat
	return nThreat
end

local function positionOffset(pos, angle, distance) --this is used by minions to form a ring around people.
	tmp = Vector3.Create(cos(angle)*distance,sin(angle)*distance)
	return tmp+pos
end

local function waveFormToBase(botBrain)
	local vecWellPos = core.allyWell and core.allyWell:GetPosition() or behaviorLib.PositionSelfBackUp()
	local vecMyPos=core.unitSelf:GetPosition()
	if (Vector3.Distance2DSq(vecMyPos, vecWellPos)>600*600)then
		if (skills.abilWaveForm:CanActivate()) then --waveform
			return core.OrderAbilityPosition(botBrain, skills.abilWaveForm, positionOffset(core.unitSelf:GetPosition(), atan2(vecWellPos.y-vecMyPos.y,vecWellPos.x-vecMyPos.x), skills.abilWaveForm:GetRange()))
		end
	end
	return false
end

local function CustomRetreatFromThreatUtilityFnOverride(botBrain)
	local bDebugEchos = false
	local nUtilityOld = behaviorLib.lastRetreatUtil
	local nUtility = object.RetreatFromThreatUtilityOld(botBrain) * object.nOldRetreatFactor
	
	--decay with a maximum of 4 utilitypoints per frame to ensure a longer retreat time
	if nUtilityOld > nUtility +4 then
		nUtility = nUtilityOld -4
	end
	
	--bonus of allies decrease fear
	local allies = core.localUnits["AllyHeroes"]
	local nAllies = core.NumberElements(allies) + 1
	--get enemy heroes
	local tEnemyTeam = HoN.GetHeroes(core.enemyTeam)
	--calculate the threat-value and increase utility value
	for id, enemy in pairs(tEnemyTeam) do
		nUtility = nUtility + funcGetThreatOfEnemy(enemy) / nAllies
	end
	return Clamp(nUtility, 0, 100)
end

local function funcRetreatFromThreatExecuteOverride(botBrain)
	local unitSelf = core.unitSelf
	local unitTarget = behaviorLib.heroTarget
	local vecPos = behaviorLib.PositionSelfBackUp()
	local nlastRetreatUtil = behaviorLib.lastRetreatUtil
	local nNow = HoN.GetGameTime()
	
	--Counting the enemies 	
	local tEnemies = core.localUnits["EnemyHeroes"]
	local nCount = 0
	local bCanSeeUnit = unitTarget and core.CanSeeUnit(botBrain, unitTarget) 
	for id, unitEnemy in pairs(tEnemies) do
		if core.CanSeeUnit(botBrain, unitEnemy) then
			nCount = nCount + 1
		end
	end
	if (nCount > 1 or unitSelf:GetHealthPercent() < .4) and bCanSeeUnit then -- More enemies or low on life
		local vecMyPosition = unitSelf:GetPosition()
		local vecTargetPosition = unitTarget:GetPosition()
		local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
		local bTargetVuln = unitTarget:IsStunned() or unitTarget:IsImmobilized()
	
		--WeedField
		local abilWeedField = skills.abilWeedField
		if abilWeedField:CanActivate() then
			local nRange = abilWeedField:GetRange()
			if nTargetDistanceSq < (nRange * nRange) then
				core.OrderAbilityPosition(botBrain, abilWeedField, vecTargetPosition)
				return
			end
		end
		
		--Activate ult if HP < ??% and retreating
		
		if behaviorLib.lastRetreatUtil> object.nWaveFormRetreatThreshold and waveFormToBase(botBrain) then return true end
		
	end
	return core.OrderMoveToPosClamp(botBrain, core.unitSelf, vecPos, false)
end

object.RetreatFromThreatUtilityOld =  behaviorLib.RetreatFromThreatUtility
behaviorLib.RetreatFromThreatBehavior["Utility"] = CustomRetreatFromThreatUtilityFnOverride
object.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatExecute
behaviorLib.RetreatFromThreatBehavior["Execute"] = funcRetreatFromThreatExecuteOverride

--------------------------------------------------
--             HealAtWell Override              --
--------------------------------------------------

--return to well more often. --2000 gold adds 8 to return utility, 0% mana also adds 8.
--When returning to well, use skills and items.
local function HealAtWellUtilityOverride(botBrain)
	return object.HealAtWellUtilityOld(botBrain)*1.75+(botBrain:GetGold()*8/2000)+ 8-(core.unitSelf:GetManaPercent()*8) --couragously flee back to base.
end

local function HealAtWellExecuteOverride(botBrain)
	return waveFormToBase(botBrain) or object.HealAtWellExecuteOld(botBrain)
end

object.HealAtWellUtilityOld = behaviorLib.HealAtWellBehavior["Utility"]
behaviorLib.HealAtWellBehavior["Utility"] = HealAtWellUtilityOverride
object.HealAtWellExecuteOld = behaviorLib.HealAtWellBehavior["Execute"]
behaviorLib.HealAtWellBehavior["Execute"] = HealAtWellExecuteOverride

----------------------------------------
--          Jungle Variables          --
----------------------------------------

jungleLib.jungleSpots[6].difficulty = 10000
jungleLib.jungleSpots[12].difficulty = 10000

--from here on, units we don't want for alch bones is negative a bit
--Units we want to kill:
jungleLib.creepDifficulty.Neutral_Minotaur = 1000
jungleLib.creepDifficulty.Neutral_Catman_leader = 1000
jungleLib.creepDifficulty.Neutral_VagabondLeader = 1000
jungleLib.creepDifficulty.Neutral_Vulture = 1000

--Units that make the hard camp bad to go back to:
jungleLib.creepDifficulty.Neutral_Goat = -100
jungleLib.creepDifficulty.Neutral_Catman = -100
jungleLib.creepDifficulty.Neutral_VagabondAssassin = -100
jungleLib.creepDifficulty.Neutral_HunterWarrior = -100
jungleLib.creepDifficulty.Neutral_SkeletonBoss = -100
jungleLib.creepDifficulty.Neutral_WolfCommander = -100
jungleLib.creepDifficulty.Neutral_Screacher = -100
jungleLib.creepDifficulty.Neutral_Skeleton = -100
jungleLib.creepDifficulty.Neutral_SkeletonBoss = -100

----------------------------------------------------
--                Alchemists bones                --
----------------------------------------------------

--When near a camp, check it to use alchemists bones on it
local vecNearestHardCamp
local nNearestCamp
local function AlchemistsBonesUtility(botBrain)
	local unitSelf = core.unitSelf
	if (not core.itemAlchBones or core.itemAlchBones:GetCharges()==0)then return 0 end
	vecNearestHardCamp,nNearestCamp=jungleLib.getNearestCampPos(unitSelf:GetPosition(), 90, 9999)
	if (not vecNearestHardCamp) then --bruteforce mode. We killed all the good camps.
		vecNearestHardCamp,nNearestCamp=jungleLib.getNearestCampPos(unitSelf:GetPosition(), -120, 9999)
	end
	if (vecNearestHardCamp) then
		core.DrawDebugArrow(unitSelf:GetPosition(), vecNearestHardCamp, 'yellow')
		return 23
	else
		return 0
	end
end

local function AlchemistsBonesExecute(botBrain)
	local unitSelf = core.unitSelf
	local vecMyPos=core.unitSelf:GetPosition()
	local vecTarget=jungleLib.jungleSpots[nNearestCamp].outsidePos
	
	--walk to target camp
	if ( Vector3.Distance2DSq(vecMyPos, vecTarget)>100*100 ) then
		return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, vecTarget, false)
	else--we are finally at a good camp!
		local tUnits = HoN.GetUnitsInRadius(vecMyPos, 800, core.UNIT_MASK_ALIVE + core.UNIT_MASK_UNIT)
		if tUnits then
			-- Find the strongest unit in the camp
			local nHighestHealth = 0
			local unitStrongest = nil
			for _, unitTarget in pairs(tUnits) do
				if unitTarget:GetHealth() > nHighestHealth and unitTarget:IsAlive() then
					unitStrongest = unitTarget
					nHighestHealth = unitTarget:GetMaxHealth()
				end
			end
			if unitStrongest and unitStrongest:GetPosition() then
				return core.OrderItemEntityClamp(botBrain, unitSelf, core.itemAlchBones, unitStrongest, false)
			else
				return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, vecTarget)
			end
		end
	end
	return false
end

behaviorLib.AlchemistsBonesBehavior = {}
behaviorLib.AlchemistsBonesBehavior["Utility"] = AlchemistsBonesUtility
behaviorLib.AlchemistsBonesBehavior["Execute"] = AlchemistsBonesExecute
behaviorLib.AlchemistsBonesBehavior["Name"] = "UseAlchemistsBones"
tinsert(behaviorLib.tBehaviors, behaviorLib.AlchemistsBonesBehavior)

--------------------------------------------
--          PushExecute Override          --
--------------------------------------------

-- Filters a group to be within a given range. Modified from St0l3n_ID's Chronos bot
local function filterGroupRange(tGroup, vecCenter, nRange)
	if tGroup and vecCenter and nRange then
		local tResult = {}
		for _, unitTarget in pairs(tGroup) do
			if Vector3.Distance2DSq(unitTarget:GetPosition(), vecCenter) <= (nRange * nRange) then
				tinsert(tResult, unitTarget)
			end
		end	

		if #tResult > 0 then
			return tResult
		end
	end

	return nil
end

-- Find the angle in degrees between two targets. Modified from St0l3n_ID's AngToTarget code
local function getAngToTarget(vecSelf, vecTarget)
	local nDeltaY = vecTarget.y - vecSelf.y
	local nDeltaX = vecTarget.x - vecSelf.x

	return floor( atan2(nDeltaY, nDeltaX) * 57.2957795131) -- That number is 180 / pi **ERROR ON LOAD: ')' expected near '='
end

local function getBestWeedFieldCastDirection(tLocalUnits, nMinimumCount)
	if nMinimumCount == nil then
		nMinimumCount = 1
	end
	
	if tLocalUnits and core.NumberElements(tLocalUnits) >= nMinimumCount then
		local unitSelf = core.unitSelf
		local vecMyPosition = unitSelf:GetPosition()
		local tTargetsInRange = filterGroupRange(tLocalTargets, vecMyPosition, 1000)
		if tTargetsInRange and #tTargetsInRange >= nMinimumCount then
			local tAngleOfTargetsInRange = {}
			for _, unitTarget in pairs(tTargetsInRange) do
				local vecEnemyPosition = unitTarget:GetPosition()
				local vecDirection = Vector3.Normalize(vecEnemyPosition - vecMyPosition)
				vecDirection = core.RotateVec2DRad(vecDirection, pi / 2)

				local nHighAngle = getAngToTarget(vecMyPosition, vecEnemyPosition + vecDirection * 50)
				local nMidAngle = getAngToTarget(vecMyPosition, vecEnemyPosition)
				local nLowAngle = getAngToTarget(vecMyPosition, vecEnemyPosition - vecDirection * 50)

				tinsert(tAngleOfTargetsInRange, {nHighAngle, nMidAngle, nLowAngle})
			end
		
			local tBestGroup = {}
			local tCurrentGroup = {}
			for _, tStartAngles in pairs(tAngleOfTargetsInRange) do
				local nStartAngle = tStartAngles[2]
				if nStartAngle <= -90 then
					-- Avoid doing calculations near the break in numbers
					nStartAngle = nStartAngle + 360
				end

				for _, tAngles in pairs(tAngleOfTargetsInRange) do
					local nHighAngle = tAngles[1]
					local nMidAngle = tAngles[2]
					local nLowAngle = tAngles[3]
					if nStartAngle > 90 and nStartAngle <= 270 then
						if nHighAngle < 0 then
							nHighAngle = nHighAngle + 360
						end
						
						if nMidAngle < 0 then
							nMidAngle = nMidAngle + 360
						end
							
						if nLowAngle < 0 then
							nLowAngle = nLowAngle + 360
						end
					end


					if nHighAngle >= nStartAngle and nStartAngle >= nLowAngle then
						tinsert(tCurrentGroup, nMidAngle)
					end
				end

				if #tCurrentGroup > #tBestGroup then
					tBestGroup = tCurrentGroup
				end

				tCurrentGroup = {}
			end
		
			local nBestGroupSize = #tBestGroup
			
			if nBestGroupSize >= nMinimumCount then
				tsort(tBestGroup)

				local nAvgAngle = (tBestGroup[1] + tBestGroup[nBestGroupSize]) / 2 * 0.01745329251 -- That number is pi / 180

				return Vector3.Create(cos(nAvgAngle), sin(nAvgAngle)) * 500
			end
		end
	end
	
	return nil
end

local function AbilityPush(botBrain)
	local bSuccess = false
	local abilWeedField = skills.abilWeedField
	local unitSelf = core.unitSelf
	local nMinimumCreeps = 3

	-- Stop the bot from trying to farm creeps if the creeps approach the spot where the bot died
	if not unitSelf:IsAlive() then
		return bSuccess
	end

	if abilWeedField:CanActivate() and unitSelf:GetManaPercent() > .4 then
		local vecCastDirection = getBestWeedFieldCastDirection(core.localUnits["EnemyCreeps"], 3)
		if vecCastDirection then 
			bSuccess = core.OrderAbilityPosition(botBrain, abilWeedField, unitSelf:GetPosition() + vecCastDirection)
		end
	end

	return bSuccess
end

local function PushExecuteOverride(botBrain)
	if not AbilityPush(botBrain) then 
		return object.PushExecuteOld(botBrain)
	end
end

object.PushExecuteOld = behaviorLib.PushBehavior["Execute"]
behaviorLib.PushBehavior["Execute"] = PushExecuteOverride

local function TeamGroupBehaviorOverride(botBrain)
	if not AbilityPush(botBrain) then 
		return object.TeamGroupBehaviorOld(botBrain)
	end
end

object.TeamGroupBehaviorOld = behaviorLib.TeamGroupBehavior["Execute"]
behaviorLib.TeamGroupBehavior["Execute"] = TeamGroupBehaviorOverride

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
