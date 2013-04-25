-------------------------------------------------------------
-----------            LEGO BOT  	             ------------
----------- 	 Yay for Group Projects		    -------------
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
    {"2 Item_IronBuckler", "Item_HealthPotion"}
behaviorLib.LaneItems =
    {"Item_Lifetube", "Item_Marchers", "Item_EnhancedMarchers"}
behaviorLib.MidItems =
    {"Item_Shield2", "Item_BloodChalice", "Item_PortalKey"} --Shield2 is HotBL
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
		nUtil = nUtil + Object.nExecutionUp
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


-----------------------------
------Harass behaviour-------
-----------------------------

local function HarassHeroExecuteOverride(botBrain)

    local unitTarget = behaviorLib.heroTarget
    if unitTarget == nil then
        return object.harassExecuteOld(botBrain)  --Target is invalid, move on to the next behavior
    end

	local vecMyPosition = unitSelf:GetPosition()
	local nAttackRangeSq = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
	nAttackRangeSq = nAttackRangeSq * nAttackRangeSq
	local nMyExtraRange = core.GetExtraRange(unitSelf)

	local vecTargetPosition = unitTarget:GetPosition()
	local nTargetExtraRange = core.GetExtraRange(unitTarget)
	local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
	local bTargetRooted = unitTarget:IsStunned() or unitTarget:IsImmobilized() or unitTarget:GetMoveSpeed() < 200

	local nLastHarassUtility = behaviorLib.lastHarassUtil

	--Taunt
	if core.CanSeeUnit(botBrain, unitTarget) then
		local abilTaunt = skills.abilTaunt
		if abilTaunt:CanActivate() and nLastHarassUtility > botBrain.nTauntThreshold then
			local nRange = abilTaunt:GetRange()
		end
	end
end

function zeroUtility(botBrain)
	return 0
end
behaviorLib.PositionSelfBehavior["Utility"] = zeroUtility
behaviorLib.PreGameBehavior["Utility"] = zeroUtility
----------------------------------
--	jungle
--
--	Utility: 20 always.  This is effectively an "idle" behavior
--
--	Move to unoccupied camps
----------------------------------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Jungling BEHAVIOUR
function jungleUtility(botBrain)
	return 19
end
function jungleExecute(botBrain)
	unitSelf=core.unitSelf
	local vMyPos=unitSelf:GetPosition()
	local vTargetPos=jungleLib.getNearestCampPos(vMyPos,0,70)
	if (not vTargetPos) then
		if (core.myTeam==HoN.GetHellbourneTeam()) then
			return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, Vector3.Create(7600,12800))
		else
			return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, Vector3.Create(7800,5500))
		end
	end
	local dist=Vector3.Distance2DSq(vMyPos, vTargetPos)
	if (dist>600*600) then --go to next camp
		return core.OrderMoveToPosAndHoldClamp(botBrain, unitSelf, vTargetPos)
	else --kill camp
		local uUnits=HoN.GetUnitsInRadius(vMyPos, 600, 35) --35 is the lowest working number. I have no clue as to why this is, but it is. Deal with it.
		if (uUnits~=nil)then
			--Get all creeps nearby and put them into a single table.
			local nHighestHealth=0
			for key, unit in pairs(uUnits) do
				if (unit:GetHealth()>nHighestHealth)then
					highestUnit=unit
					nHighestHealth=unit:GetHealth()
				end
			end
			if (highestUnit and highestUnit:GetPosition()) then
				local dist=Vector3.Distance2DSq(vMyPos, highestUnit:GetPosition())
				BotEcho("Attacking "..highestUnit:GetTypeName().." "..dist.."")
				if (dist<16384*2) then
					return core.OrderAttackClamp(botBrain, unitSelf, highestUnit,false)
				--else
				--	BotEcho("Moving")
				--	return core.OrderMoveToUnitClamp(botBrain, unitSelf, highestUnit, false)
				end
			else
				BotEcho("Attack-Moving")
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
	
	jungleLib.assess(self)
	local unitSelf = core.unitSelf
	local targetPos=jungleLib.getNearestCampPos(unitSelf:GetPosition(),0,70)
	if targetPos then
		core.DrawDebugArrow(unitSelf:GetPosition(),targetPos, 'green')
	end
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride
