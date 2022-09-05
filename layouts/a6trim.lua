return function (class)

  class.options.papersize = "90mm x 135mm"

  if class._name == "cabook" then

    class.defaultFrameset = {
      content = {
        left = "12mm",
        right = "100%pw-12mm",
        top = "12mm",
        bottom = "100%ph-12mm"
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

    SILE.setCommandDefaults("imprint:font", { size = "6.5pt" })

  end

end
