-- NodeMCU-WifiDoubleSwitch
-- Libor Gabaj

-- Configuration
cfg_init={
  version="1.1.0",
  debug=true,
  reconnect=false,
  httpPort=80,
  limitConn=15,
  limitFile=1024,
  limitSend=1406,
  limitString=3072,
}

--Compilation
local function compileFile(luaFile)
  if file.open(luaFile)
  then
    file.close()
    if cfg_init.debug then print("Compiling:", luaFile) end
    node.compile(luaFile)
    file.remove(luaFile)
    collectgarbage()
  end
end
for fileName, fileSize in pairs(file.list())
do
  if fileName:match("%.lua$")
  then
    if fileName ~= "init.lua" then compileFile(fileName) end
  end
end
compileFile=nil
collectgarbage()

--Initialization
dofile("config_lang.lc")
dofile("config_switch.lc")
dofile("config_pins.lc")
dofile("tmpl_cache.lc")
for i, params in ipairs(cfg_pins)
do
  gpio.mode(params.pin, gpio.OUTPUT)
  gpio.write(params.pin, params.status)
end

--Wifi
local function wifiStationConnect(wifiSSID, wifiPASW)
  local tryout = 0
  wifi.setmode(wifi.STATION)
  if cfg_init.debug
  then
    print("MAC: ", wifi.sta.getmac())
    print("Chip: ", node.chipid())
    print("Heap: ", node.heap())
  end
  if cfg_init.reconnect then wifi.sta.disconnect() end
  if (wifi.sta.getip() == nil) then wifi.sta.config(wifiSSID, wifiPASW) end
  tmr.alarm(0, 1000, 1, function()
    if wifi.sta.getip()
    then
      if cfg_init.debug then print(wifi.sta.getip()) end
      tmr.stop(0)
    else
      if cfg_init.debug
      then
        tryout=tryout+1
        if (tryout >= cfg_init.limitConn) then node.restart() end
        print(string.format("Connecting to AP (%d)", tryout))
      end
    end
  end)
end
dofile("config_creds.lc")
wifiStationConnect(cfg_credentials.wifiSSID, cfg_credentials.wifiPASW)
cfg_credentials.wifiSSID,cfg_credentials.wifiPASW=nil,nil
wifiStationConnect=nil
collectgarbage()

--Server
if srv then srv:close() end
srv=net.createServer(net.TCP)
if cfg_init.debug then print("Web server created") end
srv:listen(cfg_init.httpPort,
  function(conn)
    conn:on("receive",
      function(client, request)
        dofile("processing.lc")(client, request)
      end
    )
  end
)
