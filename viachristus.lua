SILE.require("packages/color")
SILE.require("packages/ifattop")
SILE.require("packages/leaders")
SILE.require("packages/raiselower")
SILE.require("packages/rebox");
SILE.require("imprint");
SILE.require("hyphenation_exceptions");

SILE.registerCommand("book:monofont", function (options, content)
  options.family = options.family or "Hack"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:sansfont", function (options, content)
  options.family = options.family or "Libertinus Sans"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:seriffont", function (options, content)
  options.family = options.family or "Libertinus Serif"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:displayfont", function (options, content)
  options.family = "Libertinus Serif Display"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:partfont", function (options, content)
  options.weight = options.weight or 600
  SILE.call("book:sansfont", options, content)
end)

SILE.registerCommand("book:partnumfont", function (options, content)
  SILE.call("book:partfont", options, content)
end)

SILE.registerCommand("book:altseriffont", function (options, content)
  options.family = options.family or "Libertinus Serif"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:subparagraphfont", function (options, content)
  options.size = options.size or "11pt"
  options.features = options.features or "+smcp"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:footnotefont", function (options, content)
  options.size = options.size or "8.5pt"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:chapterfont", function (options, content)
  options.weight = options.weight or 600
  options.size = options.size or "16pt"
  SILE.call("book:seriffont", options, content)
end)

SILE.registerCommand("book:chapternumfont", function (options, content)
  options.family = options.family or "Libertinus Serif Display"
  options.size = options.size or "11pt"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:sectionfont", function (options, content)
  options.size = options.size or "8.5pt"
  SILE.call("book:chapterfont", options, content)
end)

SILE.registerCommand("verbatim:font", function (options, content)
  options.size = options.size or "10pt"
  SILE.call("book:monofont", options, content)
end)

SILE.registerCommand("book:page-number-font", function (options, content)
  options.style = options.style or "Roman"
  options.size = options.size or "13pt"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:left-running-head-font", function (options, content)
  options.size = options.size or "12pt"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:right-running-head-font", function (options, content)
  options.style = options.style or "Italic"
  options.size = options.size or "12pt"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:titlepage-title-font", function (options, content)
  SILE.call("book:partnumfont", options, content)
end)

SILE.registerCommand("book:titlepage-subtitle-font", function (options, content)
  SILE.call("book:partfont", options, content)
end)

SILE.registerCommand("book:titlepage-author-font", function (options, content)
  SILE.call("book:partfont", options, content)
end)

SILE.registerCommand("tableofcontents:headerfont", function (options, content)
  SILE.call("book:partfont", options, content)
end)

SILE.call("set", { parameter = "typesetter.underfulltolerance", value = "6ex" })
SILE.call("set", { parameter = "typesetter.overfulltolerance", value = "0.2ex" })

SILE.registerCommand("titlepage", function (options, content)
  if not SILE.Commands["meta:title"] then return end
  SILE.call("nofolios")
  SILE.call("open-double-page")
  SILE.call("center", {}, function ()
    SILE.call("hbox")
    SILE.call("skip", { height = "10%ph" })
    SILE.call("book:titlepage-title-font", { size = "7%pw" }, function ()
      SILE.call("wraptitle", {}, function ()
        SILE.call("meta:title", {}, function ()
        end)
      end)
    end)
    if SILE.Commands["meta:subtitle"] then
      SILE.call("bigskip")
      SILE.call("book:titlepage-subtitle-font", { size = "6%pw" }, function ()
        SILE.call("wrapsubtitle", {}, function ()
          SILE.call("meta:subtitle")
        end)
      end)
    end
    if SILE.Commands["meta:author"] then
      SILE.call("skip", { height = "8%ph" })
      SILE.call("book:titlepage-author-font", { size = "4%pw", weight = 300 }, function ()
        SILE.call("meta:author")
      end)
    end
    SILE.call("vfill")
    SILE.call("img", { src = "avadanlik/vc_logo_renksiz.pdf", width = "25%pw" })
  end)
  SILE.call("par")
  SILE.call("break")
end)

