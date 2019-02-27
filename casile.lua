SILE.require("packages/color")
SILE.require("packages/ifattop")
SILE.require("packages/leaders")
SILE.require("packages/raiselower")
SILE.require("packages/rebox");
SILE.require("packages/rules")
SILE.require("packages/image")
SILE.require("packages/date")
SILE.require("packages/textcase")
SILE.require("packages/frametricks")
SILE.require("packages/footnotes")

SILE.require("imprint", CASILE.casiledir)
SILE.require("covers", CASILE.casiledir)
SILE.require("hyphenation_exceptions", CASILE.casiledir)
SILE.require("inline_styles", CASILE.casiledir)
SILE.require("block_styles", CASILE.casiledir)

textcase = SILE.require("packages/textcase").exports

SILE.settings.set("typesetter.underfulltolerance", SILE.length.parse("6ex"))
SILE.settings.set("typesetter.overfulltolerance", SILE.length.parse("0.2ex"))

SILE.call("footnote:separator", {}, function ()
  SILE.call("rebox", { width = "6em", height = "2ex" }, function ()
    SILE.call("hrule", { width = "5em", height = "0.2pt" })
  end)
  SILE.call("medskip")
end)

SILE.registerCommand("cabook:chapter:pre:tr", function ()
  SILE.typesetter:typeset("BÖLÜM ")
end)

SILE.registerCommand("cabook:chapter:post", function (options, content)
  options.weight = SU.boolean(options.decorate, true)
  SILE.call("novbreak")
  SILE.call("medskip")
  SILE.call("novbreak")
  if options.flourish then
    SILE.call("center", {} , function ()
      SILE.call("novbreak")
      SILE.call("font", { filename = CASILE.casiledir .. "/fonts/FeFlow2.otf", size = "9pt" }, function ()
        SILE.call("skip", { height = "-3pt" })
        SILE.typesetter:typeset("a")
        SILE.call("medskip")
      end)
    end)
  end
end)

SILE.registerCommand("cabook:part:pre", function () end)

SILE.registerCommand("cabook:part:post:tr", function ()
  SILE.typesetter:typeset(" KISIM")
  SILE.call("par")
end)

SILE.registerCommand("cabook:subparagraph:post", function () end)

SILE.registerCommand("tableofcontents:header", function ()
  SILE.call("center", {}, function ()
    SILE.call("hbox", {}, function ()
      SILE.call("skip", { height = "12ex" })
      SILE.call("tableofcontents:headerfont", { height = "12ex" }, function ()
        SILE.call("tableofcontents:title")
      end)
    end)
  end)
  SILE.call("bigskip")
  SILE.call("fullrule", { raise = 0 })
  SILE.call("bigskip")
end)

SILE.registerCommand("tableofcontents:footer", function ()
  SILE.call("vfill")
  SILE.call("break")
end)

SILE.registerCommand("wraptitle", function (options, content)
  SILE.process(content)
end)

SILE.registerCommand("wrapsubtitle", function (options, content)
  SILE.process(content)
end)

SILE.call("cabook:font:serif", { size = "11.5pt" })

SILE.require("packages/linespacing")
SILE.settings.set("linespacing.method", "fit-font")
SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.6ex plus 0.2ex minus 0.2ex"))
SILE.settings.set("linebreak.hyphenPenalty", 300)

SILE.registerCommand("left-running-head", function (options, content)
  SILE.scratch.headers.left = content
end, "Text to appear on the top of the left page")

SILE.registerCommand("right-running-head", function (options, content)
  SILE.scratch.headers.right = content
end, "Text to appear on the top of the right page")

SILE.registerCommand("output-right-running-head", function (options, content)
  if not SILE.scratch.headers.right then return end
  SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
    SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
    SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
    SILE.call("cabook:font:right-header", {}, function ()
      SILE.process(SILE.scratch.headers.right)
      SILE.call("hfill")
      SILE.call("cabook:font:folio", {}, function ()
        SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.folio))
      end)
    end)
    SILE.typesetter:leaveHmode()
    SILE.call("skip", { height = "-8pt" })
    SILE.call("fullrule", { raise = 0 })
  end)
