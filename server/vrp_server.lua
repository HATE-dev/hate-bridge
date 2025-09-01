if not Config or Config.DetectFramework() ~= 'vrp' then return end

local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP","vRP")

local serverEvents = Config.ServerEvents['vrp']

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
        print('[hate-bridge] Player dropped:', source)
    end
    TriggerEvent('hate-bridge:server:playerDropped', source)
end)

HateBridgeServer = HateBridgeServer or {}

HateBridgeServer.GetPlayer = function(source)
    local userId = vRP.getUserId({source})
    if userId then
        return {
            source = source,
            userId = userId,
            getJob = function()
                local job = vRP.getUserGroupByType({userId, "job"})
                return job or "unemployed"
            end,
            getName = function()
                return GetPlayerName(source)
            end,
            getIdentifier = function()
                return vRP.getUserId({source})
            end
        }
    end
    return nil
end

HateBridgeServer.GetPlayerFromIdentifier = function(identifier)
    -- VRP uses user_id as identifier
    local userId = tonumber(identifier)
    if userId then
        local source = vRP.getUserSource({userId})
        if source then
            return HateBridgeServer.GetPlayer(source)
        end
    end
    return nil
end

HateBridgeServer.CreateCallback = function(name, cb)
    -- Custom callback system for VRP
    RegisterNetEvent('hate-bridge:vrp:callback', function(callbackName, args)
        local source = source
        if callbackName == name then
            local result = cb(source, table.unpack(args or {}))
            TriggerClientEvent('hate-bridge:vrp:callback:' .. name, source, result)
        end
    end)
end

HateBridgeServer.AddMoney = function(source, moneyType, amount)
    local userId = vRP.getUserId({source})
    if userId then
        moneyType = moneyType or 'wallet'
        if moneyType == 'money' or moneyType == 'wallet' then
            vRP.giveMoney({userId, amount})
            return true
        elseif moneyType == 'bank' then
            vRP.giveBankMoney({userId, amount})
            return true
        end
    end
    return false
end

HateBridgeServer.RemoveMoney = function(source, moneyType, amount)
    local userId = vRP.getUserId({source})
    if userId then
        moneyType = moneyType or 'wallet'
        if moneyType == 'money' or moneyType == 'wallet' then
            local playerMoney = vRP.getMoney({userId})
            if playerMoney >= amount then
                vRP.tryPayment({userId, amount})
                return true
            end
        elseif moneyType == 'bank' then
            local bankMoney = vRP.getBankMoney({userId})
            if bankMoney >= amount then
                vRP.setBankMoney({userId, bankMoney - amount})
                return true
            end
        end
    end
    return false
end

HateBridgeServer.GetPlayerMoney = function(source, moneyType)
    local userId = vRP.getUserId({source})
    if userId then
        moneyType = moneyType or 'wallet'
        if moneyType == 'money' or moneyType == 'wallet' then
            return vRP.getMoney({userId}) or 0
        elseif moneyType == 'bank' then
            return vRP.getBankMoney({userId}) or 0
        end
    end
    return 0
end

HateBridgeServer.AddItem = function(source, itemName, amount, metadata)
    local userId = vRP.getUserId({source})
    if userId then
        vRP.giveInventoryItem({userId, itemName, amount, true})
        return true
    end
    return false
end

HateBridgeServer.RemoveItem = function(source, itemName, amount)
    local userId = vRP.getUserId({source})
    if userId then
        local itemCount = vRP.getInventoryItemAmount({userId, itemName})
        if itemCount >= amount then
            vRP.tryGetInventoryItem({userId, itemName, amount, true})
            return true
        end
    end
    return false
end

HateBridgeServer.GetItemCount = function(source, itemName)
    local userId = vRP.getUserId({source})
    if userId then
        return vRP.getInventoryItemAmount({userId, itemName}) or 0
    end
    return 0
end

HateBridgeServer.HasItem = function(source, itemName, amount)
    amount = amount or 1
    return HateBridgeServer.GetItemCount(source, itemName) >= amount
end

