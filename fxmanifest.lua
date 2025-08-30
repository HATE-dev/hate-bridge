fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HateBridge Framework'
description 'Unified Framework Bridge for Hate Scripts'
version '1.0.0'
license 'MIT'
repository 'https://github.com/HATE-dev/hate-bridge'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    'shared/init.lua'
}

client_scripts {
    'client/esx_client.lua',
    'client/qb_client.lua',
    'client/qbox_client.lua',
    'client/vrp_client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/esx_server.lua',
    'server/qb_server.lua',
    'server/qbox_server.lua',
    'server/vrp_server.lua'
}

dependencies {
    'oxmysql'
}

provide 'hate-bridge'
