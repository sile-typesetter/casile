CASILE.layout = "a7"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("74mm x 105mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "12mm",
        right = "100%pw-6mm",
        top = "8mm",
        bottom = "100%ph-6mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

if class.options.crop() == "true" then class:setupCrop() end

SILE.setCommandDefaults("imprint:font", { size = "7pt" })
