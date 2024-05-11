include("galaxy")
include("utility")
include("randomext")
include("weapontype")

local SectorTurretGenerator = include("sectorturretgenerator")
local UpgradeGenerator = include("upgradegenerator")

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

UpgradeSystemType = {}
UpgradeSystemType.Military = 1
UpgradeSystemType.Civilian = 2
UpgradeSystemType.Misc = 3

local upgradeSystems = {}

upgradeSystems["data/scripts/systems/militarytcs.lua"] = UpgradeSystemType.Military
upgradeSystems["data/scripts/systems/arbitrarytcs.lua"] = UpgradeSystemType.Military
upgradeSystems["data/scripts/systems/autotcs.lua"] = UpgradeSystemType.Military
upgradeSystems["data/scripts/systems/shieldbooster.lua"] = UpgradeSystemType.Military
upgradeSystems["data/scripts/systems/shieldimpenetrator.lua"] = UpgradeSystemType.Military
upgradeSystems["data/scripts/systems/energytoshieldconverter.lua"] = UpgradeSystemType.Military
upgradeSystems["data/scripts/systems/weaknesssystem.lua"] = UpgradeSystemType.Military
upgradeSystems["data/scripts/systems/resistancesystem.lua"] = UpgradeSystemType.Military
upgradeSystems["data/scripts/systems/defensesystem.lua"] = UpgradeSystemType.Military

upgradeSystems["data/scripts/systems/civiltcs.lua"] = UpgradeSystemType.Civilian
upgradeSystems["data/scripts/systems/cargoextension.lua"] = UpgradeSystemType.Civilian
upgradeSystems["data/scripts/systems/energybooster.lua"] = UpgradeSystemType.Civilian
upgradeSystems["data/scripts/systems/enginebooster.lua"] = UpgradeSystemType.Civilian
upgradeSystems["data/scripts/systems/lootrangebooster.lua"] = UpgradeSystemType.Civilian
upgradeSystems["data/scripts/systems/miningsystem.lua"] = UpgradeSystemType.Civilian
upgradeSystems["data/scripts/systems/tradingoverview.lua"] = UpgradeSystemType.Civilian
upgradeSystems["data/scripts/systems/valuablesdetector.lua"] = UpgradeSystemType.Civilian

-- This is not actually used for now - all systems not in the 2 groups above will be classified as misc
upgradeSystems["data/scripts/systems/fightersquadsystem.lua"] = UpgradeSystemType.Misc
upgradeSystems["data/scripts/systems/batterybooster.lua"] = UpgradeSystemType.Misc
upgradeSystems["data/scripts/systems/hyperspacebooster.lua"] = UpgradeSystemType.Misc
upgradeSystems["data/scripts/systems/transportersoftware.lua"] = UpgradeSystemType.Misc
upgradeSystems["data/scripts/systems/velocitybypass.lua"] = UpgradeSystemType.Misc
upgradeSystems["data/scripts/systems/excessvolumebooster.lua"] = UpgradeSystemType.Misc
upgradeSystems["data/scripts/systems/radarbooster.lua"] = UpgradeSystemType.Misc
upgradeSystems["data/scripts/systems/scannerbooster.lua"] = UpgradeSystemType.Misc

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

function UpgradeCompare(a, b)
    local sa = a.upgrade;
    local sb = b.upgrade;

    if sa.rarity.value == sb.rarity.value then
        if sa.script == sb.script then
            return sa.price > sb.price
        else
            return sa.script < sb.script
        end
    end

    return sa.rarity.value > sb.rarity.value
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

function ValidUpgradeItems(x, y, type)
    local sectorDist2ToCenter = x * x + y * y
    local res = {}
    local generator = UpgradeGenerator()

    for script, parameters in pairs(generator:GetUpgradeScripts()) do
        if (upgradeSystems[script] == type or (type == UpgradeSystemType.Misc and upgradeSystems[script] == nil)) and (not parameters.dist2ToCenter or sectorDist2ToCenter <= parameters.dist2ToCenter) then
            table.insert(res, script)
        end
    end

    return res
end

function SelectShopMaterial(x, y)
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
    local generator = SectorTurretGenerator()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * specialOfferRarityFactors[i]
    end

    generator.rarities = rarities

    local type = getRandomEntry(validItems);
    local material = Balancing_GetHighestAvailableMaterial(x, y)

    return InventoryTurret(generator:generate(x, y, nil, nil, type, Material(material)))
end

function GenerateShopUpgrades(x, y, validItems)
    local systems = {}
    local generator = UpgradeGenerator()
    local rand = random()

    local rarities = generator:getSectorRarityDistribution(x, y)
    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * rarityFactors[i]
    end

    for _, script in pairs(validItems) do
        local pair = {}
        local rarity = Rarity(getValueFromDistribution(rarities, rand))
        local seed = generator:getUpgradeSeed(x, y, script, rarity)
        pair.upgrade = SystemUpgradeTemplate(script, rarity, seed)
        pair.amount = math.floor(math.random(5, 10))
        table.insert(systems, pair)
    end

    while #systems < 13 do
        local pair = {}
        local script = getRandomEntry(validItems);
        local rarity = Rarity(getValueFromDistribution(rarities, rand))
        local seed = generator:getUpgradeSeed(x, y, script, rarity)
        pair.upgrade = SystemUpgradeTemplate(script, rarity, seed)
        pair.amount = math.floor(math.random(5, 10))
        table.insert(systems, pair)
    end

    table.sort(systems, UpgradeCompare)

    return systems
end

function GenerateSpecialShopUpgrades(x, y, validItems)
    local generator = UpgradeGenerator()
    local rand = random()

    local rarities = generator:getSectorRarityDistribution(x, y)
    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * rarityFactors[i]
    end

    local script = getRandomEntry(validItems);
    local rarity = Rarity(getValueFromDistribution(rarities, rand))
    local seed = generator:getUpgradeSeed(x, y, script, rarity)
    return SystemUpgradeTemplate(script, rarity, seed)
end