local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Demented Shaman (6.5)
local hero = HeroInfo.Create('Hero_Shaman');
hero.Threat = 0;

do -- Entangle
	local abil = AbilityInfo.Create(0, 'Ability_Shaman1');
	abil.Threat = 1.5;
	abil.TargetType = 'TargetUnit';
	abil.CastEffectType = 'Magic';
	abil.CanCastOnHostiles = true;
	abil.CanStun = { false, false, true, true };
	abil.CanInterrupt = { false, false, true, true };
	abil.CanInterruptMagicImmune = false; -- this can interrupt but only if the debuff is applied before the magic immunity is activated. Therefore it's usually not useful to know.
	abil.CanSlow = true;
	abil.StunDuration = 1000; -- MS
	abil.PhysicalDPS = { 7, 14, 21, 28 };
	abil.Debuff = 'State_Shaman_Ability1_Snare';
	abil.DebuffDuration = { 8000, 9000, 9000, 9000 };
	hero:AddAbility(abil);
end

do -- Unbreakable
	local abil = AbilityInfo.Create(1, 'Ability_Shaman2');
	abil.Threat = 1.5;
	abil.TargetType = 'TargetUnit';
	abil.CanCastOnSelf = true;
	abil.CanCastOnFriendlies = true;
	abil.Buff = 'State_Shaman_Ability2';
	abil.BuffDuration = 6000;
	hero:AddAbility(abil);
end

do -- Healing Wave
	local abil = AbilityInfo.Create(2, 'Ability_Shaman3');
	abil.Threat = 1.5;
	abil.TargetType = 'TargetUnit';
	abil.CastEffectType = 'Physical';
	abil.CanCastOnSelf = true;
	abil.CanCastOnFriendlies = true;
	abil.PhysicalDamage = { 160, 200, 240, 280 }; -- assume 2 hits
	hero:AddAbility(abil);
end

do -- Storm Cloud
	local abil = AbilityInfo.Create(3, 'Ability_Shaman4');
	abil.Threat = 2;
	abil.TargetType = 'TargetPosition';
	abil.CastEffectType = 'Magic';
	abil.CanCastOnSelf = true;
	abil.CanCastOnFriendlies = true;
	abil.CanCastOnHostiles = true;
	abil.Buff = 'State_Shaman_Ability4';
	abil.BuffDuration = { 12000, 18000, 24000 };
	abil.Debuff = 'State_Shaman_Ability4_Enemies';
	abil.DebuffDuration = { 12000, 18000, 24000 };
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
