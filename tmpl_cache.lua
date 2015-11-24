--[[
NAME: HTML templates cache

DESCRIPTION:
- page ...... Template for primary web server HTML page
- access .... Template for error web server HTML page at authentication failure
- file ...... HTML file of a templates
- content ... Entire content of a template. It should not exceed 3072 bytes
              originally as well as after replacing placeholder with current values.

CREDENTIALS:
Author: Libor Gabaj
GitHub: https://github.com/mrkale/NodeMCU-WifiDoubleSwitch.git
--]]
tmpl_cache = {
  page =   {file = "tmpl_twoswitch_full.html", content = ''},
  access = {file = "tmpl_error_access.html", content = ''},
}

--Update input HTML template string by replacing placeholders with current values
local function updateTemplate(templateString)
  --Project constants
  templateString=templateString:gsub("\${version}", cfg_init.version)    
  --Language constants
  for key, value in pairs(cfg_tmpl_lang)
  do
    templateString=templateString:gsub("\${"..key.."}", value)    
  end
  --Template constants
  for key, value in pairs(cfg_tmpl_cons)
  do
    templateString=templateString:gsub("\${"..key.."}", value)    
  end
  return templateString
end

--Read templates from files in chunks
local function ReadTemplates()
  for cat, tmpl in pairs(tmpl_cache)
  do
    if not not file.open(tmpl.file)
    then
      --Read template file      
      if cfg_init.debug then print("Reading:", tmpl.file) end
      local chunk = ''
      repeat
        if chunk
        then
          tmpl.content = tmpl.content .. chunk
          chunk = file.read(cfg_init.limitFile)
        end
      until not chunk or (#tmpl.content + #chunk > cfg_init.limitString)
      file.close()
      --Update template with placeholders
      tmpl.content = updateTemplate(tmpl.content)
    end
  end
end

ReadTemplates()
ReadTemplates = nil
updateTemplate = nil
collectgarbage()