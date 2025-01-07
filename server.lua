local sleepingPeds = {}


local function Debug(msg, ...)
    if Config.Debug then
        print('^2[Ali_SleepOffline][SERVER]^7 ' .. string.format(msg, ...))
    end
end

local function GetPlayerIdentifierByType(source, idType)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:sub(1, #idType + 1) == (idType .. ":") then
            return id
        end
    end
    return nil
end

local function maskLastname(lastname)
    if not Config.NameDisplay.MaskLastname then
        return lastname
    end

    local visibleLength = math.min(Config.NameDisplay.MaskLength, #lastname)
    return lastname:sub(1, visibleLength) .. string.rep('*', #lastname - visibleLength)
end

local function getPlayerData(identifier)
    local skin, playerName = nil, Config.Locales[Config.Locale]['unknown']

    local skinResult = MySQL.Sync.fetchAll(string.format(
        'SELECT %s FROM %s WHERE %s = @identifier',
        Config.MySQL.Tables.Fields.Skin,
        Config.MySQL.Tables.Users,
        Config.MySQL.Tables.Fields.Identifier
    ), { ['@identifier'] = identifier })

    if skinResult[1] then
        skin = json.decode(skinResult[1].skin)
        Debug('Loaded skin data for player: %s', identifier)
    else
        Debug('No skin data found for player: %s', identifier)
    end

    local nameResult = MySQL.Sync.fetchAll(string.format(
        'SELECT %s, %s FROM %s WHERE %s = @identifier',
        Config.MySQL.Tables.Fields.Firstname,
        Config.MySQL.Tables.Fields.Lastname,
        Config.MySQL.Tables.Users,
        Config.MySQL.Tables.Fields.Identifier
    ), { ['@identifier'] = identifier })

    if nameResult[1] then
        local lastname = maskLastname(nameResult[1][Config.MySQL.Tables.Fields.Lastname])
        playerName = string.format('%s %s',
            nameResult[1][Config.MySQL.Tables.Fields.Firstname],
            lastname
        )
        Debug('Loaded player name: %s', playerName)
    end

    return skin, playerName
end

local function removeOldPeds()
    local currentTime = os.time()
    for identifier, data in pairs(sleepingPeds) do
        if (currentTime - data.timestamp) > (Config.PedTimeout * 60) then
            Debug('Removing expired sleeping ped for: %s', identifier)
            TriggerClientEvent('ali_sleepoffline:removeSleepingPed', -1, identifier)
            sleepingPeds[identifier] = nil
        end
    end
end

CreateThread(function()
    while true do
        Wait(Config.PedCheckInterval * 60 * 1000)
        removeOldPeds()
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    local identifier = GetPlayerIdentifierByType(source, "license")

    Debug('Player dropped: %s', source)

    if identifier then
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local skin, playerName = getPlayerData(identifier)

        Debug('Saving sleeping ped at: %s, %s, %s', coords.x, coords.y, coords.z)
        sleepingPeds[identifier] = {
            coords = coords,
            heading = heading,
            skin = skin,
            name = playerName,
            timestamp = os.time()
        }

        TriggerClientEvent('ali_sleepoffline:spawnSleepingPed', -1, identifier, coords, heading, skin, playerName)
    end
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifier = GetPlayerIdentifierByType(source, "license")

    Debug('Player connecting: %s', source)

    if identifier and sleepingPeds[identifier] then
        Debug('Removing sleeping ped for player: %s', identifier)
        TriggerClientEvent('ali_sleepoffline:removeSleepingPed', -1, identifier)
        sleepingPeds[identifier] = nil
    end
end)

lib.addCommand(Config.Permissions.FakeCommandName, {
    restricted = 'group.admin'
}, function(source, args, raw)
    local source = source
    local identifier = GetPlayerIdentifierByType(source, "license")
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local skin, playerName = getPlayerData(identifier)

    Debug('Saving sleeping ped at: %s, %s, %s', coords.x, coords.y, coords.z)
    sleepingPeds[identifier] = {
        coords = coords,
        heading = heading,
        skin = skin,
        name = playerName,
        timestamp = os.time()
    }

    TriggerClientEvent('ali_sleepoffline:spawnSleepingPed', -1, identifier, coords, heading, skin, playerName)
end)

lib.callback.register('ali_sleepoffline:getSleepingPeds', function(source)
    Debug('Sending sleeping ped data to client: %s', source)
    return sleepingPeds
end)
