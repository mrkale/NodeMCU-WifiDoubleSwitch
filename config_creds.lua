--[[
NAME: Credentials for wifi network and web server

DESCRIPTION:
- wifiSSID ..... Name of the preferred wifi network
- wifiPASW ..... Password to the preferred wifi network
- httpSECRET ... Base64 encoded "user:password" for authenticating in web server

CREDENTIALS:
Author: Libor Gabaj
GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
--]]
cfg_credentials = {
  wifiSSID = "MySSID",
  wifiPASW = "MyPASW",
  httpSECRET = "MySECRET",
}