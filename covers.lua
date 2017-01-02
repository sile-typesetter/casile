SILE.registerCommand("frontcover", function ()
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
  SILE.call("color", { color = "#000000" }, function ()
    SILE.call("center", {}, function ()
      SILE.call("hbox")
      SILE.call("skip", { height = "1cm" })
      SILE.call("book:partnumfont", { size = "7%pw" }, function ()
        SILE.call("wraptitle", {}, { SILE.metadata.title })
      end)
      SILE.call("skip", { height = "14%ph" })
      SILE.call("book:titlefont", { size = "5%pw" }, function ()
        SILE.call("wrapsubtitle", {}, { SILE.metadata.subtitle })
      end)
      SILE.call("vfill")
      SILE.call("vfill")
      SILE.call("book:partnumfont", { size = "6%pw", weight = 300 }, { SILE.metadata.creator[1].text })
    end)
    SILE.call("par")
  end)
  SILE.call("supereject")
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
  SILE.call("color", { color = "#000000" }, function ()
    SILE.settings.set("linebreak.emergencyStretch", SILE.length.parse("2spc"))
    SILE.settings.temporarily(function ()
      SILE.call("font", { size = "1.3em", language = "tr", weight = "600" })
      SILE.settings.set("linespacing.method", "fit-font")
      SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.6ex"))
    dropcapNextLetter()
      SILE.process({ SILE.metadata.abstract })
      SILE.call("par")
      SILE.call("raggedleft", {}, function ()
        SILE.call("em", {}, { SILE.metadata.creator[1].text })
      end)
    end)
    SILE.call("vfill")
	SILE.call("img", { src = "mediya/packer.jpg", width = "85pt" })
    SILE.call("par")
    SILE.settings.temporarily(function ()
      SILE.settings.set("linespacing.method", "fit-font")
      SILE.settings.set("linespacing.fit-font.extra-space", SILE.length.parse("0.2ex"))
      SILE.call("book:sansfont", { size = "0.8em", language = "tr", weight = 600 })
      SILE.call("skip", { height = "-108pt" })
      SILE.settings.set("document.lskip", SILE.nodefactory.newGlue("92pt"))
      SILE.process({ SILE.metadata.creator[1].about })
      SILE.call("par")
    end)
    SILE.call("skip", { height = "1cm" })
    SILE.call("break")
  end)
end)

SILE.registerCommand("spine", function ()
  options = {}
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
  SILE.call("color", { color = "#000000" }, function ()
    SILE.call("center", {}, function ()
      SILE.call("font", { size = "30%fh" }, function ()
        SILE.call("topfill")
        SILE.call("skip", { height = "-0.4ex" })
        SILE.call("wraptitle")
        SILE.call("par")
      end)
    end)
  end)
  SILE.call("eject")
  SILE.call("color", { color = "#000000" }, function ()
    SILE.call("center", {}, function ()
      SILE.call("topfill")
      SILE.call("skip", { height = "10%fh" })
      SILE.call("book:partnumfont", { size = "30%fh", weight = 300 },  { SILE.metadata.creator[1].text })
      SILE.call("par")
    end)
  end)
end)

