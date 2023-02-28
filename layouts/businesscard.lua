return function (class)

  class.options.binding = "print"
  class.options.papersize = "84mm x 52mm"

  if class._name == "cabook" then

    class.defaultFrameset = {
      content = {
        left = "left(page) + 5mm",
        right = "right(page) - 5mm",
        top = "top(page) + 5mm",
        bottom = "bottom(page) - 5mm"
      }
    }

    class:loadPackage("crop", {
      bleed = SILE.length("2.5mm").length,
      trim = SILE.length("5mm").length
    })

    class:registerCommand("output-right-running-head", function () end)

    class:registerCommand("output-left-running-head", function () end)

    -- Card layouts don’t need blanks of any kind.
    class:registerCommand("open-spread", function ()
      SILE.typesetter:leaveHmode()
      SILE.call("supereject")
      SILE.typesetter:leaveHmode()
    end)

    SILE.setCommandDefaults("imprint:font", { size = "5pt" })

  end

end
