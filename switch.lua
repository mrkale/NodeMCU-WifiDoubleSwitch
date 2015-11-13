--[[
NAME: Switcher package

DESCRIPTION:
Web server in ESP8266 for switching two pins. Suitable for ESP8266-01 and
its pins GPIO0 AND GPIO2.

LICENSE:
This program is free software; you can redistribute it and/or modify
it under the terms of the license GNU GPL v3 http://www.gnu.org/licenses/gpl-3.0.html
(related to original code) and MIT License (MIT) for added code.

CREDITS:
  
CREDENTIALS:
Author: (c) 2015, Libor Gabaj
GitHub: https://github.com/mrkale/nodemcu/switcher.git
Version: 1.0.0
Updated: 06.11.2015
--]]
local moduleName = ...
local M = {}
_G[moduleName] = M

--[[ DATA STRUCTURES ]]

--[[Placeholder names in HTML templates
Statuses are set for LEDs. Swap them for relays.
--]]
local reqcons={reqvar_pin="pin",
  class_on="success", class_off="danger", class_swap="warning",
  status_on=gpio.HIGH, status_off=gpio.LOW,
  label_on="Zapni", label_off="Vypni", label_swap="Prepni",
  title_all="Naraz"
}
--NodeMCU pins
local pins={
  [3]={order=1, title="LedA", status=reqcons.status_off},
  [4]={order=2, title="LedB", status=reqcons.status_off},
 }
--HTML templates
local templates={
  full="tmpl_twoswitch_full.html",
  simple="tmpl_twoswitch_simple.html",
  trivial="tmpl_oneswitch.html"  
}
--Pin statuses
 local status={
  [reqcons.status_on]={class_lbl=reqcons.class_on, class_btn=reqcons.class_off, label=reqcons.label_off, action=reqcons.status_off},
  [reqcons.status_off]={class_lbl=reqcons.class_off, class_btn=reqcons.class_on, label=reqcons.label_on, action=reqcons.status_on}
}

--[[ CONFIGS ]]
local Debug = true
local defaultTemplate = templates.full

--[[ FUNCTIONS ]]

local function wifiStationConnect(credentialFile)
  local message, tryout = "Connecting to AP (%d)", 1
  wifi.setmode(wifi.STATION)
  if Debug
  then
    print("MAC: ", wifi.sta.getmac())
    print("Chip: ", node.chipid())
    print("Heap: ", node.heap())
    print(string.format(message, tryout))
  end
  wifi.sta.config(dofile(credentialFile)())
  tmr.alarm(0, 1000, 1, function()
    if wifi.sta.getip() ~= nil
    then
      if Debug then print(wifi.sta.getip()) end
      tmr.stop(0)
    else
      if Debug
      then
        tryout = tryout + 1
        print(string.format(message, tryout))
      end
    end
  end)
end

local function setPinMode()
  for pin, params in pairs(pins)
  do
    gpio.mode(pin, gpio.OUTPUT)
    gpio.write(pin, params.status)
  end
end

local function processRequest(request)
  local req_pin, req_state
  local req_pinstate = request:match("GET /%?" .. reqcons.reqvar_pin .. "=(%d+) HTTP")
  if req_pinstate == nil
  then
    if Debug then print("No pin state") end
  else
    if Debug then print("Pin state="..req_pinstate) end
    while #req_pinstate > 0
    do
      req_pin = req_pinstate:sub(1, 1) + 0
      req_state = req_pinstate:sub(2, 2) + 0
      for pin, params in pairs(pins)
      do
        if req_pin == params.order
        then
          params.status = req_state
          gpio.write(pin, params.status)
          break
        end
      end
      req_pinstate = req_pinstate:sub(3, #req_pinstate)
    end
  end
end

local function processTemplate(client, templateFile)
  local page, chunk = '', ''
  local fileChunkLimit, sendChunkLimit = 1024, 1460
  --Read template file
  file.open(templateFile)
  repeat
    page = page .. chunk
    chunk = file.read(fileChunkLimit)
  until chunk == nil
  file.close()
  --Replace placeholders with values
  for pin, params in pairs(pins)
  do
    for key, value in pairs(params)
    do
      page = page:gsub("\${"..key.."_"..params.order.."}", value)    
    end
    for key, value in pairs(status[params.status])
    do
      page = page:gsub("\${"..key.."_"..params.order.."}", value)    
    end
  end
  for key, value in pairs(reqcons)
  do
    page=page:gsub("\${"..key.."}", value)    
  end
  --Stream page
  while #page > 0
  do
    collectgarbage();
    client:send(page:sub(1, sendChunkLimit))
    page = page:sub(sendChunkLimit + 1, #page)
  end
end

function M.setup(credentialFile)
  wifiStationConnect(credentialFile)
  setPinMode()
end

function M.processing(client, request)
  processRequest(request)
  processTemplate(client, defaultTemplate)
end

return M