local book = SILE.require("classes/book")
local plain = SILE.require("classes/plain")
local cabook = book { id = "cabook" }

cabook:declareOption("binding", "print") -- print, paperback, hardcover, coil, stapled
cabook:declareOption("crop", "true")
cabook:declareOption("background", "true")
cabook:declareOption("verseindex", "false")

function cabook:init ()
  if self.options.crop() == "true" then
    self:loadPackage("crop", CASILE.casiledir)
  end
  if self.options.verseindex() == "true" then
    self:loadPackage("verseindex", CASILE.casiledir)
  end
  -- CaSILE books sometimes have sections, sometimes don't.
  -- Initialize some sectioning levels to work either way
  SILE.require("packages/counters")
  SILE.scratch.counters["sectioning"] = {
    value =  { 0, 0 },
    display = { "ORDINAL", "STRING" }
  }
  return book.init(self)
end

function cabook:endPage ()
  self:moveTocNodes()
  if self.moveTovNodes then self:moveTovNodes() end
  if not SILE.scratch.headers.skipthispage then
    SILE.settings.pushState()
    SILE.settings.reset()
    if self:oddPage() then
      SILE.call("output-right-running-head")
    else
      SILE.call("output-left-running-head")
    end
    SILE.settings.popState()
  end
  SILE.scratch.headers.skipthispage = false
  local ret = plain.endPage(self)
  if self.options.crop() == "true" then self:outputCropMarks() end
  return ret
end

function cabook:finish ()
  if self.moveTovNodes then
    self:writeTov()
    SILE.call("tableofverses")
  end
  return book.finish(self)
end

return cabook
