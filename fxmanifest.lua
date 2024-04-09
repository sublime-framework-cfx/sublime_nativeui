fx_version 'cerulean'
games { 'gta5', 'rdr3' } --- not tested on rdr3
lua54 'yes'
use_experimental_fxv2_oal 'yes'
version '0.0.4'

files {
    'config/**',
    'src/**',
    'src/**/**',
    'init.lua',
}

client_script 'src/main.lua'