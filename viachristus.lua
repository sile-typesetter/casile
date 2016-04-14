SILE.registerCommand("book:monofont", function(options, content)
  options.family = options.family or "Hack"
  SILE.call("font", options, content)
end)
SILE.registerCommand("book:sansfont", function(options, content)
  options.family = options.family or "Montserrat"
  SILE.call("font", options, content)
end)
SILE.registerCommand("book:seriffont", function(options, content)
  options.family = options.family or "Crimson"
  SILE.call("font", options, content)
end)
SILE.registerCommand("book:partfont", function(options, content)
  options.weight = options.weight or 600
  SILE.call("book:sansfont", options, content)
end)
SILE.registerCommand("book:partnumfont", function(options, content)
  SILE.call("book:partfont", options, content)
end)
SILE.registerCommand("book:altseriffont", function(options, content)
  options.family = options.family or "Libertinus Serif"
  SILE.call("font", options, content)
end)
SILE.registerCommand("book:subparagraphfont", function(options, content)
  options.size = options.size or "11pt"
  options.features = options.features or "+smcp"
  SILE.call("book:altseriffont", options, content)
end)
SILE.registerCommand("book:footnotefont", function(options, content)
  options.size = options.size or "8.5pt"
  SILE.call("book:altseriffont", options, content)
end)
SILE.registerCommand("book:chapterfont", function(options, content)
  options.weight = options.weight or 600
  options.size = options.size or "10pt"
  SILE.call("book:sansfont", options, content)
end)
SILE.registerCommand("book:chapternumfont", function(options, content)
  options.family = options.family or "Libertinus Serif Display"
  options.size = options.size or "11pt"
  SILE.call("font", options, content)
end)
SILE.registerCommand("book:sectionfont", function(options, content)
  options.size = options.size or "8.5pt"
  SILE.call("book:chapterfont", options, content)
end)
SILE.registerCommand("verbatim:font", function(options, content)
  options.size = options.size or "10pt"
  SILE.call("book:monofont", options, content)
end)
  --options.filename = "fonts/Scriptina_Pro.otf"
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
\define[command=book:left-running-head-font]{\book:altseriffont[size=12pt]{\process}}%
\define[command=book:right-running-head-font]{\book:altseriffont[size=12pt,style=Italic]{\process}}%
\define[command=book:page-number-font]{\book:altseriffont[style=Roman,size=13pt]{\process}}%
\define[command=tableofcontents:headerfont]{\book:partfont{\process}}%
\define[command=tableofcontents:header]{\center{\hbox\skip[height=12ex]\tableofcontents:headerfont{\tableofcontents:title}}\bigskip\fullrule\bigskip}%
\define[command=tableofcontents:level1item]{\bigskip\noindent\book:sansfont[size=10pt,weight=600]{\process}\break}%
\define[command=tableofcontents:level2item]{\skip[height=4pt]\noindent\glue[width=2ex]\font[size=11pt]{\process}\break\skip[height=0]}%
\define[command=wraptitle]{\process}
\define[command=wrapsubtitle]{\process}
\define[command=halftitlepage]{\nofolios\center{\hbox\skip[height=20ph]\book:partnumfont[size=4.5pw]{\wraptitle{\meta:wraptitle}}\bigskip}}
\define[command=titlepage]{\open-double-page\center{\hbox\skip[height=10ph]\book:partnumfont[size=7pw]{\wraptitle{\meta:title}}\bigskip\book:partfont{\font[size=6pw]{\wrapsubtitle{\meta:subtitle}}}\skip[height=8ph]\book:partfont{\font[size=4pw,weight=300]{\meta:author}}\vfill{}\img[src=avadanlik/vc_logo_renksiz.pdf,width=25pw]}\par\break}
\book:seriffont[size=11.5pt]
\script[src=packages/linespacing]
\set[parameter=linespacing.method,value=fit-font]
\set[parameter=linespacing.fit-font.extra-space,value=1.15ex plus 0.5pt minus 0.5pt]
\set[parameter=linebreak.hyphenPenalty,value=300]
\set[parameter=document.spaceskip,value=0.6ex plus 0.4ex minus 0.2ex]
\define[command=publicationpage:font]{\font[family=Libertinus Serif,size=9pt,language=und]}
\define[command=publicationpage]{\nofolios
\hbox\vfill
\begin{raggedright}
\publicationpage:font
\set[parameter=linespacing.fit-font.extra-space,value=0.8ex plus 0.5pt minus 0.5pt]
\set[parameter=document.parskip,value=1.2ex]
\font[weight=600,style=Bold]{\meta:title}\break
\meta:creators{}
\meta:info{}

\meta:rights{}

\meta:identifiers{}

\meta:contributors{}

\meta:extracredits{}

\meta:manufacturer{}

\meta:versecredits{}

\font[weight=600,style=Bold]{Via Christus Yayınları}\break
\font[size=1.8ex]{
\font[family=Hack]{https://www.viachristus.com}\break
\font[family=Hack]{viachristushizmetleri@gmail.com}
}
\end{raggedright}
\par\break
}
]])
local plain = SILE.require("classes/plain");
local book = SILE.require("classes/book");

