function SectorTurretGenerator:getSectorRarityDistribution(x, y)
    local rarities = self:getDefaultRarityDistribution()

    local f = length(vec2(x, y)) / (Balancing_GetDimensions() / 2) -- 0 (center) to 1 (edge) to ~1.5 (corner)

    rarities[-1] = math.max(0, -10 + f * 32)                       -- 22 at edge, 0 beyond the barrier
    rarities[0] = math.max(0, 1 + f * 63)                          -- 64 at edge, 1 in center
    rarities[1] = math.max(0, 10 + f * 22)                         -- 32 at edge, 10 in center

    rarities[-1] = lerp(f, 0.70, 1.5, 0, rarities[-1])
    rarities[0] = lerp(f, 0.40, 0.80, 0, rarities[0])
    rarities[1] = lerp(f, 0.10, 0.50, 0, rarities[1])
    rarities[5] = rarities[5] + lerp(f, 0, 0.3, 0.5 * rarities[4], 0)

    return rarities
end
