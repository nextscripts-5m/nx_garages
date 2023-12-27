local loaded        = false
local currentGarage = nil
local currentAuto   = nil
local currentPoint  = nil

if Config.UI == "gridsystem" then
    CreateThread(function ()
        while true do
            Wait(0)
            if not HasStreamedTextureDictLoaded(Config.StreamFile) then
                RequestStreamedTextureDict(Config.StreamFile, true)
                while not HasStreamedTextureDictLoaded(Config.StreamFile) do
                    Wait(1)
                end
            end
            break
        end
        print(("^3%s^7::Marker Loaded"):format(GetCurrentResourceName()))
    end)
end

RegisterNetEvent("esx:playerLoaded", function ()

    if loaded then return end

    loaded = true

    TriggerServerEvent("garages:PreserveVehicles")
    ConfigureGarages()
    ConfigureImpounds()
end)

ConfigureGarages = function ()

    for k, v in pairs(Config.Garages) do
        AddBlip("garage", v.position)
        CreateGarage(v.position, "garage", k, "open")
        CreateGarage(v.deposit, "garage", k, "deposit")
    end
end

ConfigureImpounds = function ()

    for k, v in pairs(Config.Impounds) do
        AddBlip("impound", v.position)
        CreateGarage(v.position, "impound", k, "open")
    end
end


---Create a Generic Garage
---@param position vector3 the position
---@param type string garage or impound
---@param garageName any garage name (index)
---@param action string the action (open or deposit)
CreateGarage = function (position, type, garageName, action)

    CreateThread(function ()

        local index = ("%s-%s"):format(action, type)



        if position == vec3(0, 0, 0) then
            print(("Skipped '%s' with name: %s"):format(type, garageName))
            goto continue
        end

        local point = lib.points.new({
            coords      = position,
            distance    = action == "deposit" and 7.0 or 4.5,
            type        = type,
            garageName  = garageName,
            action      = action,
            index       = index,
            customId    = ("%s-%s"):format(type, garageName)
        })

        function point:onEnter()
            print(("Entered %s"):format(self.garageName))
            
            currentGarage = self.garageName
            currentPoint = self.id

            if Config.UI == "lib" then
                local options = Config.TextUI[index]
                lib.showTextUI(options.text, {
                    position    = options.position,
                    icon        = options.icon,
                    style       = options.style
                })
            end

            if Config.UI == "gridsystem" then
                TriggerGridSystem(self, index)
            end

        end

        function point:onExit()
            print(("Exited %s"):format(self.garageName))

            if Config.UI == "lib" and currentPoint == self.id then
                lib.hideTextUI()
            end

            if Config.UI == "gridsystem" and currentPoint == self.id then
                TriggerEvent('gridsystem:unregisterMarker', "Marker: " .. self.customId)
            end
        end

        function point:nearby()

            if Config.UI == "3d" then
                DrawText3D(self.coords.x, self.coords.y, self.coords.z, Language[index]:format("E"))
            end

            if Config.UI == "lib" then
                local coords    = GetSafeZ(self.coords.x, self.coords.y, self.coords.z)
                local scale     = action == "deposit" and vec3(4, 4, 4) or vec3(1.2, 1.2, 1.2)
                DrawMarker(27, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale.x, scale.y, scale.z, 65, 105, 225, 100, false, true, 2, true, nil, nil, false)
            end

            if self.currentDistance < self.distance and IsControlJustReleased(0, Config.Open) then
                HandleAction(action, type, currentGarage)
            end
        end

        ::continue::
    end)
end

TriggerGridSystem = function (self, index)
    
    local coords = vec3(self.coords.x, self.coords.y, self.coords.z)

    TriggerEvent('gridsystem:registerMarker', {
        name            = "Marker: " .. self.customId, -- DO NOT CHANGE DO NOT CHANGE DO NOT CHANGE DO NOT CHANGE DO NOT CHANGE DO NOT CHANGE 
        pos             = coords,
        drawDistance    = self.action == "deposit" and 7.0 or 4.5,
        scale           = vector3(1.2, 1.2, 1.2),
        msg             = Language[index]:format("E"),
        control         = Config.Open,
        type            = 9, -- this depends on your own gridsystem
        textureDict     = Config.StreamFile,
        textureName     = Config.CustomMarkers[self.action], -- THIS IS THE TEXTURE NAME THAT YOU CAN SEE ON OpenIV
        rotate          = true,
        color           = { r = 255, g = 255, b = 255 },

        action          = function()
            -- handled by point
        end,

        onEnter         = function ()
            if Config.CustomTextUI then
                local label = (Config.OpenMarker[self.index] and Config.OpenMarker[self.index] or 'Config.OpenMarker')
                TriggerEvent('ToggleUI', true, Config.DefaultAvatar, "E", label) -- my own gridsystem event
            end
        end,
        onExit          = function ()
            if Config.CustomTextUI then
                TriggerEvent('ToggleUI', false) -- my own gridsystem event
            end
        end
    })