end)

SILE.registerCommand("output-left-running-head", function (options, content)
  if not SILE.scratch.headers.left then return end
  SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
    SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
    SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
    SILE.call("cabook:font:left-header", {}, function ()
      SILE.call("cabook:font:folio", {}, function ()
        SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.folio))
      end)
      SILE.call("hfill")
      SILE.call("meta:title")
    end)
    SILE.typesetter:leaveHmode()
    SILE.call("skip", { height = "-8pt" })
    SILE.call("fullrule", { raise = 0 })
  end)
end)

SILE.registerCommand("aki", function ()
  SILE.call("penalty", { penalty = -1 })
end)

SILE.registerCommand("book:sectioning", function (options, content)
  local content = SU.subContent(content)
  options.skiptoc = SU.boolean(options.skiptoc, false)
  options.numbering = SU.boolean(options.numbering, true)
  options.reset = SU.boolean(options.reset, false)
  local level = SU.required(options, "level", "book:sectioning")
  if options.numbering then
    SILE.call("increment-multilevel-counter", {
        id = "sectioning",
        level = options.level,
        display = options.display,
        reset = options.reset
      })
    local toc_content = {}
    for k, v in pairs(content) do
      toc_content[k] = v
    end
    local lang = SILE.settings.get("document.language")
    local counters = SILE.scratch.counters["sectioning"]
    if level == 1 then
      local val = SILE.formatCounter({ display = "ORDINAL", value = counters.value[level] })
      toc_content[1] = val .. " KISIM: " .. textcase.uppercase(content[1])
    elseif level == 2 then
      local val = SILE.formatCounter({ display = "arabic", value = counters.value[level] })
      toc_content[1] = val .. ". " .. content[1]
    end
    if options.prenumber then
      if SILE.Commands[options.prenumber..":"..lang] then options.prenumber = options.prenumber..":"..lang end
      if SILE.Commands["book:chapter:precounter"] then SILE.call("book:chapter:precounter") end
      SILE.call(options.prenumber)
    end
    SILE.call("show-multilevel-counter", { id = "sectioning", display = options.display, minlevel = level, level = level })
    if options.postnumber then
      if SILE.Commands[options.postnumber..":"..lang] then options.postnumber = options.postnumber..":"..lang end
      SILE.call(options.postnumber)
    end
    local number = SILE.formatCounter({ display = "arabic", value = counters.value[level] })
    if not skiptoc then SILE.call("tocentry", { level = options.level, number = tonumber(number) }, toc_content) end
  else
    if not skiptoc then SILE.call("tocentry", { level = options.level, number = false }, content) end
  end
end)

SILE.registerCommand("tocentry", function (options, content)
  SILE.call("info", {
    category = "toc",
    value = {
      label = content,
      number = options.number,
      skiptoc = options.skiptoc,
      level = (options.level or 1)
    }
  })
end)

-- This is the same as SILE's version but sets our no-headers variable on blank pages
-- ...and allows opening to an even page
SILE.registerCommand("open-page", function (options)
  local odd = SU.boolean(options.odd, not isScreenLayout())
  local double = SU.boolean(options.double, not isScreenLayout())
  local class = SILE.documentState.documentClass
  local count = 0
  repeat 
    if count > 0 then
      SILE.typesetter:typeset("")
      SILE.typesetter:leaveHmode()
      SILE.scratch.headers.skipthispage = true
    end
    SILE.typesetter:leaveHmode()
    SILE.Commands["supereject"]()
    count = count + 1
  until (not double or count > 1) and (not odd or class:oddPage())
  SILE.typesetter:leaveHmode()
end)

