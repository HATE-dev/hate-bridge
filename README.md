# HateBridge - Unified Framework Bridge

HateBridge is a central bridge system that provides framework independence for all Hate scripts. It supports ESX, QBCore, and QBox frameworks with automatic detection and unified API.

## Features

- **Automatic Framework Detection**: Automatically detects which framework is installed on the server
- **Unified API**: Provides a single API for all frameworks
- **Player Management**: Manages player data across different frameworks
- **Inventory Management**: Item adding/removing operations
- **Money Management**: Money adding/removing operations
- **Notification System**: Framework-independent notifications
- **Progress Bar**: Framework-independent progress bars
- **Callback System**: Server-client callbacks
- **Database Operations**: Helper functions for MySQL operations
- **Target System**: Unified targeting system (ox_target, qb-target, qtarget)

## Installation

1. Copy the `hate-bridge` folder to your resources directory
2. Add this line to your `server.cfg`:
```
ensure hate-bridge
```

## Framework Support

| Framework | Status | Version Support |
|-----------|---------|-----------------|
| ESX | ✅ | Legacy & Final |
| QBCore | ✅ | All Versions |
| QBox | ✅ | Latest |

## Dependencies

- `oxmysql` (required)
- `ox_lib` (optional, for enhanced features)

## 📚 Documentation

For complete documentation, examples, and advanced usage, visit our official documentation:

