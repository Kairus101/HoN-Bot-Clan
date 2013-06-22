local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Grinex
local hero = HeroInfo.Create('Hero_Grinex');
hero.Threat = 2;

do -- Shadow Step
	local abil = AbilityInfo.Create(0, 'Ability_Grinex1');
	abil.Threat = 2;
	abil.TargetType = 'VectorEntity';
	abil.VectorEntityTarget = { 'Hero', 'Cliff', 'Tree', 'Building' };
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.CanInterrupt = true;
	abil.StunDuration = { 1000, 1200, 1400, 1600 };
	abil.MagicDamage = { 50, 80, 110, 140 };
	hero:AddAbility(abil);
end

do -- Rift Stalk
	local abil = AbilityInfo.Create(1, 'Ability_Grinex2');
	abil.Threat = 0;
	abil.TargetType = 'Self';
	abil.CanCastOnSelf = true;
	abil.CanTurnInvisible = true;
	abil.Buff = { 'State_Grinex_Ability2', 'State_Grinex_Invis_Ability2' };
	abil.BuffDuration = { 4500, 5500, 6500, 7500 };
	hero:AddAbility(abil);
end

do -- Nether Strike
	local abil = AbilityInfo.Create(2, 'Ability_Grinex3');
	abil.Threat = 0; -- The threat for this ability is automatically calculated by the DPS threat
	abil.TargetType = 'Passive';
	abil.Buff = 'State_Grinex_Ability3';
	abil.BuffDuration = 9000;
	hero:AddAbility(abil);
end

do -- Illusory Assault
	local abil = AbilityInfo.Create(3, 'Ability_Grinex4');
	abil.Threat = 2;
	abil.TargetType = 'Self'; -- Passive, Self, AutoCast, TargetUnit, TargetPosition, VectorEntity
	abil.CanCastOnSelf = true;
	abil.CanTurnInvisible = true;
	abil.PhysicalDPS = { (200 / 4), (360 / 5), (560 / 6) }; -- total damage / duration
	abil.Buff = { 'State_Grinex_Ability4_Initial', 'State_Grinex_Ability4_Path' };
	abil.DebuffDuration = { 4000, 5000, 6000 };
	abil.Debuff = 'State_Grinex_Ability4_Sight';
	abil.DebuffDuration = { 4000, 5000, 6000 };
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
