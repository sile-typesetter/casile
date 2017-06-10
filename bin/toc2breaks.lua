#!/usr/bin/env lua

local project = os.getenv("PROJECT")
local basename = arg[1]

local tocfile = io.open(arg[2], "r")
if not tocfile then return false end
local doc = tocfile:read("*a")
tocfile:close()
local toc = assert(loadstring(doc))()

local yaml = require("yaml")
local meta = yaml.loadpath(arg[3])

local share = "https://nextcloud.alerque.com/" .. (meta.nextcloudshare and "index.php/s/" .. meta.nextcloudshare .. "/download?path=%2F&files=" or "remote.php/webdav/viachristus/" .. project .. "/")

local infofile = io.open(arg[4], "w")
if not infofile  then return false end

local infow = function(str, endpar)
  str = str or ""
  endpar = endpar and "\n" or ""
  infofile:write(str .. "\n" .. endpar)
end

infow("TITLE:")
infow(meta.title, true)

infow("SUBTITLE:")
infow(meta.subtitle, true)

for k, v in ipairs(meta.creator) do
  if v.role == "author" then meta.author = v.text end
end

infow("AUTHOR:" )
infow(meta.author, true)

infow("ABSTRACT:")
infow(meta.abstract, true)

infow("SINGLE PDF:")
local out = basename .. "-app.pdf"
infow(share .. out, true)

infow("MEDIA:")
local out = basename .. "-kare-pankart.jpg"
infow(share .. out, true)
local out = basename .. "-genis-pankart.jpg"
infow(share .. out, true)
local out = basename .. "-bant-pankart.jpg"
infow(share .. out, true)

local labels = {}
local breaks = {}

if #toc > 0 then
  -- Label the first chunk before we skip to the content
  labels[1] = toc[1].label[1]

  -- Drop the first TOC entry, the top of the file will be 1
  table.remove(toc, 1)

  local lastpage = 1
  breaks = { 1 }

  -- Get a table of major (more that 2 pages apart) TOC entries
  for i, tocentry in pairs(toc) do
    local pageno = tonumber(tocentry.pageno)
    if pageno > lastpage + 2 then
      table.insert(breaks, pageno)
      labels[#breaks] = tocentry.label[1]
      lastpage = pageno
    else
      labels[#breaks] =  labels[#breaks] .. ", " .. tocentry.label[1]
    end
  end

  -- Convert the table to page rages suitable for pdftk
  for i, v in pairs(breaks) do
    if i ~= 1 then
      breaks[i-1] = breaks[i-1] .. "-" .. v - 1
    end
  end
  breaks[#breaks] = breaks[#breaks] .. "-end"
end

-- Output a list suitable for shell script parsing
for i, v in pairs(breaks) do
  local n = string.format("%03d", i - 1)
  local out = basename .. "-app-" .. n .. ".pdf"

  -- Fieds expected by makefile to pass to pdftk
  print(v, out)

  -- Human readable info for copy/paste to the church app
  infow("CHUNK " .. i - 1  .. ":")
  infow(labels[i])
  infow(share .. out, true)
end

infofile:close()
