SILE.registerCommand("book:monofont", function (options, content)
  options.family = options.family or "Hack"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:sansfont", function (options, content)
  options.family = options.family or "Libertinus Sans"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:seriffont", function (options, content)
  options.family = options.family or "Libertinus Serif"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:displayfont", function (options, content)
  options.family = "Libertinus Serif Display"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:partfont", function (options, content)
  options.weight = options.weight or 600
  SILE.call("book:sansfont", options, content)
end)

SILE.registerCommand("book:partnumfont", function (options, content)
  SILE.call("book:partfont", options, content)
end)

SILE.registerCommand("book:altseriffont", function (options, content)
  SILE.call("book:seriffont", options, content)
end)

SILE.registerCommand("book:subparagraphfont", function (options, content)
  options.size = options.size or "11pt"
  options.features = options.features or "+smcp"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:footnotefont", function (options, content)
  options.size = options.size or "8.5pt"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:chapterfont", function (options, content)
  options.weight = options.weight or 600
  options.size = options.size or "16pt"
  SILE.call("book:seriffont", options, content)
end)

SILE.registerCommand("book:chapternumfont", function (options, content)
  options.family = options.family or "Libertinus Serif Display"
  options.size = options.size or "11pt"
  SILE.call("font", options, content)
end)

SILE.registerCommand("book:sectionfont", function (options, content)
  options.size = options.size or "8.5pt"
  SILE.call("book:chapterfont", options, content)
end)

SILE.registerCommand("verbatim:font", function (options, content)
  options.size = options.size or "10pt"
  SILE.call("book:monofont", options, content)
end)

SILE.registerCommand("book:page-number-font", function (options, content)
  options.style = options.style or "Roman"
  options.size = options.size or "13pt"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:left-running-head-font", function (options, content)
  options.size = options.size or "12pt"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:right-running-head-font", function (options, content)
  options.style = options.style or "Italic"
  options.size = options.size or "12pt"
  SILE.call("book:altseriffont", options, content)
end)

SILE.registerCommand("book:titlepage-title-font", function (options, content)
  SILE.call("book:partnumfont", options, content)
end)

SILE.registerCommand("book:titlepage-subtitle-font", function (options, content)
  SILE.call("book:partfont", options, content)
end)

SILE.registerCommand("book:titlepage-author-font", function (options, content)
  SILE.call("book:partfont", options, content)
end)

SILE.registerCommand("tableofcontents:headerfont", function (options, content)
  SILE.call("book:partfont", options, content)
end)
SILE.registerCommand("strong", function (options, content)
  SILE.call("font", { weight = 600 }, content)
end)
