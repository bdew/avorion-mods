-- this disables the normal equipment dock / merchant stuff and replaces it with my custom shops

local _bdew_original_initialize = TurretMerchant.initialize

function TurretMerchant.initialize()
    local station = Entity()

    -- prevent original initialize from actually initializing the shop, but allow other mods hooking into initialize to run
    TurretMerchant.shop.initialize = function() end 

    _bdew_original_initialize()

    station:addScriptOnce("data/scripts/entity/merchants/civilturretmerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/militaryturretmerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/defensiveturretmerchant.lua")
end

function TurretMerchant.initUI()
    -- dummied out
end
