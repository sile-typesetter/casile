publisher = "viachristus"
local book = SILE.require("classes/book")
local plain = SILE.require("classes/plain")
local vc = book { id = "vc" }

vc:declareOption("crop", "true")
vc:declareOption("background", "true")

vc.endPage = function (self)
  vc:moveTocNodes()

  if not SILE.scratch.headers.skipthispage then
    SILE.settings.pushState()
    SILE.settings.reset()
    if vc:oddPage() then
      SILE.call("output-right-running-head")
    else
      SILE.call("output-left-running-head")
    end
    SILE.settings.popState()
  end
  SILE.scratch.headers.skipthispage = false

  return plain.endPage(vc)
end

-- I can't figure out how or where, but book.endPage() gets run on the last page
book.endPage = vc.endPage

return vc
