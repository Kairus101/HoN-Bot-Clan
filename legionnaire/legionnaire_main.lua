-------------------------------------------------------------
-----------            LEGO BOT                 -------------
----------- 	 Hurrah for Group Projects		-------------
-------------------------------------------------------------

local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

object.bRunLogic        = true
object.bRunBehaviors    = true
object.bUpdates         = true
object.bUseShop         = true

object.bRunCommands     = true
object.bMoveCommands    = true
object.bAttackCommands  = true
object.bAbilityCommands = true
object.bOtherCommands   = true

object.bReportBehavior = true
object.bDebugUtility = false
object.bDebugExecute = false

object.logger = {}
object.logger.bWriteLog = false
object.logger.bVerboseLog = false

object.core         = {}
object.eventsLib    = {}
object.metadata     = {}
object.behaviorLib  = {}
object.skills       = {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventsLib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorLib.lua"

runfile "bots/advancedShopping.lua"
local shopping = object.shoppingHandler
shopping.Setup(true, true, false, false, false, false)

runfile "bots/jungleLib.lua"
jungleLib=object.jungleLib

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
    = _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
    = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp

local sqrtTwo = math.sqrt(2)

BotEcho('loading legionnaire_main...')

--------------------------------
-----Constant Definitions-------
--------------------------------

object.heroName = 'Hero_Legionnaire'

behaviorLib.StartingItems =
    {"2 Item_IronBuckler", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems =
    {"Item_Lifetube", "Item_Marchers", "Item_Shield2", "Item_EnhancedMarchers"}
behaviorLib.MidItems =
    {"Item_EnhancedMarchers", "Item_BloodChalice", "Item_PortalKey"} --Shield2 is HotBL
behaviorLib.LateItems =
    {"Item_Excruciator", "Item_SolsBulwark", "Item_DaemonicBreastplate"} --Excruciator is Barbed Armor

	-- 0 is Taunt, 1 is Charge, 2 is Whirling Blade, 3 is Execution, 4 is Attributes
object.tSkills = {
    2, 1, 2, 0, 2,
    3, 2, 1, 1, 1,
    3, 0, 0, 0, 4,
    3, 4, 4, 4, 4,
    4, 4, 4, 4, 4
}

object.nTauntUp = 7
object.nChargeUp = 5
object.nExecutionUp = 13

object.nTauntUse = 13
object.nChargeUse = 12
object.nExecutionUse = 18
object.nPortalKeyUse = 20
object.nExcruciatorUse = 18


object.nTauntThreshold = 26
object.nChargeThreshold = 36
object.nExecutionThreshold = 38
object.nPortalKeyThreshold = 20

object.nLastTauntTime = 0

----------------------------------
------Bot Function Overrides------
----------------------------------

function object:SkillBuild()
    core.VerboseLog("SkillBuild()")

    local unitSelf = self.core.unitSelf
    if  skills.abilWhirlingBlade == nil then
        skills.abilTaunt = unitSelf:GetAbility(0)
        skills.abilCharge = unitSelf:GetAbility(1)
        skills.abilWhirlingBlade = unitSelf:GetAbility(2)
        skills.abilExecution = unitSelf:GetAbility(3)
        skills.abilAttributeBoost = unitSelf:GetAbility(4)
    end
    if unitSelf:GetAbilityPointsAvailable() <= 0 then
        return
    end


    local nLev = unitSelf:GetLevel()
    local nLevPts = unitSelf:GetAbilityPointsAvailable()
    for i = nLev, nLev+nLevPts do
        unitSelf:GetAbility( object.tSkills[i] ):LevelUp()
    end
	if (nLev==3) then
		jungleLib.currentMaxDifficulty=90
	elseif (nLev==5) then
		jungleLib.currentMaxDifficulty=100
	elseif (nLev==7) then
		jungleLib.currentMaxDifficulty=130
	elseif (nLev==10) then
		jungleLib.currentMaxDifficulty=150
	elseif (nLev>=12) then
		jungleLib.currentMaxDifficulty=260
	end
end

------------------------------------
------OncombatEvent Override--------
------------------------------------

function object:oncombateventOverride(EventData)
    self:oncombateventOld(EventData)

    local nAddBonus = 0

    if EventData.Type == "Ability" then
        if EventData.InflictorName == "Ability_Legionnaire1" then
            nAddBonus = nAddBonus + object.nTauntUse
        elseif EventData.InflictorName == "Ability_Legionnaire2" then
            nAddBonus = nAddBonus + object.nChargeUse
		elseif EventData.InflictorName == "Ability_Legionnaire4" then
			nAddBonus = nAddBonus + object.nExecutionUse
        end
    end

   if nAddBonus > 0 then
        core.DecayBonus(self)
        core.nHarassBonus = core.nHarassBonus + nAddBonus
    end

end
object.oncombateventOld = object.oncombatevent
object.oncombatevent    = object.oncombateventOverride

-----------------------------------------
------CustomHarassUtility Override-------
-----------------------------------------


local function CustomHarassUtilityFnOverride(hero)
    local nUtil = 0

    if skills.abilTaunt:CanActivate() then
        nUtil = nUtil + object.nTauntUp
    end

    if skills.abilCharge:CanActivate() then
        nUtil = nUtil + object.nChargeUp
    end

	if skills.abilExecution:CanActivate() then
		nUtil = nUtil + object.nExecutionUp
	end


    return nUtil
end
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride

-------------------------------
------FindItems Override-------
-------------------------------

local function funcFindItemsOverride(botBrain)
    local bUpdated = object.FindItemsOld(botBrain)

    if core.itemPortalKey ~= nil and not core.itemPortalKey:IsValid() then
        core.itemPortalKey = nil
    end

	if core.itemEnhancedMarchers ~= nil and not core.itemEnhancedMarchers:IsValid() then
		core.itemEnhancedMarchers = nil
	end

	if core.itemExcruciator ~= nil and not core.itemExcruciator:IsValid() then
		core.itemExcruciator = nil
	end

	if core.itemBloodChalice ~=nil and not core.itemBloodChalice:IsValid() then
		core.itemBloodChalice = nil
	end

	if bUpdated then
        if core.itemPortalKey and core.itemEnhancedMarchers and core.itemExcruciator and core.itemBloodChalice then
            return
        end


        local inventory = core.unitSelf:GetInventory(true)
        for slot = 1, 12, 1 do
            local curItem = inventory[slot]
            if curItem then
                if core.itemPortalKey == nil and curItem:GetName() == "Item_PortalKey" then
                    core.itemPortalKey = core.WrapInTable(curItem)
                elseif core.itemEnhancedMarchers == nil and curItem:GetName() == "Item_EnhancedMarchers" then
                    core.itemEnhancedMarchers = core.WrapInTable(curItem)
                elseif core.itemExcruciator == nil and curItem:GetName() == "Item_Excruciator" then
                    core.itemExcruciator = core.WrapInTable(curItem)
                elseif core.itemBloodChalice == nil and curItem:GetName() == "Item_BloodChalice" then
                    core.itemBloodChalice = core.WrapInTable(curItem)
                end
            end
        end
    end
end
object.FindItemsOld = core.FindItems
core.FindItems = funcFindItemsOverride

----------------------------------------
--          Portal Key Logic          --
----------------------------------------

-- Returns the best position to Portal Key - Taunt combo
-- Returns nil if there are no enemies or there is no group with enough targets in it
local function getBestPortalKeyTauntPosition(botBrain, vecMyPosition, nMinimumTargets)
	if nMinimumTargets == nil then
		nMinimumTargets = 1
	end
	
	local tEnemyHeroes = core.localUnits["EnemyHeroes"]
	if tEnemyHeroes and core.NumberElements(tEnemyHeroes) >= nMinimumTargets then
		local nTauntRadius = 300
		local tCurrentGroup = {}
		local nCurrentGroupCount = 0
		local tBestGroup = {}
		local nBestGroupCount = 0
		for _, unitTarget in pairs(tEnemyHeroes) do
			local vecTargetPosition = unitTarget:GetPosition()
			for _, unitOtherTarget in pairs(tEnemyHeroes) do
				if Vector3.Distance2DSq(unitOtherTarget:GetPosition(), vecTargetPosition) <= (nTauntRadius * nTauntRadius) then
					tinsert(tCurrentGroup, unitOtherTarget)
				end
			end

			nCurrentGroupCount = #tCurrentGroup
			if nCurrentGroupCount > nBestGroupCount then
				tBestGroup = tCurrentGroup
				nBestGroupCount = nCurrentGroupCount
			end
			
			tCurrentGroup = {}
		end
		
		if nBestGroupCount >= nMinimumTargets then
			return core.GetGroupCenter(tBestGroup)
		end
	end

	return nil
end

-----------------------------------
--          Taunt Logic          --
-----------------------------------

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

local function getTauntRadius()
	return 300
end

-----------------------------------
--          Decap Logic          --
-----------------------------------

local function getDecapThreshold()
	local nSkillLevel = skills.abilExecution:GetLevel()

	if nSkillLevel == 1 then
		return 300
	elseif nSkillLevel == 2 then
		return 450
	elseif nSkillLevel == 3 then
		return 600
	else
		return nil
	end
end

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
	local nLastHarassUtility = behaviorLib.lastHarassUtil

	local bActionTaken = false
	
	if unitSelf:HasState("State_Legionnaire_Ability2_Self") then
		-- We are currently charging the enemy
		return true
	end

	-- Portal Key
	if not bActionTaken then
		local itemPortalKey = core.itemPortalKey
		if itemPortalKey and itemPortalKey:CanActivate() and behaviorLib.lastHarassUtil > object.nPortalKeyThreshold then
			local vecBestTauntPosition = getBestPortalKeyTauntPosition(botBrain, vecMyPosition, 2)
			if vecBestTauntPosition then
				-- Port into two or more enemies
				bActionTaken = core.OrderItemPosition(botBrain, unitSelf, itemPortalKey, vecBestTauntPosition)
			else
				-- Port to a single enemy
				local nTauntRadius = getTauntRadius() - 25
				if nTargetDistanceSq > (nTauntRadius * nTauntRadius) then
					bActionTaken = core.OrderItemPosition(botBrain, unitSelf, itemPortalKey, vecTargetPosition)
				end
			end
		end
	end

	-- Taunt
	if not bActionTaken then
		local abilTaunt = skills.abilTaunt
		if abilTaunt:CanActivate() and nLastHarassUtility > botBrain.nTauntThreshold then
			local nRadius = getTauntRadius()
			local tTauntRangeEnemies = filterGroupRange(core.localUnits["EnemyHeroes"], vecMyPosition, nRadius)
			if tTauntRangeEnemies and #tTauntRangeEnemies > 1 then
				-- If there are two or more enemy heroes in range then taunt
				bActionTaken = core.OrderAbility(botBrain, abilTaunt)
			elseif nTargetDistanceSq <= (nRadius * nRadius) then
				-- Otherwise Taunt the target only if they are in range and not disabled
				local bDisabled = unitTarget:IsImmobilized() or unitTarget:IsStunned()
				if not bDisabled then
					bActionTaken = core.OrderAbility(botBrain, abilTaunt)
				end
			end
		end
		
		if bActionTaken then
		-- Record our last taunt time 
			object.nLastTauntTime = HoN.GetMatchTime()
		end
	end
	
	-- Barbed Armor
	if not bActionTaken then
		local itemExcruciator = core.itemExcruciator
		if itemExcruciator and itemExcruciator:CanActivate() and object.nLastTauntTime + 500 > HoN.GetMatchTime() then
			-- Use Barbed within .5 seconds of taunt
			bActionTaken = core.OrderItemClamp(botBrain, unitSelf, itemExcruciator)
		end
	end

	-- Charge
	if not bActionTaken then
		local abilCharge = skills.abilCharge
		if abilCharge:CanActivate() and nLastHarassUtility > botBrain.nChargeThreshold then
			local nRange = abilCharge:GetRange()
			if nTargetDistanceSq <= (nRange * nRange) then
				bActionTaken = core.OrderAbilityEntity(botBrain, abilCharge, unitTarget)
			end
		end
	end

	-- Decap
	if not bActionTaken then
		local abilExecution = skills.abilExecution
		if abilExecution:CanActivate() and nLastHarassUtility > botBrain.nExecutionThreshold then
			local nRange = abilExecution:GetRange()
			if nTargetDistanceSq <= (nRange * nRange) then
				local nInstantKillThreshold = getDecapThreshold()
				if unitTarget:GetHealth() <  nInstantKillThreshold then
					bActionTaken = core.OrderAbilityEntity(botBrain, abilExecution, unitTarget)
				end
			end
		end
	end

	if not bActionTaken then
        return object.harassExecuteOld(botBrain)
    end

    return bActionTaken
end

object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride



-------------------------------
-- 		Jungle Behavior		 --
-------------------------------
behaviorLib.nCreepAggroUtility=0
behaviorLib.nRecentDamageMul=0.20--0.35
function zeroUtility(botBrain)
	return 0
end
behaviorLib.PositionSelfBehavior["Utility"] = zeroUtility
--behaviorLib.PreGameBehavior["Utility"] = zeroUtility

----------------------------------
--	jungle
--
--	Utility: 21 always.  This is effectively an "idle" behavior
--
--	Move to unoccupied camps
--  Attack strongest till they are dead
----------------------------------

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Jungling BEHAVIOUR
function jungleUtility(botBrain)
	behaviorLib.nTeamGroupUtilityMul = 0.13+(core.unitSelf:GetLevel()*0.01)--level 9, start grouping.
	behaviorLib.pushingCap = 13+core.unitSelf:GetLevel()--level 9, start pushing.
	behaviorLib.nTeamDefendUtilityVal = 13+core.unitSelf:GetLevel()--level 9, start defending.
	return 21--19
end

jungleLib.currentMaxDifficulty=70

jungleLib.nStacking=0--0=nothing 1=waiting/attacking 2=running away
function jungleExecute(botBrain)
	unitSelf=core.unitSelf
		
	local vMyPos=unitSelf:GetPosition()
	local vTargetPos, camp=jungleLib.getNearestCampPos(vMyPos,0,jungleLib.currentMaxDifficulty)
	if (not vTargetPos) then
		if (core.myTeam==HoN.GetHellbourneTeam()) then
			return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, jungleLib.jungleSpots[8].outsidePos)
		else
			return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, jungleLib.jungleSpots[2].outsidePos)
		end
	end
	
	core.DrawDebugArrow(unitSelf:GetPosition(),vTargetPos, 'green')

	
	local dist=Vector3.Distance2DSq(vMyPos, vTargetPos)
	if (dist>600*600 or jungleLib.nStacking~=0) then --go to next camp
		--@@@@@@@@@@@@@@@@@@@@@@@@ATTEMPT STACK
		local mins, secs = jungleLib.getTime()
		--BotEcho("Stacking status: "..jungleLib.nStacking)
		if (jungleLib.nStacking~=0 or ((secs>40 or mins==0) and dist<800*800 and dist>400*400)) then --WE ARE STACKING far enough away
			if (secs<53 and (secs>40 or mins==0)) then
				jungleLib.nStacking=1
				BotEcho(camp)
                --return core.OrderHoldClamp(botBrain, unitSelf, false)
				return core.OrderMoveToPosAndHoldClamp(botBrain, core.unitSelf, jungleLib.jungleSpots[camp].outsidePos, false)
			elseif(jungleLib.nStacking==1 and unitSelf:IsAttackReady()) then--time to attack!
				if (secs>=57) then jungleLib.nStacking=0 end
				return core.OrderAttackPosition(botBrain, unitSelf, vTargetPos,false,false)--attackmove
			elseif(jungleLib.nStacking~=0 and dist<1500*1500 and secs>50) then--we hit the camp, run!
				jungleLib.nStacking=2
				local awayPos=jungleLib.jungleSpots[camp].pos+(jungleLib.jungleSpots[camp].outsidePos-jungleLib.jungleSpots[camp].pos)*5
				
				core.DrawXPosition(jungleLib.jungleSpots[camp].pos, 'red')
				core.DrawXPosition(jungleLib.jungleSpots[camp].outsidePos, 'red')
				core.DrawDebugArrow(jungleLib.jungleSpots[camp].pos,awayPos, 'green')
				
				return core.OrderMoveToPosClamp(botBrain, core.unitSelf, awayPos, false)
			else
				jungleLib.nStacking=0
				return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, vTargetPos)
			end
		else
			return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, vTargetPos)
		end
	else --kill camp
		local uUnits=HoN.GetUnitsInRadius(vMyPos, 600, 35) --35 is the lowest working number. I have no clue as to why this is, but it is. Deal with it.
		if (uUnits~=nil)then
			--Get all creeps nearby and put them into a single table.
			local nHighestHealth=0
			local highestUnit=nil
			for key, unit in pairs(uUnits) do
				if (unit:GetHealth()>nHighestHealth and unit:IsAlive())then
					highestUnit=unit
					nHighestHealth=unit:GetHealth()
				end
			end
			if (highestUnit and highestUnit:GetPosition()) then
				local dist=Vector3.Distance2DSq(vMyPos, highestUnit:GetPosition())
				if (dist<16384*2) then
					return core.OrderAttackClamp(botBrain, unitSelf, highestUnit,false)
				end
			else
				return core.OrderAttackPosition(botBrain, unitSelf, vTargetPos,false,false)--attackmove
			end
		else
			return core.OrderAttackPosition(botBrain, unitSelf, vTargetPos,false,false)--attackmove
		end
	end
	return true
end
behaviorLib.jungleBehavior = {}
behaviorLib.jungleBehavior["Utility"] = jungleUtility
behaviorLib.jungleBehavior["Execute"] = jungleExecute
behaviorLib.jungleBehavior["Name"] = "jungle"
tinsert(behaviorLib.tBehaviors, behaviorLib.jungleBehavior)

function object:onthinkOverride(tGameVariables) --This is run, even while dead. Every frame.
	self:onthinkOld(tGameVariables)--don't distrupt old think
	
	jungleLib.assess(self) --assess camps. Know which are empty etc.
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride

---------------------------------------
---			Personality				---
---------------------------------------

core.tKillChatKeys={
    "BUAHAHAHA!",
    "Off with their heads!",
    "I put the meaning into human blender.",
    "You spin me right round!",
    "Did I break your spirit?",
    "You spin my head right round, right round. When ya go down, when ya go down down."
}
core.tDeathChatKeys = {
    "Spinning out of control..",
    "I think I'm gonna throw up...",
    "Stop taunting me!",
    "Off with.....my head?"
}

BotEcho(object:GetName()..' finished loading legionnaire_main')
