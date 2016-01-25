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
  --Project params
  require("s2eta")
  templateString=templateString:gsub("\${version}", cfg_init.version)    
  templateString=templateString:gsub("\${uptime}", s2eta.eta(cfg_init.uptime))    
  templateString=templateString:gsub("\${startDate}", cfg_init.startDate)    
  templateString=templateString:gsub("\${currDate}", cfg_init.currDate)    
  s2eta, package.loaded["s2eta"]=nil,nil
  collectgarbage()
  --Template constants
  for key, value in pairs(cfg_tmpl_cons)
  do
    templateString=templateString:gsub("\${"..key.."}", value)    
  end
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

--Create HTML page from template
local function getPage(tmpl)
  if not file.open(tmpl) then return '' end
  local chunk, content = '', ''  
  repeat
    if chunk
    then
      content = content .. chunk
      chunk = file.read(cfg_init.limitFile)
    end
    collectgarbage()
  until not chunk or (#content + #chunk > cfg_init.limitString)
  file.close()
  collectgarbage()
  --Update template placeholders
  return updateTemplate(content)
end

--Send final HTML page to the client (browser) in chunks
local function sendPage(client, page)
  local chunk
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
  collectgarbage()
end


--Create HTTP status line for input code
local function getHttpStatus(code)
  local httpCodes = {
    [200] = "OK",
    [400] = "Bad Request",
    [401] = "Authorization Required\r\nWWW-Authenticate: Basic realm=\""..cfg_header_cons.header_realm.."\"",
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
local function getHttpHeaders(code, bodyLength)
  local header = getHttpStatus(code)
    .. "Content-Type: text/html; charset=UTF-8\r\n"
    .. "Server: " .. cfg_header_cons.header_server .. "\r\n"
    .. "Date: " .. cfg_init.httpDate .. "\r\n"
  if bodyLength
  then
    header = header .. "Content-Length: " .. tostring(bodyLength) .. "\r\n"
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
    page = getPage(cfg_init.tmpl_err)
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
  --Prepare HTML page and send it
  page = getPage(cfg_init.tmpl_page)
  page = getHttpHeaders(200, #page).."\r\n"..page
  sendPage(client, page)
end