SILE.registerCommand("halftitlepage", function (options, content)
  if not SILE.Commands["meta:title"] then return end
  SILE.call("nofolios")
  SILE.call("center", {}, function ()
    SILE.call("hbox")
    SILE.call("skip", { height = "20%ph" })
    SILE.call("book:titlepage-title-font", { size = "4.5%pw" }, function ()
      SILE.call("wraptitle", {}, function ()
        SILE.call("meta:title", {}, function ()
        end)
      end)
    end)
  end)
end)

SILE.registerCommand("tableofcontents", function (options, content)
  local f,err = io.open(SILE.masterFilename .. '.toc')
  if not f then return end
  local doc = f:read("*all")
  local toc = assert(loadstring(doc))()
  SU.debug("viachristus", #toc)
  if #toc < 2 then return end -- Skip the TOC if there is only one top level entry
  SILE.call("tableofcontents:header")
  for i = 1, #toc do
    local item = toc[i]
    SILE.call("tableofcontents:item", { level = item.level, pageno = item.pageno }, item.label)
  end
  SILE.call("tableofcontents:footer")
end)


SILE.doTexlike([[
\language[main=tr]
\script[src=packages/rules]
\script[src=packages/image]
\script[src=packages/rebox]
%\script[src=packages/frametricks]
%\showframe[id=all]
\define[command=strong]{\font[weight=600]{\process}}%
\footnote:separator{\rebox[width=6em,height=2ex]{\hrule[width=5em,height=0.2pt]}\smallskip}
\define[command=book:chapter:pre:tr]{\book:chapternumfont BÖLÜM }
\define[command=book:chapter:post]{\font[filename=avadanlik/fonts/FeFlow2.otf,size=9pt]{\skip[height=-3pt]a\medskip}}
\define[command=book:part:pre]{}%
\define[command=book:part:post]{ KISIM\par}%
\define[command=book:subparagraph:post]{ }%
\define[command=tableofcontents:header]{\center{\hbox\skip[height=12ex]\tableofcontents:headerfont{\tableofcontents:title}}\bigskip\fullrule\bigskip}%
\define[command=tableofcontents:footer]{\vfill\break}%
\define[command=tableofcontents:level1item]{\bigskip\noindent\book:sansfont[size=10pt,weight=600]{\raggedright{\process}}}%
\define[command=tableofcontents:level2item]{\skip[height=4.5pt]\set[parameter=document.lskip,value=5ex]\set[parameter=document.rskip,value=3em]\set[parameter=typesetter.parfillskip,value=-2em]\noindent\glue[width=-2ex]\font[size=11pt]{\process}\break\skip[height=0]}%
\define[command=wraptitle]{\process}
\define[command=wrapsubtitle]{\process}
\book:seriffont[size=11.5pt]
\script[src=packages/linespacing]
\set[parameter=linespacing.method,value=fit-font]
\set[parameter=linespacing.fit-font.extra-space,value=0.6ex plus 0.2ex minus 0.2ex]
\set[parameter=linebreak.hyphenPenalty,value=300]
]])
local plain = SILE.require("classes/plain");
local book = SILE.require("classes/book");

book.endPage = function (self)
  book:moveTocNodes()

  if (not SILE.scratch.headers.skipthispage) then
    SILE.settings.pushState()
    SILE.settings.reset()
    if (book:oddPage() and SILE.scratch.headers.right) then
      SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
        SILE.call("book:right-running-head")
      end)
    elseif (not(book:oddPage()) and SILE.scratch.headers.left) then
      SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
        SILE.call("book:left-running-head")
      end)
    end
    SILE.settings.popState()
  else
    SILE.scratch.headers.skipthispage = false
  end
  return plain.endPage(book)
end

