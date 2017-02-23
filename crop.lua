local bleed = 3 * 2.83465
local trim = 10 * 2.83465
local len = trim - bleed

SILE.require("packages/cropmarks")

-- Use  our own version of SILE packgage
local outcounter = 1
local date = SILE.require("packages.date").exports

local outputMarks = function()
  local page = SILE.getFrame("page")
  SILE.outputter.rule(page:left() - bleed, page:top(), -len, 0.5)
  SILE.outputter.rule(page:left(), page:top() - bleed, 0.5, -len)
  SILE.outputter.rule(page:right() + bleed, page:top(), len, 0.5)
  SILE.outputter.rule(page:right(), page:top() - bleed, 0.5, -len)
  SILE.outputter.rule(page:left() - bleed, page:bottom(), -len, 0.5)
  SILE.outputter.rule(page:left(), page:bottom() + bleed, 0.5, len)
  SILE.outputter.rule(page:right() + bleed, page:bottom(), len, 0.5)
  SILE.outputter.rule(page:right(), page:bottom() + bleed, 0.5, len)

  SILE.call("hbox", {}, function()
    SILE.settings.temporarily(function()
      SILE.call("noindent")
      SILE.call("font", { size="6pt" })
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

SILE.registerCommand("crop:setup", function (o,c)
  local papersize = SU.required(o, "papersize", "setting up crop marks")
  local size = SILE.paperSizeParser(papersize)
  local oldsize = SILE.documentState.paperSize
  SILE.documentState.paperSize = size
  local offsetx = ( SILE.documentState.paperSize[1] - oldsize[1] ) / 2
  local offsety = ( SILE.documentState.paperSize[2] - oldsize[2] ) / 2
  local page = SILE.getFrame("page")
  page:constrain("right", oldsize[1] + offsetx)
  page:constrain("left", offsetx)
  page:constrain("bottom", oldsize[2] + offsety)
  page:constrain("top", offsety)
  if SILE.scratch.masters then
    for k,v in pairs(SILE.scratch.masters) do
      reconstrainFrameset(v.frames)
    end
  else
    reconstrainFrameset(SILE.documentState.documentClass.pageTemplate.frames)
  end
  if SILE.typesetter.frame then SILE.typesetter.frame:init() end

  local oldEndPage = SILE.documentState.documentClass.endPage
  SILE.documentState.documentClass.endPage = function(self)
    oldEndPage(self)
    outputMarks()
  end
end)

-- END package override

if not sheetsize then
  local papersize = SILE.documentState.paperSize
  local w = papersize[1] + (trim * 2)
  local h = papersize[2] + (trim * 2)
  sheetsize = w .. "pt x " .. h .. "pt"
end

local outcounter = 1

SILE.registerCommand("crop:header", function (options, content)
  SILE.call("meta:surum")
  SILE.typesetter:typeset(" (" .. outcounter .. ") " .. os.getenv("HOSTNAME") .. " / " .. os.date("%Y-%m-%d, %X"))
  outcounter = outcounter + 1
end)

SILE.call("crop:setup", { papersize = sheetsize })
