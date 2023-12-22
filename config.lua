Config = {}

-- Check if your language is in locales.lua
Config.Locales = "en"
Language = Lang[Config.Locales]

Config.MoneyOperator = "$"

Config.DeimpoundCost = 800

-- If a vehicles is in the "a" garage, you can find it only in that garage
Config.DifferentiateGarage = true

-- Control to open interact with blips
Config.Open = 38 -- E

--[[
    spirte: https://docs.fivem.net/docs/game-references/blips/
    display: https://docs.fivem.net/natives/?_0x9029B2F3DA924928
    scale: 0 - 1
    color: https://docs.fivem.net/docs/game-references/blips/#blip-colors
    range: https://docs.fivem.net/natives/?_0xBE8BE4FE60E27B72
]]
Config.Blip = {
    ["garage"] = {
        sprite      = 357,
        display     = 4,
        scale       = 0.6,
        color       = 3,
        shortRange  = true,
        name        = "Garage"
    },
    ["impound"] = {
        sprite      = 357,
        display     = 4,
        scale       = 0.6,
        color       = 5,
        shortRange  = true,
        name        = "Impound"
    }
}


Config.Garages = {
    ["a"] = {
        position    = vec3(-2050.3586, 3060.2180, 32.8103),
        deposit     = vec3(-2043.2585, 3065.1572, 32.8103),
        spawn       = {
            vec3(-2043.2585, 3065.1572, 32.8103),
            vec3(-2041.0353, 3057.2329, 32.8104)
        },
        distance    = 3,
        heading     = 100.0,
    }
}

Config.Impounds = {
    ["a"] = {
        position    = vec3(-2057.3008, 3046.5288, 32.8559),
        spawn       = {
            vec3(-2069.7090, 3047.0349, 32.8103)
        },
        distance    = 3,
        heading     = 100.0
    }
}

Config.Menu = {
    ["open-garage"] = {
        id          = "Vehicles",
        title       = "Garage",
        position    = "top-right"
    }
}

--[[
    0: outside
    1: parked
    2: impound
]]

Config.Groups = {
    "admin"
}

Config.GiveCarCommand = "givecar" -- if false or "" you disable it
Config.DelCarCommand = "delcar" -- if false or "" you disable it
Config.ImpoundCarCommand = "impound" -- if false or "" you disable it
Config.DeImpoundCarCommand = "deimpound" -- if false or "" you disable it