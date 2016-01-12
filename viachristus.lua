SILE.doTexlike([[
\language[main=tr]
\script[src=packages/rules]
\script[src=packages/image]
\script[src=packages/rebox]
%\script[src=packages/frametricks]
%\showframe[id=all]
\define[command=book:monofont]{\font[family=Hack]{\process}}
\define[command=book:sansfont]{\font[family=Montserrat]{\process}}
\define[command=book:seriffont]{\font[family=Crimson,style=Roman]{\process}}
\define[command=book:partnumfont]{\book:sansfont{\font[weight=600,style=Bold,size=20pt]{\process}}}
\define[command=book:partfont]{\book:sansfont{\font[weight=600,style=Bold,size=16pt]{\process}}}
\define[command=book:subparagraphfont]{\font[family=Libertine Serif,style=Regular,weight=400,size=12pt,features=+smcp]{\process}}
\define[command=book:footnotefont]{\font[family=Libertine Serif,style=Regular,weight=400,size=8.5pt]{\process}}
\footnote:separator{\rebox[width=6em,height=5pt]{\hrule[width=5em,height=0.2pt]}\smallskip}
\define[command=book:chapterfont]{\book:sansfont{\font[weight=600,style=Bold,size=10pt]{\process}}}
\define[command=book:sectionfont]{\book:sansfont{\font[weight=600,style=Bold,size=8.5pt]{\process}}}
\define[command=verbatim:font]{\book:monofont{\font[size=10pt]{\process}}}
\define[command=book:chapter:pre:tr]{\font[family=Libertine Serif Display,size=11pt,weight=400,style=Regular]BÖLÜM }
\define[command=book:chapter:post]{\font[filename=avadanlik/fonts/FeFlow2.otf,size=9pt]{\skip[height=-3pt]a\medskip}}
\define[command=book:part:pre]{}%
\define[command=book:part:post]{ KISIM\par}%
\define[command=book:subparagraph:post]{ }%
\define[command=book:left-running-head-font]{\font[family=Libertine Serif,style=Regular,size=12pt]}%
\define[command=book:right-running-head-font]{\font[family=Libertine Serif,style=Italic,size=12pt]}%
\define[command=book:page-number-font]{\font[family=Libertine Serif,style=Regular,size=13pt]{\process}}%
\define[command=tableofcontents:headerfont]{\book:partfont{\process}}%
\define[command=tableofcontents:header]{\center{\hbox\skip[height=12ex]\tableofcontents:headerfont{\tableofcontents:title}}\bigskip\fullrule\bigskip}%
\define[command=tableofcontents:level1item]{\bigskip\noindent\book:sansfont{\font[size=10pt,weight=600,style=Bold]{\process}\break}}%
\define[command=tableofcontents:level2item]{\skip[height=4pt]\noindent\glue[width=2ex]\font[size=11pt]{\process}\break\skip[height=0]}%
\define[command=wraptitle]{\meta:title}
\define[command=halftitlepage]{\nofolios\center{\hbox\skip[height=8em]\book:chapterfont{\font[size=16pt]{\wraptitle}}\bigskip\book:sectionfont{\meta:subtitle}}}
\define[command=titlepage]{\open-double-page\center{\hbox\skip[height=8em]\book:partnumfont{\font[size=26pt]{\wraptitle}}\skip[height=3em]\book:chapterfont{\meta:subtitle}\bigskip\book:partfont{\font[weight=300,style=Light]\meta:author}\vfill{}\img[src=avadanlik/vc_logo_renksiz.pdf,width=36mm]}\eject}
\font[family=Crimson,style=Roman,size=11.5pt]
\script[src=packages/linespacing]
\set[parameter=linespacing.method,value=fit-font]
\set[parameter=linespacing.fit-font.extra-space,value=1.20ex minus 0.6pt]
\set[parameter=linebreak.hyphenPenalty,value=1000]
\define[command=publicationpage]{\nofolios
\hbox\vfill
\begin{raggedright}
\font[family=Libertine Serif,style=Regular,size=9pt,language=xx]
\set[parameter=linespacing.fit-font.extra-space,value=0.8ex minus 0.6pt]
\set[parameter=document.parskip,value=1.2ex]
\font[weight=600,style=Bold]{\meta:title}\break
\meta:creators{}
\meta:info{}

\meta:rights{}

\meta:identifiers{}

\meta:date{}

\meta:contributors{}

\meta:extracredits{}

\meta:manufacturer{}

\meta:versecredits{}

\font[weight=600,style=Bold]{Via Christus Yayınları}\break
\book:monofont{\font[size=7pt]https://www.viachristus.com}\break
\book:monofont{\font[size=7pt]viachristushizmetleri@gmail.com}
\end{raggedright}
\eject
}
]])
local plain = SILE.require("classes/plain");
local book = SILE.require("classes/book");
book:loadPackage("masters")
book:defineMaster({ id = "right", firstContentFrame = "content", frames = {
  content = {left = "22.5mm", right = "100%-15mm", top = "20mm", bottom = "top(footnotes)" },
  runningHead = {left = "left(content)", right = "right(content)", top = "top(content)-8mm", bottom = "top(content)-2mm" },
  footnotes = { left="left(content)", right = "right(content)", height = "0", bottom="100%-15mm"}
}})
book:defineMaster({ id = "left", firstContentFrame = "content", frames = {}})
book:loadPackage("twoside", { oddPageMaster = "right", evenPageMaster = "left" });
book:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", {id="right"})

book.endPage = function(self)
  book:moveTocNodes()

  if (not SILE.scratch.headers.skipthispage) then
    if (book:oddPage() and SILE.scratch.headers.right) then
      SILE.typesetNaturally(SILE.getFrame("runningHead"), function()
        SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
        SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
        SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
        SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
        SILE.call("book:right-running-head-font")
        SILE.process(SILE.scratch.headers.right)
        SILE.call("hfill")
        SILE.call("book:page-number-font", {}, function()
          SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.folio))
        end)
        SILE.call("skip", {height="-8pt"})
        SILE.call("fullrule")
        SILE.call("par")
      end)
      elseif (not(book:oddPage()) and SILE.scratch.headers.left) then
        SILE.typesetNaturally(SILE.getFrame("runningHead"), function()
          SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
          SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
          SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
          SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
          SILE.call("book:left-running-head-font")
          SILE.call("book:page-number-font", {}, function()
            SILE.typesetter:typeset(SILE.formatCounter(SILE.scratch.counters.folio))
          end)
          SILE.call("hfill")
          SILE.call("meta:title")
          SILE.call("skip", {height="-8pt"})
          SILE.call("fullrule")
          SILE.call("par")
        end)
      end
    else
      SILE.scratch.headers.skipthispage = false
    end
  return plain.endPage(book);
