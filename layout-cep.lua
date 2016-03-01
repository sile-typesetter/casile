local book = SILE.require("classes/book");
book:defineMaster({ id = "right", firstContentFrame = "content", frames = {
  content = {left = "20mm", right = "100%-12.5mm", top = "20mm", bottom = "100%-15mm" },
  runningHead = {left = "left(content)", right = "right(content)", top = "top(content)-10mm", bottom = "top(content)-2mm" },
}})
book:defineMaster({ id = "left", firstContentFrame = "content", frames = {}})
book:loadPackage("twoside", { oddPageMaster = "right", evenPageMaster = "left" });
book:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", {id="right"})
