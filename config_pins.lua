--[[
NAME: ESP8266 pin definition and initial status

DESCRIPTION:
- pin ...... NodeMCU pin number
- status ... Initial and current status of the pin

CREDENTIALS:
Author: Libor Gabaj
GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
--]]
cfg_pins = {
  {pin = 3, status = cfg_tmpl_cons.status_on},
  {pin = 4, status = cfg_tmpl_cons.status_on},
}
