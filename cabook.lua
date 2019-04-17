local book = SILE.require("classes/book")
local plain = SILE.require("classes/plain")
local cabook = book { id = "cabook" }

cabook:declareOption("binding", "print") -- print, paperback, hardcover, coil, stapled
cabook:declareOption("crop", "true")
cabook:declareOption("background", "true")
cabook:declareOption("verseindex", "false")

cabook.init = function (self)
  if cabook.options.crop() == "true" then
    cabook:loadPackage("crop", CASILE.casiledir)
  end
  if cabook.options.verseindex() == "true" then
    cabook:loadPackage("verseindex", CASILE.casiledir)
  end
  return book:init()
end

cabook.endPage = function (self)
  cabook:moveTocNodes()
  if cabook.moveTovNodes then cabook:moveTovNodes() end

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

  local ret = plain.endPage(cabook)
  if cabook.options.crop() == "true" then cabook:outputCropMarks() end
  return ret
end

cabook.finish = function (self)
  if cabook.moveTovNodes then
    cabook:writeTov()
    SILE.call("tableofverses")
  end
  return book:finish()
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
