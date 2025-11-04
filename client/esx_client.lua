if not Config or Config.DetectFramework() ~= 'esx' then return end

local ESX = nil
local PlayerData = {}
local isPlayerLoaded = false

CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Wait(100)
    end
    
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    PlayerData = ESX.GetPlayerData()
    isPlayerLoaded = true
    TriggerEvent('hate-bridge:client:playerLoaded', PlayerData)
end)

local events = Config.FrameworkEvents['esx']

RegisterNetEvent(events.playerLoaded, function(xPlayer)
    PlayerData = xPlayer
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
    moneyType = moneyType or 'money'
    if PlayerData.accounts then
        for _, account in pairs(PlayerData.accounts) do
            if account.name == moneyType then
                return account.money or 0
            end
        end
    end
    return 0
end

HateBridge.TriggerCallback = function(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
end

HateBridge.ShowNotification = function(message, type, duration)
    type = type or 'info'
    duration = duration or 5000
    
    if type == 'success' then
        ESX.ShowNotification(message, 'success', duration)
    elseif type == 'error' then
        ESX.ShowNotification(message, 'error', duration)
    else
        ESX.ShowNotification(message, 'info', duration)
    end
end

HateBridge.ProgressBar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, onFinish, onCancel)
    local progressBarType = Config.DetectProgressBarSystem()
    
    if progressBarType == 'esx_progressbar' then
        local esxAnimation = {}
        if animation and animation.dict and animation.anim then
            esxAnimation = {
                animDict = animation.dict,
                anim = animation.anim,
                flags = animation.flags or 1
            }
        end
        
        if Config.Debug then
            print("[hate-bridge DEBUG] ESX Animation format:", json.encode(esxAnimation))
        end
        
        exports['esx_progressbar']:progressBar({
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
            animation = esxAnimation,
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
        
        if Config.Debug then
            print("[hate-bridge DEBUG] ox_lib Animation format:", json.encode(oxAnimation))
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
    if PlayerData.inventory then
        for _, item in pairs(PlayerData.inventory) do
            if item.name == itemName then
                return item.count or 0
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
        if options.options then
            exports['qb-target']:AddTargetEntity(entity, options)
        else
            exports['qb-target']:AddTargetEntity(entity, {
                options = options,
                distance = options.distance or 2.5
            })
        end
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
        if options.options then
            exports['qb-target']:AddTargetModel(models, options)
        else
            exports['qb-target']:AddTargetModel(models, {
                options = options,
                distance = options.distance or 2.5
            })
        end
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
    elseif targetSystem == 'qtarget' then
        exports.qtarget:AddCircleZone(name, coords, radius, targetOptions or {}, {
            options = options,
            distance = targetOptions and targetOptions.distance or 2.5
        })
    end
end

HateBridge.RemoveTargetZone = function(name)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:removeZone(name)
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:RemoveZone(name)
    elseif targetSystem == 'qtarget' then
        exports.qtarget:RemoveZone(name)
    end
end

HateBridge.CanCarryItem = function(itemName, amount, cb)
    if cb then
        ESX.TriggerServerCallback('hate-bridge:canCarryItem', cb, itemName, amount)
    else
        local result = nil
        ESX.TriggerServerCallback('hate-bridge:canCarryItem', function(canCarry)
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
