local SectorTurretGenerator = include ("sectorturretgenerator")

function SalvageCommand:generateItems(amount)
    local items = {}
    local generator = SectorTurretGenerator()

    for i = 1, amount do
        local item = {}

        item.x = random():getInt(self.area.lower.x, self.area.upper.x)
        item.y = random():getInt(self.area.lower.y, self.area.upper.y)
        item.seed = random():createSeed()

        local rarities = generator:getSectorRarityDistribution(x, y)
        item.rarity = selectByWeight(random(), rarities)

        if random():test(0.5) then
            items.turrets = items.turrets or {}
            table.insert(items.turrets, item)
        else
            items.subsystems = items.subsystems or {}
            table.insert(items.subsystems, item)
        end
    end

    return items
end
