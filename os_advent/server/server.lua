-- Checking the players group
ESX.RegisterServerCallback('esx:getPlayerGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        cb(xPlayer.getGroup())
    else
        cb(nil)
    end
end)

function _U(text)
    local locale = Config.Locale
    return Locales[locale] and Locales[locale][text] or text
end

-- This is just to send notifications! You can rewrite this for your custom notification!
function notify(source, way, title, description, position, type, other)
    if Config.UseOXnotification and title and description and position and type ~= nil and way == "ox" then
        TriggerClientEvent('ox_lib:notify', source, {
            id = 'notification',
            title = title,
            description = description,
            showDuration = false,
            position = position,
            type = type
        })
    elseif not Config.UseOXnotification and not title and not description and not position and not type and other ~= nil and way == "esx" then
        ESX.ShowNotification(other)
    end
end



-- Checking how much time is remaining for user
RegisterNetEvent('os_advent:timeRemaining')
AddEventHandler('os_advent:timeRemaining', function(distPlayer, distInteract)
    local source = source

    if not Config.Stopped then

        if not source or source <= 0 then
            print("^1ERROR:^0 Invalid player source")
            return
        end

        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then
            print("^1ERROR:^0 ESX player not found for source " .. tostring(source))
            return
        end

        local identifier = xPlayer.getIdentifier()
        MySQL.Async.fetchScalar("SELECT last_pickup FROM os_advent WHERE player_identifier = @identifier", {
            ['@identifier'] = identifier
        }, function(lastPickup)
            if lastPickup then
                local currentTime = os.time()
            
                if type(lastPickup) == "number" and lastPickup > 1000000000 then
                    lastPickup = lastPickup / 1000
                end
            
                if type(lastPickup) == "number" then
                    local lastPickupTime = lastPickup
                    local elapsedMinutes = math.floor((currentTime - lastPickupTime) / 60)

                    if elapsedMinutes > 1440 then
                        --print("^2Last pickup was over 24 hours ago^0")
                        TriggerEvent('os_advent:aZ3x1Y', source, distPlayer, distInteract, identifier)
                    else
                        --print(string.format("^2Last pickup was %d minutes ago^0", elapsedMinutes))
                        notify(source, "ox", _U('presentTakenAlreadyTitle'), _U('presentTakenAlready'), "top", "error")
                        notify(source, "esx", _U('presentTakenAlready'))
                    end
                else    -- Checking again because doppelt hält besser
                    local year, month, day, hour, min, sec = lastPickup:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
                    if year and month and day and hour and min and sec then
                        local lastPickupTime = os.time({
                            year = tonumber(year),
                            month = tonumber(month),
                            day = tonumber(day),
                            hour = tonumber(hour),
                            min = tonumber(min),
                            sec = tonumber(sec)
                        })
                    
                        if lastPickupTime and lastPickupTime > 0 then
                            local elapsedMinutes = math.floor((currentTime - lastPickupTime) / 60)
                        
                            if elapsedMinutes > 1440 then
                                --print("^2Last pickup was over 24 hours ago^0")
                                TriggerEvent('os_advent:aZ3x1Y', source, distPlayer, distInteract, identifier)
                            else
                                --print(string.format("^2Last pickup was %d minutes ago^0", elapsedMinutes))
                                notify(source, "ox", _U('presentTakenAlreadyTitle'), _U('presentTakenAlready'), "top", "error")
                                notify(source, "esx", _U('presentTakenAlready'))
                            end
                        else
                            --print("^1ERROR:^0 Invalid lastPickup time")
                            notify(source, "ox", _U('titleError'), _U('descriptionError'), "top", "error")
                            notify(source, "esx", _U('descriptionError'))
                        end
                    else
                        --print("^1ERROR:^0 Invalid timestamp format for last pickup")
                        notify(source, "ox", _U('titleError'), _U('descriptionError'), "top", "error")
                        notify(source, "esx", _U('descriptionError'))
                    end
                end
            else
                --print("^1No last pickup found for this player! proceeding to grant present^0")
                notify(source, "ox", _U('presentTakenTitle'), _U('presentTakenDescription'), "top", "success")
                notify(source, "esx", _U('presentTakenDescription'))
                TriggerEvent('os_advent:aZ3x1Y', source, distPlayer, distInteract, identifier)
            end
        end)
    end
end)



