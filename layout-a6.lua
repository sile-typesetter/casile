CASILE.layout = "a6"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("74mm x 105mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "10mm",
        right = "100%pw-7.5mm",
        top = "7.5mm",
        bottom = "100%ph-7.5mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

if class.options.crop() == "true" then class:setupCrop() end

SILE.setCommandDefaults("imprint:font", { size = "6pt" })

SILE.registerCommand("href", function (options, content)
  SILE.call("markverse", options, content)
  SILE.process(content)
end)
