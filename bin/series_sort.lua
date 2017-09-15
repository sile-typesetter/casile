#!/usr/bin/env lua

local yaml = require("yaml")

PROJECT = os.getenv("PROJECT")
SORTORDER = os.getenv("SORTORDER")

function dump(...)
  local arg = { ... } -- Avoid things that Lua stuffs in arg like args to self()
  require("pl.pretty").dump(#arg == 1 and arg[1] or arg, "/dev/stderr")
end

local booktitles = {}
local books = { ... } -- arg has 0 and -1 keys that aren't the passed arguments

local seriesmeta = yaml.loadpath(PROJECT .. '.yml')

local seriestitles = {}
local seriesorders = {}
for _, title in ipairs(seriesmeta.seriestitles) do
  table.insert(seriestitles, title.title)
  seriesorders[title.title] = title.order
end

seriessort = function (a, b)
  return getorder(a) < getorder(b)
end

getorder = function (book)
  if SORTORDER == "alphabetical" then
    return book
  end
  local bookid = book:gsub("-.*", "")
  for key,val in ipairs(seriestitles) do
    if SORTORDER == "manual" then
      if seriesorders[fetchtitle(bookid)] then
        return seriesorders[fetchtitle(bookid)]
      end
    elseif SORTORDER == "meta" then
      if val == fetchtitle(bookid) then
        return key
      end
    end
  end
  return 1 -- TODO: add option for sorting by publish date
end

fetchtitle = function (bookid)
  if not booktitles[bookid] then
    booktitles[bookid] = yaml.loadpath(bookid .. '.yml').title
  end
  return booktitles[bookid]
end

if not (SORTORDER == "none") then
  table.sort(books, seriessort)
end

print(table.concat(books, " "))