HateBridgeServer.GetItem = function(source, itemName)
    local userId = vRP.getUserId({source})
    if userId then
        local itemCount = vRP.getInventoryItemAmount({userId, itemName})
        if itemCount > 0 then
            return {
                name = itemName,
                amount = itemCount,
                count = itemCount,
                label = itemName,
                metadata = {},
                info = {},
                type = 'item'
            }
        end
    end
    return nil
end

HateBridgeServer.CanCarryItem = function(source, itemName, amount)
    local userId = vRP.getUserId({source})
    if userId then
        local weight = vRP.getInventoryWeight({userId})
        local maxWeight = vRP.getInventoryMaxWeight({userId})
        local itemWeight = vRP.getItemWeight({itemName}) * amount
        
        return (weight + itemWeight) <= maxWeight
    end
    return false
end

HateBridgeServer.GetPlayerJob = function(source)
    local userId = vRP.getUserId({source})
    if userId then
        local job = vRP.getUserGroupByType({userId, "job"})
        return {
            name = job or "unemployed",
            grade = 0,
            label = job or "Unemployed"
        }
    end
    return { name = "unemployed", grade = 0, label = "Unemployed" }
end

HateBridgeServer.SetPlayerJob = function(source, jobName, grade)
    local userId = vRP.getUserId({source})
    if userId then
        -- Remove current job
        local currentJob = vRP.getUserGroupByType({userId, "job"})
        if currentJob then
            vRP.removeUserGroup({userId, currentJob})
        end
        
        -- Add new job
        vRP.addUserGroup({userId, jobName})
        return true
    end
    return false
end

HateBridgeServer.GetPlayerGroup = function(source)
    local userId = vRP.getUserId({source})
    if userId then
        return vRP.getUserGroups({userId}) or {}
    end
    return {}
end

HateBridgeServer.HasPermission = function(source, permission)
    local userId = vRP.getUserId({source})
    if userId then
        return vRP.hasPermission({userId, permission})
    end
    return false
end

HateBridgeServer.ShowNotification = function(source, message, type, duration)
    vRPclient.notify(source, {message})
end

HateBridgeServer.GetPlayerName = function(source)
    return GetPlayerName(source)
end

HateBridgeServer.GetPlayerIdentifier = function(source)
    local userId = vRP.getUserId({source})
    return tostring(userId)
end

HateBridgeServer.IsPlayerOnline = function(identifier)
    local userId = tonumber(identifier)
    if userId then
        local source = vRP.getUserSource({userId})
        return source ~= nil
    end
    return false
end

HateBridgeServer.GetOnlinePlayers = function()
    local players = {}
    local users = vRP.getUsers({})
    
    for userId, source in pairs(users) do
        table.insert(players, {
            source = source,
            identifier = tostring(userId),
            name = GetPlayerName(source)
        })
    end
    
    return players
end

RegisterNetEvent('hate-bridge:vrp:canCarryItem', function(itemName, amount)
    local source = source
    local canCarry = HateBridgeServer.CanCarryItem(source, itemName, amount)
    TriggerClientEvent('hate-bridge:vrp:canCarryItem:response', source, canCarry)
end)

HateBridgeServer.CreateCallback('hate-bridge:canCarryItem', function(source, itemName, amount)
    return HateBridgeServer.CanCarryItem(source, itemName, amount)
end)

HateBridgeServer.CreateCallback('hate-bridge:getPlayerData', function(source)
    local player = HateBridgeServer.GetPlayer(source)
    if player then
        return {
            identifier = player.getIdentifier(),
            name = player.getName(),
            job = player.getJob(),
            money = {
                wallet = HateBridgeServer.GetPlayerMoney(source, 'wallet'),
                bank = HateBridgeServer.GetPlayerMoney(source, 'bank')
            }
        }
    end
    return nil
end)

HateBridgeServer.CreateCallback('hate-bridge:getItemCount', function(source, itemName)
    return HateBridgeServer.GetItemCount(source, itemName)
end)

HateBridgeServer.CreateCallback('hate-bridge:hasItem', function(source, itemName, amount)
    return HateBridgeServer.HasItem(source, itemName, amount)
end)

exports('getServerBridge', function()
    return HateBridgeServer
end)

AddEventHandler('hate-bridge:getServerObject', function(cb)
    cb(HateBridgeServer)
end)
