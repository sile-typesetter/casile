publisher = "viachristus"
local book = SILE.require("classes/book")
local plain = SILE.require("classes/plain")
local vc = book { id = "vc" }

-- Add a shortcut method to dump tables in a pretty-print format to stderr
local dump = require("pl.pretty").dump
local d = function(object) dump(object, "/dev/stderr") end

vc:loadPackage("folio")

vc.endPage = function (self)
  vc:moveTocNodes()

  if (not SILE.scratch.headers.skipthispage) then
    SILE.settings.pushState()
    SILE.settings.reset()
    if (vc:oddPage() and SILE.scratch.headers.right) then
      SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
        SILE.call("output-right-running-head")
      end)
    elseif (not(vc:oddPage()) and SILE.scratch.headers.left) then
      SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
        SILE.call("output-left-running-head")
      end)
    end
    SILE.settings.popState()
  else
    SILE.scratch.headers.skipthispage = false
  end
  return plain.endPage(book)
end

return vc
