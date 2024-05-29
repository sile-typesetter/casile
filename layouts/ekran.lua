return function (class)
   class.options.binding = "print"
   class.options.papersize = 1920 / 192 .. "in x " .. 1080 / 192 .. "in"

   if class._name == "cabook" then
      class:loadPackage(
         "masters",
         {
            {
               id = "right",
               firstContentFrame = "content",
               frames = {
                  page = {
                     left = "0",
                     right = "100%pw",
                     top = "0",
                     bottom = "100%ph",
                  },
                  content = {
                     left = "10%pw",
                     right = "100%pw-10%pw",
                     top = "bottom(runningHead)+1%ph",
                     bottom = "top(footnotes)-1%ph",
                  },
                  runningHead = {
                     left = "left(content)",
                     right = "right(content)",
                     top = "2%ph",
                     bottom = "10%ph",
                  },
                  footnotes = {
                     left = "left(content)",
                     right = "right(content)",
                     height = "0",
                     bottom = "100%ph-3%ph",
                  },
               },
            },
         }
      )

      class:registerCommand("output-right-running-head", function (_, _)
         if not SILE.scratch.headers.right then
            return
         end
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
            SILE.call("cabook:font:folio", {}, { class.packages.counters:formatCounter(SILE.scratch.counters.folio) })
            SILE.call("skip", { height = "-8pt" })
            SILE.call("fullrule", { raise = 0 })
         end)
      end)

      class:registerCommand("output-left-running-head", function (_, _)
         SILE.call("output-right-running-head")
      end)

      class:registerPostinit(function (_)
         SILE.setCommandDefaults("imprint:font", { size = "6.5pt" })
      end)

      -- Screen based PDF readers don't need blank even numbered pages ;)
      class:registerCommand("open-double-page", function ()
         SILE.typesetter:leaveHmode()
         SILE.call("supereject")
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
         SILE.call("background", { color = "#efe6bf" })

         local inkColor = SILE.colorparser("#262d2c")
         SILE.outputter:pushColor(inkColor)
      end
   end
end
