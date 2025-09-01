if not Config or Config.DetectFramework() ~= 'qbox' then return end

local QBX = exports['qbx_core']:GetCoreObject()

local serverEvents = Config.ServerEvents['qbox']

RegisterNetEvent(serverEvents.playerLoaded, function()
    local source = source
    if Config.Debug then
        print('[hate-bridge] Player loaded:', source)
    end
    TriggerEvent('hate-bridge:server:playerLoaded', source)
end)

RegisterNetEvent(serverEvents.playerDropped, function()
    local source = source
    if Config.Debug then
        print('[hate-bridge] Player logout:', source)
    end
    TriggerEvent('hate-bridge:server:playerDropped', source)
end)

HateBridgeServer = HateBridgeServer or {}

HateBridgeServer.GetPlayer = function(source)
    return QBX.Functions.GetPlayer(source)
end

HateBridgeServer.GetPlayerFromIdentifier = function(identifier)
    return QBX.Functions.GetPlayerByCitizenId(identifier)
end

HateBridgeServer.CreateCallback = function(name, cb)
    QBX.Functions.CreateCallback(name, cb)
end

HateBridgeServer.AddMoney = function(source, moneyType, amount)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        moneyType = moneyType or 'cash'
        if moneyType == 'money' then moneyType = 'cash' end
        Player.Functions.AddMoney(moneyType, amount)
        return true
    end
    return false
end

HateBridgeServer.RemoveMoney = function(source, moneyType, amount)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        moneyType = moneyType or 'cash'
        if moneyType == 'money' then moneyType = 'cash' end
        local playerMoney = Player.Functions.GetMoney(moneyType)
        if playerMoney >= amount then
            Player.Functions.RemoveMoney(moneyType, amount)
            return true
        end
    end
    return false
end

HateBridgeServer.GetPlayerMoney = function(source, moneyType)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        moneyType = moneyType or 'cash'
        if moneyType == 'money' then moneyType = 'cash' end
        return Player.Functions.GetMoney(moneyType)
    end
    return 0
end

HateBridgeServer.AddItem = function(source, itemName, amount, metadata)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        Player.Functions.AddItem(itemName, amount, false, metadata)
        return true
    end
    return false
end

HateBridgeServer.RemoveItem = function(source, itemName, amount)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        local item = Player.Functions.GetItemByName(itemName)
        if item and item.amount >= amount then
            Player.Functions.RemoveItem(itemName, amount)
            return true
        end
    end
    return false
end

HateBridgeServer.GetItemCount = function(source, itemName)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        local item = Player.Functions.GetItemByName(itemName)
        return item and item.amount or 0
    end
    return 0
end

HateBridgeServer.HasItem = function(source, itemName, amount)
    amount = amount or 1
    return HateBridgeServer.GetItemCount(source, itemName) >= amount
end

HateBridgeServer.GetItem = function(source, itemName)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        local item = Player.Functions.GetItemByName(itemName)
        if item and item.amount > 0 then
            return {
                name = item.name,
                amount = item.amount,
                count = item.amount,
                label = item.label,
                metadata = item.info or {},
                info = item.info or {},
                type = item.type or 'item'
            }
        end
    end
    return nil
end

HateBridgeServer.GetPlayerJob = function(source)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.job
    end
    return nil
end

HateBridgeServer.SetPlayerJob = function(source, jobName, grade)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        Player.Functions.SetJob(jobName, grade)
        return true
    end
    return false
end

HateBridgeServer.GetPlayerIdentifier = function(source)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.citizenid
    end
    return nil
end

HateBridgeServer.GetPlayerName = function(source)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    end
    return nil
end

HateBridgeServer.CreateUseableItem = function(itemName, cb)
    QBX.Functions.CreateUseableItem(itemName, cb)
end

HateBridgeServer.ShowNotification = function(source, message, type, duration)
    TriggerClientEvent('qbx_core:notify', source, message, type, duration)
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
    
    local item = QBX.Shared.Items[itemName]
    if item and item.label then
        return item.label
    end
    
    return itemName:gsub("_", " "):gsub("(%a)([%w_]*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

HateBridgeServer.GetPlayerInventory = function(source)
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then
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
    
    local items = Player.PlayerData.items
    local formattedItems = {}
    
    if items then
        for slot, item in pairs(items) do
            if item and item.name and (item.amount or item.count) and (item.amount or item.count) > 0 then
                formattedItems[slot] = {
                    name = item.name,
                    label = item.label or item.name,
                    amount = item.amount,
                    count = item.amount or item.count,
                    info = item.info or {},
                    metadata = item.info or {},
                    type = item.type or 'item',
                    slot = slot,
                    useable = item.useable or true,
                    image = item.image or item.name
                }
            end
        end
    end
    
    return formattedItems
end

HateBridgeServer.HasEnoughMoney = function(source, moneyType, amount)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        moneyType = moneyType or 'cash'
        if moneyType == 'money' then moneyType = 'cash' end
        return Player.Functions.GetMoney(moneyType) >= amount
    end
    return false
end

HateBridgeServer.HasEnoughItem = function(source, itemName, amount)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        local item = Player.Functions.GetItemByName(itemName)
        return item and item.amount >= amount
    end
    return false
end

HateBridgeServer.GetPlayerCharName = function(source, useNickname)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        if useNickname then
            return GetPlayerName(source)
        else
            return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        end
    end
    return nil
end

HateBridgeServer.CanCarryItem = function(source, itemName, amount)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        amount = amount or 1
        local itemData = QBX.Shared.Items[itemName:lower()]
        if itemData then
            return Player.Functions.CanAddItem(itemName, amount)
        end
    end
    return false
end

QBX.Functions.CreateCallback('hate-bridge:canCarryItem', function(source, cb, itemName, amount)
    cb(HateBridgeServer.CanCarryItem(source, itemName, amount))
end)

HateBridgeServer.GetItemImagePath = function(itemName)
    if not itemName then return nil end

    return Config.GetItemImagePath(itemName)
end

exports('getBridgeServer', function()
    return HateBridgeServer
end)
