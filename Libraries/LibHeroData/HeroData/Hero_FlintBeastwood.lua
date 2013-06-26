local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Flint Beastwood
local hero = HeroInfo.Create('Hero_FlintBeastwood');
hero.Threat = 3;

do -- Explosive Flare
	local abil = AbilityInfo.Create(0, 'Ability_FlintBeastwood1');
	abil.Threat = 1.5;
	abil.TargetType = 'TargetPosition';
	abil.CastEffectType = 'Magic';
	abil.CanCastOnHostiles = true;
	abil.CanSlow = true;
	abil.MagicDamage = { 25, 50, 75, 100 };
	abil.MagicDPS = { 25, 50, 75, 100 };
	abil.Debuff = { 'State_FlintBeastwood_Ability1', 'State_FlintBeastwood_Ability1_DoT' };
	abil.DebuffDuration = 2000;
	hero:AddAbility(abil);
end

do -- Hollowpoint Shells
	local abil = AbilityInfo.Create(1, 'Ability_FlintBeastwood2');
	abil.Threat = 0; -- included in base threat
	abil.TargetType = 'Passive';
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.CanInterrupt = true;
	abil.CanInterruptMagicImmune = true;
	abil.StunDuration = { 50, 100, 200, 200 };
	abil.PhysicalDamage = { 15, 30, 45, 60 };
	hero:AddAbility(abil);
end

do -- Dead Eye
	local abil = AbilityInfo.Create(2, 'Ability_FlintBeastwood3');
	abil.Threat = 0; -- included in base threat
	abil.TargetType = 'Passive';
	hero:AddAbility(abil);
end

do -- Money Shot
	local abil = AbilityInfo.Create(3, 'Ability_FlintBeastwood4');
	abil.Threat = 1.5;
	abil.TargetType = 'TargetUnit';
	abil.CastEffectType = 'SuperiorMagic';
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.CanInterrupt = true;
	abil.CanInterruptMagicImmune = true;
	abil.StunDuration = 200;
	abil.ShouldInterrupt = true; -- generally this ability is only cast to finish someone off, so by interrupting we may be able to save them.
	abil.MagicDamage = { 355, 505, 655 };
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
