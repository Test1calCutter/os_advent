ESX = nil
local spawned = false
local npc = nil
local prop = nil
local blip = nil
local showing = true
local interactionButtonActive = false
local BlipName = Config.BlipName
local BlipSprite = Config.BlipSprite
local BlipDisplay = Config.BlipDisplay
local BlipScale = Config.BlipScale
local BlipColour = Config.BlipColour
local blipCreated = false


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function _U(text)
    local locale = Config.Locale
    return Locales[locale] and Locales[locale][text] or text
end

function notify(way, title, description, position, type, other) -- This was not tested in here. Might spit errors! if using notify("esx/ox", title, description, position, type, other)
    if Config.UseOXnotification and title and description and position and type ~= nil and way == "ox" then
        lib.notify(
            {
                id = 'notification',
                title = title,
                description = description,
                showDuration = false,
                position = position,
                type = type
            }
        )
    elseif not Config.UseOXnotification and not title and not description and not position and not type and other ~= nil and way == "esx" then
        ESX.ShowNotification(other)
    end
end

function SpawnNPC()
    if not spawned then
        spawned = true

        RequestModel(Config.Ped)

        while not HasModelLoaded(Config.Ped) do
            Wait(500)
        end
    
        local pos = vector4(Config.Location.x, Config.Location.y, Config.Location.z, Config.Location.w)
    
        npc = CreatePed(4, Config.Ped, pos.x, pos.y, pos.z, pos.w, 0.0, true, false)
    
        SetEntityCoordsNoOffset(npc, pos.x, pos.y, pos.z, pos.w, true, true, true)
        SetEntityInvincible(npc, true)
        SetEntityHasGravity(npc, false)
        FreezeEntityPosition(npc, true)
        SetAmbientVoiceName(npc, "ALERT_Player")
        SetModelAsNoLongerNeeded(model)
    end
end

function SpawnProp()
    if not spawned then
        spawned = true

        RequestModel(Config.Ped)

        while not HasModelLoaded(Config.Ped) do
            Wait(500)
        end
    
        local pos = vector3(Config.Location.x, Config.Location.y, Config.Location.z)
    
        prop = CreateObject(Config.Prop, pos.x, pos.y, pos.z, pos.w, 0.0, true, false, false)
        FreezeEntityPosition(prop, true)
        SetEntityAsMissionEntity(prop, true, true)
        SetEntityCollision(prop, true, true)
        SetObjectPhysicsParams(prop, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    end
end

function DeleteProp()
    if spawned and DoesEntityExist(prop) then
        spawned = false
        DeleteEntity(prop)
        --print("^2DEBUG:^0 Prop deleted")
    end
end

function bliping()
    if showing and not blipCreated then
        AddTextEntry('label', BlipName)
        blip = AddBlipForCoord(Config.Location.x, Config.Location.y, Config.Location.z)
        SetBlipSprite(blip, BlipSprite)
        SetBlipDisplay(blip, BlipDisplay)
        SetBlipScale(blip, BlipScale)
        SetBlipColour(blip, BlipColour)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("label")
        EndTextCommandSetBlipName(blip)
        blipCreated = true
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local positionInteraction = Config.Location
        
        if Config.UseBlip then
            showing = true
            bliping()
        end

        if playerPed then
            local positionPlayer = GetEntityCoords(playerPed)
            local interactDistance = GetDistanceBetweenCoords(
                positionPlayer.x, positionPlayer.y, positionPlayer.z,
                positionInteraction.x, positionInteraction.y, positionInteraction.z,
                true
            )

            if Config.SpawnPed or Config.SpawnProp then
                if interactDistance <= Config.SpawnRange and not spawned then
                    if Config.SpawnPed and not DoesEntityExist(npc) then
                        SpawnNPC()
                    end

                    if Config.SpawnProp and not DoesEntityExist(prop) then
                        SpawnProp()
                    end
                elseif interactDistance > Config.SpawnRange and spawned then
                    if Config.SpawnPed and DoesEntityExist(npc) then
                        DeleteNPC()
                    end
                    if Config.SpawnProp and DoesEntityExist(prop) then
                        DeleteProp()
                    end
                end
            end

            if interactDistance <= Config.InteractionRange then
                if Config.ThirdEye then
                    local pos = vector3(positionInteraction.x, positionInteraction.y, positionInteraction.z)
                    local range = Config.ThirdEyeRange or 2.0
                    local obj = nil
                    if Config.SpawnPed and not Config.SpawnProp then
                        obj = Config.Ped
                    elseif Config.SpawnProp and not Config.SpawnPed then
                        obj = Config.Prop
                    end

                    if not interactionButtonActive then
                        options = {
                            {
                                label = _U("interactThirdEye"),
                                icon = 'fas fa-gift',
                                onSelect = function()
                                    TriggerServerEvent('os_advent:timeRemaining', interactDistance)
                                end
                            }
                        }
                        exports.ox_target:addModel(obj, options)
                        interactionButtonActive = true
                    end
                else
                    ESX.ShowHelpNotification(_U("interact"))
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('os_advent:timeRemaining', interactDistance)
                    end
                end
            else
                if interactionButtonActive then
                    exports.ox_target:removeModel(Config.Ped)
                    exports.ox_target:removeModel(Config.Prop)
                    interactionButtonActive = false
                end
            end
        else
            print("^1ERROR:^0 Player is not found!")
        end
    end
end)

RegisterCommand("givePresent", function(source, args, rawCommand)
    local playerIngameID = GetPlayerServerId(PlayerId())

    ESX.TriggerServerCallback('esx:getPlayerGroup', function(group)
        if Config.Groups[group] then
            TriggerServerEvent('os_advent:g51Jkl0l', playerIngameID)
        else
            ESX.ShowNotification(_U("noPermission"))
        end
    end)
end, false)

RegisterCommand("stopAdvent", function(source, args, rawCommand)
    local playerIngameID = GetPlayerServerId(PlayerId())

    ESX.TriggerServerCallback('esx:getPlayerGroup', function(group)
        if Config.Groups[group] then
            TriggerServerEvent('os_advent:st01Jkl0l')
        else
            ESX.ShowNotification(_U("noPermission"))
        end
    end)
end, false)

RegisterCommand("startAdvent", function(source, args, rawCommand)
    local playerIngameID = GetPlayerServerId(PlayerId())

    
    ESX.TriggerServerCallback('esx:getPlayerGroup', function(group)
        if Config.Groups[group] then
            TriggerServerEvent('os_advent:st41Jkl0l')
        else
            ESX.ShowNotification(_U("noPermission"))
        end
    end)
end, false)

RegisterCommand("resetTimer", function(source, args, rawCommand)
    local playerIngameID = GetPlayerServerId(PlayerId())

    local playerId = tonumber(args[1])
    if not playerId then
        ESX.ShowNotification("Invalid player ID!")
        --print("DEBUG: Invalid player id passed")
        return
    end

    --print("DEBUG: Player id parsed: " .. playerId)

    ESX.TriggerServerCallback('esx:getPlayerGroup', function(group)
        if Config.Groups[group] then
            --print("DEBUG: Triggering server event w/ player ID: " .. playerId)
            TriggerServerEvent('os_advent:re53tkl0l', playerId)
        else
            ESX.ShowNotification(_U("noPermission"))
        end
    end)
end, false)
