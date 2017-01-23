publisher = "viachristus"
local book = SILE.require("classes/book")
local plain = SILE.require("classes/plain")
local cabook = book { id = "cabook" }

cabook:declareOption("crop", "true")
cabook:declareOption("background", "true")

cabook.endPage = function (self)
  cabook:moveTocNodes()

  if not SILE.scratch.headers.skipthispage then
    SILE.settings.pushState()
    SILE.settings.reset()
    if cabook:oddPage() then
      SILE.call("output-right-running-head")
    else
      SILE.call("output-left-running-head")
    end
    SILE.settings.popState()
  end
  SILE.scratch.headers.skipthispage = false

  return plain.endPage(cabook)
end

-- CaSILE books sometimes have sections, sometimes don't.
-- Initialize some sectioning levels to work either way
SILE.scratch.counters["sectioning"] = {
  value =  { 0, 0 },
  display = { "ORDINAL", "STRING" }
}

-- I can't figure out how or where, but book.endPage() gets run on the last page
book.endPage = cabook.endPage

return cabook
