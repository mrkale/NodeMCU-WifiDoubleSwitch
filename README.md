# NodeMCU-WifiDoubleSwitch
NodeMCU based web server within ESP8266 for switching two pins from the browser through WiFi.

init.lua
==
Initial script running at power cycle. It creates connection to a Wifi network in station mode and creates web server running in the ESP8266.

- It is recommended to remove initial comments in order to save storage.  

credentials.lua
==
Function returning credentials for preferred WiFi network. Update values of returned parameters according to your situation.

- The script should be compiled to **credentials.lc** file.

switch.lua
==
Package for processing HTTP requests and rendering HTML pages.
- It is useful to compile the package file to **switch.lc** file in order to get rid of comments and descrease storage space and heap needed. 

tmpl_twoswitch_full.html
==
The HTML page template for control two pins individually as well as at once both of them.

- The template uses Bootstrap 3.3.5 framework imported from CDN.
- The templated does not imports Bootstrap javascripts.
- The placeholders of the template are described in the repository wiki. 

tmpl_twoswitch_simple.html
==
The HTML page template for control two pins individually only. However, the templae is derived from the *tmpl_twoswitch_full* template. 

tmpl_oneswitch.html
==
The HTML page template for control just one (the first) pin . However, the templae is derived from the *tmpl_twoswitch_simple* template. 
