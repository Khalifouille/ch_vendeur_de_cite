ESX = exports['es_extended']:getSharedObject()

local spawned = false
local gerantped, chair
local chairX, chairY, chairZ = -197.775818, -1605.547241, 34.385376
local chairHeading = 75.0
local pnjModels = {"a_m_y_business_01", "a_m_y_business_02", "a_m_y_business_03"}
local pnjList = {}
local tapinage = false
local animDict = "mp_ped_interaction"
local animName = "hugs_guy_a"

local function LoadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(1)
    end
end

Citizen.CreateThread(function()
    local pedModel = "a_m_y_beach_03"
    local x, y, z = -187.041748, -1586.993408, 34.907715
    local heading = 235.0

    LoadModel(pedModel)

    if not spawned then
        gerantped = CreatePed(4, GetHashKey(pedModel), x, y, z - 1.0, heading, true, true)
        if DoesEntityExist(gerantped) then
            spawned = true
            FreezeEntityPosition(gerantped, true)
            NetworkRegisterEntityAsNetworked(gerantped)
            SetEntityAsMissionEntity(gerantped, true, true)
            SetPedFleeAttributes(gerantped, 0, 0)
            SetPedCombatAttributes(gerantped, 46, 1)
            SetPedArmour(gerantped, 100)
            SetPedMaxHealth(gerantped, 200)
            SetPedRelationshipGroupHash(gerantped, GetHashKey("CIVMALE"))
            SetBlockingOfNonTemporaryEvents(gerantped, true)
            SetPedCanRagdoll(gerantped, false)
            SetEntityInvincible(gerantped, true)
            TaskStartScenarioInPlace(gerantped, "WORLD_HUMAN_SMOKING", 0, true)
        end
        SetModelAsNoLongerNeeded(GetHashKey(pedModel))
    end
end)

local function spawnPNJ()
    local model = pnjModels[1]
    LoadModel(model)
    local pnj = CreatePed(4, GetHashKey(model), chairX + 25, chairY, chairZ, chairHeading, true, true)
    table.insert(pnjList, pnj)

    local direction = GetEntityForwardVector(chair)
    TaskGoStraightToCoord(pnj, chairX - direction.x, chairY - direction.y, chairZ, 3.0, -1, chairHeading, 0)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        spawnPNJ()
    end
end)
local function SellWeedToPNJ(playerCoords)
    for _, pnj in ipairs(pnjList) do
        if DoesEntityExist(pnj) then
            local pnjCoords = GetEntityCoords(pnj)
            local distanceToPNJ = #(pnjCoords - vector3(chairX, chairY, chairZ))
            local distanceToPlayer = #(pnjCoords - playerCoords)

            if distanceToPNJ < 2.0 and distanceToPlayer < 2.0 then
                DrawText3D(pnjCoords.x, pnjCoords.y + 0.2, pnjCoords.z + 1.0, "[E] Vendre de la weed")

                if IsControlJustReleased(0, 38) then
                    ESX.TriggerServerCallback('ox_inventory:getItemAmount', function(amount)
                        if amount > 0 then
                            local quantity = math.random(1, math.min(10, amount))
                            local pricePerUnit = math.random(40, 70)
                            local totalPrice = quantity * pricePerUnit

                            TriggerServerEvent('ox_inventory:removeItem', 'marijuana', quantity)
                            TriggerServerEvent('vendweed', totalPrice)
                            ShowNotification("Vous avez vendu " .. quantity .. " pochons de weed pour $" .. totalPrice .. " (" .. pricePerUnit .. "$ chacun).")

                            local playerPed = PlayerPedId()
                            local playerHeading = GetEntityHeading(playerPed)
                            SetEntityHeading(pnj, -playerHeading)

                            RequestAnimDict(animDict)
                            while not HasAnimDictLoaded(animDict) do
                                Citizen.Wait(100)
                            end

                            TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 3000, 49, 0, false, false, false, false, false, false)
                            TaskPlayAnim(pnj, animDict, animName, 8.0, -8.0, 3000, 49, 0, false, false, false, false, false, false)
                            Citizen.Wait(3000)

                            DeleteEntity(pnj)
                        else
                            ShowNotification("Vous n'avez pas de marijuana à vendre.")
                        end
                    end, 'marijuana')
                end
            end
        end
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
                if tapinage then
                    DrawText3D(coords.x - 0.45, coords.y, coords.z + 1, "[E] Fini le tapinage")
                else
                    DrawText3D(coords.x - 0.45, coords.y, coords.z + 1, "[E] Interagir")
                end

                if IsControlJustReleased(0, 38) then
                    if tapinage then
                        TriggerServerEvent('findutp') 
                        ShowNotification("Allez donne la sacoche !")
                        tapinage = false
                    else
                        TriggerServerEvent('gerantweed', 500)
                        local chairModel = "hei_prop_hei_skid_chair"
                        LoadModel(chairModel)
                        chair = CreateObject(GetHashKey(chairModel), chairX, chairY, chairZ, true, true, true)
                        SetEntityHeading(chair, chairHeading)
                        FreezeEntityPosition(chair, true)
                        PlaceObjectOnGroundProperly(chair)
                        ShowNotification("Une chaise a été placée.")
                        spawnPNJ()
                        tapinage = true
                    end
                end
            end

            local playerCoords = GetEntityCoords(PlayerPedId())
            SellWeedToPNJ(playerCoords)
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = #(p - vector3(x, y, z))
    local scale = (1 / distance) * 2.5 * (1 / GetGameplayCamFov()) * 100

    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end