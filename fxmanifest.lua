fx_version 'cerulean'
game 'gta5'

author 'YGA   |   Discord : y_g_a'

lua54 'yes'

shared_script '@ox_lib/init.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/logo.png'
}

client_script 'client.lua'

dependency 'ox_lib'