SILE.registerCommand("book:right-running-head", function (options, content)
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

SILE.registerCommand("book:left-running-head", function (options, content)
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
  local closure = SILE.settings.wrap()
  SILE.scratch.headers.left = function () closure(content) end
end, "Text to appear on the top of the left page");

SILE.registerCommand("right-running-head", function (options, content)
  local closure = SILE.settings.wrap()
  SILE.scratch.headers.right = function () closure(content) end
end, "Text to appear on the top of the right page");

local _initml = function (c)
  if not(SILE.scratch.counters[c]) then
    SILE.scratch.counters[c] = { value= { 0 }, display = { "arabic" } }
  end
end

SILE.registerCommand("my-increment-multilevel-counter", function (options, content)
  local c = options.id; _initml(c)
  local this = SILE.scratch.counters[c]
  local currentLevel = #this.value
  local level = tonumber(options.level) or currentLevel
  if level == currentLevel then
    this.value[level] = this.value[level] + 1
  elseif level > currentLevel then
    while level > currentLevel do
      currentLevel = currentLevel + 1
      if options.reset == false then
        this.value[currentLevel] = this.value[currentLevel-1]
      else
        this.value[currentLevel] = 1
      end
      this.display[currentLevel] = this.display[currentLevel-1]
    end
  else -- level < currentLevel
    this.value[level] = this.value[level] + 1
    while currentLevel > level do
      if not options.rest == false then this.value[currentLevel] = nil end
      this.display[currentLevel] = nil
      currentLevel = currentLevel - 1
    end
  end
  if options.display then this.display[currentLevel] = options.display end
end)

SILE.registerCommand("book:sectioning", function (options, content)
  local content = SU.subContent(content)
  local level = SU.required(options, "level", "book:sectioning")
  if not (options.numbering == false or options.numbering == "false") then
    if not options.reset == true or options.reset == "true" then reset = false end
    SILE.call("my-increment-multilevel-counter", {
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
      toc_content[1] = val .. " KISIM: " .. trupper(content[1])
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

SILE.registerCommand("chapter", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  SILE.call("set-counter", { id = "footnote", value = 1 })
  SILE.scratch.theChapter = content
  SILE.call("center", {}, function ()
    SILE.settings.temporarily(function ()
      SILE.typesetter:typeset(" ")
      SILE.call("skip", { height = "10%ph" })
      SILE.call("book:sectioning", {
        numbering = options.numbering,
        level = 2,
        reset = false,
        display = "STRING",
        prenumber = "book:chapter:pre",
        postnumber = "book:chapter:post"
      }, content)
      -- If Sectioning doesn't output numbering, the chapter starts too high on the page
      if (options.numbering == false or options.numbering == "false") then
        SILE.call("skip", { height = "10ex" })
      end
      SILE.call("book:chapterfont", {}, content)
      SILE.call("bigskip")
      SILE.call("fullrule")
      SILE.call("skip", { height = "-1ex" }) -- part of bug 262 hack
    end)
  end)
  SILE.call("left-running-head")
  SILE.Commands["right-running-head"]({}, function ()
    SILE.call("book:right-running-head-font", {}, content)
  end)
  SILE.scratch.headers.skipthispage = true
  if (options.numbering == false or options.numbering == "false") then
    SILE.call("skip", { height = "10pt" })
  end
  SILE.call("skip", { height = "8pt" })
  --SILE.call("nofoliosthispage")
end, "Begin a new chapter");

SILE.registerCommand("section", function (options, content)
  SILE.call("goodbreak")
  SILE.call("ifnotattop", {}, function ()
    SILE.call("skip", { height = "12pt plus 6pt minus 4pt" })
  end)
  SILE.settings.temporarily(function ()
    SILE.call("noindent")
    SILE.call("book:sectionfont", {}, function ()
      SILE.call("uppercase", {}, content)
    end)
  end)
  SILE.call("novbreak")
end, "Begin a new section")

SILE.registerCommand("part", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  SILE.call("set-counter", { id = "footnote", value = 1})
  SILE.call("center", {}, function ()
    SILE.call("book:partnumfont", { size = "5%pw" }, function ()
      SILE.call("hbox")
      SILE.call("skip", { height = "10%ph" })
      SILE.call("book:sectioning", {
        numbering = options.numbering,
        level = 1,
        reset = false,
        display = "ORDINAL",
        prenumber = "book:part:pre",
        postnumber = "book:part:post"
      }, content)
    end)
    SILE.call("medskip")
    SILE.Commands["book:partfont"]({ size = "4%pw" }, content);
    SILE.call("medskip")
    SILE.call("font", { filename = "avadanlik/fonts/FeFlow2.otf", size = "9pt" }, { "a" })
    SILE.call("bigskip")
  end)
  SILE.scratch.headers.skipthispage = true
end, "Begin a new part");

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

SILE.registerCommand("subparagraph", function (options, content)
  SILE.typesetter:leaveHmode()
  SILE.call("novbreak")
  -- Backtracking to approximate the skip after quotations
  SILE.call("skip", { height = "-8pt" })
  SILE.call("novbreak")
  SILE.Commands["book:subparagraphfont"]({}, function ()
    SILE.call("raggedleft", {}, function ()
      SILE.settings.set("document.rskip", SILE.nodefactory.newGlue("20pt"))
      SILE.process(content)
    end)
  end)
  SILE.typesetter:leaveHmode()
  SILE.call("novbreak")
  SILE.call("skip", { height = "3en" })
  SILE.call("novbreak")
  SILE.scratch.last_was_ref = true
end, "Begin a new subparagraph")

local utf8 = require("lua-utf8")
local inputfilter = SILE.require("packages/inputfilter").exports
function trupper (string)
  string = string:gsub("i", "İ")
  return utf8.upper(string)
end
SILE.registerCommand("uppercase", function (options, content)
  SILE.process(inputfilter.transformContent(content, trupper))
end, "Typeset the enclosed text as uppercase")

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

SILE.formatCounter = function (options)
  if (options.display == "roman") then return romanize(options.value):lower() end
  if (options.display == "Roman") then return romanize(options.value) end
  if (options.display == "alpha") then return alpha(options.value) end
  --if (options.display == "Alpha") then return alpha(options.value):upper() end
  if (options.display == "string") then return tr_num2text(options.value):lower() end
  if (options.display == "String") then return tr_num2text(options.value) end
  if (options.display == "STRING") then return trupper(tr_num2text(options.value)) end
  if (options.display == "Ordinal") then return tr_num2text(options.value, true) end
  if (options.display == "ORDINAL") then return trupper(tr_num2text(options.value, true)) end
  return tostring(options.value);
end

local _initml = function (c)
  if not(SILE.scratch.counters[c]) then
    SILE.scratch.counters[c] = { value= { 0 }, display= { "arabic" } };
  end
end

SILE.registerCommand("increment-multilevel-counter", function (options, content)
  local c = options.id; _initml(c)
  local this = SILE.scratch.counters[c]

  local currentLevel = #this.value
  local level = tonumber(options.level) or currentLevel
  local prev
  if level == currentLevel then
    this.value[level] = this.value[level] + 1
  elseif level > currentLevel then
    while level > currentLevel do
      if not(options.reset == false) then
        prev = 0
      else
        prev = this.value[currentLevel] + 1
      end
      currentLevel = currentLevel + 1
      this.value[currentLevel] = prev
      this.display[currentLevel] = this.display[currentLevel -1]
    end
  else -- level < currentLevel
    this.value[level] = this.value[level] + 1
    while currentLevel > level do
      this.value[currentLevel] = nil
      this.display[currentLevel] = nil
      currentLevel = currentLevel - 1
    end
  end
  if options.display then this.display[currentLevel] = options.display end
end)

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

SILE.doTexlike([[
\define[command=langel]{\font[language=el,style=Italic]{\process}}
\define[command=langhe]{\font[language=he,style=Italic]{\process}}
\define[command=langund]{\font[language=und,style=Italic]{\process}}
\define[command=langla]{\font[language=la,style=Italic]{\process}}
\define[command=langen]{\font[language=en,style=Italic]{\process}}
]])

-- For when pushBack breaks my whitespace
-- Remove this dreadful hack when https://github.com/simoncozens/sile/issues/262
SILE.registerCommand("hackBack", function (options, content)
  SILE.call("par")
  SILE.call("hbox")
  SILE.call("skip", { height = "4.1em" })
  SILE.call("kern")
  SILE.call("par")
  SILE.call("skip", { height = "-4em" })
end)

SILE.registerCommand("quote", function (options, content)
  options.setback = options.setback or SILE.settings.get("document.parindent")
  SILE.call("hackBack")
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
