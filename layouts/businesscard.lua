return function (class)

  class.options.papersize = "84mm x 52mm"

  class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = {
        content = {
          left = "5mm",
          right = "100%pw-5mm",
          top = "5mm",
          bottom = "100%ph-5mm"
        }
      }
    }})
  class:loadPackage("twoside", {
      oddPageMaster = "right",
      evenPageMaster = "left"
    })

  if class.options.crop then
    class:loadPackage("crop", {
        bleed = SILE.length("2.5mm").length,
        trim = SILE.length("5mm").length
      })
  end

  SILE.registerCommand("output-right-running-head", function () end)

  SILE.registerCommand("output-left-running-head", function () end)

  -- Card layouts don’t need blanks of any kind.
  SILE.registerCommand("open-double-page", function ()
    SILE.typesetter:leaveHmode()
    SILE.call("supereject")
    SILE.typesetter:leaveHmode()
  end)

  SILE.setCommandDefaults("imprint:font", { size = "5pt" })

end
