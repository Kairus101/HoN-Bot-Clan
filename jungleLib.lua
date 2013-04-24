local _G = getfenv(0)
local object = _G.object

object.jungleLib = object.jungleLib or {}
local jungleLib, eventsLib, core, behaviorLib = object.jungleLib, object.eventsLib, object.core, object.behaviorLib

local print, ipairs, pairs, string, table, next, type, tinsert, tremove, tsort, format, tostring, tonumber, strfind, strsub
	= _G.print, _G.ipairs, _G.pairs, _G.string, _G.table, _G.next, _G.type, _G.table.insert, _G.table.remove, _G.table.sort, _G.string.format, _G.tostring, _G.tonumber, _G.string.find, _G.string.sub
local ceil, floor, pi, tan, atan, atan2, abs, cos, sin, acos, max, random
	= _G.math.ceil, _G.math.floor, _G.math.pi, _G.math.tan, _G.math.atan, _G.math.atan2, _G.math.abs, _G.math.cos, _G.math.sin, _G.math.acos, _G.math.max, _G.math.random

local BotEcho, VerboseLog, BotLog = core.BotEcho, core.VerboseLog, core.BotLog

leigonSpots={
{pos={7200,3600},	description="L closest to well"			},
{pos={7800,4500},	description="L easy camp"				},
{pos={9800,4200},	description="L mid-jungle hard camp"	},
{pos={11100,3100},	description="L pullable camp"			},
{pos={11300,4400},	description="L camp above pull camp"	},
{pos={5100,8000},	description="L ancients"				}
}

hellbourneSpots={
{pos={9400,11200},	description="H closest to well"			}	,
{pos={7700,11600},	description="H easy camp"				}	,
{pos={6600,10500},	description="H below easy camp"			}	,
{pos={5100,12500},	description="H pullable camp"			}	,
{pos={4000,11500},	description="H far hard camp"			}	,--far hard
{pos={12300,5600},	description="H ancients"				}	--ancients
}

function object.jungle.assess(botBrain)
	
	
	
end