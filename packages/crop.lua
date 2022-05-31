local bleed = 3 * 2.83465
local trim = 10 * 2.83465
local len = trim - bleed

local outcounter, cropbinding

local function reconstrainFrameset(fs)
  for n,f in pairs(fs) do
    if n ~= "page" then
      if f:isAbsoluteConstraint("right") then
        f.constraints.right = "left(page) + (" .. f.constraints.right .. ")"
      end
      if f:isAbsoluteConstraint("left") then
        f.constraints.left = "left(page) + (" .. f.constraints.left .. ")"
      end
      if f:isAbsoluteConstraint("top") then
        f.constraints.top = "top(page) + (" .. f.constraints.top .. ")"
      end
      if f:isAbsoluteConstraint("bottom") then
        f.constraints.bottom = "top(page) + (" .. f.constraints.bottom .. ")"
      end
      f:invalidate()
    end
  end
end

local setupCrop = function (_, args)
  if args then
    bleed = args.bleed or bleed
    trim = args.trim or trim
    len = trim - bleed
  end
  local papersize = SILE.documentState.paperSize
  local w = papersize[1] + (trim * (cropbinding and 2 or 2))
  local h = papersize[2] + (trim * 2)
  local oldsize = SILE.documentState.paperSize
  SILE.documentState.paperSize = SILE.paperSizeParser(w .. "pt x " .. h .. "pt")
  local page = SILE.getFrame("page")
  page:constrain("right", oldsize[1] + trim)
  page:constrain("left", trim)
  page:constrain("bottom", oldsize[2] + trim)
  page:constrain("top", trim)
  if SILE.scratch.masters then
		-- TODO: should this be ipairs()?
    for _, v in pairs(SILE.scratch.masters) do
      reconstrainFrameset(v.frames)
    end
  else
    reconstrainFrameset(SILE.documentState.documentClass.pageTemplate.frames)
  end
  if SILE.typesetter and SILE.typesetter.frame then SILE.typesetter.frame:init() end
end

local outputMarks = function ()
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

  SILE.call("hbox", {}, function ()
    SILE.settings.temporarily(function ()
      SILE.call("noindent")
      SILE.call("font", { family = "Libertinus Serif", size = bleed * 0.8,  weight = 400, style = nil, features = nil })
      SILE.call("crop:header")
    end)
  end)
  local hbox = SILE.typesetter.state.nodes[#SILE.typesetter.state.nodes]
  SILE.typesetter.state.nodes[#SILE.typesetter.state.nodes] = nil

  SILE.typesetter.frame.state.cursorX = page:left() + bleed
  SILE.typesetter.frame.state.cursorY = page:top() - bleed - len / 2 + 2
  outcounter = outcounter + 1

  if hbox then
    for i=1,#(hbox.value) do hbox.value[i]:outputYourself(SILE.typesetter, {ratio=1}) end
  end
end

local function init (class, args)

  outcounter = 1
  cropbinding = class.options.binding == "stapled"
  setupCrop(args)

end
local function registerCommands (_)

  SILE.registerCommand("crop:header", function (_, _)
    SILE.call("meta:surum")
    SILE.typesetter:typeset(" (" .. outcounter .. ") " .. os.getenv("HOSTNAME") .. " / " .. os.date("%Y-%m-%d, %X"))
  end)

end

return {
  init = init,
  registerCommands = registerCommands,
  exports =  {
    outputCropMarks = outputMarks,
    setupCrop = setupCrop
  }
}
