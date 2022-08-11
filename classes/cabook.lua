local book = require("classes/book")
local plain = require("classes/plain")

local class = pl.class(book)
class._name = "cabook"

function class:_init (options)
  if not CASILE then
    SU.error("Cannot run without CASILE global instantiated")
  end
  book._init(self, options)
  self:loadPackage("casile")
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
  self:loadPackage("inputfilter")
  self:loadPackage("linespacing")
  if self.options.verseindex then
    self:loadPackage("verseindex")
  end
  self:loadPackage("imprint")
  self:loadPackage("covers")
  self:loadPackage("cabook-commands")
  self:loadPackage("cabook-inline-styles")
  self:loadPackage("cabook-block-styles")
  if CASILE.language then
    SILE.settings:set("document.language", CASILE.language, true)
  end
  SILE.settings:set("font.family", "Libertinus Serif", true)
  SILE.settings:set("font.size", "11.5", true)
  self:registerPostinit(function (_)
    -- CaSILE books sometimes have sections, sometimes don't.
    -- Initialize some sectioning levels to work either way
    SILE.scratch.counters["sectioning"] = {
      value =  { 0, 0 },
      display = { "ORDINAL", "STRING" }
    }
    require("hyphenation_exceptions")
    SILE.settings:set("typesetter.underfulltolerance", SILE.length("6ex"))
    SILE.settings:set("typesetter.overfulltolerance", SILE.length("0.2ex"))
    table.insert(SILE.input.preambles, function ()
      SILE.call("footnote:separator", {}, function ()
        SILE.call("rebox", { width = "6em", height = "2ex" }, function ()
          SILE.call("hrule", { width = "5em", height = "0.2pt" })
        end)
        SILE.call("medskip")
      end)
    end)
    SILE.settings:set("linespacing.method", "fit-font")
    SILE.settings:set("linespacing.fit-font.extra-space", SILE.length("0.6ex plus 0.2ex minus 0.2ex"))
    SILE.settings:set("linebreak.hyphenPenalty", 300)
    SILE.scratch.insertions.classes.footnote.interInsertionSkip = SILE.length("0.7ex plus 0 minus 0")
    SILE.scratch.last_was_ref = false
    SILE.typesetter:registerPageEndHook(function ()
      SILE.scratch.last_was_ref = false
    end)
  end)
end

function class:declareOptions ()
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
  self:declareOption("layout", function (_, value)
    if value then
      layout = value
      require("layouts."..layout)(self)
    end
    return layout
    end)
end

function class:setOptions (options)
  options.binding = options.binding or "print" -- print, paperback, hardcover, coil, stapled
  options.crop = options.crop or true
  options.background = options.background or true
  options.verseindex = options.verseindex or false
  options.layout = options.layout or "a4"
  book.setOptions(self, options)
end

function class:endPage ()
  if not SILE.scratch.headers.skipthispage then
    SILE.settings:pushState()
    SILE.settings:reset()
    if self:oddPage() then
      SILE.call("output-right-running-head")
    else
      SILE.call("output-left-running-head")
    end
    SILE.settings:popState()
  end
  SILE.scratch.headers.skipthispage = false
  return plain.endPage(self)
end

return class
