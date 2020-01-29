CASILE.layout = "app"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("80mm x 128mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "2mm",
        right = "100%pw-2mm",
        top = "bottom(runningHead)+2mm",
        bottom = "top(footnotes)"
      },
      runningHead = {
        left = "left(content)",
        right = "right(content)",
        top = "2mm",
        bottom = "14mm"
      },
      footnotes = {
        left = "left(content)",
        right = "right(content)",
        height = "0",
        bottom = "100%ph-2mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

SILE.registerCommand("output-right-running-head", function (options, content)
  if not SILE.scratch.headers.right then return end
  SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
    SILE.settings.set("current.parindent", SILE.nodefactory.glue())
    SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.glue())
    SILE.settings.set("document.lskip", SILE.nodefactory.glue())
    SILE.settings.set("document.rskip", SILE.nodefactory.glue())
    SILE.call("cabook:font:right-header", {}, function ()
      SILE.call("center", {}, function ()
        SILE.call("meta:title")
      end)
    end)
    SILE.call("skip", { height = "2pt" })
    SILE.call("cabook:font:right-header", {}, SILE.scratch.headers.right)
    SILE.call("hfill")
    SILE.call("cabook:font:folio", {},  { SILE.formatCounter(SILE.scratch.counters.folio) })
    SILE.call("skip", { height = "-8pt" })
    SILE.call("fullrule", { raise = 0 })
  end)
end)

SILE.registerCommand("output-left-running-head", function (options, content)
  SILE.call("output-right-running-head")
end)

local oldImprintFont = SILE.Commands["imprint:font"]
SILE.registerCommand("imprint:font", function (options, content)
  options.size = options.size or "6.5pt"
  oldImprintFont(options, content)
end)

-- Mobile device PDF readers don't need blank even numbered pages ;)
SILE.registerCommand("open-double-page", function ()
  SILE.typesetter:leaveHmode();
  SILE.Commands["supereject"]();
  SILE.typesetter:leaveHmode();
end)

-- Forgo bottom of page layouts for mobile devices
SILE.registerCommand("topfill", function (options, content)
  SILE.typesetter:leaveHmode();
end)

local origToc = SILE.Commands["tableofcontents"]
SILE.registerCommand("tableofcontents", function (options, content)
  SILE.scratch.headers.skipthispage = true
  origToc(options, content)
  SILE.scratch.headers.right = {}
end)

if SILE.documentState.documentClass.options.background() == "true" then
  SILE.require("packages/background")
  SILE.call("background", { color = "#e1e2e6" })

  local inkColor = SILE.colorparser("#19191A")
  SILE.outputter:pushColor(inkColor)
end

SILE.settings.set("linebreak.emergencyStretch", SILE.length("3em"))
