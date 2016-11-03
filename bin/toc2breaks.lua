#!/bin/env lua

-- local dump = require("pl.pretty").dump

local tocfile = io.open(arg[1])
if not tocfile then return false end
local doc = tocfile:read("*all")
local toc = assert(loadstring(doc))()

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

-- Output a list suitable for shell script parsing
for i, v in pairs(breaks) do
    print(string.format("%03d %s", i, v))
end