end

HandleAction = function (action, type, garageName)

    if action == "open" then
        OpenGarage(type, garageName)
    end

    if action == "deposit" then
        DepositVehicle(garageName)
    end
end

DepositVehicle = function (garageName)
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        ESX.ShowNotification(Language["not-in-vehicle"])
        return
    end

    local vehicle = GetVehiclePedIsUsing(PlayerPedId())

    if DoesEntityExist(vehicle) then
        ESX.TriggerServerCallback("validateVehicle", function (valid)
            if valid then
                ESX.Game.DeleteVehicle(vehicle)
            else
                ESX.ShowNotification(Language["not-owner"])
            end
        end, ESX.Game.GetVehicleProperties(vehicle), garageName)
    end
end

---Open a garage
---@param type string garage or impound
---@param garageName string garage name
OpenGarage = function (type, garageName)
    ESX.TriggerServerCallback(("garages:%sVehicles"):format(type), function (vehicles)

        local spawnCoords   = type == "garage" and Config.Garages[garageName].spawn or Config.Impounds[garageName].spawn

        if #spawnCoords == 0 then
            ESX.ShowNotification(Language["no-spawn-points"])
            return
        end

        local heading       = type == "garage" and (Config.Garages[garageName].heading + 0.0) or (Config.Impounds[garageName].heading + 0.0)
        
        if #vehicles > 0 then

            local options = {}

            for i = 1, #vehicles do

                local vehicle = vehicles[i]

                if vehicle then
                    table.insert(options, {
                        label       = GetLabelText(GetDisplayNameFromVehicleModel(vehicle.vehicle)),
                        description = type == "garage" and (Language["plate"]):format(vehicle.props.plate) or (Language["pay"]:format(Config.MoneyOperator, Config.DeimpoundCost)),
                        args        = {model = vehicle.vehicle, props = vehicle.props, stored = vehicle.stored}
                    })
                end
            end

            local index = ("open-%s"):format(type)

            lib.registerMenu({
                id          = Config.Menu[index].id,
                title       = Config.Menu[index].title,
                position    = Config.Menu[index].position,
                options     = options,

                onSelected = function (selected, scrollIndex, args)
                    local vehicle = args.model
                    lib.requestModel(vehicle)

                    if DoesEntityExist(currentAuto) then
                        ESX.Game.DeleteVehicle(currentAuto)
                    end
                    
                    local position = FoundPosition(spawnCoords, 1)

                    if position == nil then
                        ESX.ShowNotification(Language["no-clear"])
                        return
                    end

                    ESX.Game.SpawnLocalVehicle(vehicle, position, heading, function (Vehicle)
                        currentAuto = Vehicle
                        ESX.Game.SetVehicleProperties(Vehicle, args.props)
                    end)
                end,

                onClose = function ()
                    if DoesEntityExist(currentAuto) then
                        ESX.Game.DeleteVehicle(currentAuto)
                    end
                end
            },
                function (selected, scrollIndex, args)
                    local vehicle = args.model
                    lib.requestModel(vehicle)

                    
                    if DoesEntityExist(currentAuto) then
                        ESX.Game.DeleteVehicle(currentAuto)
                    end

                    local position = FoundPosition(spawnCoords, 1)

                    if position == nil then
                        -- ESX.ShowNotification(Language["no-clear"])
                        return
                    end

                    if args.stored == 0 then
                        ESX.ShowNotification(Language["outside"])
                        return
                    elseif args.stored == 2 and type ~= "impound" then
                        ESX.ShowNotification(Language["impounded"])
                        return
                    end

                    ESX.Game.SpawnVehicle(vehicle, position, heading, function(Vehicle)
                        ESX.Game.SetVehicleProperties(Vehicle, args.props)
                        NetworkFadeInEntity(Vehicle, true)
                        TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)
                        SetEntityAsMissionEntity(Vehicle, true, true)

                        if type == "impound" then
                            PayImpound(args.props.plate)
                        end

                        TriggerServerEvent("garages:spawnVehicle", args.props.plate)
                    end)
                end
            )

            lib.showMenu(Config.Menu[index].id)
        else
            ESX.ShowNotification(Language["no-vehicles"])
            return
        end

    end, garageName)
