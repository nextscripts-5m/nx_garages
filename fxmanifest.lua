fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'locales.lua',
	'config.lua',
}

client_scripts {
	'client/*.lua'
}

server_scripts {
    'server/*.lua',
	'@oxmysql/lib/MySQL.lua',
}

escrow_ignore {
	'config.lua',
	'locales.lua',
	'server/editable.lua',
	'client/editable.lua'
}