return function (class)

  class.options.papersize = "105mm x 148mm"

  if class._name == "cabook" then

    class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = {
        content = {
          left = "12mm",
          right = "100%pw-12mm",
          top = "12mm",
          bottom = "100%ph-12mm"
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

    SILE.setCommandDefaults("imprint:font", { size = "6.5pt" })

  end

end
