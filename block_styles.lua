SILE.registerCommand("titlepage", function (options, content)
  if not SILE.Commands["meta:title"] then return end
  SILE.call("nofolios")
  SILE.call("open-double-page")
  SILE.call("center", {}, function ()
    SILE.call("topfill")
    SILE.call("cabook:font:title", { size = "7%pw" }, function ()
      SILE.call("wraptitle", {}, { CASILE.metadata.title } )
    end)
    SILE.call("skip", { height = "9%ph" })
    if CASILE.metadata.subtitle then
      SILE.call("cabook:font:subtitle", { size = "4%pw" }, function ()
        SILE.call("wrapsubtitle", {}, { CASILE.metadata.subtitle })
      end)
    end
    if SILE.Commands["meta:author"] then
      SILE.call("vfill")
      SILE.call("cabook:font:author", { size = "4%pw", weight = 300 }, function ()
        SILE.call("meta:author")
      end)
      SILE.call("vfill")
      SILE.call("vfill")
    end
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
    SILE.call("cabook:font:title", { size = "4.5%pw" }, function ()
      SILE.call("wraptitle", {}, { CASILE.metadata.title })
    end)
  end)
end)

SILE.registerCommand("tableofcontents", function (options, content)
  local f,err = io.open(SILE.masterFilename .. '.toc')
  if not f then return end
  local doc = f:read("*all")
  local toc = assert(loadstring(doc))()
  if #toc < 2 then return end -- Skip the TOC if there is only one top level entry
  SILE.call("tableofcontents:header")
  for i = 1, #toc do
    local item = toc[i]
    SILE.call("tableofcontents:item", { level = item.level, pageno = item.pageno }, item.label)
  end
  SILE.call("tableofcontents:footer")
end)

SILE.registerCommand("cabook:chapter:before", function (options, content)
  SILE.call("open-double-page")
  SILE.call("noindent")
  -- If Sectioning doesn't output numbering, the chapter starts too high on the page
  if (options.numbering == false or options.numbering == "false") then
    SILE.call("skip", { height = "10ex" })
  end
end)

SILE.registerCommand("cabook:chapter:after", function (options, content)
  SILE.call("bigskip")
  SILE.call("fullrule")
  if (options.numbering == false or options.numbering == "false") then
    SILE.call("skip", { height = "10pt" })
  end
  SILE.call("skip", { height = "8pt" })
  --SILE.call("nofoliosthispage")
end)

SILE.registerCommand("chapter", function (options, content)
  options.display = options.display or "STRING"
  options.numbering = options.numbering or true
  SILE.call("cabook:chapter:before", options, content)
  SILE.call("set-counter", { id = "footnote", value = 1 })
  SILE.call("center", {}, function ()
    SILE.settings.temporarily(function ()
      SILE.typesetter:typeset(" ")
      SILE.call("skip", { height = "10%ph" })
      SILE.call("book:sectioning", {
        numbering = options.numbering,
        level = 2,
        reset = false,
        display = options.display,
        prenumber = "book:chapter:pre",
        postnumber = "book:chapter:post"
      }, content)
      SILE.call("cabook:font:chaptertitle", {}, content)
    end)
  end)
  SILE.call("left-running-head")
  SILE.call("right-running-head", {}, content)
  SILE.scratch.headers.skipthispage = true
  SILE.call("cabook:chapter:after", options, content)
end, "Begin a new chapter");

SILE.registerCommand("section", function (options, content)
  SILE.call("goodbreak")
  SILE.call("ifnotattop", {}, function ()
    SILE.call("skip", { height = "12pt plus 6pt minus 4pt" })
  end)
  SILE.settings.temporarily(function ()
    SILE.call("noindent")
    SILE.call("cabook:font:sectiontitle", {}, function ()
      SILE.call("uppercase", {}, content)
    end)
  end)
  SILE.call("novbreak")
end, "Begin a new section")

SILE.registerCommand("subsection", function (options, content)
  SILE.call("goodbreak")
  SILE.call("ifnotattop", {}, function ()
    SILE.call("skip", { height = "12pt plus 6pt minus 4pt" })
  end)
  SILE.settings.temporarily(function ()
    SILE.call("noindent")
    SILE.call("cabook:font:sectiontitle", { size = "0.9em"}, function ()
      SILE.call("uppercase", {}, content)
    end)
  end)
  SILE.call("novbreak")
end, "Begin a new section")

SILE.registerCommand("subsubsection", function (options, content)
  SILE.call("goodbreak")
  SILE.call("ifnotattop", {}, function ()
    SILE.call("skip", { height = "12pt plus 6pt minus 4pt" })
  end)
  SILE.settings.temporarily(function ()
    SILE.call("noindent")
    SILE.call("cabook:font:sectiontitle", { size = "0.8em"}, function ()
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
    SILE.call("cabook:font:partno", { size = "5%pw" }, function ()
      SILE.call("hbox")
      SILE.call("skip", { height = "10%ph" })
      SILE.call("book:sectioning", {
        numbering = options.numbering,
        level = 1,
        reset = false,
        display = "ORDINAL",
        prenumber = "cabook:part:pre",
        postnumber = "cabook:part:post"
      }, content)
    end)
    SILE.call("medskip")
    SILE.Commands["cabook:font:parttitle"]({ size = "4%pw" }, content);
    SILE.call("medskip")
    SILE.call("font", { filename = CASILE.casiledir .. "/fonts/FeFlow2.otf", size = "9pt" }, { "a" })
    SILE.call("bigskip")
  end)
  SILE.scratch.headers.skipthispage = true
end, "Begin a new part");

SILE.registerCommand("subparagraph", function (options, content)
  SILE.typesetter:leaveHmode()
  SILE.call("novbreak")
  -- Backtracking to approximate the skip after quotations
  SILE.call("skip", { height = "-8pt" })
  SILE.call("novbreak")
  SILE.Commands["cabook:font:subparagraph"]({}, function ()
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
