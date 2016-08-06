local book = SILE.require("classes/book");
book:defineMaster({ id = "right", firstContentFrame = "content", frames = {
  content = {left = "2mm", right = "100%pw-2mm", top = "12mm", bottom = "100%ph-2mm" },
  runningHead = {left = "left(content)", right = "right(content)", top = "top(content)-10mm", bottom = "top(content)-2mm" },
  footnotes = {left = "left(content)", right = "right(content)", top = "0", height = "0" },
}})
book:defineMaster({ id = "left", firstContentFrame = "content", frames = {}})
book:loadPackage("twoside", { oddPageMaster = "right", evenPageMaster = "left" });
book:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", {id="right"})
SILE.doTexlike([[
\define[command=publicationpage:font]{\font[family=Libertinus Serif,style=Regular,size=7.5pt,language=und]}
]])
