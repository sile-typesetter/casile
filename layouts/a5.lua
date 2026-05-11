return function (class)
   class.options.papersize = "148mm x 205mm"

   if class._name == "cabook" then
      class.defaultFrameset = {
         content = {
            left = "left(page) + 22.5mm",
            right = "right(page) - 15mm",
            top = "top(page) + 20mm",
            bottom = "top(footnotes)",
         },
         runningHead = {
            left = "left(content)",
            right = "right(content)",
            top = "top(page) + 12mm",
            bottom = "top(page) + 18mm",
         },
         footnotes = {
            left = "left(content)",
            right = "right(content)",
            height = "0",
            bottom = "bottom(page) - 18mm",
         },
         folio = {
            left = "left(content)",
            right = "right(content)",
            top = "bottom(page) - 12mm",
            height = "6mm",
         },
      }

      class:registerPostinit(function (_)
         SILE.setCommandDefaults("imprint:font", { size = "8.5pt" })
      end)
   end
end
