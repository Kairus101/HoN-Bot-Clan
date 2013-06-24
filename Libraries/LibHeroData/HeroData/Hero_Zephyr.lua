local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Zephyr
local hero = HeroInfo.Create('Hero_Zephyr');
hero.Threat = 2;

do -- Gust
	local abil = AbilityInfo.Create(0, 'Ability_Zephyr1');
	abil.Threat = 2;
	abil.TargetType = 'TargetVector';
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.CanInterrupt = true;
	abil.StunDuration = 100;
	abil.MagicDamage = { 70, 140, 210, 280 };
	hero:AddAbility(abil);
end

do -- Cyclones
	local abil = AbilityInfo.Create(1, 'Ability_Zephyr2');
	abil.Threat = 0;
	abil.TargetType = 'Passive'; -- is actually Self, but we consider this passive since it does a continuous AOE damage
	abil.CanCastOnHostiles = true;
	abil.MagicDPS = { 15, 20, 25, 30 };
	hero:AddAbility(abil);
end

do -- Wind Shield
	local abil = AbilityInfo.Create(2, 'Ability_Zephyr3');
	abil.Threat = 0;
	abil.TargetType = 'Passive';
	hero:AddAbility(abil);
end

do -- Typhoon
	local abil = AbilityInfo.Create(3, 'Ability_Zephyr4');
	abil.Threat = 2;
	abil.TargetType = 'TargetPosition';
	abil.CanCastOnHostiles = true;
	abil.CanSlow = true;
	abil.ShouldSpread = true;
	abil.MagicDPS = { 60, 80, 100 };
	abil.Debuff = 'State_Zephyr_Ability4_Debuff';
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
