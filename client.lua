local spawned = false
local gerantped

Citizen.CreateThread(function()
    local pedModel = "a_m_y_beach_03"
    local x, y, z = -187.041748, -1586.993408, 34.907715

    RequestModel(GetHashKey(pedModel))
    while not HasModelLoaded(GetHashKey(pedModel)) do
        Citizen.Wait(1)
    end

    if not HasModelLoaded(GetHashKey(pedModel)) then
        return
    end

    if not spawned then
        gerantped = CreatePed(4, GetHashKey(pedModel), x, y, z - 1.0, 0.0, true, true)
        if DoesEntityExist(gerantped) then
        else
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
        SetModelAsNoLongerNeeded(GetHashKey(pedModel))
        TaskStartScenarioInPlace(gerantped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    end
end)