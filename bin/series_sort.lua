#!/usr/bin/env lua

local yaml = require("yaml")

local project = os.getenv("PROJECT")

function dump(...)
  local arg = { ... } -- Avoid things that Lua stuffs in arg like args to self()
  require("pl.pretty").dump(#arg == 1 and arg[1] or arg, "/dev/stderr")
end

local booktitles = {}
local books = { ... } -- arg has 0 and -1 keys that aren't the passed arguments

local seriesmeta = yaml.loadpath(project .. '.yml')

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
  local bookid = book:gsub("-.*", "")
  for key,val in ipairs(seriestitles) do
    if seriesorders[fetchtitle(bookid)] then
      return seriesorders[fetchtitle(bookid)]
    end
    if val == fetchtitle(bookid) then
      return key
    end
  end
end

fetchtitle = function (bookid)
  if not booktitles[bookid] then
    booktitles[bookid] = yaml.loadpath(bookid .. '.yml').title
  end
  return booktitles[bookid]
end

table.sort(books, seriessort)

print(table.concat(books, " "))
