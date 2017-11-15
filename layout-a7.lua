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

setCommandDefaults("imprint:font", { size = "7pt" })

SILE.registerCommand("href", function (options, content)
  SILE.call("markverse", options, content)
  SILE.process(content)
end)
