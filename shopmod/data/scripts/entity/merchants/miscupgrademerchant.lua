package.path = package.path .. ";data/scripts/lib/?.lua"
include ("utility")
include ("randomext")
include ("faction")
include("bdewmerchantutils")
local ShopAPI = include ("shop")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace MiscUpgradeMerchant
MiscUpgradeMerchant = {}
MiscUpgradeMerchant = ShopAPI.CreateNamespace()

local function getValidItems(x, y)
    return ValidUpgradeItems(x, y, UpgradeSystemType.Misc)
end

function MiscUpgradeMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

function MiscUpgradeMerchant.shop:addItems()
    local x, y = Sector():getCoordinates()
    local systems = GenerateShopUpgrades(x, y, getValidItems(x, y))
    for _, pair in pairs(systems) do
        MiscUpgradeMerchant.shop:add(pair.upgrade, pair.amount)
    end
end

function MiscUpgradeMerchant.shop:onSpecialOfferSeedChanged()
    local x, y = Sector():getCoordinates()
    local specialOfferSystem = GenerateSpecialShopUpgrades(x, y, getValidItems(x, y))
    MiscUpgradeMerchant.shop:setSpecialOffer(specialOfferSystem)
end

function MiscUpgradeMerchant.initialize()
    local station = Entity()
    MiscUpgradeMerchant.shop:initialize(station.translatedTitle)
end

function MiscUpgradeMerchant.initUI()
    local station = Entity()
    MiscUpgradeMerchant.shop:initUI("Trade Equipment" % _t, station.translatedTitle, "Misc Upgrades" % _t, "data/textures/icons/patch-notes.png")
end