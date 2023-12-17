resource_type 'gametype' { 
	name = 'Freeroam' 
}

fx_version 'cerulean'

games { 'gta5', 'rdr3' }

version '3.0'

description 'Cake Framework'

shared_scripts {
	'locale.lua',
	'locales/en.lua',

	'config.lua',
	'config/*.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'async.lua',

	'config/server/*.lua',

	'server/common.lua',

	'common/modules/init.lua',
	'common/modules/log.lua',
	'common/modules/math.lua',
	'common/modules/strings.lua',
	'common/modules/md5.lua',
	'common/modules/kvp.lua',
	'common/functions.lua',

	'server/db.lua',

	'server/classes/player.lua',
	'server/classes/account.lua',
	'server/classes/party.lua',
	'server/classes/society.lua',

	'server/functions.lua',
	'server/paycheck.lua',
	'server/main.lua',
	'server/init.lua',
	'server/commands.lua',

	'server/modules/society.lua',
	'server/modules/rpc.lua',
	'server/modules/net.lua',
	'server/modules/anticheat.lua',
	'server/modules/characters.lua',
	'server/modules/permissions.lua',
	'server/modules/discord.lua',
	'server/modules/death.lua',
	'server/modules/inventory.lua',
	'server/modules/crews.lua',
	'server/modules/logs.lua',
	'server/modules/parties.lua',
	'server/modules/carkeys.lua',
	'server/modules/license.lua',
	'server/modules/xp.lua',
	'server/modules/ui.lua',
	'server/modules/appearance.lua',

	'server/orm/*.lua',
	'server/orm.lua',
}

client_scripts {
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
	'@prp-lib/client.lua',

	'config/client/*.lua',

	'client/common.lua',
	'client/entityiter.lua',
	'client/functions.lua',

	'common/modules/init.lua',
	'common/modules/log.lua',
	'common/modules/log.lua',
	'common/modules/math.lua',
	'common/modules/strings.lua',
	'common/modules/md5.lua',
	'common/modules/kvp.lua',

	'client/main.lua',
	'client/init.lua',
	'common/functions.lua',

	'client/modules/cache.lua',
	'client/modules/zones.lua',
	'client/modules/death.lua',
	'client/modules/scaleform.lua',
	'client/modules/streaming.lua',
	'client/modules/keymaps.lua',
	'client/modules/net.lua',
	'client/modules/teleport.lua',
	'client/modules/carkeys.lua',
	'client/modules/ui.lua',
	'client/modules/rpc.lua',
	'client/modules/inventory.lua',
	'client/modules/discord.lua',
	'client/modules/xp.lua',
	'client/modules/utils.lua',
	'client/modules/characters.lua',
}

files {
	'config/logo.txt'
}

exports {
	'getSharedObject'
}

server_exports {
	'getSharedObject'
}

dependencies {
	'mysql-async',
}

lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'