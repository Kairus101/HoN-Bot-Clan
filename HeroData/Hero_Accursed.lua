local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Accursed
local hero = HeroInfo.Create('Hero_Accursed');
hero.Threat = 2;

-- Cauterize
local abilCauterize = AbilityInfo.Create(0, 'Ability_Accursed1');
abilCauterize.Threat = 2;
abilCauterize.IsSingleTarget = true;
abilCauterize.MagicDamage = { 100, 150, 200, 250 };
hero:AddAbility(abilCauterize);

-- Fire Shield
local abilFireShield = AbilityInfo.Create(1, 'Ability_Accursed2');
abilFireShield.Threat = 2;
abilFireShield.IsSingleTarget = true;
abilFireShield.MagicDamage = { 110, 140, 170, 200 }; --TODO: should we really consider this?
abilFireShield.Buff = 'State_Accursed_Ability2';
hero:AddAbility(abilFireShield);

-- Sear
local abilSear = AbilityInfo.Create(2, 'Ability_Accursed3');
abilSear.Threat = 0; -- The threat for this ability is automatically calculated by the DPS threat
--abilFlameConsumption.Buff = 'State_Accursed_Ability3_Buff'; -- not relevant, threat is calculated by DPS threat
--abilFlameConsumption.Debuff = 'State_Accursed_Ability3_Debuff';
hero:AddAbility(abilSear);

-- Flame Consumption
local abilFlameConsumption = AbilityInfo.Create(3, 'Ability_Accursed4');
abilFlameConsumption.Threat = 0;
abilFlameConsumption.IsSingleTarget = true;
abilFlameConsumption.Buff = 'State_Accursed_Ability4';
hero:AddAbility(abilFlameConsumption);

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
