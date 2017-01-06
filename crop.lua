SILE.require("packages/cropmarks");

if not sheetsize then
  local papersize = SILE.documentState.paperSize
  local w = papersize[1] + 56.6929 -- 10mm trim × 2
  local h = papersize[2] + 56.6929
  sheetsize = w .. "pt x " .. h .. "pt"
end

local outcounter = 1

SILE.registerCommand("crop:header", function (options, content)
  SILE.call("meta:surum")
  SILE.typesetter:typeset(" (" .. outcounter .. ") " .. os.getenv("HOSTNAME") .. " / " .. os.date("%Y-%m-%d, %X"))
  outcounter = outcounter + 1
end)

SILE.call("crop:setup", { papersize = sheetsize })