**[📖 HATE Development Documentation](https://hate-development.gitbook.io/hate-development-docs/hate-framework-bridge)**

The documentation includes:
- Detailed API reference
- Step-by-step integration guides  
- Code examples and best practices
- Troubleshooting and FAQ
- Framework migration guides

## Usage in Other Hate Scripts

### FXManifest Dependency

Add dependency to your `fxmanifest.lua`:

```lua
dependencies {
    'hate-bridge'
}
```

### Client Side Usage

```lua
local HateBridge = nil

-- Load HateBridge
CreateThread(function()
    while HateBridge == nil do
        HateBridge = exports['hate-bridge']:getBridge()
        Wait(100)
    end
end)

-- Usage examples
-- Get player data
local playerData = HateBridge.GetPlayerData()

-- Check if player is loaded
if HateBridge.IsPlayerLoaded() then
    print("Player is loaded")
end

-- Get player job
local job = HateBridge.GetPlayerJob()

-- Get player money
local money = HateBridge.GetPlayerMoney('money') -- or 'bank', 'black_money'

-- Show notification
HateBridge.ShowNotification('Hello World!', 'success', 5000)

-- Progress bar
HateBridge.ProgressBar('my_progressbar', 'Doing something...', 5000, false, true, {
    disableMovement = true,
    disableCarMovement = true,
    disableMouse = false,
    disableCombat = true,
}, {
    animDict = 'mini@repair',
    anim = 'fixing_a_player',
    flags = 49,
}, {}, function()
    print('Progress completed')
end, function()
    print('Progress cancelled')
end)

-- Trigger server callback
HateBridge.TriggerCallback('my_callback', function(result)
    print('Callback result:', result)
end, 'arg1', 'arg2')

-- Target system
HateBridge.AddTargetEntity(entity, {
    {
        name = 'my_option',
        icon = 'fas fa-hand',
        label = 'Interact',
        action = function()
            print('Entity targeted!')
        end,
        distance = 2.0
    }
})
```

### Server Side Usage

```lua
local HateBridge = exports['hate-bridge']:getBridgeServer()

-- Get player
local Player = HateBridge.GetPlayer(source)

-- Add money
HateBridge.AddMoney(source, 'money', 1000)

-- Remove money
HateBridge.RemoveMoney(source, 'money', 500)

-- Add item
HateBridge.AddItem(source, 'bread', 5, {quality = 100})

-- Remove item
HateBridge.RemoveItem(source, 'bread', 2)

-- Check if player has item
local hasItem = HateBridge.HasItem(source, 'bread', 3)

-- Get item count
local itemCount = HateBridge.GetItemCount(source, 'bread')

-- Create server callback
HateBridge.CreateCallback('my_callback', function(source, cb, arg1, arg2)
    cb(true)
end)

-- Database operations
HateBridge.ExecuteQuery('SELECT * FROM users WHERE identifier = ?', {identifier}, function(result)
    print('Query result:', json.encode(result))
end)
```

## Client API Reference

### Player Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `GetPlayerData()` | Get all player data | None | table |
| `IsPlayerLoaded()` | Check if player is loaded | None | boolean |
| `GetPlayerJob()` | Get player job information | None | table |
| `GetPlayerMoney(moneyType)` | Get player money amount | string (optional) | number |

### UI Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `ShowNotification(message, type, duration)` | Show notification | string, string, number | void |
| `ProgressBar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, onFinish, onCancel)` | Show progress bar | multiple | void |

### Callback Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `TriggerCallback(name, cb, ...)` | Trigger server callback | string, function, ... | void |

### Target System Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `AddTargetEntity(entity, options)` | Add target to entity | number, table | void |
| `RemoveTargetEntity(entity, optionNames)` | Remove target from entity | number, table | void |
| `AddTargetModel(models, options)` | Add target to models | table, table | void |
| `RemoveTargetModel(models, optionNames)` | Remove target from models | table, table | void |
| `AddGlobalPed(options)` | Add global ped target | table | void |
| `RemoveGlobalPed(optionNames)` | Remove global ped target | table | void |
| `AddTargetZone(name, coords, length, width, options, targetOptions)` | Add target zone | string, vector3, number, number, table, table | void |
| `AddCircleZone(name, coords, radius, options, targetOptions)` | Add circle zone | string, vector3, number, table, table | void |
| `RemoveTargetZone(name)` | Remove target zone | string | void |

## Server API Reference

### Player Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `GetPlayer(source)` | Get player object | number | object |
| `GetPlayerFromIdentifier(identifier)` | Get player by identifier | string | object |
| `GetPlayerIdentifier(source)` | Get player identifier | number | string |
| `GetPlayerName(source)` | Get player name | number | string |
| `GetPlayerCharName(source, useNickname)` | Get character name | number, boolean | string |

### Money Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `AddMoney(source, moneyType, amount)` | Add money to player | number, string, number | boolean |
| `RemoveMoney(source, moneyType, amount)` | Remove money from player | number, string, number | boolean |
| `GetPlayerMoney(source, moneyType)` | Get player money | number, string | number |
| `HasEnoughMoney(source, moneyType, amount)` | Check if player has enough money | number, string, number | boolean |

### Inventory Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `AddItem(source, itemName, amount, metadata)` | Add item to player | number, string, number, table | boolean |
| `RemoveItem(source, itemName, amount)` | Remove item from player | number, string, number | boolean |
| `GetItemCount(source, itemName)` | Get item count | number, string | number |
| `HasItem(source, itemName, amount)` | Check if player has item | number, string, number | boolean |
| `HasEnoughItem(source, itemName, amount)` | Check if player has enough items | number, string, number | boolean |
| `CanCarryItem(source, itemName, amount)` | Check if player can carry item | number, string, number | boolean |
| `GetPlayerInventory(source)` | Get player inventory | number | table |

### Job Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `GetPlayerJob(source)` | Get player job | number | table |
| `SetPlayerJob(source, jobName, grade)` | Set player job | number, string, number | boolean |

### Callback Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `CreateCallback(name, cb)` | Create server callback | string, function | void |

### Database Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `ExecuteQuery(query, parameters, cb)` | Execute MySQL query | string, table, function | mixed |
| `ExecuteInsert(query, parameters, cb)` | Execute MySQL insert | string, table, function | number |
| `ExecuteUpdate(query, parameters, cb)` | Execute MySQL update | string, table, function | number |

### Utility Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `CreateUseableItem(itemName, cb)` | Create useable item | string, function | void |
| `ShowNotification(source, message, type, duration)` | Show notification to player | number, string, string, number | void |
| `GetItemLabel(itemName)` | Get item label | string | string |
| `GetItemImagePath(itemName)` | Get item image path | string | string |

## Shared Exports

These exports are available on both client and server:

| Export | Description | Returns |
|--------|-------------|---------|
| `getFramework()` | Get detected framework name | string |
| `getTargetSystem()` | Get detected target system | string |
| `getProgressBarSystem()` | Get detected progress bar system | string |
| `getFrameworkEvents()` | Get framework events table | table |
| `getServerEvents()` | Get server events table | table |

## Framework Detection

The bridge automatically detects your framework on startup:

- **ESX**: Detects `es_extended` resource
- **QBCore**: Detects `qb-core` resource  
- **QBox**: Detects `qbx_core` resource

## Target System Support

Automatically detects and supports:
- `ox_target`
- `qb-target`
- `qtarget`

## Progress Bar Support

Automatically detects and supports:
- `ox_lib` (progressCircle)
- `esx_progressbar`
- `qb-progressbar`

## Events

### Client Events

| Event | Description | Parameters |
|-------|-------------|------------|
| `hate-bridge:client:playerLoaded` | Triggered when player loads | playerData |
| `hate-bridge:client:playerUnloaded` | Triggered when player unloads | None |
| `hate-bridge:client:jobUpdate` | Triggered when job updates | jobData |

### Server Events

| Event | Description | Parameters |
|-------|-------------|------------|
| `hate-bridge:server:playerLoaded` | Triggered when player loads | source |
| `hate-bridge:server:playerDropped` | Triggered when player drops | source |

## Configuration

Edit `config.lua` to customize:

```lua
Config.Debug = true -- Enable debug prints
Config.Framework = nil -- Force framework (auto-detect if nil)
```

## Example Usage in Scripts

### Complete Client Example

```lua
-- Wait for bridge to be available
local HateBridge = nil
CreateThread(function()
    while HateBridge == nil do
        HateBridge = exports['hate-bridge']:getBridge()
        Wait(100)
    end
    
    -- Now you can use HateBridge functions
    print('Bridge loaded, framework:', exports['hate-bridge']:getFramework())
end)

-- Listen for player load
RegisterNetEvent('hate-bridge:client:playerLoaded')
AddEventHandler('hate-bridge:client:playerLoaded', function(playerData)
    print('Player loaded with job:', playerData.job.name)
end)

-- Example interaction
RegisterCommand('testbridge', function()
    if not HateBridge or not HateBridge.IsPlayerLoaded() then
        return
    end
    
    local job = HateBridge.GetPlayerJob()
    local money = HateBridge.GetPlayerMoney('money')
    
    HateBridge.ShowNotification('Job: ' .. job.name .. ' | Money: $' .. money, 'info')
end)
```

### Complete Server Example

```lua
-- Get bridge on resource start
local HateBridge = exports['hate-bridge']:getBridgeServer()

-- Create a callback for client use
HateBridge.CreateCallback('myresource:getData', function(source, cb)
    local Player = HateBridge.GetPlayer(source)
    if Player then
        cb({
            name = HateBridge.GetPlayerName(source),
            job = HateBridge.GetPlayerJob(source),
            money = HateBridge.GetPlayerMoney(source, 'money')
        })
    else
        cb(false)
    end
end)

-- Listen for player load
RegisterNetEvent('hate-bridge:server:playerLoaded')
AddEventHandler('hate-bridge:server:playerLoaded', function()
    local src = source
    print('Player loaded on server:', src)
    
    -- Give welcome bonus
    HateBridge.AddMoney(src, 'money', 100)
    HateBridge.ShowNotification(src, 'Welcome bonus: $100', 'success')
end)

-- Example command
RegisterCommand('givebread', function(source, args)
    local amount = tonumber(args[1]) or 1
    
    if HateBridge.CanCarryItem(source, 'bread', amount) then
        HateBridge.AddItem(source, 'bread', amount)
        HateBridge.ShowNotification(source, 'You received ' .. amount .. ' bread', 'success')
    else
        HateBridge.ShowNotification(source, 'You cannot carry that much bread', 'error')
    end
end)
```

## Troubleshooting

### Common Issues

1. **Framework not detected**: Ensure your framework resource is started before hate-bridge
2. **Exports not working**: Make sure to add hate-bridge as a dependency in your fxmanifest.lua
3. **Player data nil**: Wait for the player to be fully loaded before accessing data

### Debug Mode

Enable debug mode in config.lua to see detection logs:

```lua
Config.Debug = true
```

### Framework Override

You can force a specific framework if auto-detection fails:

```lua
Config.Framework = 'esx' -- or 'qb', 'qbox'
```

## Migration from Framework-Specific Code

### From ESX:
```lua
-- Old ESX code
ESX.TriggerServerCallback('callback', function(result) end)
ESX.ShowNotification('message')

-- New HateBridge code  
HateBridge.TriggerCallback('callback', function(result) end)
HateBridge.ShowNotification('message', 'info')
```

### From QBCore:
```lua
-- Old QB code
QBCore.Functions.TriggerCallback('callback', function(result) end)
QBCore.Functions.Notify('message')

-- New HateBridge code
HateBridge.TriggerCallback('callback', function(result) end)  
HateBridge.ShowNotification('message', 'info')
```

## Performance Notes

- HateBridge uses minimal resources
- Framework detection happens once on startup
- No polling or continuous checks
- Event-driven architecture for optimal performance

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### What does this mean?
- ✅ Commercial use allowed
- ✅ Modification allowed
- ✅ Distribution allowed
- ✅ Private use allowed
- ❗ License and copyright notice must be included

## Support

📖 **Primary Support**: [Official Documentation](https://hate-development.gitbook.io/hate-development-docs/hate-framework-bridge)

For additional support:
- Check the documentation first for common solutions
- Visit our community forums  
- Contact the development team
- Report issues on GitHub

---

**Note**: This bridge is designed specifically for Hate scripts ecosystem. While it can be used with other resources, it's optimized for Hate scripts integration.

Eğer herhangi bir sorun yaşarsanız:

1. HateBridge'in düzgün yüklendiğinden emin olun
2. Debug modunu açın (`Config.Debug = true`)
3. Server console'unda hata mesajlarını kontrol edin
4. Framework'ünüzün desteklendiğinden emin olun

## Güncelleme Notları

- Tüm hate scriptleri artık hate-bridge dependency'si gerektirir
- Eski framework-specific kodlar kaldırıldı
- Performans iyileştirmeleri yapıldı
- Kod tekrarları azaltıldı
