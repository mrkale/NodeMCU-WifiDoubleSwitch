local format = string.format
local floor = math.floor

cfg_init={
  version="1.6.1e",
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
  dateFormat="%02d.%02d.%4d %02d:%02d:%02d",
}

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

require("nistclock")
dofile("config_switch.lc")
dofile("config_pins.lc")
for i, params in ipairs(cfg_pins)
do
  gpio.mode(params.pin, gpio.OUTPUT)
  gpio.write(params.pin, params.status)
end

wifi.setmode(wifi.STATION)
dofile("config_creds.lc")
if cfg_credentials.ipconfig
then
  wifi.sta.setip(cfg_credentials.ipconfig)
end
wifi.sta.config(cfg_credentials.wifiSSID, cfg_credentials.wifiPASW)
cfg_credentials.wifiSSID,cfg_credentials.wifiPASW,cfg_credentials.ipconfig=nil,nil,nil
collectgarbage()

function nistcb()
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
    if cfg_init.start and cfg_init.debug then print(format("Connect %d.", cfg_init.tryout)) end
    if cfg_init.tryout % cfg_init.limitConn == 0
    then
      wifi.sta.disconnect()
      wifi.sta.connect()
    end
  end
  local second, minute, hour, weekday, day, month, year = nistclock.getTime()
  if second ~= nil
  then
    cfg_init.currDate = format(cfg_init.dateFormat, day, month, year, hour, minute, second)
    if cfg_init.startDate == ""
    then
      cfg_init.startDate = cfg_init.currDate
      nistclock.correctStartTime(floor((cfg_init.uptime - tmr.now())/1000000))
    end
    cfg_init.uptime = nistclock.getElapsedSecs()
  end
end

nistclock.setup{
  timer = 0,
  tzdelay = cfg_init.nist_tzdelay,
  refresh = cfg_init.nist_refresh,
  debug = cfg_init.debug,
  tickcb = nistcb,
}
cfg_init.nist_tzdelay, cfg_init.nist_refresh = nil, nil
nistclock.start()

srv=net.createServer(net.TCP)
srv:listen(cfg_init.httpPort,
  function(conn)
    conn:on("receive",
      function(client, request)
        dofile("processing.lc")(client, request)
      end
    )
  end
)
