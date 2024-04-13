include("galaxy")
include("utility")
include("randomext")
include("weapontype")

local SectorTurretGenerator = include("sectorturretgenerator")

local rarityFactors = {}
rarityFactors[-1] = 0.1
rarityFactors[0] = 0.25
rarityFactors[1] = 0.5
rarityFactors[2] = 1.0
rarityFactors[3] = 1.0
rarityFactors[4] = 1.0
rarityFactors[5] = 1.0

local specialOfferRarityFactors = {}
specialOfferRarityFactors[-1] = 0.0
specialOfferRarityFactors[0] = 0.0
specialOfferRarityFactors[1] = 0.0
specialOfferRarityFactors[2] = 1.0
specialOfferRarityFactors[3] = 1.0
specialOfferRarityFactors[4] = 0.25
specialOfferRarityFactors[5] = 0.0

function TurretCompare(a, b)
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

function ValidTurretItem(x, y, list)
    local res = {}
    local weaponProbabilities = GetWeaponProbabilities()
    local distFromCenter = length(vec2(x, y)) / Balancing_GetMaxCoordinates()

    for _, type in pairs(list) do
        local specs = weaponProbabilities[type];
        if not specs.d or distFromCenter < specs.d then
            table.insert(res, type)
        else
        end
    end

    return res
end

local function SelectShopMaterial(x, y)
    local material = Balancing_GetHighestAvailableMaterial(x, y)
    if material > 0 and random():test(0.25) then
        material = material - 1
    end
    return Material(material)
end

function GenerateShopTurrets(x, y, validItems)
    local turrets = {}

    local generator = SectorTurretGenerator()
    generator.rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(generator.rarities) do
        generator.rarities[i] = rarity * rarityFactors[i]
    end

    for _, type in pairs(validItems) do
        local pair = {}
        pair.turret = InventoryTurret(generator:generate(x, y, nil, nil, type, SelectShopMaterial(x, y)))
        pair.amount = math.floor(math.random(10, 30))
        table.insert(turrets, pair)
    end

    while #turrets < 13 do
        local pair = {}
        local type = getRandomEntry(validItems);
        pair.turret = InventoryTurret(generator:generate(x, y, nil, nil, type, SelectShopMaterial(x, y)))
        pair.amount = math.floor(math.random(10, 30))
        table.insert(turrets, pair)
    end

    table.sort(turrets, TurretCompare)
    return turrets;
end

function GenerateSpecialShopTurrets(x, y, validItems)
    local generator = SectorTurretGenerator(MilitaryTurretMerchant.shop:generateSeed())
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * specialOfferRarityFactors[i]
    end

    generator.rarities = rarities

    local type = getRandomEntry(validItems);
    local material = Balancing_GetHighestAvailableMaterial(x, y)

    return InventoryTurret(generator:generate(x, y, nil, nil, type, Material(material)))
end
