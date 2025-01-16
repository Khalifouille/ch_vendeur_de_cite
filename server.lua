ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('gerantweed')
AddEventHandler('gerantweed', function()
    local source = source
    exports.ox_inventory:AddItem(source, 'marijuana', 100)
end)

RegisterNetEvent('findutp')
AddEventHandler('findutp', function()
    local source = source
    exports.ox_inventory:RemoveItem(source, 'marijuana', 1000)
end)

RegisterNetEvent('vendweed', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(amount)
    end
end)

ESX.RegisterServerCallback('ox_inventory:getItemAmount', function(source, cb, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local itemCount = xPlayer.getInventoryItem(itemName).count
        cb(itemCount)
    else
        cb(0)
    end
end)