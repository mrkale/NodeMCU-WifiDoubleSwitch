--[[
NAME: HTML template placeholder names for language constants

DESCRIPTION:
- lang_title .......... Title of web server page as well as browser window
- lang_error_access ... Page title for failed or refused web server login dialog
- lang_pin_1 .......... Custom name for the first ESP8266 pin, i.e., connected device
- lang_pin_2 .......... Custom name for the second ESP8266 pin, i.e., connected device
- lang_pinALL ......... Label introducing batch control of both pins at once
- lang_switch_on ...... Text for button switching on both pins at once
  lang_switch_off ..... Text for button switching off both pins at once
  lang_switch ......... Text for button togling current state of both pins at once

CREDENTIALS:
Author: Libor Gabaj
GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
--]]
cfg_tmpl_lang = {
  lang_title = "Wifi dvojitá zásuvka",
  lang_error_access = "Nedovolený prístup",
  lang_pin_1 = "Zásuvka A",
  lang_pin_2 = "Zásuvka B",
  lang_pinALL = "Naraz",
  lang_switch_on = "Zapni",
  lang_switch_off = "Vypni",
  lang_switch = "Prepni",
  lang_version = "Verzia",
  lang_uptime = "Čas behu",
  lang_wifitime = "Čas wifi",
}