book.endPage = function(self)
  book:moveTocNodes()

  if (not SILE.scratch.headers.skipthispage) then
    SILE.settings.pushState()
    SILE.settings.reset()
    if (book:oddPage() and SILE.scratch.headers.right) then
      SILE.typesetNaturally(SILE.getFrame("runningHead"), function()
        SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
        SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
        SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
        SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
        SILE.call("book:right-running-head-font", {}, function()
          SILE.process(SILE.scratch.headers.right)
          SILE.call("hfill")
          SILE.call("book:page-number-font", {}, function()
            SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.folio))
          end)
        end)
        SILE.typesetter:leaveHmode()
        SILE.call("skip", {height="-8pt"})
        SILE.call("fullrule")
      end)
    elseif (not(book:oddPage()) and SILE.scratch.headers.left) then
      SILE.typesetNaturally(SILE.getFrame("runningHead"), function()
        SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
        SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
        SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
        SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
        SILE.call("book:left-running-head-font", {}, function()
          SILE.call("book:page-number-font", {}, function()
            SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.folio))
          end)
          SILE.call("hfill")
          SILE.call("meta:title")
        end)
        SILE.typesetter:leaveHmode()
        SILE.call("skip", {height="-8pt"})
        SILE.call("fullrule")
      end)
    end
    SILE.settings.popState()
  else
    SILE.scratch.headers.skipthispage = false
  end
  return plain.endPage(book)
end

SILE.registerUnit("pw", { relative = true, definition = function (v)
  return v / 100 * SILE.documentState.paperSize[1]
end})
SILE.registerUnit("ph", { relative = true, definition = function (v)
  return v / 100 * SILE.documentState.paperSize[2]
end})

SILE.registerCommand("aki", function()
  SILE.call("penalty", { penalty=-1 })
end)

SILE.registerCommand("left-running-head", function(options, content)
  local closure = SILE.settings.wrap()
  SILE.scratch.headers.left = function () closure(content) end
end, "Text to appear on the top of the left page");

SILE.registerCommand("right-running-head", function(options, content)
  local closure = SILE.settings.wrap()
  SILE.scratch.headers.right = function () closure(content) end
end, "Text to appear on the top of the right page");

local _initml = function (c)
  if not(SILE.scratch.counters[c]) then
    SILE.scratch.counters[c] = { value= {0}, display= {"arabic"} }
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
      this.display[currentLevel] = this.display[currentLevel -1]
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
      local val = SILE.formatCounter({display = "ORDINAL", value = counters.value[level]})
      toc_content[1] = val .. " KISIM: " .. trupper(content[1])
    elseif level == 2 then
      local val = SILE.formatCounter({display = "arabic", value = counters.value[level]})
      toc_content[1] = val .. ". " .. content[1]
    end
    if options.prenumber then
      if SILE.Commands[options.prenumber..":"..lang] then options.prenumber = options.prenumber..":"..lang end
      if SILE.Commands["book:chapter:precounter"] then SILE.call("book:chapter:precounter") end
      SILE.call(options.prenumber)
    end
    SILE.call("show-multilevel-counter", {id="sectioning", display = options.display, minlevel = level, level = level})
    if options.postnumber then
      if SILE.Commands[options.postnumber..":"..lang] then options.postnumber = options.postnumber..":"..lang end
      SILE.call(options.postnumber)
    end
    SILE.call("tocentry", {level = options.level}, toc_content)
  else
    SILE.call("tocentry", {level = options.level}, content)
  end
end)

