local base = require("packages.base")

local package = pl.class(base)
package._name = "cabook-inline-styles"

function package:registerCommands ()

  -- General purpose font families (no sizes)

  self:registerCommand("cabook:font:serif", function (options, content)
    options.family = options.family or "Libertinus Serif"
    SILE.call("font", options, content)
  end)

  self:registerCommand("cabook:font:sans", function (options, content)
    options.family = options.family or "Libertinus Sans"
    SILE.call("font", options, content)
  end)

  self:registerCommand("cabook:font:mono", function (options, content)
    options.family = options.family or "Hack"
    SILE.call("font", options, content)
  end)

  self:registerCommand("cabook:font:display", function (options, content)
    options.family = options.family or "Libertinus Serif Display"
    SILE.call("font", options, content)
  end)

  self:registerCommand("cabook:font:alt", function (options, content)
    SILE.call("cabook:font:serif", options, content)
  end)

  -- Fonts for specific locations in layouts (including default sizes)

  self:registerCommand("cabook:font:parttitle", function (options, content)
    options.size = options.size or "4%pw"
    options.weight = options.weight or 600
    SILE.call("cabook:font:sans", options, content)
  end)

  self:registerCommand("cabook:font:partno", function (options, content)
    options.size = options.size or "5%pw"
    SILE.call("cabook:font:parttitle", options, content)
  end)

  self:registerCommand("cabook:font:title", function (options, content)
    options.size = options.size or "2em"
    SILE.call("cabook:font:partno", options, content)
  end)

  self:registerCommand("cabook:font:subtitle", function (options, content)
    options.size = options.size or "1.5em"
    SILE.call("cabook:font:parttitle", options, content)
  end)

  self:registerCommand("cabook:font:author", function (options, content)
    options.size = options.size or "1.2em"
    SILE.call("cabook:font:parttitle", options, content)
  end)

  self:registerCommand("cabook:font:folio", function (options, content)
    options.size = options.size or "1.1em"
    options.weight = options.weight or 400
    options.style = options.style or "Roman"
    SILE.call("cabook:font:alt", options, content)
  end)

  self:registerCommand("cabook:font:left-header", function (options, content)
    options.size = options.size or "1.05em"
    SILE.call("cabook:font:alt", options, content)
  end)

  self:registerCommand("cabook:font:right-header", function (options, content)
    options.size = options.size or "1.05em"
    options.style = options.style or "Italic"
    SILE.call("cabook:font:left-header", options, content)
  end)

  self:registerCommand("tableofcontents:headerfont", function (options, content)
    options.size = options.size or "1.4em"
    SILE.call("cabook:font:parttitle", options, content)
  end)

  self:registerCommand("cabook:font:dedication", function (options, content)
    options.size = options.size or "1.15em"
    options.style = options.style or "Italic"
    SILE.call("cabook:font:serif", options, content)
  end)

  self:registerCommand("cabook:font:footnote", function (options, content)
    options.size = options.size or "0.74em"
    SILE.call("cabook:font:alt", options, content)
  end)

  self:registerCommand("cabook:font:chaptertitle", function (options, content)
    options.weight = options.weight or 600
    options.size = options.size or "1.4em"
    SILE.call("cabook:font:serif", options, content)
  end)

  self:registerCommand("cabook:font:chapterno", function (options, content)
    options.family = options.family or "Libertinus Serif Display"
    options.size = options.size or "0.96em"
    SILE.call("font", options, content)
  end)

  self:registerCommand("cabook:font:sectiontitle", function (options, content)
    options.size = options.size or "0.92em"
    SILE.call("cabook:font:chaptertitle", options, content)
  end)

  self:registerCommand("cabook:font:subsectiontitle", function (options, content)
    options.size = options.size or "0.84em"
    SILE.call("cabook:font:sectiontitle", options, content)
  end)

  self:registerCommand("cabook:font:subsubsectiontitle", function (options, content)
    options.size = options.size or "0.76em"
    SILE.call("cabook:font:sectiontitle", options, content)
  end)

  self:registerCommand("cabook:font:subparagraph", function (options, content)
    options.size = options.size or "0.96em"
    options.features = options.features or "+smcp"
    SILE.call("cabook:font:alt", options, content)
  end)

  -- Overrides for SILE style commands

  self:registerCommand("code", function (options, content)
    SILE.call("cabook:font:mono", options, content)
  end)

  self:registerCommand("em", function (_, content)
    SILE.call("font", { style = "Italic" }, content)
    SILE.call("kern", { width = "1pt" })
  end)

  self:registerCommand("strong", function (_, content)
    SILE.call("font", { weight = 600 }, content)
  end)

  self:registerCommand("verbatim:font", function (options, content)
    options.size = options.size or "0.86em"
    SILE.call("cabook:font:mono", options, content)
  end)

end

return package
