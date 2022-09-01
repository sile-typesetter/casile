return function (class)

  if class._name == "cabook" then

    class.defaultFrameset = {
        content = {
          left = "32mm",
          right = "100%pw-32mm",
          top = "34mm",
          bottom = "top(footnotes)"
        },
        runningHead = {
          left = "left(content)",
          right = "right(content)",
          top = "24mm",
          bottom = "30mm"
        },
        footnotes = {
          left = "left(content)",
          right = "right(content)",
          height = "0",
          bottom = "100%ph-34mm"
        },
        folio = {
          left = "left(content)",
          right = "right(content)",
          top = "100%ph-32mm",
          bottom = "100%ph-26mm"
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

    -- We have a bound A4 format too, but this one doesn't need double-page openers
    class:registerCommand("open-spread", function ()
      SILE.typesetter:leaveHmode()
      SILE.call("supereject")
      SILE.typesetter:leaveHmode()
    end)

  end

end
