function UpgradeGenerator:getSectorRarityDistribution(x, y)
    local rarities = self:getDefaultRarityDistribution()

    local f = length(vec2(x, y)) / (Balancing_GetDimensions() / 2) -- 0 (center) to 1 (edge) to ~1.5 (corner)

    -- we need to adjust drop rates for higher-tier upgrades in the outer regions since they don't have a tech level
    rarities[-1] = 4 + f * 20 -- 24 at edge, 4 in center
    rarities[0] = 4 + f * 44  -- 48 at edge, 4 in center
    rarities[1] = 8 + f * 8   -- 16 at edge, 8 in center

    rarities[3] = lerp(f, 0.3, 1.0, rarities[3], rarities[3] * 0.75)
    rarities[4] = lerp(f, 0.3, 1.0, rarities[4], rarities[4] * 0.5)
    rarities[5] = lerp(f, 0.3, 1.0, rarities[5], rarities[5] * 0.25)

    rarities[-1] = lerp(f, 0.70, 1.5, 0, rarities[-1])
    rarities[0] = lerp(f, 0.40, 0.80, 0, rarities[0])
    rarities[1] = lerp(f, 0.10, 0.50, 0, rarities[1])

    rarities[5] = rarities[5] + lerp(f, 0, 0.3, 0.5 * rarities[4], 0)

    return rarities
end

function UpgradeGenerator:getSectorBossLootRarityDistribution(x, y)
    local rarities = self:getBossLootRarityDistribution()
    local d = length(vec2(x, y))

    rarities[4] = lerp(d, 450, 0, rarities[4], rarities[4] * 0.5)   -- exotic: full at the edge, ca 2.5 at 0.0
    rarities[3] = lerp(d, 450, 0, rarities[3], rarities[3] * 0.25)  -- exceptional: full at the edge, ca (1 - 3.5, depending on difficulty) at 0.0
    rarities[2] = lerp(d, 450, 150, rarities[2], rarities[2] * 0.0) -- rare: full at the edge, nothing inside barrier

    rarities[5] = rarities[5] + lerp(d, 0, 95, 0.5 * rarities[4], 0)
    rarities[4] = rarities[4] + lerp(d, 0, 150, 1 * rarities[4], 0)

    print("UpgradeGenerator::getSectorRarityDistribution" .. tostring(x) .. ":" .. tostring(y))

    return rarities
end
