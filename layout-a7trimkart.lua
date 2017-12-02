CASILE.layout = "a7trimkart"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("85mm x 54mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "8mm",
        right = "100%pw-8mm",
        top = "8mm",
        bottom = "100%ph-8mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

if class.options.crop() == "true" then class:setupCrop() end

SILE.registerCommand("output-right-running-head", function () end)

SILE.registerCommand("output-left-running-head", function () end)

-- Card layouts don’t need blanks of any kind.
SILE.registerCommand("open-double-page", function ()
  SILE.typesetter:leaveHmode();
  SILE.Commands["supereject"]();
  SILE.typesetter:leaveHmode();
end)

SILE.setCommandDefaults("imprint:font", { size = "7pt" })

SILE.registerCommand("href", function (options, content)
  SILE.call("markverse", options, content)
  SILE.process(content)
end)
