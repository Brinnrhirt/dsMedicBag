if Config.Framework == 'QBCore' then
	local QBCore = exports['qb-core']:GetCoreObject()

    local ObjectList = {}
    RegisterNetEvent('dsMedicBag:client:SpawnBag', function()
        if lib.progressBar({
            duration = 3000,
            label = _U('info.using_item'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                mouse = false,
                combat = false
            },
            anim = {
                dict = 'anim@narcotics@trash',
                clip = 'drop_front'
            },
            prop = {},
        }) then 
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            local pos = GetEntityCoords(PlayerPedId())
            QBCore.Functions.Notify(_U('success.medbag_placed'), "success")
            PlaceMedicBag(pos)
        else 
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            QBCore.Functions.Notify(_U('error.cancelled'), "error")
        end
    end)


    function GetClosestMedicBag()
        local pos = GetEntityCoords(PlayerPedId(), true)
        local current = nil
        local dist = nil
        
        for id, _ in pairs(ObjectList) do
            local dist2 = #(pos - ObjectList[id].coords)
            if current then
                if dist2 < dist then
                    current = id
                    dist = dist2
                end
            else
                dist = dist2
                current = id
            end
        end
        return current
    end

    function PlaceMedicBag(coords)
        MedicBagLoc = coords
        TriggerServerEvent("dsMedicBag:server:spawnObject", "medbag")
    end
    local function GetClosestPlayer()
        local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
        local closestDistance = -1
        local closestPlayer = -1
        local coords = GetEntityCoords(PlayerPedId())
    
        for i = 1, #closestPlayers, 1 do
            if closestPlayers[i] ~= PlayerId() then
                local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
                local distance = #(pos - coords)
    
                if closestDistance == -1 or closestDistance > distance then
                    closestPlayer = closestPlayers[i]
                    closestDistance = distance
                end
            end
        end
        return closestPlayer, closestDistance
    end
    function HealingZone(coords)
        local sphere = lib.zones.sphere({
            coords = coords,
            radius = 3,
            debug = Config.Debug,
            onEnter = onEnter,
            inside = StartHeal,
            onExit = RemoveHeal,
        })
        SetTimeout(Config.Time * 1000, function()
            sphere:remove()
            RemoveMedicBag()
        end)
    end
    function onEnter(self)
        -- Insert whatever thing u want here when the player enters the zone
        if Config.Debug then 
            print('entered zone', self.id)
        end
    end
    
    function RemoveHeal(self)
        -- Insert whatever thing you want here when the player leaves the zone
        if Config.Debug then 
            print('exited zone', self.id)
        end
    end
    
    function StartHeal(self)
        if Config.Debug then 
            print('you are inside zone ' .. self.id)
        end
        Wait(1000)
        local totalHealth = GetEntityHealth(PlayerPedId())
        SetEntityHealth(PlayerPedId(), totalHealth + Config.HealthPerSecond)
        if Config.RevivePlayer then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                local isDead = PlayerData.metadata['isdead']
                if isDead then
                    local player, distance = GetClosestPlayer() -- We don't use distance as we're reviving ourself.
                    local playerId = GetPlayerServerId(player)
                    TriggerServerEvent('hospital:server:RevivePlayer', playerId)
                end
            end)
        end
    end

    function RemoveMedicBag()
        local objectId = GetClosestMedicBag()
        TriggerServerEvent("dsMedicBag:server:deleteObject", objectId)
    end

    RegisterNetEvent('dsMedicBag:client:spawnObject', function(objectId, type, player)
        local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
        local heading = GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(player)))
        local forward = GetEntityForwardVector(PlayerPedId())
        local x, y, z = table.unpack(coords + forward * 0.5)
        local spawnedObj = CreateObject(Config.Objects[type].model, x, y, z, true, false, false)
        PlaceObjectOnGroundProperly(spawnedObj)
        SetEntityHeading(spawnedObj, heading)
        FreezeEntityPosition(spawnedObj, Config.Objects[type].freeze)
        ObjectList[objectId] = {
            id = objectId,
            object = spawnedObj,
            coords = vector3(x, y, z - 0.3),
        }
        HealingZone(MedicBagLoc)
    end)
    RegisterNetEvent('dsMedicBag:client:removeObject', function(objectId)
        NetworkRequestControlOfEntity(ObjectList[objectId].object)
        DeleteObject(ObjectList[objectId].object)
        ObjectList[objectId] = nil
    end)
end