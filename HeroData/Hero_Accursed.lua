local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Accursed
local hero = HeroInfo.Create('Hero_Accursed');
hero.Threat = 2;

do -- Cauterize
	local abil = AbilityInfo.Create(0, 'Ability_Accursed1');
	abil.Threat = 2;
	abil.IsSingleTarget = true;
	abil.MagicDamage = { 100, 150, 200, 250 };
	hero:AddAbility(abil);
end

do -- Fire Shield
	local abil = AbilityInfo.Create(1, 'Ability_Accursed2');
	abil.Threat = 2;
	abil.IsSingleTarget = true;
	abil.MagicDamage = { 110, 140, 170, 200 }; --TODO: should we really consider this?
	abil.Buff = 'State_Accursed_Ability2';
	hero:AddAbility(abil);
end

do -- Sear
	local abil = AbilityInfo.Create(2, 'Ability_Accursed3');
	abil.Threat = 0; -- The threat for this ability is automatically calculated by the DPS threat
	--abil.Buff = 'State_Accursed_Ability3_Buff'; -- not relevant, threat is calculated by DPS threat
	--abil.Debuff = 'State_Accursed_Ability3_Debuff';
	hero:AddAbility(abil);
end

do -- Flame Consumption
	local abil = AbilityInfo.Create(3, 'Ability_Accursed4');
	abil.Threat = 0;
	abil.IsSingleTarget = true;
	abil.Buff = 'State_Accursed_Ability4';
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
