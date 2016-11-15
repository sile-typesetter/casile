local class = SILE.documentState.documentClass

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "32mm",
        right = "100%pw-32mm",
        top = "bottom(runningHead)+4mm",
        bottom = "top(footnotes)-4mm"
      },
      runningHead = {
        left = "left(content)",
        right = "right(content)",
        top = "24mm",
        bottom = "30mm"
      },
      footnotes = {
        left = "left(content)",
        right = "right(content)",
        height = "0",
        bottom = "top(folio)-4mm"
      },
      folio = {
        left = "left(content)",
        right = "right(content)",
        top = "100%ph-30mm",
        bottom = "100%ph-24mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

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
