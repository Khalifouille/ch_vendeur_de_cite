ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('gerantweed')
AddEventHandler('gerantweed', function()
    local source = source
    exports.ox_inventory:AddItem(source, 'marijuana', 100)
end)

RegisterNetEvent('vendweed', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(amount)
    end
end)