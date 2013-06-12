local _G = getfenv(0);
local setmetatable, type = _G.setmetatable, _G.type;

-- The bot classes namespace
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.Classes = _G.HoNBots.Classes or {};

local classes = _G.HoNBots.Classes;

-- Make class table
classes.AbilityInfo = {};

-- Easy reference
local class = classes.AbilityInfo;
class.__index = class;

-- Private
class.__Slot = nil;
class.__TypeName = nil;

-- Public properties
-- These properties may also be tables containing different values per level, e.g. abil.CanStun = { false,false,false,true }
class.IsSingleTarget = false;

class.CanStun = false;
class.StunDuration = 0; -- MS
class.CanInterrupt = false;
class.CanInterruptMagicImmune = false;
class.CanSlow = false;
class.CanRoot = false;
class.CanDisarm = false;
class.CanInvisSelf = false;
class.CanInvisOther = false;
class.CanReveal = false;

class.ShouldSpread = false;
class.ShouldInterrupt = false;
class.ShouldBreakFree = false;

-- A negative value is considered a percentage.
-- Can also provide a function to calculate the damage (first parameter passed must be ability level, second must be the unit affected)
class.MagicDamage = 0;
class.MagicDPS = 0;
class.PhysicalDamage = 0;
class.PhysicalDPS = 0;

class.Buff = nil; -- e.g. abil.Buff = 'State_Aluna_Ability4'
class.BuffDuration = 0;
class.Debuff = nil; -- e.g. abil.Debuff = 'State_Andromeda_Ability2'
class.DebuffDuration = 0;

function class.Create(nSlot, sTypeName)
	local instance = {};
	setmetatable(instance, class);
	
	instance.__Slot = nSlot;
	instance.__TypeName = sTypeName;
	
	return instance;
end

function class:GetTypeName()
	return self.__TypeName;
end
function class:GetSlot()
	return self.__Slot;
end
function class:GetValue(val, nAbilityLevel)
	if type(val) == 'table' then
		return val[nAbilityLevel - 1];
	end
	
	return val;
end