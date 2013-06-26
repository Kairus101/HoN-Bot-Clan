local _G = getfenv(0);
local setmetatable, type = _G.setmetatable, _G.type;

-- The bot classes namespace
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.Classes = _G.HoNBots.Classes or {};

local classes = _G.HoNBots.Classes;

-- Make class table
classes.AbilityInfo = classes.AbilityInfo or {};

local class = classes.AbilityInfo; -- An easy to remember and general reference
class.__index = class;

-----------------------------------------------------------------------------------------------------------------------------------------
-- Private fields
-----------------------------------------------------------------------------------------------------------------------------------------
class.__Slot = nil;
class.__TypeName = nil;
class.__HeroInfo = nil;

-----------------------------------------------------------------------------------------------------------------------------------------
-- Required properties: these should be set in every ability instance.
-----------------------------------------------------------------------------------------------------------------------------------------

-- The threat of the ability. Only one value allowed. Only applied when the ability is off cooldown. For passive abilities add threat to the hero. Keep in mind that any abilities that increase the visual DPS of the hero will automatically increase threat too.
class.Threat = 0;
-- The targeting type of the ability. Only one value allowed. May be used to automatically determine how an ability should be cast.
class.TargetType = ''; -- Passive, Self, AutoCast, TargetUnit, TargetPosition, TargetVector, VectorEntity

-- The below value isn't really required: it should be filled if the casteffecttype in the ability.entity file for the abiltiy has been filled. If not then you can skip setting this property. (it's not listed as an optional property since it doesn't share those traits)
-- You can also provide a table with multiple values, e.g. Tundra's Piercing Shards which is both superior magic and superior physical would be { 'SuperiorMagic', 'SuperiorPhysical' }.
class.CastEffectType = ''; -- Magic, Physical, SuperiorMagic, SuperiorPhysical 

-----------------------------------------------------------------------------------------------------------------------------------------
-- Optional properties
-- Most of these properties may also be tables containing different values per level, e.g. abil.CanStun = { false, false, false, true }
-----------------------------------------------------------------------------------------------------------------------------------------

-- If the TargetType is VectorEntity this should specify what kind of target is optimal (e.g. for Grinex this would be a table: { 'Hero', 'Cliff', 'Tree', 'Building' }, for Rally this is 'Hero').
class.VectorEntityTarget = nil;

-- Whether the ability can only be cast on self. Things like Scout's Vanish or Accursed's ult count as such.
class.CanCastOnSelf = false;
-- Whether the ability can be used on friendly heroes.
class.CanCastOnFriendlies = false;
-- Whether the ability can be used on hostile heroes. Should not be used for auras such as Accursed's Sear.
class.CanCastOnHostiles = false;

-- The state that is applied if the hero is channeling this ability. Only required for abilities that need to be channeled.
class.ChannelingState = nil;

class.CanStun = false;
class.CanInterrupt = false;
class.CanInterruptMagicImmune = false; -- e.g. Panda's abilities that go through shrunken head
class.CanSlow = false;
class.CanRoot = false;
class.CanDisarm = false;
class.CanTurnInvisible = false; -- e.g. Scout Vanish or Keeper Nature's Veil
class.CanReveal = false; -- e.g. Tempest ult, Scout's Eyes, Pestilence ult
class.CanDispositionSelf = false; -- e.g. Andro swap, Magebane Blink, Chronos Time Leap, Pharaoh ult, Doctor ult - i.e. anything moving your own hero
class.CanDispositionFriendlies = false; -- e.g. Andro swap, devo hook
class.CanDispositionHostiles = false; -- e.g. Andro swap, devo hook, prisoner ball and chain

class.StunDuration = 0; -- MS

class.ShouldSpread = false; -- for abilities like Elemental Void (Tempest's ult)
class.ShouldInterrupt = false; -- for abilities like Elemental Void (Tempest's ult)
class.ShouldBreakFree = false; -- for abilities like Root (Keeper of the Forest's ult)
class.ShouldPort = false; -- for abilities like Hemorrhage (Blood Hunter's ult)
class.ShouldAvoidDamage = false; -- for abilities like Cursed Ground (Voodoo Jester's E)

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

--[[ function class.Create(nSlot, sTypeName)
description:		Create a new instance of the AbilityInfo class.
parameters:			nSlot				(Number) The slot number for the ability.
					sTypeName			(String) The type name for the ability.
returns:			(AbilityInfo) A new instance of the AbilityInfo class.
]]
function class.Create(nSlot, sTypeName)
	local instance = {};
	setmetatable(instance, class);
	
	instance.__Slot = nSlot;
	instance.__TypeName = sTypeName;
	
	return instance;
end

--[[ function class:GetTypeName()
description:		Returns the type name for this ability.
returns:			(String) The type name for this ability.
]]
function class:GetTypeName()
	return self.__TypeName;
end
--[[ function class:GetSlot()
description:		Returns the slot for this ability.
returns:			(Number) The slot for this ability.
]]
function class:GetSlot()
	return self.__Slot;
end
--[[ function class:GetValue(val, nAbilityLevel)
description:		Get the value fitting the ability level.
parameters:			val					(object) The value of any of the properties of this class.
					nAbilityLevel		(Number) The ability level to return data for.
returns:			(object) A single value indicating the value for the ability of this level.
example:			abilInfo:GetValue(abilInfo.CanStun, abil:GetLevel())
]]
function class:GetValue(val, nAbilityLevel)
	if type(val) == 'table' then
		return val[nAbilityLevel - 1];
	end
	
	return val;
end

function class:SetHeroInfo(heroInfo)
	self.__HeroInfo = heroInfo;
end
function class:GetHeroInfo()
	return self.__HeroInfo;
end
function class:IsFrom(unit)
	if unit:GetTypeName() == self.__HeroInfo:GetTypeName() then
		return true;
	end
	
	return false;
end
