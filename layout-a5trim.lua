local book = SILE.require("classes/book");
book:loadPackage("masters")
book:defineMaster({ id = "right", firstContentFrame = "content", frames = {
  content = { left = "22.5mm", right = "100%pw-15mm", top = "20mm", bottom = "top(footnotes)" },
  runningHead = { left = "left(content)", right = "right(content)", top = "top(content)-8mm", bottom = "top(content)-2mm" },
  footnotes = { left = "left(content)", right = "right(content)", height = "0", bottom = "100%ph-15mm" }
}})
book:defineMaster({ id = "left", firstContentFrame = "content", frames = {} })
book:loadPackage("twoside", { oddPageMaster = "right", evenPageMaster = "left" });
book:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right"  })

local oldImprintFont = SILE.Commands["imprint:font"]
SILE.registerCommand("imprint:font", function (options, content)
  options.size = options.size or "8.5pt"
  oldImprintFont(options, content)
end)
