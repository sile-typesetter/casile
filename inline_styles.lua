SILE.registerCommand("cabook:monofont", function (options, content)
  options.family = options.family or "Hack"
  SILE.call("font", options, content)
end)

SILE.registerCommand("cabook:sansfont", function (options, content)
  options.family = options.family or "Libertinus Sans"
  SILE.call("font", options, content)
end)

SILE.registerCommand("cabook:seriffont", function (options, content)
  options.family = options.family or "Libertinus Serif"
  SILE.call("font", options, content)
end)

SILE.registerCommand("cabook:displayfont", function (options, content)
  options.family = "Libertinus Serif Display"
  SILE.call("font", options, content)
end)

SILE.registerCommand("cabook:partfont", function (options, content)
  options.weight = options.weight or 600
  SILE.call("cabook:sansfont", options, content)
end)

SILE.registerCommand("cabook:partnumfont", function (options, content)
  SILE.call("cabook:partfont", options, content)
end)

SILE.registerCommand("cabook:altseriffont", function (options, content)
  SILE.call("cabook:seriffont", options, content)
end)

SILE.registerCommand("cabook:subparagraphfont", function (options, content)
  options.size = options.size or "11pt"
  options.features = options.features or "+smcp"
  SILE.call("cabook:altseriffont", options, content)
end)

SILE.registerCommand("cabook:footnotefont", function (options, content)
  options.size = options.size or "8.5pt"
  SILE.call("cabook:altseriffont", options, content)
end)

SILE.registerCommand("cabook:chapterfont", function (options, content)
  options.weight = options.weight or 600
  options.size = options.size or "16pt"
  SILE.call("cabook:seriffont", options, content)
end)

SILE.registerCommand("cabook:chapternumfont", function (options, content)
  options.family = options.family or "Libertinus Serif Display"
  options.size = options.size or "11pt"
  SILE.call("font", options, content)
end)

SILE.registerCommand("cabook:sectionfont", function (options, content)
  options.size = options.size or "8.5pt"
  SILE.call("cabook:chapterfont", options, content)
end)

SILE.registerCommand("cabook:font:dedication", function (options, content)
  options.style = options.style or "Italic"
  SILE.call("cabook:seriffont", options, content)
end)

SILE.registerCommand("verbatim:font", function (options, content)
  options.size = options.size or "10pt"
  SILE.call("cabook:monofont", options, content)
end)

SILE.registerCommand("cabook:page-number-font", function (options, content)
  options.style = options.style or "Roman"
  options.size = options.size or "13pt"
  options.weight = options.weight or 400
  SILE.call("cabook:altseriffont", options, content)
end)

SILE.registerCommand("cabook:left-running-head-font", function (options, content)
  options.size = options.size or "12pt"
  SILE.call("cabook:altseriffont", options, content)
end)

SILE.registerCommand("cabook:right-running-head-font", function (options, content)
  options.style = options.style or "Italic"
  options.size = options.size or "12pt"
  SILE.call("cabook:altseriffont", options, content)
end)

SILE.registerCommand("cabook:titlepage-title-font", function (options, content)
  SILE.call("cabook:partnumfont", options, content)
end)

SILE.registerCommand("cabook:titlepage-subtitle-font", function (options, content)
  SILE.call("cabook:partfont", options, content)
end)

SILE.registerCommand("cabook:titlepage-author-font", function (options, content)
  SILE.call("cabook:partfont", options, content)
end)

SILE.registerCommand("tableofcontents:headerfont", function (options, content)
  SILE.call("cabook:partfont", options, content)
end)

SILE.registerCommand("strong", function (options, content)
  SILE.call("font", { weight = 600 }, content)
end)

SILE.registerCommand("em", function (options, content)
  SILE.call("font", { style = "Italic" }, content)
  SILE.call("kern", { width = "1pt" })
end)
