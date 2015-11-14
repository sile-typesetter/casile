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
  end)
  SILE.call("novbreak")
end, "Begin a new section")

