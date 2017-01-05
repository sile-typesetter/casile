local book=SILE.require("classes/book");

SILE.documentState.paperSize = SILE.paperSizeParser("110mm x 170mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

book:defineMaster({
  id = "right", firstContentFrame = "content", frames = {
    content = { left = "20mm", right = "100%pw-10mm", top = "20mm", bottom = "100%ph-15mm" },
    runningHead =  { left = "left(content)", right = "right(content)", top = "top(content)-10mm", bottom = "top(content)-2mm" },
    footnotes = { left = "20mm", right = "100%pw-12.5mm", top = "0", height = "0" },
  }
})
book:defineMaster({ id = "left", firstContentFrame = "content", frames = {} })
book:loadPackage("twoside", { oddPageMaster = "right", evenPageMaster = "left" });
book:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

SILE.require("crop")

local oldImprintFont = SILE.Commands["imprint:font"]
SILE.registerCommand("imprint:font", function (options, content)
  options.size = options.size or "7pt"
  oldImprintFont(options, content)
end)
