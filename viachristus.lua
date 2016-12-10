SILE.require("packages/color")
SILE.require("packages/ifattop")
SILE.require("packages/leaders")
SILE.require("packages/raiselower")
SILE.require("packages/rebox");
SILE.require("packages/rules")
SILE.require("packages/image")

SILE.require("imprint");
SILE.require("hyphenation_exceptions");
SILE.require("inline_styles");
SILE.require("block_styles");

SILE.settings.set("typesetter.underfulltolerance", SILE.length.parse("6ex"))
SILE.settings.set("typesetter.overfulltolerance", SILE.length.parse("0.2ex"))

SILE.call("language", { main = "tr" })

SILE.call("footnote:separator", {}, function ()
  SILE.call("rebox", { width = "6em", height = "2ex" }, function ()
    SILE.call("hrule", { width = "5em", height = "0.2pt" })
  end)
  SILE.call("medskip")
end)

SILE.registerCommand("book:chapter:pre:tr", function ()
  SILE.typesetter:typeset("BÖLÜM ")
end)

SILE.registerCommand("book:chapter:post", function ()
  SILE.call("font", { filename = "avadanlik/fonts/FeFlow2.otf", size = "9pt" }, function ()
    SILE.call("skip", { height = "-3pt" })
    SILE.typesetter:typeset("a")
    SILE.call("medskip")
  end)
end)

SILE.registerCommand("book:part:pre", function ()
end)

SILE.registerCommand("book:part:post", function ()
  SILE.typesetter:typeset(" KISIM")
  SILE.call("par")
end)

SILE.registerCommand("book:subparagraph:post", function ()
end)

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
  SILE.call("fullrule")
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

SILE.call("book:seriffont", { size = "11.5pt" })

SILE.require("packages/linespacing")
SILE.settings.set("linespacing.method", "fit-font")
SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.6ex plus 0.2ex minus 0.2ex"))
SILE.settings.set("linebreak.hyphenPenalty", 300)

SILE.registerCommand("output-right-running-head", function (options, content)
  SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
  SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
  SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
  SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
  SILE.call("book:right-running-head-font", {}, function ()
    SILE.process(SILE.scratch.headers.right)
    SILE.call("hfill")
    SILE.call("book:page-number-font", {}, function ()
      SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.folio))
    end)
  end)
  SILE.typesetter:leaveHmode()
  SILE.call("skip", { height = "-8pt" })
  SILE.call("fullrule")
end)

SILE.registerCommand("output-left-running-head", function (options, content)
  SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
  SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
  SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
  SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
  SILE.call("book:left-running-head-font", {}, function ()
    SILE.call("book:page-number-font", {}, function ()
      SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.folio))
    end)
    SILE.call("hfill")
    SILE.call("meta:title")
  end)
  SILE.typesetter:leaveHmode()
  SILE.call("skip", { height = "-8pt" })
  SILE.call("fullrule")
end)

SILE.registerCommand("aki", function ()
  SILE.call("penalty", { penalty = -1 })
end)

SILE.registerCommand("left-running-head", function (options, content)
  SILE.scratch.headers.left = content
end, "Text to appear on the top of the left page");

SILE.registerCommand("right-running-head", function (options, content)
  SILE.scratch.headers.right = content
end, "Text to appear on the top of the right page");

SILE.registerCommand("book:sectioning", function (options, content)
  local content = SU.subContent(content)
  local level = SU.required(options, "level", "book:sectioning")
  if not (options.numbering == false or options.numbering == "false") then
    if not options.reset == true or options.reset == "true" then reset = false end
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
      toc_content[1] = val .. " KISIM: " .. uppercase(content[1])
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
    SILE.call("tocentry", { level = options.level }, toc_content)
  else
    SILE.call("tocentry", { level = options.level }, content)
  end
end)

-- This is the same as SILE's version but sets our no-headers variable on blank pages
SILE.registerCommand("open-double-page", function ()
  SILE.typesetter:leaveHmode();
  SILE.Commands["supereject"]();
  if SILE.documentState.documentClass:oddPage() then
    SILE.typesetter:typeset("")
    SILE.typesetter:leaveHmode();
    SILE.Commands["supereject"]();
    SILE.scratch.headers.skipthispage = true
  end
  SILE.typesetter:leaveHmode();
end)

local icu = require("justenoughicu")
local inputfilter = SILE.require("packages/inputfilter").exports

function uppercase(input)
  return icu.case(input, SILE.settings.get("document.language"), "upper")
end

function lowercase(input)
  return icu.case(input, SILE.settings.get("document.language"), "lower")
end

function titlecase(input)
  return icu.case(input, SILE.settings.get("document.language"), "title")
end

SILE.registerCommand("uppercase", function(options, content)
  SILE.process(inputfilter.transformContent(content, uppercase))
end, "Typeset the enclosed text as uppercase")

SILE.registerCommand("lowercase", function(options, content)
  SILE.process(inputfilter.transformContent(content, lowercase))
end, "Typeset the enclosed text as lowercase")

SILE.registerCommand("titlecase", function(options, content)
  SILE.process(inputfilter.transformContent(content, titlecase))
end, "Typeset the enclosed text as titlecase")

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
  if (options.display == "string") then return tr_num2text(options.value):lower() end
  if (options.display == "String") then return tr_num2text(options.value) end
  if (options.display == "STRING") then return uppercase(tr_num2text(options.value)) end
  if (options.display == "Ordinal") then return tr_num2text(options.value, true) end
  if (options.display == "ORDINAL") then return uppercase(tr_num2text(options.value, true)) end
  return originalFormatter(options)
end

