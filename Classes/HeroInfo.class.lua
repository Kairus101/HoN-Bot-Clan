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

--[[ function class.Create(sTypeName)
description:		Create a new instance of the HeroInfo class.
parameters:			sTypeName			(String) The type name for the hero.
returns:			(HeroInfo) A new instance of the HeroInfo class.
]]
function class.Create(sTypeName)
	local instance = {};
	setmetatable(instance, class);
	
	instance.__TypeName = sTypeName;
	instance.Abilities = {};
	
	return instance;
end

--[[ function class:GetTypeName()
description:		Get the type name for this hero.
returns:			(String) The type name for this hero.
]]
function class:GetTypeName()
	return self.__TypeName;
end

--[[ function class:AddAbility(abil)
description:		Add an ability to this hero.
parameters:			abil				(AbilityData) The ability to add.
]]
function class:AddAbility(abil)
	self.Abilities[abil:GetSlot()] = abil;
	--self.Abilities[abil:GetTypeName()] = abil;
end
--[[ function class:GetAbility(nSlot)
description:		Get the ability for the provided slot.
parameters:			nSlot				(Number) The slot of the ability.
returns:			(AbilityData) An instance of the AbilityData if it exists, nil if not.
]]
function class:GetAbility(nSlot)
	return self.Abilities[nSlot];
end
--function class:GetAbility2(sTypeName)
--	return self.Abilities[sTypeName];
--end

--[[ function class:Has(sAction)
description:		Check if this Hero has an ability that can do the provided action.
parameters:			sAction				(String) The action an ability need to be able to do.
										May be Stun, Interrupt, InterruptMagicImmune, Slow, Root, Disarm, InvisSelf, InvisOther or Reveal.
returns:			(Boolean) True if one or more of the abilities can do this action.
example:			hero:Has('Stun')
]]
function class:Has(sAction)
	for i = 0, 8 do
		local abil = self:GetAbility(i);
		
		if abil then
			if abil['Can' .. sAction] then
				return true;
			end
		end
	end
	
	return false;
end
