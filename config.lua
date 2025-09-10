Config = {}

-- Scam Types
Config.ScamTypes = {
    {
        name = "Smooth Easy Scam",
        description = "Offer a fake item for cash.",
        successChance = 70,
        reward = {money = {min = 50, max = 350}}
    },
       {
        name = "Life Insurance Scam",
        description = "Life insurance service that never happens.",
        successChance = 50,
        reward = {money = {min = 1000, max = 20000}}
    }
}

-- Cooldowns
Config.ScamCooldown = 120 -- seconds
Config.MaxDistance = 3.0  -- meters

-- Risk Settings (on failure)
Config.ScamRisk = {
    [1] = { policeChance = 20, attackChance = 10 }, -- Direct Scam
    [2] = { policeChance = 25, attackChance = 15 }, -- Trade Scam
    [3] = { policeChance = 40, attackChance = 20 }  -- Service Scam
}

-- Police blip settings
Config.BlipDuration = 60   -- seconds
Config.BlipColor = 1       -- red
Config.BlipRadius = 100.0  -- meters
