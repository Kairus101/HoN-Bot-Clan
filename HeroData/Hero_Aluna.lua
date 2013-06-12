local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Aluna
local hero = HeroInfo.Create('Hero_Aluna');
hero.Threat = 1;

-- Emerald Lightning
local abilEmeraldLightning = AbilityInfo.Create(0, 'Ability_Aluna1');
abilEmeraldLightning.Threat = 2;
abilEmeraldLightning.IsSingleTarget = true;
abilEmeraldLightning.CanStun = true;
abilEmeraldLightning.StunDuration = 1000; -- MS
abilEmeraldLightning.CanInterrupt = true;
abilEmeraldLightning.MagicDamage = { 100, 150, 200, 250 };
--abilEmeraldLightning.Buff = 'State_Aluna_Ability1_Self'; -- not relevant, threat is already calculated by DPS threat
abilEmeraldLightning.Debuff = 'State_Aluna_Ability1_Enemy';
hero:AddAbility(abilEmeraldLightning);

-- Power Throw
local abilPowerThrow = AbilityInfo.Create(1, 'Ability_Aluna2');
abilPowerThrow.Threat = 1;
abilPowerThrow.MagicDamage = { 140, 210, 280, 350 };
hero:AddAbility(abilPowerThrow);

-- Deja Vu
local abilDejaVu = AbilityInfo.Create(2, 'Ability_Aluna3');
abilDejaVu.Threat = 1; -- The threat for this ability is automatically calculated by the DPS threat
abilDejaVu.Buff = 'State_Aluna_Ability3';
hero:AddAbility(abilDejaVu);

-- Emerald Red
local abilEmeraldRed = AbilityInfo.Create(3, 'Ability_Aluna4');
abilEmeraldRed.Threat = 1;
abilEmeraldRed.Buff = 'State_Aluna_Ability4';
hero:AddAbility(abilEmeraldRed);

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
