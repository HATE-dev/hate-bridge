if not Config or Config.DetectFramework() ~= 'vrp' then return end

local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP","vRP")

local PlayerData = {}
local isPlayerLoaded = false

CreateThread(function()
    while not vRP.getUserId do
        Wait(100)
    end
    
    local userId = vRP.getUserId()
    while not userId do
        userId = vRP.getUserId()
        Wait(100)
    end
    
    PlayerData.id = userId
    isPlayerLoaded = true
    TriggerEvent('hate-bridge:client:playerLoaded', PlayerData)
end)

local events = Config.FrameworkEvents['vrp']

RegisterNetEvent(events.playerLoaded, function()
    local userId = vRP.getUserId()
    if userId then
        PlayerData.id = userId
        isPlayerLoaded = true
        TriggerEvent('hate-bridge:client:playerLoaded', PlayerData)
    end
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

-- Helper function to convert ox_target options to qb-target format
local function ConvertOptionsForQBTarget(options)
    if type(options) ~= 'table' then return options end
    
    local converted = {}
    for i, option in ipairs(options) do
        local qbOption = {}
        
        -- Copy all properties
        for key, value in pairs(option) do
            qbOption[key] = value
        end
        
        -- Convert onSelect to action (qb-target uses action instead of onSelect)
        if option.onSelect and not option.action then
            qbOption.action = option.onSelect
            qbOption.onSelect = nil
        end
        
        converted[i] = qbOption
    end
    
    return converted
end

HateBridge = HateBridge or {}

HateBridge.GetPlayerData = function()
    return PlayerData
end

HateBridge.IsPlayerLoaded = function()
    return isPlayerLoaded
end

HateBridge.GetPlayerJob = function()
    if PlayerData.id then
        local job = vRP.getUserGroupByType(PlayerData.id, "job")
        return { name = job, grade = 0 }
    end
    return {}
end

HateBridge.GetPlayerMoney = function(moneyType)
    moneyType = moneyType or 'wallet'
    if PlayerData.id then
        if moneyType == 'money' or moneyType == 'wallet' then
            return vRP.getMoney(PlayerData.id) or 0
        elseif moneyType == 'bank' then
            return vRP.getBankMoney(PlayerData.id) or 0
        end
    end
    return 0
end

HateBridge.TriggerCallback = function(name, cb, ...)
    local args = {...}
    TriggerServerEvent('hate-bridge:vrp:callback', name, args)
    local callbackData = nil
    
    local callbackHandler = function(data)
        callbackData = data
    end
    
    local eventName = 'hate-bridge:vrp:callback:' .. name
    RegisterNetEvent(eventName, callbackHandler)
    
    local timeout = 0
    while callbackData == nil and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    
    RemoveEventHandler(eventName, callbackHandler)
    
    if cb then
        cb(callbackData)
    end
    
    return callbackData
end

HateBridge.ShowNotification = function(message, type, duration)
    type = type or 'info'
    duration = duration or 5000
    
    if vRPclient.notify then
        vRPclient.notify(PlayerId(), {message})
    else
        -- Fallback notification
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(0, 1)
    end
end

HateBridge.ProgressBar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, onFinish, onCancel)
    local progressBarType = Config.DetectProgressBarSystem()
    
    if progressBarType == 'ox_lib' then
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
        -- VRP native progress or fallback
        if vRPclient.progress then
            vRPclient.progress(PlayerId(), {duration})
            SetTimeout(duration, function()
                if onFinish then onFinish() end
            end)
        else
            -- Simple fallback
            if onFinish then
                SetTimeout(duration, onFinish)
            end
        end
    end
end

HateBridge.GetItemCount = function(itemName)
    if PlayerData.id then
        return vRP.getInventoryItemAmount(PlayerData.id, itemName) or 0
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
        local optionsArray = options.options or options
        local convertedOptions = ConvertOptionsForQBTarget(optionsArray)
        
        exports['qb-target']:AddTargetEntity(entity, {
            options = convertedOptions,
            distance = options.distance or 2.5
        })
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
        local optionsArray = options.options or options
        local convertedOptions = ConvertOptionsForQBTarget(optionsArray)
        
        exports['qb-target']:AddTargetModel(models, {
            options = convertedOptions,
            distance = options.distance or 2.5
        })
    elseif targetSystem == 'qtarget' then
        exports.qtarget:AddTargetModel(models, options)
    end
end

HateBridge.AddGlobalPed = function(options)
    local targetSystem = Config.DetectTargetSystem()
    if targetSystem == 'ox_target' then
        exports.ox_target:addGlobalPed(options.options or options)
    elseif targetSystem == 'qb-target' then
        local optionsArray = options.options or options
        local convertedOptions = ConvertOptionsForQBTarget(optionsArray)
        
        exports['qb-target']:AddGlobalPed({
            options = convertedOptions,
            distance = options.distance or 2.5
        })
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
        TriggerServerEvent('hate-bridge:vrp:canCarryItem', itemName, amount)
        local callbackData = nil
        
        local callbackHandler = function(canCarry)
            callbackData = canCarry
        end
        
        local eventName = 'hate-bridge:vrp:canCarryItem:response'
        RegisterNetEvent(eventName, callbackHandler)
        
        local timeout = 0
        while callbackData == nil and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end
        
        RemoveEventHandler(eventName, callbackHandler)
        cb(callbackData or false)
    else
        local result = nil
        TriggerServerEvent('hate-bridge:vrp:canCarryItem', itemName, amount)
        
        RegisterNetEvent('hate-bridge:vrp:canCarryItem:response', function(canCarry)
            result = canCarry
        end)
        
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
