-- this disables the normal equipment dock / merchant stuff and replaces it with my custom shops

function EquipmentDock.initialize()
    local station = Entity()
    if station.title == "" then
        station.title = "Equipment Dock"%_t
    end

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/sdwhite.png"
    end

    Entity():setValue("remove_permanent_upgrades", true)

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
