CASILE.layout = "a4ciltli"

local class = SILE.documentState.documentClass

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "38mm",
        right = "100%pw-26mm",
        top = "bottom(runningHead)+4mm",
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
        bottom = "top(folio)-4mm"
      },
      folio = {
        left = "left(content)",
        right = "right(content)",
        top = "100%ph-30mm",
        bottom = "100%ph-24mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })
