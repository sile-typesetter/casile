return function (class)

  class.options.papersize = "85mm x 54mm"

  class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = {
        content = {
          left = "8mm",
          right = "100%pw-8mm",
          top = "8mm",
          bottom = "100%ph-8mm"
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

  class:registerCommand("output-right-running-head", function () end)

  class:registerCommand("output-left-running-head", function () end)

  -- Card layouts don’t need blanks of any kind.
  class:registerCommand("open-double-page", function ()
    SILE.typesetter:leaveHmode()
    SILE.call("supereject")
    SILE.typesetter:leaveHmode()
  end)

  SILE.setCommandDefaults("imprint:font", { size = "7pt" })

end
