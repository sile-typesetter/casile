return function (class)
   class.options.papersize = "110mm x 170mm"

   if class._name == "cabook" then
      class.defaultFrameset = {
         content = {
            left = "left(page) + 20mm",
            right = "right(page) - 10mm",
            top = "top(page) + 20mm",
            bottom = "top(footnotes)",
         },
         runningHead = {
            left = "left(content)",
            right = "right(content)",
            top = "top(content) - 10mm",
            bottom = "top(content) - 2mm",
         },
         footnotes = {
            left = "left(content)",
            right = "right(content)",
            height = "0",
            bottom = "bottom(page) - 15mm",
         },
      }

      class:registerPostinit(function (_)
         SILE.setCommandDefaults("imprint:font", { size = "7pt" })
      end)

      -- Hack to avoid SILE bug in print editions
      -- See https://github.com/simoncozens/sile/issues/355
      class:registerCommand("href", function (options, content)
         if class.options.verseindex then
            SILE.call("markverse", options, content)
         end
         SILE.process(content)
      end)
   end
end