end;

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
    SILE.scratch.counters[c] = { value= {0}, display= {"arabic"} };
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

SILE.registerCommand("chapternumber", function (o,c)
  SILE.call("typeset:chapternumber", o, c)
  SILE.call("save-chapter-number", o, c) 
end)

SILE.registerCommand("chapter", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  SILE.call("set-counter", {id = "footnote", value = 1})  
  SILE.scratch.theChapter = content
  SILE.call("center", {}, function()
    SILE.settings.temporarily(function()
      SILE.typesetter:typeset(" ")
      SILE.call("skip", {height="2ex"})
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
        SILE.call("skip", { height = "8ex" })
      end
      SILE.call("book:chapterfont", {}, content)
      SILE.call("bigskip")
      SILE.call("fullrule")
    end)
  end)
  SILE.call("left-running-head")
  SILE.Commands["right-running-head"]({}, function()
    SILE.settings.temporarily(function()
      SILE.call("book:right-running-head-font")
      SILE.process(content)
    end)
  end)
  SILE.scratch.headers.skipthispage = true
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
      --SILE.process(content)
    end)
  end)
  SILE.call("novbreak")
end, "Begin a new section")

SILE.registerCommand("part", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  SILE.call("set-counter", {id = "footnote", value = 1})
  SILE.call("center", {}, function()
    SILE.call("book:partnumfont", {}, function()
      SILE.typesetter:typeset(" ")
      SILE.call("skip", {height="6ex"})
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
    SILE.Commands["book:partfont"]({}, content);
    SILE.call("medskip")
    SILE.call("font", { filename = "avadanlik/fonts/FeFlow2.otf", size = "9pt"}, {"a"})
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
  SILE.Commands["skip"]({ height = "-6pt" })
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

SILE.registerCommand("quote", function(options, content)
  local setback = options.setback or "20pt"
  SILE.call("medskip")
  SILE.settings.pushState()
  SILE.settings.temporarily(function()
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
end, "Typeset quototion blocks")

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
  SILE.settings.set("linespacing.fit-font.extra-space", "0.4ex minus 0.1pt")
  SILE.settings.set("linebreak.emergencyStretch", SILE.length.parse("3em"))
  SILE.settings.set("linebreak.hyphenPenalty", 1000)
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
        SILE.Commands["font"]({language = "xx"}, function()
          SILE.process(content)
        end)
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
\define[command=langxx]{\font[language=xx,style=Italic]{\process}}
\define[command=langla]{\font[language=la,style=Italic]{\process}}
\define[command=langen]{\font[language=en,style=Italic]{\process}}
]])

SILE.registerCommand("verse", function()
    SILE.call("font", {family="Libertine Serif", weight=400, size="11.5pt", style="Italic", features="+salt,+ss02,+onum,+liga,+dlig,+clig"})
    SILE.settings.set("linespacing.fit-font.extra-space", "0.9ex minus 0.6pt")
end)

SILE.registerCommand("poetry", function()
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("30pt"))
    SILE.settings.set("document.rskip", SILE.nodefactory.hfillGlue)
    SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
    SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.spaceskip", SILE.length.new({ length = SILE.shaper:measureDim(" ") }))
end)
