
local _G = getfenv(0)
local object = _G.object

object.myName = object:GetName()

object.bRunLogic		 = true
object.bRunBehaviors	= true
object.bUpdates		 = true
object.bUseShop		 = true

object.bRunCommands	 = true 
object.bMoveCommands	 = true
object.bAttackCommands	 = true
object.bAbilityCommands = true
object.bOtherCommands	 = true

object.bReportBehavior = false
object.bDebugUtility = false

object.logger = {}
object.logger.bWriteLog = false
object.logger.bVerboseLog = false

object.core		 = {}
object.eventsLib	 = {}
object.metadata	 = {}
object.behaviorLib	 = {}
object.skills		 = {}

runfile "bots/core.lua"
runfile "bots/botbraincore.lua"
runfile "bots/eventsLib.lua"
runfile "bots/metadata.lua"
runfile "bots/behaviorLib.lua"
runfile "bots/bottle.lua"

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp


BotEcho(object:GetName()..' loading succubus_main...')


----------------------------------------------------------
--  			  bot constant definitions				--
----------------------------------------------------------

object.heroName = 'Hero_Succubis'


--   item buy order. internal names  
behaviorLib.StartingItems  = {"Item_MarkOfTheNovice", "Item_MarkOfTheNovice", "Item_RunesOfTheBlight", "Item_MarkOfTheNovice"}
behaviorLib.LaneItems  = {"Item_Bottle", "Item_EnhancedMarchers"}
behaviorLib.MidItems  = {"Item_PortalKey", "Item_Summon 3", "Item_Intelligence7"}
--behaviorLib.LateItems  = {}
--item_summon is puzzlebox Item_Intelligence7 is master staff



object.ultTime = 0



------------------------------
--	 skills			   --
------------------------------
-- skillbuild table, 0=smitten, 1=heartache, 2=mesme, 3=ult, 4=attri
object.tSkills = {
	1, 2, 1, 2, 1,
	3, 1, 2, 2, 0, 
	3, 0, 0, 0, 4,
	3, 4, 4, 4, 4,
	4, 4, 4, 4, 4,
}
function object:SkillBuild()
	core.VerboseLog("skillbuild()")

-- takes care at load/reload, <name_#> to be replaced by some convinient name.
	local unitSelf = self.core.unitSelf
	if  skills.smitten == nil then
		skills.smitten = unitSelf:GetAbility(0)
		skills.heartache = unitSelf:GetAbility(1)
		skills.mesme = unitSelf:GetAbility(2)
		skills.hold = unitSelf:GetAbility(3)
		skills.abilAttributeBoost = unitSelf:GetAbility(4)
	end
	if unitSelf:GetAbilityPointsAvailable() <= 0 then
		return
	end
	
   
	local nlev = unitSelf:GetLevel()
	local nlevpts = unitSelf:GetAbilityPointsAvailable()
	for i = nlev, nlev+nlevpts do
		unitSelf:GetAbility( object.tSkills[i] ):LevelUp()
	end
end

------------------------------------------------------
--			onthink override					  --
-- Called every bot tick, custom onthink code here  --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function object:onthinkOverride(tGameVariables)
	self:onthinkOld(tGameVariables)

	-- custom code here
end
object.onthinkOld = object.onthink
object.onthink 	= object.onthinkOverride

object.retreatCastThreshold = 55
function behaviorLib.RetreatFromThreatExecuteOverride(botBrain)
	local unitSelf = core.unitSelf
	local mypos = unitSelf:GetPosition()

	local lastRetreatUtil = behaviorLib.lastRetreatUtil

	local missingHP = unitSelf:GetMaxHealth() - unitSelf:GetHealth()

	local mesmeRange = skills.mesme:GetRange()
	local heartacheRange = skills.heartache:GetRange()
	local mesmeCanActivate = skills.mesme:CanActivate()
	local heartacheCanActivate = skills.heartache:CanActivate()
	local bActionTaken = false


	if lastRetreatUtil > object.retreatCastThreshold then
		for _,hero in pairs(core.localUnits["EnemyHeroes"]) do
			distanceSq = Vector3.Distance2DSq(mypos, hero:GetPosition())
			if heartacheCanActivate and distanceSq < heartacheRange*heartacheRange and missingHP > 300 and not hero:HasState("State_Succubis_Ability3") then
				bActionTaken = core.OrderAbilityEntity(botBrain, skills.heartache, hero)
				break
			elseif mesmeCanActivate and distanceSq < mesmeRange*mesmeRange then
				bActionTaken = core.OrderAbilityEntity(botBrain, skills.mesme, hero)
				break
			end
		end
	end
	if not bActionTaken then
		behaviorLib.RetreatFromThreatExecuteOld(botBrain)
	end
