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

--Update input HTML template string by replacing placeholders with current values
local function updateTemplate(templateString)
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
  while #page > 0
  do
    client:send(page:sub(1, cfg_init.limitSend))
    page = page:sub(cfg_init.limitSend + 1, #page)
    collectgarbage()
  end
  client:close()
  collectgarbage()
end

--Create HTTP header for input code
local function getHttpHeader(code)
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
    header = "HTTP/1.1 "..code.." "..header.."\r\nServer: "..cfg_header_cons.header_server.."\r\n\r\n"
  else
    header = getHttpHeader(501)
  end
  return header
end

--Process HTTP request
return function (client, request)
  --Dummy requests
  if request:match("GET /favicon.ico HTTP") then return end
  --Check authorization
  local auth = request:match("Authorization: Basic ([A-Za-z0-9+/=]+)")
  if (auth == nil or auth ~= cfg_credentials.httpSECRET)
  then
    local page = getHttpHeader(401)..updateTemplate(tmpl_cache.access.content)
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
  sendPage(client, getHttpHeader(200)..updateTemplate(tmpl_cache.page.content))
end
