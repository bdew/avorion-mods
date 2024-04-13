package.path = package.path .. ";data/scripts/lib/?.lua"

include("galaxy")
include("utility")
include("randomext")
include("faction")
include("stringutility")
include("weapontype")
include("bdewmerchantutils")

local ShopAPI = include("shop")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace CivilTurretMerchant
CivilTurretMerchant = {}
CivilTurretMerchant = ShopAPI.CreateNamespace()
CivilTurretMerchant.interactionThreshold = -30000

local function getValidItems(x, y)
    return ValidTurretItem(x, y, WeaponTypes.unarmedTypes)
end

function CivilTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, CivilTurretMerchant.interactionThreshold)
end

function CivilTurretMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local turrets = GenerateShopTurrets(x, y, getValidItems(x, y))
    for _, pair in pairs(turrets) do
        CivilTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

function CivilTurretMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local specialOfferTurret = GenerateSpecialShopTurrets(x, y, getValidItems(x, y))
    CivilTurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end

function CivilTurretMerchant.initialize()
    local station = Entity()
    CivilTurretMerchant.shop:initialize(station.translatedTitle)
end

function CivilTurretMerchant.initUI()
    local station = Entity()
    CivilTurretMerchant.shop:initUI("Trade Equipment" % _t, station.translatedTitle, "Civillian Turrets" % _t, "data/textures/icons/mining-laser.png")
end
