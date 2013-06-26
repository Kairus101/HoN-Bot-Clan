local _G = getfenv(0)

require('/bots/Libraries/LibHeroData/Classes/HeroInfo.class.lua');
require('/bots/Libraries/LibHeroData/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Rally
local hero = HeroInfo.Create('Hero_Rally');
hero.Threat = 2;

do -- Compel
	local abil = AbilityInfo.Create(0, 'Ability_Rally1');
	abil.Threat = 2;
	abil.TargetType = 'VectorEntity'; -- not_rooted_willing_ally_heroes
	abil.CastEffectType = 'Magic';
	-- Cast on self/friendlies, hurts hostiles
	abil.CanCastOnSelf = true;
	abil.CanCastOnFriendlies = true;
	abil.CanStun = true; -- magic stun even though the damage is physical
	abil.CanInterrupt = true;
	abil.CanDispositionSelf = true;
	abil.CanDispositionFriendlies = true;
	abil.StunDuration = { 1250, 1500, 1750, 2000 };
	abil.PhysicalDamage = { 70, 130, 190, 250 };
	hero:AddAbility(abil);
end

do -- Demoralizing Roar
	local abil = AbilityInfo.Create(1, 'Ability_Rally2');
	abil.Threat = 0;
	abil.TargetType = 'Self';
	abil.CanCastOnHostiles = true;
	abil.CanSlow = true;
	abil.PhysicalDamage = { 40, 80, 120, 160 };
	abil.Debuff = { 'State_Rally_Ability2_Active_b', 'State_Rally_Ability2_Active_b_Alt', 'State_Rally_Ability2_Active_b_Alt2', 'State_Rally_Ability2_Active_b_Alt4' }; -- each avatar has it's own debuff due to a recolor
	abil.DebuffDuration = 3000;
	hero:AddAbility(abil);
end

do -- Battle Experience
	local abil = AbilityInfo.Create(2, 'Ability_Rally3');
	abil.Threat = 0; -- The threat for this ability is automatically calculated by the DPS threat
	abil.TargetType = 'Passive';
	hero:AddAbility(abil);
end

do -- Seismic Slam
	local abil = AbilityInfo.Create(3, 'Ability_Rally4');
	abil.Threat = 4; -- pretty damaging - we should stay out of range of this one
	abil.TargetType = 'TargetPosition';
	abil.CastEffectType = 'Physical';
	abil.CanCastOnHostiles = true;
	abil.PhysicalDamage = { 400, 650, 900 };
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.LibHeroData = _G.HoNBots.LibHeroData or {};
_G.HoNBots.LibHeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
