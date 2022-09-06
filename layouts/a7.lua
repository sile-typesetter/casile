return function (class)

  class.options.papersize = "74mm x 105mm"

  if class._name == "cabook" then

    class.defaultFrameset = {
        content = {
          left = "12mm",
          right = "100%pw-6mm",
          top = "8mm",
          bottom = "100%ph-6mm"
        }
      }

    class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = class.defaultFrameset
    }})

    class:loadPackage("twoside", {
      oddPageMaster = "right",
      evenPageMaster = "left"
    })

    class:registerPostinit(function (class)
      SILE.setCommandDefaults("imprint:font", { size = "7pt" })
    end)

  end

end
