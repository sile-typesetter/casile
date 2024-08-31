return function (class)
   class.options.papersize = "halfletter"

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
            top = "top(content) - 8mm",
            bottom = "top(content)",
         },
         footnotes = {
            left = "left(content)",
            right = "right(content)",
            height = "0",
            bottom = "bottom(page) - 15mm",
         },
      }
   end
end
