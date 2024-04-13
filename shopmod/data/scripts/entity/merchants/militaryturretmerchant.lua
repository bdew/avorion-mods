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
-- namespace MilitaryTurretMerchant
MilitaryTurretMerchant = {}
MilitaryTurretMerchant = ShopAPI.CreateNamespace()
MilitaryTurretMerchant.interactionThreshold = -30000

MilitaryTurretMerchant.rarityFactors = {}
MilitaryTurretMerchant.rarityFactors[-1] = 0.1
MilitaryTurretMerchant.rarityFactors[0] = 0.25
MilitaryTurretMerchant.rarityFactors[1] = 0.5
MilitaryTurretMerchant.rarityFactors[2] = 1.0
MilitaryTurretMerchant.rarityFactors[3] = 1.0
MilitaryTurretMerchant.rarityFactors[4] = 1.0
MilitaryTurretMerchant.rarityFactors[5] = 1.0

MilitaryTurretMerchant.specialOfferRarityFactors = {}
MilitaryTurretMerchant.specialOfferRarityFactors[-1] = 0.0
MilitaryTurretMerchant.specialOfferRarityFactors[0] = 0.0
MilitaryTurretMerchant.specialOfferRarityFactors[1] = 0.0
MilitaryTurretMerchant.specialOfferRarityFactors[2] = 1.0
MilitaryTurretMerchant.specialOfferRarityFactors[3] = 1.0
MilitaryTurretMerchant.specialOfferRarityFactors[4] = 0.25
MilitaryTurretMerchant.specialOfferRarityFactors[5] = 0.0

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function MilitaryTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, MilitaryTurretMerchant.interactionThreshold)
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

function MilitaryTurretMerchant.shop:addItems()
    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}

    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    generator.rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(generator.rarities) do
        generator.rarities[i] = rarity * MilitaryTurretMerchant.rarityFactors[i] or 1
    end

    for _, type in pairs(WeaponTypes.armedTypes) do
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
        
        local type = getRandomEntry(WeaponTypes.armedTypes);
        pair.turret = InventoryTurret(generator:generate(x, y, nil, nil, type, Material(material)))
        pair.amount = math.floor(math.random(10, 30))

        table.insert(turrets, pair)
    end

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        MilitaryTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

-- sets the special offer that gets updated every 20 minutes
function MilitaryTurretMerchant.shop:onSpecialOfferSeedChanged()
    local generator = SectorTurretGenerator(MilitaryTurretMerchant.shop:generateSeed())

    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * MilitaryTurretMerchant.specialOfferRarityFactors[i] or 1
    end

    generator.rarities = rarities

    local type = getRandomEntry(WeaponTypes.armedTypes);
    local material = Balancing_GetHighestAvailableMaterial(x, y)

    local specialOfferTurret = InventoryTurret(generator:generate(x, y, nil, nil, type, Material(material)))
    MilitaryTurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end

function MilitaryTurretMerchant.initialize()
    local station = Entity()
    MilitaryTurretMerchant.shop:initialize(station.translatedTitle)
end

function MilitaryTurretMerchant.initUI()
    local station = Entity()
    MilitaryTurretMerchant.shop:initUI("Trade Equipment" % _t, station.translatedTitle, "Military Turrets" % _t, "data/textures/icons/chaingun.png")
end
