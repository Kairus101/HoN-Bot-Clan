local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- HERO NAME
local hero = HeroInfo.Create('Hero_TYPENAME');
hero.Threat = 2;

do -- First Ability Name
	local abil = AbilityInfo.Create(0, 'Ability_TYPENAME1');
	abil.Threat = 2;
	abil.IsSingleTarget = true;
	abil.CanSlow = true;
	abil.MagicDPS = { 4, 8, 12, 16 };
	abil.Debuff = 'State_Arachna_Ability1';
	hero:AddAbility(abil);
end

do -- Second Ability Name
	local abil = AbilityInfo.Create(1, 'Ability_TYPENAME2');
	abil.Threat = 0;
	hero:AddAbility(abil);
end

do -- Third Ability Name
	local abil = AbilityInfo.Create(2, 'Ability_TYPENAME3');
	abil.Threat = 0; -- The threat for this ability is automatically calculated by the DPS threat
	abil.Buff = 'State_Arachna_Ability3';
	hero:AddAbility(abil);
end

do -- Ultimate Name
	local abil = AbilityInfo.Create(3, 'Ability_TYPENAME4');
	abil.Threat = 2;
	abil.ShouldPort = true;
	abil.PhysicalDPS = { 75, 150, 225 }; -- total damage / 5 seconds
	abil.Debuff = 'State_Arachna_Ability4';
	abil.DebuffDuration = 5000; -- assume 5 seconds, may be longer
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!REMOVE EVERYTHING FROM THIS LINE AND BELOW FROM ACTUAL HEROINFO FILES!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Don't copy the comments for the abilities, they should only exist in the AbilityInfo class and in this template.
-- You can always look at existing hero info files for examples.
-- The sum threat of a hero + abilities should generally always be 6. There are a few exceptions to this rule, such as Armadon (5 - increases per stack of spine burst), Behemoth (7 - only with ult) and Tempest (10 - only with ult).
--[[
Available properties:
]]
-- Whether the ability is a single target ability or an AoE. 
abil.IsSingleTarget = false;

-- Whether the ability can only be cast on self. Things like Scout's Vanish or Accursed's ult count as such.
class.CanCastOnSelf = false;
-- Whether the ability can be used on friendly heroes.
class.CanCastOnFriendlies = false;
-- Whether the ability can be used on hostile heroes. Should not be used for auras such as Accursed's Sear.
class.CanCastOnHostiles = false;

-- Whether the ability can stun.
abil.CanStun = false;
-- Whether the ability can interrupt anyone.
abil.CanInterrupt = false;
-- Wether the ability can interrupt someone that is magic immune (physical interrupt).
abil.CanInterruptMagicImmune = false;
-- Whether the ability can slow.
abil.CanSlow = false;
-- Whether the ability can root.
abil.CanRoot = false;
-- Whether the ability can disarm.
abil.CanDisarm = false;
-- Whether the ability can make a hero invisible.
abil.CanTurnInvisible = false;
-- Whether the ability would reveal invisible targets.
abil.CanReveal = false;

-- The duration of a stun.
abil.StunDuration = 0; -- MS

-- Whether the bot may want to spread (e.g. Ult from Tempest). This is completely suggestive and may be ignored.
abil.ShouldSpread = false;
-- Whether the bot may want to try to interrupt this ability (e.g. Ult from Tempest). This is completely suggestive and may be ignored.
abil.ShouldInterrupt = false;
-- Whether the bot may want to break free from an ability (e.g. Root from Keeper). This is completely suggestive and may be ignored.
abil.ShouldBreakFree = false;
-- Whether the bot may want to port out (e.g. Ult from Arachna or Blood Hunter). This is completely suggestive and may be ignored.
abil.ShouldPort = false;

-- A negative value is considered a percentage.
-- Can also provide a function to calculate the damage (first parameter passed must be ability level, second must be the unit affected)
-- The amount of INSTANT magic damage this does.
abil.MagicDamage = 0;
-- The amount of magic damage PER SECOND this does.
abil.MagicDPS = 0;
-- The amount of INSTANT physical damage this does.
abil.PhysicalDamage = 0;
-- The amount of physical damage PER SECOND this does.
abil.PhysicalDPS = 0;

-- What buff the caster gains.
abil.Buff = nil; -- e.g. abil.Buff = 'State_Aluna_Ability4'
-- For how long the caster gains this buff.
abil.BuffDuration = 0;
-- What debuff the target gets.
abil.Debuff = nil; -- e.g. abil.Debuff = 'State_Andromeda_Ability2'
-- The duration of said debuff.
abil.DebuffDuration = 0;

