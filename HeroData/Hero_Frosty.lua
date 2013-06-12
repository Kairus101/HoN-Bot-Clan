local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Glacius (5)
local hero = HeroInfo.Create('Hero_Frosty');
hero.Threat = 0;

do -- Tundra Blast
	local abil = AbilityInfo.Create(0, 'Ability_Frosty1');
	abil.Threat = 1;
	abil.CanSlow = true;
	abil.MagicDamage = { 80, 130, 180, 230 };
	abil.Debuff = 'State_Frosty_Ability1';
	abil.DebuffDuration = { 3000, 3500, 4000, 4500 };
	hero:AddAbility(abil);
end

do -- Ice Imprisonment
	local abil = AbilityInfo.Create(1, 'Ability_Frosty2');
	abil.Threat = 2;
	abil.IsSingleTarget = true;
	-- This isn't a real stun! It's an immobilize that disarms.
	abil.CanInterrupt = true;
	abil.CanInterruptMagicImmune = true;
	abil.CanRoot = true;
	abil.CanDisarm = true;
	abil.CanReveal = true;
	abil.MagicDPS = 70;
	abil.Debuff = 'State_Frosty_Ability2';
	abil.DebuffDuration = { 1500, 2000, 2500, 3000 };
	hero:AddAbility(abil);
end

do -- Chilling Presence
	local abil = AbilityInfo.Create(2, 'Ability_Frosty3');
	abil.Threat = 0;
	abil.Buff = 'State_Frosty_Ability3';
	hero:AddAbility(abil);
end

do -- Glacial Downpour
	local abil = AbilityInfo.Create(3, 'Ability_Frosty4');
	abil.Threat = 2;
	abil.CanSlow = true;
	abil.ShouldInterrupt = true;
	abil.MagicDPS = { 55, 95, 135 }; -- assume one hit per second
	abil.Debuff = 'State_Frosty_Ability4';
	abil.DebuffDuration = 1500;
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
