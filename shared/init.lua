if not Config then
    print('[hate-bridge ERROR] Config table not found! Make sure config.lua is loaded first.')
    return
end

Config.InitializeFramework()


local targetSystem = Config.DetectTargetSystem()
if Config.Debug and targetSystem then
    print('[hate-bridge] Detected target system:', targetSystem)
end

local progressSystem = Config.DetectProgressBarSystem()
if Config.Debug and progressSystem then
    print('[hate-bridge] Detected progress bar system:', progressSystem)
end

local frameworkEvents = Config.Framework and Config.FrameworkEvents[Config.Framework] or nil
local serverEvents = Config.Framework and Config.ServerEvents[Config.Framework] or nil

if Config.Debug then
    if frameworkEvents then
        print('[hate-bridge] Framework events loaded for:', Config.Framework)
    end
    if serverEvents then
        print('[hate-bridge] Server events loaded for:', Config.Framework)
    end
end

if IsDuplicityVersion() then
    exports('getFramework', function()
        return Config.Framework
    end)
    
    exports('getTargetSystem', function()
        return targetSystem
    end)
    
    exports('getProgressBarSystem', function()
        return progressSystem
    end)
    
    exports('getFrameworkEvents', function()
        return frameworkEvents
    end)
    
    exports('getServerEvents', function()
        return serverEvents
    end)
else
    exports('getFramework', function()
        return Config.Framework
    end)
    
    exports('getTargetSystem', function()
        return targetSystem
    end)
    
    exports('getProgressBarSystem', function()
        return progressSystem
    end)
    
    exports('getFrameworkEvents', function()
        return frameworkEvents
    end)
    
    exports('getServerEvents', function()
        return serverEvents
    end)
end

if Config.Debug then
    print('[hate-bridge] Initialization complete')
    print('  Framework:', Config.Framework or 'none')
    print('  Target System:', targetSystem or 'none')
    print('  Progress Bar System:', progressSystem or 'none')
    print('  Framework Events:', frameworkEvents and 'loaded' or 'none')
    print('  Server Events:', serverEvents and 'loaded' or 'none')
end
