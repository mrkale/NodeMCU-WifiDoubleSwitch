-- NAME: Initial script
--
-- DESCRIPTION:
-- Script establishes connection to the preferred Wifi network.
--
-- LICENSE:
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the license GNU GPL v3 http://www.gnu.org/licenses/gpl-3.0.html
-- (related to original code) and MIT License (MIT) for added code.
--
-- CREDENTIALS:
-- Author: (c) 2015, Libor Gabaj
-- GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
-- Version: 1.0.0
-- Updated: 06.11.2015
--
switch = require("switch")
switch.setup("credentials.lc")
srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
  conn:on("receive", function(client, request)
    switch.processing(client, request)
    client:close()
    collectgarbage()
  end)
end)
