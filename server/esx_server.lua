if not Config or Config.DetectFramework() ~= 'esx' then return end

local ESX = nil

CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Wait(100)
    end
    
    -- Register callbacks after ESX is loaded
    ESX.RegisterServerCallback('hate-bridge:canCarryItem', function(source, cb, itemName, amount)
        cb(HateBridgeServer.CanCarryItem(source, itemName, amount))
    end)
end)

local serverEvents = Config.ServerEvents['esx']

RegisterNetEvent(serverEvents.playerLoaded, function()
    local source = source
    if Config.Debug then
        print('[hate-bridge] Player loaded:', source)
    end
    TriggerEvent('hate-bridge:server:playerLoaded', source)
end)

AddEventHandler(serverEvents.playerDropped, function(playerId)
    if Config.Debug then
        print('[hate-bridge] Player dropped:', playerId)
    end
    TriggerEvent('hate-bridge:server:playerDropped', playerId)
end)

HateBridgeServer = HateBridgeServer or {}

HateBridgeServer.GetPlayer = function(source)
    return ESX.GetPlayerFromId(source)
end

HateBridgeServer.GetPlayerFromIdentifier = function(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

HateBridgeServer.CreateCallback = function(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

HateBridgeServer.AddMoney = function(source, moneyType, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        moneyType = moneyType or 'money'
        xPlayer.addAccountMoney(moneyType, amount)
        return true
    end
    return false
end

HateBridgeServer.RemoveMoney = function(source, moneyType, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        moneyType = moneyType or 'money'
        local playerMoney = xPlayer.getAccount(moneyType).money
        if playerMoney >= amount then
            xPlayer.removeAccountMoney(moneyType, amount)
            return true
        end
    end
    return false
end

HateBridgeServer.GetPlayerMoney = function(source, moneyType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        moneyType = moneyType or 'money'
        return xPlayer.getAccount(moneyType).money
    end
    return 0
end

HateBridgeServer.AddItem = function(source, itemName, amount, metadata)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem(itemName, amount, metadata)
        return true
    end
    return false
end

HateBridgeServer.RemoveItem = function(source, itemName, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local itemCount = xPlayer.getInventoryItem(itemName).count
        if itemCount >= amount then
            xPlayer.removeInventoryItem(itemName, amount)
            return true
        end
    end
    return false
end

HateBridgeServer.GetItemCount = function(source, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getInventoryItem(itemName).count
    end
    return 0
end

HateBridgeServer.HasItem = function(source, itemName, amount)
    amount = amount or 1
    return HateBridgeServer.GetItemCount(source, itemName) >= amount
end

HateBridgeServer.GetItem = function(source, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local item = xPlayer.getInventoryItem(itemName)
        if item and item.count > 0 then
            return {
                name = item.name,
                amount = item.count,
                count = item.count,
                label = item.label,
                metadata = {},
                info = {},
                type = 'item'
            }
        end
    end
    return nil
end

HateBridgeServer.GetPlayerJob = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.job
    end
    return nil
end

HateBridgeServer.SetPlayerJob = function(source, jobName, grade)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.setJob(jobName, grade)
        return true
    end
    return false
end

HateBridgeServer.GetPlayerIdentifier = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.identifier
    end
    return nil
end

HateBridgeServer.GetPlayerName = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getName()
    end
    return nil
end

HateBridgeServer.CreateUseableItem = function(itemName, cb)
    ESX.RegisterUsableItem(itemName, cb)
end

HateBridgeServer.ShowNotification = function(source, message, type, duration)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.showNotification(message, type, duration)
    end
end

HateBridgeServer.ExecuteQuery = function(query, parameters, cb)
    if cb then
        MySQL.query(query, parameters, cb)
    else
        return MySQL.query.await(query, parameters)
    end
end

HateBridgeServer.ExecuteInsert = function(query, parameters, cb)
    if cb then
        MySQL.insert(query, parameters, cb)
    else
        return MySQL.insert.await(query, parameters)
    end
end

HateBridgeServer.ExecuteUpdate = function(query, parameters, cb)
    if cb then
        MySQL.update(query, parameters, cb)
    else
        return MySQL.update.await(query, parameters)
    end
end

HateBridgeServer.GetItemLabel = function(itemName)
    if GetResourceState('ox_inventory') == 'started' then
        local item = exports.ox_inventory:Items(itemName)
        if item and item.label then
            return item.label
        end
    end
    
    local itemLabel = nil

    if ESX.GetItemLabel then
        itemLabel = ESX.GetItemLabel(itemName)
        if itemLabel and itemLabel ~= itemName and itemLabel ~= "" then
            return itemLabel
        end
    end

    if ESX.Items and ESX.Items[itemName] then
        if ESX.Items[itemName].label then
            return ESX.Items[itemName].label
        end
    end

    if ESX.GetSharedObject then
        local ESXShared = ESX.GetSharedObject()
        if ESXShared and ESXShared.Items and ESXShared.Items[itemName] then
            if ESXShared.Items[itemName].label then
                return ESXShared.Items[itemName].label
            end
        end
    end
    local success, result = pcall(function()
        return exports['es_extended']:getSharedObject().GetItemLabel(itemName)
    end)
    
    if success and result and result ~= itemName and result ~= "" then
        return result
    end

    return itemName:gsub("_", " "):gsub("(%a)([%w_]*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

HateBridgeServer.GetPlayerInventory = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return {}
    end
    
    if GetResourceState('ox_inventory') == 'started' then
        local inventory = {}
        
        local success, oxInventory = pcall(function()
            return exports.ox_inventory:GetInventoryItems(source)
        end)
        
        if success and oxInventory then
            for slot, item in pairs(oxInventory) do
                if item and item.name and item.count and item.count > 0 then
                    inventory[item.name] = {
                        name = item.name,
                        amount = item.count,
                        label = item.label or item.name,
                        slot = slot,
                        info = item.metadata or {}
                    }
                end
            end
            return inventory
        end
    end
    
    local inventory = xPlayer.getInventory(true)
    local formattedItems = {}
    
    for slot, item in pairs(inventory) do
        if item and (item.count or item.amount) and (item.count or item.amount) > 0 then
            formattedItems[slot] = {
                name = item.name,
                label = item.label or item.name,
                amount = item.count,
                count = item.count or item.amount,
                info = item.metadata or {},
                metadata = item.metadata or {},
                type = item.type or 'item',
                slot = slot,
                useable = true,
                image = item.name
            }
        end
    end
    
    return formattedItems
end

HateBridgeServer.HasEnoughMoney = function(source, moneyType, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        moneyType = moneyType or 'money'
        return xPlayer.getAccount(moneyType).money >= amount
    end
    return false
end

HateBridgeServer.HasEnoughItem = function(source, itemName, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local itemCount = xPlayer.getInventoryItem(itemName).count or 0
        return itemCount >= amount
    end
    return false
end

HateBridgeServer.GetPlayerCharName = function(source, useNickname)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        if useNickname then
            return GetPlayerName(source)
        else
            return xPlayer.getName()
        end
    end
    return nil
end

HateBridgeServer.CanCarryItem = function(source, itemName, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        amount = amount or 1
        return xPlayer.canCarryItem(itemName, amount)
    end
    return false
end

HateBridgeServer.GetItemImagePath = function(itemName)
    if not itemName then return nil end

    return Config.GetItemImagePath(itemName)
end

exports('getBridgeServer', function()
    return HateBridgeServer
end)
