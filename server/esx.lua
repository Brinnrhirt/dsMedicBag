if Config.Framework == 'ESX' then
	if Config.ESXOldVersion then
		ESX	= nil
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	end
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

    RegisterNetEvent('dsMedicBag:server:deleteObject', function(objectId)
        TriggerClientEvent('dsMedicBag:client:removeObject', -1, objectId)
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
        local xPlayer = ESX.GetPlayerFromId(src)
        if Config.Debug then print('Passed event, reviving player') end
        xPlayer.triggerEvent('esx_ambulancejob:revive')
    end)


    -- Add How many items you want.
    ESX.RegisterUsableItem('medbag', function(source, _)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        if Config.WhitelistToJobs then
            for k, v in pairs(Config.Jobs) do
                if xPlayer.job.name == v then
                    TriggerClientEvent("dsMedicBag:client:SpawnBag", src)
                    xPlayer.removeInventoryItem('medbag', 1)
                else
                    TriggerClientEvent('esx:showNotification', src, _U('error.no_permission'))
                end
            end
        else 
            TriggerClientEvent("dsMedicBag:client:SpawnBag", src)
            xPlayer.removeInventoryItem('medbag', 1)
        end
    end)
end