local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Tempest (10)
local hero = HeroInfo.Create('Hero_Tempest');
hero.Threat = 0;

-- Glacial Blasts
local abilGlacialBlasts = AbilityInfo.Create(0, 'Ability_Tempest1');
abilGlacialBlasts.Threat = 3; -- Pretty strong stun
abilGlacialBlasts.CanStun = true;
abilGlacialBlasts.StunDuration = 1000; -- 1 second stun (1000ms) every 2 seconds for 1/2/2/3 times
abilGlacialBlasts.CanInterrupt = true;
abilGlacialBlasts.IsSingleTarget = true;
abilGlacialBlasts.MagicDamage = { 30, 40, 65, 80 }; -- Initial damage is instant
abilGlacialBlasts.MagicDPS = { 0, (40 / 3), (65 / 3), (160 / 5) }; -- Damage is done at an interval of 2 seconds and the initial damage is not included. Therefor DPS is (damage per hit * (hits - 1) / (hits * 2 - 1))
abilGlacialBlasts.DebuffDuration = { 1000, 3000, 3000, 5000 };
--abilGlacialBlasts.Debuff = ''; -- this has no debuff! :(
hero:AddAbility(abilGlacialBlasts);

-- Elemental
local abilElemental = AbilityInfo.Create(1, 'Ability_Tempest2');
abilElemental.Threat = 0; -- Threat from this is automatically calculated by the CreepAggroUtility
abilElemental.IsSingleTarget = true;
hero:AddAbility(abilElemental);

-- Meteor
local abilMeteor = AbilityInfo.Create(2, 'Ability_Tempest3');
abilMeteor.Threat = 1; -- Lots of damage!
abilMeteor.MagicDPS = { -0.03, -0.04, -0.05, -0.06 }; -- negative values are considered percentages
abilMeteor.Debuff = 'State_Tempest_Ability3_Tooltip';
abilMeteor.DebuffDuration = 8000;
hero:AddAbility(abilMeteor);

-- Elemental Void
local abilElementalVoid = AbilityInfo.Create(3, 'Ability_Tempest4');
abilElementalVoid.Threat = 6; -- Bonus threat! Tempest ult is one of the strongest ingame. Be careful!
abilElementalVoid.CanStun = true;
abilElementalVoid.StunDuration = 4000;
abilElementalVoid.CanInterrupt = true;
abilElementalVoid.CanInterruptMagicImmune = true;
abilElementalVoid.ShouldSpread = true;
abilElementalVoid.ShouldInterrupt = true;
abilElementalVoid.MagicDPS = { 45, 75, 105 }; -- Average DPS
abilElementalVoid.Debuff = 'State_Tempest_Ability4_Pull';
hero:AddAbility(abilElementalVoid);

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;