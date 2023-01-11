return function (class)

  class.options.papersize = "74mm x 105mm"

  if class._name == "cabook" then

    class.defaultFrameset = {
        content = {
          left = "left(page) + 12mm",
          right = "right(page) - 6mm",
          top = "top(page) + 8mm",
          bottom = "bottom(page) - 6mm"
        }
      }

    class:registerPostinit(function (_)
      SILE.setCommandDefaults("imprint:font", { size = "7pt" })
    end)

  end

end