end

-- Functions

PayImpound = function (plate)
    TriggerServerEvent("garages:payImpound", plate)
end

FoundPosition = function (spawnCoords, k)
    local position  = spawnCoords[k]
    local found     = false

    if not ESX.Game.IsSpawnPointClear(position, 3.0) then

        for k2, v in pairs(spawnCoords) do

            if k2 ~= k then
                if ESX.Game.IsSpawnPointClear(v, 3.0) then
                    position    = v
                    found       = true
                    break
                end
            end
        end

        if not found then
            position = nil
            ESX.ShowNotification(Language["no-clear-points"])
        end

    end
    return position
end

GetSafeZ = function (x, y, z)
    local _, safeZ = GetGroundZFor_3dCoord(x, y, z, true)
    return vector3(x, y, safeZ)
end

AddBlip = function (type, position)

    local metadata = Config.Blip[type]

    local blip = AddBlipForCoord(position.x, position.y, position.z)

    SetBlipSprite (blip, metadata.sprite)
    SetBlipDisplay(blip, metadata.display)
    SetBlipScale  (blip, metadata.scale)
    SetBlipColour (blip, metadata.color)
    SetBlipAsShortRange(blip, metadata.shortRange)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(metadata.name)
    EndTextCommandSetBlipName(blip)
end

DrawText3D = function(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end


exports("OpenGarage", OpenGarage)

-- Commands

CheckValid = function (valid)
    if not valid then
        ESX.ShowNotification(Language["no-perms"])
    end
    return valid
end

if Config.GiveCarCommand or #Config.GiveCarCommand > 0 then
    RegisterCommand(Config.GiveCarCommand, function (source, args, raw)
        ESX.TriggerServerCallback("garages:checkPermissions", function (valid)

            if not CheckValid(valid) then return end

            local id    = args[1]
            local model = args[2]
            local plate = args[3]

            if not id or not model then
                ESX.ShowNotification(Language["command-failed"])
                return
            end

            TriggerServerEvent("garages:giveCar", id, model, plate)
        end)
    end)
    TriggerEvent('chat:addSuggestion', ("/%s"):format(Config.GiveCarCommand), 'Give a Car', {
        {name = "ID", help ="Player's ID"},
        {name = "Model", help ="Car Model"},
        {name = "<Plate>", help ="If not provided, random"},
    })
end

if Config.DelCarCommand or #Config.DelCarCommand > 0 then
    RegisterCommand(Config.DelCarCommand, function (source, args, raw)
        ESX.TriggerServerCallback("garages:checkPermissions", function (valid)

            if not CheckValid(valid) then return end

            local plate = args[1]

            if not plate then
                ESX.ShowNotification(Language["command-failed"])
                return
            end

            TriggerServerEvent("garages:delCar", plate)
        end)
    end)
    TriggerEvent('chat:addSuggestion', ("/%s"):format(Config.DelCarCommand), 'Delete a Car', {
        {name = "Plate", help ="Car's Plate"},
    })
end

if Config.ImpoundCarCommand or #Config.ImpoundCarCommand > 0 then
    RegisterCommand(Config.ImpoundCarCommand, function (source, args, raw)
        ESX.TriggerServerCallback("garages:checkPermissions", function (valid)

            if not CheckValid(valid) then return end

            local id    = args[1]
            local plate = args[2]

            if not id or not plate then
                ESX.ShowNotification(Language["command-failed"])
                return
            end

            TriggerServerEvent("garages:impoundCar", id, plate)
        end)
    end)
    TriggerEvent('chat:addSuggestion', ("/%s"):format(Config.ImpoundCarCommand), 'Impound a car', {
        {name = "ID", help ="Player's ID"},
        {name = "Plate", help ="Car's Plate"},
    })
end

if Config.DeImpoundCarCommand or #Config.DeImpoundCarCommand > 0 then
    RegisterCommand(Config.DeImpoundCarCommand, function (source, args, raw)
        ESX.TriggerServerCallback("garages:checkPermissions", function (valid)

            if not CheckValid(valid) then return end

            local plate = args[1]

            if not plate then
                ESX.ShowNotification(Language["command-failed"])
                return
            end

            TriggerServerEvent("garages:deimpoundCar", plate)
        end)
    end)
    TriggerEvent('chat:addSuggestion', ("/%s"):format(Config.DeImpoundCarCommand), 'DeImpound a car', {
        {name = "Plate", help ="Car's Plate"},
    })
end