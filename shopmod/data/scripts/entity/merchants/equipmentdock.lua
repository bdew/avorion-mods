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

    
end


function EquipmentDock.initUI()
    -- dummied out
end

