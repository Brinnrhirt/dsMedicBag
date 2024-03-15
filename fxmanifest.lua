fx_version {'cerulean'}
game {'gta5'}
lua54 {'yes'}
author 'Brinnrhirt' -- Discord: https://discord.gg/9Sd6Tf4FfY
description 'Medical Bag that Heals/Revives on a zone'
version '1.1.3'

shared_scripts {
	'@ox_lib/init.lua',
    '@es_extended/imports.lua', -- Only for Legacy ESX, remove if you're not using it
    'shared/config.lua',
    'shared/locale.lua',
    'locales/*.lua',    
}
client_scripts {
    'shared/config.lua',
	'client/*.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'shared/config.lua',
	'server/*.lua',
}
