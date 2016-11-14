local class = SILE.documentState.documentClass
class:loadPackage("masters")
class:defineMaster({ id = "right", firstContentFrame = "content", frames = {
  content = { left = "32mm", right = "100%pw-32mm", top = "36mm", bottom = "top(footnotes)" },
  runningHead = { left = "left(content)", right = "right(content)", top = "top(content)-12mm", bottom = "top(content)-2mm" },
  footnotes = { left = "left(content)", right = "right(content)", height = "0", bottom = "100%ph-24mm"}
}})
class:defineMaster({ id = "left", firstContentFrame = "content", frames = {} })
class:loadPackage("twoside", { oddPageMaster = "right", evenPageMaster = "left" });
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", {id = "right"})

SILE.registerCommand("meta:distribution", function (options, content)
  SILE.call("font", { weight = 600, style = "Bold" }, { "Yayın: " })
  SILE.typesetter:typeset("Bu PDF biçimi, özellikle yerel kiliselerin kendi cemaatları için basmalarına uygun hazırlanmıştır ve Via Christus’un internet sitesinde üçretsiz yayılmaktadır.")
end)

-- We have a bound A4 format too, but this one doesn't need double-page openers
SILE.registerCommand("open-double-page", function ()
  SILE.typesetter:leaveHmode();
  SILE.Commands["supereject"]();
  SILE.typesetter:leaveHmode();
end)
