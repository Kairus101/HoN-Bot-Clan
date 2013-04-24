local _G = getfenv(0)
local object = _G.object

object.jungleLib = object.jungleLib or {}
local jungleLib, eventsLib, core, behaviorLib = object.jungleLib, object.eventsLib, object.core, object.behaviorLib

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random = _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog

BotEcho("Loading jungleLib!")

jungleLib.jungleSpots={
--Leigon
{pos=Vector3.Create(7200,3600),  description="L closest to well"      ,difficulty=100 ,stacks=0},
{pos=Vector3.Create(7800,4500),  description="L easy camp"            ,difficulty=30  ,stacks=0},
{pos=Vector3.Create(9800,4200),  description="L mid-jungle hard camp" ,difficulty=100 ,stacks=0},
{pos=Vector3.Create(11100,3100), description="L pullable camp"        ,difficulty=55  ,stacks=0},
{pos=Vector3.Create(11300,4400), description="L camp above pull camp" ,difficulty=55  ,stacks=0},
{pos=Vector3.Create(5100,8000),  description="L ancients"             ,difficulty=250 ,stacks=0},
--Hellbourne
{pos=Vector3.Create(9400,11200), description="H closest to well"      ,difficulty=100 ,stacks=0},
{pos=Vector3.Create(7700,11600), description="H easy camp"            ,difficulty=30  ,stacks=0},
{pos=Vector3.Create(6600,10500), description="H below easy camp"      ,difficulty=55  ,stacks=0},
{pos=Vector3.Create(5100,12500), description="H pullable camp"        ,difficulty=55  ,stacks=0},
{pos=Vector3.Create(4000,11500), description="H far hard camp"        ,difficulty=100 ,stacks=0},
{pos=Vector3.Create(12300,5600), description="H ancients"             ,difficulty=250 ,stacks=0}
}
jungleLib.minutesPassed=-1
jungleLib.stacking=0

function jungleLib.assess(botBrain)
	--NEUTRAL SPAWNING
	local time=HoN.GetMatchTime()
	local mins=-1
	if time then
		mins=floor(time/60000)
		local secs=floor((time-60000*mins)/1000)
		if secs==30 or (mins~=jungleLib.minutesPassed and mins~=0) then --SPAWNING
			for i=1,#jungleLib.jungleSpots do
				jungleLib.jungleSpots[i].stacks=1 --assume something spawned. If not, it will be removed later if not.
			end
			if (jungleLib.stacking~=0) then --add stack if stacking.
				jungleLib.jungleSpots[jungleLib.stacking].stacks=jungleLib.jungleSpots[jungleLib.stacking].stacks+1
			end
			jungleLib.stacking=0
		end
	end
	jungleLib.minutesPassed=mins

	--CHECK NEUTRAL SPAWN CAMPS
	local debug=true
	for i=1,#jungleLib.jungleSpots do
		if (debug) then
			if (jungleLib.jungleSpots[i].stacks==0) then
				core.DrawXPosition(jungleLib.jungleSpots[i].pos, 'green')
			else
				core.DrawXPosition(jungleLib.jungleSpots[i].pos, 'red')
			end
		end
	
		if (HoN.CanSeePosition(jungleLib.jungleSpots[i].pos))then
			local nUnitsNearCamp=0
			local uUnits=HoN.GetUnitsInRadius(jungleLib.jungleSpots[i].pos, 600, 35) --35 is the lowest working number. I have no clue as to why this is, but it is. Deal with it.
			for key, unit in pairs(uUnits) do
				nUnitsNearCamp=nUnitsNearCamp+1
				core.DrawXPosition(unit:GetPosition(), 'red')
			end
			
			if jungleLib.jungleSpots[i].stacks~=0 and nUnitsNearCamp==0 then --we can see the camp, nothing is there.
				BotEcho("Camp "..jungleLib.jungleSpots[i].description.." is empty. Are they all dead? "..jungleLib.jungleSpots[i].stacks)
				jungleLib.jungleSpots[i].stacks=0
			end
			if (nUnitsNearCamp~=0 and jungleLib.jungleSpots[i].stacks==0 ) then --this shouldn't be true. New units should be made on the minute.
				BotEcho("Camp "..jungleLib.jungleSpots[i].description.." isn't empty, but I thought it was... Maybe I pulled it too far?")
				jungleLib.jungleSpots[i].stacks=1
			end
		end
	end
end

function jungleLib.getNearestCamp(pos,minimumDifficulty,maximumDifficulty)
	minimumDifficulty=minimumDifficulty or 0
	maximumDifficulty=maximumDifficulty or 999
	
	local nClosestSq = 9999*9999
	for i=1,#jungleLib.jungleSpots do
		local dist=Vector3.Distance2DSq(pos, jungleLib.jungleSpots[i].pos)
		if dist<nClosestSq and jungleLib.jungleSpots[i].difficulty>minimumDifficulty and jungleLib.jungleSpots[i].difficulty<maximumDifficulty then
			nClosestSq=dist
			nClosestCamp=i
		end
	end
	return nClosestCamp
end