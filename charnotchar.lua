#!/usr/bin/env lua

local lpeg = require("lpeg")
local R, P, C = lpeg.R, lpeg.P, lpeg.C

local D = require("pl.pretty").dump

local tests = {
  "İbraniler",
  "Ülker",
  "Galatyalılar",
  "Ilık",
  "'Foo",
  "A. J. Hend",
  "1. zaman",
}

local foo = function (str)
  return str:match("([^%w]*[%w][^%w]*)(.*)")
end

local bar = function (str)
  local letter = P"Ü" + P"Ö" + P"Ş" + P"Ç" + P"İ" + P"Â" + R"AZ" + R"09"
  local lpunct = P"'" + P'"' + P"‘" + P"“"
  local tpunct = P"'" + P'l' + P"’" + P"”" + P"."
  local grp = C(lpunct^0 * letter * tpunct^0) * C(P(1)^1) * P(-1)
  return grp:match(str)
end

local dump = function (a, b)
  print(a or "~", " | ", b or "~")
end

for _, str in ipairs(tests) do
  local a, b = foo(str)
  local c, d = bar(str)
  print(str)
  print("----------")
  dump(a, b)
  dump(c, d)
  print()
end
