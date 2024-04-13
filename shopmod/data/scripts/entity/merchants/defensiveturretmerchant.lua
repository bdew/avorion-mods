package.path = package.path .. ";data/scripts/lib/?.lua"
include("galaxy")
include("utility")
include("randomext")
include("faction")
include("stringutility")
include("weapontype")
local ShopAPI = include("shop")
local SectorTurretGenerator = include("sectorturretgenerator")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace DefensiveTurretMerchant
DefensiveTurretMerchant = {}
DefensiveTurretMerchant = ShopAPI.CreateNamespace()
DefensiveTurretMerchant.interactionThreshold = -30000

DefensiveTurretMerchant.rarityFactors = {}
DefensiveTurretMerchant.rarityFactors[-1] = 0.1
DefensiveTurretMerchant.rarityFactors[0] = 0.25
DefensiveTurretMerchant.rarityFactors[1] = 0.5
DefensiveTurretMerchant.rarityFactors[2] = 1.0
DefensiveTurretMerchant.rarityFactors[3] = 1.0
DefensiveTurretMerchant.rarityFactors[4] = 1.0
DefensiveTurretMerchant.rarityFactors[5] = 1.0

DefensiveTurretMerchant.specialOfferRarityFactors = {}
DefensiveTurretMerchant.specialOfferRarityFactors[-1] = 0.0
DefensiveTurretMerchant.specialOfferRarityFactors[0] = 0.0
DefensiveTurretMerchant.specialOfferRarityFactors[1] = 0.0
DefensiveTurretMerchant.specialOfferRarityFactors[2] = 1.0
DefensiveTurretMerchant.specialOfferRarityFactors[3] = 1.0
DefensiveTurretMerchant.specialOfferRarityFactors[4] = 0.25
DefensiveTurretMerchant.specialOfferRarityFactors[5] = 0.0

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function DefensiveTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, DefensiveTurretMerchant.interactionThreshold)
end

local function comp(a, b)
    local ta = a.turret;
    local tb = b.turret;

    if ta.rarity.value == tb.rarity.value then
        if ta.material.value == tb.material.value then
            return ta.weaponPrefix < tb.weaponPrefix
        else
            return ta.material.value > tb.material.value
        end
    else
        return ta.rarity.value > tb.rarity.value
    end
end

function DefensiveTurretMerchant.shop:addItems()
    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}

    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    generator.rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(generator.rarities) do
        generator.rarities[i] = rarity * DefensiveTurretMerchant.rarityFactors[i] or 1
    end

    for _, type in pairs(WeaponTypes.defensiveTypes) do
        local pair = {}

        local material = Balancing_GetHighestAvailableMaterial(x, y)
        if material > 0 and random():test(0.25) then
            material = material - 1
        end

        pair.turret = InventoryTurret(generator:generate(x, y, nil, nil, type, Material(material)))
        pair.amount = math.floor(math.random(10, 30))

        table.insert(turrets, pair)
    end

    while #turrets < 13 do
        local pair = {}

        local material = Balancing_GetHighestAvailableMaterial(x, y)
        if material > 0 and random():test(0.25) then
            material = material - 1
        end
        
        local type = getRandomEntry(WeaponTypes.defensiveTypes);
        pair.turret = InventoryTurret(generator:generate(x, y, nil, nil, type, Material(material)))
        pair.amount = math.floor(math.random(10, 30))

        table.insert(turrets, pair)
    end

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        DefensiveTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

-- sets the special offer that gets updated every 20 minutes
function DefensiveTurretMerchant.shop:onSpecialOfferSeedChanged()
    local generator = SectorTurretGenerator(DefensiveTurretMerchant.shop:generateSeed())

    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * DefensiveTurretMerchant.specialOfferRarityFactors[i] or 1
    end

    generator.rarities = rarities

    local type = getRandomEntry(WeaponTypes.defensiveTypes);
    local material = Balancing_GetHighestAvailableMaterial(x, y)

    local specialOfferTurret = InventoryTurret(generator:generate(x, y, nil, nil, type, Material(material)))
    DefensiveTurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end

function DefensiveTurretMerchant.initialize()
    local station = Entity()
    DefensiveTurretMerchant.shop:initialize(station.translatedTitle)
end

function DefensiveTurretMerchant.initUI()
    local station = Entity()
    DefensiveTurretMerchant.shop:initUI("Trade Equipment" % _t, station.translatedTitle, "Defensive Turrets" % _t, "data/textures/icons/flak.png")
end
