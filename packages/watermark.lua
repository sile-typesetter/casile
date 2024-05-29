local base = require("packages.base")

local package = pl.class(base)
package._name = "watermark"

local text = os.getenv("CASILE_WATERMARK") or "DRAFT"

function package:_init (options)
   if options.text then
      text = options.text
   end
   base._init(self, options)
   self:loadPackage("rotate")
   self.class:registerHook("newpage", self.addWatermark)
   self:addWatermark()
end

function package.addWatermark ()
   local frame = SILE.newFrame({
      id = "watermark",
      left = "left(page)+20",
      right = "right(page)-20",
      top = "top(page)+20",
      bottom = "bottom(page)-20",
   })
   SILE.documentState.thisPageTemplate.frames.watermark = frame
   SILE.typesetNaturally(frame, SILE.Commands["watermark:content"])
end

function package:registerCommands ()
   self:registerCommand("watermark:content", function (_, _)
      SILE.call("hbox")
      SILE.call("skip", { height = "20%fh" })
      SILE.call("center", {}, function ()
         SILE.call("color", { color = "#fafafa" }, function ()
            SILE.call("rotate", { angle = -35 }, function ()
               SILE.call("font", { family = "TeX Gyre Heros", weight = 900, size = "8%fw" }, { text })
            end)
            SILE.call("skip", { height = "20%fh" })
            SILE.call("rotate", { angle = -35 }, function ()
               SILE.call("font", { family = "TeX Gyre Heros", weight = 900, size = "8%fw" }, { text })
            end)
         end)
      end)
   end)
end

return package