local function en_num2text (num, ordinal)
  local ord = ordinal or false
  local ones = { "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine" }
  local tens = { "Ten", "Twenty", "Thirty", "Fourty", "Fifty", "Sizty", "Seventy", "Eighty", "Ninety" }
  local places = { "Hundred", "Thousand", "Million", "Billion" }
  local ordinals = { "First", "Second", "Third", "Fourth", "Fith", "Sixth", "Seventh", "Eighth", "Ninte", "Tenth" }
  local num = string.reverse(num)
  local parts = {}
  for i = 1, #num do
    local val = tonumber(string.sub(num, i, i))
    if val >= 1 then
      if i == 1 then
        if ord then
          parts[#parts+1] = ordinals[val]
        else
          parts[#parts+1] = ones[val]
        end
      elseif i == 2 then
        parts[#parts+1] = tens[val]
      elseif i >= 3 then
        parts[#parts+1] = places[i-2]
        if val >= 2 then
          if ord then
            parts[#parts+1] = ordinals[val]
          else
            parts[#parts+1] = ones[val]
          end
        end
      end
    end
  end
  local words = {}
  for i = 1, #parts do
    words[#parts+1-i] = parts[i]
  end
  return table.concat( words, " " )
end

local function tr_num2text (num, ordinal)
  local ord = ordinal or false
  local ones = { "Bir", "İki", "Üç", "Dört", "Beş", "Altı", "Yedi", "Sekiz", "Dokuz" }
  local tens = { "On", "Yirmi", "Otuz", "Kırk", "Eli", "Altmış", "Yetmiş", "Seksen", "Dokuz" }
  local places = { "Yüz", "Bin", "Milyon", "Milyar" }
  local ordinals = { "Birinci", "İkinci", "Üçüncü", "Dördüncü", "Beşinci", "Altıncı", "Yedinci", "Sekizinci", "Dokuzuncu", "Onuncu" }
  local num = string.reverse(num)
  local parts = {}
  for i = 1, #num do
    local val = tonumber(string.sub(num, i, i))
    if val >= 1 then
      if i == 1 then
        if ord then
          parts[#parts+1] = ordinals[val]
        else
          parts[#parts+1] = ones[val]
        end
      elseif i == 2 then
        parts[#parts+1] = tens[val]
      elseif i >= 3 then
        parts[#parts+1] = places[i-2]
        if val >= 2 then
          if ord then
            parts[#parts+1] = ordinals[val]
          else
            parts[#parts+1] = ones[val]
          end
        end
      end
    end
  end
  local words = {}
  for i = 1, #parts do
    words[#parts+1-i] = parts[i]
  end
  return table.concat( words, " " )
end

local originalFormatter = SILE.formatCounter
SILE.formatCounter = function (options)
  local numfunc = SILE.settings.get("document.language") == "tr" and tr_num2text or en_num2text
  if (options.display == "string") then return numfunc(options.value):lower() end
  if (options.display == "String") then return numfunc(options.value) end
  if (options.display == "STRING") then return textcase.uppercase(numfunc(options.value)) end
  if (options.display == "Ordinal") then return numfunc(options.value, true) end
  if (options.display == "ORDINAL") then return textcase.uppercase(numfunc(options.value, true)) end
  return originalFormatter(options)
end

SILE.registerCommand("chaptertoc", function (options, content)
  local thischapter = SILE.scratch.counters.sectioning.value[2]
  if thischapter < 1 then return end
  SILE.call("section", { numbering = false }, { "Bölümdekiler" })
  local tocfile,_ = io.open(SILE.masterFilename .. '.toc')
  if not tocfile then return end
  local doc = tocfile:read("*all")
  local toc = assert(loadstring(doc))()
  local zone = false
  local chaptertoc = {}
  for _, item in pairs(toc) do
    if zone and item.level > 2 then
      SILE.call("tableofcontents:item", {
          chaptertoc = true,
          level = item.level,
          pageno = item.pageno
        }, item.label)
    end
    if item.level == 2 then zone = item.number == thischapter end
  end
end)

SILE.registerCommand("tableofcontents", function (options, content)
  local tocfile,_ = io.open(SILE.masterFilename .. '.toc')
  if not tocfile then
    SILE.call("tableofcontents:notocmessage")
    return
  end
  local doc = tocfile:read("*all")
  local toc = assert(loadstring(doc))()
  local haschapters = false
  for i = 1, #toc do
    if toc[i].level == 2 then
      haschapters = true
    end
  end
  if not haschapters then return end
  SILE.call("tableofcontents:header")
  for _, item in ipairs(toc) do -- pairs turns things back in the wrong order sometime
    if not item.skiptoc then
      SILE.call("tableofcontents:item", {
          chaptertoc = false,
          level = item.level,
          pageno = item.pageno
        }, item.label)
    end
  end
  SILE.call("tableofcontents:footer")
end)

SILE.registerCommand("tableofcontents:item", function (options, content)
  options.dotfill = SU.boolean(options.dotfill, true)
  SILE.settings.temporarily(function ()
    SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
    SILE.call("tableofcontents:level"..options.level.."item", {}, function ()
      SILE.process(addDiscressionaryBreaks({}, content))
      if options.level == 2 then
        SILE.call("hbox", {}, function ()
          if options.dotfill then SILE.call("dotfill") else SILE.call("hfill") end
          SILE.typesetter:typeset(options.pageno)
        end)
      else
        SILE.call("hss")
      end
    end)
  end)
end)

SILE.registerCommand("tableofcontents:level1item", function (options, content)
  SILE.call("bigskip")
  SILE.settings.temporarily(function ()
    SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
    SILE.call("cabook:font:sans", { size = "10pt", weight = 600 }, content)
  end)
end)

SILE.registerCommand("tableofcontents:level2item", function (options, content)
  SILE.call("skip", { height = "4.5pt" })
  SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("5ex"))
  SILE.settings.set("document.rskip", SILE.nodefactory.newGlue("3em"))
  SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.newGlue("-2em"))
  SILE.call("glue", { width = "-2ex" })
  SILE.call("font", { size = "11pt" }, content)
  SILE.call("break")
  SILE.call("skip", { height = 0 })
end)

SILE.registerCommand("tableofcontents:level3item", function (options, content)
  SILE.call("skip", { height = "4.5pt" })
  SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("5ex"))
  SILE.settings.set("document.rskip", SILE.nodefactory.newGlue("3em"))
  SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.newGlue("-2em"))
  SILE.call("glue", { width = "-2ex" })
  SILE.call("font", { size = "10pt" }, content)
  SILE.call("break")
  SILE.call("skip", { height = 0 })
end)

SILE.registerCommand("tableofcontents:level4item", function (options, content)
  SILE.call("skip", { height = "4.5pt" })
  SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("5ex"))
  SILE.settings.set("document.rskip", SILE.nodefactory.newGlue("3em"))
  SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.newGlue("-2em"))
  SILE.call("glue", { width = "-2ex" })
  SILE.call("font", { size = "9pt" }, content)
  SILE.call("break")
  SILE.call("skip", { height = 0 })
end)

SILE.registerCommand("tableofcontents:level5item", function (options, content)
  SILE.call("skip", { height = "4.5pt" })
  SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("5ex"))
  SILE.settings.set("document.rskip", SILE.nodefactory.newGlue("3em"))
  SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.newGlue("-2em"))
  SILE.call("glue", { width = "-2ex" })
  SILE.call("font", { size = "9pt" }, content)
  SILE.call("break")
  SILE.call("skip", { height = 0 })
end)

local insertions = SILE.require("packages/insertions")
SILE.registerCommand("footnote", function (options, content)
  options.indent = options.indent or "14pt"
  SILE.call("footnotemark")
  local opts = SILE.scratch.insertions.classes.footnote
  local f = SILE.getFrame(opts["insertInto"].frame)
  local oldT = SILE.typesetter
  SILE.typesetter = SILE.typesetter {}
  SILE.typesetter:init(f)
  SILE.typesetter.pageTarget = function () return 0xFFFFFF end
  SILE.settings.pushState()
  SILE.settings.reset()
  SILE.settings.set("linespacing.method", "fit-font")
  SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.05ex plus 0.1pt minus 0.1pt"))
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(options.indent))
  local material = SILE.Commands["vbox"]({}, function ()
    SILE.Commands["cabook:font:footnote"]({}, function ()
      SILE.call("footnote:counter", options, content)
      -- don't justify footnotes
      SILE.call("raggedright", {}, function ()
        --inhibit hyphenation in footnotes
        SILE.call("font", { language = "und" }, content)
      end)
    end)
  end)
  SILE.settings.popState()
  SILE.typesetter = oldT
  insertions.exports:insert("footnote", material)
  SILE.scratch.counters.footnote.value = SILE.scratch.counters.footnote.value + 1
end)

SILE.registerCommand("footnote:counter", function (options, content)
  SILE.call("noindent")
  local width = SILE.length.parse(options.indent)
  SILE.typesetter:pushGlue({ width = width:negate() })
  SILE.call("rebox", { width = tostring(width) }, function ()
    SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.footnote) .. ".")
  end)
end)

SILE.scratch.insertions.classes.footnote.interInsertionSkip = SILE.length.parse("0.7ex plus 0 minus 0")

SILE.registerCommand("font:la", function (options, content)
	options.style = options.style or "Italic"
	SILE.call("font", options, content)
end)
SILE.registerCommand("font:el", function (options, content)
	options.style = options.style or "Italic"
	SILE.call("font", options, content)
end)
SILE.registerCommand("lang", function (options, content)
	local language = options.language or "und"
	local fontfunc = SILE.Commands[SILE.Commands["font:" .. language] and "font:" .. language or "font"]
	fontfunc({ language = language }, content)
end)
SILE.registerCommand("langund", function (options, content)
	SILE.call("lang", {}, content)
end)
SILE.registerCommand("langel", function (options, content)
	SILE.call("lang", { language = "el" }, content)
end)
SILE.registerCommand("langla", function (options, content)
	SILE.call("lang", { language = "la" }, content)
end)
SILE.registerCommand("langen", function (options, content)
	SILE.call("lang", { language = "en" }, content)
end)
SILE.registerCommand("langde", function (options, content)
	SILE.call("lang", { language = "de" }, content)
end)
SILE.registerCommand("langfr", function (options, content)
	SILE.call("lang", { language = "fr" }, content)
end)
SILE.registerCommand("langnl", function (options, content)
	SILE.call("lang", { language = "nl" }, content)
end)
SILE.registerCommand("langhe", function (options, content)
	SILE.call("lang", { language = "he" }, content)
end)

SILE.registerCommand("quote", function (options, content)
  options.setback = options.setback or SILE.settings.get("document.parindent")
  SILE.settings.pushState()
  SILE.settings.temporarily(function ()
    SILE.call("noindent")
    SILE.settings.set("document.rskip", SILE.nodefactory.newGlue(options.setback))
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(options.setback))
    SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.parindent", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.parskip", SILE.nodefactory.newVglue("1.5ex"))
    SILE.process(content)
    SILE.settings.set("document.parskip", SILE.nodefactory.zeroVglue)
    SILE.typesetter:pushGlue(SILE.nodefactory.hfillGlue)
    SILE.call("novbreak")
    SILE.call("par")
    SILE.call("novbreak")
  end)
  SILE.settings.popState()
  SILE.call("skip", { height = "6pt" })
  SILE.call("novbreak")
  SILE.call("noindent")
end, "Typeset quotation blocks")

SILE.registerCommand("excerpt", function ()
  SILE.call("font", { size = "0.975em" })
  SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.675ex plus 0.05ex minus 0.05ex"))
end)

SILE.scratch.last_was_ref = false
SILE.typesetter:registerPageEndHook(function ()
  SILE.scratch.last_was_ref = false
end)

SILE.registerCommand("verse", function ()
  if SILE.scratch.last_was_ref then
    SILE.call("skip", { height = "-3en" })
  end
  SILE.scratch.last_was_ref = false
  SILE.call("font", { family = "Libertinus Serif", weight = 400, style = "Italic", features = "+salt,+ss02,+onum,+liga,+dlig,+clig" })
  SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.25ex plus 0.05ex minus 0.05ex"))
end)

SILE.registerCommand("poetry", function ()
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("30pt"))
  SILE.settings.set("document.rskip", SILE.nodefactory.hfillGlue)
  SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
  SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
end)

