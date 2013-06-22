local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Hammerstorm
local hero = HeroInfo.Create('Hero_Hammerstorm');
hero.Threat = 2;

do -- Hammer Throw
	local abil = AbilityInfo.Create(0, 'Ability_Hammerstorm1');
	abil.Threat = 2;
	abil.TargetType = 'TargetUnit';
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.StunDuration = 2000;
	abil.MagicDamage = { 100, 175, 250, 325 };
	abil.Debuff = 'State_Stunned';
	abil.DebuffDuration = 2000;
	hero:AddAbility(abil);
end

do -- Mighty Swing
	local abil = AbilityInfo.Create(1, 'Ability_Hammerstorm2');
	abil.Threat = 0;
	abil.TargetType = 'Passive';
	hero:AddAbility(abil);
end

do -- Galvanize
	local abil = AbilityInfo.Create(2, 'Ability_Hammerstorm3');
	abil.Threat = 0;
	abil.TargetType = 'Self';
	abil.CanCastOnSelf = true;
	abil.CanCastOnFriendlies = true;
	abil.Buff = 'State_Hammerstorm_Ability3';
	abil.BuffDuration = 6000;
	hero:AddAbility(abil);
end

do -- Brute Strength
	local abil = AbilityInfo.Create(3, 'Ability_Hammerstorm4');
	abil.Threat = 2; -- The threat for this ability is automatically calculated by the DPS threat
	abil.TargetType = 'Self';
	abil.CanCastOnSelf = true;
	abil.Debuff = 'State_Hammerstorm_Ability4';
	abil.DebuffDuration = 25000;
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
