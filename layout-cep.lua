local book = SILE.require("classes/book");
book:defineMaster({ id = "right", firstContentFrame = "content", frames = {
  content = {left = "20mm", right = "100%pw-12.5mm", top = "20mm", bottom = "100%ph-15mm" },
  runningHead = {left = "left(content)", right = "right(content)", top = "top(content)-10mm", bottom = "top(content)-2mm" },
  endnotes = {left = "20mm", right = "100%pw-12.5mm", top = "0", height = "10mm" },
}})
book:defineMaster({ id = "left", firstContentFrame = "content", frames = {}})
book:loadPackage("twoside", { oddPageMaster = "right", evenPageMaster = "left" });
book:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", {id="right"})
SILE.doTexlike([[
\define[command=publicationpage:font]{\font[family=Libertinus Serif,style=Regular,size=7.5pt,language=und]}
]])
