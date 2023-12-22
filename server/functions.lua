Utils = {}

Utils.log = function (text, invoker, type)
    type = string.upper(type)
    print(("[%s][%s] %s!"):format(type, invoker, text))
end

Utils.checkPlayer = function (xPlayer)
    if xPlayer then return true end
    Utils.log("Error fetching xPlayer", GetInvokingResource(), "error")
    return false
end

DeimpoundVehicle = function (plate)
    MySQL.query.await("UPDATE owned_vehicles SET stored = 0 WHERE plate = ?", {plate})
end

IsOwnVehicle = function (identifier, plate)

    for k, auto in pairs(FetchAllPlayerVehicles(identifier)) do
        if auto.plate == plate then
            return true
        end
    end
    return false
end

FetchGarageVehicles = function (identifier, garageName)

    local vehicles  = {}

    for k, auto in pairs(FetchAllPlayerVehicles(identifier)) do
        if auto.garageName == nil or auto.garageName == garageName or auto.garageName == "" then
            vehicles[#vehicles+1] = auto
        end
    end
    return vehicles
end

FetchImpoundedVehicles = function (identifier)

    local vehicles  = {}

    for k, auto in pairs(FetchAllPlayerVehicles(identifier)) do
        if tonumber(auto.stored) == 2 then
            vehicles[#vehicles+1] = auto
        end
    end
    return vehicles
end

FetchAllPlayerVehicles = function (identifier)
    local vehicles  = {}
    local response  = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ?", {identifier})

    if #response > 0 then
        for i = 1, #response do

            local row = response[i]
            local vehicle = json.decode(row.vehicle) and json.decode(row.vehicle) or {}

            vehicles[#vehicles+1] = {
                owner       = row.owner,
                plate       = row.plate,
                props       = vehicle,
                vehicle     = vehicle.model,
                type        = row.type,
                stored      = row.stored,
                distance    = row.mileage,
                garageName  = row.garage
            }

        end
    end
    return vehicles
end

-- Commands

IsAllowed = function (myGroup)

    for k, group in pairs(Config.Groups) do
        if group == myGroup then
            return true
        end
    end
    return false
end