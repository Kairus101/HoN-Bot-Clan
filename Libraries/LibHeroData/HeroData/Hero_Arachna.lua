local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Arachna (7)
local hero = HeroInfo.Create('Hero_Arachna');
hero.Threat = 2;

do -- Webbed Shot
	local abil = AbilityInfo.Create(0, 'Ability_Arachna1');
	abil.Threat = 2;
	abil.TargetType = 'AutoCast';
	abil.CanCastOnHostiles = true;
	abil.CanSlow = true;
	abil.MagicDPS = { 4, 8, 12, 16 };
	abil.Debuff = 'State_Arachna_Ability1';
	abil.DebuffDuration = 3000;
	hero:AddAbility(abil);
end

do -- Harden Carapace
	local abil = AbilityInfo.Create(1, 'Ability_Arachna2');
	abil.Threat = 0;
	abil.TargetType = 'Self';
	abil.CanCastOnSelf = true;
	hero:AddAbility(abil);
end

do -- Precision
	local abil = AbilityInfo.Create(2, 'Ability_Arachna3');
	abil.Threat = 0; -- The threat for this ability is automatically calculated by the DPS threat
	abil.TargetType = 'Self';
	abil.Buff = 'State_Arachna_Ability3';
	hero:AddAbility(abil);
end

do -- Spider Sting
	local abil = AbilityInfo.Create(3, 'Ability_Arachna4');
	abil.Threat = 3;
	abil.TargetType = 'TargetUnit';
	abil.CanCastOnHostiles = true;
	abil.ShouldPort = true;
	abil.PhysicalDPS = { 75, 150, 225 }; -- total damage / 5 seconds
	abil.Debuff = 'State_Arachna_Ability4';
	abil.DebuffDuration = 5000; -- assume 5 seconds, may be longer
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
