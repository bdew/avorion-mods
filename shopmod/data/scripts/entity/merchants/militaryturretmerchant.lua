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
-- namespace MilitaryTurretMerchant
MilitaryTurretMerchant = {}
MilitaryTurretMerchant = ShopAPI.CreateNamespace()
MilitaryTurretMerchant.interactionThreshold = -30000

local function getValidItems(x, y)
    return ValidTurretItem(x, y, WeaponTypes.armedTypes)
end

function MilitaryTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, MilitaryTurretMerchant.interactionThreshold)
end

function MilitaryTurretMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local turrets = GenerateShopTurrets(x, y, getValidItems(x, y))
    for _, pair in pairs(turrets) do
        MilitaryTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

function MilitaryTurretMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local specialOfferTurret = GenerateSpecialShopTurrets(x, y, getValidItems(x, y))
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
