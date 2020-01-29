local color = "#FFFFFF"

SILE.registerCommand("frontcover", function ()
  options = {}
  options["first-content-frame"] = "front"
  SILE.call("pagetemplate", options, function ()
    SILE.call("frame", {
        id = "front",
        top = "0",
        bottom = "100%ph",
        left = "15%pw",
        right = "85%pw"
      })
  end)
  SILE.call("color", { color = color }, function ()
    SILE.call("center", {}, function ()
      SILE.call("hbox")
      SILE.call("vfill")
      SILE.call("cabook:font:title", { size = "7%pmed" }, function ()
        SILE.call("wraptitle", {}, { CASILE.metadata.title })
      end)
      SILE.call("skip", { height = "7%pmin" })
      SILE.call("cabook:font:subtitle", { size = "5%pmed" }, function ()
        SILE.call("wrapsubtitle", {}, { CASILE.metadata.subtitle })
      end)
      SILE.call("vfill")
      SILE.call("vfill")
      if CASILE.metadata.creator then
        SILE.call("cabook:font:author", { size = "6%pmed", weight = 300 }, { CASILE.metadata.creator[1].text })
      end
    end)
    SILE.call("par")
    SILE.call("vfill")
    SILE.call("break")
  end)
end)

SILE.registerCommand("backcover", function ()
  options = {}
  options["first-content-frame"] = "front"
  SILE.call("pagetemplate", options, function ()
    SILE.call("frame", {
        id = "front",
        top = "15%pw",
        bottom = "100%ph - 15%pw",
        left = "15%pw",
        right = "85%pw"
      })
  end)
  SILE.call("noindent")
  SILE.call("color", { color = color }, function ()
    SILE.settings.set("linebreak.emergencyStretch", SILE.length("2spc"))
    SILE.settings.temporarily(function ()
      SILE.call("font", { size = "5.2%fw", language = "tr", weight = "600" })
      SILE.settings.set("linespacing.method", "fit-font")
      SILE.settings.set("linespacing.fit-font.extra-space", SILE.length("0.6ex"))
      dropcapNextLetter()
      SILE.process({ CASILE.metadata.abstract })
      SILE.call("par")
      if CASILE.metadata.creator then
        SILE.call("raggedleft", {}, function ()
          SILE.call("em", {}, { CASILE.metadata.creator[1].text })
        end)
      end
    end)
    SILE.call("skip", { height = "8%pmin" })
    SILE.call("par")
    SILE.settings.temporarily(function ()
      SILE.settings.set("linespacing.method", "fit-font")
      SILE.settings.set("linespacing.fit-font.extra-space", SILE.length("0.32ex"))
      SILE.call("cabook:font:sans", { size = "3.4%fw", language = "tr", weight = 600 })
      SILE.settings.set("document.lskip", SILE.nodefactory.glue("82pt"))
      if CASILE.metadata.creator then
        SILE.process({ CASILE.metadata.creator[1].about })
      end
      SILE.call("par")
    end)
    SILE.call("skip", { height = "1cm" })
    SILE.call("break")
  end)
end)

SILE.registerCommand("spine", function (options)
  options["first-content-frame"] = "spine1"
  SILE.call("pagetemplate", options, function ()
    SILE.call("frame", {
        id = "spine1",
        top = "-" .. spine,
        height = spine,
        left = spine,
        width = "46%ph",
        next = "spine2",
        rotate = 90
      })
    SILE.call("frame", {
        id = "spine2",
        top = "-50%ph-" .. spine,
        height = spine,
        left = spine,
        width = "30%ph",
        rotate = 90
      })
  end)
  SILE.call("noindent")
  SILE.call("color", { color = color }, function ()
    SILE.call("center", {}, function ()
        SILE.call("topfill")
        SILE.call("skip", { height = "-10%fh" })
        SILE.call("cabook:font:title", { size = "60%fh" }, { CASILE.metadata.title })
        SILE.call("par")
    end)
  end)
  SILE.call("framebreak")
  SILE.call("color", { color = color }, function ()
    SILE.call("center", {}, function ()
      SILE.call("topfill")
      SILE.call("skip", { height = "10%fh" })
      if CASILE.metadata.creator then
        SILE.call("cabook:font:author", { size = "30%fh" },  { CASILE.metadata.creator[1].text })
      end
      SILE.call("par")
    end)
  end)
end)