SILE.registerCommand("dedication", function (options, content)
  SILE.settings.temporarily(function ()
    SILE.call("class:dedication", options, content)
  end)
end)

SILE.registerCommand("class:dedication", function (options, content)
  options.eject = SU.boolean(options.eject, true)
  SILE.scratch.headers.skipthispage = true
  SILE.call("center", {}, function ()
    SILE.settings.set("linespacing.method", "fit-font")
    SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.4ex plus 0.1ex minus 0.1ex"))
    SILE.call("topfill")
    SILE.call("cabook:font:dedication", {}, content)
  end)
  if options.eject then SILE.call("eject") end
end)

SILE.registerCommand("seriespage:series", function (options, content)
  SILE.call("center", {}, function ()
    SILE.call("cabook:font:chaptertitle", {}, function ()
      SILE.process(content)
      SILE.call("aki")
      SILE.typesetter:typeset(" Serisi’ndeki Yayınlar")
      SILE.call("cabook:chapter:post")
    end)
  end)
end)

SILE.registerCommand("seriespage:pre", function (options, content)
  SILE.call("open-page")
  SILE.scratch.headers.skipthispage = true
  SILE.call("nofolios")
  SILE.call("topfill")
end)

-- Make this a function because we want to override it in some layouts
SILE.registerCommand("topfill", function (options, content)
  SILE.typesetter:leaveHmode()
  SILE.call("hbox")
  SILE.call("vfill")
end)

