local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Predator (7)
local hero = HeroInfo.Create('Hero_Predator');
hero.Threat = 3;

do -- Venomous Leap
	local abil = AbilityInfo.Create(0, 'Ability_Predator1');
	abil.Threat = 2;
	abil.TargetType = 'TargetUnit';
	abil.CanCastOnHostiles = true;
	abil.CanSlow = true;
	abil.MagicDamage = { 75, 125, 175, 225 };
	abil.Debuff = 'State_Arachna_Ability1';
	abil.DebuffDuration = { 2000, 3000, 4000, 5000 };
	hero:AddAbility(abil);
end

do -- Stone Hide
	local abil = AbilityInfo.Create(1, 'Ability_Predator2');
	abil.Threat = 0;
	abil.TargetType = 'Self';
	abil.CanCastOnSelf = true;
	hero:AddAbility(abil);
end

do -- Carnivorous
	local abil = AbilityInfo.Create(2, 'Ability_Predator3');
	abil.Threat = 0;
	abil.TargetType = 'Passive';
	hero:AddAbility(abil);
end

do -- Terror
	local abil = AbilityInfo.Create(3, 'Ability_Predator4');
	abil.Threat = 2; -- Additional threat for this ability is automatically calculated by the DPS threat
	abil.TargetType = 'Passive';
	abil.Buff = 'State_Predator_Ability4_Buff';
	abil.BuffDuration = 3500;
	abil.Debuff = 'State_Predator_Ability4_Enemy';
	abil.DebuffDuration = 3000;
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
