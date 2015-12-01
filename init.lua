--NodeMCU-WifiDoubleSwitch
--Libor Gabaj

--Configuration
cfg_init={
  version="1.2.0",
  debug=true,
  start=true,
  tryout=0,
  httpPort=80,
  limitConn=30,
  limitFile=1024,
  limitSend=1406,
  limitString=3072,
  uptime=tmr.time(),
  wifitime=0,
  reconnects=0,
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
wifi.setmode(wifi.STATION)
if cfg_init.debug
then
  print("MAC: ", wifi.sta.getmac())
  print("Chip: ", node.chipid())
  print("Heap: ", node.heap())
end
dofile("config_creds.lc")
wifi.sta.config(cfg_credentials.wifiSSID, cfg_credentials.wifiPASW)
cfg_credentials.wifiSSID,cfg_credentials.wifiPASW=nil,nil
collectgarbage()

--Wifi Timer
tmr.alarm(0, 1000, 1, function()
  cfg_init.uptime=tmr.time()
  if wifi.sta.getip()
  then
    if cfg_init.start
    then
      cfg_init.start = nil
      if cfg_init.debug then print(wifi.sta.getip()) end
      collectgarbage()
    end
  else
    cfg_init.tryout = cfg_init.tryout + 1
    if cfg_init.start and cfg_init.debug then print(string.format("Connecting to AP (%d)", cfg_init.tryout)) end
    if cfg_init.tryout % cfg_init.limitConn == 0
    then
      cfg_init.reconnects = cfg_init.reconnects + 1
      wifi.sta.disconnect()
      wifi.sta.connect()
    end
  end
end)

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
