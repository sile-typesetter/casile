return function (class)

  class.options.papersize = "165mm x 250mm"

  if class._name == "cabook" then

    class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = {
        content = {
          left = "left(page) + 22.5mm",
          right = "right(page) - 15mm",
          top = "22mm",
          bottom = "top(footnotes)"
        },
        runningHead = {
          left = "left(content)",
          right = "right(content)",
          top = "top(content) - 10mm",
          bottom = "top(content) - 4mm"
        },
        footnotes = {
          left = "left(content)",
          right = "right(content)",
          height = "0",
          bottom = "top(folio) - 5mm"
        },
        folio = {
          left = "left(content)",
          right = "right(content)",
          height = "5mm",
          bottom = "bottom(page) - 12.5mm"
        }
      }
    }})

  end

end
