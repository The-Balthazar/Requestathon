--------------------------------------------------------------------------------
-- Hook File: /lua/system/blueprints.lua
--------------------------------------------------------------------------------
-- Modded By: Balthazar
--------------------------------------------------------------------------------
do

local OldModBlueprints = ModBlueprints

function ModBlueprints(all_blueprints)         
    OldModBlueprints(all_blueprints)
    
    HarglebarbleNorepair(all_blueprints.Unit)
end

--------------------------------------------------------------------------------
-- ALL ABOARD THE STEALTH TRAIN BABY
--------------------------------------------------------------------------------

function HarglebarbleNorepair(all_bps)
    all_bps['ual0303'].General.CommandCaps.RULEUCC_Repair = false
    all_bps['ual0303'].General.CommandCaps.RULEUCC_Reclaim = false
    all_bps['ual0303'].Economy.BuildRate = nil
    table.removeByValue(all_bps['ual0303'].Display.Abilities,'<LOC ability_reclaim>Reclaims')
    table.removeByValue(all_bps['ual0303'].Display.Abilities,'<LOC ability_repairs>Repairs')
    all_bps['ual0303'].General.UnitName = '<LOC val0303_name>Harbinger Mark III'
end

end