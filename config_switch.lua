--[[
CREDENTIALS:
Author: Libor Gabaj
GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
--]]

--[[
NAME: HTML template placeholder constant strings

DESCRIPTION:
- reqvar_pin ...... HTTP request variable for controlling pins
- status_on ....... Value for switching on a pin. At relays consider active low or active high ones. 
- status_off ...... Value for switching off a pin.  At relays consider active low or active high ones. 
- class_btn_on .... Bootstrap class modifier for button switching on a pin
- class_btn_off ... Bootstrap class modifier for button switching off a pin
- class_lbl_on .... Bootstrap class modifier for label denoting a pin switched on
- class_lbl_off ... Bootstrap class modifier for label denoting a pin switched off
- label_on ........ Text for button switching on a pin. Taken from language table.
- label_off ....... Text for button switching on a pin. Taken from language table.
--]]
cfg_tmpl_cons = {
  reqvar_pin = "pin",
  status_on = gpio.LOW,
  status_off = gpio.HIGH,
  class_btn_on = "success",
  class_btn_off = "danger",
  class_lbl_on = "primary",
  class_lbl_off = "default",
  label_on = cfg_tmpl_lang.lang_switch_on,
  label_off = cfg_tmpl_lang.lang_switch_off,
}

--[[
NAME: HTTP headers constant strings

DESCRIPTION:
- header_server ... Name of web server for HTTP response header
- header_realm .... Real name for HTTP login dialog
--]]
cfg_header_cons = {
  header_server = "NodeMCU-WifiDoubleSwitch",
  header_realm = "ESP8266 Web server",
}

--[[
NAME: Parameters of pin statuses

DESCRIPTION:
Values for all parameters are taken from previous HTML templates tables
- class_lbl ... Bootstrap class modifier for pin name label
- class_btn ... Bootstrap class modifier for pin control button
- label ....... Text for control button denoting target pin status
- action ...... Target pin status invoked by its control button
--]] 
cfg_tmpl_states = {
[cfg_tmpl_cons.status_on] = {
  class_lbl = cfg_tmpl_cons.class_lbl_on,
  class_btn = cfg_tmpl_cons.class_btn_off,
  label = cfg_tmpl_cons.label_off,
  action = cfg_tmpl_cons.status_off
  },
[cfg_tmpl_cons.status_off] = {
  class_lbl = cfg_tmpl_cons.class_lbl_off,
  class_btn = cfg_tmpl_cons.class_btn_on,
  label = cfg_tmpl_cons.label_on,
  action = cfg_tmpl_cons.status_on
  },
}