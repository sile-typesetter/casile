local cabook = require("classes.cabook")

local class = pl.class(cabook)
class._name = "cabinding"

local spineoffset = SILE.measurement(CASILE.spine):tonumber() / 2

local spreadFrameset = {
  front = {
    right = "right(page)",
    width = "50%pw-" .. spineoffset,
    top = "top(page)",
    bottom = "bottom(page)",
    next = "back"
  },
  back = {
    left = "left(page)",
    width = "width(front)",
    top = "top(page)",
    bottom = "bottom(page)",
    next = "spine"
  },
  spine = {
    left = "left(front)",
    top = "top(page)-height(spine)",
    width = "height(page)",
    height = "left(front)-right(back)",
    rotate = 90,
    next = "scratch"
  },
  scratch = { -- controling overflow is hard
    left = "left(page)",
    top = "bottom(page)",
    width = 0,
    height = 0
  }
}

local posterFrameset = {
  front = {
    right = "right(page)",
    left = "left(page)",
    top = "top(page)",
    bottom = "bottom(page)",
    next = "scratch"
  },
  scratch = { -- controling overflow is hard
    left = "left(page)",
    top = "bottom(page)",
    width = 0,
    height = 0
  }
}

class.defaultFrameset = spreadFrameset

class.firstContentFrame = "front"

function class:_init (options)

  cabook._init(self, options)

  self:loadPackage("rotate")

  SILE.settings:set("document.parindent", 0, true)
  SILE.settings:set("document.lskip", 0, true)
  SILE.settings:set("document.rskip", 0, true)

  local writeToc = self.packages.tableofcontents.writeToc
  self.packages.tableofcontents.writeToc = function () end
  for i, func in ipairs(self.hooks.finish) do
    if func == writeToc then
      self.hooks.finish[i] = nil
    end
  end

  return self

end

function class:declareOptions ()
  cabook.declareOptions(self)
  local binding
  self:declareOption("binding", function (_, value)
      if value then binding = value end
      return binding
    end)
  self:declareOption("papersize", function (_, size)
    if size then
      self.papersize = size
      local parsed = SILE.papersize(size)
      if binding == "print" or CASILE.layout == "print" then
        self.defaultFrameset = posterFrameset
        SILE.documentState.paperSize = { parsed[1], parsed[2] }
      else
        local spread = parsed[1] * 2 + SILE.measurement(CASILE.spine):tonumber()
        SILE.documentState.paperSize = { spread, parsed[2] }
      end
      SILE.documentState.orgPaperSize = SILE.documentState.paperSize
      SILE.newFrame({
        id = "page",
        left = 0,
        top = 0,
        right = SILE.documentState.paperSize[1],
        bottom = SILE.documentState.paperSize[2]
      })
    end
    return self.papersize
  end)
end

class.setOptions = cabook.setOptions

function class:registerCommands ()

  cabook.registerCommands(self)

  self:registerCommand("meta:surum", function (_, _)
    SILE.typesetter:typeset(CASILE.versioninfo)
  end)

  self:registerCommand("output-right-running-head", function (_, _) end)

end

function class:endPage ()
  SILE.typesetter:chuck()
  cabook.endPage(self)
end

return class
