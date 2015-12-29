--[[
NAME: Credentials for wifi network and web server

DESCRIPTION:
- wifiSSID ..... Name of the preferred wifi network
- wifiPASW ..... Password to the preferred wifi network
- httpSECRET ... Base64 encoded "user:password" for authenticating in web server
- ipconfig ..... Table with static IP address parameters

CREDENTIALS:
Author: Libor Gabaj
GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
--]]
cfg_credentials = {
  wifiSSID = "MySSID",
  wifiPASW = "MyPASW",
  httpSECRET = "MySECRET",
  ipconfig={
    ip="192.168.0.6",
    netmask="255.255.255.0",
    gateway="192.168.0.1",
    },
}