SILE.registerCommand("chapter", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  SILE.call("set-counter", {id = "footnote", value = 1})
  SILE.scratch.theChapter = content
  SILE.call("center", {}, function()
    SILE.settings.temporarily(function()
      SILE.typesetter:typeset(" ")
      SILE.call("skip", { height="10ph" })
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
    end)
  end)
  SILE.call("left-running-head")
  SILE.Commands["right-running-head"]({}, function()
    SILE.call("book:right-running-head-font", {}, content)
  end)
  SILE.scratch.headers.skipthispage = true
  if (options.numbering == false or options.numbering == "false") then
    SILE.call("medskip")
  end
  SILE.call("medskip")
  --SILE.call("nofoliosthispage")
end, "Begin a new chapter");

SILE.registerCommand("section", function (options, content)
  SILE.typesetter:leaveHmode()
  SILE.call("goodbreak")
  SILE.call("skip", {height="12pt plus 6pt minus 4pt"})
  SILE.call("noindent")
  SILE.settings.temporarily(function()
    SILE.call("book:sectionfont", {}, function()
      SILE.call("uppercase", {}, content)
    end)
  end)
  SILE.call("novbreak")
end, "Begin a new section")

SILE.registerCommand("part", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  SILE.call("set-counter", {id = "footnote", value = 1})
  SILE.call("center", {}, function()
    SILE.call("book:partnumfont", { size="5pw" }, function()
      SILE.call("hbox")
      SILE.call("skip", { height="10ph" })
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
    SILE.Commands["book:partfont"]({ size="4pw" }, content);
    SILE.call("medskip")
    SILE.call("font", { filename="avadanlik/fonts/FeFlow2.otf", size="9pt" }, {"a"})
    SILE.call("bigskip")
  end)
  SILE.scratch.headers.skipthispage = true
end, "Begin a new part");

SILE.registerCommand("open-double-page", function()
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
  -- Backtracking 6pt approximates the \medskip after quotations
  SILE.Commands["skip"]({ height = "-8pt" })
  SILE.call("novbreak")
  SILE.Commands["book:subparagraphfont"]({}, function()
    SILE.call("raggedleft", {}, function()
      SILE.settings.set("document.rskip", SILE.nodefactory.newGlue("20pt"))
      SILE.process(content)
    end)
  end)
  SILE.typesetter:leaveHmode()
  SILE.call("novbreak")
  SILE.call("bigskip")
  SILE.call("novbreak")
end, "Begin a new subparagraph")

local utf8 = require("lua-utf8")
local inputfilter = SILE.require("packages/inputfilter").exports
function trupper (string)
  string = string:gsub("i", "İ")
  return utf8.upper(string)
end
SILE.registerCommand("uppercase", function(options, content)
  SILE.process(inputfilter.transformContent(content, trupper))
end, "Typeset the enclosed text as uppercase")

SILE.require("packages/raiselower")
SILE.require("packages/rebox")
SILE.require("packages/leaders")

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

SILE.formatCounter = function(options)
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
    SILE.scratch.counters[c] = { value= {0}, display= {"arabic"} };
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
    SILE.call("tableofcontents:level"..o.level.."item", {}, function()
      SILE.process({c})
      if o.level == 1 then
        SILE.call("hss")
      elseif o.level == 2 then
        SILE.call("dotfill")
        SILE.typesetter:typeset(o.pageno)
      end
    end)
  end)
end)

SILE.registerCommand("fullrule", function (options, content)
  local height = options.height or "0.2pt"
  SILE.call("hrule", { height = height, width = SILE.typesetter.frame:lineWidth() })
end)

