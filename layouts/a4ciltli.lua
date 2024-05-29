return function (class)
   if class._name == "cabook" then
      class.defaultFrameset = {
         content = {
            left = "left(page) + 38mm",
            right = "right(page) - 26mm",
            top = "bottom(runningHead) + 4mm",
            bottom = "top(footnotes)",
         },
         runningHead = {
            left = "left(content)",
            right = "right(content)",
            top = "top(page) + 24mm",
            height = "6mm",
         },
         footnotes = {
            left = "left(content)",
            right = "right(content)",
            height = "0",
            bottom = "top(folio) - 4mm",
         },
         folio = {
            left = "left(content)",
            right = "right(content)",
            top = "bottom(page) - 30mm",
            height = "6mm",
         },
      }
   end
end
