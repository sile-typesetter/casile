return function (class)

  class.options.papersize = "105mm x 74mm"

  if class._name == "cabook" then

    class.defaultFrameset = {
      content = {
        left = "8mm",
        right = "100%pw-8mm",
        top = "8mm",
        bottom = "100%ph-8mm"
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

    class:registerCommand("output-right-running-head", function () end)

    class:registerCommand("output-left-running-head", function () end)

    -- Card layouts don’t need blanks of any kind.
    class:registerCommand("open-spread", function ()
      SILE.typesetter:leaveHmode()
      SILE.call("supereject")
      SILE.typesetter:leaveHmode()
    end)

    SILE.setCommandDefaults("imprint:font", { size = "7pt" })

  end

end
