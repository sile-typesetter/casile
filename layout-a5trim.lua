local class = SILE.documentState.documentClass

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "22.5mm",
        right = "100%pw-15mm",
        top = "20mm",
        bottom = "top(footnotes)"
      },
      runningHead = {
        left = "left(content)",
        right = "right(content)",
        top = "top(content)-8mm",
        bottom = "top(content)-2mm"
      },
      footnotes = {
        left = "left(content)",
        right = "right(content)",
        height = "0",
        bottom = "100%ph-15mm"
      },
      folio = {
        left = "left(content)",
        right = "right(content)",
        top = "100%ph-13mm",
        height = "6mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

setCommandDefaults("imprint:font", { size = "8.5pt" })

SILE.registerCommand("href", function (options, content)
  SILE.process(content)
end)
