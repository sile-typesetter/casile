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
    if publisher == "viachristus" then
      SILE.call("vfill")
      SILE.call("img", { src = "avadanlik/vc_logo_renksiz.pdf", width = "25%pw" })
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
  if #toc < 2 then return end -- Skip the TOC if there is only one top level entry
  SILE.call("tableofcontents:header")
  for i = 1, #toc do
    local item = toc[i]
    SILE.call("tableofcontents:item", { level = item.level, pageno = item.pageno }, item.label)
  end
  SILE.call("tableofcontents:footer")
end)
