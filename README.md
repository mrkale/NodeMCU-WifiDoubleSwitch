#NodeMCU-WifiDoubleSwitch<br><small>reduced version for ESP8266-01</small>
This branch follows the master branch, but some scripts are reduced in order to enable them to upload to the microcontroler module ESP8266-01 due to reduced free space in its file system.

All functionality and description valid for master branch is valid for this branch as well except listed bellow.

###Features
- In non-compiled script **init.lua** the all program comments and not neccessary debuging printouts are removed.
- Application does not generate the HTTP header **Date**, so that names of week days and months are removed from *init.lua*.
- The ESP8266-01 always needs cca 3700 bytes free space on its file system, so that
	- It is recommended to compile each script (except *init.lua*) manually one by one and compiled versions to store separately on a workstation.
	- Compilation may be provided on another devkit with a larger file system, e.g., NodeMCU (with ESP8266-12E), by the application at once and upload them to ESP8266-01 after.
	- Upload *init.lua* as the very last script.


	Check the correct length of each uploaded script.


- In case of insufficient free space on the file system of the ESP8266-01, the upload tool, e.g., ESPlorer, or the ESP8266-01 itself does not alert you that it truncated some piece of an uploading script. Then you can get weird program code errors. Thus, compare byte length of each script, compiled or not, to the version stored on your workstation.