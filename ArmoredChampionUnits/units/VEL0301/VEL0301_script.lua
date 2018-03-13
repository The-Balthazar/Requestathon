local Shield = import('/lua/shield.lua').Shield
local EffectUtil = import('/lua/EffectUtilities.lua')
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local TWeapons = import('/lua/terranweapons.lua')
local TDFHeavyPlasmaCannonWeapon = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGeneratorCom --TWeapons.TDFHeavyPlasmaCannonWeapon
local TIFCommanderDeathWeapon = {}
local IsFAF = false

if string.sub(GetVersion(),1,3) == '1.5' and tonumber(string.sub(GetVersion(),5)) > 3603 then
    TIFCommanderDeathWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon
    IsFAF = true
else
    TIFCommanderDeathWeapon = TWeapons.TIFCommanderDeathWeapon
end

UEL0301 = Class(TWalkingLandUnit) {

    IntelEffects = {
		{
			Bones = {
				'Jetpack',
			},
			Scale = 0.5,
			Type = 'Jammer01',
		},
    },

    Weapons = {
        RightHeavyPlasmaCannon = Class(TDFHeavyPlasmaCannonWeapon) {
            IdleState = State(TDFHeavyPlasmaCannonWeapon.IdleState) {
                 Main = function(self)
                    if self.RotatorManip then
                        self.RotatorManip:SetSpeed(0)
                    end
                    if self.SliderManip then
                        self.SliderManip:SetGoal(0,0,0)
                        self.SliderManip:SetSpeed(2)
                    end
                    TDFHeavyPlasmaCannonWeapon.IdleState.Main(self)
                end,
            },

            CreateProjectileAtMuzzle = function(self, muzzle)
                if not self.SliderManip then
                    self.SliderManip = CreateSlider(self.unit, 'Center_Turret_Barrel')
                    self.unit.Trash:Add(self.SliderManip)
                end
                if not self.RotatorManip then
                    self.RotatorManip = CreateRotator(self.unit, 'Center_Turret_Barrel', 'z')
                    self.unit.Trash:Add(self.RotatorManip)
                end
                self.RotatorManip:SetSpeed(180)
                self.SliderManip:SetPrecedence(11)
                self.SliderManip:SetGoal(0, 0, -1)
                self.SliderManip:SetSpeed(-1)
                TDFHeavyPlasmaCannonWeapon.CreateProjectileAtMuzzle(self, muzzle)
            end,

            PlayFxWeaponUnpackSequence = function( self )
                self.unit.BodyRotators[1]:SetGoal(0)
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self)
            end,

            PlayFxWeaponPackSequence = function(self)
                self.unit.BodyRotators[1]:SetGoal(45)
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,
        },

        DeathWeapon = Class(TIFCommanderDeathWeapon) {
        },
    },

    OnCreate = function(self)
        TWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        --self:HideBone('Jetpack', true)
        --self:HideBone('SAM', true)
        self:SetupBuildBones()
        AddBuildRestriction(self:GetArmy(), categories[self:GetBlueprint().BlueprintId] )
        self.BodyRotators = {
            CreateRotator(self, 'TorsoB', 'y'),
            CreateRotator(self, 'Head', 'y'),
        }
        self.BodyRotators[1]:SetGoal(45)
        self.BodyRotators[1]:SetSpeed(90)
        self:SetCustomName(LOC(self:GetBlueprint().General.UnitName) )
        if not IsFAF then
            self:AddKills(math.random(50,75) )
        end
        --self.BodyRotators[2]:SetGoal(-45)
        --self.BodyRotators[2]:SetSpeed(90)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        TWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
        self:DisableUnitIntel('Jammer')
    end,

    OnDamage = function(self, instigator, amount, vector, damageType)
        --LOG(repr(vector))

        TWalkingLandUnit.OnDamage(self, instigator, amount, vector, damageType)
    end,

    OnKilled = function(self, instigator, type, overKillRatio)
        --Allow another if it was never finished.
        if self:GetFractionComplete() < 1 then
            RemoveBuildRestriction(self:GetArmy(), categories[self:GetBlueprint().BlueprintId] )
        end
        TWalkingLandUnit.OnKilled(self, instigator, type, overKillRatio)
    end,

    OnDestroy = function(self)
        --Allow another if it was never finished.
        if self:GetFractionComplete() < 1 then
            RemoveBuildRestriction(self:GetArmy(), categories[self:GetBlueprint().BlueprintId] )
        end
        TWalkingLandUnit.OnDestroy(self)
    end,

    OnIntelEnabled = function(self)
        TWalkingLandUnit.OnIntelEnabled(self)
        if self.RadarJammerEnh and self:IsIntelEnabled('Jammer') then
            if self.IntelEffects then
		        self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
	        end
	        self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['RadarJammer'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
        end
    end,

    OnIntelDisabled = function(self)
        TWalkingLandUnit.OnIntelDisabled(self)
        if self.RadarJammerEnh and not self:IsIntelEnabled('Jammer') then
            self:SetMaintenanceConsumptionInactive()
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
            end
        end
    end,

    OnPaused = function(self)
        TWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end
    end,

    OnUnpaused = function(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        TWalkingLandUnit.OnUnpaused(self)
    end,
}

TypeClass = UEL0301
