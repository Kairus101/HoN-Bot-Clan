--------------------------------------------------------------------
-- __  __                      _     _             ____        _   
--|  \/  |                    (_)   | |           |  _ \      | |  
--| \  / |_   _ _ __ _ __ ___  _  __| | ___  _ __ | |_) | ___ | |_ 
--| |\/| | | | | '__| '_ ` _ \| |/ _` |/ _ \| '_ \|  _ < / _ \| __|
--| |  | | |_| | |  | | | | | | | (_| | (_) | | | | |_) | (_) | |_ 
--|_|  |_|\__, |_|  |_| |_| |_|_|\__,_|\___/|_| |_|____/ \___/ \__|
--         __/ |                                                   
--        |___/         
--------------------------------------------------------------------
--       A HoN Community Bot Project        --
----------------------------------------------
--                Created by:               --
----------------------------------------------
--                    VHD                   --
--                  DarkFire                --
--                 Kairus101                --
----------------------------------------------

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

runfile "bots/advancedShopping.lua"
local shopping = object.shoppingHandler
shopping.Setup(true, true, false, false, false, false)
shopping.PreGameWaiting=false

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

-- Legionnaire
object.heroName = 'Hero_Hydromancer'

-- Item buy order. internal names
behaviorLib.StartingItems =
	{"2 Item_IronBuckler", "Item_RunesOfTheBlight"}
behaviorLib.LaneItems =
	{"Item_Lifetube", "Item_Marchers", "Item_Shield2", "Item_MysticVestments"} -- Shield2 is HotBL
behaviorLib.MidItems =
	{"Item_EnhancedMarchers", "Item_PortalKey"} 
behaviorLib.LateItems =
	{"Item_Excruciator", "Item_SolsBulwark", "Item_DaemonicBreastplate", "Item_BehemothsHeart", "Item_Freeze"} --Excruciator is Barbed Armor, Freeze is Frostwolf's Skull.

-- Skillbuild. 0 is Taunt, 1 is Charge, 2 is Whirling Blade, 3 is Execution, 4 is Attributes
object.tSkills = {
	2, 1, 2, 0, 2,
	3, 2, 1, 1, 1,
	3, 0, 0, 0, 4,
	3, 4, 4, 4, 4,
	4, 4, 4, 4, 4
}

-- Bonus agression points if a skill/item is available for use

--object.nTauntUp = 7

-- Bonus agression points that are applied to the bot upon successfully using a skill/item

--object.nTauntUse = 13

-- Thresholds of aggression the bot must reach to use these abilities

--object.nTauntThreshold = 26

-- Other variables

--object.nLastTauntTime = 0

------------------------------
--          Skills          --
------------------------------

function object:SkillBuild()
	core.VerboseLog("SkillBuild()")

	local unitSelf = self.core.unitSelf
	if  skills.abilWhirlingBlade == nil then
		skills.abilTaunt = unitSelf:GetAbility(0)
		skills.abilCharge = unitSelf:GetAbility(1)
		skills.abilWhirlingBlade = unitSelf:GetAbility(2)
		skills.abilDecap = unitSelf:GetAbility(3)
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

	if core.itemGhostMarchers ~= nil and not core.itemGhostMarchers:IsValid() then
		core.itemGhostMarchers = nil
	end

	if bUpdated then
		if core.itemPortalKey and core.itemGhostMarchers and core.itemBarbedArmor then
			return
		end

		local inventory = core.unitSelf:GetInventory(true)
		for slot = 1, 12, 1 do
			local curItem = inventory[slot]
			if curItem then
				if core.itemPortalKey == nil and curItem:GetName() == "Item_PortalKey" then
					core.itemPortalKey = core.WrapInTable(curItem)
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
		if EventData.InflictorName == "Ability_Legionnaire1" then
			nAddBonus = nAddBonus + object.nTauntUse
		end
	elseif EventData.Type == "Item" then
		if core.itemPortalKey ~= nil and EventData.SourceUnit == core.unitSelf:GetUniqueID() and EventData.InflictorName == core.itemPortalKey:GetName() then
			nAddBonus = nAddBonus + self.nPortalKeyUse
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
	
	if skills.abilTaunt:CanActivate() then
		nUtility = nUtility + object.nTauntUp
	end
	
	if object.itemPortalKey and object.itemPortalKey:CanActivate() then
		nUtility = nUtility + object.nPortalKeyUp
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
	local nLastHarassUtility = behaviorLib.lastHarassUtil

	local bActionTaken = false

	if not bActionTaken then
		
	end

	return bActionTaken
end

object.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

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
