if not Config or Config.DetectFramework() ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isPlayerLoaded = false
local events = Config.FrameworkEvents['qb']

RegisterNetEvent(events.playerLoaded, function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isPlayerLoaded = true
    TriggerEvent('hate-bridge:client:playerLoaded', PlayerData)
end)

RegisterNetEvent(events.playerUnload, function()
    PlayerData = {}
    isPlayerLoaded = false
    TriggerEvent('hate-bridge:client:playerUnloaded')
end)

RegisterNetEvent(events.setJob, function(job)
    PlayerData.job = job
    TriggerEvent('hate-bridge:client:jobUpdate', job)
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

HateBridge = HateBridge or {}
HateBridge.GetPlayerData = function()
    return PlayerData
end

HateBridge.IsPlayerLoaded = function()
    return isPlayerLoaded
end

HateBridge.GetPlayerJob = function()
    return PlayerData.job or {}
end

HateBridge.GetPlayerMoney = function(moneyType)
    moneyType = moneyType or 'cash'
    if moneyType == 'money' then moneyType = 'cash' end
    
    if PlayerData.money and PlayerData.money[moneyType] then
        return PlayerData.money[moneyType]
    end
    return 0
end

HateBridge.TriggerCallback = function(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end

HateBridge.ShowNotification = function(message, type, duration)
    type = type or 'primary'
    duration = duration or 5000
    
    QBCore.Functions.Notify(message, type, duration)
end

HateBridge.ProgressBar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, onFinish, onCancel)
    -- Use config to detect progress bar system
    local progressBarType = Config.DetectProgressBarSystem()
    
    if progressBarType == 'qb-progressbar' then
        -- QB progressbar expects animation in different format
        local qbAnimation = {}
        if animation and animation.dict and animation.anim then
            qbAnimation = {
                animDict = animation.dict,
                anim = animation.anim,
                flags = animation.flags or 1
            }
        end
        
        exports['qb-progressbar']:Progress({
            name = name,
            duration = duration,
            label = label,
            useWhileDead = useWhileDead or false,
            canCancel = canCancel or false,
            controlDisables = disableControls or {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = qbAnimation,
            prop = prop or {},
        }, function(cancelled)
            if not cancelled and onFinish then
                onFinish()
            elseif cancelled and onCancel then
                onCancel()
            end
        end)
    elseif progressBarType == 'ox_lib' then
        local oxAnimation = {}
        if animation and animation.dict and animation.anim then
            oxAnimation = {
                dict = animation.dict,
                clip = animation.anim,
                flag = animation.flags or 1
            }
        end
        
        if lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = useWhileDead or false,
            canCancel = canCancel or false,
            disable = disableControls or {
                car = true,
                move = true,
                combat = true
            },
            anim = oxAnimation,
            prop = prop or {}
        }) then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
    else
        if onFinish then
            SetTimeout(duration, onFinish)
        end
    end
end

HateBridge.GetItemCount = function(itemName)
    if PlayerData.items then
        for _, item in pairs(PlayerData.items) do
            if item.name == itemName then
                return item.amount or 0
            end
        end
    end
    return 0
end

HateBridge.HasItem = function(itemName, amount)
    amount = amount or 1
    return HateBridge.GetItemCount(itemName) >= amount
end

HateBridge.GetItemImagePath = function(itemName)
    if not itemName then return nil end

    return Config.GetItemImagePath(itemName)
end

HateBridge.AddTargetEntity = function(entity, options)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:addLocalEntity(entity, options.options or options)
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:AddTargetEntity(entity, options)
    elseif targetSystem == 'qtarget' then
        exports.qtarget:AddTargetEntity(entity, options)
    end
end

HateBridge.RemoveTargetEntity = function(entity, optionNames)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:removeLocalEntity(entity, optionNames)
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(entity, optionNames)
    elseif targetSystem == 'qtarget' then
        exports.qtarget:RemoveTargetEntity(entity, optionNames)
    end
end

HateBridge.AddTargetModel = function(models, options)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:addModel(models, options.options or options)
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:AddTargetModel(models, options)
    elseif targetSystem == 'qtarget' then
        exports.qtarget:AddTargetModel(models, options)
    end
end

HateBridge.AddGlobalPed = function(options)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:addGlobalPed(options.options or options)
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:AddGlobalPed(options)
    elseif targetSystem == 'qtarget' then
        exports.qtarget:AddGlobalPed(options)
    end
end

HateBridge.RemoveGlobalPed = function(optionNames)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:removeGlobalPed(optionNames)
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:RemoveGlobalPed(optionNames)
    elseif targetSystem == 'qtarget' then
        exports.qtarget:RemoveGlobalPed(optionNames)
    end
end

HateBridge.RemoveTargetModel = function(models, optionNames)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:removeModel(models, optionNames)
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:RemoveTargetModel(models, optionNames)
    elseif targetSystem == 'qtarget' then
        exports.qtarget:RemoveTargetModel(models, optionNames)
    end
end

HateBridge.AddTargetZone = function(name, coords, radius, options, targetOptions)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = radius,
            debug = targetOptions and targetOptions.debug or false,
            options = options
        })
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:AddCircleZone(name, coords, radius, targetOptions or {}, {
            options = options,
            distance = targetOptions and targetOptions.distance or 2.5
        })
    elseif GetResourceState('qtarget') == 'started' then
        exports.qtarget:AddCircleZone(name, coords, radius, targetOptions or {}, {
            options = options,
            distance = targetOptions and targetOptions.distance or 2.5
        })
    end
end

HateBridge.RemoveTargetZone = function(name)
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeZone(name)
    elseif GetResourceState('qb-target') == 'started' then
        exports['qb-target']:RemoveZone(name)
    elseif GetResourceState('qtarget') == 'started' then
        exports.qtarget:RemoveZone(name)
    end
end

HateBridge.CanCarryItem = function(itemName, amount, cb)
    if cb then
        QBCore.Functions.TriggerCallback('hate-bridge:canCarryItem', cb, itemName, amount)
    else
        local result = nil
        QBCore.Functions.TriggerCallback('hate-bridge:canCarryItem', function(canCarry)
            result = canCarry
        end, itemName, amount)
        
        local timeout = 0
        while result == nil and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end
        
        return result or false
    end
end

AddEventHandler('hate-bridge:getObject', function(cb)
    cb(HateBridge)
end)

exports('getBridge', function()
    return HateBridge
end)
