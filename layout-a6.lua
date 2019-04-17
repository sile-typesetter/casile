CASILE.layout = "a6"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("105mm x 148mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "12mm",
        right = "100%pw-12mm",
        top = "12mm",
        bottom = "100%ph-12mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

if class.options.crop() == "true" then class:setupCrop() end

SILE.setCommandDefaults("imprint:font", { size = "6.5pt" })
