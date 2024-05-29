return function (class)
   if class._name == "cabook" then
      class.defaultFrameset = {
         content = {
            left = "left(page) + 32mm",
            right = "right(page) - 32mm",
            top = "top(page) + 34mm",
            bottom = "top(footnotes)",
         },
         runningHead = {
            left = "left(content)",
            right = "right(content)",
            top = "top(page) + 24mm",
            bottom = "top(page) + 30mm",
         },
         footnotes = {
            left = "left(content)",
            right = "right(content)",
            height = "0",
            bottom = "bottom(page) - 34mm",
         },
         folio = {
            left = "left(content)",
            right = "right(content)",
            top = "bottom(page) - 32mm",
            height = "6mm",
         },
      }

      -- We have a bound A4 format too, but this one doesn't need double-page openers
      class:registerCommand("open-spread", function ()
         SILE.typesetter:leaveHmode()
         SILE.call("supereject")
         SILE.typesetter:leaveHmode()
      end)
   end
end
