local _G = getfenv(0)
local object = _G.object

local core, eventsLib, behaviorLib, metadata, skills = object.core, object.eventsLib, object.behaviorLib, object.metadata, object.skills

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog
local Clamp = core.Clamp

object.bottle = {}
local bottle = object.bottle

local function BottleFindItemsOverride(botBrain)
	object.BottleFindItemsOld(botBrain)
	if core.itemBottle ~= nil and not core.itemBottle:IsValid() then
		core.itemBottle = nil
	end

	local inventory = core.unitSelf:GetInventory(true)
	for slot = 1, 6, 1 do
		local curItem = inventory[slot]
		if curItem ~= nil then
			if core.itemBottle == nil and curItem:GetName() == "Item_Bottle" then
				core.itemBottle = core.WrapInTable(curItem)
			end
		end
	end
end

object.BottleFindItemsOld = core.FindItems
core.FindItems = BottleFindItemsOverride

function bottle.haveBottle()
	return core.itemBottle ~= nil
end

function bottle.drink(botBrain)
	if bottle.haveBottle() and core.itemBottle:GetActiveModifierKey() ~= "bottle_empty" and core.itemBottle:CanActivate() then
		if not core.unitSelf:HasState("State_Bottle") or bottle.getCharges() == 4 then
			botBrain:OrderItem(core.itemBottle.object)
			return true
		end
	end
	return false
end

function bottle.getCharges()
	if not bottle.haveBottle() then
		return nil
	end

	local charges = nil
	local modifier = core.itemBottle:GetActiveModifierKey()
	if modifier == "bottle_empty" then
		charges = 0
	elseif modifier == "bottle_1" then
		charges = 1
	elseif modifier == "bottle_2" then
		charges = 2
	elseif modifier == "bottle_3" then
		charges = 3
	else
		charges = 4 --rune
	end
	return charges
end

--Damage Stealth Illusion MoveSpeed Regen
function bottle.getRune()
	if not bottle.haveBottle() then
		return ""
	end
	local modifier = core.itemBottle:GetActiveModifierKey()
	local key = string.gmatch(modifier, "bottle_%w")
	if key == "1" or key == "2" or key == "3" or key =="empty" then
		return ""
	else
		return key
	end
end