SILE.registerCommand("tableofcontents:item", function (o,c)
  SILE.settings.temporarily(function ()
    SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
    SILE.call("tableofcontents:level"..o.level.."item", {}, function ()
      SILE.process(addDiscressionaryBreaks({},c))
      if o.level == 2 then
        SILE.call("hbox", {}, function ()
          SILE.call("dotfill")
          SILE.typesetter:typeset(o.pageno)
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
    SILE.call("book:sansfont", { size = "10pt", weight = 600 }, content)
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

SILE.registerCommand("fullrule", function (options, content)
  local height = options.height or "0.2pt"
  SILE.call("hrule", { height = height, width = SILE.typesetter.frame:lineWidth() })
end)

local insertions = SILE.require("packages/insertions")
SILE.registerCommand("footnote", function (options, content)
  local indent = "14pt"
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
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(indent))
  local material = SILE.Commands["vbox"]({}, function ()
    SILE.Commands["book:footnotefont"]({}, function ()
      SILE.call("noindent")
      SILE.typesetter:pushGlue({ width = 0 - SILE.length.parse(indent) })
      SILE.Commands["rebox"]({ width = indent }, function ()
        SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.footnote)..".")
      end)
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
  SILE.scratch.headers.skipthispage = true
  SILE.call("center", {}, function ()
    SILE.settings.set("linespacing.method", "fit-font")
    SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.4ex plus 0.1ex minus 0.1ex"))
    SILE.call("hbox")
    SILE.call("vfill")
    SILE.call("font", { style = "Italic", size = "14pt" }, content)
    SILE.call("bigskip")
  end)
end)

SILE.registerCommand("seriespage:series", function (options, content)
  SILE.call("center", {}, function ()
    SILE.call("book:chapterfont", {}, function ()
      SILE.process(content)
      SILE.call("aki")
      SILE.typesetter:typeset(" Serisi’ndeki Yayınlar")
      SILE.call("book:chapter:post")
    end)
  end)
end)

SILE.registerCommand("seriespage:pre", function (options, content)
  SILE.call("open-double-page")
  SILE.scratch.headers.skipthispage = true
  SILE.call("nofolios")
  SILE.call("topfill")
end)

-- Make this a function because we want to override it in some layouts
SILE.registerCommand("topfill", function (options, content)
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
      if options.breakbefore == true then
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
  if not options.breakat then options.breakat = "[:]" end
  if not options.breakwith then options.breakwith = "aki" end
  if not options.breakopts then options.breakopts = {} end
  if not options.breakall then options.breakall = false end
  if not options.breakbefore then options.breakbefore = false end
  return inputfilter.transformContent(content, discressionaryBreaksFilter, options)
end

SILE.registerCommand("addDiscressionaryBreaks", function (options, content)
  SILE.process(addDiscressionaryBreaks(options, content))
end, "Try to find good breakpoints based on punctuation")

if SILE.settings.get("document.language") == "tr" then
	os.setlocale("tr_TR.utf-8", "time")
end

SILE.registerCommand("pubDateFormat", function (options, content)
	local input =  SU.contentToString(content)
	local pattern = "(%d+)-(%d+)"
	local year, month = input:match(pattern)
	local ts = os.time({ year = year, month = month, day = 1 })
	SILE.typesetter:typeset(os.date("%B %Y", ts))
end, "Try to find good breakpoints based on punctuation")

setCommandDefaults = function (command, newOptions)
  local oldCommand = SILE.Commands[command]
  SILE.Commands[command] = function (options, content)
    for k, v in pairs(newOptions) do
      options[k] = options[k] or v
    end
    return oldCommand(options, content)
  end
end

local pdf = require("justenoughlibtexpdf")
local inputfilter = SILE.require("packages/inputfilter").exports

local urlFilter = function (node, content, breakpat)
  if type(node) == "table" then return node end
  local result = {}
  for token in SU.gtoke(node, breakpat) do
    if token.string then
      result[#result+1] = token.string
    else
      result[#result+1] = token.separator
      result[#result+1] = inputfilter.createCommand(
        content.pos, content.col, content.line,
        "penalty", { penalty = 100 }, nil
      )
    end
  end
  return result
end

SILE.registerCommand("href", function (options, content)
  if not options.src then
    options.src = content[1]
    local breakpat = options.breakpat or "/"
    content = inputfilter.transformContent(content, urlFilter, breakpat)
    SILE.call("color", { color = "#00FF00" }, content)
  elseif pdf then
    SILE.call("color", { color = "#0000FF" }, function ()
      SILE.call("pdf:externallink", { dest = options.src }, content)
    end)
  else
    SILE.call("color", { color = "#FF0000" }, content)
  end
end)

SILE.registerCommand("pdf:externallink", function (options,content)
  local dest = SU.required(options, "dest", "pdf:externallink")
  local llx, lly

  SILE.typesetter:pushHbox({
    value = nil,
    height = 0,
    width = 0,
    depth = 0,
    outputYourself = function (self,typesetter)
      llx = typesetter.frame.state.cursorX
      lly = SILE.documentState.paperSize[2] - typesetter.frame.state.cursorY
      pdf.begin_annotation()
    end
  })

  local hbox = SILE.Commands["hbox"]({}, content) -- hack

  SILE.typesetter:pushHbox({
    value = nil,
    height = 0,
    width = 0,
    depth = 0,
    outputYourself = function (self,typesetter)
      local d = "<</Type/Annot/Subtype/Link/C [ 1 0 0 ]/A<</Type/Action/S/URI/URI("..dest..")>>>>"
      pdf.end_annotation(d, llx, lly, typesetter.frame.state.cursorX, SILE.documentState.paperSize[2] -typesetter.frame.state.cursorY + hbox.height)
    end
  })

end)
