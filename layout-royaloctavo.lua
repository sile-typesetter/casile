CASILE.layout = "royaloctavo"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("165mm x 250mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "22.5mm",
        right = "100%pw-15mm",
        top = "22mm",
        bottom = "top(footnotes)"
      },
      runningHead = {
        left = "left(content)",
        right = "right(content)",
        top = "top(content)-10mm",
        bottom = "top(content)-4mm"
      },
      footnotes = {
        left = "left(content)",
        right = "right(content)",
        height = "0",
        bottom = "top(folio)-5mm"
      },
      folio = {
        left = "left(content)",
        right = "right(content)",
        height = "5mm",
        bottom = "100%ph-12.5mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

if class.options.crop() == "true" then class:setupCrop() end
