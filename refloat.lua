-- See SILE #1185
-- Here be dragons.

local lockAdvance = function ()
  SILE.typesetter:initline()
  local l = SILE.measurement("1.2ex")
  SILE.typesetter:pushVglue(-l)
  SILE.typesetter:endline()
  local page = SILE.pagebuilder:collateVboxes(SILE.typesetter.state.outputQueue)
  return page.height + page.depth
end

local shape = function (content)
  SILE.call("noindent")
  local a = SILE.measurement("1em"):absolute() - SILE.measurement("1ex"):absolute()
  SILE.typesetter:pushVglue(-a/2)
  local hbox
  hbox = SILE.call("hbox", {}, content)
  return hbox
end

local splitFrame = function (used, width, height)
  local current = SILE.typesetter.frame
  previous_bottom = current.variables.bottom.value
  current:relax("bottom")
  current:constrain("height", used + height)
  local cont = SILE.newFrame({
    top = current:bottom(),
    left = current:left(),
    right = current:right(),
    bottom = previous_bottom,
    next = current.next,
    id = current.id .. "_cont"
  })
  local wrap = SILE.newFrame({
    top = current:bottom() - height,
    left = current:left() + width,
    right = current:right(),
    bottom = current:bottom(),
    next = cont.id,
    id = current.id .. "_side"
  })
  current.next = wrap.id
end

SILE.registerCommand("refloat", function (options, content)
  local used = lockAdvance()
  if #SILE.typesetter.state.nodes > 0 then
    SU.error("Node queue not empty")
  end
  local hbox = shape(content)
  local w = hbox.width:absolute() + SILE.measurement(options.rightboundary):absolute()
  local h = hbox.height:absolute() + hbox.depth:absolute() + SILE.measurement(options.bottomboundary):absolute()
  splitFrame(used, w, h)
  SILE.typesetter:leaveHmode()
  SILE.call("kern", { width = -SILE.measurement(options.rightboundary) })
end)

SILE.documentState.documentClass.endPar = function (self)
  self:leaveHmode()
  self:leaveHmode()
  local parskip  = SILE.settings.get("document.parskip")
  self:pushVglue(parskip)
  self:leaveHmode()
  self:leaveHmode()
end
