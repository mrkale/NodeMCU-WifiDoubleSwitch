--[[
NAME: HTTP request processing

DESCRIPTION:
Processing of HTTP request including Basic HTTP Authentication.
Public function populates current HTML template with current state of pins,
creates web page, ads HTTP headers and sends response to the client.
If there is not basic authentication present in the request from a browser,
the function invokes login dialog in the browser.
  
CREDENTIALS:
Author: Libor Gabaj
GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
--]]
local floor = math.floor
local format = string.format

--Format time
local function secsToTime(seconds)
  secs = seconds%60
  mins = floor(seconds/60)%60
  hours = floor(seconds/3600)
  return format("%02d:%02d:%02d", hours, mins, secs)
end

--Update input HTML template string by replacing placeholders with current values
local function updateTemplate(templateString)
  --Project params
  templateString=templateString:gsub("\${uptime}", secsToTime(cfg_init.uptime))    
  templateString=templateString:gsub("\${wifitime}", secsToTime(cfg_init.wifitime))    
  templateString=templateString:gsub("\${reconnects}", cfg_init.reconnects)    
  --Pins state
  for i, params in ipairs(cfg_pins)
  do
    for key, value in pairs(cfg_tmpl_states[params.status])
    do
      templateString = templateString:gsub("\${"..key.."_"..i.."}", value)    
    end
  end
  return templateString
end

--Send final HTML page to the client (browser) in chunks
local function sendPage(client, page)
  local majorVer = node.info()
  local chunk
  if majorVer > 0
  then
    local function sender(client)
      if #page > 0
      then
        chunk = page:sub(1, cfg_init.limitSend)
        page = page:sub(cfg_init.limitSend + 1, #page)
        client:send(chunk, sender)
      else
        client:close()
      end
    end
    sender(client)
  else
    while #page > 0
    do
      chunk = page:sub(1, cfg_init.limitSend)
      page = page:sub(cfg_init.limitSend + 1, #page)
      client:send(chunk)
    end
    client:close()
  end
  collectgarbage()
end

--Create HTTP status line for input code
local function getHttpStatus(code)
  local httpCodes = {
    [200] = "OK",
    [400] = "Bad Request",
    [401] = "Authorization Required\r\nWWW-Authenticate: Basic realm=\""..cfg_header_cons.header_realm.."\"",
    [404] = "Not Found",
    [501] = "Not implemented",
  }
  local header = httpCodes[code]
  if header
  then
    header = "HTTP/1.1 "..code.." "..header.."\r\n"
  else
    header = getHttpHeader(501)
  end
  return header
end

--Create HTTP headers
local function getHttpHeaders(code, bodyLength, dateString)
  local header = getHttpStatus(code)
    .. "Content-Type: text/html; charset=UTF-8\r\n"
    .. "Server: " .. cfg_header_cons.header_server .. "\r\n"
  if bodyLength
  then
    header = header .. "Content-Length: " .. tostring(bodyLength) .. "\r\n"
  end
  if dateString
  then
    header = header .. "Date: " .. dateString .. "\r\n"
  end
  return header
end

--Process HTTP request
return function (client, request)
  local page
  --Dummy requests
  if request:match("GET /favicon.ico HTTP") then return end
  --Check authorization
  local auth = request:match("Authorization: Basic ([A-Za-z0-9+/=]+)")
  if (auth == nil or auth ~= cfg_credentials.httpSECRET)
  then
    page = updateTemplate(tmpl_cache.access.content)
    page = getHttpHeaders(401, #page).."\r\n"..page
    sendPage(client, page)
    return
  end
  local req_pin, req_state  
  local req_pinstate = request:match("GET /%?" .. cfg_tmpl_cons.reqvar_pin .. "=(%d+) HTTP/([1-9]+.[0-9]+)")
  --Process pins
  if req_pinstate == nil
  then
    if cfg_init.debug then print("No pin state") end
  else
    if cfg_init.debug then print("Pin state="..req_pinstate) end
    while #req_pinstate > 0
    do
      req_pin = req_pinstate:sub(1, 1) + 0
      req_state = req_pinstate:sub(2, 2) + 0
      local params = cfg_pins[req_pin]
      if params ~= nil
      then
          params.status = req_state
          gpio.write(params.pin, params.status)
      end
      req_pinstate = req_pinstate:sub(3, #req_pinstate)
    end
  end
  page = updateTemplate(tmpl_cache.page.content)
  page = getHttpHeaders(200, #page).."\r\n"..page
  sendPage(client, page)
end
