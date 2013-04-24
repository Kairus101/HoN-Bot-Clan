local _G = getfenv(0)
local object = _G.object

object.jungleLib = object.jungleLib or {}
local jungleLib, eventsLib, core, behaviorLib = object.jungleLib, object.eventsLib, object.core, object.behaviorLib

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog

function object.jungle.assess(botBrain)
	leigonSpots={
	{7200,3600},--closest
	{7800,4500},--easy
	{9800,4200},--hard
	{11100,3100},--pull
	{11300,4400}--above pull
	{5100,8000}--ancients
	}
	
	hellbourneSpots={
	{9400,11200},--closest
	{7700,11600},--easy
	{6600,10500}--below easy
	{5100,12500},--pull
	{4000,11500}--far hard
	{12300,5600}--ancients
	}
end