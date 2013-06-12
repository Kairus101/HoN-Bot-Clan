local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Keeper of the Forest
local hero = HeroInfo.Create('Hero_Treant');
hero.Threat = 2;

-- Nature's Veil
local abilNaturesVeil = AbilityInfo.Create(0, 'Ability_Treant1');
abilNaturesVeil.Threat = 0;
abilNaturesVeil.IsSingleTarget = true;
abilNaturesVeil.CanInvisSelf = true;
abilNaturesVeil.CanInvisOther = true;
abilNaturesVeil.Buff = 'State_Treant_Ability1';
hero:AddAbility(abilNaturesVeil);

-- Animate Forest
local abilAnimateForest = AbilityInfo.Create(1, 'Ability_Treant2');
abilAnimateForest.Threat = 0; -- Threat from this is automatically calculated by the CreepAggroUtility
abilAnimateForest.IsSingleTarget = true;
hero:AddAbility(abilAnimateForest);

-- Entmoot
local abilEntmoot = AbilityInfo.Create(2, 'Ability_Treant3');
abilEntmoot.Threat = 0;
abilEntmoot.Buff = 'State_Treant_Ability3';
hero:AddAbility(abilEntmoot);

-- Root
local abilRoot = AbilityInfo.Create(3, 'Ability_Treant4');
abilRoot.Threat = 6; -- Bonus threat! Keeper ult is one of the strongest ingame. Be careful!
abilRoot.CanInterrupt = true;
abilRoot.CanInterruptMagicImmune = true;
abilRoot.CanRoot = true;
abilRoot.CanReveal = true;
abilRoot.CanDisarm = true;
abilRoot.ShouldSpread = true;
abilRoot.ShouldBreakFree = true;
abilRoot.MagicDPS = 100;
abilRoot.Debuff = 'State_Treant_Ability4';
abilRoot.DebuffDuration = { 2000, 3000, 4000 };
hero:AddAbility(abilRoot);

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;