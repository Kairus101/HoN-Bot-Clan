local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Aluna
local hero = HeroInfo.Create('Hero_Aluna');
hero.Threat = 1;

do -- Emerald Lightning
	local abil = AbilityInfo.Create(0, 'Ability_Aluna1');
	abil.Threat = 2;
	abil.IsSingleTarget = true;
	abil.CanStun = true;
	abil.StunDuration = 1000; -- MS
	abil.CanInterrupt = true;
	abil.MagicDamage = { 100, 150, 200, 250 };
	--abil.Buff = 'State_Aluna_Ability1_Self'; -- not relevant, threat is already calculated by DPS threat
	abil.Debuff = 'State_Aluna_Ability1_Enemy';
	hero:AddAbility(abil);
end

do -- Power Throw
	local abil = AbilityInfo.Create(1, 'Ability_Aluna2');
	abil.Threat = 1;
	abil.MagicDamage = { 140, 210, 280, 350 };
	hero:AddAbility(abil);
end

do -- Deja Vu
	local abil = AbilityInfo.Create(2, 'Ability_Aluna3');
	abil.Threat = 1; -- The threat for this ability is automatically calculated by the DPS threat
	abil.Buff = 'State_Aluna_Ability3';
	hero:AddAbility(abil);
end

do -- Emerald Red
	local abil = AbilityInfo.Create(3, 'Ability_Aluna4');
	abil.Threat = 1;
	abil.Buff = 'State_Aluna_Ability4';
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
