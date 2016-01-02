# NodeMCU-WifiDoubleSwitch<br><small>version 1.4.1</small>
NodeMCU based web server within ESP8266 for switching two pins from the browser through WiFi. The project contains a couple of configuration files, where each of them sets up particular aspect of the project.

A **simple HTML templating** mechanism is used especially for creating localized web pages and their various versions. HTML pages employ *Twitter Bootstrap 3.*


<a id="dependency"></a>
##Dependency
**s2eta**: Module for converting elapsed seconds to time string with *days, hours, minutes, and seconds* components.


<a id="scripts"></a>
##Scripts
NodeMCU lua scripts. For better performance and memory efficiency all the program code is devided to separate scripts.

###init.lua
Initial script running at power cycle. It
- automatically compiles all *.lua* files except itself
- creates connection to a Wifi network in station mode
- reconnects to Wifi network after connection lost
- launches configuration tables from configuration files
- measures uptime (from recent restart) and time since recent wifi connection
- creates web server running in the ESP8266

###config_creds.lua
The script creates configuration table with credentials for preferred WiFi network as well as for web server basic HTTP authorization.
- The credential configuration table may containg IP configuration table for establishing static IP address. 
- Update values according to your situation.

###config_lang.lua
The script creates configuration table with language dependent string constants for HTML templates. *Only this script is needed to be changed for localization of HTML templates.* The script is predefined with english language strings for controlling sockets.

###config_pins.lua
The script creates configuration table with hardware configuration. It simply defines the order of pins in HTML templates, their NodeMCU numbers, and keeps current state of pins.

The state of pins in the script is considered as the initial state after power up the ESP8266 and is predefined for active low relays initially turned off, which are expected to be controlled by the ESP8266. The numbering of pins is suitable for ESP8266-01, which the project is primarily aimed to.

*In spite of just two pins defined in the configuration table, it can be extended by whatever number of other pins with corresponding updates in HTML templates in order to control more output devices.*  

###config_switch.lua
The script creates the configuration table for rendering HTML pages with help of Bootstrap classes and the table for HTTP headers. This script may be updated only if you wish to change the visual and color appearance of HTML pages and/or *assign different gpio state to pin  state*.

	Current gpio state of pins is set for low active relays.   

###tmpl_cache.lua
The script creates the table defining used HTML templates for normal and erroneous HTML pages and caches its content partially updated with template constants from respective configuration tables. The table is predefined with primary HTML template. Update this table, if you wish to use another HTML template for the project. 

###processing.lua
The script processes HTTP requests, executes commands from them, and creates HTTP responses including HTTP headers as well as it updates cached HTML templates with current state of pins and corresponding rendering.
At sending HTML pages the script uses callback function if running in framework major version 1 and on, but uses multiple send commands if running in previous major versions of the framework.

	The script uses the separate module s2eta. 


<a id="templates"></a>
##Templates
HTML templates for web server.

###tmpl_twoswitch_full.html
The primary HTML template for control two pins individually as well as at once both of them.

- The template uses Bootstrap 3.3.5 framework imported from CDN.
- The templated does not imports Bootstrap javascripts.
- The placeholders of the template are based on command shell variable substitution (*${varname}*) and are described in the repository wiki.
- Bellow the bottom line there is the current version, uptime, time of recent wifi connnect displayed along side with number of wifi reconnections in braces.

###tmpl_error_access.html
The HTML template for failed authorization to the web server.

##resources

This folder contains other HTML templates, usually derived from the primary template and language configuration scripts.

###tmpl_twoswitch_simple.html
The HTML template for control two pins individually only. 

###tmpl_oneswitch.html
The HTML template for control just one (the first) pin.

###config_lang_en.lua
The script defining language strings for HTML templates in English and for controlling relays. If you wish to use it, update, copy, and rename it to *config_lang.lua* in order to be recognized by the *init.lua*.

###config_lang_sk.lua
The script defining language strings for HTML templates in Slovak and for controlling power sockets by relays. If you wish to use the script, update, copy, and rename it to *config_lang.lua* in order to be recognized by the *init.lua*.

Skript definuje jazykové konštanty pre HTML šablóny v slovenčine a pre ovládanie elektrických zásuviek cez relátka. Ak ju chcete použiť, skript aktualizujte, skopírujte a premenujte na *config_lang.lua*, aby ho rozoznal skript *init.lua*. 
