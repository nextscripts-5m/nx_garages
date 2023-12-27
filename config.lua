Config = {}

--[[
    You can chose between:
        "lib", (0.05 resmon while near the point, else 0.0)
        "3d", (0.05 resmon while near the point, else 0.0)
        "gridsystem" (0.01 resmon, while near the point, else 0.0. ATTENTION! gridsystem will have 0.03-0.04 always while we are near the point)

    NOTE: resmon it's imprtant, yes. But not at all times, remember that we are just fetching vehicles, not fighting nor driving!
            while we are far from the blip the resmon is 0.0
]]
Config.UI = "gridsystem"

-- Marker name in the .ytd file (this makes sense only if Config.UI = "gridsystem")
Config.CustomMarkers = {
    ["open"] = "Open Garage",
    ["deposit"] = "Deposit Garage"
}

Config.StreamFile = "markers_garage" -- .ytd file that is in /stream folder (this makes sense only if Config.UI = "gridsystem")

Config.CustomTextUI = true -- put it to true if you use my own gridsystem, else false (this makes sense only if Config.UI = "gridsystem")

-- this makes sense only if Config.UI = "gridsystem" and Config.CustomTextUI = true
Config.OpenMarker = {
    ["open-garage"] = "TO OPEN THE GARAGE",
    ["open-impound"] = "TO VIEW IMPOUND VEHICLES",
    ["deposit"] = "TO DEPOSIT VEHICLE",
}

Config.DefaultAvatar = "https://cdn.discordapp.com/attachments/1136989226429321357/1161571533999837265/logo2.png?ex=659511ca&is=65829cca&hm=3feda243c701ff05a4521ebecdb7446b189f8d6378a4406f0eeaa1ef59e73fa7&"

-- Check if your language is in locales.lua
Config.Locales = "en"
Language = Lang[Config.Locales]

-- Just string formatting
Config.MoneyOperator = "$"

-- Deimpound cost for de-impounding a vehicle
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

-- Makes sense only if Config.UI = "lib"
Config.TextUI = {
    ["open-garage"] = {
        text        = "[E] - Open Garage",
        position    = "right-center",
        icon        = "hand",
        style       = {
            borderRadius    = 0,
            backgroundColor = '#48BB78',
            color           = 'white'
        }
    },
    ["open-impound"] = {
        text        = "[E] - Open Impound",
        position    = "right-center",
        icon        = "hand",
        style       = {
            borderRadius    = 0,
            backgroundColor = '#48BB78',
            color           = 'white'
        }
    },
    ["deposit-garage"] = {
        text        = "[E] - Deposit Vehicle",
        position    = "right-center",
        icon        = "hand",
        style       = {
            borderRadius    = 0,
            backgroundColor = '#48BB78',
            color           = 'white'
        }
    }
}

Config.Menu = {
    ["open-garage"] = {
        id          = "Vehicles",
        title       = "Garage",
        position    = "top-right"
    },
    ["open-impound"] = {
        id          = "Impounds",
        title       = "Impounded Vehicles",
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