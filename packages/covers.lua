local base = require("packages.base")

local package = pl.class(base)
package._name = "covers"

local color = "#FFFFFF"

function package:_init ()
  base._init(self)
  self:loadPackage("markdown")
end

function package:registerCommands ()

  self:registerCommand("frontcover", function (_, _)
    SILE.call("color", { color = color }, function ()
      SILE.call("center", {}, function ()
        SILE.call("topfill")
        SILE.call("cabook:font:title", { size = "8%fmed" }, function ()
          SILE.call("wraptitle", {}, { CASILE.metadata.title })
        end)
        SILE.call("skip", { height = "7%pmin" })
        SILE.call("cabook:font:subtitle", { size = "5%fmed" }, function ()
          SILE.call("wrapsubtitle", {}, { CASILE.metadata.subtitle })
        end)
        SILE.call("vfill")
        SILE.call("vfill")
        if CASILE.metadata.creator then
          SILE.call("cabook:font:author", { size = "6%fmed", weight = 300 }, { CASILE.metadata.creator[1].text })
        end
      end)
      SILE.call("par")
      SILE.call("vfill")
      SILE.call("framebreak")
    end)
  end)

  self:registerCommand("backcover", function (_, _)
    SILE.call("noindent")
    SILE.call("color", { color = color }, function ()
    SILE.typesetter:leaveHmode()
      SILE.settings:set("linebreak.emergencyStretch", SILE.length("2spc"))
      SILE.settings:set("document.lskip", "7%ph")
      SILE.settings:set("document.rskip", "7%ph")
      SILE.call("skip", { height = "7%ph" })
      SILE.settings:temporarily(function ()
        SILE.call("font", { size = "5.2%fw", weight = "600" })
        SILE.settings:set("linespacing.method", "fit-font")
        SILE.settings:set("linespacing.fit-font.extra-space", SILE.length("0.6ex"))
        CASILE.dropcapNextLetter()
        SILE.processMarkdown(SU.contentToString(CASILE.metadata.abstract or ""))
        SILE.call("par")
        if CASILE.metadata.creator then
          SILE.call("raggedleft", {}, function ()
            SILE.call("em", {}, { CASILE.metadata.creator[1].text })
          end)
        end
      end)
      SILE.call("skip", { height = "8%pmin" })
      SILE.call("par")
      SILE.settings:temporarily(function ()
        SILE.settings:set("linespacing.method", "fit-font")
        SILE.settings:set("linespacing.fit-font.extra-space", SILE.length("0.32ex"))
        SILE.call("cabook:font:sans", { size = "3.4%fw", weight = 600 })
        SILE.settings:set("document.lskip", SILE.nodefactory.glue("82pt"))
        if CASILE.metadata.creator then
          SILE.process({ CASILE.metadata.creator[1].about })
        end
        SILE.call("par")
      end)
      SILE.call("par")
      SILE.call("vfill")
      SILE.call("framebreak")
    end)
  end)

  self:registerCommand("spine", function (_, _)
    SILE.call("noindent")
    SILE.call("color", { color = color }, function ()
      SILE.call("topfill")
      SILE.settings:set("current.parindent", 0)
      SILE.settings:set("document.lskip", "5%ph")
      SILE.settings:set("document.rskip", "10%ph")
      SILE.call("raise", { height = ".18bs" }, function() -- Balance visual center of assenders
        SILE.call("cabook:font:title", { size = "80%fh" }, { CASILE.metadata.title })
        SILE.call("hfill")
        if CASILE.metadata.creator then
          SILE.call("cabook:font:author", { size = "50%fh" },  { CASILE.metadata.creator[1].text })
        end
      end)
      SILE.call("par")
    end)
    SILE.call("framebreak")
    SILE.typesetter:leaveHmode()
  end)

end

return package
