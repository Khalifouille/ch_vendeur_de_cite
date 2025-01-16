ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('gerantweed')
AddEventHandler('gerantweed', function()
    local source = source
    exports.ox_inventory:AddItem(source, 'marijuana', 500)
end)

RegisterNetEvent('sellWeed:addMoney', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(amount)
    end
end)