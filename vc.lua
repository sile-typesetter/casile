publisher = "viachristus"
local book = SILE.require("classes/book")
local plain = SILE.require("classes/plain")
local vc = book { id = "vc" }

vc.endPage = function (self)
  vc:moveTocNodes()

  if (not SILE.scratch.headers.skipthispage) then
    SILE.settings.pushState()
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
  end
  SILE.scratch.headers.skipthispage = false
  return plain.endPage(book)
end

return vc