end
behaviorLib.RetreatFromThreatExecuteOld = behaviorLib.RetreatFromThreatBehavior["Execute"]
behaviorLib.RetreatFromThreatBehavior["Execute"] = behaviorLib.RetreatFromThreatExecuteOverride


------------------------------------------
--			oncombatevent override		--
------------------------------------------
object.mesmeUseBonus = 5
object.holdUseBonus = 35
object.heartacheUseBonus = 15
function object:oncombateventOverride(EventData)
	self:oncombateventOld(EventData)

	local addBonus = 0

	if EventData.Type == "Ability" then
		if EventData.InflictorName == "Ability_Succubis1" then

		elseif EventData.InflictorName == "Ability_Succubis2" then
			addBonus = addBonus + object.heartacheUseBonus
		elseif EventData.InflictorName == "Ability_Succubis3" then
			addBonus = addBonus + object.heartacheUseBonus
		elseif EventData.InflictorName == "Ability_Succubis4" then
			addBonus = addBonus + object.holdUseBonus
			object.ultTime = HoN.GetGameTime()
		end
	end


	if addBonus > 0 then
		core.DecayBonus(self)
		core.nHarassBonus = core.nHarassBonus + addBonus
	end
end
object.oncombateventOld = object.oncombatevent
object.oncombatevent	 = object.oncombateventOverride


object.mesmeUpBonus = 5
object.holdUpBonus = 20
object.heartacheUpBonus = 10
local function CustomHarassUtilityFnOverride(hero)
	local val = 0
	
	if skills.mesme:CanActivate() then
		val = val + object.mesmeUpBonus
	end
	
	if skills.hold:CanActivate() then
		val = val + object.holdUpBonus
	end

	if skills.heartache:CanActivate() then
		val = val + object.heartacheUpBonus
	end

	-- Less mana less aggerssion
	val = val + (core.unitSelf:GetManaPercent() - 0.80) * 45
	return val

end
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride  



---------------------------------------------------------
--					Harass Behavior					   --
---------------------------------------------------------


object.holdThreshold = 60
object.heartacheThreshold = 40
local function HarassHeroExecuteOverride(botBrain)
	local unitSelf = core.unitSelf

	--Cant trust to dontbreakchanneling
	if object.ultTime + 300 > HoN.GetGameTime() or unitSelf:IsChanneling() then
		return true
	end

	local unitTarget = behaviorLib.heroTarget
	if unitTarget == nil then
		return object.harassExecuteOld(botBrain) --Target is invalid, move on to the next behavior
	end
	
	--mesme goes where it wants
	if unitTarget:HasState("State_Succubis_Ability3") then
		return false
	end

	local vecMyPosition = unitSelf:GetPosition() 
	local nAttackRange = core.GetAbsoluteAttackRangeToUnit(unitSelf, unitTarget)
	local nMyExtraRange = core.GetExtraRange(unitSelf)
	
	local vecTargetPosition = unitTarget:GetPosition()
	local nTargetExtraRange = core.GetExtraRange(unitTarget)
	local nTargetDistanceSq = Vector3.Distance2DSq(vecMyPosition, vecTargetPosition)
	
	local nLastHarassUtility = behaviorLib.lastHarassUtil
	local bCanSee = core.CanSeeUnit(botBrain, unitTarget)	
	local bActionTaken = false
	
	if bCanSee then
		if nLastHarassUtility > object.heartacheThreshold and skills.hold:CanActivate() then
			bActionTaken = core.OrderAbilityEntity(botBrain, skills.hold, unitTarget)
		end
		if not bActionTaken and nLastHarassUtility > object.holdThreshold and skills.heartache:CanActivate() then
			bActionTaken = core.OrderAbilityEntity(botBrain, skills.heartache, unitTarget)
		end
	end
	
	if not bActionTaken then
		return object.harassExecuteOld(botBrain)
	end 
