fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'OnlyScripts / veryappropriatename & coy_boy'
description 'This script lets players open a gift every x hours/minutes || You may not re-sell or re-publish on other websites without consent!'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@mysql-async/lib/MySQL.lua',
    '@ox_lib/init.lua',
    'shared/config.lua',
    'locales/*.lua'
}

client_scripts {
    'shared/config.lua',
    'locales/*.lua',
	'client/client.lua',
}

server_scripts {
    'shared/config.lua',
    'locales/*.lua',
    'server/server.lua'
}
