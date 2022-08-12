return function (class)

  class.options.papersize = "halfletter"

  if class._name == "cabook" then

    class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = {
        content = {
          left = "22.5mm",
          right = "100%pw-15mm",
          top = "20mm",
          bottom = "top(footnotes)"
        },
        runningHead = {
          left = "left(content)",
          right = "right(content)",
          top = "top(content)-8mm",
          bottom = "top(content)"
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

  end

end
