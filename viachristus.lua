SILE.doTexlike([[%
\define[command=book:part:pre]{Part }%
\define[command=book:part:post]{\par}%
\define[command=book:subparagraph:post]{ }%
]])

SILE.registerCommand("book:sectioning", function (options, content)
  SILE.call("tocentry", {level = options.level}, content)
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
  SILE.call("book:chapterfont", {}, function()  
    SILE.call("book:sectioning", {
      numbering = options.numbering, 
      level = 1,
      prenumber = "book:chapter:pre",
      postnumber = "book:chapter:post"
    }, content)
  end)
  SILE.scratch.theChapter = content
  SILE.Commands["book:chapterfont"]({}, content);
  SILE.Commands["left-running-head"]({}, content)
  SILE.call("bigskip")
  SILE.call("nofoliosthispage")
end, "Begin a new chapter");


SILE.registerCommand("section", function (options, content)
  SILE.typesetter:leaveHmode()
  SILE.call("goodbreak")  
  SILE.call("bigskip")
  SILE.call("noindent")
  SILE.Commands["book:sectionfont"]({}, function()
    SILE.call("book:sectioning", {
      numbering = options.numbering, 
      level = 2,
      postnumber = "book:section:post"
    }, content)
	SILE.process(content)
	--SILE.call("uppercase", {}, content)
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
    SILE.Commands["font"]({weight=800, size="10pt"}, content)
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
  SILE.call("goodbreak")
  SILE.call("noindent")
  SILE.call("medskip")
  SILE.Commands["book:subparagraphfont"]({}, function()
    SILE.call("book:sectioning", {
          numbering = options.numbering,
          level = 3,
          postnumber = "book:subparagraph:post"
        }, content)
    SILE.process(content)
  end)
  SILE.typesetter:leaveHmode()
  SILE.call("novbreak")
  SILE.call("medskip")
  SILE.call("novbreak")
end, "Begin a new subparagraph")
