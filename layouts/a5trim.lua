CASILE.layout = "a5trim"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("135mm x 195mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

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
        bottom = "100%ph-18mm"
      },
      folio = {
        left = "left(content)",
        right = "right(content)",
        top = "100%ph-12mm",
        height = "6mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

if class.options.crop() == "true" then class:setupCrop() end

SILE.setCommandDefaults("imprint:font", { size = "8.5pt" })

-- Hack to avoid SILE bug in print editions
-- See https://github.com/simoncozens/sile/issues/355
SILE.registerCommand("href", function (options, content)
  if class.options.verseindex() == "true" then
    SILE.call("markverse", options, content)
  end
  SILE.process(content)
end)