SILE.require("packages/rebox");
local insertions = SILE.require("packages/insertions")
SILE.registerCommand("footnote", function(options, content)
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
  SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.4ex plus 0.1pt minus 0.1pt"))
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(indent))
  local material = SILE.Commands["vbox"]({}, function()
    SILE.Commands["book:footnotefont"]({}, function()
      SILE.call("noindent")
      SILE.typesetter:pushGlue({ width = 0 - SILE.length.parse(indent) })
      SILE.Commands["rebox"]({ width = indent }, function()
        SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.footnote)..".")
      end)
      -- don't justify footnotes
      SILE.call("raggedright", {}, function()
        --inhibit hyphenation in footnotes
        SILE.call("font", { language="und" }, content)
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

SILE.registerCommand("quote", function(options, content)
  local setback = options.setback or "2em"
  SILE.call("par")
  SILE.call("skip", { height="1.1em plus 2pt minus 1pt" })
  SILE.typesetter:typeset(" ")
  SILE.call("par")
  SILE.call("skip", { height="-1em plus 2pt minus 1pt" })
  SILE.settings.pushState()
  SILE.settings.temporarily(function()
    SILE.call("noindent")
    SILE.settings.set("document.rskip", SILE.nodefactory.newGlue(setback))
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(setback))
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
  SILE.call("medskip")
  SILE.call("novbreak")
  SILE.call("noindent")
end, "Typeset quototion blocks")

SILE.registerCommand("excerpt", function()
  SILE.call("font", { size="0.975em" })
  SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.975ex plus 0.05ex minus 0.05ex"))
end)

SILE.registerCommand("verse", function()
  SILE.call("font", {family="Libertinus Serif", weight=400, style="Italic", features="+salt,+ss02,+onum,+liga,+dlig,+clig"})
  SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.8ex plus 0.05ex minus 0.05ex"))
end)

SILE.registerCommand("poetry", function()
  SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("30pt"))
  SILE.settings.set("document.rskip", SILE.nodefactory.hfillGlue)
  SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
  SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
end)

SILE.registerCommand("dedication", function(options, content)
  SILE.call("center", {}, function()
    SILE.call("hbox")
    SILE.call("vfill")
    SILE.call("font", { style="Italic", size="14pt" }, content)
    SILE.call("bigskip")
  end)
end)

SILE.registerCommand("seriespage:series", function(options, content)
  SILE.call("center", {}, function()
    SILE.call("book:chapterfont", {}, function()
      SILE.process(content)
      SILE.call("aki")
      SILE.typesetter:typeset(" Serisi’ndeki Kitaplar")
      SILE.call("book:chapter:post")
    end)
  end)
end)

SILE.registerCommand("seriespage:title", function(options, content)
  SILE.call("raggedright", {}, function()
    SILE.settings.set("current.parindent", SILE.nodefactory.newGlue("-2em"))
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("2em"))
    if not options.author then
      SILE.call("font", { style="Italic", language="und" }, content)
      SILE.call("medskip")
    else
      SILE.call("font", { weight="600", language="und" }, content)
      SILE.typesetter:typeset(" ")
      SILE.call("aki")
      SILE.typesetter:typeset("— ")
      SILE.call("font", { style="Italic", language="und" }, function()
        SILE.typesetter:typeset(options.author)
      end)
      SILE.call("smallskip")
    end
  end)
end)

SILE.require("packages/color")

SILE.registerCommand("criticHighlight", function(options, content)
  SILE.settings.temporarily(function()
    SILE.call("font", { weight=600 })
    SILE.call("color", { color="#0000E6" }, content)
  end)
end)

SILE.registerCommand("criticComment", function(options, content)
  SILE.settings.temporarily(function()
    SILE.call("font", { style="Italic" })
    SILE.call("color", { color="#bdbdbd" }, function()
      SILE.typesetter:typeset(" (")
      SILE.process(content)
      SILE.typesetter:typeset(")")
    end)
  end)
end)

SILE.registerCommand("criticAdd", function(options, content)
  SILE.settings.temporarily(function()
    SILE.call("font", { weight=600 })
    SILE.call("color", { color="#0E7A00" }, content)
  end)
end)

SILE.registerCommand("criticDel", function(options, content)
  SILE.settings.temporarily(function()
    SILE.call("font", { weight=600 })
    SILE.call("color", { color="#E60000" }, content)
  end)
end)

local inputfilter = SILE.require("packages/inputfilter").exports
local discressionaryBreaksFilter = function(content, args, options)
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
      process = function(separator) currentText = currentText..separator end
    end
  end
  process = function(separator)
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
addDiscressionaryBreaks = function(options, content)
  if not options.breakat then options.breakat = "[:]" end
  if not options.breakwith then options.breakwith = "aki" end
  if not options.breakopts then options.breakopts = {} end
  if not options.breakall then options.breakall = false end
  if not options.breakbefore then options.breakbefore = false end
  return inputfilter.transformContent(content, discressionaryBreaksFilter, options)
end

SILE.registerCommand("addDiscressionaryBreaks", function(options, content)
  SILE.process(addDiscressionaryBreaks(options, content))
end, "Try to find good breakpoints based on punctuation")
