local originalInitialize = initialize

function initialize()
    local station = Entity()
    originalInitialize()
    station:addScriptOnce("data/scripts/entity/hqrecruit.lua")
end
