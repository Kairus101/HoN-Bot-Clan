local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Tempest (10)
local hero = HeroInfo.Create('Hero_Tempest');
hero.Threat = 0;

do -- Glacial Blasts
	local abil = AbilityInfo.Create(0, 'Ability_Tempest1');
	abil.Threat = 3; -- Pretty strong stun
	abil.TargetType = 'TargetUnit';
	abil.CastEffectType = 'Magic';
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.CanInterrupt = true;
	abil.StunDuration = 1000; -- 1 second stun (1000ms) every 2 seconds for 1/2/2/3 times
	abil.MagicDamage = { 30, 40, 65, 80 }; -- Initial damage is instant
	abil.MagicDPS = { 0, (40 / 3), (65 / 3), (160 / 5) }; -- Damage is done at an interval of 2 seconds and the initial damage is not included. Therefor DPS is (damage per hit * (hits - 1) / (hits * 2 - 1))
	abil.DebuffDuration = { 1000, 3000, 3000, 5000 };
	--abil.Debuff = ''; -- this has no debuff! :(
	hero:AddAbility(abil);
end

do -- Elemental
	local abil = AbilityInfo.Create(1, 'Ability_Tempest2');
	abil.Threat = 0; -- Threat from this is automatically calculated by the CreepAggroUtility
	abil.TargetType = 'TargetUnit';
	hero:AddAbility(abil);
end

do -- Meteor
	local abil = AbilityInfo.Create(2, 'Ability_Tempest3');
	abil.Threat = 1; -- Lots of damage!
	abil.TargetType = 'TargetPosition';
	abil.CastEffectType = 'Magic';
	abil.CanCastOnHostiles = true;
	abil.MagicDPS = { -0.03, -0.04, -0.05, -0.06 }; -- negative values are considered percentages
	abil.Debuff = 'State_Tempest_Ability3_Tooltip';
	abil.DebuffDuration = 8000;
	hero:AddAbility(abil);
end

do -- Elemental Void
	local abil = AbilityInfo.Create(3, 'Ability_Tempest4');
	abil.Threat = 6; -- Bonus threat! Tempest ult is one of the strongest ingame. Be careful!
	abil.TargetType = 'TargetPosition';
	abil.CastEffectType = 'Magic';
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.StunDuration = 4000;
	abil.CanInterrupt = true;
	abil.CanInterruptMagicImmune = true;
	abil.ShouldSpread = true;
	abil.ShouldInterrupt = true;
	abil.MagicDPS = { 45, 75, 105 }; -- Average DPS
	abil.Debuff = 'State_Tempest_Ability4_Pull';
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
