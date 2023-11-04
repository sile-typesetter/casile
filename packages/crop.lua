local base = require("packages.base")

local package = pl.class(base)
package._name = "crop"

local mm = 2.83465
local bleed = 3 * mm
local trim = 10 * mm
local len

local outcounter, cropbinding

-- See https://github.com/sile-typesetter/sile/pull/1470#discussion_r964040477
function package.mirrorMaster (_, existing, new)
  if not SILE.scratch.masters[new] then SILE.scratch.masters[new] = { frames = {} } end
  if not SILE.scratch.masters[existing] then
    SU.error("Can't find master "..existing)
  end
  for name, frame in pairs(SILE.scratch.masters[existing].frames) do
    local newframe = pl.tablex.deepcopy(frame)
    if frame:isAbsoluteConstraint("right") then
      newframe.constraints.left = "2 * left(page) + 100%pw-("..frame.constraints.right..")"
    end
    if frame:isAbsoluteConstraint("left") then
      newframe.constraints.right = "2 * left(page) + 100%pw-("..frame.constraints.left..")"
    end
    SILE.scratch.masters[new].frames[name] = newframe
    if frame == SILE.scratch.masters[existing].firstContentFrame then
      SILE.scratch.masters[new].firstContentFrame = newframe
    end
  end
end

function package._setupCrop (_, args)
  if args then
    bleed = args.bleed or bleed
    trim = args.trim or trim
  end
  len = trim - bleed
  local papersize = SILE.documentState.paperSize
  local w = papersize[1] + (trim * (cropbinding and 2 or 2))
  local h = papersize[2] + (trim * 2)
  SILE.documentState.paperSize = SILE.paperSizeParser(w .. "pt x " .. h .. "pt")
  local page = SILE.getFrame("page")
  page:constrain("left", trim)
  page:constrain("right", page.constraints.right + trim)
  page:constrain("top", trim)
  page:constrain("bottom", page.constraints.bottom + trim)
  page:invalidate()
  if SILE.typesetter and SILE.typesetter.frame then SILE.typesetter.frame:init() end
end

local function _outputCropMarks ()
  local page = SILE.getFrame("page")

  -- Top left
  SILE.outputter:drawRule(page:left() - bleed, page:top(), -len, 0.5)
  SILE.outputter:drawRule(page:left(), page:top() - bleed, 0.5, -len)

  -- Top  right
  SILE.outputter:drawRule(page:right() + bleed, page:top(), len, 0.5)
  SILE.outputter:drawRule(page:right(), page:top() - bleed, 0.5, -len)

  -- Bottom left
  SILE.outputter:drawRule(page:left() - bleed, page:bottom(), -len, 0.5)
  SILE.outputter:drawRule(page:left(), page:bottom() + bleed, 0.5, len)

  -- Bottom right
  SILE.outputter:drawRule(page:right() + bleed, page:bottom(), len, 0.5)
  SILE.outputter:drawRule(page:right(), page:bottom() + bleed, 0.5, len)

  local statelen = #SILE.typesetter.state.nodes
  local hbox = SILE.call("hbox", {}, function ()
    SILE.settings:temporarily(function ()
      SILE.call("noindent")
      SILE.call("font", { family = "Libertinus Serif", size = bleed * 0.8,  weight = 400, style = nil, features = nil })
      SILE.call("crop:header")
    end)
  end)
  pl.tablex.clear(SILE.typesetter.state.nodes, statelen)

  SILE.typesetter.frame.state.cursorX = page:left() + bleed
  SILE.typesetter.frame.state.cursorY = page:top() - bleed - len / 2 + 2
  outcounter = outcounter + 1

  if hbox then
    for i = 1, #hbox.value do hbox.value[i]:outputYourself(SILE.typesetter, { ratio = 1 }) end
  end
end

function package:_init (args)
  base._init(self, args)

  -- See https://github.com/sile-typesetter/sile/pull/1470#discussion_r964040477
  self:export("mirrorMaster", self.mirrorMaster)

  outcounter = 1
  cropbinding = self.class.options.binding == "stapled"
  self:_setupCrop(args)

  self.class:registerHook("endpage", _outputCropMarks)

end

function package:registerCommands ()

  self:registerCommand("crop:header", function (_, _)
    SILE.call("meta:surum")
    SILE.typesetter:typeset(" (" .. outcounter .. ") " .. os.getenv("HOSTNAME") .. " / " .. os.date("%Y-%m-%d, %X"))
  end)

end

return package
