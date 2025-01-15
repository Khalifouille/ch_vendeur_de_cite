local spawned = false
local gerantped
local chair
local chairX, chairY, chairZ = -197.775818, -1605.547241, 34.385376
local chairHeading = 75.0
local pnjModels = {"a_m_y_business_01", "a_m_y_business_02", "a_m_y_business_03"}
local pnjList = {test}

Citizen.CreateThread(function()
    local pedModel = "a_m_y_beach_03"
    local x, y, z = -187.041748, -1586.993408, 34.907715
    local heading = 235.0

    RequestModel(GetHashKey(pedModel))
    while not HasModelLoaded(GetHashKey(pedModel)) do
        Citizen.Wait(1)
    end

    if not HasModelLoaded(GetHashKey(pedModel)) then
        return
    end

    if not spawned then
        gerantped = CreatePed(4, GetHashKey(pedModel), x, y, z - 1.0, heading, true, true)
        if not DoesEntityExist(gerantped) then
            return
        end

        FreezeEntityPosition(gerantped, true)
        if not NetworkGetEntityIsNetworked(gerantped) then
            NetworkRegisterEntityAsNetworked(gerantped)
        end
        spawned = true

        SetEntityAsMissionEntity(gerantped, true, true)
        SetPedFleeAttributes(gerantped, 0, 0)
        SetPedCombatAttributes(gerantped, 46, 1)
        SetPedArmour(gerantped, 100)
        SetPedMaxHealth(gerantped, 200)
        SetPedRelationshipGroupHash(gerantped, GetHashKey("CIVMALE"))
        SetBlockingOfNonTemporaryEvents(gerantped, true)
        SetPedCanRagdoll(gerantped, false)
        SetEntityInvincible(gerantped, true)
        SetModelAsNoLongerNeeded(GetHashKey(pedModel))
        TaskStartScenarioInPlace(gerantped, "WORLD_HUMAN_SMOKING", 0, true)
    end
end)

function spawnPNJ()
    for _, model in ipairs(pnjModels) do
        RequestModel(GetHashKey(model))
        while not HasModelLoaded(GetHashKey(model)) do
            Citizen.Wait(1)
        end

        local pnj = CreatePed(4, GetHashKey(model), chairX + 25, chairY, chairZ, chairHeading, true, true)
        table.insert(pnjList, pnj)

        TaskGoStraightToCoord(pnj, chairX, chairY, chairZ, 1.0, -1, chairHeading, 0)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if spawned and DoesEntityExist(gerantped) then
            local coords = GetEntityCoords(gerantped)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z)

            if distance < 1.5 then
                DrawText3D(coords.x - 0.45, coords.y, coords.z + 1, "[E] Interagir")

                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('gerantweed', 500)

                    local chairModel = "hei_prop_hei_skid_chair"

                    RequestModel(chairModel)
                    while not HasModelLoaded(chairModel) do
                        Citizen.Wait(1)
                    end

                    chair = CreateObject(GetHashKey(chairModel), chairX, chairY, chairZ, true, true, true)
                    SetEntityHeading(chair, chairHeading)
                    FreezeEntityPosition(chair, true)
                    PlaceObjectOnGroundProperly(chair)
                    ShowNotification("Une chaise a été placée.")
                    spawnPNJ()
                end
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = Vdist(p.x, p.y, p.z, x, y, z)
    local scale = (1 / distance) * 2.5
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        -- DrawRect(_x, _y + 0.0125 * scale, 0.005 + factor, 0.03 * scale, 0, 0, 0, 100)
    end
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end