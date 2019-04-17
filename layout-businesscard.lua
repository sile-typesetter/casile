CASILE.layout = "businesscard"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("84mm x 52mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "5mm",
        right = "100%pw-5mm",
        top = "5mm",
        bottom = "100%ph-5mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

if class.options.crop() == "true" then class:setupCrop({
  bleed = SILE.length.parse("2.5mm").length,
  trim = SILE.length.parse("5mm").length
}) end

SILE.registerCommand("output-right-running-head", function () end)

SILE.registerCommand("output-left-running-head", function () end)

-- Card layouts don’t need blanks of any kind.
SILE.registerCommand("open-double-page", function ()
  SILE.typesetter:leaveHmode();
  SILE.Commands["supereject"]();
  SILE.typesetter:leaveHmode();
end)

SILE.setCommandDefaults("imprint:font", { size = "5pt" })
