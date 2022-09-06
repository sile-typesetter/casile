return function (class)

  class.options.papersize = "110mm x 170mm"

  if class._name == "cabook" then

    class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = {
        content = {
          left = "left(page) + 20mm",
          right = "right(page) - 10mm",
          top = "top(page) + 20mm",
          bottom = "top(footnotes)"
        },
        runningHead = {
          left = "left(content)",
          right = "right(content)",
          top = "top(content) - 10mm",
          bottom = "top(content) - 2mm"
        },
        footnotes = {
          left = "left(content)",
          right = "right(content)",
          height = "0",
          bottom = "bottom(page) - 15mm"
        }
      }
    }})

    SILE.setCommandDefaults("imprint:font", { size = "7pt" })

  end

end
