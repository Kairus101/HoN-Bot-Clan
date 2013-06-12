local _G = getfenv(0);
local setmetatable, type = _G.setmetatable, _G.type;

-- The bot classes namespace
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.Classes = _G.HoNBots.Classes or {};

local classes = _G.HoNBots.Classes;

-- Make class table
classes.HeroInfo = {};

-- Easy reference
local class = classes.HeroInfo;
class.__index = class;

-- Private
class.__TypeName = nil;

-- Public properties
class.Abilities = nil;
class.Threat = 0;

function class.Create(sTypeName)
	local instance = {};
	setmetatable(instance, class);
	
	instance.__TypeName = sTypeName;
	instance.Abilities = {};
	
	return instance;
end

function class:GetTypeName()
	return self.__TypeName;
end

function class:AddAbility(abil)
	self.Abilities[abil:GetSlot()] = abil;
	--self.Abilities[abil:GetTypeName()] = abil;
end
function class:GetAbility(nSlot)
	return self.Abilities[nSlot];
end
--function class:GetAbility2(sTypeName)
--	return self.Abilities[sTypeName];
--end
