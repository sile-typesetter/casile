return function (class)

  class.options.papersize = "85mm x 54mm"

  if class._name == "cabook" then

    class.defaultFrameset = {
      content = {
        left = "left(page) + 8mm",
        right = "right(page) - 8mm",
        top = "top(page) + 8mm",
        bottom = "bottom(page) - 8mm"
      }
    }

    class:registerCommand("output-right-running-head", function () end)

    class:registerCommand("output-left-running-head", function () end)

    -- Card layouts don’t need blanks of any kind.
    class:registerCommand("open-spread", function ()
      SILE.typesetter:leaveHmode()
      SILE.call("supereject")
      SILE.typesetter:leaveHmode()
    end)

    class:registerPostinit(function (_)
      SILE.setCommandDefaults("imprint:font", { size = "7pt" })
    end)

  end

end
