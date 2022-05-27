local book = require("classes/book")
local plain = require("classes/plain")

local cabook = pl.class(book)
cabook._name = "cabook"

function cabook:_init (options)

  -- print, paperback, hardcover, coil, stapled
  options.binding = options.binding or "print"
  local binding
  self:declareOption("binding", function (_, value)
      if value then binding = value end
      return binding
    end)
  options.crop = options.crop or true
  local crop
  self:declareOption("crop", function (_, value)
      if value then crop = SU.cast("boolean", value) end
      return crop
    end)
  options.background = options.background or true
  local background
  self:declareOption("background", function (_, value)
      if value then background = SU.cast("boolean", value) end
      return background
    end)
  options.verseindex = options.verseindex or false
  local verseindex
  self:declareOption("verseindex", function (_, value)
      if value then verseindex = SU.cast("boolean", value) end
      return verseindex
    end)

  book._init(self, options)

  if self.options.crop then
    self:loadPackage("crop", CASILE.casiledir)
  end
  if self.options.verseindex then
    self:loadPackage("verseindex", CASILE.casiledir)
  end
  -- CaSILE books sometimes have sections, sometimes don't.
  -- Initialize some sectioning levels to work either way
  self:loadPackage("counters")
  SILE.scratch.counters["sectioning"] = {
    value =  { 0, 0 },
    display = { "ORDINAL", "STRING" }
  }

  -- Avoid calling this (yet) if we're the parent of some child class
  if self._name == "cabook" then self:post_init() end
  return self
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