-- Give player their present and enter lastPickup in database
RegisterNetEvent('os_advent:aZ3x1Y') -- Hiding from cheaters, also kicking cheaters if triggered in wrong place (if enabled in config)
AddEventHandler('os_advent:aZ3x1Y', function(sourceID, distPlayer, distInteract, identifier)
    local source = source

    if not Config.Stopped then
        if source then
            if distPlayer > Config.MaxRange then
                TriggerEvent('os_advent:jTo03Z', source)
            else
                MySQL.Async.fetchScalar("SELECT last_pickup FROM os_advent WHERE player_identifier = @identifier", {
                    ['@identifier'] = identifier
                }, function(lastPickup)
                    local currentTime = os.date('%Y-%m-%d %H:%M:%S')

                    MySQL.Async.execute("REPLACE INTO os_advent (player_identifier, last_pickup) VALUES (@identifier, @currentTime)", {
                        ['@identifier'] = identifier,
                        ['@currentTime'] = currentTime
                    })

                    local keys = {}
                    for k in pairs(Config.Gifts) do table.insert(keys, k) end
                    local randomKey = keys[math.random(#keys)]
                    local chosenGift = Config.Gifts[randomKey]
                    local maxAmount = chosenGift.maxAmount
                    local spawnName = chosenGift.spawnName

                    local itemKeys = {}
                    for item in pairs(chosenGift.items) do table.insert(itemKeys, item) end
                    local randomItem = itemKeys[math.random(#itemKeys)]
                    local count = chosenGift.items[randomItem]



                    -- Giving the gift
                    if Config.UseOxInventory then
                        if Config.CustomItem then
                            exports.ox_inventory:AddItem(tonumber(sourceID), spawnName, maxAmount)
                        else
                            exports.ox_inventory:AddItem(tonumber(sourceID), randomItem, count)
                        end
                    else
                        if tonumber(sourceID).canCarryItem(randomItem, count) then
                            tonumber(sourceID).addInventoryItem(item, count)
                        else
                            notify(source, "esx", _U('notEnoughSpace'))
                        end
                    end
                end)
            end
        else
            print("^1ERROR:^0 Player is not found!")
        end
    end
end)



RegisterNetEvent('os_advent:jTo03Z') -- Kicking the player (if cheaters use this, they kick themselves 🤷‍♂️)
AddEventHandler('os_advent:jTo03Z', function(source)
    if source then
        DropPlayer(source, _U('DropMsg'))
    else
        print("^1ERROR:^0 Player is not found!")
    end
end)





-- Admin Commands:

-- Giving a present to player id
RegisterNetEvent('os_advent:g51Jkl0l')
AddEventHandler('os_advent:g51Jkl0l', function(playerId)
    if playerId then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local identifier = xPlayer.getIdentifier()
            TriggerEvent('os_advent:aZ3x1Y', source, 1, 10000, identifier)
            if Config.UseOXnotification then
                notify(source, "ox", _U('titleSuccess'), _U('adminGiftGiven'), "top", "success")
            else
                notify(source, "esx", _U('adminGiftGiven'))
            end
        else
            print("^1ERROR:^0 Player not found with ID " .. tostring(playerId))
        end
    else
        print("^1ERROR:^0 Invalid player ID provided")
    end
end)

-- Stopping the event so nobody can take anymore presents
RegisterNetEvent('os_advent:st01Jkl0l')
AddEventHandler('os_advent:st01Jkl0l', function()
    if not Config.Stopped then
        Config.Stopped = true
        if Config.UseOXnotification then
            notify(source, "ox", _U('titleSuccess'), _U('StoppedEventDes'), "top", "success")
        else
            notify(source, "esx", _U('StoppedEventDes'))
        end
    end
end)

-- Starting the event again
RegisterNetEvent('os_advent:st41Jkl0l')
AddEventHandler('os_advent:st41Jkl0l', function()
    if Config.Stopped then
        Config.Stopped = false
        if Config.UseOXnotification then
            notify(source, "ox", _U('titleSuccesStarted'), _U('StartedEventDes'), "top", "success")
        else
            notify(source, "esx", _U('StartedEventDes'))
        end
    end
end)

-- Resetting a players lastPickup time so they can take a new present
RegisterNetEvent('os_advent:re53tkl0l')
AddEventHandler('os_advent:re53tkl0l', function(playerId)
    if not playerId or playerId <= 0 then
        print("^1ERROR:^0 Invalid player ID received")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        print("^1ERROR:^0 Player not found for ID: " .. tostring(playerId))
        return
    end

    local identifier = xPlayer.getIdentifier()
    if not identifier then
        print("^1ERROR:^0 Identifier is nil for player ID: " .. tostring(playerId))
        return
    end

    --print("^2DEBUG:^0 Identifier: " .. identifier)

    MySQL.Async.execute("UPDATE os_advent SET last_pickup = @pastTime WHERE player_identifier = @identifier", {
        ['@identifier'] = identifier,
        ['@pastTime'] = "1300-01-01 00:00:00"
    }, function(affectedRows)
        --print("^2DEBUG:^0 Rows affected: " .. affectedRows)
        if affectedRows > 0 then
            if Config.UseOXnotification then
                notify(playerId, "ox", _U('resetTitle'), _U('resetDescription', xPlayer.getName()), "top", "success")
            else
                notify(playerId, "esx", _U('resetDescription', xPlayer.getName()))
            end
        else
            print("^1ERROR:^0 Failed to update last_pickup for player: " .. identifier)
        end
    end)
end)

