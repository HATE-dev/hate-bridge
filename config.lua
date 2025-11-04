Config = {}

Config.Framework = nil -- Will be auto-detected
Config.Debug = true

Config.FrameworkEvents = {
    ['esx'] = {
        playerLoaded = 'esx:playerLoaded',
        playerUnload = 'esx:onPlayerLogout',
        setJob = 'esx:setJob',
        playerSpawned = 'esx:onPlayerSpawn'
    },
    ['qb'] = {
        playerLoaded = 'QBCore:Client:OnPlayerLoaded',
        playerUnload = 'QBCore:Client:OnPlayerUnload',
        setJob = 'QBCore:Client:OnJobUpdate',
        playerSpawned = 'QBCore:Client:OnPlayerLoaded'
    },
    ['qbox'] = {
        playerLoaded = 'qbx_core:client:playerLoaded',
        playerUnload = 'qbx_core:client:playerUnloaded',
        setJob = 'qbx_core:client:onJobUpdate',
        playerSpawned = 'qbx_core:client:playerLoaded'
    },
    ['vrp'] = {
        playerLoaded = 'vRP:playerSpawn',
        playerUnload = 'vRP:playerLeave',
        setJob = 'vRP:jobUpdate',
        playerSpawned = 'vRP:playerSpawn'
    }
}

Config.ServerEvents = {
    ['esx'] = {
        playerLoaded = 'esx:playerLoaded',
        playerDropped = 'esx:playerDropped'
    },
    ['qb'] = {
        playerLoaded = 'QBCore:Server:OnPlayerLoaded',
        playerDropped = 'QBCore:Player:SetPlayerData'
    },
    ['qbox'] = {
        playerLoaded = 'qbx_core:server:playerLoaded',
        playerDropped = 'qbx_core:server:playerLogout'
    },
    ['vrp'] = {
        playerLoaded = 'vRP:playerSpawn',
        playerDropped = 'vRP:playerLeave'
    }
}

Config.DetectTargetSystem = function()
    if GetResourceState('ox_target') == 'started' then
        return 'ox_target'
    elseif GetResourceState('qb-target') == 'started' then
        return 'qb-target'
    elseif GetResourceState('qtarget') == 'started' then
        return 'qtarget'
    end
    return nil
end

Config.DetectProgressBarSystem = function()
    if GetResourceState('ox_lib') == 'started' then
        return 'ox_lib'
    elseif GetResourceState('qb-progressbar') == 'started' then
        return 'qb-progressbar'
    elseif GetResourceState('esx_progressbar') == 'started' then
        return 'esx_progressbar'
    end
    return nil
end

--[[
Config.DatabaseTables = {
    ['esx'] = {
        users = 'users',
        characters = 'users',
        jobs = 'jobs',
        job_grades = 'job_grades'
    },
    ['qb'] = {
        users = 'players',
        characters = 'players',
        jobs = 'jobs',
        job_grades = 'job_grades'
    },
    ['qbox'] = {
        users = 'players',
        characters = 'players',
        jobs = 'jobs',
        job_grades = 'job_grades'
    }
} ]]

Config.DetectFramework = function()
    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb'
    elseif GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    elseif GetResourceState('vrp') == 'started' then
        return 'vrp'
    end
    return nil
end

Config.InitializeFramework = function()
    Config.Framework = Config.DetectFramework()
    if Config.Debug then
        print('[hate-bridge] Detected framework:', Config.Framework or 'none')
    end
    return Config.Framework
end

Config.InventoryPaths = {
    ['core'] = 'nui://core_inventory/html/img/',
    ['ox'] = 'nui://ox_inventory/web/images/',
    ['qb'] = 'nui://qb-inventory/html/images/',
    ['quasar'] = 'nui://qs-inventory/html/images/',
    ['esx'] = 'nui://ox_inventory/web/images/',
    ['custom'] = 'nui://your-inventory/html/images/'
}


Config.GetItemImagePath = function(itemName)
    local basePath = ""
    
    if GetResourceState('core_inventory') == 'started' then
        basePath = Config.InventoryPaths['core']
    elseif GetResourceState('ox_inventory') == 'started' then
        basePath = Config.InventoryPaths['ox']
    elseif GetResourceState('qb-inventory') == 'started' then
        basePath = Config.InventoryPaths['qb']
    elseif GetResourceState('qs-inventory') == 'started' then
        basePath = Config.InventoryPaths['quasar']
    else
        basePath = Config.InventoryPaths['custom']
    end
    if itemName == 'default' then
        return basePath
    else
        return basePath .. itemName .. '.png'
    end
end
