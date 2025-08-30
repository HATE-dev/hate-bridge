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
| VRP | ✅ | 1.0+ |

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
If you experience any issues:

1. Make sure HateBridge is installed correctly
2. Enable debug mode (`Config.Debug = true`)
3. Check the server console for error messages
4. Ensure your framework is supported

## Changelog

- All Hate scripts now require the hate-bridge dependency
- Removed old framework-specific code
- Performance improvements made
- Reduced code duplication