SILE.registerCommand("seriespage:title", function (options, content)
  SILE.call("raggedright", {}, function ()
    SILE.settings.set("current.parindent", SILE.nodefactory.newGlue("-2em"))
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("2em"))
    SILE.settings.set("linespacing.method", "fixed")
    SILE.settings.set("linespacing.fixed.baselinedistance", SILE.length.parse("3ex plus 1ex minus 0.5ex"))
    if not options.author then
      SILE.call("font", { style = "Italic", language = "und" }, content)
      SILE.call("medskip")
    else
      SILE.call("font", { weight = "600", language = "und" }, content)
      SILE.typesetter:typeset(" ")
      SILE.call("aki")
      SILE.typesetter:typeset("— ")
      SILE.call("font", { style = "Italic", language = "und" }, function ()
        SILE.typesetter:typeset(options.author)
      end)
      SILE.call("smallskip")
    end
  end)
end)

SILE.registerCommand("criticHighlight", function (options, content)
  SILE.settings.temporarily(function ()
    SILE.call("font", { weight = 600 })
    SILE.call("color", { color = "#0000E6" }, content)
  end)
end)

SILE.registerCommand("criticComment", function (options, content)
  SILE.settings.temporarily(function ()
    SILE.call("font", { style = "Italic" })
    SILE.call("color", { color = "#bdbdbd" }, function ()
      SILE.typesetter:typeset(" (")
      SILE.process(content)
      SILE.typesetter:typeset(")")
    end)
  end)
end)

