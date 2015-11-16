SILE.doTexlike([[%
\define[command=book:part:pre]{Kısım }%
\define[command=book:part:post]{\par}%
\define[command=book:subparagraph:post]{ }%
]])

SILE.registerCommand("book:sectioning", function (options, content)
  local level = SU.required(options, "level", "book:sectioning")
  SILE.call("increment-multilevel-counter", {id = "sectioning", level = options.level})
  local lang = SILE.settings.get("document.language")
  if level >= 2 then
	  return
  end
  SILE.call("tocentry", {level = options.level}, content)
  if options.numbering == nil or options.numbering == "yes" then
    if options.prenumber then
      if SILE.Commands[options.prenumber..":"..lang] then options.prenumber = options.prenumber..":"..lang end
	  if SILE.Commands["book:chapter:precounter"] then SILE.call("book:chapter:precounter") end
      SILE.call(options.prenumber)
    end
    SILE.call("show-multilevel-counter", {id="sectioning"})
    if options.postnumber then
      if SILE.Commands[options.postnumber..":"..lang] then options.postnumber = options.postnumber..":"..lang end
      SILE.call(options.postnumber)
    end
  end
end)

SILE.registerCommand("chapternumber", function (o,c)
  SILE.call("typeset:chapternumber", o, c)
  SILE.call("save-chapter-number", o, c) 
end)

SILE.registerCommand("chapter", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  SILE.scratch.headers.right = nil
  SILE.call("set-counter", {id = "footnote", value = 1})  
  SILE.scratch.theChapter = content
  SILE.call("center", {}, function()
    SILE.settings.temporarily(function()
      SILE.call("book:sectioning", {
        numbering = options.numbering, 
        level = 1,
        prenumber = "book:chapter:pre",
        postnumber = "book:chapter:post"
      }, content)
      SILE.call("book:chapterfont", {}, content)
      SILE.call("bigskip")
      SILE.call("hrule", { height = ".5pt", width = SILE.typesetter.frame:lineWidth() })
    end)
  end)
  SILE.Commands["left-running-head"]({}, content)
  SILE.call("bigskip")
  SILE.call("nofoliosthispage")
end, "Begin a new chapter");

SILE.registerCommand("section", function (options, content)
  SILE.typesetter:leaveHmode()
  SILE.call("goodbreak")  
  SILE.call("bigskip")
  SILE.call("noindent")
  SILE.settings.temporarily(function()
    SILE.call("book:sectionfont", {}, function()
      SILE.call("book:sectioning", {
        numbering = options.numbering, 
        level = 2,
        postnumber = "book:section:post"
      }, content)
      SILE.call("uppercase", {}, content)
      --SILE.process(content)
    end)
  end)
  SILE.call("novbreak")
end, "Begin a new section")

SILE.registerCommand("book:partfont", function (options, content)
  SILE.settings.temporarily(function()
    SILE.Commands["font"]({weight=800, size="36pt"}, content)
  end)
end)
SILE.registerCommand("book:subparagraphfont", function (options, content)
  SILE.settings.temporarily(function()
    SILE.Commands["font"]({family="Libertine Serif", features="+smcp", weight=400, size="12pt"}, content)
  end)
end)

SILE.registerCommand("part", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  SILE.scratch.headers.right = nil
  SILE.call("set-counter", {id = "footnote", value = 1})
  SILE.call("book:partfont", {}, function()
    SILE.call("book:sectioning", {
      numbering = options.numbering,
      level = 1,
      prenumber = "book:part:pre",
      postnumber = "book:part:post"
    }, content)
  end)
  SILE.Commands["book:partfont"]({}, content);
  SILE.Commands["left-running-head"]({}, function()
    SILE.settings.temporarily(function()
      SILE.call("book:left-running-head-font")
      SILE.process(content)
    end)
  end)
  SILE.call("bigskip")
  SILE.call("nofoliosthispage")
end, "Begin a new part");

SILE.registerCommand("subparagraph", function (options, content)
  SILE.typesetter:leaveHmode()
  SILE.call("novbreak")
  SILE.call("smallskip")
  SILE.call("novbreak")
  SILE.Commands["book:subparagraphfont"]({}, function()
    SILE.call("raggedleft", {}, function()
      SILE.settings.set("document.rskip", SILE.nodefactory.newGlue("20pt"))
      SILE.call("book:sectioning", {
        numbering = options.numbering,
        level = 3,
        postnumber = "book:subparagraph:post"
      }, content)
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
SILE.registerCommand("uppercase", function(options, content)
  content[1] = content[1]:gsub("i", "İ")
  SILE.process(inputfilter.transformContent(content, utf8.upper))
end, "Typeset the enclosed text as uppercase")

SILE.require("packages/color")
SILE.require("packages/raiselower")
SILE.require("packages/rebox")
SILE.registerCommand("pullquote:font", function(options, content)
end, "The font chosen for the pullquote environment")
SILE.registerCommand("pullquote:author-font", function(options, content)
  SILE.settings.set("font.style", "italic")
end, "The font style with which to typeset the author attribution.")
SILE.registerCommand("pullquote:mark-font", function(options, content)
  SILE.settings.set("font.family", "Libertine Serif")
end, "The font from which to pull the quotation marks.")

SILE.registerCommand("quote", function(options, content)
  local author = options.author or nil
  local setback = options.setback or "20pt"
  local color = options.color or "#999999"
  SILE.settings.temporarily(function()
    SILE.settings.set("document.rskip", SILE.nodefactory.newGlue(setback))
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(setback))

    SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
    SILE.call("pullquote:font")
    SILE.process(content)
    SILE.typesetter:pushGlue(SILE.nodefactory.hfillGlue)
    if author then
      SILE.settings.temporarily(function()
        SILE.typesetter:leaveHmode()
        SILE.call("pullquote:author-font")
        SILE.call("raggedleft", {}, function ()
          SILE.typesetter:typeset("— " .. author)
        end)
      end)
    else
      SILE.call("par")
    end
  end)
end, "Typeset verse blocks")
