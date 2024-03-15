if Config.Framework == 'ESX' then
    local ObjectList = {}
	if Config.ESXOldVersion then
		ESX = nil
		Citizen.CreateThread(function()
			while ESX == nil do
				TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
				Citizen.Wait(0)
			end
		end)
	end

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
            ESX.ShowNotification(_U('success.medbag_placed'))
            PlaceMedicBag(pos)
        else 
            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
            ESX.ShowNotification(_U('error.cancelled'))
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
        if Config.Debug then print('Healing '..Config.HealthPerSecond..' per second, Current Health: '..totalHealth) end
        if Config.RevivePlayer then
            ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(isDead)
                if Config.Debug then if isDead then print('Player dead, reviving...') else print('Player not dead') end end
                if isDead then
                    TriggerServerEvent('dsMedicBag:server:revivePlayer')
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