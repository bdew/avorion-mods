-- this disables the normal equipment dock / merchant stuff and replaces it with my custom shops

function TurretMerchant.initialize()
    local station = Entity()
    if station.title == "" then
        station.title = "Turret Merchant"%_t
    end

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/turret.png"
    end

    station:addScriptOnce("data/scripts/entity/merchants/civilturretmerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/militaryturretmerchant.lua")
    station:addScriptOnce("data/scripts/entity/merchants/defensiveturretmerchant.lua")
end

function TurretMerchant.initUI()
    -- dummied out
end
