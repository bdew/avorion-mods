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
-- namespace DefensiveTurretMerchant
DefensiveTurretMerchant = {}
DefensiveTurretMerchant = ShopAPI.CreateNamespace()
DefensiveTurretMerchant.interactionThreshold = -30000

local function getValidItems(x, y)
    return ValidTurretItem(x, y, WeaponTypes.defensiveTypes)
end

function DefensiveTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, DefensiveTurretMerchant.interactionThreshold)
end

function DefensiveTurretMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local turrets = GenerateShopTurrets(x, y, getValidItems(x, y))
    for _, pair in pairs(turrets) do
        DefensiveTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

function DefensiveTurretMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local specialOfferTurret = GenerateSpecialShopTurrets(x, y, getValidItems(x, y))
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
