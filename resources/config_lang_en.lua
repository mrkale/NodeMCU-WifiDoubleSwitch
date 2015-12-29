--[[
NAME: HTML template placeholder names for language constants

DESCRIPTION:
- lang_title .......... Title of web server page as well as browser window
- lang_error_access ... Page title for failed or refused web server login dialog
- lang_pin_1 .......... Custom name for the first ESP8266 pin, i.e., connected device
- lang_pin_2 .......... Custom name for the second ESP8266 pin, i.e., connected device
- lang_pinALL ......... Label introducing batch control of both pins at once
- lang_switch_on ...... Text for button switching on both pins at once
- lang_switch_off ..... Text for button switching off both pins at once
- lang_switch ......... Text for button toggling current state of both pins at once
- lang_version ........ Text for version label
- lang_uptime ......... Text for uptime label
- lang_wifitime ....... Text for wifi uptime label

CREDENTIALS:
Author: Libor Gabaj
GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
--]]
cfg_tmpl_lang = {
  lang_title = "Wifi Double Outlet",
  lang_error_access = "Unauthorized access",
  lang_pin_1 = "Socket A",
  lang_pin_2 = "Socket B",
  lang_pinALL = "Together",
  lang_switch_on = "ON",
  lang_switch_off = "OFF",
  lang_switch = "Toggle",
  lang_version = "Version",
  lang_uptime = "Uptime",
  lang_wifitime = "Wifitime",
}
