local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Keeper of the Forest (8)
local hero = HeroInfo.Create('Hero_Treant');
hero.Threat = 2;

do -- Nature's Veil
	local abil = AbilityInfo.Create(0, 'Ability_Treant1');
	abil.Threat = 0;
	abil.IsSingleTarget = true;
	abil.CanCastOnSelf = true;
	abil.CanCastOnFriendlies = true;
	abil.CanInvisSelf = true;
	abil.CanInvisOther = true;
	abil.Buff = 'State_Treant_Ability1';
	hero:AddAbility(abil);
end

do -- Animate Forest
	local abil = AbilityInfo.Create(1, 'Ability_Treant2');
	abil.Threat = 0; -- Threat from this is automatically calculated by the CreepAggroUtility
	abil.IsSingleTarget = true;
	hero:AddAbility(abil);
end

do -- Entmoot
	local abil = AbilityInfo.Create(2, 'Ability_Treant3');
	abil.Threat = 0; -- Threat from this is automatically calculated by the DPS threat
	abil.Buff = 'State_Treant_Ability3';
	hero:AddAbility(abil);
end

do -- Root
	local abil = AbilityInfo.Create(3, 'Ability_Treant4');
	abil.Threat = 6; -- Bonus threat! Keeper ult is one of the strongest ingame. Be careful!
	abil.CanCastOnHostiles = true;
	abil.CanInterrupt = true;
	abil.CanInterruptMagicImmune = true;
	abil.CanRoot = true;
	abil.CanReveal = true;
	abil.CanDisarm = true;
	abil.ShouldSpread = true;
	abil.ShouldBreakFree = true;
	abil.MagicDPS = 100;
	abil.Debuff = 'State_Treant_Ability4';
	abil.DebuffDuration = { 2000, 3000, 4000 };
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
