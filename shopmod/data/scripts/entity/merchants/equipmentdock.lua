-- this disables the normal equipment dock / merchant stuff and replaces it with my custom shops

local _bdew_original_initialize = EquipmentDock.initialize

function EquipmentDock.initialize()
    local station = Entity()

    -- prevent original initialize from actually initializing the shop, but allow other mods hooking into initialize to run
    EquipmentDock.shop.initialize = function() end

    _bdew_original_initialize()

    station:addScriptOnce("data/scripts/entity/merchants/civilypgrademerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/militaryupgrademerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/miscupgrademerchant.lua")
end

function EquipmentDock.initUI()
    -- dummied out
end

-- Those are passed out to misc upgrade shop so that special items like XSTN-K IV can still be sold

function EquipmentDock.setSpecialOffer(item_in, amount)
    local station = Entity()
    station:invokeFunction("miscupgrademerchant", "setSpecialOffer", item_in, amount)
end

function EquipmentDock.setStaticSeed(value)
    local station = Entity()
    station:invokeFunction("miscupgrademerchant", "setStaticSeed", value)
end
