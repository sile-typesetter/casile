SILE.registerCommand("book:sectioning", function (options, content)
  SILE.call("tocentry", {level = options.level}, content)
end)

SILE.registerCommand("chapternumber", function (o,c)
  SILE.call("typeset:chapternumber", o, c)
  SILE.call("save-chapter-number", o, c) 
end)
SILE.registerCommand("versenumber", function (o,c)
  SILE.call("indent")
  SILE.call("typeset:versenumber", o, c)
  SILE.call("save-verse-number", o, c)
  SILE.call("left-running-head", {}, function ()
    SILE.settings.temporarily(function()
      SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
      SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)
      SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
      SILE.call("font", {size="10pt", family="Gentium"}, function ()
        SILE.call("first-reference")
        SILE.call("hfill")
        SILE.call("font", {style="italic"}, SILE.scratch.theChapter)
      end)
      SILE.typesetter:leaveHmode()
    end)
  end)
  SILE.call("right-running-head", {}, function ()
    SILE.settings.temporarily(function()
      SILE.settings.set("document.lskip", SILE.nodefactory.zeroGlue)
      SILE.settings.set("document.rskip", SILE.nodefactory.zeroGlue)      
      SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
      SILE.call("font", {size="10pt", family="Gentium"}, function ()
        SILE.call("font", {style="italic"}, SILE.scratch.theChapter)
        SILE.call("hfill")
        SILE.call("last-reference")
      end)
      SILE.typesetter:leaveHmode()
    end)
  end)  
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
  SILE.scratch.theSection = content  
  if not SILE.scratch.counters.folio.off then
    SILE.Commands["right-running-head"]({}, function()
      SILE.call("rightalign", {}, function ()
        SILE.settings.temporarily(function()
          SILE.settings.set("font.style", "italic")
          SILE.call("show-multilevel-counter", {id="sectioning", level =2})
          SILE.typesetter:typeset(" ")
          SILE.process(content)
        end)
      end)
    end);
  end
  SILE.call("novbreak")
  SILE.call("bigskip")
  SILE.call("novbreak")
end, "Begin a new section")
