local book = require("classes/book")
local plain = require("classes/plain")

local cabook = pl.class(book)
cabook._name = "cabook"

function cabook:_init (options)
  book._init(self, options)

  self:loadPackage("color")
  self:loadPackage("ifattop")
  self:loadPackage("leaders")
  self:loadPackage("raiselower")
  self:loadPackage("rebox");
  self:loadPackage("rules")
  self:loadPackage("image")
  self:loadPackage("date")
  self:loadPackage("textcase")
  self:loadPackage("frametricks")

  if self.options.crop then
    self:loadPackage("crop", CASILE.casiledir)
  end
  if self.options.verseindex then
    self:loadPackage("verseindex", CASILE.casiledir)
  end
  -- CaSILE books sometimes have sections, sometimes don't.
  -- Initialize some sectioning levels to work either way
  SILE.scratch.counters["sectioning"] = {
    value =  { 0, 0 },
    display = { "ORDINAL", "STRING" }
  }

  SILE.require("imprint", CASILE.casiledir)
  SILE.require("covers", CASILE.casiledir)
  SILE.require("hyphenation_exceptions", CASILE.casiledir)
  SILE.require("inline_styles", CASILE.casiledir)
  SILE.require("block_styles", CASILE.casiledir)

  self:registerPostinit(function ()
    require("casile", CASILE.casiledir)(self)
  end)

  -- Avoid calling this (yet) if we're the parent of some child class
  if self._name == "cabook" then self:post_init() end
  return self
end

function cabook:declareSettings ()

  book.declareSettings(self)

  -- require("classes.cabook-settings")()

end

function cabook:declareOptions ()
  book.declareOptions(self)
  local binding, crop, background, verseindex, layout
  self:declareOption("binding", function (_, value)
      if value then binding = value end
      return binding
    end)
  self:declareOption("crop", function (_, value)
      if value then crop = SU.cast("boolean", value) end
      return crop
    end)
  self:declareOption("background", function (_, value)
      if value then background = SU.cast("boolean", value) end
      return background
    end)
  self:declareOption("verseindex", function (_, value)
      if value then verseindex = SU.cast("boolean", value) end
      return verseindex
    end)
    -- SU.error("ga cl 2.5")
  self:declareOption("layout", function (_, value)
    if value then
      layout = value
      self:registerPostinit(function (_)
          require("layouts."..layout)(self)
        end)
    end
    return layout
    end)
end

function cabook:setOptions (options)
  options.binding = options.binding or "print" -- print, paperback, hardcover, coil, stapled
  options.crop = options.crop or true
  options.background = options.background or true
  options.verseindex = options.verseindex or false
  options.layout = options.layout or "a4"
  book.setOptions(self, options)
end

function cabook:registerCommands ()

  book.registerCommands(self)

  require("classes.cabook-commands")()

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
