package.path = package.path .. ";data/scripts/lib/?.lua"
include ("utility")
include ("randomext")
include ("faction")
include("bdewmerchantutils")
local ShopAPI = include ("shop")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace MilitaryUpgradeMerchant
MilitaryUpgradeMerchant = {}
MilitaryUpgradeMerchant = ShopAPI.CreateNamespace()

local function getValidItems(x, y)
    return ValidUpgradeItems(x, y, UpgradeSystemType.Military)
end

function MilitaryUpgradeMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

function MilitaryUpgradeMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local systems = GenerateShopUpgrades(x, y, getValidItems(x, y))
    for _, pair in pairs(systems) do
        MilitaryUpgradeMerchant.shop:add(pair.upgrade, pair.amount)
    end
end

function MilitaryUpgradeMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local specialOfferSystem = GenerateSpecialShopUpgrades(x, y, getValidItems(x, y))
    MilitaryUpgradeMerchant.shop:setSpecialOffer(specialOfferSystem)
end

function MilitaryUpgradeMerchant.initialize()
    local station = Entity()
    MilitaryUpgradeMerchant.shop:initialize(station.translatedTitle)
end

function MilitaryUpgradeMerchant.initUI()
    local station = Entity()
    MilitaryUpgradeMerchant.shop:initUI("Trade Equipment" % _t, station.translatedTitle, "Military Upgrades" % _t, "data/textures/icons/shield.png")
end