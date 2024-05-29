local base = require("packages.base")

local package = pl.class(base)
package._name = "cabook-block-styles"

-- luacheck: ignore loadstring
local loadstring = loadstring or load

function package:registerCommands ()
   self:registerCommand("foliostyle", function (_, content)
      SILE.call("center", {}, function ()
         SILE.call("cabook:font:folio", {}, content)
      end)
   end)

   self:registerCommand("titlepage", function (_, _)
      if not SILE.Commands["meta:title"] then
         return
      end
      SILE.call("nofolios")
      if not CASILE.isScreenLayout() then
         SILE.call("open-spread")
      end
      SILE.call("center", {}, function ()
         SILE.call("topfill")
         SILE.call("font", { size = "3%pw" }, function ()
            SILE.call("cabook:font:title", {}, function ()
               SILE.call("wraptitle", {}, { CASILE.metadata.title })
            end)
         end)
         SILE.call("skip", { height = "9%ph" })
         if CASILE.metadata.subtitle then
            SILE.call("font", { size = "3%pw" }, function ()
               SILE.call("cabook:font:subtitle", {}, function ()
                  SILE.call("wrapsubtitle", {}, { CASILE.metadata.subtitle })
               end)
            end)
         end
         if SILE.Commands["meta:author"] then
            SILE.call("vfill")
            SILE.call("font", { size = "3%pw" }, function ()
               SILE.call("cabook:font:author", { weight = 300 }, function ()
                  SILE.call("meta:author")
               end)
            end)
            SILE.call("vfill")
            SILE.call("vfill")
         end
      end)
      SILE.call("par")
      SILE.call("break")
   end)

   self:registerCommand("halftitlepage", function (_, _)
      if CASILE.isScreenLayout() then
         return
      end
      if not SILE.Commands["meta:title"] then
         return
      end
      SILE.call("nofolios")
      SILE.call("center", {}, function ()
         SILE.call("hbox")
         SILE.call("skip", { height = "20%ph" })
         SILE.call("font", { size = "1.5%pw" }, function ()
            SILE.call("cabook:font:title", {}, function ()
               SILE.call("wraptitle", {}, { CASILE.metadata.title })
            end)
         end)
      end)
   end)

   self:registerCommand("tableofcontents", function (_, _)
      local f, _ = io.open(SILE.masterFilename .. ".toc")
      if not f then
         return
      end
      local doc = f:read("*all")
      local toc = assert(loadstring(doc))()
      if #toc < 2 then
         return
      end -- Skip the TOC if there is only one top level entry
      SILE.call("tableofcontents:header")
      for i = 1, #toc do
         local item = toc[i]
         SILE.call("tableofcontents:item", {
            level = item.level,
            pageno = item.pageno,
            number = item.number,
         }, item.label)
      end
      SILE.call("tableofcontents:footer")
   end)

   self:registerCommand("cabook:chapter:before", function (options, _)
      SILE.call("open-spread")
      SILE.call("noindent")
      -- If Sectioning doesn't output numbering, the chapter starts too high on the page
      if options.numbering == false or options.numbering == "false" then
         SILE.call("skip", { height = "10ex" })
      end
      SILE.typesetter:typeset(" ")
      SILE.call("skip", { height = "10%ph" })
   end)

   self:registerCommand("cabook:chapter:after", function (options, _)
      SILE.call("bigskip")
      SILE.call("noindent")
      SILE.call("fullrule")
      if options.numbering == false or options.numbering == "false" then
         SILE.call("skip", { height = "10pt" })
      end
      SILE.call("skip", { height = "8pt" })
      --SILE.call("nofoliosthispage")
   end)

   self:registerCommand("chapter", function (options, content)
      options.display = options.display or "STRING"
      options.numbering = SU.boolean(options.numbering, true)
      SILE.call("set-counter", { id = "footnote", value = 1 })
      SILE.settings:temporarily(function ()
         SILE.call("center", {}, function ()
            SILE.call("cabook:chapter:before", options, content)
            SILE.call("cabook:font:chapterno", {}, function ()
               SILE.call("book:sectioning", {
                  numbering = options.numbering,
                  level = 2,
                  reset = false,
                  display = options.display,
                  prenumber = "cabook:chapter:pre",
                  postnumber = "cabook:chapter:post",
               }, content)
            end)
            SILE.call("cabook:font:chaptertitle", {}, content)
         end)
      end)
      SILE.call("left-running-head")
      SILE.call("right-running-head", {}, content)
      SILE.scratch.headers.skipthispage = true
      SILE.call("cabook:chapter:after", options, content)
   end, "Begin a new chapter")

   self:registerCommand("section", function (_, content)
      SILE.call("goodbreak")
      SILE.call("ifnotattop", {}, function ()
         SILE.call("skip", { height = "12pt plus 6pt minus 4pt" })
      end)
      SILE.settings:temporarily(function ()
         SILE.call("noindent")
         SILE.call("raggedright", {}, function ()
            SILE.call("cabook:font:sectiontitle", {}, function ()
               SILE.call("uppercase", {}, content)
            end)
         end)
      end)
      SILE.call("novbreak")
   end, "Begin a new section")

   self:registerCommand("subsection", function (_, content)
      SILE.call("goodbreak")
      SILE.call("ifnotattop", {}, function ()
         SILE.call("skip", { height = "12pt plus 6pt minus 4pt" })
      end)
      SILE.settings:temporarily(function ()
         SILE.call("noindent")
         SILE.call("raggedright", {}, function ()
            SILE.call("cabook:font:subsectiontitle", {}, function ()
               SILE.call("uppercase", {}, content)
            end)
         end)
      end)
      SILE.call("novbreak")
   end, "Begin a new section")

   self:registerCommand("subsubsection", function (_, content)
      SILE.call("goodbreak")
      SILE.call("ifnotattop", {}, function ()
         SILE.call("skip", { height = "12pt plus 6pt minus 4pt" })
      end)
      SILE.settings:temporarily(function ()
         SILE.call("noindent")
         SILE.call("raggedright", {}, function ()
            SILE.call("cabook:font:subsubsectiontitle", {}, function ()
               SILE.call("uppercase", {}, content)
            end)
         end)
      end)
      SILE.call("novbreak")
   end, "Begin a new section")

   self:registerCommand("part", function (options, content)
      SILE.call("open-spread")
      SILE.call("noindent")
      SILE.call("set-counter", { id = "footnote", value = 1 })
      SILE.call("center", {}, function ()
         SILE.call("cabook:font:partno", {}, function ()
            SILE.call("hbox")
            SILE.call("skip", { height = "10%ph" })
            SILE.call("book:sectioning", {
               numbering = options.numbering,
               level = 1,
               reset = false,
               display = "ORDINAL",
               prenumber = "cabook:part:pre",
               postnumber = "cabook:part:post",
            }, content)
         end)
         SILE.call("medskip")
         SILE.call("cabook:font:parttitle", {}, content)
         SILE.call("medskip")
         SILE.call("font", { family = "IM FELL FLOWERS 2", size = "9pt" }, { "a" })

         SILE.call("bigskip")
      end)
      SILE.scratch.headers.skipthispage = true
   end, "Begin a new part")

   self:registerCommand("subparagraph", function (_, content)
      SILE.typesetter:leaveHmode()
      SILE.call("novbreak")
      -- Backtracking to approximate the skip after quotations
      SILE.call("skip", { height = "-8pt" })
      SILE.call("novbreak")
      SILE.call("cabook:font:subparagraph", {}, function ()
         SILE.call("raggedleft", {}, function ()
            SILE.settings:set("document.rskip", SILE.nodefactory.glue("20pt"))
            SILE.process(content)
         end)
      end)
      SILE.typesetter:leaveHmode()
      SILE.call("novbreak")
      SILE.call("skip", { height = "3en" })
      SILE.call("novbreak")
      SILE.scratch.last_was_ref = true
   end, "Begin a new subparagraph")
end

return package
