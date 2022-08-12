return function (class)

  class.options.papersize = "80mm x 128mm"

  if class._name == "cabook" then

    class:loadPackage("masters", {{
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
    }})
    class:loadPackage("twoside", {
      oddPageMaster = "right",
      evenPageMaster = "left"
    })

    if class.options.crop then
      class:loadPackage("crop")
    end

    class:registerCommand("output-right-running-head", function (_, _)
      if not SILE.scratch.headers.right then return end
      SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
        SILE.settings:set("current.parindent", SILE.nodefactory.glue())
        SILE.settings:set("typesetter.parfillskip", SILE.nodefactory.glue())
        SILE.settings:set("document.lskip", SILE.nodefactory.glue())
        SILE.settings:set("document.rskip", SILE.nodefactory.glue())
        SILE.call("cabook:font:right-header", {}, function ()
          SILE.call("center", {}, function ()
            SILE.call("meta:title")
          end)
        end)
        SILE.call("skip", { height = "2pt" })
        SILE.call("cabook:font:right-header", {}, SILE.scratch.headers.right)
        SILE.call("hfill")
        SILE.call("cabook:font:folio", {},  { class.packages.counters:formatCounter(SILE.scratch.counters.folio) })
        SILE.call("skip", { height = "-8pt" })
        SILE.call("fullrule", { raise = 0 })
      end)
    end)

    class:registerCommand("output-left-running-head", function (_, _)
      SILE.call("output-right-running-head")
    end)

    local oldImprintFont = SILE.Commands["imprint:font"]
    class:registerCommand("imprint:font", function (options, content)
      options.size = options.size or "6.5pt"
      oldImprintFont(options, content)
    end)

    -- Mobile device PDF readers don't need blank even numbered pages ;)
    class:registerCommand("open-double-page", function ()
      SILE.typesetter:leaveHmode()
      SILE.call("supereject")
      SILE.typesetter:leaveHmode()
    end)

    -- Forgo bottom of page layouts for mobile devices
    class:registerCommand("topfill", function (_, _)
      SILE.typesetter:leaveHmode()
    end)

    local origToc = SILE.Commands["tableofcontents"]
    class:registerCommand("tableofcontents", function (options, content)
      SILE.scratch.headers.skipthispage = true
      origToc(options, content)
      SILE.scratch.headers.right = {}
    end)

    if class.options.background() == "true" then
      SILE.require("packages/background")
      SILE.call("background", { color = "#e1e2e6" })

      local inkColor = SILE.colorparser("#19191A")
      SILE.outputter:pushColor(inkColor)
    end

    SILE.settings:set("linebreak.emergencyStretch", SILE.length("3em"))

  end

end
