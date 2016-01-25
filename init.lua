--NodeMCU-WifiDoubleSwitch
--Libor Gabaj
local format = string.format
local floor = math.floor

--Configuration
cfg_init={
  version="1.6.1",
  nist_tzdelay=3600,
  nist_refresh=60*15,
  tmpl_page = "tmpl_page.html",
  tmpl_err = "tmpl_err.html",
  debug=true,
  start=true,
  tryout=0,
  httpPort=80,
  limitConn=30,
  limitFile=1024,
  limitSend=1406,
  limitString=3072,
  uptime=tmr.now(),
  startDate="",
  currDate="",
  httpDate="",
  dateFormat="%02d.%02d.%4d %02d:%02d:%02d",
  httpFormat="%s, %d %s %d %02d:%02d:%02d GMT",
}

days = {
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
}

months = {
  "January",
  "Febuary",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
}

--Compilation
local function compileFile(luaFile)
  if file.open(luaFile)
  then
    file.close()
    collectgarbage()
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
require("nistclock")
dofile("config_switch.lc")
dofile("config_pins.lc")
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
if cfg_credentials.ipconfig
then
  wifi.sta.setip(cfg_credentials.ipconfig)
end
wifi.sta.config(cfg_credentials.wifiSSID, cfg_credentials.wifiPASW)
cfg_credentials.wifiSSID,cfg_credentials.wifiPASW,cfg_credentials.ipconfig=nil,nil,nil
collectgarbage()

--Callback function for NISTclock
function nistcb()
  --Connect to wifi
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
    if cfg_init.start and cfg_init.debug then print(format("Connecting to AP (%d)", cfg_init.tryout)) end
    if cfg_init.tryout % cfg_init.limitConn == 0
    then
      wifi.sta.disconnect()
      wifi.sta.connect()
    end
  end
  --Uptime
  local second, minute, hour, weekday, day, month, year = nistclock.getTime()
  if second ~= nil
  then
    cfg_init.currDate = format(cfg_init.dateFormat, day, month, year, hour, minute, second)
    second, minute, hour, weekday, day, month, year = nistclock.getTime(0)
    cfg_init.httpDate = format(cfg_init.httpFormat, days[weekday]:sub(1,3), day, months[month]:sub(1,3), year, hour, minute, second)
    if cfg_init.startDate == ""
    then
      cfg_init.startDate = cfg_init.currDate
      nistclock.correctStartTime(floor((cfg_init.uptime - tmr.now())/1000000))
    end
    cfg_init.uptime = nistclock.getElapsedSecs()
  end
end

--NISTclock timer
nistclock.setup{
  timer = 0,
  tzdelay = cfg_init.nist_tzdelay,
  refresh = cfg_init.nist_refresh,
  debug = cfg_init.debug,
  tickcb = nistcb,
}
cfg_init.nist_tzdelay, cfg_init.nist_refresh = nil, nil
nistclock.start()

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
