RegisterNetEvent("garages:PreserveVehicles", function ()
    
    local source    = source
    local xPlayer   =  ESX.GetPlayerFromId(source)
    local response  = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ?", {xPlayer.getIdentifier()})

    if #response then
        for i = 1, #response do

            local row       = response[i]
            local stored    = tonumber(row.stored)

            if stored == 0 then
                local plate = row.plate
                MySQL.query.await("UPDATE owned_vehicles SET stored = 1 WHERE plate = ?", {plate})
            end
        end
    end
end)

RegisterNetEvent("garages:spawnVehicle", function (plate)
    DeimpoundVehicle(plate)
end)

ESX.RegisterServerCallback("garages:impoundVehicles", function (source, cb, garageName)

    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)

    if not Utils.checkPlayer(xPlayer) then return end

    local vehicles = FetchImpoundedVehicles(xPlayer.getIdentifier())

    cb(vehicles)
end)

ESX.RegisterServerCallback("garages:garageVehicles", function (source, cb, garageName)

    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)

    if not Utils.checkPlayer(xPlayer) then return end

    local vehicles = FetchGarageVehicles(xPlayer.getIdentifier(), garageName)

    cb(vehicles)
end)

ESX.RegisterServerCallback("validateVehicle", function (source, cb, props, garageName)

    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)

    if not Utils.checkPlayer(xPlayer) then return end

    local valid = IsOwnVehicle(xPlayer.getIdentifier(), props.plate)

    if valid then
        MySQL.query.await("UPDATE owned_vehicles SET garage = ? WHERE plate = ?", {garageName, props.plate})
        MySQL.query.await("UPDATE owned_vehicles SET stored = 1 WHERE plate = ?", {props.plate})
    end

    cb(valid)
end)


RegisterNetEvent("garages:payImpound", function (plate)
    
    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)

    if not Utils.checkPlayer(xPlayer) then return end

    DeimpoundVehicle(plate)

    local cost = Config.DeimpoundCost and Config.DeimpoundCost or 800
    xPlayer.removeAccountMoney("bank", cost)
    xPlayer.showNotification(Language["paid"]:format(Config.MoneyOperator, cost))
end)


-- Commands

ESX.RegisterServerCallback("garages:checkPermissions", function (source, cb)
    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)

    if not Utils.checkPlayer(xPlayer) then
        cb(false)
        -- return
    end

    local myGroup   = xPlayer.getGroup()

    if IsAllowed(myGroup) then
        cb(true)
    end

    cb(false)
end)

FormatPlate = function (plate)
    local newPlate
    newPlate = string.gsub(plate, "-", " ")
    newPlate = string.upper(newPlate)
    return newPlate
end

GenerateRandomPlate = function ()
    local letters = string.char(math.random(65, 65 + 25)) .. string.char(math.random(65, 65 + 25)) .. string.char(math.random(65, 65 + 25))
    local numbers = string.char(math.random(48, 57)) .. string.char(math.random(48, 57)) .. string.char(math.random(48, 57))
    local plate = letters .. " " .. numbers
    if CheckPlate(plate) then
        GenerateRandomPlate()
    end
    return plate
end

CheckPlate = function (plate)
    local response = MySQL.query.await("SELECT * FROM owned_vehicles WHERE plate = ?", {plate})
    return #response > 0
end

RegisterNetEvent("garages:giveCar", function (id, model, plate)

    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)
    local target    = id

    local xTarget   = ESX.GetPlayerFromId(target)

    if not Utils.checkPlayer(xTarget) then
        xPlayer.showNotification(Language["not-online"]:format(target))
        return
    end

    if not plate then
        plate = GenerateRandomPlate()
    else
        plate = FormatPlate(plate)
    end

    if CheckPlate(plate) then
        xPlayer.showNotification(Language["plate-already-exists"])
        return
    end

    MySQL.query.await("INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)", {
        xTarget.getIdentifier(),
        plate,
        json.encode({model = model, plate = plate, fuelLevel = 100.0, color1 = 0, color2 = 0}),
        1
    })

    xPlayer.showNotification(Language["give-car"]:format(xTarget.getName(), plate))
end)

RegisterNetEvent("garages:delCar", function (plate)
    
    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)

    if not Utils.checkPlayer(xPlayer) then
        return
    end

    plate = FormatPlate(plate)

    if not CheckPlate(plate) then
        xPlayer.showNotification(Language["plate-not-exists"])
        return
    end

    
    MySQL.query.await("DELETE FROM owned_vehicles WHERE plate = ?", {plate})
    xPlayer.showNotification(Language["del-car"])
end)


RegisterNetEvent("garages:impoundCar", function (id, plate)
    
    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)
    local target    = id
    local xTarget   = ESX.GetPlayerFromId(target)

    if not Utils.checkPlayer(xTarget) then
        xPlayer.showNotification(Language["not-online"])
        return
    end

    plate = FormatPlate(plate)

    if not CheckPlate(plate) then
        xPlayer.showNotification(Language["plate-not-exists"])
        return
    end

    MySQL.query.await("UPDATE owned_vehicles SET stored = 2 WHERE owner = ? AND plate = ?", {xTarget.getIdentifier(), plate})
    xPlayer.showNotification(Language["impound-car"])
    
end)

RegisterNetEvent("garages:deimpoundCar", function (plate)
    
    local source    = source
    local xPlayer   = ESX.GetPlayerFromId(source)

    plate = FormatPlate(plate)

    if not CheckPlate(plate) then
        xPlayer.showNotification(Language["player-not-exists"])
        return
    end

    MySQL.query.await("UPDATE owned_vehicles SET stored = 1 WHERE plate = ?", {plate})
    xPlayer.showNotification(Language["deimpound-car"])
end)