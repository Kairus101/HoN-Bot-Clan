local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- HERONAME
local hero = HeroInfo.Create('Hero_TYPENAME');
hero.Threat = 2;

do -- FirstAbilityName
	local abil = AbilityInfo.Create(0, 'Ability_TYPENAME1');
	abil.Threat = 2;
	abil.TargetType = 'UNKNOWN'; -- Passive (only for abilities that can NOT be toggled! e.g. Glacius' Chilling Presence), Self (also for abilities that can be toggled, such as Arachna's Aura), AutoCast, TargetUnit, TargetPosition, VectorEntity
	abil.CanCastOnHostiles = true;
	abil.CanSlow = true;
	abil.MagicDPS = { 4, 8, 12, 16 };
	abil.Debuff = 'State_Arachna_Ability1';
	hero:AddAbility(abil);
end

do -- SecondAbilityName
	local abil = AbilityInfo.Create(1, 'Ability_TYPENAME2');
	abil.Threat = 0;
	abil.TargetType = 'UNKNOWN'; -- Passive (only for abilities that can NOT be toggled! e.g. Glacius' Chilling Presence), Self (also for abilities that can be toggled, such as Arachna's Aura), AutoCast, TargetUnit, TargetPosition, VectorEntity
	abil.CanCastOnSelf = true;
	abil.CanCastOnFriendlies = true;
	hero:AddAbility(abil);
end

do -- ThirdAbilityName
	local abil = AbilityInfo.Create(2, 'Ability_TYPENAME3');
	abil.Threat = 0; -- The threat for this ability is automatically calculated by the DPS threat
	abil.TargetType = 'UNKNOWN'; -- Passive (only for abilities that can NOT be toggled! e.g. Glacius' Chilling Presence), Self (also for abilities that can be toggled, such as Arachna's Aura), AutoCast, TargetUnit, TargetPosition, VectorEntity
	abil.Buff = 'State_Arachna_Ability3';
	hero:AddAbility(abil);
end

do -- UltimateName
	local abil = AbilityInfo.Create(3, 'Ability_TYPENAME4');
	abil.Threat = 2;
	abil.TargetType = 'UNKNOWN'; -- Passive (only for abilities that can NOT be toggled! e.g. Glacius' Chilling Presence), Self (also for abilities that can be toggled, such as Arachna's Aura), AutoCast, TargetUnit, TargetPosition, VectorEntity
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

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!REMOVE EVERYTHING FROM THIS LINE AND BELOW FROM ACTUAL HEROINFO FILES!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Don't copy the comments for the abilities, they should only exist in the AbilityInfo class and in this template.
-- You can always look at existing hero info files for examples.
-- The sum threat of a hero + abilities should generally always be 6. There are a few exceptions to this rule, such as Armadon (5 - increases per stack of spine burst), Behemoth (7 - only with ult) and Tempest (10 - only with ult).
--[[
Available properties:
]]
-- Passive (only for abilities that can NOT be toggled! e.g. Glacius' Chilling Presence), Self (also for "Toggle" abilities and "Self Position"), AutoCast, TargetUnit, TargetPosition, VectorEntity
abil.TargetType = 'UNKNOWN';

-- Whether the ability can only be cast on self. Things like Scout's Vanish or Accursed's ult count as such.
abil.CanCastOnSelf = true;
-- Whether the ability can be used on friendly heroes.
abil.CanCastOnFriendlies = true;
-- Whether the ability can be used on hostile heroes. Should not be used for auras such as Accursed's Sear.
abil.CanCastOnHostiles = true;

-- The state that is applied to the hero that is channeling this ability. Only required for abilities that need to be channeled. Not all abilities have a state applied to the hero channeling the ability.
abil.ChannelingState = 'State_Hero_Ability_SelfCast';

-- Whether the ability can stun.
abil.CanStun = true;
-- Whether the ability can interrupt anyone.
abil.CanInterrupt = true;
-- Wether the ability can interrupt someone that is magic immune (physical interrupt).
abil.CanInterruptMagicImmune = true;
-- Whether the ability can slow.
abil.CanSlow = true;
-- Whether the ability can root.
abil.CanRoot = true;
-- Whether the ability can disarm.
abil.CanDisarm = true;
-- Whether the ability can make a hero invisible.
abil.CanTurnInvisible = true;
-- Whether the ability would reveal invisible targets.
abil.CanReveal = true;
-- Whether the ability can change the position of your own hero. e.g. Andro swap, Magebane Blink, Chronos Time Leap, Pharaoh ult, DR ult
abil.CanDispositionSelf = true;
-- Whether the ability can change the position of a friendly hero. e.g. Andro swap, devo hook
abil.CanDispositionFriendlies = true;
-- Whether the ability can change the position of a hostile hero. e.g. Andro swap, devo hook, prisoner ball and chain
abil.CanDispositionHostiles = true;

-- The duration of a stun.
abil.StunDuration = 1000; -- MS

-- Whether the bot may want to spread (e.g. Ult from Tempest).
abil.ShouldSpread = true;
-- Whether the bot may want to try to interrupt this ability (e.g. Ult from Tempest).
abil.ShouldInterrupt = true;
-- Whether the bot may want to break free from an ability (e.g. Root from Keeper).
abil.ShouldBreakFree = true;
-- Whether the bot may want to port out (e.g. Ult from Arachna or Blood Hunter).
abil.ShouldPort = true;
-- Whether the bot should avoid damage (e.g. Cursed Ground).
abil.ShouldAvoidDamage = true;

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

-- Buff/Debuff properties do NOT hold buffs per level, but instead all possible buffs. Some alts have different state names that do the exact same.
-- What buff the caster gains.
abil.Buff = 'State_Name_Here_Buff'; -- e.g. abil.Buff = 'State_Aluna_Ability4'
-- For how long the caster gains this buff.
abil.BuffDuration = 2000;
-- What debuff the target gets.
abil.Debuff = 'State_Name_Here_Debuff'; -- e.g. abil.Debuff = 'State_Andromeda_Ability2'
-- The duration of said debuff.
abil.DebuffDuration = 2000;

