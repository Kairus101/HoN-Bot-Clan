local _G = getfenv(0)

require('/bots/Classes/HeroInfo.class.lua');
require('/bots/Classes/AbilityInfo.class.lua');

local classes = _G.HoNBots.Classes;
local HeroInfo, AbilityInfo = classes.HeroInfo, classes.AbilityInfo;

-- Voodoo Jester
local hero = HeroInfo.Create('Hero_Voodoo');
hero.Threat = 0;

do -- Acid Cocktail
	local abil = AbilityInfo.Create(0, 'Ability_Voodoo1');
	abil.Threat = 2;
	abil.IsSingleTarget = true;
	abil.CanCastOnHostiles = true;
	abil.CanStun = true;
	abil.CanInterrupt = true;
	abil.StunDuration = 1500;
	abil.Debuff = 'State_Stunned';
	abil.DebuffDuration = 1500;
	hero:AddAbility(abil);
end

do -- Mojo
	local abil = AbilityInfo.Create(1, 'Ability_Voodoo2');
	abil.Threat = 0;
	abil.CanCastOnSelf = true;
	abil.CanCastOnFriendlies = true;
	abil.CanCastOnHostiles = true;
	abil.MagicDPS = { 10, 20, 30, 40 };
	abil.Buff = 'State_Voodoo_Ability2_Buff';
	abil.BuffDuration = 8000;
	abil.Debuff = 'State_Voodoo_Ability2_Debuff';
	abil.DebuffDuration = 8000;
	hero:AddAbility(abil);
end

do -- Cursed Ground
	local abil = AbilityInfo.Create(2, 'Ability_Voodoo3');
	abil.Threat = 4;
	abil.CanCastOnHostiles = true;
	abil.MagicDPS = function (nLevel, unitTarget)
		local nDPS = nLevel * 5; -- each level increases DPS by a static 5 magic DPS
		
		return nDPS + (nLevel * 0.1 * (unitTarget:GetMaxHealth() - unitTarget:GetHealth()); -- not 100% accurate, but ought to do
	end;
	abil.ShouldAvoidDamage = true;
	abil.Debuff = 'State_Voodoo_Ability3';
	abil.DebuffDuration = 12000;
	hero:AddAbility(abil);
end

do -- Spirit Ward
	local abil = AbilityInfo.Create(3, 'Ability_Voodoo4');
	abil.Threat = 2;
	abil.CanCastOnHostiles = true;
	abil.ShouldInterrupt = true;
	abil.PhysicalDPS = { 200, 300, 400 };
	hero:AddAbility(abil);
end

-- Because runfile doesn't return the return value of an executed file, we have to use this workaround:
_G.HoNBots = _G.HoNBots or {};
_G.HoNBots.HeroData = _G.HoNBots.HeroData or {};
_G.HoNBots.HeroData[hero:GetTypeName()] = hero;

-- It would be prettier if we could just get the return value from runfile;
return hero;
