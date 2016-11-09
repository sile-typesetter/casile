publisher = "viachristus"
local book = SILE.require("classes/book")
local vc = book { id = "vc" }

-- Add a shortcut method to dump tables in a pretty-print format to stderr
local dump = require("pl.pretty").dump
d = function(t) dump(t, "/dev/stderr") end

vc.endPage = function (self)
  book:moveTocNodes()

  if (not SILE.scratch.headers.skipthispage) then
	SILE.settings.pushState()
	SILE.settings.reset()
	if (book:oddPage() and SILE.scratch.headers.right) then
	  SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
		SILE.call("book:right-running-head")
	  end)
	elseif (not(book:oddPage()) and SILE.scratch.headers.left) then
	  SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
		SILE.call("book:left-running-head")
	  end)
	end
	SILE.settings.popState()
  else
	SILE.scratch.headers.skipthispage = false
  end
  return book.endPage(book)
end

return vc
