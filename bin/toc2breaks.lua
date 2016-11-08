#!/bin/env lua

-- local dump = require("pl.pretty").dump

local tocfile = io.open(arg[1], "r")
if not tocfile then return false end
local doc = tocfile:read("*a")
tocfile:close()
local toc = assert(loadstring(doc))()

local basename = arg[2]
local share = arg[3]

local yaml = require("yaml")
local meta = yaml.loadpath(basename .. ".yml")

-- local meta = yaml.load(doc)

local infofile = io.open(arg[4], "w")
if not infofile  then return false end

local infow = function(str, endpar)
  str = str or ""
  endpar = endpar and "\n" or ""
  infofile:write(str .. "\n" .. endpar)
end

infow("BOOK NAME:")
infow(meta.title, true)

infow("SUBTITLE:")
infow(meta.subtitle, true)

for k, v in ipairs(meta.creator) do
  if v.role == "author" then meta.author = v.text end
end

infow("AUTHOR:" )
infow(meta.author, true)

-- Drop the first TOC entry, the top of the file will be 1
table.remove(toc, 1)

local lastpage = 1
local breaks = { 1 }

-- Get a table of major (more that 2 pages apart) TOC entries
for k, tocentry in pairs(toc) do
  local pageno = tonumber(tocentry.pageno)
  if pageno > lastpage + 2 then
    table.insert(breaks, pageno)
    lastpage = pageno
  end
end

-- Convert the table to page rages suitable for pdftk
for i, v in pairs(breaks) do
  if i ~= 1 then
    breaks[i-1] = breaks[i-1] .. "-" .. v - 1
  end
end
breaks[#breaks] = breaks[#breaks] .. "-end"

infow("WHOLE FILE:")
local out = basename .. "-app.pdf"
infow(share .. out, true)

infow("--------------------------------------------------------------------------------", true)

-- Output a list suitable for shell script parsing
for i, v in pairs(breaks) do
  local n = string.format("%03d", i)
  local out = basename .. "-app-" .. n .. ".pdf"

  -- Fieds expected by makefile to pass to pdftk
  print(n, v, out)

  -- Human readable info for copy/paste to the church app
  infow("CHUNK " .. i  .. ":")
  infow(share .. out, true)
end

infofile:close()