end
object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

----------------------
-- Healing behavior --
----------------------
behaviorLib.healFunc = nil

function behaviorLib.newUseHealthRegenUtility(botBrain)
	oldUtil = behaviorLib.oldUseHealthRegenUtility(botBrain)

	local unitSelf = core.unitSelf

	local missingHP = unitSelf:GetMaxHealth() - unitSelf:GetHealth()

	local heartacheUtil = 0

	if skills.heartache:CanActivate() and core.NumberElements(core.localUnits["Enemies"]) > 0 then
		heartacheUtil = core.ATanFn(missingHP, Vector3.Create(300, 25), Vector3.Create(0,0), 100)
	end

	local bottleUtil = 0
	if core.itemBottle and core.itemBottle:CanActivate() and core.NumberElements(eventsLib.incomingProjectiles["all"]) == 0 then
		bottleUtil = core.ATanFn(missingHP, Vector3.Create(135, 25), Vector3.Create(0,0), 100)
	end

	--Bottle
	if oldUtil > heartacheUtil and oldUtil >= bottleUtil then
		behaviorLib.healFunc = behaviorLib.oldUseHealthRegenExecute
	elseif heartacheUtil >= bottleUtil then
		behaviorLib.healFunc = behaviorLib.healHeartache
	else
		behaviorLib.healFunc = behaviorLib.bottleHeal
	end
	return max(oldUtil, heartacheUtil, bottleUtil)
end
behaviorLib.oldUseHealthRegenUtility = behaviorLib.UseHealthRegenBehavior["Utility"]
behaviorLib.UseHealthRegenBehavior["Utility"] = behaviorLib.newUseHealthRegenUtility

function behaviorLib.healHeartache(botBrain)
	local unitSelf = core.unitSelf
	local mypos = unitSelf:GetPosition()

	local bActionTaken = false

	local heartacheCanActivate = skills.heartache:CanActivate()
	if not bActionTaken and heartacheCanActivate then
		local heartacheRange = skills.heartache:GetRange()
		if core.NumberElements(core.localUnits["EnemyHeroes"]) > 0 then
			local closestHero = nil
			local closestDistance = 99999999
			for _, hero in pairs(core.localUnits["EnemyHeroes"]) do
				local distance = Vector3.Distance2DSq(hero:GetPosition(), mypos)
				if distance < closestDistance then
					closestDistance = distance
					closestHero = hero
					if distance < heartacheRange*heartacheRange then
						break
					end
				end
			end
			if closestHero then
				bActionTaken = core.OrderAbilityEntity(botBrain, skills.heartache, closestHero)
			end
		else
			if core.NumberElements(core.localUnits["EnemyCreeps"]) then
				--just find creep in range or closest
				local closestCreep = nil
				local closestDistance = 99999999
				for _, creep in pairs(core.localUnits["EnemyCreeps"]) do
					local distance = Vector3.Distance2DSq(creep:GetPosition(), mypos)
					if distance < closestDistance then
						closestDistance = distance
						closestCreep = creep
						if distance < heartacheRange*heartacheRange then
							break
						end
					end
				end
				if closestCreep then
					bActionTaken = core.OrderAbilityEntity(botBrain, skills.heartache, closestCreep)
				end
			end
		end
	end
	return bActionTaken
end

function behaviorLib.bottleHeal(botBrain)
	if core.itemBottle and core.itemBottle:CanActivate() then
		object.bottle.drink(botBrain)
	end
	return false
end

function behaviorLib.newUseHealthRegenExecute(botBrain)
	return behaviorLib.healFunc(botBrain)
end

behaviorLib.oldUseHealthRegenExecute = behaviorLib.UseHealthRegenBehavior["Execute"]
behaviorLib.UseHealthRegenBehavior["Execute"] = behaviorLib.newUseHealthRegenExecute