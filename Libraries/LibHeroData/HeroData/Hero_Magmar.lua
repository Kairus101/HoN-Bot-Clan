local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Magmus
local hero = HeroInfo.Create('Hero_Magmar');
hero.Threat = 0;

do -- Lava Surge
	local abil = AbilityInfo.Create(0, 'Ability_Magmar1');
	abil.Threat = 3;
	abil.TargetType = 'TargetPosition';
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.StunDuration = 1650;
	abil.MagicDamage = { 100, 160, 220, 280 };
	hero:AddAbility(abil);
end

do -- Steam Bath
	local abil = AbilityInfo.Create(1, 'Ability_Magmar2');
	abil.Threat = 0;
	abil.TargetType = 'Self';
	abil.CanCastOnSelf = true;
	abil.CanTurnInvisible = true;
	abil.MagicDPS = { 20, 40, 60, 80 };
	abil.Buff = 'State_Magmar_Ability2';
	abil.BuffDuration = { 20000, 40000, 60000, 80000 };
	hero:AddAbility(abil);
end

do -- Volcanic Touch
	local abil = AbilityInfo.Create(2, 'Ability_Magmar3');
	abil.Threat = 0;
	abil.TargetType = 'Passive';
	abil.MagicDamage = { 90, 130, 170, 210 };
	hero:AddAbility(abil);
end

do -- Eruption
	local abil = AbilityInfo.Create(3, 'Ability_Magmar4');
	abil.Threat = 3;
	abil.TargetType = 'Self';
	abil.CanCastOnHostiles = true; -- while in reality this is cast on self, it damages heroes around self which counts as an AoE
	abil.ChannelingState = 'State_Magmar_Ability4_SelfCast'; -- this is applied to Magmus while he is channeling - it's not a visible buff though
	abil.CanSlow = true;
	abil.ShouldSpread = true;
	abil.ShouldInterrupt = true;
	abil.MagicDPS = { 377, 359, 349 }; -- total damage / duration
	abil.Debuff = 'State_Magmar_Ability4';
	abil.DebuffDuration = { 1750, 2450, 3150 };
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
