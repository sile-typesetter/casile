local book = SILE.require("classes/book");
book:loadPackage("masters")
book:defineMaster({ id = "right", firstContentFrame = "content", frames = {
  content = {left = "32mm", right = "100%pw-32mm", top = "36mm", bottom = "top(footnotes)" },
  runningHead = {left = "left(content)", right = "right(content)", top = "top(content)-12mm", bottom = "top(content)-2mm" },
  footnotes = { left="left(content)", right = "right(content)", height = "0", bottom="100%ph-24mm"}
}})
book:defineMaster({ id = "left", firstContentFrame = "content", frames = {}})
book:loadPackage("twoside", { oddPageMaster = "right", evenPageMaster = "left" });
book:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", {id="right"})

SILE.registerCommand("meta:distribution", function(options, content)
  SILE.call("font", { weight=600, style="Bold" }, {"Yayın: "})
  SILE.typesetter:typeset("Bu PDF biçimi, özellikle yerel kiliselerin kendi cemaatları için basmalarına uygun hazırlanmıştır ve Via Christus’un internet sitesinde üçretsiz yayılmaktadır.")
end)