SILE.registerCommand("criticAdd", function (options, content)
  SILE.settings.temporarily(function ()
    SILE.call("font", { weight = 600 })
    SILE.call("color", { color = "#0E7A00" }, content)
  end)
end)

SILE.registerCommand("criticDel", function (options, content)
  SILE.settings.temporarily(function ()
    SILE.call("font", { weight = 600 })
    SILE.call("color", { color = "#E60000" }, content)
  end)
end)

local inputfilter = SILE.require("packages/inputfilter").exports
local discressionaryBreaksFilter = function (content, args, options)
  local currentText = ""
  local result = {}
  local process
  local function insertText()
    if (#currentText>0) then
      table.insert(result, currentText)
      currentText = ""
    end
  end
  local function insertPenalty()
    table.insert(result, inputfilter.createCommand(
      content.pos, content.col, content.line, options.breakwith, options.breakopts
    ))
    if not options.breakall then
      process = function (separator) currentText = currentText..separator end
    end
  end
  process = function (separator)
    if options.replace then
      insertText()
      insertPenalty()
    elseif options.breakbefore == true then
      insertText()
      insertPenalty()
      currentText = currentText .. separator
    else
      currentText = currentText .. separator
      insertText()
      insertPenalty()
    end
  end
  for token in SU.gtoke(content, options.breakat) do
    if(token.string) then
      currentText = currentText .. token.string
    else
      process(token.separator)
    end
  end
  insertText()
  return result
end

addDiscressionaryBreaks = function (options, content)
  if type(options[1]) ~= "table" then options = { options } end
  for _, options in pairs(options) do
    if not options.breakat then options.breakat = "[:]" end
    if not options.breakwith then options.breakwith = "aki" end
    if not options.breakopts then options.breakopts = {} end
    if not options.breakall then options.breakall = false end
    if not options.breakbefore then options.breakbefore = false end
    if not options.replace then options.replace = false end
    content = inputfilter.transformContent(content, discressionaryBreaksFilter, options)
  end
  return content
end

SILE.registerCommand("addDiscressionaryBreaks", function (options, content)
  SILE.process(addDiscressionaryBreaks(options, content))
end, "Try to find good breakpoints based on punctuation")

SILE.registerCommand("pubDateFormat", function (options, content)
  local input = SU.contentToString(content)
  local date = {}
  for m in input:gmatch("(%d+)") do table.insert(date, tonumber(m)) end
  local ts = os.time({ year = date[1] or 1970, month = date[2] or 1, day = date[3] or 1 })
  SILE.call("date", { format = "%B %Y", time = ts, locale = "tr_TR.utf-8" })
end, "Output publication dates in proper format for imprint page")

local originalTypesetter = SILE.typesetter.typeset
dropcapNextLetter = function ()
  SILE.typesetter.typeset = function (self, text)
    local first, rest = text:match("([^%w]*%w)(.*)")
    if load and first and rest then
      SILE.typesetter.typeset = originalTypesetter
      SILE.call("dropcap", {}, { first })
      SILE.typesetter.typeset(self, rest)
    else
      originalTypesetter(self, text)
    end
  end
end

SILE.registerCommand("dropcap", function (options, content)
  SILE.call("noindent")
  SILE.call("float", { bottomboundary = "1.2ex", rightboundary = "1spc" }, function ()
    SILE.call("cabook:font:chaptertitle", { size = "5.2ex", weight = 800 }, content)
  end)
  SILE.call("indent")
end)

SILE.registerCommand("requireSpace", function (options, content)
	local required = SILE.length.parse(options.height or 1)
	SILE.typesetter:leaveHmode()
	local hbox = SILE.Commands["hbox"]({}, content)
	table.remove(SILE.typesetter.state.nodes) -- steal it back
	local heightOfPageSoFar = SILE.pagebuilder.collateVboxes(SILE.typesetter.state.outputQueue).height
	local heightOfFrame = SILE.typesetter.frame:height()
	if heightOfFrame - heightOfPageSoFar < required then
		SILE.call("supereject")
	end
end)

SILE.registerUnit("%pmed", { relative = true, definition = function (v)
  return v / 100 * (SILE.documentState.orgPaperSize[1] + SILE.documentState.orgPaperSize[2]) / 2
end})

local parseSize = function (size)
  return SILE.length.parse(size):absolute().length
end

constrainSize = function (ideal, max, min)
  local idealSize = parseSize(ideal)
  if max then
    local maxSize = parseSize(max)
    if idealSize > maxSize then return max end
  end
  if min then
    local minSize = parseSize(min)
    if idealSize < minSize then return min end
  end
  return ideal
end

isWideLayout = function ()
  return CASILE.layout == "banner" or CASILE.layout == "wide" or CASILE.layout == "screen"
end

isScreenLayout = function ()
  return CASILE.layout == "app" or CASILE.layout == "screen"
end

-- Apostrophe Hack, see https://github.com/simoncozens/sile/issues/355
SILE.registerCommand("ah", function ()
  SILE.call("discretionary", { prebreak = "-", replacement = "’" })
end)
