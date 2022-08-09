return function (class)

  class.options.papersize = "110mm x 170mm"

  class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = {
        content = {
          left = "20mm",
          right = "100%pw-10mm",
          top = "20mm",
          bottom = "top(footnotes)"
        },
        runningHead = {
          left = "left(content)",
          right = "right(content)",
          top = "top(content)-10mm",
          bottom = "top(content)-2mm"
        },
        footnotes = {
          left = "left(content)",
          right = "right(content)",
          height = "0",
          bottom = "100%ph-15mm"
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

  SILE.setCommandDefaults("imprint:font", { size = "7pt" })

end
