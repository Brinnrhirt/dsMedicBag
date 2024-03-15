if Config.Framework == 'QBCore' then
    local QBCore = exports['qb-core']:GetCoreObject()
    local Objects = {}
    local function CreateObjectId()
        if Objects then
            local objectId = math.random(10000, 99999)
            while Objects[objectId] do
                objectId = math.random(10000, 99999)
            end
            return objectId
        else
            local objectId = math.random(10000, 99999)
            return objectId
        end
    end

    RegisterNetEvent('dsMedicBag:server:spawnObject', function(type)
        local src = source
        local objectId = CreateObjectId()
        Objects[objectId] = type
        TriggerClientEvent("dsMedicBag:client:spawnObject", src, objectId, type, src)
    end)

    function CreateObjectId()
        if Objects then
            local objectId = math.random(10000, 99999)
            while Objects[objectId] do
                objectId = math.random(10000, 99999)
            end
            return objectId
        else
            local objectId = math.random(10000, 99999)
            return objectId
        end
    end

    RegisterNetEvent('dsMedicBag:server:revivePlayer', function()
        local src = source
        local Player =  QBCore.Functions.GetPlayer(src)
        if Config.Debug then print('Passed event, reviving player') end
        TriggerClientEvent('hospital:client:Revive', Player.PlayerData.source)
    end)

    -- Add How many items you want.
    QBCore.Functions.CreateUseableItem('medbag', function(source, _)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Config.WhitelistToJobs then
            k, v in pairs(Config.Jobs) do
                if xPlayer.job.name == v then
                    TriggerClientEvent("dsMedicBag:client:SpawnBag", src)
                    Player.Functions.RemoveItem('medbag', 1)
                else
                    TriggerClientEvent('QBCore:Notify', src, _U('error.no_permission'))
                end
            end
        else 
            TriggerClientEvent("dsMedicBag:client:SpawnBag", src)
            Player.Functions.RemoveItem('medbag', 1)
        end
    end)
end